// Package sched: 调度系统 (里程碑6) —— 旁路对账与补偿的统一框架。
//
// 定位 (设计红线): 调度系统绝不进主链路。它是独立进程 yim-sched,
// 挂了只影响"补偿变慢", 不影响任何收发; 它做的每件事都必须幂等
// (条件 UPDATE / INSERT IGNORE / 客户端 seq 去重), 重复执行无正确性代价。
//
// 架构 (选主 → 广播 → 抢占 → 幂等, 四级防重复):
//
//	etcd 选主   : concurrency.Election, 同一时刻只有 leader 触发任务
//	任务分片广播 : leader 把一次触发拆成 N 个分片描述, 投入 Redis 队列
//	worker 抢占 : 全部实例 (含 follower) BRPOP 认领分片 —— 水平扩 worker 不改代码
//	SETNX 执行幂等: 认领后抢 sched:lock:{task}:{window}:{shard}, TTL 兜底;
//	               防 leader 双主/重触发导致同窗口重复入队
//
// 降级哲学 (与 cache.Cache 同一原则): Redis 不可用时退化为 leader 单机
// 内联执行 —— 队列和锁都是优化组件 (并行度/防重), 任务本身的幂等性
// 才是正确性锚点, 两个都缺席也只是"补偿被单机慢速执行"。
//
// 为什么不复用 Kafka: 调度事件是低频控制面信号, 为它维护 topic/消费组
// 的运维成本大于收益; Redis list 的 BRPOP 天然就是抢占语义。
package sched

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
	"go.etcd.io/etcd/client/v3"
	"go.etcd.io/etcd/client/v3/concurrency"
	"go.uber.org/zap"

	"github.com/yim/internal/logger"
)

// Task 旁路任务契约: 分片化的周期任务。
// Shards 返回分片标识 (如 DB 编号 / uid 取模桶), Exec 单分片执行。
// Exec 必须幂等 —— 调度框架提供 at-least-once, 任务自己保证恰好一次效果。
type Task interface {
	Name() string
	Interval() time.Duration
	Shards() []string
	Exec(ctx context.Context, shard string) error
}

const (
	electionPrefix = "/yim/sched/leader"
	sessionTTL     = 10 // 秒: 心跳断 10s 即改选, leader 切换窗口
	lockTTL        = 2 * time.Minute
	popTimeout     = time.Second
)

// shardDesc 队列里的分片描述: window 是触发的时间桶, 同任务同窗口
// 重复触发时靠 lock 键去重。
type shardDesc struct {
	Task   string `json:"task"`
	Window int64  `json:"window"`
	Shard  string `json:"shard"`
}

func queueKey(task string) string { return "sched:q:" + task }
func lockKey(d shardDesc) string {
	return fmt.Sprintf("sched:lock:%s:%d:%s", d.Task, d.Window, d.Shard)
}

// Scheduler 多实例对等的调度器: 大家都跑 worker 抢队列, 谁是 leader 谁触发。
type Scheduler struct {
	cli   *clientv3.Client
	rdb   *redis.Client // 可为 nil: 降级为 leader 内联执行
	tasks []Task
	self  string // 实例标识 (日志/选举 value)
}

func New(cli *clientv3.Client, rdb *redis.Client, self string, tasks ...Task) *Scheduler {
	return &Scheduler{cli: cli, rdb: rdb, self: self, tasks: tasks}
}

// Run 阻塞运行: 后台起 worker 消费循环, 主 goroutine 走选举循环
// (leader 掉线自动重新 campaign, session TTL 内的空窗由任务幂等兜底)。
func (s *Scheduler) Run(ctx context.Context) {
	for _, t := range s.tasks {
		go s.workerLoop(ctx, t)
	}
	for {
		if err := s.leadLoop(ctx); err != nil && ctx.Err() == nil {
			logger.L.Warn("sched election retry", zap.Error(err), zap.String("self", s.self))
			time.Sleep(time.Second)
			continue
		}
		return // ctx 取消, 正常停机
	}
}

// leadLoop 竞选 leader, 当选后为每个任务起触发 ticker;
// 失去 leadership (session 过期/被夺) 时 ticker 退出, 返回后重新竞选。
func (s *Scheduler) leadLoop(ctx context.Context) error {
	session, err := concurrency.NewSession(s.cli, concurrency.WithTTL(sessionTTL), concurrency.WithContext(ctx))
	if err != nil {
		return fmt.Errorf("etcd session: %w", err)
	}
	defer session.Close()

	election := concurrency.NewElection(session, electionPrefix)
	if err := election.Campaign(ctx, s.self); err != nil {
		return fmt.Errorf("campaign: %w", err)
	}
	logger.L.Info("sched leader elected", zap.String("self", s.self))

	done := make(chan struct{}, len(s.tasks))
	for _, t := range s.tasks {
		go s.triggerLoop(ctx, t, done)
	}

	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-session.Done(): // 心跳断线, leadership 丢失
		logger.L.Warn("sched leadership lost (session expired)", zap.String("self", s.self))
		return nil // 外层重新竞选
	}
}

// triggerLoop 单任务触发器: 按间隔把全部分片入队。
// window = 当前时间除以间隔的时间桶 —— 同桶内重复触发 (双主/重启)
// 入队多次, 但 worker 侧 SETNX 锁保证同 (task, window, shard) 只执行一次。
func (s *Scheduler) triggerLoop(ctx context.Context, t Task, done chan struct{}) {
	defer func() { done <- struct{}{} }()
	ticker := time.NewTicker(t.Interval())
	defer ticker.Stop()
	// 启动即触发一次 (进程重启后尽快补一轮对账)
	s.trigger(ctx, t)
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			s.trigger(ctx, t)
		}
	}
}

func (s *Scheduler) trigger(ctx context.Context, t Task) {
	window := time.Now().Unix() / int64(t.Interval().Seconds())
	for _, shard := range t.Shards() {
		desc := shardDesc{Task: t.Name(), Window: window, Shard: shard}
		if s.rdb == nil {
			// 降级: 无队列无锁, leader 内联直接执行 (任务幂等兜底正确性)
			s.execInline(ctx, desc)
			continue
		}
		b, _ := json.Marshal(desc)
		if err := s.rdb.RPush(ctx, queueKey(t.Name()), b).Err(); err != nil {
			logger.L.Error("sched enqueue (fallback inline)",
				zap.Error(err), zap.String("task", t.Name()), zap.String("shard", shard))
			s.execInline(ctx, desc) // 入队失败就地执行, 不让一轮对账整体落空
		}
	}
	logger.L.Debug("sched triggered", zap.String("task", t.Name()), zap.Int("shards", len(t.Shards())))
}

// workerLoop 分片消费者: BRPOP 抢占认领 → SETNX 执行锁 → 单分片执行。
// Redis 降级时 worker 无事可做 (leader 已内联), 空转返回。
func (s *Scheduler) workerLoop(ctx context.Context, t Task) {
	if s.rdb == nil {
		return
	}
	for {
		res, err := s.rdb.BLPop(ctx, popTimeout, queueKey(t.Name())).Result()
		if err != nil {
			if ctx.Err() != nil {
				return
			}
			if err != redis.Nil { // redis.Nil = 空队列超时, 正常空转
				logger.L.Warn("sched pop", zap.Error(err))
				time.Sleep(500 * time.Millisecond)
			}
			continue
		}
		// BLPop 返回 [key, value]
		if len(res) < 2 {
			continue
		}
		var d shardDesc
		if json.Unmarshal([]byte(res[1]), &d) != nil {
			logger.L.Error("sched bad descriptor, skip", zap.String("raw", res[1]))
			continue
		}
		s.claim(ctx, d)
	}
}

// claim 认领分片: SETNX 抢执行锁, 抢到才执行 —— 同窗口重复入队在这里被吸收。
func (s *Scheduler) claim(ctx context.Context, d shardDesc) {
	ok, err := s.rdb.SetNX(ctx, lockKey(d), s.self, lockTTL).Result()
	if err != nil {
		// 锁判断不了: 宁可重复执行 (任务幂等), 不丢任务
		logger.L.Warn("sched lock check failed, executing anyway", zap.Error(err))
	} else if !ok {
		return // 已被认领
	}

	execCtx, cancel := context.WithTimeout(ctx, lockTTL)
	defer cancel()
	start := time.Now()
	if err := s.runTask(execCtx, d); err != nil {
		logger.L.Error("sched shard exec",
			zap.Error(err), zap.String("task", d.Task), zap.String("shard", d.Shard))
		return
	}
	logger.L.Debug("sched shard done", zap.String("task", d.Task),
		zap.String("shard", d.Shard), zap.Duration("elapsed", time.Since(start)))
}

func (s *Scheduler) runTask(ctx context.Context, d shardDesc) error {
	for _, t := range s.tasks {
		if t.Name() == d.Task {
			return t.Exec(ctx, d.Shard)
		}
	}
	return fmt.Errorf("unknown task %s", d.Task)
}

// execInline 无 Redis 时的降级执行路径 (leader 同步调, 无锁无队列)。
func (s *Scheduler) execInline(ctx context.Context, d shardDesc) {
	execCtx, cancel := context.WithTimeout(ctx, lockTTL)
	defer cancel()
	if err := s.runTask(execCtx, d); err != nil {
		logger.L.Error("sched inline exec",
			zap.Error(err), zap.String("task", d.Task), zap.String("shard", d.Shard))
	}
}

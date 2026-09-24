// delivery: 投递层 (三道防线的主体, 里程碑4; Kafka 化重构于 Kafka 接入)。
//
// 职责链: PushEvent → deliver → 查会话成员 → 逐成员广播 comet
//
//	在线:  注册重试定时 (200ms→800ms→3.2s), 等 ACK 取消; 3 次未确认 → 离线箱
//	离线:  写离线箱, SYNC/重连时补拉
//
// 双形态 (同一 Deliverer 核心, 换队列实现不换逻辑):
//
//	进程内: JobPusher  —— channel 消费 (Kafka 不可用时的降级形态)
//	Kafka:  cmd/yim-job —— 消费者组消费 yim.push / yim.ack (标准形态)
//
// channel 满 / Kafka 写失败均丢弃不阻塞发送主链路:
// 消息已落库 (local_message 有投递任务), 防线3 扫描补偿兜底。
package message

import (
	"context"
	"os"
	"strings"
	"sync"
	"time"

	"go.uber.org/zap"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/store"
	"github.com/yim/internal/timewheel"
)

// 重试参数: 指数退避, 3 次后转离线箱 (防线1 → 防线2)。
// 一级 1s: 必须大于 ACK 回路 RTT (push → 客户端 ACK → comet → message →
// yim.ack topic → job 消费), 否则正常确认的推送也会被重推 —— 2000/s 压测
// 实测: broker 饱和时 ACK 消费延迟 >200ms, 200ms 定时让 81% 消息被重推,
// 重推又加重 broker 负载 (正反馈风暴)。1s 切断该环; 真丢推的代价只是晚 1s 补。
var retryDelays = []time.Duration{1 * time.Second, 4 * time.Second, 16 * time.Second}

const deliveryQueueSize = 1024

// Acker ACK 回路接口: 取消投递重试定时。
// 进程内形态 = 直删注册表; Kafka 形态 = 发 yim.ack 事件给 Job。
type Acker interface {
	AckPush(uid, convID, ackSeq int64)
}

// RetryTimer 重试定时抽象: 压测里程碑 7 的可切换点。
//
//	native = time.AfterFunc: 每任务一个 runtime 堆节点, O(log n) 插入
//	wheel  = 层级时间轮: O(1) 桶插入, ±tick 精度 (重试退避容忍)
//
// 取消语义两边一致: 都是懒删除 —— 定时器照常触发, 回调里 pendingAcks.alive()
// 校验失效后静默退出, ACK 只是标记不删定时器。
type RetryTimer interface {
	AfterFunc(d time.Duration, fn func())
}

// NativeTimer time.AfterFunc 形态 (对照基准)。
type NativeTimer struct{}

func (NativeTimer) AfterFunc(d time.Duration, fn func()) { time.AfterFunc(d, fn) }

// WheelTimer 层级时间轮形态 (每进程一个 Wheel, 由调用方 Start/Stop)。
type WheelTimer struct{ W *timewheel.Wheel }

func (t WheelTimer) AfterFunc(d time.Duration, fn func()) { t.W.After(d, fn) }

// NewWheelTimer 便捷构造: tick 100ms × 512 槽 = 第一级覆盖 51.2s,
// 重试退避 (200ms/800ms/3.2s) 全落第一级; 溢出轮按需懒建。
func NewWheelTimer() *WheelTimer {
	return &WheelTimer{W: timewheel.Start(100*time.Millisecond, 512)}
}

// DefaultRetryTimer 按 YIM_RETRY_TIMER 选定时实现:
// wheel (默认, 标准形态) | native (压测对照 / 时间轮异常时的回退)。
func DefaultRetryTimer() RetryTimer {
	switch os.Getenv("YIM_RETRY_TIMER") {
	case "native":
		logger.L.Warn("retry timer = native time.AfterFunc (benchmark/fallback mode)")
		return NativeTimer{}
	default:
		return NewWheelTimer()
	}
}

// ============================================================
// Deliverer 投递核心: 纯逻辑, 无队列无 goroutine。
// 进程内 JobPusher 与 Kafka 消费者 (cmd/yim-job) 共用同一实例逻辑。
// ============================================================

type Deliverer struct {
	db    *store.MySQL
	seqs  SeqClient
	comet *cometCluster
	cache *cache.Cache // 可为 nil: 成员查询直接走 DB

	timer RetryTimer // 重试定时实现: native (默认) / wheel
	pend  pendingAcks
	marks *markBatcher
}

func NewDeliverer(db *store.MySQL, seqs SeqClient, comet *cometCluster, c *cache.Cache) *Deliverer {
	d := &Deliverer{db: db, seqs: seqs, comet: comet, cache: c, timer: NativeTimer{}}
	d.marks = newMarkBatcher(d)
	return d
}

// UseTimer 切换重试定时实现 (main 装配时按 YIM_RETRY_TIMER 选择)。
func (d *Deliverer) UseTimer(t RetryTimer) { d.timer = t }

// Deliver 单个投递事件 (panic 不许击穿进程 —— 发送主链路已提交,
// 兜底语义 = 防线3 扫描 local_message 补偿)。
func (d *Deliverer) Deliver(e PushEvent) {
	defer func() {
		if r := recover(); r != nil {
			logger.L.Error("deliver panic (recovered, scan-compensation will recover)",
				zap.Any("panic", r), zap.Int64("conv_id", e.ConvID), zap.Int64("max_seq", e.MaxSeq))
		}
	}()
	d.deliver(e)
}

// deliver 单个投递事件: 查成员 → 逐成员广播。
// 群聊扇出 N 成员 = N 次 Push RPC, 生产环境批量接口优化 (当前 count 小可接受)。
// YIM_DELIVER_TRACE=1 时输出分段耗时 (压测瓶颈定位用, 观测代码不进主路径)。
func (d *Deliverer) deliver(e PushEvent) {
	var (
		trace  = deliverTrace
		t0     = clock()
		msMem  int64
		msBump int64
		msPush int64
		msMark int64
		msReg  int64
	)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	members, err := d.convMembers(ctx, e.ConvID)
	if err != nil {
		logger.L.Error("conv members lookup", zap.Error(err), zap.Int64("conv_id", e.ConvID))
		return // 留给防线3: local_message 仍是待投递状态
	}
	if trace {
		msMem = clock() - t0
	}

	for _, uid := range members {
		if uid == e.FromUID {
			continue // 发送者自己不推送
		}
		// 接收者 sync seq 推进: 无论在线离线, "有新消息"都该反映到水位,
		// 否则 CONNECT_RSP 下发的 user_sync_seq 无法触发重连后的 SYNC
		tb := clock()
		syncSeq, _ := d.seqs.BumpSyncSeq(ctx, uid)
		msBump += clock() - tb

		tp := clock()
		// 定点推送 (里程碑8): route:{uid} 命中只推在线实例, miss/Redis 不可用
		// 回退全实例广播 —— cache 为 nil 时 PushRouted 内部直走广播形态
		delivered := d.comet.PushRouted(ctx, d.cache, uid, e.ConvID, e.MaxSeq, e.FromUID, syncSeq)
		msPush += clock() - tp
		if deliverTrace {
			tr := clock()
			if delivered {
				d.pend.register(uid, e.ConvID, e.MaxSeq, d.retryFire(e, uid))
			} else {
				d.writeOfflineBox(uid, e.ConvID, e.MaxSeq, "offline")
			}
			msReg += clock() - tr
		} else if delivered {
			d.pend.register(uid, e.ConvID, e.MaxSeq, d.retryFire(e, uid))
		} else {
			d.writeOfflineBox(uid, e.ConvID, e.MaxSeq, "offline")
		}
	}

	// 扇出完成 → local_message.status=1 (投递闭环): 防线3 扫表只看 status=0,
	// 没这步扫表会对每条消息重复补偿一次。成员查询失败在上面的 return 提前退出,
	// status 留 0 由调度重扫 —— 语义即"先处理后提交" (与 Kafka offset 一致)。
	// 单接收者的重试/落箱是扇出内部的事, 不阻塞整事件标记。
	if e.MsgID != 0 {
		tm := clock()
		d.marks.add(e.ConvID, e.MsgID) // 攒批回写, 见 markBatcher
		if trace {
			msMark = clock() - tm
		}
	}
	if trace {
		logger.L.Info("deliver trace",
			zap.Int64("conv", e.ConvID), zap.Int64("seq", e.MaxSeq),
			zap.Int64("members_ms", msMem), zap.Int64("bump_ms", msBump),
			zap.Int64("push_ms", msPush), zap.Int64("mark_ms", msMark),
			zap.Int64("reg_ms", msReg),
			zap.Int64("total_ms", clock()-t0), zap.Int("members", len(members)))
	}
}

var deliverTrace = os.Getenv("YIM_DELIVER_TRACE") == "1"

func clock() int64 { return time.Now().UnixMilli() }

// markBatcher 投递完成标记的攒批回写 (里程碑 7 收尾优化)。
//
// 动机: mark 回写是每消息一次同步 UPDATE, 单机实测 8.6ms (负载下, 空闲
// 3.5ms), 8 reader 的消费天花板 = 8 / 10ms ≈ 800/s, mark 占 90% —— 与
// Kafka offset 攒批提交同一逻辑: 闭环标记是 best-effort, 攒批引入的
// "崩溃丢失窗口" (≤50ms 未回写, 留 status=0) 由防线3 扫表补偿重推 +
// 客户端 seq 去重兜底, 语义与单条回写完全一致。
//
// 结构: 按 shard 分桶 (mark 路由到 yim_msg_0/1), 每桶满 markFlushSize 或
// markFlushDelay 到期触发一次 multi-row UPDATE (row constructor 走 PK)。
type markBatcher struct {
	d *Deliverer

	mu   sync.Mutex
	buf  map[int]map[[2]int64]struct{} // shard db 索引 → (conv_id, msg_id) 集合
	arms map[int]bool                  // 每桶一个在途 flush 定时器
}

const (
	markFlushSize  = 32
	markFlushDelay = 50 * time.Millisecond
)

func newMarkBatcher(d *Deliverer) *markBatcher {
	return &markBatcher{d: d, buf: make(map[int]map[[2]int64]struct{}), arms: make(map[int]bool)}
}

// add 缓冲一个完成标记, 满/到期批量回写。
func (b *markBatcher) add(convID, msgID int64) {
	shard := store.RouteMsg(convID).DBIndex
	b.mu.Lock()
	if b.buf[shard] == nil {
		b.buf[shard] = make(map[[2]int64]struct{})
	}
	b.buf[shard][[2]int64{convID, msgID}] = struct{}{}
	full := len(b.buf[shard]) >= markFlushSize
	needArm := !full && !b.arms[shard]
	if needArm {
		b.arms[shard] = true
	}
	b.mu.Unlock()

	if full {
		go b.flush(shard) // 异步回写: UPDATE 幂等 (status=0 条件写), 同会话并发
		                  // flush 不重叠 (buf 交换在锁内), 调用方不许阻塞在 DB 上
		                  // —— 同步版每 32 条付一次批量 UPDATE 时延, 实测摊薄 3ms/条
		return
	}
	if needArm {
		time.AfterFunc(markFlushDelay, func() { b.flush(shard) })
	}
}

// flush 回写一桶 (定时器侧与满触发侧都可能进来, 幂等)。
func (b *markBatcher) flush(shard int) {
	b.mu.Lock()
	rows := b.buf[shard]
	b.buf[shard] = nil
	b.arms[shard] = false
	b.mu.Unlock()
	if len(rows) == 0 {
		return
	}

	// UPDATE local_message SET status=1 WHERE status=0 AND (conv_id,msg_id) IN ((..),(..))
	// row constructor 命中 PRIMARY KEY (conv_id, msg_id), 一次往返替代 N 次
	var (
		sb    strings.Builder
		args  = make([]interface{}, 0, len(rows)*2)
		first = true
	)
	sb.WriteString("UPDATE local_message SET status = 1 WHERE status = 0 AND (conv_id, msg_id) IN (")
	for k := range rows {
		if !first {
			sb.WriteByte(',')
		}
		first = false
		sb.WriteString("(?,?)")
		args = append(args, k[0], k[1])
	}
	sb.WriteByte(')')
	if _, err := b.d.db.ShardDB(store.MsgShard{DBIndex: shard}).ExecContext(context.Background(), sb.String(), args...); err != nil {
		logger.L.Warn("mark local_message batch (scan-compensation will rescan)",
			zap.Error(err), zap.Int("shard", shard), zap.Int("rows", len(rows)))
	}
}

// AckPush 客户端累积确认: seq <= ackSeq 的待确认推送全部取消重试。
// 幂等——重复 ACK 只是重复删除。
func (d *Deliverer) AckPush(uid, convID, ackSeq int64) {
	d.pend.ack(uid, convID, ackSeq)
}

// retryFire 生成重试触发闭包: 第 level 级在 retryDelays[level-1] 后重推,
// 共重试 len(retryDelays) 次, 仍未确认 → 移出注册表 + 写离线箱。
// 定时实现经 RetryTimer 可切换 (native=time.AfterFunc / wheel=层级时间轮);
// 万级待确认时 AfterFunc 的堆节点内存与全局锁竞争可见, 时间轮 O(1) 插入。
func (d *Deliverer) retryFire(e PushEvent, uid int64) func(level int) {
	return func(level int) {
		d.timer.AfterFunc(retryDelays[level-1], func() {
			if !d.pend.alive(uid, e.ConvID, e.MaxSeq) {
				return // 已 ACK, 定时器空转退出
			}
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()
			logger.L.Info("push retry", zap.Int64("uid", uid),
				zap.Int64("conv_id", e.ConvID), zap.Int("retry", level))
			d.comet.PushRouted(ctx, d.cache, uid, e.ConvID, e.MaxSeq, e.FromUID, 0)

			if level >= len(retryDelays) {
				// 防线1 耗尽 → 防线2: 离线箱 (调度系统扫描是防线3)
				d.pend.remove(uid, e.ConvID, e.MaxSeq)
				d.writeOfflineBox(uid, e.ConvID, e.MaxSeq, "ack_timeout")
				return
			}
			d.pend.schedule(uid, e.ConvID, e.MaxSeq, level+1)
		})
	}
}

// convMembers 读会话成员。缓存路径见 cache.ConvMembers (cache-aside, TTL 10min);
// member_uids 整列读回 Go 侧解析。
func (d *Deliverer) convMembers(ctx context.Context, convID int64) ([]int64, error) {
	return d.cache.ConvMembers(ctx, d.db, convID)
}

// writeOfflineBox 防线2 落点: 待确认超限/目标离线都归入离线箱。
// 幂等: PRIMARY KEY (uid, conv_id, seq), INSERT IGNORE 重复投递不重复落箱。
func (d *Deliverer) writeOfflineBox(uid, convID, seq int64, reason string) {
	_, err := d.db.Meta.ExecContext(context.Background(),
		"INSERT IGNORE INTO offline_box (uid, conv_id, msg_id, seq, status, create_time_ms) VALUES (?,?,?,?,0,?)",
		uid, convID, 0, seq, time.Now().UnixMilli())
	if err != nil {
		logger.L.Error("offline box write", zap.Error(err),
			zap.Int64("uid", uid), zap.Int64("conv_id", convID))
	}
	logger.L.Info("offline box", zap.Int64("uid", uid),
		zap.Int64("conv_id", convID), zap.Int64("seq", seq), zap.String("reason", reason))
}

// ---- pending 注册表: 内存态, 重启丢失 = 多重推一次, 客户端按 seq 去重 ----

// 注册表结构: 按 (uid, convID) 分桶, 桶内 seq → 重试闭包。
// 索引设计动机 (压测 1000/s 实测教训): ACK 累积确认需按 (uid,convID,seq<=ackSeq)
// 匹配删除, 若用全局 map 线性扫描 (O(全部 pending)) 且持锁, backlog 大时形成
// 反馈环 —— handle 越慢 → pending 越多 → 每个 ACK 扫越长 → handle 更慢
// (实测 8 reader 每条 10ms+)。分桶后 ACK 只扫本会话桶, O(该会话在途数)。

type pendConvKey struct{ uid, convID int64 }

type pendingAcks struct {
	mu sync.Mutex
	m  map[pendConvKey]map[int64]func(level int) // (uid,convID) → seq → fire
}

func (p *pendingAcks) bucket(ck pendConvKey, create bool) map[int64]func(level int) {
	b, ok := p.m[ck]
	if !ok && create {
		b = make(map[int64]func(level int))
		p.m[ck] = b
	}
	return b
}

func (p *pendingAcks) register(uid, convID, seq int64, fire func(level int)) {
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.m == nil {
		p.m = make(map[pendConvKey]map[int64]func(level int))
	}
	b := p.bucket(pendConvKey{uid, convID}, true)
	if _, ok := b[seq]; ok {
		return // 已在等待确认 (重复推送事件)
	}
	b[seq] = fire
	go fire(1) // 启动第一级定时
}

// schedule 安排下一级重试 (级别推进由 retryFire 的闭包参数维护)
func (p *pendingAcks) schedule(uid, convID, seq int64, level int) {
	p.mu.Lock()
	fire := p.m[pendConvKey{uid, convID}][seq]
	p.mu.Unlock()
	if fire != nil {
		go fire(level)
	}
}

// alive 校验该 key 仍在等待确认 (防 ACK 后定时器空转重推)
func (p *pendingAcks) alive(uid, convID, seq int64) bool {
	p.mu.Lock()
	defer p.mu.Unlock()
	_, ok := p.m[pendConvKey{uid, convID}][seq]
	return ok
}

func (p *pendingAcks) ack(uid, convID, ackSeq int64) {
	p.mu.Lock()
	defer p.mu.Unlock()
	b := p.m[pendConvKey{uid, convID}]
	for seq := range b {
		if seq <= ackSeq {
			delete(b, seq) // 幂等——重复 ACK 只是重复删除
		}
	}
	if len(b) == 0 {
		delete(p.m, pendConvKey{uid, convID}) // 空桶回收
	}
}

func (p *pendingAcks) remove(uid, convID, seq int64) {
	p.mu.Lock()
	defer p.mu.Unlock()
	ck := pendConvKey{uid, convID}
	delete(p.m[ck], seq)
	if len(p.m[ck]) == 0 {
		delete(p.m, ck)
	}
}

// ============================================================
// JobPusher 进程内形态: Deliverer + channel 队列。
// Kafka 可用时的降级形态 (YIM_KAFKA_BROKERS 未配置), 契约与 Kafka 一致。
// ============================================================

type JobPusher struct {
	*Deliverer

	chans  []chan PushEvent // conv-hash 分片: 同会话永远进同一 channel, 多 worker 并行且保序
	stopCh chan struct{}
	wg     sync.WaitGroup
}

// DeliverWorkers 投递 worker 数: 单 goroutine 每条 ~1.2ms (comet RPC 为主)
// 排水 ~800/s, 2000/s 发送下队列必满 —— 事件被丢, 实时路径断裂掉进防线3
// 兜底 (分钟级)。8 worker × 800/s = 6400/s, 覆盖当前目标速率。
// 导出给 main 装配 (Run 参数须等于分片数, 少启 = 分片无人消费)。
const DeliverWorkers = 8

func NewJobPusher(db *store.MySQL, seqs SeqClient, comet *cometCluster, c *cache.Cache) *JobPusher {
	p := &JobPusher{
		Deliverer: NewDeliverer(db, seqs, comet, c),
		stopCh:    make(chan struct{}),
	}
	for i := 0; i < DeliverWorkers; i++ {
		p.chans = append(p.chans, make(chan PushEvent, deliveryQueueSize))
	}
	return p
}

// Run 启动投递 worker (Kafka 形态下这里是 Job 进程的消费者组)
func (p *JobPusher) Run(workers int) {
	if workers <= 0 || workers > len(p.chans) {
		workers = len(p.chans)
	}
	for i := 0; i < workers; i++ {
		idx := i
		p.wg.Add(1)
		go p.consumeLoop(idx)
	}
	logger.L.Info("job pusher started (in-process channel mode)",
		zap.Int("workers", workers), zap.Int("shards", len(p.chans)))
}

func (p *JobPusher) Close() {
	close(p.stopCh)
	p.wg.Wait()
}

// Push 非阻塞快速路径 + 阻塞背压慢路径 (conv-hash 选片)。
// 队列满 = 投递容量瞬时不足: 先等待 (与 Kafka 形态的 writer 队列阻塞同语义
// —— 发送已落库, 背压的是投递容量, 表现为发送延迟上升而不是消息丢失),
// 等待超过 2s (真过载) 才放弃, 走防线3 扫描补偿兜底。
// 顺序: 同会话永远进同一 channel (FIFO), 多 worker 并行不破坏会话内顺序。
func (p *JobPusher) Push(ctx context.Context, e PushEvent) {
	ch := p.chans[e.ConvID%int64(len(p.chans))]
	select {
	case ch <- e:
		return
	default:
	}
	t := time.NewTimer(2 * time.Second)
	defer t.Stop()
	select {
	case ch <- e:
	case <-t.C:
		logger.L.Warn("delivery queue full after backpressure wait, dropped (scan-compensation will recover)",
			zap.Int64("conv_id", e.ConvID), zap.Int64("max_seq", e.MaxSeq))
	}
}

func (p *JobPusher) consumeLoop(idx int) {
	defer p.wg.Done()
	for {
		select {
		case <-p.stopCh:
			return
		case e := <-p.chans[idx]:
			p.Deliver(e)
		}
	}
}

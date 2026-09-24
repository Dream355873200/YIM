// compensation.go: 旁路对账任务 (里程碑6 调度系统的执行体)。
//
// 全部任务满足三条纪律:
//   - 幂等: 条件 UPDATE (AND status=0 / AND last_seq<?) / 客户端 seq 去重,
//     调度框架 at-least-once 重复触发无正确性代价
//   - 旁路: 只读主链路数据 + 条件写, 不被主链路依赖, 挂了只影响补偿时延
//   - 分片: Shards 按库/取模桶切分, 多 worker 抢占并行执行
//
// 与三道防线的关系: 防线1 (重试定时) 防线2 (离线箱) 都有内存态/单次性,
// 本文件的 scanCompensation 是防线3 的实体 —— 一切内存态丢失、队列丢弃、
// 进程崩溃的漏网之鱼, 最终被周期扫表追回。
package message

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"github.com/yim/internal/logger"
	"github.com/yim/internal/store"
)

// scanGrace 扫描补偿的宽限期: 正常投递链路 (事务提交 → Kafka 异步写 →
// Job 消费 → 扇出) 端到端秒级, 超过宽限期仍 status=0 的才算"漏网"。
// 宽限期避免了"每条消息被调度重复推一次"的系统性放大 —— 定值必须盖过
// 高负载下的投递排队 + mark 异步落库滞后 (2000/s 压测实测: e2e p50 4.2s
// 时 10s 宽限下 2.76% 推送被扫描重复; 60s 后归零)。补偿是分钟级防线,
// 宽限期取大不取小。
const scanGrace = 60 * time.Second

// scanBatch 单分片单轮的批量上限: 有界执行, 不让一轮任务拖死 worker。
const scanBatch = 200

// ============================================================
// 任务 1: local_message 扫描补偿 (防线3 本体)
// ============================================================

// ScanCompensationTask 扫描待投递残留: status=0 且超过宽限期的 local_message,
// 从消息表重建投递事件重新走 Deliverer (与正常投递同一核心, 幂等)。
// 覆盖面: Kafka 写失败 / 队列满丢弃 / Job 崩溃丢内存态 / 消费半途宕机。
type ScanCompensationTask struct {
	db  *store.MySQL
	del *Deliverer
}

func NewScanCompensationTask(db *store.MySQL, d *Deliverer) *ScanCompensationTask {
	return &ScanCompensationTask{db: db, del: d}
}

func (t *ScanCompensationTask) Name() string            { return "local-msg-scan" }
func (t *ScanCompensationTask) Interval() time.Duration { return 30 * time.Second }
func (t *ScanCompensationTask) Shards() []string        { return dbShards() }

func dbShards() []string {
	s := make([]string, store.MsgDBCount)
	for i := range s {
		s[i] = fmt.Sprintf("%d", i)
	}
	return s
}

func (t *ScanCompensationTask) Exec(ctx context.Context, shard string) error {
	var dbIndex int
	if _, err := fmt.Sscanf(shard, "%d", &dbIndex); err != nil || dbIndex >= store.MsgDBCount {
		return fmt.Errorf("bad shard %q", shard)
	}
	if dbIndex >= store.MsgDBCount {
		return nil
	}
	db := t.db.ShardDB(store.MsgShard{DBIndex: dbIndex})

	cutoff := time.Now().Add(-scanGrace).UnixMilli()
	rows, err := db.QueryContext(ctx,
		"SELECT conv_id, msg_id FROM local_message WHERE status = 0 AND create_time_ms < ? LIMIT ?",
		cutoff, scanBatch)
	if err != nil {
		return fmt.Errorf("scan local_message: %w", err)
	}
	type pend struct{ convID, msgID int64 }
	var batch []pend
	for rows.Next() {
		var p pend
		if err := rows.Scan(&p.convID, &p.msgID); err != nil {
			rows.Close()
			return err
		}
		batch = append(batch, p)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return err
	}

	for _, p := range batch {
		if err := t.redeliverOne(ctx, db, p.convID, p.msgID); err != nil {
			logger.L.Error("scan compensation (skip poison row)", zap.Error(err),
				zap.Int64("conv_id", p.convID), zap.Int64("msg_id", p.msgID))
		}
	}
	if len(batch) > 0 {
		logger.L.Info("scan compensation round", zap.Int("rescanned", len(batch)), zap.String("db", shard))
	}
	return nil
}

// redeliverOne 从消息表重建投递事件, 走与正常投递同一个 Deliverer 核心。
// 事件带 MsgID → Deliverer 扇出完成后自己回写 status=1 (闭环)。
// 消息行都查不到属于数据事故: 标 status=1 让位 (毒丸不阻塞扫描) 并记 Error。
func (t *ScanCompensationTask) redeliverOne(ctx context.Context, db *sql.DB, convID, msgID int64) error {
	shard := store.RouteMsg(convID)
	var seq, fromUID int64
	err := t.db.ShardDB(shard).QueryRowContext(ctx,
		fmt.Sprintf("SELECT seq, from_uid FROM %s WHERE conv_id = ? AND msg_id = ? LIMIT 1", shard.Table()),
		convID, msgID).Scan(&seq, &fromUID)
	if errors.Is(err, sql.ErrNoRows) {
		_, _ = db.ExecContext(ctx,
			"UPDATE local_message SET status = 1 WHERE conv_id = ? AND msg_id = ? AND status = 0",
			convID, msgID)
		return fmt.Errorf("message row missing (marked done): conv=%d msg=%d", convID, msgID)
	}
	if err != nil {
		return fmt.Errorf("load message: %w", err)
	}
	t.del.Deliver(PushEvent{ConvID: convID, MaxSeq: seq, FromUID: fromUID, MsgID: msgID})
	return nil
}

// ============================================================
// 任务 2: offline_box 对账 (防线2 的清理方)
// ============================================================

// offlineBoxTTL 登记表保留期: 超期未补偿的条目放弃补推,
// 客户端 SYNC 全量路径兜底 (离线箱是登记表不是收件箱, 清理不丢消息)。
const offlineBoxTTL = 7 * 24 * time.Hour

// OfflineBoxTask 对离线箱做两件事:
//  1. 用户已在线 → 重推一次 (PushAll delivered=true 即标已补偿)
//  2. 超期条目 → 标记关闭 (客户端 SYNC/全量拉取兜底, 表只是登记)
//
// 未命中的条目留 status=0 下轮再看; 按.uid%16 分桶并行。
type OfflineBoxTask struct {
	db    *store.MySQL
	comet *cometCluster
}

func NewOfflineBoxTask(db *store.MySQL, c *cometCluster) *OfflineBoxTask {
	return &OfflineBoxTask{db: db, comet: c}
}

func (t *OfflineBoxTask) Name() string            { return "offline-box-reconcile" }
func (t *OfflineBoxTask) Interval() time.Duration { return time.Minute }
func (t *OfflineBoxTask) Shards() []string {
	s := make([]string, 16)
	for i := range s {
		s[i] = fmt.Sprintf("%d", i)
	}
	return s
}

func (t *OfflineBoxTask) Exec(ctx context.Context, shard string) error {
	var bucket int
	if _, err := fmt.Sscanf(shard, "%d", &bucket); err != nil {
		return fmt.Errorf("bad shard %q", shard)
	}

	rows, err := t.db.Meta.QueryContext(ctx,
		"SELECT uid, conv_id, seq, create_time_ms FROM offline_box WHERE status = 0 AND uid % 16 = ? LIMIT ?",
		bucket, scanBatch)
	if err != nil {
		return fmt.Errorf("scan offline_box: %w", err)
	}
	type entry struct{ uid, convID, seq, createTimeMs int64 }
	var batch []entry
	for rows.Next() {
		var e entry
		if err := rows.Scan(&e.uid, &e.convID, &e.seq, &e.createTimeMs); err != nil {
			rows.Close()
			return err
		}
		batch = append(batch, e)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return err
	}

	pctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	for _, e := range batch {
		expired := time.Since(time.UnixMilli(e.createTimeMs)) > offlineBoxTTL
		if !expired && t.comet.PushAll(pctx, e.uid, e.convID, e.seq, 0, 0) {
			t.markDone(e.uid, e.convID, e.seq)
			continue
		}
		if expired {
			// 放弃补推: 客户端 SYNC 水位差集拉取覆盖它, 表只留登记记录
			t.markDone(e.uid, e.convID, e.seq)
		}
	}
	return nil
}

func (t *OfflineBoxTask) markDone(uid, convID, seq int64) {
	_, err := t.db.Meta.ExecContext(context.Background(),
		"UPDATE offline_box SET status = 1 WHERE uid = ? AND conv_id = ? AND seq = ? AND status = 0",
		uid, convID, seq)
	if err != nil {
		logger.L.Warn("offline_box mark done", zap.Error(err),
			zap.Int64("uid", uid), zap.Int64("conv_id", convID))
	}
}

// ============================================================
// 任务 3: conv.last_seq 对账 (未读数的分母校准)
// ============================================================

// UnreadReconcileTask 校准跨库推进的会话水位: conversations.last_seq
// (元库, 事务外单调推进) 可能落后于消息表的真实 MAX(seq) (分片库)。
// 落后的代价 = 未读数偏小 (last_seq - read_seq), 兑现 06.5 的"对账兜底"承诺。
type UnreadReconcileTask struct {
	db *store.MySQL
}

func NewUnreadReconcileTask(db *store.MySQL) *UnreadReconcileTask {
	return &UnreadReconcileTask{db: db}
}

func (t *UnreadReconcileTask) Name() string            { return "unread-reconcile" }
func (t *UnreadReconcileTask) Interval() time.Duration { return 10 * time.Minute }
func (t *UnreadReconcileTask) Shards() []string {
	// conv_id 连续发号, %8 切桶近似均匀 (与 1024 slot 同一取模思想)
	s := make([]string, 8)
	for i := range s {
		s[i] = fmt.Sprintf("%d", i)
	}
	return s
}

func (t *UnreadReconcileTask) Exec(ctx context.Context, shard string) error {
	var bucket int
	if _, err := fmt.Sscanf(shard, "%d", &bucket); err != nil {
		return fmt.Errorf("bad shard %q", shard)
	}

	rows, err := t.db.Meta.QueryContext(ctx,
		"SELECT conv_id, last_seq FROM conversations WHERE conv_id % 8 = ? LIMIT 500", bucket)
	if err != nil {
		return fmt.Errorf("scan conversations: %w", err)
	}
	type conv struct{ id, lastSeq int64 }
	var batch []conv
	for rows.Next() {
		var c conv
		if err := rows.Scan(&c.id, &c.lastSeq); err != nil {
			rows.Close()
			return err
		}
		batch = append(batch, c)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return err
	}

	for _, c := range batch {
		shardMsg := store.RouteMsg(c.id)
		var maxSeq int64
		err := t.db.ShardDB(shardMsg).QueryRowContext(ctx,
			fmt.Sprintf("SELECT COALESCE(MAX(seq), 0) FROM %s WHERE conv_id = ?", shardMsg.Table()),
			c.id).Scan(&maxSeq)
		if err != nil {
			return fmt.Errorf("max seq conv %d: %w", c.id, err)
		}
		if maxSeq <= c.lastSeq {
			continue
		}
		// 单调推进 (AND last_seq < ?): 与主链路并发写安全, 只追不回退
		if _, err := t.db.Meta.ExecContext(ctx,
			"UPDATE conversations SET last_seq = ? WHERE conv_id = ? AND last_seq < ?",
			maxSeq, c.id, maxSeq); err != nil {
			logger.L.Warn("unread reconcile update", zap.Error(err), zap.Int64("conv_id", c.id))
			continue
		}
		logger.L.Info("unread reconcile: conv last_seq advanced",
			zap.Int64("conv_id", c.id), zap.Int64("from", c.lastSeq), zap.Int64("to", maxSeq))
	}
	return nil
}

// ============================================================
// 任务 4: 布隆过滤器每日重建 (广播触发, 执行方在 Message Svc)
// ============================================================

// BloomRebuildChannel 布隆重建的广播频道: 调度系统发布触发信号,
// Message Svc 订阅并执行 WarmIdempotencyBloom —— 布隆实例在 Message 进程
// 内存里, 调度系统只发信号不搬运数据, 执行方自持幂等 (影子代双写)。
const BloomRebuildChannel = "sched:bloom-rebuild"

// BloomRebuildTask 每日发布重建信号。布隆只增不减, 假阳性率随历史缓慢上升,
// 重建 = 从 DB 重装近 N 天的 key (Rebuild 影子代, 重建期间双写无感知切换)。
type BloomRebuildTask struct {
	rdb *redis.Client
}

func NewBloomRebuildTask(rdb *redis.Client) *BloomRebuildTask {
	return &BloomRebuildTask{rdb: rdb}
}

func (t *BloomRebuildTask) Name() string            { return "bloom-rebuild" }
func (t *BloomRebuildTask) Interval() time.Duration { return 24 * time.Hour }
func (t *BloomRebuildTask) Shards() []string        { return []string{"0"} } // 单分片: 广播信号

func (t *BloomRebuildTask) Exec(ctx context.Context, _ string) error {
	if t.rdb == nil {
		return fmt.Errorf("redis unavailable (bloom rebuild needs pub/sub)")
	}
	return t.rdb.Publish(ctx, BloomRebuildChannel, "7").Err()
}

// ============================================================
// 任务 5: local_message 清理 (表卫生, 防 status=1 历史无限堆积)
// ============================================================

// LocalMsgCleanupTask 清理已投递且过保留期的 local_message 行。
// local_message 是投递任务的登记表不是审计日志, 已完成使命的可删。
// 注意只删 status=1: status=0 的待投递永远不清 (正确性锚点)。
type LocalMsgCleanupTask struct {
	db *store.MySQL
}

func NewLocalMsgCleanupTask(db *store.MySQL) *LocalMsgCleanupTask {
	return &LocalMsgCleanupTask{db: db}
}

func (t *LocalMsgCleanupTask) Name() string            { return "local-msg-cleanup" }
func (t *LocalMsgCleanupTask) Interval() time.Duration { return 24 * time.Hour }
func (t *LocalMsgCleanupTask) Shards() []string        { return dbShards() }

func (t *LocalMsgCleanupTask) Exec(ctx context.Context, shard string) error {
	var dbIndex int
	if _, err := fmt.Sscanf(shard, "%d", &dbIndex); err != nil || dbIndex >= store.MsgDBCount {
		return fmt.Errorf("bad shard %q", shard)
	}
	if dbIndex >= store.MsgDBCount {
		return nil
	}
	cutoff := time.Now().Add(-offlineBoxTTL).UnixMilli()

	var total int64
	for {
		res, err := t.db.ShardDB(store.MsgShard{DBIndex: dbIndex}).ExecContext(ctx,
			"DELETE FROM local_message WHERE status = 1 AND create_time_ms < ? LIMIT 1000",
			cutoff)
		if err != nil {
			return fmt.Errorf("cleanup local_message: %w", err)
		}
		n, _ := res.RowsAffected()
		total += n
		if n < 1000 {
			break
		}
	}
	if total > 0 {
		logger.L.Info("local_message cleanup", zap.Int64("deleted", total), zap.String("db", shard))
	}
	return nil
}

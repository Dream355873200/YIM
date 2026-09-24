// Package message: 消息主链路 (里程碑1 最小闭环)。
//
// 发送事务模型 (最终一致, 无分布式事务):
//
//	同一本地事务: 消息落库(分片) + local_message 落库 (同库同片, 无跨库事务)
//	事务提交后:   bump 会话成员 sync seq → 推送
//	推送失败重试: Job Svc + 时间轮在后续里程碑补齐 (三道防线)
//
// 幂等三道闸 (里程碑5 起, 逐层递进, 拦截率递减、成本递增):
//
//	① 布隆过滤器: "肯定没见过" 直接跳过 ②③, 省一次 Redis 往返
//	② Redis SETNX(idem:{conv}:{cmid}): 命中即拿上次结果返回, 不碰 DB
//	③ DB UNIQUE(conv_id, client_msg_id) + 1062: 最终防线, 永远兜底
package message

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"sync"
	"time"

	"github.com/go-sql-driver/mysql"
	"go.uber.org/zap"
	"google.golang.org/protobuf/encoding/protojson"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/store"
	"github.com/yim/kitex_gen/yim"
)

// Pusher 投递接口: 里程碑1 由 main 注入内存实现;
// 拆分后由 Job Svc 实现 (Kafka 消费), 契约不变。
type Pusher interface {
	Push(ctx context.Context, e PushEvent)
}

type PushEvent struct {
	ConvID      int64
	MaxSeq      int64
	FromUID     int64
	UserSyncSeq int64
	MsgID       int64 // local_message 主键之一: 投递完成后回写 status=1 (防线3 扫表增量)
}

type Service struct {
	db       *store.MySQL
	seqs     SeqClient       // 单体=LocalSeqClient 直连; 拆分后=RPCSeqClient → Seq Svc
	pusher   Pusher          // 可为 nil: 仅验证写路径
	cache    *cache.Cache    // 可为 nil: 全部走 DB 慢路径
	bloom    *cache.Bloom    // 可为 nil: 跳过粗筛
	msgIDs   *msgIDAlloc     // msg_id 进程内预取 (里程碑8)
	convSeqs *convSeqAlloc   // conv seq 进程内预取 (16 里程碑)
	lastSeqs *lastSeqBatcher // conv.last_seq 攒批推进 (16 里程碑)
	rel      RelationClient  // Relation Svc (里程碑9): 好友校验/群 seed, nil = 跳过
}

func NewService(db *store.MySQL, seqs SeqClient, pusher Pusher, c *cache.Cache) *Service {
	s := &Service{
		db: db, seqs: seqs, pusher: pusher, cache: c,
		msgIDs:   &msgIDAlloc{seqs: seqs},
		convSeqs: &convSeqAlloc{seqs: seqs},
	}
	s.lastSeqs = &lastSeqBatcher{s: s}
	if c != nil {
		s.bloom = cache.NewBloom(1<<25, 4)
	}
	return s
}

// msgIDAlloc msg_id 进程内预取 (里程碑8 降密度): 每条消息一次 AllocID RPC
// → 每 msgIDStep 条一次。msg_id 无序性要求 (只是唯一主键), 批量预取不破坏
// 任何语义。实现用互斥锁而非 CAS —— 临界区是两次 int 赋值 (~ns 级), 目标
// 速率 (万级/s) 下锁竞争可忽略; CAS 版的跨段 undo 有把邻段号发出去的竞态,
// 复杂度不划算。
type msgIDAlloc struct {
	seqs SeqClient

	mu        sync.Mutex
	cur, last int64 // [cur, last] = 本段剩余可发号; cur > last 段耗尽
}

const msgIDStep = 512

func (a *msgIDAlloc) Alloc(ctx context.Context) (int64, error) {
	a.mu.Lock()
	defer a.mu.Unlock()
	// cur==0 = 尚未装载 (零值 cur=0,last=0 不满足 cur>last, 首次调用会
	// 直接漏过补段返回 0 —— 已实测: 重启后第一条消息 msg_id=0)。
	// seq svc 号段恒从 ≥1 开始, cur==0 唯一语义就是"未装载"。
	if a.cur == 0 || a.cur > a.last {
		start, err := a.seqs.AllocID(ctx, "msg", 0, msgIDStep)
		if err != nil {
			return 0, err // 补段失败 = seq RPC 故障, 语义与改造前逐条分配一致
		}
		a.cur, a.last = start, start+msgIDStep-1
	}
	v := a.cur
	a.cur++
	return v, nil
}

// convSeqAlloc conv seq 进程内号段预取 (16 里程碑降密度, 对账 goim/OpenIM):
// 每条消息一次 AllocConvSeq RPC → 每 convSeqStep 条一次。refill 复用现有
// RPC (count=64), 号段仍由 seq svc 的 DB seq_segment 管理 —— 不引入 Redis
// 依赖、无回退风险; 进程崩溃浪费 ≤64 个号 (容忍空洞, 与 msg_id 同构),
// 多实例各持不相交段, 单调性不破坏。
//
// commit 顺序说明 (原注释警告"批取破坏 commit 顺序"的复核): seq 分配在
// 插入之前, "分配序 ≠ 提交序" 的竞争在逐条 RPC 下同样存在 (同 conv 的并发
// 发送方本就无串行化), 进程内预取不扩大窗口; refill 走 seq svc 的 per-conv
// 池, 段间不相交。锁内 refill 与 msgIDAlloc 同款: refill 频率 = 速率/64,
// 锁竞争可忽略。
type convSeqAlloc struct {
	seqs SeqClient

	mu sync.Mutex
	m  map[int64][2]int64 // conv_id → [cur, last]; cur > last = 段耗尽
}

const (
	convSeqStep    = 64
	convSeqMapHigh = 4096 // 防膨胀: 超限整体清空, 丢弃在途段 (空洞容忍)
)

func (a *convSeqAlloc) Alloc(ctx context.Context, convID int64) (int64, error) {
	a.mu.Lock()
	defer a.mu.Unlock()
	if a.m == nil {
		a.m = make(map[int64][2]int64)
	}
	for {
		seg, ok := a.m[convID]
		if ok && seg[0] <= seg[1] {
			v := seg[0]
			a.m[convID] = [2]int64{v + 1, seg[1]}
			return v, nil
		}
		if len(a.m) >= convSeqMapHigh {
			a.m = make(map[int64][2]int64)
		}
		start, err := a.seqs.AllocConvSeq(ctx, convID, convSeqStep)
		if err != nil {
			return 0, err // 补段失败 = seq RPC 故障, 语义与改造前逐条分配一致
		}
		a.m[convID] = [2]int64{start, start + convSeqStep - 1}
	}
}

// lastSeqBatcher conv.last_seq 攒批推进 (16 里程碑降密度): 每条消息一次
// 同步元库 UPDATE → 攒批 (32 conv 或 50ms) 一次。last_seq 本就是事务外
// best-effort 单调提示 (conversations 在元库、消息在分片库, 无同事务可能,
// 见 SendMessage 注释) —— 失败/延迟只是未读数暂时偏小, 对账任务兜底,
// 丢失窗口语义与 markBatcher 完全同构。
type lastSeqBatcher struct {
	s *Service

	mu  sync.Mutex
	buf map[int64]int64 // conv_id → 本批最大 seq (单调条件写, 取 max 即安全)
	arm bool            // 在途 flush 定时器
}

const (
	lastSeqFlushSize  = 32
	lastSeqFlushDelay = 50 * time.Millisecond
)

func (b *lastSeqBatcher) add(convID, seq int64) {
	b.mu.Lock()
	if b.buf == nil {
		b.buf = make(map[int64]int64)
	}
	if b.buf[convID] < seq {
		b.buf[convID] = seq
	}
	full := len(b.buf) >= lastSeqFlushSize
	needArm := !full && !b.arm
	if needArm {
		b.arm = true
	}
	b.mu.Unlock()

	if full {
		go b.flush() // 异步推进: UPDATE 带单调守卫, 并发 flush 行集不重叠
		return
	}
	if needArm {
		time.AfterFunc(lastSeqFlushDelay, b.flush)
	}
}

// flush 推进一桶 (定时器侧与满触发侧都可能进来, 幂等)。
func (b *lastSeqBatcher) flush() {
	b.mu.Lock()
	rows := b.buf
	b.buf = nil
	b.arm = false
	b.mu.Unlock()
	for convID, seq := range rows {
		if _, err := b.s.db.Meta.ExecContext(context.Background(),
			"UPDATE conversations SET last_seq = ? WHERE conv_id = ? AND last_seq < ?",
			seq, convID, seq); err != nil {
			logger.L.Warn("bump conv last_seq batch (unread may lag, reconciliation will fix)",
				zap.Error(err), zap.Int64("conv_id", convID), zap.Int64("seq", seq))
			continue // 失败的 conv 不失效缓存, 下次 add 重新入批
		}
		b.s.cache.InvalidateConv(context.Background(), convID)
	}
}

// Bloom 供启动预热 (main 里 goroutine 调 WarmIdempotencyBloom) 与里程碑6 调度重建。
func (s *Service) Bloom() *cache.Bloom { return s.bloom }

// SendMessage 单条消息发送。群聊批量 seq 用 AllocConvSeq 的 count 预留 (里程碑2)。
func (s *Service) SendMessage(ctx context.Context, clientMsgID, convID, fromUID int64, content *yim.ConvMsgContent) (msgID, convSeq int64, err error) {
	shard := store.RouteMsg(convID)
	db := s.db.ShardDB(shard)

	// 0. 成员校验 (fail-close): fromUID 必须在会话成员内, 否则任何登录用户都
	//    能向任意 conv_id 写消息 (横向挤进他人会话)。meta 走 cache-aside 热路径。
	meta, err := s.cache.GetConvMeta(ctx, s.db, convID)
	if err != nil {
		return 0, 0, fmt.Errorf("conv meta %d: %w", convID, err)
	}
	isMember := false
	for _, m := range meta.MemberUIDs {
		if m == fromUID {
			isMember = true
			break
		}
	}
	if !isMember {
		return 0, 0, ErrNotMember
	}

	// 幂等 ①②: 布隆粗筛 → Redis 精查。快速路径拿到历史结果直接返回。
	if s.bloom != nil && s.bloom.MightContain(cache.BloomKey(convID, clientMsgID)) {
		if v, ok := s.cache.IdemGet(ctx, convID, clientMsgID); ok {
			return v.MsgID, v.Seq, nil
		}
	}

	// 1. 会话 seq: 排序唯一依据, 会话内单调。进程内号段预取 (每 64 条一次 RPC,
	// 见 convSeqAlloc 注释: 分配序≠提交序的竞争与逐条 RPC 完全一致)
	seqStart, err := s.convSeqs.Alloc(ctx, convID)
	if err != nil {
		return 0, 0, fmt.Errorf("alloc conv seq: %w", err)
	}

	// 2. 消息 ID: 进程内号段预取 (每 512 条一次 AllocID RPC, 里程碑8)。
	// msg_id 只要求全局唯一不要求有序, 批取不破坏任何语义
	msgID, err = s.msgIDs.Alloc(ctx)
	if err != nil {
		return 0, 0, fmt.Errorf("alloc msg id: %w", err)
	}

	// 2.5 幂等精查标记: SETNX 赢家才有资格插入。
	// 输家 = 同 ID 已在落库 (并发重放): 不确定对方是否提交完成 → 查 DB,
	// 查不到 (对方事务未提交) 就继续走插入, 让唯一键决胜。
	if s.cache != nil {
		ok, err := s.cache.IdemPut(ctx, convID, clientMsgID, cache.IdemValue{MsgID: msgID, Seq: seqStart})
		if err == nil && !ok {
			if v, hit := s.cache.IdemGet(ctx, convID, clientMsgID); hit {
				return v.MsgID, v.Seq, nil
			}
			if id, s2, qerr := s.queryByClientMsgID(ctx, db, shard.Table(), convID, clientMsgID); qerr == nil {
				return id, s2, nil
			}
		}
		// IdemPut 出错 (Redis 抖动): 继续走 DB, 唯一键兜底
	}

	// 3. 本地事务: 消息 + local_message
	contentJSON, err := protojson.Marshal(content)
	if err != nil {
		s.cache.IdemDel(ctx, convID, clientMsgID)
		return 0, 0, fmt.Errorf("marshal content: %w", err)
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return 0, 0, err
	}
	defer func() { _ = tx.Rollback() }()

	_, err = tx.ExecContext(ctx, fmt.Sprintf(
		"INSERT INTO %s (msg_id, conv_id, from_uid, seq, msg_type, content, client_msg_id, server_time_ms) VALUES (?,?,?,?,?,?,?,?)",
		shard.Table()),
		msgID, convID, fromUID, seqStart, int32(content.Type), contentJSON, clientMsgID, timeNowMs())
	if err != nil {
		s.cache.IdemDel(ctx, convID, clientMsgID) // 失败回滚标记, 不误伤同 ID 后续重试
		if isDuplicateKey(err) {
			// 幂等命中: 返回已落库的 msg_id/seq, 对发送方表现为成功
			return s.queryByClientMsgID(ctx, db, shard.Table(), convID, clientMsgID)
		}
		return 0, 0, fmt.Errorf("insert message: %w", err)
	}
	if _, err = tx.ExecContext(ctx,
		"INSERT INTO local_message (msg_id, conv_id, status, create_time_ms) VALUES (?,?,0,?)",
		msgID, convID, timeNowMs()); err != nil {
		s.cache.IdemDel(ctx, convID, clientMsgID)
		return 0, 0, fmt.Errorf("insert local_message: %w", err)
	}
	if err = tx.Commit(); err != nil {
		s.cache.IdemDel(ctx, convID, clientMsgID)
		return 0, 0, err
	}

	// 4. 提交后: 布隆注册 + recent 预热 (best-effort) + bump 成员 sync seq + 推送
	if s.bloom != nil {
		s.bloom.Add(cache.BloomKey(convID, clientMsgID))
	}
	if cm, err := protojson.Marshal(&yim.ConvMessage{
		MsgId: msgID, ConvId: convID, FromUid: fromUID, Seq: seqStart,
		ServerTimeMs: timeNowMs(), Content: content,
	}); err == nil {
		s.cache.RecentAdd(ctx, convID, seqStart, cm)
	}
	// conv.last_seq 攒批推进 (原逐条同步 UPDATE, 16 里程碑): conversations 在
	// 元库、消息在分片库, 本就无同事务可能 —— 攒批 32 conv/50ms 异步推进,
	// 丢失窗口由单调条件写 + 对账兜底, 与 markBatcher 同语义。
	s.lastSeqs.add(convID, seqStart)
	if s.pusher != nil {
		s.pusher.Push(ctx, PushEvent{
			ConvID: convID, MaxSeq: seqStart, FromUID: fromUID,
			UserSyncSeq: s.bumpSyncSeq(ctx, fromUID), MsgID: msgID,
		})
	}
	return msgID, seqStart, nil
}

// WarmIdempotencyBloom 布隆预热: 装载近 days 天的 client_msg_id。
// 启动时异步调用; 失败只影响命中率 (重复消息多查一次), 不影响正确性。
func (s *Service) WarmIdempotencyBloom(ctx context.Context, days int) error {
	if s.bloom == nil {
		return nil
	}
	cutoff := time.Now().Add(-time.Duration(days) * 24 * time.Hour).UnixMilli()
	return s.bloom.Rebuild(ctx, func(ctx context.Context) ([]uint64, error) {
		var keys []uint64
		for _, shard := range store.AllMsgShards() {
			rows, err := s.db.ShardDB(shard).QueryContext(ctx, fmt.Sprintf(
				"SELECT conv_id, client_msg_id FROM %s WHERE server_time_ms > ? LIMIT 500000",
				shard.Table()), cutoff)
			if err != nil {
				return nil, err
			}
			for rows.Next() {
				var convID, cmid int64
				if err := rows.Scan(&convID, &cmid); err != nil {
					rows.Close()
					return nil, err
				}
				keys = append(keys, cache.BloomKey(convID, cmid))
			}
			rows.Close()
		}
		return keys, nil
	})
}

// bumpSyncSeq 用户级变更水位 +1, 返回新值 (推拉同步协议的"漏没漏"判据)。
// 简化: 只 bump 发送者; 接收者水位在投递成功后 bump (Job Svc 职责)。
func (s *Service) bumpSyncSeq(ctx context.Context, uid int64) int64 {
	v, err := s.seqs.BumpSyncSeq(ctx, uid)
	if err != nil {
		return 0 // 水位缺失只影响同步效率, 不影响投递正确性
	}
	return v
}

func (s *Service) queryByClientMsgID(ctx context.Context, db *sql.DB, table string, convID, clientMsgID int64) (int64, int64, error) {
	var id, s2 int64
	err := db.QueryRowContext(ctx, fmt.Sprintf(
		"SELECT msg_id, seq FROM %s WHERE conv_id = ? AND client_msg_id = ?", table),
		convID, clientMsgID).Scan(&id, &s2)
	if err != nil {
		return 0, 0, fmt.Errorf("idempotent lookup: %w", err)
	}
	return id, s2, nil
}

// isDuplicateKey MySQL 1062: 幂等的最终防线
func isDuplicateKey(err error) bool {
	var me *mysql.MySQLError
	return errors.As(err, &me) && me.Number == 1062
}

func timeNowMs() int64 { return time.Now().UnixMilli() }

// SeqClient 发号抽象 —— 里程碑1 单体直连 seq.Pool, 里程碑2 起走 Seq Svc RPC,
// 里程碑8 sync 水位降密度为 Redis INCR (RedisSyncSeqClient 包装降级)。
// 业务代码 (service.go/delivery.go) 只依赖接口, 适配器在此收口。
package message

import (
	"context"
	"sync"
	"time"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/store"
	"github.com/yim/internal/seq"
	"github.com/yim/kitex_gen/yim"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
	"go.uber.org/zap"
)

type SeqClient interface {
	// AllocID 通用实体 ID (biz=uid/msg/conv_id, key=0)
	AllocID(ctx context.Context, biz string, key int64, n int) (int64, error)
	// AllocConvSeq 会话 seq, 返回区间起点 [start, start+n-1]
	AllocConvSeq(ctx context.Context, convID int64, n int) (int64, error)
	// BumpSyncSeq 用户同步水位 +1, 返回新值
	BumpSyncSeq(ctx context.Context, uid int64) (int64, error)
}

// ============================================================
// LocalSeqClient: 进程内直连 (测试 / 退化到单体时用)
// ============================================================

type LocalSeqClient struct{ pool *seq.Pool }

func NewLocalSeqClient(p *seq.Pool) *LocalSeqClient { return &LocalSeqClient{pool: p} }

func (c *LocalSeqClient) AllocID(ctx context.Context, biz string, key int64, n int) (int64, error) {
	a, err := c.pool.For(ctx, biz, key)
	if err != nil {
		return 0, err
	}
	return a.Next(n)
}

func (c *LocalSeqClient) AllocConvSeq(ctx context.Context, convID int64, n int) (int64, error) {
	a, err := c.pool.For(ctx, "conv", convID)
	if err != nil {
		return 0, err
	}
	return a.Next(n)
}

func (c *LocalSeqClient) BumpSyncSeq(ctx context.Context, uid int64) (int64, error) {
	a, err := c.pool.For(ctx, "sync", uid)
	if err != nil {
		return 0, err
	}
	return a.Next(1)
}

// ============================================================
// RPCSeqClient: 走 Seq Svc (里程碑2 拆分后的正路)
// ============================================================

type RPCSeqClient struct{ cli seqservice.Client }

func NewRPCSeqClient(cli seqservice.Client) *RPCSeqClient { return &RPCSeqClient{cli: cli} }

func (c *RPCSeqClient) AllocID(ctx context.Context, biz string, key int64, n int) (int64, error) {
	rsp, err := c.cli.AllocId(ctx, &yim.AllocIdReq{Biz: biz, KeyId: key, Count: int32(n)})
	if err != nil {
		return 0, err
	}
	return rsp.Start, nil
}

func (c *RPCSeqClient) AllocConvSeq(ctx context.Context, convID int64, n int) (int64, error) {
	rsp, err := c.cli.AllocConvSeq(ctx, &yim.AllocConvSeqReq{ConvId: convID, Count: int32(n)})
	if err != nil {
		return 0, err
	}
	return rsp.Start, nil
}

func (c *RPCSeqClient) BumpSyncSeq(ctx context.Context, uid int64) (int64, error) {
	rsp, err := c.cli.BumpSyncSeq(ctx, &yim.BumpSyncSeqReq{Uid: uid})
	if err != nil {
		return 0, err
	}
	return rsp.SyncSeq, nil
}

// ============================================================
// RedisSyncSeqClient: sync 水位走 Redis INCR (里程碑8 降密度)。
//
// 动机: BumpSyncSeq 每条消息 1~2 次 RPC (发送方 + 每个接收方), 2000 msg/s
// 时就是 4000 RPC/s 打在单实例 seq svc 上。水位只是"有新事件"的触发提示
// (客户端以此决定是否 SYNC), 不是消息序号 —— 单调即可, 重复/跳号无害,
// 所以能放 Redis: INCR 原子单调, 异步回写 DB 持久化。
//
// 正确性分层:
//	Redis 为主分配器 (INCR, 单调)
//	DB seq_segment 异步回写 = 持久化兜底 (GREATEST 保单调, 幂等)
//	Redis 不可用/出错 → 整体回退 RPCSeqClient (与降级前形态逐字节一致)
//
// 冷启动播种: Redis 丢失后从 DB 水位 + seedMargin 重新起跳 —— margin 覆盖
// "已 INCR 未回写"的窗口, 保证恢复后的值不高于崩溃前发过的值 (防水位回退
// 让客户端漏 SYNC 触发)。浪费 margin 个数 = 容忍空洞哲学的又一次变现。
// ============================================================

const (
	seedMargin       = 1024
	syncFlushSize    = 64
	syncFlushDelay   = 200 * time.Millisecond
	syncBackfillRate = 32 // 回写限速: 每批最多重推 N 个 uid 的水位 (防超大 backlog 一次打满 DB)
)

type RedisSyncSeqClient struct {
	SeqClient // 内嵌降级路径: Redis 出错时的完整回退实现

	c  *cache.Cache // nil = 纯降级形态 (等同 RPCSeqClient)
	db *store.MySQL

	mu    sync.Mutex
	floor map[int64]int64 // uid → 播种基线 (DB 水位 + margin), 进程内缓存

	mu2   sync.Mutex
	buf   map[int64]int64 // uid → 待回写水位 (保留最大值)
	armed bool            // 仅一个在途 flush 定时器
}

func NewRedisSyncSeqClient(c *cache.Cache, fallback SeqClient, db *store.MySQL) *RedisSyncSeqClient {
	r := &RedisSyncSeqClient{
		SeqClient: fallback,
		c:         c,
		db:        db,
		floor:     make(map[int64]int64),
		buf:       make(map[int64]int64),
	}
	return r
}

// floorFor 取 uid 的播种基线: 进程内缓存, 首次查 DB 水位 + margin。
func (r *RedisSyncSeqClient) floorFor(ctx context.Context, uid int64) int64 {
	r.mu.Lock()
	f, ok := r.floor[uid]
	r.mu.Unlock()
	if ok {
		return f
	}
	var dbMax int64
	_ = r.db.Meta.QueryRowContext(ctx,
		"SELECT max_id FROM seq_segment WHERE biz = 'sync' AND key_id = ?", uid).Scan(&dbMax)
	f = dbMax + seedMargin
	r.mu.Lock()
	// 双检: 并发首查时保留较大者 (DB 只会单调涨)
	if f > r.floor[uid] {
		r.floor[uid] = f
	}
	f = r.floor[uid]
	r.mu.Unlock()
	return f
}

func (r *RedisSyncSeqClient) BumpSyncSeq(ctx context.Context, uid int64) (int64, error) {
	if r.c == nil {
		return r.SeqClient.BumpSyncSeq(ctx, uid) // 无 Redis: 纯降级形态
	}
	v, err := r.c.SyncSeqBump(ctx, uid, r.floorFor(ctx, uid))
	if err != nil {
		return r.SeqClient.BumpSyncSeq(ctx, uid) // Redis 故障: 回退 RPC, 语义与改造前一致
	}
	r.backfill(uid, v)
	return v, nil
}

// backfill 缓冲水位待异步回写 DB (markBatcher 同款: 满 N 条或定时触发,
// 调用方不付 flush 的钱)。同 uid 保留最大值, 回写乱序也不会回退。
func (r *RedisSyncSeqClient) backfill(uid, v int64) {
	r.mu2.Lock()
	if r.buf[uid] < v {
		r.buf[uid] = v
	}
	full := len(r.buf) >= syncFlushSize
	needArm := !full && !r.armed
	if needArm {
		r.armed = true
	}
	r.mu2.Unlock()

	if full {
		go r.flush()
		return
	}
	if needArm {
		time.AfterFunc(syncFlushDelay, func() { r.flush() })
	}
}

// flush 批量回写: INSERT ... ON DUPLICATE KEY UPDATE max_id = GREATEST(...)。
// 幂等单调 —— 重复回写/乱序回写/重启后重放都不回退水位, 与 seq_segment 的
// 号段推进语义兼容 (GREATEST 不会覆盖 seq svc 自己推进的更大值)。
func (r *RedisSyncSeqClient) flush() {
	r.mu2.Lock()
	rows := r.buf
	r.buf = make(map[int64]int64)
	r.armed = false
	r.mu2.Unlock()
	if len(rows) == 0 {
		return
	}
	if len(rows) > syncBackfillRate {
		// 超大批拆散慢推: 回写是兜底不是主链路, 不许挤占 DB (防线3 语义)
		n := 0
		for uid, v := range rows {
			if n >= syncBackfillRate {
				r.backfill(uid, v) // 超出部分放回缓冲, 下批再写
				continue
			}
			r.writeBack(uid, v)
			n++
		}
		return
	}
	for uid, v := range rows {
		r.writeBack(uid, v)
	}
}

func (r *RedisSyncSeqClient) writeBack(uid, v int64) {
	_, err := r.db.Meta.ExecContext(context.Background(),
		"INSERT INTO seq_segment (biz, key_id, max_id, step) VALUES ('sync', ?, ?, 1) "+
			"ON DUPLICATE KEY UPDATE max_id = GREATEST(max_id, VALUES(max_id))", uid, v)
	if err != nil {
		logger.L.Warn("sync seq backfill (degraded: reconnect-resync covers)",
			zap.Error(err), zap.Int64("uid", uid), zap.Int64("val", v))
	}
}

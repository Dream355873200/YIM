// Package seq: 号段双 buffer 发号器 (对标微信 seqsvr)。
//
// 两类序列 (biz 区分):
//
//	conv  — 会话 seq, 每会话独立单调, 消息排序唯一依据
//	sync  — 用户 sync seq, 任意会话有新消息时递增, 推拉同步的"漏没漏"水位
//	msg   — 全局消息 ID (key=0), 里程碑1 复用号段, 后续可换雪花
//	uid / conv_id — 实体 ID 发号
//
// 双 buffer: 当前号段剩余 < 10% 时异步预取下一段, 领取后原子切换。
// DB 宕机可用性窗口 ≈ 剩余号段 / 发号速率 (step 越大窗口越长, 代价是浪费)。
package seq

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log"
	"math"
	"sync"
	"sync/atomic"
	"time"
)

var ErrBatchTooLarge = errors.New("seq: batch exceeds segment step")

// Segment 号段区间 [start, end], cursor 为已分配位置。
type Segment struct {
	start, end int64
	cursor     atomic.Int64
}

func newSegment(start, end int64) *Segment {
	s := &Segment{start: start, end: end}
	s.cursor.Store(start - 1)
	return s
}

// take CAS 抢占 n 个号。耗尽返回 false。
// 竞争失败重试而非加锁: 号段分配是无锁热路径。
func (s *Segment) take(n int64) (int64, bool) {
	for {
		cur := s.cursor.Load()
		next := cur + n
		if next > s.end {
			return 0, false
		}
		if s.cursor.CompareAndSwap(cur, next) {
			return next - n + 1, true
		}
	}
}

type Allocator struct {
	meta *sql.DB
	biz  string
	key  int64
	step int64

	cur  atomic.Pointer[Segment] // 当前发号段
	buf  atomic.Pointer[Segment] // 预取好的下一段
	last atomic.Int64            // 已发出的最大号, math.MinInt64 = 尚未发过

	mu sync.Mutex // 串行化段装载 (DB 是慢路径, 必须防惊群)
}

// NewAllocator 同步装载首段 —— 调用方保证启动期 DB 可用。
func NewAllocator(ctx context.Context, meta *sql.DB, biz string, key int64, step int) (*Allocator, error) {
	a := &Allocator{meta: meta, biz: biz, key: key, step: int64(step)}
	a.last.Store(math.MinInt64)
	seg, err := a.loadSegment(ctx)
	if err != nil {
		return nil, fmt.Errorf("seq %s/%d init: %w", biz, key, err)
	}
	a.cur.Store(seg)
	// 首段装好但尚未发号: 水位 = 段起点-1 (如首段 [1,10000] → 水位 0)
	a.last.Store(seg.start - 1)
	return a, nil
}

// Next 取 n 个连续号, 返回区间起点 [ret, ret+n-1]。
// 号段耗尽时同步装载; 越过段尾的号作废 (seq 允许空洞, 单调性不受影响)。
func (a *Allocator) Next(n int) (int64, error) {
	if n <= 0 || int64(n) > a.step {
		return 0, ErrBatchTooLarge
	}
	for {
		seg := a.cur.Load()
		if seg != nil {
			if start, ok := seg.take(int64(n)); ok {
				a.last.Store(start + int64(n) - 1)
				// 低水位触发异步预取: 剩余不足 10%
				if seg.end-seg.cursor.Load() < a.step/10 {
					a.refillAsync()
				}
				return start, nil
			}
		}
		if err := a.swapSync(); err != nil {
			return 0, err
		}
	}
}

// Cur 已分配到的位置 (监控号段水位)
func (a *Allocator) Cur() int64 {
	if seg := a.cur.Load(); seg != nil {
		return seg.cursor.Load()
	}
	return 0
}

// Peek 只读水位: 已发出的最大号, 不发号不触发装载 (GetSyncSeq 用)。
func (a *Allocator) Peek() (int64, bool) {
	v := a.last.Load()
	if v == math.MinInt64 {
		return 0, false
	}
	return v, true
}

func (a *Allocator) refillAsync() {
	if a.buf.Load() != nil {
		return
	}
	go func() {
		a.mu.Lock()
		defer a.mu.Unlock()
		if a.buf.Load() != nil {
			return
		}
		seg, err := a.loadSegment(context.Background())
		if err != nil {
			// 预取失败不致命: 段耗尽时 Next 走 swapSync 同步装载兜底
			log.Printf("seq %s/%d prefetch failed: %v", a.biz, a.key, err)
			return
		}
		a.buf.Store(seg)
	}()
}

func (a *Allocator) swapSync() error {
	a.mu.Lock()
	defer a.mu.Unlock()
	if seg := a.buf.Swap(nil); seg != nil {
		a.cur.Store(seg)
		return nil
	}
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	seg, err := a.loadSegment(ctx)
	if err != nil {
		return err
	}
	a.cur.Store(seg)
	return nil
}

// loadSegment 原子领取号段。
// INSERT IGNORE 建行 + 行锁 UPDATE + 同事务读回: 并发领取者拿到不重叠区间。
func (a *Allocator) loadSegment(ctx context.Context) (*Segment, error) {
	var lastErr error
	for attempt := 0; attempt < 3; attempt++ {
		if attempt > 0 {
			time.Sleep(time.Duration(attempt) * 100 * time.Millisecond)
		}
		seg, err := a.tryLoad(ctx)
		if err == nil {
			return seg, nil
		}
		lastErr = err
	}
	return nil, fmt.Errorf("seq %s/%d load: %w", a.biz, a.key, lastErr)
}

func (a *Allocator) tryLoad(ctx context.Context) (*Segment, error) {
	tx, err := a.meta.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer func() { _ = tx.Rollback() }()

	if _, err = tx.ExecContext(ctx,
		"INSERT IGNORE INTO seq_segment (biz, key_id, max_id, step) VALUES (?, ?, 0, ?)",
		a.biz, a.key, a.step); err != nil {
		return nil, err
	}
	if _, err = tx.ExecContext(ctx,
		"UPDATE seq_segment SET max_id = max_id + ? WHERE biz = ? AND key_id = ?",
		a.step, a.biz, a.key); err != nil {
		return nil, err
	}
	var maxID int64
	if err = tx.QueryRowContext(ctx,
		"SELECT max_id FROM seq_segment WHERE biz = ? AND key_id = ?",
		a.biz, a.key).Scan(&maxID); err != nil {
		return nil, err
	}
	if err = tx.Commit(); err != nil {
		return nil, err
	}
	return newSegment(maxID-a.step+1, maxID), nil
}

// ============================================================
// Pool: 按需创建、复用每 key 的 Allocator
// (消息写入的并发会话数有限, Pool 无淘汰——冷会话的号段常驻内存可接受;
//  若未来会话量极大, 加 LRU 淘汰未耗尽的段会浪费号, 得不偿失)
// ============================================================

type Pool struct {
	meta *sql.DB
	step int

	mu sync.Mutex
	m  map[string]*Allocator
}

func NewPool(meta *sql.DB, step int) *Pool {
	return &Pool{meta: meta, step: step, m: make(map[string]*Allocator)}
}

// For 取 (biz, key) 的发号器, 不存在则同步初始化首段。
func (p *Pool) For(ctx context.Context, biz string, key int64) (*Allocator, error) {
	k := fmt.Sprintf("%s:%d", biz, key)
	p.mu.Lock()
	a, ok := p.m[k]
	p.mu.Unlock()
	if ok {
		return a, nil
	}
	na, err := NewAllocator(ctx, p.meta, biz, key, p.step)
	if err != nil {
		return nil, err
	}
	p.mu.Lock()
	if existing, ok := p.m[k]; ok {
		p.mu.Unlock()
		return existing, nil // 并发创建: 复用先到者
	}
	p.m[k] = na
	p.mu.Unlock()
	return na, nil
}

// Current 只读水位 (GetSyncSeq): 已发出的最大号, 不发号不触发段装载。
//
// 精确性前提: 单进程持有 (biz,key) 的 Allocator —— 拆分后 Seq Svc 是唯一发号进程。
//   - 本进程有 allocator: 内存 last 精确;
//   - 本进程无 allocator: 段都未被持有, DB max_id 即精确水位。
func (p *Pool) Current(ctx context.Context, biz string, key int64) (int64, error) {
	k := fmt.Sprintf("%s:%d", biz, key)
	p.mu.Lock()
	a := p.m[k]
	p.mu.Unlock()
	if a != nil {
		if v, ok := a.Peek(); ok {
			return v, nil
		}
	}
	var maxID int64
	err := p.meta.QueryRowContext(ctx,
		"SELECT max_id FROM seq_segment WHERE biz = ? AND key_id = ?", biz, key).Scan(&maxID)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, nil // 该 key 从未发过号
	}
	if err != nil {
		return 0, err
	}
	return maxID, nil
}

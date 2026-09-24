// Package timewheel: 层级时间轮 (Kafka utils.timer 同构)。
//
// 解决什么: time.AfterFunc 每任务一个 runtime 四叉堆节点, 插入 O(log n)
// 且全局锁竞争, 万级并发定时器时内存与调度开销可见。时间轮用"精度换吞吐":
// O(1) 插入的无序桶数组, 靠任务容忍粗粒度触发 (±tick) 买单。
//
// 层级: 单级轮的跨度 = tick × size, 精度与跨度矛盾。多级轮用不同精度的
// 轮子叠加 (钟表秒/分/针思想): 插入时延迟超出本轮跨度 → 进溢出轮 (懒创建);
// 溢出轮扫到桶时任务未到期 → 按剩余延迟降级重插 (最终必落进第一级被精确触发)。
//
// 懒删除: 不提供 Remove —— 调用方在任务触发时自行校验有效性 (投递层的
// pendingAcks.alive()), 失效任务静默丢弃。桶里残余的空转任务最长多活一个
// 延迟周期, 允许浪费换简单。
//
// 并发模型: 单 driver goroutine 每 tick 推进一次 (advance), 多 goroutine
// 并发 After。桶各自持锁; currentTime 由 wheel 锁保护。
package timewheel

import (
	"sync"
	"sync/atomic"
	"time"
)

// Task 到期回调, 在独立 goroutine 中执行。
type Task func()

type entry struct {
	expire time.Time // 绝对到期时间 (跨轮降级重算的依据)
	fn     Task
}

type bucket struct {
	mu      sync.Mutex
	entries []*entry
}

func (b *bucket) add(e *entry) {
	b.mu.Lock()
	b.entries = append(b.entries, e)
	b.mu.Unlock()
}

// take 清空并取走桶内全部任务 (drain 语义, 持锁窗口最小化)。
func (b *bucket) take() []*entry {
	b.mu.Lock()
	es := b.entries
	b.entries = nil
	b.mu.Unlock()
	return es
}

// Wheel 一级时间轮。由 Start 创建并驱动; After 并发安全。
type Wheel struct {
	tick  time.Duration
	size  uint32
	mask  uint32
	slots []*bucket

	mu       sync.Mutex   // 保护 current / overflow (driver 写, After 读)
	current  time.Time    // 当前轮面时间 (driver 已推进到的 tick 边界)
	overflow *Wheel       // 上一级 (更粗) 的轮, 懒创建
	root     *Wheel       // 降级重插的入口 (只有 root 会接到降级任务)
	ticker   *time.Ticker // 仅 root 持有
	stopCh   chan struct{}
	stopOnce sync.Once
	fired    atomic.Int64 // 统计: 触发数 (观测用)
}

// Start 创建并启动一个层级时间轮。
// tick 是最小刻度 (触发精度 ±tick), size 是每级槽数 (建议 2 的幂)。
// 第一级覆盖 [0, tick×size), 超出部分自动逐级溢出, 无层数上限。
func Start(tick time.Duration, size uint32) *Wheel {
	w := &Wheel{
		tick:    tick,
		size:    size,
		mask:    size - 1,
		slots:   make([]*bucket, size),
		current: time.Now(),
		stopCh:  make(chan struct{}),
	}
	for i := range w.slots {
		w.slots[i] = &bucket{}
	}
	w.root = w
	w.ticker = time.NewTicker(tick)
	go w.loop()
	return w
}

// span 本轮覆盖的时间跨度。
func (w *Wheel) span() time.Duration { return w.tick * time.Duration(w.size) }

// After 延迟 delay 后执行 fn (实际触发在 [delay, delay+tick) 窗口内)。
// O(1): 计算槽下标 + 桶 append。delay ≤ 0 立即执行。
func (w *Wheel) After(delay time.Duration, fn Task) {
	if delay <= 0 {
		go fn()
		return
	}
	w.insert(w.root, time.Now().Add(delay), fn)
}

// insert 把 (expire, fn) 放入 wheel 层级 (wheel 必须是 root)。
func (w *Wheel) insert(root *Wheel, expire time.Time, fn Task) {
	wheel := root
	for {
		wheel.mu.Lock()
		remaining := expire.Sub(wheel.current)
		if remaining < wheel.tick {
			// 剩余不足一个刻度: 直接触发 (Kafka 同款语义)。既防"任务落进
			// 本拍已扫过的槽要空等一整圈"的边界竞争, 也保证触发窗口 ≤ tick。
			wheel.mu.Unlock()
			go fn()
			return
		}
		if remaining < wheel.span() {
			// 落在本轮跨度内: 按绝对到期时间定槽。
			// 槽号基于 expire 而非 remaining —— current 与槽号同源, 驱动侧
			// 推进到哪格就扫哪格, 天然对齐。
			idx := uint32(expire.UnixNano()/int64(wheel.tick)) & wheel.mask
			wheel.slots[idx].add(&entry{expire: expire, fn: fn})
			wheel.mu.Unlock()
			return
		}
		// 超出跨度: 取 (懒建) 溢出轮, 逐级上交
		ow := wheel.overflow
		if ow == nil {
			ow = newLevel(wheel, root)
			wheel.overflow = ow
		}
		wheel.mu.Unlock()
		wheel = ow
	}
}

// newLevel 创建 wheel 的下一级: tick = wheel.span(), 尺寸不变。
func newLevel(wheel, root *Wheel) *Wheel {
	w := &Wheel{
		tick:    wheel.span(),
		size:    wheel.size,
		mask:    wheel.mask,
		slots:   make([]*bucket, wheel.size),
		current: wheel.current,
		root:    root,
	}
	for i := range w.slots {
		w.slots[i] = &bucket{}
	}
	return w
}

// loop root 轮的驱动循环: 每 tick 推进一次。
func (w *Wheel) loop() {
	for {
		select {
		case now := <-w.ticker.C:
			w.advance(now)
		case <-w.stopCh:
			w.ticker.Stop()
			return
		}
	}
}

// advance 推进到 now 所在 tick 并扫桶; 若本轮走满一圈, 逐级推进溢出轮。
// 只有 driver 调用 (root 每 tick 一次, 溢出轮经此递归), 无并发推进。
func (w *Wheel) advance(now time.Time) {
	w.mu.Lock()
	if now.Sub(w.current) < w.tick {
		w.mu.Unlock()
		return // ticker 抖动提前到达, 等下一拍
	}
	w.current = now
	idx := uint32(now.UnixNano()/int64(w.tick)) & w.mask
	w.mu.Unlock()

	w.drain(w.slots[idx], now)

	// 本轮走满一圈 → 溢出轮的一格, 递归推进 (钟表分针动一格 = 秒针走一圈)
	if w.overflow != nil && idx == 0 {
		w.overflow.advance(now)
	}
}

// drain 扫桶: 到期触发, 未到期 (跨轮降级 / 加快到的边界竞争) 重插回 root。
func (w *Wheel) drain(b *bucket, now time.Time) {
	for _, e := range b.take() {
		if !e.expire.After(now) {
			w.fired.Add(1)
			go e.fn()
			continue
		}
		w.root.insert(w.root, e.expire, e.fn)
	}
}

// FiredCount 触发总数 (观测用)。
func (w *Wheel) FiredCount() int64 { return w.fired.Load() }

// Stop 停止驱动。已入桶任务不再触发 (投递层重启丢内存态 = 多重推一次, 去重兜底)。
func (w *Wheel) Stop() {
	w.stopOnce.Do(func() { close(w.stopCh) })
}

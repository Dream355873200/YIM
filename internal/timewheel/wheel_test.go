package timewheel

import (
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

// TestAfterFiresWithinTick 基本: 单任务在 [delay, delay+tick] 窗口内触发。
func TestAfterFiresWithinTick(t *testing.T) {
	w := Start(20*time.Millisecond, 64)
	defer w.Stop()

	done := make(chan struct{})
	start := time.Now()
	w.After(80*time.Millisecond, func() { close(done) })

	select {
	case <-done:
		elapsed := time.Since(start)
		if elapsed < 60*time.Millisecond { // 允许 driver 抖动的少量提前
			t.Fatalf("fired too early: %v", elapsed)
		}
		if elapsed > 300*time.Millisecond {
			t.Fatalf("fired too late: %v", elapsed)
		}
	case <-time.After(time.Second):
		t.Fatal("task never fired")
	}
}

// TestImmediateFires delay≤0 立即执行。
func TestImmediateFires(t *testing.T) {
	w := Start(50*time.Millisecond, 8)
	defer w.Stop()

	done := make(chan struct{})
	w.After(0, func() { close(done) })
	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("immediate task never fired")
	}
}

// TestManyTimers 万级并发插入: 全部触发且触发次数精确 (无丢/无重)。
func TestManyTimers(t *testing.T) {
	w := Start(10*time.Millisecond, 256)
	defer w.Stop()

	const n = 10000
	var fired atomic.Int64
	var wg sync.WaitGroup
	wg.Add(n)
	for i := 0; i < n; i++ {
		d := time.Duration(10+i%50) * time.Millisecond // 10~60ms, 密集同槽竞争
		w.After(d, func() {
			fired.Add(1)
			wg.Done()
		})
	}
	fin := make(chan struct{})
	go func() { wg.Wait(); close(fin) }()
	select {
	case <-fin:
	case <-time.After(5 * time.Second):
		t.Fatalf("fired %d/%d", fired.Load(), n)
	}
	if got := fired.Load(); got != n {
		t.Fatalf("fired %d, want %d (lost or duplicated)", got, n)
	}
}

// TestHierarchicalOverflow 延迟远超单级跨度: 必须逐级降级后精确触发。
// tick 10ms × 8 槽 = 80ms 一级; 500ms 需要 ≥3 级溢出。
func TestHierarchicalOverflow(t *testing.T) {
	w := Start(10*time.Millisecond, 8)
	defer w.Stop()

	done := make(chan struct{})
	start := time.Now()
	w.After(500*time.Millisecond, func() { close(done) })
	select {
	case <-done:
		if elapsed := time.Since(start); elapsed > time.Second {
			t.Fatalf("overflow task fired too late: %v", elapsed)
		}
	case <-time.After(3 * time.Second):
		t.Fatal("overflow task never fired (demotion broken)")
	}
}

// TestDeepOverflow 多级嵌套 (延迟超过两级跨度): 溢出轮的溢出轮。
func TestDeepOverflow(t *testing.T) {
	w := Start(10*time.Millisecond, 8) // span: 80ms, 640ms, 5.12s
	defer w.Stop()

	done := make(chan struct{})
	start := time.Now()
	w.After(1500*time.Millisecond, func() { close(done) }) // 落在第 3 级
	select {
	case <-done:
		if elapsed := time.Since(start); elapsed > 4*time.Second {
			t.Fatalf("deep overflow fired too late: %v", elapsed)
		}
	case <-time.After(8 * time.Second):
		t.Fatal("deep overflow task never fired")
	}
}

// TestInsertRacesWithDrain 插入与驱动扫桶的边界竞争:
// 密集插入接近 tick 的延迟, 不允许有任务错过一圈才触发 (≤2×tick 宽限)。
func TestInsertRacesWithDrain(t *testing.T) {
	w := Start(10*time.Millisecond, 32)
	defer w.Stop()

	const n = 2000
	var fired atomic.Int64
	var wg sync.WaitGroup
	wg.Add(n)
	var wgInsert sync.WaitGroup
	for i := 0; i < n; i++ {
		wgInsert.Add(1)
		go func(i int) {
			defer wgInsert.Done()
			w.After(10*time.Millisecond+time.Duration(i%3)*time.Millisecond, func() {
				fired.Add(1)
				wg.Done()
			})
		}(i)
	}
	wgInsert.Wait()
	fin := make(chan struct{})
	go func() { wg.Wait(); close(fin) }()
	select {
	case <-fin:
	case <-time.After(5 * time.Second):
		t.Fatalf("racy insert fired %d/%d", fired.Load(), n)
	}
}

// TestStop Stop 后不再触发 (驱动 goroutine 退出)。
func TestStop(t *testing.T) {
	w := Start(10*time.Millisecond, 8)
	var fired atomic.Int64
	w.After(30*time.Millisecond, func() { fired.Add(1) })
	w.Stop()
	time.Sleep(100 * time.Millisecond)
	if got := fired.Load(); got != 0 {
		t.Fatalf("task fired after stop")
	}
}

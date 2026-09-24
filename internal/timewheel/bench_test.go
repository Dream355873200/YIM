package timewheel

import (
	"runtime"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

// 基准: 百万级 pending 定时器的并发插入+触发, 对照 time.AfterFunc。
//
// 结论预期 (写入 STUDY): 规模小 (万级) 时两者无可见差异 —— Go runtime
// 定时器自 1.14 起是 per-P 定时器, 本就不差; 时间轮的收益在 pending 规模
// 逼近十万/百万时显现 (runtime 每定时器一个堆节点 + 全局调度, 时间轮是
// 固定桶数组 + O(1) append)。用 allocs/op 和总内存刻画。

// benchN 向 fn 注册 n 个延迟 ~10ms 的定时器, 等全部触发后返回 (b) 或统计 (fn外)。
func benchInsertFire(b *testing.B, n int, arm func(d time.Duration, fn func())) {
	var fired atomic.Int64
	var wg sync.WaitGroup
	wg.Add(n)
	done := make(chan struct{})
	go func() { wg.Wait(); close(done) }()

	b.ResetTimer()
	start := time.Now()
	var wgIns sync.WaitGroup
	for g := 0; g < runtime.GOMAXPROCS(0); g++ {
		wgIns.Add(1)
		go func(g int) {
			defer wgIns.Done()
			for i := g; i < n; i += runtime.GOMAXPROCS(0) {
				arm(10*time.Millisecond, func() {
					fired.Add(1)
					wg.Done()
				})
			}
		}(g)
	}
	wgIns.Wait()
	<-done
	b.StopTimer()
	b.ReportMetric(float64(n)/time.Since(start).Seconds(), "timers/s")
}

func BenchmarkWheel100k(b *testing.B) {
	w := Start(5*time.Millisecond, 1024)
	defer w.Stop()
	for i := 0; i < b.N; i++ {
		benchInsertFire(b, 100_000, func(d time.Duration, fn func()) { w.After(d, fn) })
	}
}

func BenchmarkAfterFunc100k(b *testing.B) {
	for i := 0; i < b.N; i++ {
		benchInsertFire(b, 100_000, func(d time.Duration, fn func()) {
			time.AfterFunc(d, fn)
		})
	}
}

// BenchmarkMemory 高量级内存对照: 各注册 50 万 pending (不触发, 量稳态内存)。
func benchmarkPendingMemory(b *testing.B, arm func(d time.Duration, fn func())) {
	var block atomic.Int64
	var before, after runtime.MemStats
	runtime.GC()
	runtime.ReadMemStats(&before)
	const n = 500_000
	for i := 0; i < n; i++ {
		arm(time.Hour, func() { block.Add(1) }) // 永不触发: 纯 pending 存量
	}
	runtime.ReadMemStats(&after)
	b.ReportMetric(float64(after.TotalAlloc-before.TotalAlloc)/n, "B-alloc/timer")
	b.ReportMetric(float64(after.HeapObjects-before.HeapObjects)/n, "objects/timer")
}

func BenchmarkWheelPendingMemory(b *testing.B) {
	w := Start(time.Minute, 1024)
	defer w.Stop()
	benchmarkPendingMemory(b, func(d time.Duration, fn func()) { w.After(d, fn) })
}

func BenchmarkAfterFuncPendingMemory(b *testing.B) {
	benchmarkPendingMemory(b, func(d time.Duration, fn func()) {
		time.AfterFunc(d, fn)
	})
}

package cache

import (
	"context"
	"testing"
)

func TestBloomAddContain(t *testing.T) {
	b := NewBloom(1<<20, 4)
	for i := int64(0); i < 1000; i++ {
		b.Add(BloomKey(i, i*7))
	}
	for i := int64(0); i < 1000; i++ {
		if !b.MightContain(BloomKey(i, i*7)) {
			t.Fatalf("false negative at %d (布隆不允许假阴性)", i)
		}
	}
	// 全新 key 允许假阳性, 但 1000 个里不应大面积命中
	fp := 0
	for i := int64(10000); i < 11000; i++ {
		if b.MightContain(BloomKey(i, i*7)) {
			fp++
		}
	}
	if fp > 50 {
		t.Fatalf("false positive rate too high: %d/1000", fp)
	}
}

// 重建装载期间并发 Add 必须双写影子代, 否则换血后出现假阴性
func TestBloomRebuildDoubleWrite(t *testing.T) {
	b := NewBloom(1<<20, 4)

	// Add 放在 loader 里: 此时 Rebuild 已挂上自己的影子代,
	// 精确模拟"装载进行中有新消息落库"的并发时序
	if err := b.Rebuild(context.Background(), func(ctx context.Context) ([]uint64, error) {
		b.Add(BloomKey(1, 1))
		return []uint64{BloomKey(2, 2)}, nil
	}); err != nil {
		t.Fatal(err)
	}
	if !b.MightContain(BloomKey(1, 1)) {
		t.Fatal("key added during rebuild lost (假阴性: 双写失效)")
	}
	if !b.MightContain(BloomKey(2, 2)) {
		t.Fatal("loaded key missing after rebuild")
	}
}

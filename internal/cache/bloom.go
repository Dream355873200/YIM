// 双 buffer 布隆过滤器: 幂等前置筛的第一道闸 (ARCHITECTURE.md §6)。
//
// 定位与安全性论证 (面试高频, 想清楚再用):
//   布隆说"可能有" → 准确率无保证 → 只是去查一次 Redis/DB, 多花一次往返;
//   布隆说"肯定没有" → 无假阴性前提成立时才可信 → 直接走新增路径。
//   因此它只拦截"全新消息"这 99% 的 Redis 往返, 判错的代价被 DB 唯一键
//   UNIQUE(conv_id, client_msg_id) 兜住 —— 布隆任何时刻都可以整个丢掉,
//   丢掉后系统退化为"每条消息多一次 SETNX", 正确性不受影响。
//
// 为什么双 buffer: 布隆不支持删除, 重建必须整表换血。单 buffer 在线重建
// 会读到"半新半旧"状态; 双 buffer 在影子位图上重建, 重建期间新增写同时
// 落两代 (防换血瞬间假阴性), 完成后原子换指针。
//
// 重建触发: 启动预热 + 调度系统每日重建 (里程碑6 接入, 本文件提供 API)。
package cache

import (
	"context"
	"encoding/binary"
	"hash/fnv"
	"sync/atomic"
)

type Bloom struct {
	mBits uint64 // 位图位数
	k     uint32 // 哈希函数个数

	cur      atomic.Pointer[bloomGen] // 当前代: 读 + 写
	building atomic.Pointer[bloomGen] // 影子代: 重建期间写双份, 建完换上来
}

type bloomGen struct {
	bits []uint64
}

// NewBloom mBits 取 1<<25 (4MB) 时, 百万级 key 假阳性率 < 0.02%;
// 假阳性只多一次 Redis 查询, 尺寸按消息量级估算即可, 无需精确。
func NewBloom(mBits uint64, k uint32) *Bloom {
	if mBits == 0 {
		mBits = 1 << 25
	}
	if k == 0 {
		k = 4
	}
	b := &Bloom{mBits: mBits, k: k}
	b.cur.Store(b.newGen())
	return b
}

func (b *Bloom) newGen() *bloomGen {
	return &bloomGen{bits: make([]uint64, (b.mBits+63)/64)}
}

// hashes Kirsch-Mitzenmacher: 用两个 64bit 哈希线性组合出 k 个位置,
// 免去真算 k 次哈希; FNV-1a 换 seed 即得第二个。
func (b *Bloom) hashes(key uint64) []uint64 {
	var buf [8]byte
	binary.LittleEndian.PutUint64(buf[:], key)

	h1raw := fnv.New64a()
	_, _ = h1raw.Write(buf[:])
	h1 := h1raw.Sum64()

	var seed [9]byte
	copy(seed[:8], buf[:])
	seed[8] = 0xB7 // 变换输入凑第二个独立哈希, 不引入第二个哈希族
	h2raw := fnv.New64a()
	_, _ = h2raw.Write(seed[:])
	h2 := h2raw.Sum64()

	out := make([]uint64, b.k)
	for i := uint32(0); i < b.k; i++ {
		out[i] = (h1 + uint64(i)*h2) % b.mBits
	}
	return out
}

func (g *bloomGen) add(pos []uint64) {
	for _, p := range pos {
		g.bits[p/64] |= 1 << (p % 64)
	}
}

func (g *bloomGen) mightContain(pos []uint64) bool {
	for _, p := range pos {
		if g.bits[p/64]&(1<<(p%64)) == 0 {
			return false // 任一位为 0 → 必然没见过
		}
	}
	return true
}

// Add 成功落库后调用。key = conv_id 与 client_msg_id 的复合
// (幂等键是 (conv_id, client_msg_id), 见 service.go)。
func (b *Bloom) Add(key uint64) {
	pos := b.hashes(key)
	b.cur.Load().add(pos)
	if bg := b.building.Load(); bg != nil {
		bg.add(pos) // 重建中: 双写, 防换血后假阴性
	}
}

// MightContain true = 可能见过 (去查幂等缓存), false = 一定没见过 (直接走新增)。
func (b *Bloom) MightContain(key uint64) bool {
	return b.cur.Load().mightContain(b.hashes(key))
}

// Rebuild 整表换血: 影子位图装载 loader 给的全部 key, 装完原子替换。
// loader 通常按 create_time 窗口扫 DB 取近期 client_msg_id (调度系统任务)。
// 顺序要点: 影子代必须先挂上再装载 —— 装载期间并发的 Add() 会双写影子代,
// 否则装载与换血之间落进来的 key 在新代缺失 (假阴性, 虽然兜底防线可接,
// 但窗口能关就关)。
func (b *Bloom) Rebuild(ctx context.Context, loader func(ctx context.Context) ([]uint64, error)) error {
	bg := b.newGen()
	b.building.Store(bg)
	keys, err := loader(ctx)
	if err != nil {
		b.building.Store(nil)
		return err
	}
	for _, key := range keys {
		bg.add(b.hashes(key))
	}
	b.cur.Store(bg) // 原子换指针: 读侧要么旧代要么全量新代, 无中间态
	b.building.Store(nil)
	return nil
}

package comet

import (
	"sync"
)

// Keeper 连接仓库: uid+device → Conn 的内存索引。
//
// 分桶 (goim 经典设计): 全局一把锁在连接数上万后成为推送热路径的瓶颈,
// 按 uid 分桶后锁冲突面缩小 N 倍。桶数 2 的幂, 取模即定位。
const bucketCount = 16

// Keeper 并发安全。Add/Remove 由连接生命周期驱动, Get/Devices 由推送 RPC 驱动。
type Keeper struct {
	bs [bucketCount]bucket
}

type bucket struct {
	mu sync.RWMutex
	// uid → deviceID → conn (多端: 同一 uid 每设备一条)
	m map[int64]map[string]*Conn
}

func NewKeeper() *Keeper {
	k := &Keeper{}
	for i := range k.bs {
		k.bs[i].m = make(map[int64]map[string]*Conn)
	}
	return k
}

// Add 登记已认证连接。同 uid+device 已有旧连接时由调用方 (handler) 先踢旧。
func (k *Keeper) Add(c *Conn) {
	b := k.bucketFor(c.uid)
	b.mu.Lock()
	defer b.mu.Unlock()
	dm, ok := b.m[c.uid]
	if !ok {
		dm = make(map[string]*Conn)
		b.m[c.uid] = dm
	}
	dm[c.deviceID] = c
}

// Remove 摘除。校验 conn 身份: 旧连接关闭时若槽位已被新连接顶替, 不能误删。
// 返回值: 该 uid 在本实例的最后一条连接是否刚被摘掉 (路由表注销用)。
func (k *Keeper) Remove(c *Conn) bool {
	if !c.IsAuthed() {
		return false
	}
	b := k.bucketFor(c.uid)
	b.mu.Lock()
	defer b.mu.Unlock()
	dm, ok := b.m[c.uid]
	if !ok {
		return false
	}
	if cur, ok := dm[c.deviceID]; ok && cur == c {
		delete(dm, c.deviceID)
	}
	if len(dm) == 0 {
		delete(b.m, c.uid)
		return true
	}
	return false
}

// Get 精确取 uid 的某设备连接
func (k *Keeper) Get(uid int64, deviceID string) (*Conn, bool) {
	b := k.bucketFor(uid)
	b.mu.RLock()
	defer b.mu.RUnlock()
	dm, ok := b.m[uid]
	if !ok {
		return nil, false
	}
	c, ok := dm[deviceID]
	return c, ok
}

// Devices 取 uid 全部在线连接 (多端推送)
func (k *Keeper) Devices(uid int64) []*Conn {
	b := k.bucketFor(uid)
	b.mu.RLock()
	defer b.mu.RUnlock()
	dm, ok := b.m[uid]
	if !ok {
		return nil
	}
	out := make([]*Conn, 0, len(dm))
	for _, c := range dm {
		out = append(out, c)
	}
	return out
}

// All 遍历全部连接 (排水/统计/心跳扫描)
func (k *Keeper) All() []*Conn {
	var out []*Conn
	for i := range k.bs {
		b := &k.bs[i]
		b.mu.RLock()
		for _, dm := range b.m {
			for _, c := range dm {
				out = append(out, c)
			}
		}
		b.mu.RUnlock()
	}
	return out
}

func (k *Keeper) Count() int { return len(k.All()) }

// Sweep 返回心跳超时连接 (调用方负责 Close)。判死依据是"最近活跃",
// 收发都续命; 阈值 = 3 × 心跳间隔 (常量在 server.go)。
func (k *Keeper) Sweep(idleMs int64) []*Conn {
	var dead []*Conn
	for _, c := range k.All() {
		if c.IdleMs() > idleMs {
			dead = append(dead, c)
		}
	}
	return dead
}

func (k *Keeper) bucketFor(uid int64) *bucket { return &k.bs[uid&(bucketCount-1)] }

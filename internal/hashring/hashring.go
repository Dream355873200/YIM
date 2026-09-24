// Package hashring: 一致性哈希环 (虚拟节点 + 权重)。
//
// 适用边界 (与 store 包 slot 预分片对照):
//   - 数据分片 (MySQL): 节点固定 → slot 预分片 + 映射表, 不用环
//   - 动态节点层: 连接网关 Comet 的接入点分配、多节点缓存分片 → 用环,
//     节点增减只影响相邻区间, 避免连接/缓存全量重映射
//
// Comet 场景: 用户建立连接时按 uid 选接入点 (网关本地缓存会话状态时,
// 必须保证同一 uid 稳定落同一实例); 网关扩缩容只迁移相邻段的连接。
// 缓存场景: 节点宕机只击穿相邻段, 而非雪崩全集群。
package hashring

import (
	"hash/fnv"
	"sort"
	"strconv"
	"sync"
)

type vnode struct {
	hash uint64
	node string
}

type Ring struct {
	mu            sync.RWMutex
	vnodes        []vnode // 按 hash 升序
	vnodesPerNode int
	nodes         map[string]struct{}
}

// New vnodesPerNode: 每物理节点的虚拟节点基数 (权重 1 时)。
// 经验值 100~200 可将倾斜控制在 5% 以内。
func New(vnodesPerNode int) *Ring {
	if vnodesPerNode <= 0 {
		vnodesPerNode = 100
	}
	return &Ring{
		vnodesPerNode: vnodesPerNode,
		nodes:         make(map[string]struct{}),
	}
}

// Add 加入节点, weight 支持异构机器 (大机器挂更多虚拟节点)。
func (r *Ring) Add(node string, weight int) {
	if weight <= 0 {
		weight = 1
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, ok := r.nodes[node]; ok {
		return
	}
	r.nodes[node] = struct{}{}
	count := r.vnodesPerNode * weight
	for i := 0; i < count; i++ {
		h := hashKey(node + "#" + strconv.Itoa(i))
		r.vnodes = append(r.vnodes, vnode{hash: h, node: node})
	}
	sort.Slice(r.vnodes, func(i, j int) bool { return r.vnodes[i].hash < r.vnodes[j].hash })
}

// Remove 摘除节点 (优雅下线时先 Drain 再 Remove)。
func (r *Ring) Remove(node string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, ok := r.nodes[node]; !ok {
		return
	}
	delete(r.nodes, node)
	filtered := r.vnodes[:0]
	for _, v := range r.vnodes {
		if v.node != node {
			filtered = append(filtered, v)
		}
	}
	r.vnodes = filtered
}

// Get key → 归属节点。顺时针找第一个 >= hash 的虚拟节点。
func (r *Ring) Get(key string) (string, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	if len(r.vnodes) == 0 {
		return "", false
	}
	h := hashKey(key)
	i := sort.Search(len(r.vnodes), func(i int) bool { return r.vnodes[i].hash >= h })
	if i == len(r.vnodes) {
		i = 0 // 环回绕
	}
	return r.vnodes[i].node, true
}

// GetN 取 N 个不同节点 (缓存副本/多路写)。不足 N 时返回全部。
func (r *Ring) GetN(key string, n int) []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	if len(r.nodes) == 0 || n <= 0 {
		return nil
	}
	h := hashKey(key)
	i := sort.Search(len(r.vnodes), func(i int) bool { return r.vnodes[i].hash >= h })
	if i == len(r.vnodes) {
		i = 0
	}
	out := make([]string, 0, n)
	seen := make(map[string]struct{}, n)
	for j := 0; j < len(r.vnodes) && len(out) < n; j++ {
		v := r.vnodes[(i+j)%len(r.vnodes)]
		if _, ok := seen[v.node]; !ok {
			seen[v.node] = struct{}{}
			out = append(out, v.node)
		}
	}
	return out
}

func hashKey(s string) uint64 {
	h := fnv.New64a()
	_, _ = h.Write([]byte(s))
	return h.Sum64()
}

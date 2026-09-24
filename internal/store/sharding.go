package store

import (
	"fmt"
	"sync"
)

// ============================================================
// 分片路由: 1024 逻辑 slot → 物理库表 (预分片思想, 对标 Redis Cluster slot)
//
// 为什么不是一致性哈希:
//   数据层节点固定, 扩容是计划内事件 → 预分片 + 映射表更简单,
//   数据定位纯计算零查环。一致性哈希留给动态节点层 (连接网关/缓存), 见 hashring 包。
//
// 路由规则: conv_id % 1024 → slot (永不改变)
//           slot → 物理位置 (映射表, 扩容时只改映射 + 搬 slot 数据)
// 迁移单元 = slot: 调度系统按 slot 圈定会话集合做在线迁移。
// conv_id 的 12bit 分片基因 (见 proto) 预留为 slot 编号的存档位。
// ============================================================

const (
	// SlotCount 逻辑分片数, 终态容量一次定死。
	SlotCount = 1024

	// MsgDBCount 物理库数量 (2 库 × 4 表 = 8 物理组, 每组 128 slot)
	MsgDBCount    = 2
	MsgTablePerDB = 4
)

type MsgShard struct {
	DBIndex    int
	TableIndex int
}

func (s MsgShard) DBName() string { return fmt.Sprintf("yim_msg_%d", s.DBIndex) }
func (s MsgShard) Table() string  { return fmt.Sprintf("message_%02d", s.TableIndex) }

// QualifiedName "yim_msg_0.message_03" (运维排查直接定位)
func (s MsgShard) QualifiedName() string {
	return fmt.Sprintf("%s.%s", s.DBName(), s.Table())
}

// SlotTable slot → 物理分片映射表。
// 默认映射为确定性计算; 扩容时通过 SetOverride 改映射 (后续从元库/etcd 加载)。
type SlotTable struct {
	mu        sync.RWMutex
	mapping   [SlotCount]MsgShard
	overrides int
}

// DefaultSlotTable 8 物理组均分 1024 slot, 相邻 slot 交叉落库 (避免整段数据挤在同一库)。
func DefaultSlotTable() *SlotTable {
	t := &SlotTable{}
	groups := MsgDBCount * MsgTablePerDB
	slotsPerGroup := SlotCount / groups
	for slot := 0; slot < SlotCount; slot++ {
		group := slot / slotsPerGroup
		t.mapping[slot] = MsgShard{
			DBIndex:    group % MsgDBCount,
			TableIndex: group / MsgDBCount,
		}
	}
	return t
}

// Default 全局默认路由表 (单体期共用; 拆微服务后各实例启动时从元库加载)
var Default = DefaultSlotTable()

// RouteMsg conv_id → 物理分片。数据定位: 一次取模 + 一次数组下标。
func RouteMsg(convID int64) MsgShard {
	Default.mu.RLock()
	defer Default.mu.RUnlock()
	return Default.mapping[mod(convID, SlotCount)]
}

// AllMsgShards 枚举全部物理分片 (全分片扫描用: 布隆预热/对账任务)。
func AllMsgShards() []MsgShard {
	out := make([]MsgShard, 0, MsgDBCount*MsgTablePerDB)
	for db := 0; db < MsgDBCount; db++ {
		for tb := 0; tb < MsgTablePerDB; tb++ {
			out = append(out, MsgShard{DBIndex: db, TableIndex: tb})
		}
	}
	return out
}

// SetOverride 扩容迁移时改写单个 slot 的物理位置 (调度系统调用)。
func SetOverride(slot int, s MsgShard) {
	Default.mu.Lock()
	defer Default.mu.Unlock()
	Default.mapping[slot] = s
	Default.overrides++
}

// Overrides 当前生效的手工映射数量 (监控/对账)
func Overrides() int {
	Default.mu.RLock()
	defer Default.mu.RUnlock()
	return Default.overrides
}

// ConvGene conv_id 预留的分片基因位 (见 proto conv_id 结构定义)。
// 升级说明: 基因位规划为 slot 编号存档, 当前 conv_id 由元库发号器分配, 暂为 0。
func ConvGene(convID int64) int64 {
	return (convID >> 10) & 0xFFF
}

func mod(v, m int64) int64 {
	r := v % m
	if r < 0 {
		r += m
	}
	return r
}

// ephemeral 通道 (里程碑12): Redis PubSub 即发即弃信令 —— 输入中提示 /
// 已读回执。特征与普通消息相反: 不落库、可丢 (丢的代价只是对方晚一拍看到
// "正在输入"/"已读"), 任何客户端断线重连后状态自然消散, 所以不值得持久化。
//
// 与 yim.relation.event (Kafka) 的分工: Kafka 承载"必须尽量送达"的关系事件
// (at-least-once + 拉取兜底), ephemeral 承载"丢了无所谓"的瞬态信令 ——
// PubSub 无持久化无消费组, 延迟最低, 语义恰好。
package cache

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/redis/go-redis/v9"
)

const EphemeralChannel = "yim.ephemeral"

// EphemeralMsg 通道消息体 (JSON)。
//   t=typing: conv/from/to —— 对方正在输入
//   t=read:   conv/from/to/seq —— 对方已读至 seq (仅单聊, 群聊回执噪音大)
type EphemeralMsg struct {
	T    string `json:"t"`
	Conv int64  `json:"conv"`
	From int64  `json:"from"`
	To   int64  `json:"to"`
	Seq  int64  `json:"seq,omitempty"`
}

// PublishEphemeral 发布瞬态信令 (nil cache / 发布失败静默 —— 语义即"可丢")。
func (c *Cache) PublishEphemeral(ctx context.Context, m EphemeralMsg) {
	if c == nil {
		return
	}
	b, err := json.Marshal(m)
	if err != nil {
		return
	}
	_ = c.rdb.Publish(ctx, EphemeralChannel, b).Err()
}

// SubscribeEphemeral 订阅瞬态信令; 返回的 PubSub 由调用方 Close。
// nil cache 返回 nil (调用方跳过订阅循环)。
func (c *Cache) SubscribeEphemeral(ctx context.Context) *redis.PubSub {
	if c == nil {
		return nil
	}
	return c.rdb.Subscribe(ctx, EphemeralChannel)
}

// ConvMembersCacheOnly 只读 Redis 的成员表 (不发 DB): comet 收到 CMD_TYPING
// 时的扇出用 —— 投递热路径的 ConvMembers 已把成员表预热进缓存 (10min TTL),
// miss = 冷会话, 输入中提示丢掉无妨。
func (c *Cache) ConvMembersCacheOnly(ctx context.Context, convID int64) ([]int64, bool) {
	if c == nil {
		return nil, false
	}
	raw, err := c.rdb.Get(ctx, fmt.Sprintf("conv:%d:members", convID)).Bytes()
	if err != nil {
		return nil, false
	}
	var m []int64
	if json.Unmarshal(raw, &m) != nil {
		return nil, false
	}
	return m, true
}

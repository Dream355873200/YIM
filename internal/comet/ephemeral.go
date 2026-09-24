// ephemeral.go (里程碑12): 瞬态信令的收发。
//
// 收 (SubscribeEphemeralLoop): 每实例订阅 Redis ephemeral 通道, 按目标 uid
// 过滤本地连接推送 CMD_EVENT (TYPING/READ)。PubSub 全实例广播 —— 目标不在
// 本实例时零成本跳过, 与 Kafka 事件消费同构但无消费组。
//
// 发 (onTyping): 客户端 CMD_TYPING → 成员表 (Redis 热键, miss 丢弃) →
// 逐成员发 ephemeral 消息, 由各实例 (含本实例) 的订阅循环转成 CMD_EVENT。
package comet

import (
	"context"
	"encoding/json"

	"github.com/yim/internal/cache"
	"github.com/yim/kitex_gen/yim"
)

const (
	EvTyping = "TYPING" // EventFrame.type: uid = 正在输入者
	EvRead   = "READ"   // EventFrame.type: uid = 已读者, seq = 读到的水位
)

// SubscribeEphemeralLoop 阻塞订阅循环 (main 起 goroutine)。
// redis 断连由 go-redis 自动重连; ctx 取消即退出。
func SubscribeEphemeralLoop(ctx context.Context, c *cache.Cache, keeper *Keeper) {
	sub := c.SubscribeEphemeral(ctx)
	if sub == nil {
		return
	}
	defer sub.Close()
	ch := sub.Channel()
	for {
		select {
		case <-ctx.Done():
			return
		case msg, ok := <-ch:
			if !ok {
				return
			}
			var m cache.EphemeralMsg
			if json.Unmarshal([]byte(msg.Payload), &m) != nil || m.To == 0 {
				continue
			}
			evType := EvTyping
			frame := &yim.EventFrame{Type: evType, Uid: m.From, ConvId: m.Conv}
			if m.T == "read" {
				evType = EvRead
				frame.Type = evType
				frame.Seq = m.Seq
			}
			for _, dev := range keeper.Devices(m.To) {
				dev.Send(&yim.Frame{Cmd: yim.Command_CMD_EVENT,
					Payload: &yim.Frame_Event{Event: frame}})
			}
		}
	}
}

// onTyping 输入中上行: 扇出给会话其他成员。静默路径为主 (成员冷键/Redis
// 抖动直接丢), 打字提示的语义允许丢。
func (h *Handler) onTyping(c *Conn, f *yim.Frame) {
	if !c.IsAuthed() {
		return
	}
	convID := f.GetTyping().GetConvId()
	if convID == 0 || h.cache == nil {
		return
	}
	members, ok := h.cache.ConvMembersCacheOnly(context.Background(), convID)
	if !ok {
		return
	}
	from := c.UID()
	for _, uid := range members {
		if uid == from {
			continue
		}
		h.cache.PublishEphemeral(context.Background(), cache.EphemeralMsg{
			T: "typing", Conv: convID, From: from, To: uid,
		})
	}
}

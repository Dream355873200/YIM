// events.go (里程碑10): 关系域事件的推侧 —— comet 上的 Kafka 生产 + 消费。
//
// 拓扑 (topic yim.relation.event):
//
//	comet  ──PRESENCE(原始, targets 空)──►┐
//	relation ──好友/群事件(targets 具体用户)─┤──► topic ──► 每个 comet 实例
//	 relation 消费原始 PRESENCE → 补齐好友列表 → 发回同 topic (targets 具体用户)
//	                                       └──► 按 targets 过滤本地连接 → CMD_EVENT 帧
//
// 设计要点:
//   - 每实例全量消费 + 本地过滤: 事件量级低 (社交动作非消息洪峰), 免去路由查询
//     与 per-uid RPC; 消费组 ID 含实例地址, 保证每个实例都拿到全流。
//   - 事件只带"发生了什么", 不带业务全量 —— 客户端收到后局部重拉 (推实时, 拉可靠)。
//   - at-most-once (StartOffset Last + 异步 producer): 事件可丢可重, 丢失由
//     客户端既有的拉取制兜底 (切 tab/进页重拉), 不引入正确性影响。
//   - Kafka 不可用: producer/consumer 均不装配, 全系统退回纯拉取制 (里程碑9 形态)。
package comet

import (
	"context"
	"fmt"
	"time"

	"github.com/segmentio/kafka-go"
	"go.uber.org/zap"
	"google.golang.org/protobuf/proto"

	"github.com/yim/internal/logger"
	"github.com/yim/kitex_gen/yim"
)

const TopicRelationEvent = "yim.relation.event"

// EventPublisher 在线事件生产者 (comet 侧只发原始 PRESENCE, targets 留空由
// relation 补齐好友列表)。
type EventPublisher struct {
	w *kafka.Writer
}

func NewEventPublisher(brokers []string) *EventPublisher {
	return &EventPublisher{w: &kafka.Writer{
		Addr:                   kafka.TCP(brokers...),
		Topic:                  TopicRelationEvent,
		Async:                  true,
		AllowAutoTopicCreation: true,
		BatchTimeout:           5 * time.Millisecond,
		RequiredAcks:           kafka.RequireOne,
		ErrorLogger: kafka.LoggerFunc(func(msg string, args ...interface{}) {
			logger.L.Warn("kafka produce relation event (pull-based fallback covers)",
				zap.String("detail", fmt.Sprintf(msg, args...)))
		}),
	}}
}

// PublishPresence 上线/下线原始事件 (uid 最后一条连接建立/断开)。
func (p *EventPublisher) PublishPresence(uid int64, online bool) {
	if p == nil {
		return
	}
	b, err := proto.Marshal(&yim.RelationEvent{
		Event: &yim.EventFrame{Type: "PRESENCE", Uid: uid, Online: online},
	})
	if err != nil {
		return
	}
	_ = p.w.WriteMessages(context.Background(), kafka.Message{Value: b})
}

// Close 排空关闭 (优雅停机)。
func (p *EventPublisher) Close() {
	if p == nil {
		return
	}
	_ = p.w.Close()
}

// ConsumeRelationEvents 每实例全量消费事件流: 按 targets 过滤本地在线连接,
// 逐连接发 CMD_EVENT 帧。targets 为空的事件 (原始 PRESENCE) 跳过 —— 那是
// 发给 relation 补目标的, 不直达客户端。
// reader 用 per-instance 消费组 (独立于 yim-job), 保证每个实例都收全流。
func ConsumeRelationEvents(ctx context.Context, brokers []string, instanceID string, keeper *Keeper) {
	r := kafka.NewReader(kafka.ReaderConfig{
		Brokers:     brokers,
		GroupID:     "yim-comet-rel-" + instanceID, // 每实例独立组 = 全量广播
		Topic:       TopicRelationEvent,
		MinBytes:    1,
		MaxBytes:    1 << 20,
		StartOffset: kafka.LastOffset, // at-most-once: 只管在线时刻的实时性
	})
	defer r.Close()
	for {
		m, err := r.FetchMessage(ctx)
		if err != nil {
			if ctx.Err() != nil {
				return
			}
			logger.L.Warn("comet relation event fetch", zap.Error(err))
			time.Sleep(500 * time.Millisecond)
			continue
		}
		var ev yim.RelationEvent
		if err := proto.Unmarshal(m.Value, &ev); err != nil {
			continue // 毒丸跳过
		}
		if len(ev.GetTargets()) == 0 {
			continue // 原始 PRESENCE → relation 域, 不直达客户端
		}
		for _, uid := range ev.GetTargets() {
			for _, c := range keeper.Devices(uid) {
				_ = c.Send(&yim.Frame{
					Cmd:     yim.Command_CMD_EVENT,
					Payload: &yim.Frame_Event{Event: ev.GetEvent()},
				})
			}
		}
	}
}

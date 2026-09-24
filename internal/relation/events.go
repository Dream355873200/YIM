// events.go (里程碑10): 关系域事件的生产 + 在线事件补目标。
//
// topic yim.relation.event (与 comet 的消费侧同一契约, 见 internal/comet/events.go):
//   - 关系动作 (申请/同意/删除/群变更) 由本服务直发, targets = 应通知用户
//   - comet 发的原始 PRESENCE (targets 空) 由 EnrichPresence 消费 → 补齐好友
//     列表后发回同 topic (targets = 好友) —— relation 不直接订阅 comet,
//     靠 topic 自解耦, 避免 relation↔comet RPC 环
//
// 异步 producer + at-least-once 消费: 事件可丢可重, 丢失由客户端拉取制兜底
// (切 tab/进页重拉), 不影响正确性。Kafka 未配置时 producer 为 nil = 全 no-op。
package relation

import (
	"context"
	"time"

	"github.com/segmentio/kafka-go"
	"go.uber.org/zap"
	"google.golang.org/protobuf/proto"

	"github.com/yim/internal/logger"
	"github.com/yim/kitex_gen/yim"
)

const TopicRelationEvent = "yim.relation.event"

// 事件类型 (EventFrame.type)
const (
	EvFriendRequest = "FRIEND_REQUEST" // uid=申请人, targets=[被申请人]
	EvFriendHandled = "FRIEND_HANDLED" // uid=处理人, targets=[申请人] (accept 才发)
	EvFriendDeleted = "FRIEND_DELETED" // uid=删除人, targets=[被删人]
	EvGroupChanged  = "GROUP_CHANGED"  // uid=操作者, conv_id=群会话, targets=相关成员
	EvPresence      = "PRESENCE"       // uid=状态变更者, online=上下线
)

// EventProducer 关系域事件生产者。
type EventProducer struct {
	w *kafka.Writer
}

func NewEventProducer(brokers []string) *EventProducer {
	return &EventProducer{w: &kafka.Writer{
		Addr:                   kafka.TCP(brokers...),
		Topic:                  TopicRelationEvent,
		Async:                  true, // 不阻塞业务主链路
		AllowAutoTopicCreation: true,
		BatchTimeout:           5 * time.Millisecond,
		RequiredAcks:           kafka.RequireOne,
		ErrorLogger: kafka.LoggerFunc(func(msg string, args ...interface{}) {
			logger.L.Warn("kafka produce relation event (pull-based fallback covers)",
				zap.String("detail", msg))
		}),
	}}
}

// Emit 发事件 (producer 未装配 = no-op)。
func (p *EventProducer) Emit(evType string, uid, convID int64, targets ...int64) {
	p.EmitFrame(&yim.EventFrame{Type: evType, Uid: uid, ConvId: convID}, targets...)
}

// EmitFrame 发完整事件帧 —— PRESENCE 富化必须走这里: online 标志不能丢
// (proto 零值 false, 走 Emit 会被改成"离线", 上线事件永远推不出去)。
func (p *EventProducer) EmitFrame(ev *yim.EventFrame, targets ...int64) {
	if p == nil {
		return
	}
	b, err := proto.Marshal(&yim.RelationEvent{
		Event:   ev,
		Targets: targets,
	})
	if err != nil {
		return
	}
	_ = p.w.WriteMessages(context.Background(), kafka.Message{Value: b})
}

// Close 排空关闭 (优雅停机)。
func (p *EventProducer) Close() {
	if p == nil {
		return
	}
	_ = p.w.Close()
}

// EnrichPresence 消费原始 PRESENCE (targets 空) → 好友列表补目标 → 发回 topic。
// 独立消费组; 富化后的事件 targets 非空, 本循环再次遇到时跳过 (不闭环)。
func EnrichPresence(ctx context.Context, brokers []string, s *Service) {
	r := kafka.NewReader(kafka.ReaderConfig{
		Brokers:     brokers,
		GroupID:     "yim-relation-presence",
		Topic:       TopicRelationEvent,
		MinBytes:    1,
		MaxBytes:    1 << 20,
		StartOffset: kafka.LastOffset,
	})
	defer r.Close()
	for {
		m, err := r.FetchMessage(ctx)
		if err != nil {
			if ctx.Err() != nil {
				return
			}
			logger.L.Warn("relation presence fetch", zap.Error(err))
			time.Sleep(500 * time.Millisecond)
			continue
		}
		var ev yim.RelationEvent
		if err := proto.Unmarshal(m.Value, &ev); err != nil || len(ev.GetTargets()) > 0 {
			_ = r.CommitMessages(ctx, m) // 毒丸/富化事件: 提交跳过
			continue
		}
		if ev.GetEvent().GetType() == EvPresence {
			if friends := s.friendUIDs(ctx, ev.GetEvent().GetUid()); len(friends) > 0 {
				// 原样保留 online 标志 (富化前 comet 已置位; 丢弃会被零值改写成 false)
				s.pub.EmitFrame(ev.GetEvent(), friends...)
			}
		}
		if err := r.CommitMessages(ctx, m); err != nil {
			logger.L.Warn("relation presence commit", zap.Error(err))
		}
	}
}

// friendUIDs 直接查 friendships (本服务的数据域, 不走 RPC)。
func (s *Service) friendUIDs(ctx context.Context, uid int64) []int64 {
	rows, err := s.db.Meta.QueryContext(ctx,
		`SELECT friend_uid FROM friendships WHERE uid = ?`, uid)
	if err != nil {
		logger.L.Warn("enrich presence query friends", zap.Int64("uid", uid), zap.Error(err))
		return nil
	}
	defer rows.Close()
	var out []int64
	for rows.Next() {
		var f int64
		if err := rows.Scan(&f); err == nil {
			out = append(out, f)
		}
	}
	return out
}

// memberUIDsOf 群现存成员 (exclude 不含, 用于"存量 + 被移除者"的通知目标)。
func (s *Service) memberUIDsOf(ctx context.Context, convID, exclude int64) []int64 {
	rows, err := s.db.Meta.QueryContext(ctx,
		`SELECT uid FROM group_members WHERE conv_id = ? AND uid <> ?`, convID, exclude)
	if err != nil {
		return nil
	}
	defer rows.Close()
	var out []int64
	for rows.Next() {
		var u int64
		if err := rows.Scan(&u); err == nil {
			out = append(out, u)
		}
	}
	if exclude > 0 {
		out = append(out, exclude) // 被踢/退群者也要刷新自己的会话列表
	}
	return out
}

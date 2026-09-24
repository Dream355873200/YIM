// kafka.go: 投递层的 Kafka 形态 (里程碑 4 的"Kafka 接口位"落地)。
//
// 拓扑: Message Svc --yim.push--> Kafka --消费组--> Job Svc --> comet
//
//	--yim.ack--->        (ACK 回路, 取消重试定时)
//
// 设计要点:
//   - 异步 producer (Async writer): Kafka 写失败不阻塞发送主链路 —— 消息与
//     local_message 已同事务落库, 防线3 扫描补偿兜底 (与 channel 形态同一语义)
//   - 分区键 = conv_id: 同会话事件同分区, 会话内投递有序; ACK 同键同分区,
//     单实例消费时天然与投递事件共址
//   - 序列化 = protobuf 线格式 (DeliveryEvent/AckEvent, 见 service_job.proto;
//     kitex 生成的 prutal Marshal 与标准 protobuf 互通)
package message

import (
	"context"
	"encoding/binary"
	"fmt"
	"time"

	"github.com/segmentio/kafka-go"
	"go.uber.org/zap"
	"google.golang.org/protobuf/proto"

	"github.com/yim/internal/logger"
	"github.com/yim/kitex_gen/yim"
)

const (
	TopicPush = "yim.push"
	TopicAck  = "yim.ack"
)

// KafkaPusher 实现 Pusher + Acker: Message Svc 侧的 Kafka producer。
type KafkaPusher struct {
	pushW *kafka.Writer
	ackW  *kafka.Writer
}

// errLogger 异步写错误挂到 writer 的 ErrorLogger: local_message 是正确性
// 锚点, produce 失败只记日志 (防线3 扫描补偿)。
func errLogger(topic string) kafka.LoggerFunc {
	return kafka.LoggerFunc(func(msg string, args ...interface{}) {
		logger.L.Warn("kafka produce "+topic+" (scan-compensation will recover)",
			zap.String("detail", fmt.Sprintf(msg, args...)))
	})
}

func NewKafkaPusher(brokers []string) *KafkaPusher {
	mk := func(topic string) *kafka.Writer {
		return &kafka.Writer{
			Addr:                   kafka.TCP(brokers...),
			Topic:                  topic,
			Balancer:               &kafka.Hash{}, // key=conv_id → 同会话同分区
			Async:                  true,          // 不阻塞发送主链路
			AllowAutoTopicCreation: true,
			BatchTimeout:           5 * time.Millisecond, // 低延迟优先 (默认 10ms)
			RequiredAcks:           kafka.RequireOne,
			ErrorLogger:            errLogger(topic),
		}
	}
	return &KafkaPusher{pushW: mk(TopicPush), ackW: mk(TopicAck)}
}

func convKey(convID int64) []byte {
	var b [8]byte
	binary.BigEndian.PutUint64(b[:], uint64(convID))
	return b[:]
}

// Push 投递事件入 topic yim.push (key=conv_id)。
func (p *KafkaPusher) Push(_ context.Context, e PushEvent) {
	ev := &yim.DeliveryEvent{
		ConvId: e.ConvID, MaxSeq: e.MaxSeq, FromUid: e.FromUID, UserSyncSeq: e.UserSyncSeq,
		MsgId: e.MsgID,
	}
	b, err := proto.Marshal(ev)
	if err != nil {
		logger.L.Error("marshal delivery event (scan-compensation will recover)", zap.Error(err))
		return
	}
	_ = p.pushW.WriteMessages(context.Background(), // Async writer 不等结果
		kafka.Message{Key: convKey(e.ConvID), Value: b})
}

// AckPush 确认事件入 topic yim.ack (key=conv_id)。
func (p *KafkaPusher) AckPush(uid, convID, ackSeq int64) {
	b, err := proto.Marshal(&yim.AckEvent{Uid: uid, ConvId: convID, AckSeq: ackSeq})
	if err != nil {
		logger.L.Error("marshal ack event", zap.Error(err))
		return
	}
	_ = p.ackW.WriteMessages(context.Background(),
		kafka.Message{Key: convKey(convID), Value: b})
}

// Close 排空并关闭 writer (优雅停机)。
func (p *KafkaPusher) Close() {
	_ = p.pushW.Close()
	_ = p.ackW.Close()
}

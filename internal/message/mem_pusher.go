package message

import (
	"context"

	"github.com/yim/internal/logger"
	"go.uber.org/zap"
)

// MemPusher 单体期内存投递实现: 仅记录日志。
// 里程碑2 拆分后由 Job Svc (Kafka 消费) 替代, Pusher 接口不变。
type MemPusher struct{}

func NewMemPusher() *MemPusher { return &MemPusher{} }

func (p *MemPusher) Push(_ context.Context, e PushEvent) {
	logger.L.Info("push (mem)",
		zap.Int64("conv_id", e.ConvID),
		zap.Int64("max_seq", e.MaxSeq),
		zap.Int64("from_uid", e.FromUID),
		zap.Int64("user_sync_seq", e.UserSyncSeq),
	)
}

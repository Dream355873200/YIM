// CometHandler: Kitex gRPC handler —— 集群内部接口 (Job Svc 推送/踢人/排水)。
// 实现即协议操作: 组帧 → 写连接 → 断连, 无业务判断。
package main

import (
	"context"
	"time"

	"go.uber.org/zap"

	"github.com/yim/internal/comet"
	"github.com/yim/internal/logger"
	"github.com/yim/kitex_gen/yim"
)

// CometHandler implements yim.CometService.
type CometHandler struct {
	server *comet.Server
	keeper *comet.Keeper
}

// PushMessage 向本实例上的目标连接推轻通知。
// delivered=false 表示设备不在线 —— Job Svc 据此写离线箱 (三道防线之一)。
// 多端共享一次 EncodeFrame 的编码字节 (16 里程碑, goim 同款): 同一帧
// proto.Marshal 一次, N 连接 SendRaw 复用 —— 扇出 N 的编码成本 N→1。
func (h *CometHandler) PushMessage(ctx context.Context, req *yim.PushMessageReq) (*yim.PushMessageRsp, error) {
	f := &yim.Frame{Cmd: yim.Command_CMD_MESSAGE_PUSH,
		Payload: &yim.Frame_MessagePush{MessagePush: &yim.MessagePush{
			ConvId:      req.GetConvId(),
			MaxSeq:      req.GetMaxSeq(),
			FromUid:     req.GetFromUid(),
			UserSyncSeq: req.GetUserSyncSeq(),
		}}}

	var targets []*comet.Conn
	for _, c := range h.keeper.Devices(req.GetUid()) {
		if req.GetDeviceId() != "" && c.DeviceID() != req.GetDeviceId() {
			continue // 多端精确推送
		}
		targets = append(targets, c)
	}
	delivered := false
	if len(targets) > 0 {
		raw, err := comet.EncodeFrame(f)
		if err != nil {
			logger.L.Error("comet push encode", zap.Error(err),
				zap.Int64("uid", req.GetUid()), zap.Int64("conv_id", req.GetConvId()))
			return &yim.PushMessageRsp{Delivered: false}, nil
		}
		for _, c := range targets {
			if err := c.SendRaw(raw); err != nil {
				logger.L.Warn("comet push write failed", zap.Error(err), zap.String("conn", c.Tag()))
				continue
			}
			delivered = true
		}
	}
	logger.L.Info("comet push",
		zap.Int64("uid", req.GetUid()), zap.Int64("conv_id", req.GetConvId()),
		zap.Int("devices", len(targets)), zap.Bool("delivered", delivered))
	return &yim.PushMessageRsp{Delivered: delivered}, nil
}

// Kick 踢下线: 发 KICK 帧后断连 (被踢端禁止用同一 token 重连)。
func (h *CometHandler) Kick(ctx context.Context, req *yim.KickReq) (*yim.KickRsp, error) {
	f := &yim.Frame{Cmd: yim.Command_CMD_KICK,
		Payload: &yim.Frame_Kick{Kick: &yim.Kick{
			Reason:      req.GetReason(),
			UserSyncSeq: req.GetUserSyncSeq(),
		}}}
	for _, c := range h.keeper.Devices(req.GetUid()) {
		if req.GetDeviceId() != "" && c.DeviceID() != req.GetDeviceId() {
			continue
		}
		_ = c.Send(f)
		c.Close()
		logger.L.Info("comet kicked", zap.Int64("uid", req.GetUid()),
			zap.String("device", c.DeviceID()), zap.String("reason", req.GetReason()))
	}
	return &yim.KickRsp{}, nil
}

// Drain 排水 (优雅发布): 停收新连接 → 通知重连 → 超时强制断开。
func (h *CometHandler) Drain(ctx context.Context, req *yim.DrainReq) (*yim.DrainRsp, error) {
	timeout := time.Duration(req.GetTimeoutMs()) * time.Millisecond
	if timeout <= 0 {
		timeout = 10 * time.Second
	}
	remaining := h.server.Drain(timeout)
	logger.L.Info("comet drain", zap.Int("remaining", remaining), zap.Duration("timeout", timeout))
	return &yim.DrainRsp{RemainingConnections: int32(remaining)}, nil
}

// Stats 连接水位 (压测/监控)
func (h *CometHandler) Stats(ctx context.Context, req *yim.CometStatsReq) (*yim.CometStatsRsp, error) {
	return &yim.CometStatsRsp{
		OnlineConnections:     int64(h.keeper.Count()),
		HeartbeatTimeoutCount: h.server.HeartbeatTimeoutCount(),
	}, nil
}

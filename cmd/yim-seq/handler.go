// SeqHandler: Kitex handler —— proto 契约 ↔ 号段池。
package main

import (
	"context"

	"go.uber.org/zap"

	"github.com/yim/internal/logger"
	"github.com/yim/internal/seq"
	"github.com/yim/kitex_gen/yim"
)

type SeqHandler struct {
	pool *seq.Pool
}

// AllocId 通用实体 ID (uid/msg/conv_id, key 固定 0)
func (h *SeqHandler) AllocId(ctx context.Context, req *yim.AllocIdReq) (*yim.AllocIdRsp, error) {
	a, err := h.pool.For(ctx, req.Biz, req.KeyId)
	if err != nil {
		return nil, err
	}
	start, err := a.Next(int(req.Count))
	if err != nil {
		return nil, err
	}
	return &yim.AllocIdRsp{Start: start}, nil
}

func (h *SeqHandler) AllocConvSeq(ctx context.Context, req *yim.AllocConvSeqReq) (*yim.AllocConvSeqRsp, error) {
	a, err := h.pool.For(ctx, "conv", req.ConvId)
	if err != nil {
		return nil, err
	}
	start, err := a.Next(int(req.Count))
	if err != nil {
		return nil, err
	}
	logger.C(ctx).Info("conv seq allocated", zap.Int64("conv_id", req.ConvId), zap.Int64("start", start))
	return &yim.AllocConvSeqRsp{Start: start, Count: req.Count}, nil
}

func (h *SeqHandler) BumpSyncSeq(ctx context.Context, req *yim.BumpSyncSeqReq) (*yim.BumpSyncSeqRsp, error) {
	a, err := h.pool.For(ctx, "sync", req.Uid)
	if err != nil {
		return nil, err
	}
	v, err := a.Next(1)
	if err != nil {
		return nil, err
	}
	return &yim.BumpSyncSeqRsp{SyncSeq: v}, nil
}

// GetSyncSeq 只读水位: CONNECT_OK 下发用, 客户端以此判断增量起点
func (h *SeqHandler) GetSyncSeq(ctx context.Context, req *yim.GetSyncSeqReq) (*yim.GetSyncSeqRsp, error) {
	v, err := h.pool.Current(ctx, "sync", req.Uid)
	if err != nil {
		return nil, err
	}
	return &yim.GetSyncSeqRsp{SyncSeq: v}, nil
}

// InitConv 建会话时预热 (确保号段行存在, seq 从 1 开始)
func (h *SeqHandler) InitConv(ctx context.Context, req *yim.InitConvReq) (*yim.InitConvRsp, error) {
	if _, err := h.pool.For(ctx, "conv", req.ConvId); err != nil {
		return nil, err
	}
	return &yim.InitConvRsp{}, nil
}

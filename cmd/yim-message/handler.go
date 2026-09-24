// MessageHandler: Kitex gRPC handler 适配层 —— proto 契约 ↔ 内部 Service。
// 业务实现始终在 internal/message, 这里只做参数搬运, 拆分不引入逻辑分叉。
package main

import (
	"context"
	"errors"
	"strings"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/message"
	"github.com/yim/kitex_gen/yim"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
)

// MessageHandler implements yim.MessageService.
type MessageHandler struct {
	svc    *message.Service
	acker  message.Acker     // ACK 回路直达投递层 (取消重试定时)
	seqCli seqservice.Client // Sync 响应带当前 user_sync_seq (Redis miss 时回退)
	cache  *cache.Cache      // 水位主存储 (里程碑8); nil = 纯 seq RPC 降级形态
}

func (h *MessageHandler) SendMessage(ctx context.Context, req *yim.SendMessageReq) (*yim.SendMessageRsp, error) {
	msgID, seq, err := h.svc.SendMessage(ctx, int64(req.ClientMsgId), req.ConvId, req.FromUid, req.Content)
	if err != nil {
		return nil, err
	}
	return &yim.SendMessageRsp{MsgId: msgID, Seq: seq}, nil
}

func (h *MessageHandler) PullHistory(ctx context.Context, req *yim.PullHistoryReq) (*yim.PullHistoryRsp, error) {
	if req.Mode != yim.PullMode_PULL_PAGE_BACKWARD {
		return nil, errors.New("pull mode not supported yet") // 里程碑4: SEQ_RANGE (增量同步)
	}
	msgs, err := h.svc.PullHistory(ctx, req.GetOpUid(), req.ConvId, req.BeforeSeq, int(req.Limit))
	if err != nil {
		if errors.Is(err, message.ErrNotMember) {
			// 业务错误走 rsp.Error (网关映射 403), 不走 gRPC error
			return &yim.PullHistoryRsp{Error: &yim.Error{
				Code: 25, Msg: "not a member of this conversation"}}, nil
		}
		return nil, err
	}
	rsp := &yim.PullHistoryRsp{Messages: msgs}
	if len(msgs) > 0 {
		rsp.MinSeq = msgs[0].Seq
		rsp.HasMore = len(msgs) == int(req.Limit) && rsp.MinSeq > 1
	}
	return rsp, nil
}

// Sync 增量同步: 按各会话水位差集拉增量 (推拉协议的"拉"侧)。
func (h *MessageHandler) Sync(ctx context.Context, req *yim.SyncReq2) (*yim.SyncRsp2, error) {
	msgs, overflow, err := h.svc.Sync(ctx, req.GetUid(), req.GetWatermarks())
	if err != nil {
		return nil, err
	}
	// 响应带当前用户级水位: 客户端以它判断是否还有别的会话漏了。
	// Redis 主存储 (≤回写滞后的最新值); miss/故障回退 seq RPC
	var syncSeq int64
	if v, ok := h.cache.SyncSeqGet(ctx, req.GetUid()); ok {
		syncSeq = v
	} else if rsp, err := h.seqCli.GetSyncSeq(ctx, &yim.GetSyncSeqReq{Uid: req.GetUid()}); err == nil {
		syncSeq = rsp.GetSyncSeq()
	}
	return &yim.SyncRsp2{UserSyncSeq: syncSeq, Messages: msgs, Overflow: overflow}, nil
}

// AckPush 客户端推送确认: 取消投递层重试定时 (时间轮)
func (h *MessageHandler) AckPush(ctx context.Context, req *yim.AckPushReq) (*yim.AckPushRsp, error) {
	h.acker.AckPush(req.GetUid(), req.GetConvId(), req.GetAckSeq())
	return &yim.AckPushRsp{}, nil
}

// CreateConv 建会话 (单聊去重/群聊发号), 里程碑5 临时归属 Message Svc
// 里程碑9: 单聊好友校验 (ErrNotFriends → code 22) + 群成员 seed (owner_uid)
func (h *MessageHandler) CreateConv(ctx context.Context, req *yim.CreateConvReq) (*yim.CreateConvRsp, error) {
	conv, exist, err := h.svc.CreateConv(ctx, req.GetType(), req.GetMemberUids(), req.GetOwnerUid(), req.GetName())
	if err != nil {
		if errors.Is(err, message.ErrNotFriends) {
			return &yim.CreateConvRsp{Error: &yim.Error{
				Code: 22, Msg: "not friends (single chat requires friendship)"}}, nil
		}
		return nil, err
	}
	return &yim.CreateConvRsp{Conv: conv, AlreadyExist: exist}, nil
}

// MarkRead 已读回执: 推进 user_conv_state.read_seq, 不产生消息
func (h *MessageHandler) MarkRead(ctx context.Context, req *yim.MarkReadReq) (*yim.MarkReadRsp, error) {
	if err := h.svc.MarkRead(ctx, req.GetUid(), req.GetConvId(), req.GetReadSeq()); err != nil {
		return nil, err
	}
	return &yim.MarkReadRsp{}, nil
}

// GetReadState 会话各成员已读水位 (客户端进窗拉取兜底 READ 实时事件)
func (h *MessageHandler) GetReadState(ctx context.Context, req *yim.GetReadStateReq) (*yim.GetReadStateRsp, error) {
	states, bizErr := h.svc.GetReadState(ctx, req.GetOpUid(), req.GetConvId())
	if bizErr != nil {
		return &yim.GetReadStateRsp{Error: bizErr}, nil
	}
	return &yim.GetReadStateRsp{States: states}, nil
}

// ListConversations 会话列表: 元数据 + 未读数 + 最近一条预览 (缓存体系)
func (h *MessageHandler) ListConversations(ctx context.Context, req *yim.ListConversationsReq) (*yim.ListConversationsRsp, error) {
	var pageNum, pageSize int32
	if p := req.GetPage(); p != nil {
		pageNum, pageSize = p.PageNum, p.PageSize
	}
	convs, hasMore, err := h.svc.ListConversations(ctx, req.GetUid(), pageNum, pageSize)
	if err != nil {
		return nil, err
	}
	return &yim.ListConversationsRsp{Conversations: convs, HasMore: hasMore}, nil
}

// 以下接口随里程碑6+ 补齐。
func (h *MessageHandler) RevokeMessage(ctx context.Context, req *yim.RevokeMessageReq) (*yim.RevokeMessageRsp, error) {
	msgID, seq, err := h.svc.RevokeMessage(ctx, req.GetMsgId(), req.GetConvId(), req.GetOpUid())
	if err != nil {
		if errors.Is(err, message.ErrRevokeDenied) {
			return &yim.RevokeMessageRsp{Error: &yim.Error{Code: 30, Msg: "只能撤回自己的消息"}}, nil
		}
		if strings.Contains(err.Error(), "revoke window") {
			return &yim.RevokeMessageRsp{Error: &yim.Error{Code: 31, Msg: "超过 2 分钟, 无法撤回"}}, nil
		}
		return nil, err
	}
	return &yim.RevokeMessageRsp{RevokeMsgId: msgID, Seq: seq}, nil
}

func (h *MessageHandler) SearchMessages(ctx context.Context, req *yim.SearchMessagesReq) (*yim.SearchMessagesRsp, error) {
	msgs, truncated, err := h.svc.SearchMessages(ctx, req.GetUid(), req.GetKeyword(), req.GetLimit())
	if err != nil {
		return nil, err
	}
	return &yim.SearchMessagesRsp{Messages: msgs, Truncated: truncated}, nil
}

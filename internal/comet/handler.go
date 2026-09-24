// 帧分发: 协议语义 → RPC 下沉。本文件是 Comet 唯一"懂一点业务"的地方,
// 也只做"取参数 → 调 RPC → 组响应", 判定逻辑在下游服务。
package comet

import (
	"context"
	"time"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/logger"
	"github.com/yim/kitex_gen/yim"
	messageservice "github.com/yim/kitex_gen/yim/messageservice"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
	"go.uber.org/zap"
)

// Handler 帧处理器依赖注入 (main 装配, 测试可注入 fake)。
// cache 可为 nil: 水位读回退 seq RPC, 路由登记缺席回退广播 (降级不阻断)。
type Handler struct {
	auth    Authenticator
	msg     messageservice.Client
	seq     seqservice.Client
	keeper  *Keeper
	cache   *cache.Cache // 里程碑8: 水位读 + 路由表登记
	rpcAddr string       // 本实例 etcd 注册地址 (路由表成员值)
	pub     *EventPublisher // 里程碑10: 在线事件 (nil = 未装配, 退回纯拉取)
}

func NewHandler(auth Authenticator, msg messageservice.Client, seq seqservice.Client, keeper *Keeper, c *cache.Cache, rpcAddr string) *Handler {
	return &Handler{auth: auth, msg: msg, seq: seq, keeper: keeper, cache: c, rpcAddr: rpcAddr}
}

// SetEventPublisher 装配在线事件生产者 (main)。
func (h *Handler) SetEventPublisher(p *EventPublisher) { h.pub = p }

// HandleFrame 分发入口。pump goroutine 串行调用 (单连接内天然有序)。
func (h *Handler) HandleFrame(c *Conn, f *yim.Frame) {
	switch f.Cmd {
	case yim.Command_CMD_CONNECT:
		h.onConnect(c, f)
	case yim.Command_CMD_HEARTBEAT:
		if c.IsAuthed() {
			h.cache.RouteTouch(context.Background(), c.UID()) // 路由 TTL 续期 (miss 时 no-op)
		}
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_HEARTBEAT,
			Payload: &yim.Frame_Heartbeat{Heartbeat: &yim.Heartbeat{LastFrameId: f.GetHeartbeat().GetLastFrameId()}}})
	case yim.Command_CMD_MESSAGE_UP:
		h.onMessageUp(c, f)
	case yim.Command_CMD_ACK:
		h.onAck(c, f)
	case yim.Command_CMD_TYPING:
		h.onTyping(c, f)
	case yim.Command_CMD_SYNC:
		h.onSync(c, f)
	case yim.Command_CMD_KICK, yim.Command_CMD_DISCONNECT, yim.Command_CMD_MESSAGE_PUSH, yim.Command_CMD_SYNC_RSP:
		// 服务端专属指令出现在上行 = 协议违规, 断连
		logger.L.Warn("comet protocol violation", zap.String("conn", c.Tag()), zap.String("cmd", f.Cmd.String()))
		c.Close()
	default:
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: f.Cmd,
			Error: &yim.Error{Code: ErrCodeBadRequest, Msg: "unknown command"}})
	}
}

// onConnect 握手: 鉴权 → 顶替同设备旧连接 → 登记 → 下发同步水位。
func (h *Handler) onConnect(c *Conn, f *yim.Frame) {
	if c.IsAuthed() {
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_CONNECT_RSP,
			Error: &yim.Error{Code: ErrCodeBadRequest, Msg: "already connected"}})
		return
	}
	req := f.GetConnect()
	if req.GetDevice().GetDeviceId() == "" {
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_CONNECT_RSP,
			Error: &yim.Error{Code: ErrCodeBadRequest, Msg: "device_id required"}})
		return
	}
	uid, err := h.auth.Auth(context.Background(), req.GetToken())
	if err != nil {
		// 鉴权失败: 回错误帧后断连 (客户端不得用同一 token 重试)
		logger.L.Warn("auth failed", zap.String("conn", c.Tag()), zap.Error(err))
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_CONNECT_RSP,
			Error: &yim.Error{Code: ErrCodeInvalidToken, Msg: "auth failed"}})
		c.Close()
		return
	}

	// 同设备重连: 顶替旧连接 (旧连接大概率已死但心跳还没判死, 或客户端闪断重连)
	if old, ok := h.keeper.Get(uid, req.GetDevice().GetDeviceId()); ok {
		_ = old.Send(&yim.Frame{Cmd: yim.Command_CMD_KICK,
			Payload: &yim.Frame_Kick{Kick: &yim.Kick{Reason: "device_replaced"}}})
		old.Close()
	}

	c.setIdentity(uid, req.GetDevice())
	h.keeper.Add(c)
	h.cache.RouteAdd(context.Background(), uid, h.rpcAddr) // 路由登记 (幂等 SADD, nil cache 静默跳过)
	h.pub.PublishPresence(uid, true)                       // 上线事件 (推侧, nil 静默)

	// 下发用户级同步水位: 客户端对比本地, 落后即 SYNC (推拉结合协议的起点)。
	// Redis 是水位主存储 (里程碑8, INCR + 异步回写 DB); miss/故障回退 seq RPC
	// —— 回退值可能略低 (≤200ms 回写滞后), 只影响"快速判漏", 客户端兜底全量拉取
	var syncSeq int64
	if v, ok := h.cache.SyncSeqGet(context.Background(), uid); ok {
		syncSeq = v
	} else if rsp, err := h.seq.GetSyncSeq(context.Background(), &yim.GetSyncSeqReq{Uid: uid}); err == nil {
		syncSeq = rsp.GetSyncSeq()
	} else {
		logger.L.Warn("get sync seq failed", zap.String("conn", c.Tag()), zap.Error(err))
	}

	logger.L.Info("comet connected", zap.String("conn", c.Tag()),
		zap.String("device_type", req.GetDevice().GetType().String()), zap.Int64("user_sync_seq", syncSeq))
	_ = c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_CONNECT_RSP,
		Payload: &yim.Frame_ConnectRsp{ConnectRsp: &yim.ConnectRsp{
			ServerTimeMs: time.Now().UnixMilli(),
			UserSyncSeq:  syncSeq,
		}}})
}

// onMessageUp 上行消息: 身份以连接为准 (不信 payload), 转发 Message Svc。
func (h *Handler) onMessageUp(c *Conn, f *yim.Frame) {
	if !c.IsAuthed() {
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_MESSAGE_UP_RSP,
			Error: &yim.Error{Code: ErrCodeBadRequest, Msg: "not connected"}})
		return
	}
	req := f.GetMessageUp()
	if req.GetClientMsgId() == 0 || req.GetConvId() == 0 || req.GetContent() == nil {
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_MESSAGE_UP_RSP,
			Error: &yim.Error{Code: ErrCodeBadRequest, Msg: "client_msg_id, conv_id, content required"}})
		return
	}
	rsp, err := h.msg.SendMessage(context.Background(), &yim.SendMessageReq{
		ClientMsgId: req.GetClientMsgId(),
		ConvId:      req.GetConvId(),
		FromUid:     c.UID(),
		Content:     req.GetContent(),
	})
	if err != nil {
		// RPC 失败 (含超时重试耗尽): 客户端按 frame_id 超时重发, 幂等保证不重复落库
		logger.L.Error("comet message up rpc", zap.Error(err), zap.String("conn", c.Tag()),
			zap.Int64("conv_id", req.GetConvId()), zap.Uint64("client_msg_id", req.GetClientMsgId()))
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_MESSAGE_UP_RSP,
			Error: &yim.Error{Code: ErrCodeInternal, Msg: "send failed"}})
		return
	}
	_ = c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_MESSAGE_UP_RSP,
		Payload: &yim.Frame_MessageUpRsp{MessageUpRsp: &yim.MessageUpRsp{
			ClientMsgId:  req.GetClientMsgId(),
			MsgId:        rsp.GetMsgId(),
			Seq:          rsp.GetSeq(),
			ServerTimeMs: time.Now().UnixMilli(),
		}}})
}

// onSync 增量同步: 转发 Message Svc, 响应体直接作为 SYNC_RSP 的 payload。
// 同步响应可能大 (多条消息), 由 MaxBodySize 上限保护, 超限走 overflow 分页。
func (h *Handler) onSync(c *Conn, f *yim.Frame) {
	if !c.IsAuthed() {
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_SYNC_RSP,
			Error: &yim.Error{Code: ErrCodeBadRequest, Msg: "not connected"}})
		return
	}
	req := f.GetSync()
	rsp, err := h.msg.Sync(context.Background(), &yim.SyncReq2{
		Uid:         c.UID(),
		UserSyncSeq: req.GetUserSyncSeq(),
		Watermarks:  req.GetWatermarks(),
	})
	if err != nil {
		logger.L.Error("comet sync rpc", zap.Error(err), zap.String("conn", c.Tag()))
		c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_SYNC_RSP,
			Error: &yim.Error{Code: ErrCodeInternal, Msg: "sync failed"}})
		return
	}
	_ = c.Send(&yim.Frame{FrameId: f.FrameId, Cmd: yim.Command_CMD_SYNC_RSP,
		Payload: &yim.Frame_SyncRsp{SyncRsp: &yim.SyncRsp{
			UserSyncSeq: rsp.GetUserSyncSeq(),
			Messages:    rsp.GetMessages(),
			Overflow:    rsp.GetOverflow(),
		}}})
}

// onAck 推送确认: 取消投递层重试定时。异步转发, 不阻塞本连接读循环。
func (h *Handler) onAck(c *Conn, f *yim.Frame) {
	if !c.IsAuthed() {
		return
	}
	ack := f.GetAck()
	if ack.GetTarget() != yim.AckTarget_ACK_FOR_PUSH || ack.GetConvId() == 0 {
		return
	}
	uid := c.UID()
	convID, ackSeq := ack.GetConvId(), ack.GetAckSeq()
	go func() {
		if _, err := h.msg.AckPush(context.Background(), &yim.AckPushReq{
			Uid: uid, ConvId: convID, AckSeq: ackSeq,
		}); err != nil {
			// ACK 丢失的代价 = 服务端多重推一次, 客户端按 seq 去重, 无正确性影响
			logger.L.Warn("comet ack rpc", zap.Error(err), zap.String("conn", c.Tag()))
		}
	}()
}

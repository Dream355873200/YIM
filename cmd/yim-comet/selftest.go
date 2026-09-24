// comet selftest: 投递闭环端到端验证 (里程碑4)。
//
// 场景 (真实 TCP + 真实 RPC + 真实 MySQL):
//  1. 握手: uid1 连接 comet, 下发 user_sync_seq
//  2. 在线推送: uid2 上行消息 → uid1 收 MESSAGE_PUSH (投递层广播 comet)
//  3. SYNC: uid1 带水位拉增量 → 收到消息体 (推拉协议"拉"侧)
//  4. ACK 取消重试: uid1 回 ACK, 不再收到重推
//  5. 防线1: uid1 不 ACK → 1s/4s/16s 三次重推 → 防线2 离线箱落库
//  6. 离线投递: 目标完全不在线 → 直接写离线箱
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"time"

	"github.com/cloudwego/kitex/client"
	etcd "github.com/kitex-contrib/registry-etcd"
	"go.uber.org/zap"

	"github.com/yim/internal/comet"
	"github.com/yim/internal/config"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/store"
	"github.com/yim/kitex_gen/yim"
	logicservice "github.com/yim/kitex_gen/yim/logicservice"
	messageservice "github.com/yim/kitex_gen/yim/messageservice"
	relationservice "github.com/yim/kitex_gen/yim/relationservice"
)

func runCometSelftest(cfg *config.Config) {
	ctx := context.Background()
	db, err := store.OpenMySQL(ctx, cfg.MySQLDSN)
	if err != nil {
		logger.L.Fatal("open mysql", zap.Error(err))
	}
	defer db.Close()

	resolver, err := etcd.NewEtcdResolver(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd resolver", zap.Error(err))
	}

	// ---- 种子: 注册 4 个用户 (走 Logic Svc 真注册, JWT 验签同链路) + 两个会话 ----
	logicCli, err := logicservice.NewClient("yim.logic", client.WithResolver(resolver))
	if err != nil {
		logger.L.Fatal("kitex client yim.logic", zap.Error(err))
	}
	suffix := fmt.Sprintf("st%d", time.Now().UnixNano()%1000000)
	register := func(n int) (int64, string) {
		nick := fmt.Sprintf("%s-u%d", suffix, n)
		rr, err := logicCli.Register(ctx, &yim.RegisterReq{Nickname: nick, Password: "pass123456"})
		if err != nil || rr.GetError() != nil {
			logger.L.Fatal("register", zap.String("nick", nick),
				zap.Error(err), zap.String("biz_err", rr.GetError().GetMsg()))
		}
		lr, err := logicCli.Login(ctx, &yim.LoginReq{Nickname: nick, Password: "pass123456"})
		if err != nil || lr.GetError() != nil {
			logger.L.Fatal("login", zap.Error(err))
		}
		return lr.GetUid(), lr.GetToken()
	}
	uid1, tok1 := register(1)
	uid2, tok2 := register(2)
	uid3, _ := register(3)
	uid4, tok4 := register(4)
	// ---- 会话: 走 Message Svc CreateConv (不再直插 SQL), 单聊重复建验证去重 ----
	msgCli, err := messageservice.NewClient("yim.message", client.WithResolver(resolver))
	if err != nil {
		logger.L.Fatal("kitex client yim.message", zap.Error(err))
	}
	// 好友种子 (里程碑9): 单聊好友校验 fail-close, selftest 用户对先走真实
	// Relation 链路结为好友 (申请→同意)
	relCli, err := relationservice.NewClient("yim.relation", client.WithResolver(resolver))
	if err != nil {
		logger.L.Fatal("kitex client yim.relation", zap.Error(err))
	}
	seedFriend := func(a, b int64) {
		if rsp, err := relCli.SendFriendRequest(ctx, &yim.SendFriendRequestReq{FromUid: a, ToUid: b}); err != nil || rsp.GetError() != nil {
			logger.L.Fatal("seed friend request", zap.Int64("a", a), zap.Int64("b", b),
				zap.Error(err), zap.String("biz_err", rsp.GetError().GetMsg()))
		}
		if rsp, err := relCli.HandleFriendRequest(ctx, &yim.HandleFriendRequestReq{
			OpUid: b, FromUid: a, Accept: true}); err != nil || rsp.GetError() != nil {
			logger.L.Fatal("seed friend accept", zap.Int64("a", a), zap.Int64("b", b),
				zap.Error(err), zap.String("biz_err", rsp.GetError().GetMsg()))
		}
	}
	newConv := func(a, b int64) int64 {
		seedFriend(a, b)
		rsp, err := msgCli.CreateConv(ctx, &yim.CreateConvReq{
			Type: yim.ConvType_CONV_SINGLE, MemberUids: []int64{a, b}})
		if err != nil {
			logger.L.Fatal("create conv", zap.Error(err))
		}
		return rsp.GetConv().GetConvId()
	}
	conv12, conv34 := newConv(uid1, uid2), newConv(uid3, uid4)
	// 单聊去重: 同对成员再建一次, 必须返回同一 conv_id 且 already_exist=true
	if dup, err := msgCli.CreateConv(ctx, &yim.CreateConvReq{
		Type: yim.ConvType_CONV_SINGLE, MemberUids: []int64{uid2, uid1}}); err != nil ||
		dup.GetConv().GetConvId() != conv12 || !dup.GetAlreadyExist() {
		logger.L.Fatal("single conv dedup failed",
			zap.Int64("got", dup.GetConv().GetConvId()), zap.Bool("exist", dup.GetAlreadyExist()), zap.Error(err))
	}
	logger.L.Info("selftest: create conv + dedup OK", zap.Int64("conv12", conv12))

	// ---- uid1 连接 comet (接收方, 真 JWT); uid2 也有连接 (发送方) ----
	cli1 := dialSelftest(cfg, tok1, "receiver-pc")
	defer cli1.c.Close()
	cli2 := dialSelftest(cfg, tok2, "sender-pc")
	defer cli2.c.Close()

	// 1. 握手成功
	rsp := cli1.recv()
	if rsp.Cmd != yim.Command_CMD_CONNECT_RSP || rsp.GetError() != nil {
		logger.L.Fatal("uid1 connect rejected", zap.String("err", rsp.GetError().GetMsg()))
	}
	if rsp2 := cli2.recv(); rsp2.GetError() != nil {
		logger.L.Fatal("uid2 connect rejected")
	}

	// 2. 在线推送: uid2 上行 → uid1 收 MESSAGE_PUSH
	sendUp(cli2, 10, conv12, 1001)
	push := cli1.recv()
	if push.Cmd != yim.Command_CMD_MESSAGE_PUSH || push.GetMessagePush().GetConvId() != conv12 {
		logger.L.Fatal("expect MESSAGE_PUSH", zap.String("got", push.Cmd.String()))
	}
	logger.L.Info("selftest: online push OK", zap.Int64("max_seq", push.GetMessagePush().GetMaxSeq()))

	// 3. SYNC: uid1 带水位 {conv12, 0} → 拉到消息体
	cli1.send(&yim.Frame{FrameId: 20, Cmd: yim.Command_CMD_SYNC,
		Payload: &yim.Frame_Sync{Sync: &yim.SyncReq{UserSyncSeq: 0,
			Watermarks: []*yim.ConvWatermark{{ConvId: conv12, LastSeq: 0}}}}})
	syncRsp := cli1.recv()
	if syncRsp.Cmd != yim.Command_CMD_SYNC_RSP || len(syncRsp.GetSyncRsp().GetMessages()) != 1 {
		logger.L.Fatal("expect SYNC_RSP with 1 message", zap.Int("got", len(syncRsp.GetSyncRsp().GetMessages())))
	}
	syncMsg := syncRsp.GetSyncRsp().GetMessages()[0]
	logger.L.Info("selftest: sync OK",
		zap.Int64("seq", syncMsg.GetSeq()), zap.String("text", syncMsg.GetContent().GetText()),
		zap.Int64("user_sync_seq", syncRsp.GetSyncRsp().GetUserSyncSeq()))

	// 4. ACK: uid1 确认 seq=1 → 投递层取消重试, 等待期内不落离线箱
	cli1.send(&yim.Frame{FrameId: 21, Cmd: yim.Command_CMD_ACK,
		Payload: &yim.Frame_Ack{Ack: &yim.Ack{ConvId: conv12, AckSeq: 1,
			Target: yim.AckTarget_ACK_FOR_PUSH}}})
	time.Sleep(500 * time.Millisecond)
	assertOfflineCount(db, uid1, conv12, 1, 0, "after ack (no retry needed)")

	// 5. 防线1: uid2 再发一条, uid1 不 ACK → 3 次重推 (1s/4s/16s, 全程 21s) → 离线箱
	sendUp(cli2, 11, conv12, 1002)
	push2 := cli1.recv()
	if push2.GetMessagePush().GetMaxSeq() != 2 {
		logger.L.Fatal("expect push max_seq=2")
	}
	for i := 0; i < 3; i++ { // 三次重推全部到达
		r := cli1.recv()
		if r.Cmd != yim.Command_CMD_MESSAGE_PUSH {
			logger.L.Fatal("expect retry push", zap.Int("i", i), zap.String("got", r.Cmd.String()))
		}
	}
	time.Sleep(600 * time.Millisecond) // 最后一级落离线箱
	assertOfflineCount(db, uid1, conv12, 2, 1, "after ack timeout (defense line 2)")

	// 6. 离线投递: uid4 发消息, uid3 从未连接 → 直接离线箱
	cli4 := dialSelftest(cfg, tok4, "uid4-pc")
	defer cli4.c.Close()
	if r := cli4.recv(); r.GetError() != nil {
		logger.L.Fatal("uid4 connect rejected")
	}
	sendUp(cli4, 10, conv34, 2001)
	assertOfflineCount(db, uid3, conv34, 1, 1, "offline target (defense line 2 direct)")

	// 7. 幂等前置筛 (里程碑5): 同 client_msg_id 重放 → 同 msg_id/seq
	//    第二次走 布隆命中 → Redis 精查 快速路径, 不再落库
	rsp1, err := msgCli.SendMessage(ctx, &yim.SendMessageReq{ClientMsgId: 8888, ConvId: conv12,
		FromUid: uid2, Content: &yim.ConvMsgContent{Type: yim.MsgType_MSG_TEXT, Text: "idem"}})
	if err != nil {
		logger.L.Fatal("send idem#1", zap.Error(err))
	}
	rsp2, err := msgCli.SendMessage(ctx, &yim.SendMessageReq{ClientMsgId: 8888, ConvId: conv12,
		FromUid: uid2, Content: &yim.ConvMsgContent{Type: yim.MsgType_MSG_TEXT, Text: "idem"}})
	if err != nil || rsp1.GetMsgId() != rsp2.GetMsgId() || rsp1.GetSeq() != rsp2.GetSeq() {
		logger.L.Fatal("idempotent replay mismatch",
			zap.Int64("id1", rsp1.GetMsgId()), zap.Int64("seq1", rsp1.GetSeq()),
			zap.Int64("id2", rsp2.GetMsgId()), zap.Int64("seq2", rsp2.GetSeq()), zap.Error(err))
	}
	logger.L.Info("selftest: idempotent replay OK (bloom+SETNX fast path)",
		zap.Int64("msg_id", rsp1.GetMsgId()), zap.Int64("seq", rsp1.GetSeq()))

	// 8. 已读回执: uid1 读到最新 (含场景7的 seq=3) → 未读归零
	if _, err := msgCli.MarkRead(ctx, &yim.MarkReadReq{Uid: uid1, ConvId: conv12, ReadSeq: rsp1.GetSeq()}); err != nil {
		logger.L.Fatal("mark read", zap.Error(err))
	}
	// 9. 会话列表: uid1 未读=0 且有预览; uid2 未读=发送条数 (从未读过)
	list1, err := msgCli.ListConversations(ctx, &yim.ListConversationsReq{
		Uid: uid1, Page: &yim.PageInfo{PageNum: 1, PageSize: 20}})
	if err != nil {
		logger.L.Fatal("list convs uid1", zap.Error(err))
	}
	var brief1 *yim.ConversationBrief
	for _, b := range list1.GetConversations() {
		if b.GetConv().GetConvId() == conv12 {
			brief1 = b
		}
	}
	if brief1 == nil || brief1.GetUnreadCount() != 0 || brief1.GetLastMessage() == nil {
		logger.L.Fatal("uid1 conv brief wrong",
			zap.Bool("found", brief1 != nil),
			zap.Int64("unread", brief1.GetUnreadCount()),
			zap.Bool("has_last", brief1.GetLastMessage() != nil))
	}
	list2, err := msgCli.ListConversations(ctx, &yim.ListConversationsReq{
		Uid: uid2, Page: &yim.PageInfo{PageNum: 1, PageSize: 20}})
	if err != nil {
		logger.L.Fatal("list convs uid2", zap.Error(err))
	}
	var unread2 int64
	for _, b := range list2.GetConversations() {
		if b.GetConv().GetConvId() == conv12 {
			unread2 = b.GetUnreadCount()
		}
	}
	if unread2 <= 0 {
		logger.L.Fatal("uid2 unread should be > 0", zap.Int64("unread", unread2))
	}
	logger.L.Info("selftest: markread + conv list OK",
		zap.Int64("uid1_unread", brief1.GetUnreadCount()), zap.Int64("uid2_unread", unread2))

	logger.L.Info("COMET SELFTEST ALL PASS",
		zap.Int64("conv12", conv12), zap.Int64("conv34", conv34),
		zap.Int64("uid1", uid1), zap.Int64("uid3", uid3))
}

// ---- 自检工具函数 ----

type selfClient struct {
	c  net.Conn
	s  *comet.TCPStream
	id uint32
}

func dialSelftest(cfg *config.Config, token, device string) *selfClient {
	c, err := net.DialTimeout("tcp", cfg.CometTCP, 3*time.Second)
	if err != nil {
		logger.L.Fatal("dial comet", zap.Error(err))
	}
	sc := &selfClient{c: c, s: comet.NewTCPStream(c)}
	sc.send(&yim.Frame{FrameId: 1, Cmd: yim.Command_CMD_CONNECT,
		Payload: &yim.Frame_Connect{Connect: &yim.ConnectReq{
			Token:  token,
			Device: &yim.DeviceInfo{Type: yim.DeviceType_DEVICE_DESKTOP, DeviceId: device},
		}}})
	return sc
}

func (sc *selfClient) send(f *yim.Frame) {
	sc.id++
	f.FrameId = sc.id
	if err := sc.s.WriteFrame(f); err != nil {
		logger.L.Fatal("write frame", zap.Error(err))
	}
}

func (sc *selfClient) recv() *yim.Frame {
	// 每次读独立 30s 死线 (兜底卡死): 重推全程 21s, 单次拨号设绝对死线会
	// 被前置步骤吃掉预算 (曾致 step5 误报 i/o timeout)
	_ = sc.c.SetReadDeadline(time.Now().Add(30 * time.Second))
	f, err := sc.s.ReadFrame()
	if err != nil {
		logger.L.Fatal("read frame", zap.Error(err))
	}
	return f
}

func sendUp(sc *selfClient, frameID uint32, convID, clientMsgID int64) {
	sc.send(&yim.Frame{FrameId: frameID, Cmd: yim.Command_CMD_MESSAGE_UP,
		Payload: &yim.Frame_MessageUp{MessageUp: &yim.MessageUpReq{
			ClientMsgId: uint64(clientMsgID), ConvId: convID,
			Content: &yim.ConvMsgContent{Type: yim.MsgType_MSG_TEXT, Text: "selftest msg"},
		}}})
	if rsp := sc.recv(); rsp.GetError() != nil {
		logger.L.Fatal("message up rejected", zap.String("err", rsp.GetError().GetMsg()))
	}
}

func assertOfflineCount(db *store.MySQL, uid, convID, seq int64, want int, when string) {
	// deliver 在消费 goroutine 异步执行, UP_RSP 返回 ≠ 投递完成 → 轮询
	deadline := time.Now().Add(5 * time.Second)
	for {
		var n int
		if err := db.Meta.QueryRowContext(context.Background(),
			"SELECT COUNT(*) FROM offline_box WHERE uid=? AND conv_id=? AND seq=?", uid, convID, seq).Scan(&n); err != nil {
			logger.L.Fatal("offline box query", zap.Error(err))
		}
		if n == want {
			logger.L.Info("selftest: offline box OK", zap.String("when", when), zap.Int("count", n))
			return
		}
		if time.Now().After(deadline) {
			raw, _ := json.Marshal(map[string]any{"uid": uid, "conv": convID, "seq": seq, "got": n, "want": want})
			logger.L.Fatal("offline box assertion", zap.String("when", when), zap.ByteString("detail", raw))
		}
		time.Sleep(100 * time.Millisecond)
	}
}

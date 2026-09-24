package comet

import (
	"context"
	"net"
	"os"
	"testing"
	"time"

	"github.com/cloudwego/kitex/client/callopt"

	"github.com/yim/internal/logger"
	"github.com/yim/kitex_gen/yim"
	messageservice "github.com/yim/kitex_gen/yim/messageservice"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
)

func TestMain(m *testing.M) {
	if err := logger.Init(true); err != nil {
		panic(err)
	}
	os.Exit(m.Run())
}

// ---------- fake 下游 (避免测试依赖 etcd/DB) ----------

type fakeMsgClient struct {
	messageservice.Client
	msgID, seq int64
}

func (f *fakeMsgClient) SendMessage(ctx context.Context, req *yim.SendMessageReq, _ ...callopt.Option) (*yim.SendMessageRsp, error) {
	f.msgID++
	f.seq++
	return &yim.SendMessageRsp{MsgId: f.msgID, Seq: f.seq}, nil
}

type fakeSeqClient struct {
	seqservice.Client
	syncSeq int64
}

func (f *fakeSeqClient) GetSyncSeq(ctx context.Context, req *yim.GetSyncSeqReq, _ ...callopt.Option) (*yim.GetSyncSeqRsp, error) {
	return &yim.GetSyncSeqRsp{SyncSeq: f.syncSeq}, nil
}

// ---------- 测试客户端 ----------

type testClient struct {
	c net.Conn
	s stream
}

func dialTestClient(t *testing.T, addr string) *testClient {
	c, err := net.Dial("tcp", addr)
	if err != nil {
		t.Fatal(err)
	}
	return &testClient{c: c, s: newNetStream(c)}
}

func (tc *testClient) send(t *testing.T, f *yim.Frame) {
	b, err := EncodeFrame(f)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := tc.c.Write(b); err != nil {
		t.Fatal(err)
	}
}

func (tc *testClient) recv(t *testing.T) *yim.Frame {
	f, err := readFrame(tc.s)
	if err != nil {
		t.Fatal(err)
	}
	return f
}

func (tc *testClient) close() { _ = tc.c.Close() }

// ---------- 端到端: 真实 TCP 上走 握手→心跳→上行→服务端推送 ----------

func TestServerEndToEnd(t *testing.T) {
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer ln.Close()

	keeper := NewKeeper()
	handler := NewHandler(DevAuthenticator{}, &fakeMsgClient{}, &fakeSeqClient{syncSeq: 7}, keeper, nil, "")
	srv := NewServer(keeper, handler)
	go func() { _ = srv.Serve(ln) }()
	time.Sleep(100 * time.Millisecond) // 等 accept 就绪

	cli := dialTestClient(t, ln.Addr().String())
	defer cli.close()

	// 1. 握手: token 鉴权 + 水位下发
	cli.send(t, &yim.Frame{FrameId: 1, Cmd: yim.Command_CMD_CONNECT,
		Payload: &yim.Frame_Connect{Connect: &yim.ConnectReq{
			Token:  "dev.42",
			Device: &yim.DeviceInfo{Type: yim.DeviceType_DEVICE_DESKTOP, DeviceId: "pc-1"},
		}}})
	rsp := cli.recv(t)
	if rsp.Cmd != yim.Command_CMD_CONNECT_RSP || rsp.Error != nil {
		t.Fatalf("connect rsp bad: %+v err=%v", rsp, rsp.Error)
	}
	if rsp.GetConnectRsp().GetUserSyncSeq() != 7 {
		t.Fatalf("user_sync_seq = %d, want 7", rsp.GetConnectRsp().GetUserSyncSeq())
	}

	// 2. 心跳回显
	cli.send(t, &yim.Frame{FrameId: 2, Cmd: yim.Command_CMD_HEARTBEAT,
		Payload: &yim.Frame_Heartbeat{Heartbeat: &yim.Heartbeat{LastFrameId: 1}}})
	rsp = cli.recv(t)
	if rsp.Cmd != yim.Command_CMD_HEARTBEAT {
		t.Fatalf("heartbeat rsp cmd = %v", rsp.Cmd)
	}

	// 3. 上行消息 → Message Svc → 回执带 msg_id/seq
	cli.send(t, &yim.Frame{FrameId: 3, Cmd: yim.Command_CMD_MESSAGE_UP,
		Payload: &yim.Frame_MessageUp{MessageUp: &yim.MessageUpReq{
			ClientMsgId: 1000, ConvId: 555,
			Content: &yim.ConvMsgContent{Type: yim.MsgType_MSG_TEXT, Text: "hi"},
		}}})
	rsp = cli.recv(t)
	if rsp.Cmd != yim.Command_CMD_MESSAGE_UP_RSP || rsp.Error != nil {
		t.Fatalf("up rsp bad: %+v err=%v", rsp, rsp.Error)
	}
	up := rsp.GetMessageUpRsp()
	if up.GetClientMsgId() != 1000 || up.GetMsgId() == 0 || up.GetSeq() == 0 {
		t.Fatalf("up payload bad: %+v", up)
	}

	// 4. 未认证连接发上行 → 拒绝
	cli2 := dialTestClient(t, ln.Addr().String())
	defer cli2.close()
	cli2.send(t, &yim.Frame{FrameId: 1, Cmd: yim.Command_CMD_MESSAGE_UP,
		Payload: &yim.Frame_MessageUp{MessageUp: &yim.MessageUpReq{ClientMsgId: 1, ConvId: 1,
			Content: &yim.ConvMsgContent{}}}})
	rsp = cli2.recv(t)
	if rsp.GetError().GetCode() != ErrCodeBadRequest {
		t.Fatalf("unauth up err code = %v", rsp.GetError())
	}

	// 5. 非法 token → 错误帧后断连
	cli3 := dialTestClient(t, ln.Addr().String())
	defer cli3.close()
	cli3.send(t, &yim.Frame{FrameId: 1, Cmd: yim.Command_CMD_CONNECT,
		Payload: &yim.Frame_Connect{Connect: &yim.ConnectReq{
			Token:  "bad.token",
			Device: &yim.DeviceInfo{DeviceId: "pc-9"},
		}}})
	rsp = cli3.recv(t)
	if rsp.GetError().GetCode() != ErrCodeInvalidToken {
		t.Fatalf("bad token err code = %v", rsp.GetError())
	}

	// 6. 同设备重连顶替: 新 TCP 连接 auth 后, keeper 槽位被顶替, 旧连接收 KICK
	cli4 := dialTestClient(t, ln.Addr().String())
	defer cli4.close()
	cli4.send(t, &yim.Frame{FrameId: 9, Cmd: yim.Command_CMD_CONNECT,
		Payload: &yim.Frame_Connect{Connect: &yim.ConnectReq{
			Token:  "dev.42",
			Device: &yim.DeviceInfo{Type: yim.DeviceType_DEVICE_DESKTOP, DeviceId: "pc-1"},
		}}})
	rsp = cli4.recv(t)
	if rsp.Cmd != yim.Command_CMD_CONNECT_RSP || rsp.Error != nil {
		t.Fatalf("reconnect rsp bad: %+v", rsp)
	}
	if got := len(keeper.Devices(42)); got != 1 {
		t.Fatalf("keeper devices = %d, want 1 (replaced)", got)
	}
	// 旧连接收到 KICK (device_replaced)
	kick := cli.recv(t)
	if kick.Cmd != yim.Command_CMD_KICK {
		t.Fatalf("old conn kick cmd = %v", kick.Cmd)
	}

	// 7. 服务端推送 (模拟 Job Svc 调 PushMessage 的底层路径) → 打到顶替后的新连接
	if err := keeper.Devices(42)[0].Send(&yim.Frame{Cmd: yim.Command_CMD_MESSAGE_PUSH,
		Payload: &yim.Frame_MessagePush{MessagePush: &yim.MessagePush{ConvId: 555, MaxSeq: 3}}}); err != nil {
		t.Fatal(err)
	}
	rsp = cli4.recv(t)
	if rsp.Cmd != yim.Command_CMD_MESSAGE_PUSH || rsp.GetMessagePush().GetConvId() != 555 {
		t.Fatalf("push frame bad: %+v", rsp)
	}
}

package comet

import (
	"bytes"
	"encoding/binary"
	"errors"
	"io"
	"net"
	"testing"
	"time"

	"github.com/yim/kitex_gen/yim"
)

// bytesConn 测试用 net.Conn: 从内存读、写入 buffer (满足 newNetStream 签名)
type bytesConn struct {
	r    io.Reader
	w    *bytes.Buffer
	dead chan struct{}
}

func newFrameStream(b []byte) stream {
	return newNetStream(&bytesConn{r: bytes.NewReader(b), dead: make(chan struct{})})
}

func newFrameStreamBytes(r io.Reader) stream {
	return newNetStream(&bytesConn{r: r, dead: make(chan struct{})})
}

func (c *bytesConn) Read(p []byte) (int, error)         { return c.r.Read(p) }
func (c *bytesConn) Write(p []byte) (int, error)        { return c.w.Write(p) }
func (c *bytesConn) Close() error                       { close(c.dead); return nil }
func (c *bytesConn) LocalAddr() net.Addr                { return dummyAddr{} }
func (c *bytesConn) RemoteAddr() net.Addr               { return dummyAddr{} }
func (c *bytesConn) SetDeadline(t time.Time) error      { return nil }
func (c *bytesConn) SetReadDeadline(t time.Time) error  { return nil }
func (c *bytesConn) SetWriteDeadline(t time.Time) error { return nil }

type dummyAddr struct{}

func (dummyAddr) Network() string { return "test" }
func (dummyAddr) String() string  { return "test" }

func testFrame(payload *yim.Frame_MessagePush) *yim.Frame {
	return &yim.Frame{
		FrameId: 42,
		Cmd:     yim.Command_CMD_MESSAGE_PUSH,
		Payload: payload,
	}
}

// Roundtrip: 编码 → 一次性读完 → 解码, 字段无损
func TestEncodeDecodeRoundtrip(t *testing.T) {
	f := testFrame(&yim.Frame_MessagePush{MessagePush: &yim.MessagePush{
		ConvId: 12345, MaxSeq: 6789, FromUid: 7, UserSyncSeq: 8,
	}})
	b, err := EncodeFrame(f)
	if err != nil {
		t.Fatal(err)
	}
	got, err := readFrame(newFrameStream(b))
	if err != nil {
		t.Fatal(err)
	}
	if got.FrameId != 42 || got.Cmd != yim.Command_CMD_MESSAGE_PUSH {
		t.Fatalf("header fields mismatch: %+v", got)
	}
	if got.GetMessagePush().GetConvId() != 12345 || got.GetMessagePush().GetMaxSeq() != 6789 {
		t.Fatalf("payload mismatch: %+v", got.GetMessagePush())
	}
}

// 半包: 帧字节分多次喂进来, 必须等到完整才解码
func TestReadFramePartialFeed(t *testing.T) {
	f := testFrame(&yim.Frame_MessagePush{MessagePush: &yim.MessagePush{ConvId: 1, MaxSeq: 2}})
	b, _ := EncodeFrame(f)

	// slowReader 每次只给 1 字节, 模拟最恶劣的 TCP 分段
	got, err := readFrame(newFrameStreamBytes(&slowReader{r: bytes.NewReader(b)}))
	if err != nil {
		t.Fatal(err)
	}
	if got.GetMessagePush().GetConvId() != 1 {
		t.Fatalf("payload mismatch: %+v", got.GetMessagePush())
	}
}

// 粘包: 两帧连续到达, 逐帧消费互不干扰
func TestReadFrameCoalesce(t *testing.T) {
	b1, _ := EncodeFrame(testFrame(&yim.Frame_MessagePush{MessagePush: &yim.MessagePush{ConvId: 1}}))
	b2, _ := EncodeFrame(testFrame(&yim.Frame_MessagePush{MessagePush: &yim.MessagePush{ConvId: 2}}))
	s := newFrameStreamBytes(bytes.NewReader(append(b1, b2...)))

	g1, err := readFrame(s)
	if err != nil {
		t.Fatal(err)
	}
	g2, err := readFrame(s)
	if err != nil {
		t.Fatal(err)
	}
	if g1.GetMessagePush().GetConvId() != 1 || g2.GetMessagePush().GetConvId() != 2 {
		t.Fatalf("coalesced frames mismatch: %d, %d",
			g1.GetMessagePush().GetConvId(), g2.GetMessagePush().GetConvId())
	}
}

// 恶意长度: body_len 超上限必须拒绝, 而不是尝试分配 4GB
func TestReadFrameBodyTooLarge(t *testing.T) {
	hdr := make([]byte, HeaderSize)
	binary.BigEndian.PutUint32(hdr[0:4], uint32(MaxBodySize)+1)
	hdr[4] = VersionV1
	if _, err := readFrame(newFrameStreamBytes(bytes.NewReader(hdr))); !errors.Is(err, ErrBodyTooLarge) {
		t.Fatalf("want ErrBodyTooLarge, got %v", err)
	}
}

// 版本不识别: 拒绝
func TestReadFrameBadVersion(t *testing.T) {
	hdr := make([]byte, HeaderSize)
	binary.BigEndian.PutUint32(hdr[0:4], 4)
	hdr[4] = 99
	if _, err := readFrame(newFrameStreamBytes(bytes.NewReader(hdr))); !errors.Is(err, ErrBadVersion) {
		t.Fatalf("want ErrBadVersion, got %v", err)
	}
}

// Unknown cmd 拒绝 (0 值帧 = 解析异常)
func TestEncodeFrameUnknownCmd(t *testing.T) {
	if _, err := EncodeFrame(&yim.Frame{FrameId: 1}); err == nil {
		t.Fatal("want error for CMD_UNKNOWN")
	}
}

// slowReader io.Reader 包装: 每次 Read 只吐 1 字节
type slowReader struct{ r io.Reader }

func (s *slowReader) Read(p []byte) (int, error) {
	if len(p) == 0 {
		return 0, nil
	}
	return s.r.Read(p[:1])
}

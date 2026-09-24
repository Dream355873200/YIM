package comet

import (
	"net"

	"github.com/yim/kitex_gen/yim"
)

// TCPStream 客户端侧帧流封装 (自检工具/联调客户端/压测脚本用)。
// 服务端内部走未导出的 stream 接口; 这里导出最小 API 供 dial 方使用。
type TCPStream struct {
	s stream
}

func NewTCPStream(c net.Conn) *TCPStream { return &TCPStream{s: newNetStream(c)} }

func (t *TCPStream) WriteFrame(f *yim.Frame) error {
	b, err := EncodeFrame(f)
	if err != nil {
		return err
	}
	return t.s.Write(b)
}

func (t *TCPStream) ReadFrame() (*yim.Frame, error) { return readFrame(t.s) }

func (t *TCPStream) Close() error { return t.s.Close() }

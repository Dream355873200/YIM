//go:build windows

// 标准库回退适配 (Windows 开发机): goroutine-per-conn + 自管读缓冲。
//
// 为什么需要: netpoll 只支持 Linux/macOS, v0.7.5 在 Windows 上
// NewEventLoop 返回 (nil, nil) 不报错 (实测), 服务无法起。
// 参照 Hertz 自身的 network lib 抽象: 同一套 stream 接口下,
// Linux 走 Netpoll 零拷贝, Windows 走标准库, 业务层零感知。
package comet

import (
	"errors"
	"io"
	"net"
)

var errNetpollUnavailable = errors.New("comet: netpoll unavailable on this platform")

// netStream 标准库适配: 自管读缓冲实现阻塞 Peek 语义。
// bufio.Reader 无法"读窥探后回填", 所以自己维护未消费字节缓冲。
type netStream struct {
	conn net.Conn
	buf  []byte // 未消费数据
}

func newNetStream(c net.Conn) stream { return &netStream{conn: c} }

func (s *netStream) Peek(n int) ([]byte, error) {
	if len(s.buf) >= n {
		return s.buf[:n], nil
	}
	need := n - len(s.buf)
	tmp := make([]byte, need+4096) // 多读一些, 减少小帧场景的系统调用
	m, err := io.ReadAtLeast(s.conn, tmp, need)
	s.buf = append(s.buf, tmp[:m]...)
	if err != nil && len(s.buf) < n {
		return nil, err
	}
	return s.buf[:n], nil
}

func (s *netStream) Skip(n int) error {
	if n > len(s.buf) {
		return io.ErrShortBuffer
	}
	s.buf = s.buf[n:]
	return nil
}

func (s *netStream) Write(b []byte) error { _, err := s.conn.Write(b); return err }
func (s *netStream) Close() error         { return s.conn.Close() }

// acceptLoop 平台接入循环: 标准库 Accept + goroutine-per-conn。
// TCP_NODELAY: push/ACK 都是小帧, Nagle 等对端 ACK + 对端延迟 ACK 互相扣
// (实测 2000/s 压测 e2e p50 1.7s 的元凶), IM 长连接必须关 (goim 同款)。
func acceptLoop(ln net.Listener, onStream func(stream)) error {
	for {
		c, err := ln.Accept()
		if err != nil {
			return err
		}
		if tc, ok := c.(*net.TCPConn); ok {
			_ = tc.SetNoDelay(true)
		}
		go onStream(newNetStream(c))
	}
}

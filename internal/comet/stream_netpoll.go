//go:build !windows

// Netpoll 适配 (Linux/macOS): 零拷贝读写, 生产形态。
package comet

import (
	"context"
	"errors"
	"net"

	"github.com/cloudwego/netpoll"
)

var errNetpollUnavailable = errors.New("comet: netpoll unavailable on this platform")

// netpollStream 适配 netpoll.Connection → stream 接口。
type netpollStream struct{ c netpoll.Connection }

func newNetpollStream(c netpoll.Connection) stream { return &netpollStream{c: c} }

func (s *netpollStream) Peek(n int) ([]byte, error) { return s.c.Reader().Peek(n) }
func (s *netpollStream) Skip(n int) error           { return s.c.Reader().Skip(n) }
func (s *netpollStream) Write(b []byte) error {
	if _, err := s.c.Writer().WriteBinary(b); err != nil {
		return err
	}
	return s.c.Writer().Flush()
}
func (s *netpollStream) Close() error { return s.c.Close() }

// acceptLoop 平台接入循环。
//
// netpoll 模式: OnPrepare 在连接建立时刻 (poller goroutine) 触发, 这里只做
// 非阻塞动作 —— 起 pump goroutine 阻塞读帧。netpoll 的阻塞读是 park+epoll 唤醒,
// 不占 poller 线程; 代价是每连接一个 goroutine 栈 (~4KB, 10 万连接数百 MB),
// 压测里程碑再评估是否改 OnRequest 事件驱动批读。
// 不注册 OnRequest: 读完全由 pump goroutine 接管, 避免 poller 回调竞争。
func acceptLoop(ln net.Listener, onStream func(stream)) error {
	loop, err := netpoll.NewEventLoop(
		func(ctx context.Context, c netpoll.Connection) error { return nil },
		netpoll.WithOnPrepare(func(c netpoll.Connection) context.Context {
			c.SetNoDelay(true) // push/ACK 小帧不走 Nagle (Windows 侧同款, 见 stream_windows.go)
			onStream(newNetpollStream(c))
			return context.Background()
		}),
	)
	if err != nil {
		return err
	}
	if loop == nil {
		return errNetpollUnavailable
	}
	return loop.Serve(ln)
}

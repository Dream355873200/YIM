package comet

import (
	"context"
	"net"
	"sync"
	"sync/atomic"
	"time"

	"github.com/yim/internal/logger"
	"github.com/yim/kitex_gen/yim"
	"go.uber.org/zap"
)

// 心跳参数 (protocol.proto 契约): 间隔 30s, 3 次超时判死。
// 服务端是"被动判死"—— 不主动发心跳, 只看最近活跃; 客户端是主动方。
const (
	HeartbeatInterval = 30 * time.Second
	IdleTimeout       = 3 * HeartbeatInterval
	SweepInterval     = 10 * time.Second
)

// FrameHandler 帧分发接口 (handler.go 实现), server 与业务解耦。
type FrameHandler interface {
	HandleFrame(c *Conn, f *yim.Frame)
}

// Server Comet 接入层主体: accept → pump 读帧 → 分发。
type Server struct {
	keeper  *Keeper
	handler FrameHandler

	draining atomic.Bool // 置位后拒绝新连接 (发布排水)
	wg       sync.WaitGroup

	heartbeatTimeouts atomic.Int64 // 统计: 心跳判死次数 (CometStats 用)

	// onOffline uid 在本实例的最后一条连接断开时的回调 (路由表注销), nil = 无操作。
	// 路由表 (里程碑8) 属优化组件, 回调缺席只影响定点推送命中率, 不影响正确性。
	onOffline func(uid int64)
}

func NewServer(keeper *Keeper, handler FrameHandler) *Server {
	return &Server{keeper: keeper, handler: handler}
}

// SetOfflineHook 装配路由注销回调 (main 装配)。
func (s *Server) SetOfflineHook(fn func(uid int64)) { s.onOffline = fn }

func (s *Server) Draining() bool { return s.draining.Load() }

// Serve 阻塞运行接入循环 (acceptLoop 为平台适配, 见 stream_*.go)。
func (s *Server) Serve(ln net.Listener) error {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go s.sweepLoop(ctx)
	return acceptLoop(ln, s.onStream)
}

// onStream 新连接入口 (accept / OnPrepare 时刻, 必须非阻塞)。
func (s *Server) onStream(sc stream) {
	if s.draining.Load() {
		_ = sc.Close() // 排水: 直接拒绝, 客户端按"连接失败"重连其他实例
		return
	}
	c := newConn(sc, s.onConnClosed)
	logger.L.Info("comet conn open", zap.Uint64("conn_id", c.id))
	s.wg.Add(1)
	go s.pump(c)
}

// pump 单连接读循环: 半包/粘包由 readFrame 的阻塞 Peek 语义消化。
func (s *Server) pump(c *Conn) {
	defer s.wg.Done()
	defer c.Close()
	for {
		f, err := readFrame(c.sc)
		if err != nil {
			// 正常关闭/对端断开都从这里退出; 主动 Close 后 readFrame 返回错误属预期
			if !c.closed.Load() {
				logger.L.Info("comet conn read end", zap.Uint64("conn_id", c.id), zap.Error(err))
			}
			return
		}
		c.Touch()
		// 同步分发: MESSAGE_UP 的 RPC 耗时会阻塞本连接后续读,
		// 但单连接本就是串行会话语义 (上行无需乱序并发), 可接受;
		// 推送走独立 RPC goroutine, 不经过这里。
		s.handler.HandleFrame(c, f)
	}
}

// onConnClosed 关闭钩子: 从 keeper 摘除 (未认证连接 uid=0, Remove 内部跳过);
// uid 在本实例 offline 时回调路由注销。
func (s *Server) onConnClosed(c *Conn) {
	last := s.keeper.Remove(c)
	if last && s.onOffline != nil {
		s.onOffline(c.uid)
	}
	logger.L.Info("comet conn closed", zap.Uint64("conn_id", c.id),
		zap.Int64("uid", c.uid), zap.String("device", c.deviceID))
}

// sweepLoop 心跳扫描: 每 10s 扫一遍, 空闲超 90s 判死。
// 假活连接 (对端崩溃/网络静默断) 只有这样才能发现 —— TCP 层 FIN/RST 都收不到。
func (s *Server) sweepLoop(ctx context.Context) {
	t := time.NewTicker(SweepInterval)
	defer t.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-t.C:
			for _, c := range s.keeper.Sweep(IdleTimeout.Milliseconds()) {
				if c.Close() {
					s.heartbeatTimeouts.Add(1)
					logger.L.Info("comet heartbeat timeout",
						zap.String("conn", c.Tag()), zap.Int64("idle_ms", c.IdleMs()))
				}
			}
		}
	}
}

// Drain 排水: 停收新连接, 通知存量客户端重连, timeout 后强制断开。
func (s *Server) Drain(timeout time.Duration) int {
	s.draining.Store(true)
	conns := s.keeper.All()
	go func() {
		d := &yim.Disconnect{Reason: "server_maintenance", RetryAfterMs: 3000}
		for _, c := range conns {
			_ = c.Send(&yim.Frame{Cmd: yim.Command_CMD_DISCONNECT, Payload: &yim.Frame_Disconnect{Disconnect: d}})
		}
		time.Sleep(timeout)
		for _, c := range conns {
			c.Close()
		}
	}()
	return len(conns)
}

// HeartbeatTimeoutCount 供 Stats
func (s *Server) HeartbeatTimeoutCount() int64 { return s.heartbeatTimeouts.Load() }

package comet

import (
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"github.com/yim/kitex_gen/yim"
)

// Conn 单连接状态: 身份 + 写互斥 + 心跳水位。
//
// 写路径加锁而非写队列: 当前推送频率下锁竞争可忽略 (写 syscall 才是瓶颈);
// goim 用 ring buffer 写队列 + 兜底 flush goroutine, 连接数/推送量上去后再演进。
type Conn struct {
	id         uint64 // 实例内自增, 日志定位用
	uid        int64  // 0 = 未认证 (CONNECT 前只允许 CONNECT 帧)
	deviceID   string
	deviceType yim.DeviceType

	sc      stream
	writeMu sync.Mutex
	closed  atomic.Bool
	lastAct atomic.Int64 // 最近活跃 unix ms (收发都算)

	onClosed func(*Conn) // 服务端挂的清理回调 (从 keeper 摘除)
}

var connSeq atomic.Uint64

func newConn(sc stream, onClosed func(*Conn)) *Conn {
	c := &Conn{
		id:       connSeq.Add(1),
		sc:       sc,
		onClosed: onClosed,
	}
	c.Touch()
	return c
}

// 认证完成后由 handler 填身份
func (c *Conn) setIdentity(uid int64, d *yim.DeviceInfo) {
	c.uid = uid
	c.deviceType = d.GetType()
	c.deviceID = d.GetDeviceId()
}

func (c *Conn) UID() int64                 { return c.uid }
func (c *Conn) DeviceID() string           { return c.deviceID }
func (c *Conn) DeviceType() yim.DeviceType { return c.deviceType }
func (c *Conn) IsAuthed() bool             { return c.uid != 0 }
func (c *Conn) Tag() string {
	return fmt.Sprintf("conn#%d uid=%d device=%s", c.id, c.uid, c.deviceID)
}

func (c *Conn) Touch()        { c.lastAct.Store(time.Now().UnixMilli()) }
func (c *Conn) IdleMs() int64 { return time.Now().UnixMilli() - c.lastAct.Load() }

// Send 线上写一帧 (RPC handler goroutine 与 pump goroutine 并发调用, 内部互斥)。
func (c *Conn) Send(f *yim.Frame) error {
	if c.closed.Load() {
		return fmt.Errorf("comet: %s send on closed conn", c.Tag())
	}
	b, err := EncodeFrame(f)
	if err != nil {
		return err
	}
	c.writeMu.Lock()
	err = c.sc.Write(b)
	c.writeMu.Unlock()
	if err != nil {
		return fmt.Errorf("comet: %s write: %w", c.Tag(), err)
	}
	c.Touch()
	return nil
}

// SendRaw 写一段已编码的帧字节 (多设备共享同一编码结果: EncodeFrame 一次,
// N 连接共享字节 —— goim 同款, 省掉每连接一次 proto.Marshal; sc.Write
// 直接进内核缓冲, 不持有切片引用)。
func (c *Conn) SendRaw(b []byte) error {
	if c.closed.Load() {
		return fmt.Errorf("comet: %s send on closed conn", c.Tag())
	}
	c.writeMu.Lock()
	err := c.sc.Write(b)
	c.writeMu.Unlock()
	if err != nil {
		return fmt.Errorf("comet: %s write: %w", c.Tag(), err)
	}
	c.Touch()
	return nil
}

// Close 幂等。回调先于底层关闭执行 (摘除索引后断连, 避免推送打到已关连接)。
func (c *Conn) Close() bool {
	if !c.closed.CompareAndSwap(false, true) {
		return false
	}
	if c.onClosed != nil {
		c.onClosed(c)
	}
	_ = c.sc.Close()
	return true
}

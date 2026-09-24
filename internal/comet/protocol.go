// Package comet: 连接网关 (对标 goim 的 comet 层)。
//
// 职责边界: 只做连接管理 + 协议编解码 + 心跳保活, 零业务逻辑。
// 业务 (鉴权语义/消息落库/同步计算) 全部下沉 RPC (message/seq/logic svc)。
//
// 帧格式 (protocol.proto):
//
//	| body_len: 4B BE | version: 1B | flag: 1B | cmd: 2B BE | body: protobuf |
//
// cmd 冗余进帧头: 分发时不用解 body 即可路由 (解 protobuf 才能拿 Frame.Cmd)。
// 传输层做了平台抽象 (stream 接口): Linux 走 Netpoll 零拷贝,
// Windows 开发机走标准库回退 —— netpoll v0.7.5 在 Windows 上 NewEventLoop
// 返回 (nil, nil) 不报错 (实测), 参照 Hertz 的 network lib 抽象处理。
package comet

import (
	"encoding/binary"
	"errors"
	"fmt"

	"google.golang.org/protobuf/proto"

	"github.com/yim/kitex_gen/yim"
)

const (
	VersionV1  byte = 1
	HeaderSize      = 8
	// MaxBodySize 单帧上限。消息体上限远小于此 (HTTP 网关层还会再限),
	// 超限帧直接断连: 长度前缀协议不对长度做上限 = 恶意帧可触发任意大分配。
	MaxBodySize = 64 << 10 // 64KB

	FlagCompress byte = 1 << 0 // 预留: 未实现, 收到即拒绝
	FlagEncrypt  byte = 1 << 1 // 预留: 未实现, 收到即拒绝
)

// 业务错误码 (proto Error.code)。传输层错误走断连, 业务错误走 Error 帧。
const (
	ErrCodeInvalidToken = 1
	ErrCodeBadRequest   = 2
	ErrCodeInternal     = 3
	ErrCodeNotImpl      = 4
)

var (
	ErrShortHeader  = errors.New("comet: short frame header")
	ErrBadVersion   = fmt.Errorf("comet: unsupported version, want %d", VersionV1)
	ErrBadFlag      = errors.New("comet: unsupported flag (compress/encrypt not implemented)")
	ErrBodyTooLarge = fmt.Errorf("comet: body exceeds %d bytes", MaxBodySize)
)

// EncodeFrame 帧 → 线上字节 (header + body), 调用方拥有返回值。
func EncodeFrame(f *yim.Frame) ([]byte, error) {
	if f.Cmd == yim.Command_CMD_UNKNOWN {
		return nil, fmt.Errorf("comet: frame cmd unknown")
	}
	body, err := proto.Marshal(f)
	if err != nil {
		return nil, fmt.Errorf("comet: marshal frame: %w", err)
	}
	if len(body) > MaxBodySize {
		return nil, ErrBodyTooLarge
	}
	buf := make([]byte, HeaderSize+len(body))
	binary.BigEndian.PutUint32(buf[0:4], uint32(len(body)))
	buf[4] = VersionV1
	buf[5] = 0 // flag
	binary.BigEndian.PutUint16(buf[6:8], uint16(f.Cmd))
	copy(buf[HeaderSize:], body)
	return buf, nil
}

// stream 单连接读写抽象 (平台适配层, 见 stream_*.go)。
// Peek 阻塞语义与 netpoll.Reader 一致: 不足 n 字节时等待, 而非返回短读。
type stream interface {
	Peek(n int) ([]byte, error) // 只读窥探, 返回值在下一次读之前有效
	Skip(n int) error           // 消费 n 字节
	Write(b []byte) error       // 完整写出 (调用方保证互斥)
	Close() error
}

// readFrame 从流上读一整帧。Peek 阻塞语义天然处理粘包/半包:
// 半包 = Peek 等待剩余字节; 粘包 = Skip 只消费本帧, 剩余留给下一轮。
func readFrame(s stream) (*yim.Frame, error) {
	hdr, err := s.Peek(HeaderSize)
	if err != nil {
		return nil, fmt.Errorf("peek header: %w", err)
	}
	bodyLen := binary.BigEndian.Uint32(hdr[0:4])
	if hdr[4] != VersionV1 {
		return nil, ErrBadVersion
	}
	if hdr[5] != 0 {
		return nil, ErrBadFlag
	}
	if bodyLen > MaxBodySize {
		return nil, ErrBodyTooLarge
	}
	full, err := s.Peek(HeaderSize + int(bodyLen))
	if err != nil {
		return nil, fmt.Errorf("peek body (%d bytes): %w", bodyLen, err)
	}
	if err := s.Skip(HeaderSize + int(bodyLen)); err != nil {
		return nil, fmt.Errorf("skip frame: %w", err)
	}
	f := &yim.Frame{}
	if bodyLen > 0 {
		if err := proto.Unmarshal(full[HeaderSize:], f); err != nil {
			return nil, fmt.Errorf("unmarshal frame: %w", err)
		}
	}
	// cmd 以 body 为准 (header 的 cmd 只是预路由提示)
	if f.Cmd == yim.Command_CMD_UNKNOWN {
		return nil, fmt.Errorf("comet: frame cmd unknown")
	}
	return f, nil
}

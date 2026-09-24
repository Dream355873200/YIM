// Package kitexcfg: Kitex 治理配置收口 —— 超时/重试/熔断, client 侧治理。
//
// 重试安全性论证 (面试高频):
//   - SendMessage 幂等 (client_msg_id 唯一键, 重放返回同一 msg_id/seq) → 可重试
//   - 发号类 RPC 非幂等, 但号段设计天然容忍空洞 (耗尽的号作废不回退) → 重试只浪费一个号
//   - WithRetryBreaker: 错误率超阈值熔断重试本身, 防止雪崩时重试放大流量
package kitexcfg

import (
	"net"
	"time"

	"github.com/cloudwego/kitex/client"
	"github.com/cloudwego/kitex/pkg/circuitbreak"
	"github.com/cloudwego/kitex/pkg/discovery"
	"github.com/cloudwego/kitex/pkg/registry"
	"github.com/cloudwego/kitex/pkg/retry"
	"github.com/cloudwego/kitex/pkg/rpcinfo"
	"github.com/cloudwego/kitex/server"
	"github.com/kitex-contrib/obs-opentelemetry/tracing"
)

// ClientOptions 标准客户端配置: 服务发现 + 超时 + 重试 + 熔断 + trace。
func ClientOptions(res discovery.Resolver, dest string) []client.Option {
	fp := retry.NewFailurePolicy()
	fp.WithMaxRetryTimes(2)
	fp.WithRandomBackOff(50, 200) // 抖开同时失败的重试
	fp.WithRetryBreaker(0.1)      // 错误率超 10% 熔断重试本身
	return []client.Option{
		client.WithResolver(res),
		client.WithDestService(dest),
		client.WithConnectTimeout(200 * time.Millisecond),
		client.WithRPCTimeout(time.Second), // seq 慢路径 (领段) 上限, 防 DB 抖动拖垮调用方
		client.WithFailureRetry(fp),
		client.WithCircuitBreaker(circuitbreak.NewCBSuite(circuitbreak.RPCInfo2Key)),
		// trace: TTHeader transport + metainfo 传播 (官方 otel Suite, 为什么不自制见 trace/propagate.go)
		client.WithSuite(tracing.NewClientSuite()),
	}
}

// DirectClientOptions 直连单实例客户端 (不经服务发现, 按 addr 固定):
// 广播场景用 —— JobPusher 对每个 comet 实例各持一个 client, PushMessage 逐实例推送。
func DirectClientOptions(addr string) []client.Option {
	fp := retry.NewFailurePolicy()
	fp.WithMaxRetryTimes(1)
	fp.WithRandomBackOff(50, 200)
	fp.WithRetryBreaker(0.3) // 直连单实例没有 LB 兜底, 熔断稍放宽 (kitex 要求 < 0.5)
	return []client.Option{
		client.WithHostPorts(addr),
		client.WithConnectTimeout(200 * time.Millisecond),
		client.WithRPCTimeout(time.Second),
		client.WithFailureRetry(fp),
		client.WithCircuitBreaker(circuitbreak.NewCBSuite(circuitbreak.RPCInfo2Key)),
		client.WithSuite(tracing.NewClientSuite()),
	}
}

// ServerOptions 标准服务端配置: 监听 + 注册 + trace。
func ServerOptions(serviceName string, addr string, reg registry.Registry) ([]server.Option, error) {
	a, err := net.ResolveTCPAddr("tcp", addr)
	if err != nil {
		return nil, err
	}
	return []server.Option{
		server.WithServiceAddr(a),
		server.WithServerBasicInfo(&rpcinfo.EndpointBasicInfo{ServiceName: serviceName}),
		server.WithRegistry(reg),
		server.WithSuite(tracing.NewServerSuite()),
	}, nil
}

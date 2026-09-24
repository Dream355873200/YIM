// HTTP 层 trace 贯通: Hertz 入口提取/生成 W3C traceparent。
//
// RPC 层的传播由 kitex-contrib/obs-opentelemetry 的 tracing Suite 承担
// (TTHeader transport + metainfo, 见 internal/kitexcfg)。
// 之所以不自制 RPC 中间件: Kitex server 的 endpoint middleware 拿到的 ctx
// 不含 transport 层 incoming metadata, 官方 Suite 用 stats.Tracer 钩子在
// 正确时机接住 —— 这是个真实的坑, 自制版本会静默丢 trace。
//
// 日志 (logger.C) 从 ctx 读 SpanContext, 因此任何一层打日志都带 trace_id,
// Loki → Jaeger 可互跳。
package trace

import (
	"context"
	"fmt"

	"github.com/cloudwego/hertz/pkg/app"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/propagation"
)

// W3C 传播涉及的 header
var traceHeaders = []string{"traceparent", "tracestate", "baggage"}

// HertzServerMiddleware HTTP 入口: 提取上游 traceparent (没有则本请求为根 span)。
func HertzServerMiddleware() app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		carrier := propagation.MapCarrier{}
		for _, k := range traceHeaders {
			if v := string(c.Request.Header.Get(k)); v != "" {
				carrier.Set(k, v)
			}
		}
		ctx = otel.GetTextMapPropagator().Extract(ctx, carrier)
		ctx, span := otel.Tracer("yim").Start(ctx,
			fmt.Sprintf("HTTP %s %s", c.Method(), c.Path()))
		defer span.End()
		c.Next(ctx)
	}
}

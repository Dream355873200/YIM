// Package trace: OpenTelemetry 初始化。
//
// 全链路传播路径 (必须第一天就打通, 事后补传是灾难):
//
//	Client (HTTP header: traceparent) → Hertz → gRPC (interceptor)
//	→ Kafka (header 注入) → Job → Comet
//
// 服务端只生产 OTLP, 导出目标由 OTel Collector 收敛:
// 换 Jaeger/Tempo/商用 APM 不改业务代码。
package trace

import (
	"context"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
	"go.uber.org/zap"
)

type Config struct {
	Endpoint    string // OTel Collector OTLP gRPC 地址
	ServiceName string
	Dev         bool // dev: 100% 采样; 生产: 父子继承+10%兜底
}

// Init 注册全局 TracerProvider 与传播器, 返回 shutdown 供优雅退出刷缓冲。
func Init(ctx context.Context, cfg Config, log *zap.Logger) (func(context.Context) error, error) {
	exp, err := otlptracegrpc.New(ctx,
		otlptracegrpc.WithEndpoint(cfg.Endpoint),
		// 本地开发 Collector 未起时不阻塞服务启动 (异步 batcher, 重试失败仅丢弃)
		otlptracegrpc.WithInsecure(),
		otlptracegrpc.WithTimeout(3*time.Second),
	)
	if err != nil {
		return nil, err
	}

	res, err := resource.New(ctx,
		resource.WithAttributes(semconv.ServiceName(cfg.ServiceName)),
	)
	if err != nil {
		return nil, err
	}

	var sampler sdktrace.Sampler
	if cfg.Dev {
		sampler = sdktrace.ParentBased(sdktrace.AlwaysSample())
	} else {
		sampler = sdktrace.ParentBased(sdktrace.TraceIDRatioBased(0.1))
	}

	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exp,
			sdktrace.WithBatchTimeout(500*time.Millisecond), // dev 观察低延迟
		),
		sdktrace.WithResource(res),
		sdktrace.WithSampler(sampler),
	)
	otel.SetTracerProvider(tp)

	// W3C traceparent/tracestate + baggage, HTTP/gRPC/Kafka 统一这一套
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{},
		propagation.Baggage{},
	))

	// 未导出的 span 在进程退出时也要落地
	otel.SetErrorHandler(otel.ErrorHandlerFunc(func(err error) {
		log.Warn("otel", zap.Error(err))
	}))

	shutdown := func(ctx context.Context) error {
		return tp.Shutdown(ctx)
	}
	return shutdown, nil
}

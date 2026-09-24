// Package logger: zap 初始化, 全局单例 + hlog 桥接 + trace 关联。
package logger

import (
	"context"

	"github.com/cloudwego/hertz/pkg/common/hlog"
	hertzzap "github.com/hertz-contrib/logger/zap"
	"go.opentelemetry.io/otel/trace"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var L *zap.Logger

// Init 初始化全局 logger。
// dev=true: console 编码+彩色+debug 级; 否则 json 编码+info 级(生产)。
func Init(dev bool) error {
	var cfg zap.Config
	if dev {
		cfg = zap.NewDevelopmentConfig()
		cfg.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
	} else {
		cfg = zap.NewProductionConfig()
	}
	l, err := cfg.Build()
	if err != nil {
		return err
	}
	L = l
	zap.ReplaceGlobals(l)

	// 桥接 hertz hlog: 框架日志与业务日志统一 zap 格式。
	// 框架 access log 不带 trace (业务日志经 logger.C(ctx) 注入 trace_id)
	hl := hertzzap.NewLogger()
	hlog.SetLogger(hl)
	return nil
}

// traceFields 从 ctx 提取 span 上下文, 注入为结构化字段。
// 无 trace 时(如后台任务未接入)返回空, 日志照常输出。
func traceFields(ctx context.Context) []zap.Field {
	if ctx == nil {
		return nil
	}
	sc := trace.SpanContextFromContext(ctx)
	if !sc.IsValid() {
		return nil
	}
	return []zap.Field{
		zap.String("trace_id", sc.TraceID().String()),
		zap.String("span_id", sc.SpanID().String()),
	}
}

// C 返回带 trace 上下文的 logger。
// 业务代码统一使用: logger.C(ctx).Info("msg delivered", zap.Int64("seq", s))
// json 模式下 trace_id 落盘 → Loki 按 trace_id 关联查链路。
func C(ctx context.Context) *zap.Logger {
	if ctx == nil {
		return L
	}
	return L.With(traceFields(ctx)...)
}

// Sync 退出前刷缓冲。
func Sync() {
	if L != nil {
		_ = L.Sync()
	}
}

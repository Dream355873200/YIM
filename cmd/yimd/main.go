// yimd: YIM API 网关 (里程碑2 起)。
//
// 职责收窄为: HTTP 路由 → Kitex RPC 转发, 不含业务逻辑。
// 通过 etcd 发现下游服务 (yim.message), 负载均衡/熔断/重试由 Kitex client 侧治理。
// 里程碑1 的单体实现已拆出 -> cmd/yim-message。
package main

import (
	"context"
	"crypto/tls"
	"flag"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/cloudwego/hertz/pkg/app/server"
	hconfig "github.com/cloudwego/hertz/pkg/common/config"
	etcd "github.com/kitex-contrib/registry-etcd"
	"go.uber.org/zap"

	"github.com/yim/internal/config"
	"github.com/yim/internal/kitexcfg"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/middleware"
	"github.com/yim/internal/trace"
	messageservice "github.com/yim/kitex_gen/yim/messageservice"
	relationservice "github.com/yim/kitex_gen/yim/relationservice"
	logicservice "github.com/yim/kitex_gen/yim/logicservice"
)

func main() {
	dev := flag.Bool("dev", true, "dev mode: console log + 100% sampling")
	selftest := flag.Bool("selftest", false, "send messages end-to-end via RPC and exit")
	flag.Parse()

	if err := logger.Init(*dev); err != nil {
		panic(err)
	}
	defer logger.Sync()

	cfg, err := config.Load()
	if err != nil {
		logger.L.Fatal("load config", zap.Error(err))
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	shutdownTP, err := trace.Init(ctx, trace.Config{
		Endpoint:    cfg.OTelEndpoint,
		ServiceName: "yimd",
		Dev:         *dev,
	}, logger.L)
	if err != nil {
		logger.L.Warn("otel disabled", zap.Error(err))
	}

	// ---------- 服务发现 + Kitex client (治理能力在 client 侧配置) ----------
	resolver, err := etcd.NewEtcdResolver(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd resolver", zap.Error(err))
	}
	msgCli, err := messageservice.NewClient("yim.message",
		kitexcfg.ClientOptions(resolver, "yim.message")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.message", zap.Error(err))
	}
	logicCli, err := logicservice.NewClient("yim.logic",
		kitexcfg.ClientOptions(resolver, "yim.logic")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.logic", zap.Error(err))
	}
	relCli, err := relationservice.NewClient("yim.relation",
		kitexcfg.ClientOptions(resolver, "yim.relation")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.relation", zap.Error(err))
	}

	logger.L.Info("yimd ready",
		zap.String("http", cfg.HTTPAddr),
		zap.Strings("etcd", cfg.EtcdEndpoints),
	)

	if *selftest {
		runSelftest(cfg, msgCli)
		return
	}

	hzOpts := []hconfig.Option{server.WithHostPorts(cfg.HTTPAddr)}
	// 可选 HTTPS (里程碑14): YIM_TLS_CERT/KEY 配置后网关整体升级 TLS,
	// 不再接受明文请求 (hertz 语义); 不配则维持 HTTP, 部署形态由 LB 终止 TLS 亦可
	if cfg.TLSCert != "" && cfg.TLSKey != "" {
		cert, terr := tls.LoadX509KeyPair(cfg.TLSCert, cfg.TLSKey)
		if terr != nil {
			logger.L.Fatal("load tls keypair", zap.Error(terr))
		}
		hzOpts = append(hzOpts, server.WithTLS(&tls.Config{
			Certificates: []tls.Certificate{cert},
			MinVersion:   tls.VersionTLS12,
		}))
		logger.L.Info("gateway HTTPS enabled", zap.String("cert", cfg.TLSCert))
	}
	hz := server.Default(hzOpts...)
	hz.Use(trace.HertzServerMiddleware()) // HTTP 入口 trace 起点
	// 网关鉴权 (里程碑9): register/login/files 豁免, 其余路由验 JWT;
	// handler 的 from_uid/op_uid 一律从中间件注入的身份取 (http.go)
	hz.Use(middleware.JWTAuth(cfg.JWTSecret, cfg.AuthMode == "dev"))
	registerRoutes(hz, msgCli, logicCli, relCli, cfg)
	registerAvatarRoutes(hz, cfg, relCli)
	hz.Spin()

	<-ctx.Done()
	logger.L.Info("yimd shutting down")
	if shutdownTP != nil {
		tctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		_ = shutdownTP(tctx)
	}
}

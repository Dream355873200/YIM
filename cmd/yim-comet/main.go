// yim-comet: 连接网关 (里程碑3)。
//
// 双面进程:
//   - 南向 (客户端): 自研 TCP 二进制协议, Netpoll/标准库接入, 心跳保活
//   - 北向 (集群):   Kitex gRPC "yim.comet", Job Svc 经此推送/踢人/排水
//
// 无状态之外只持连接索引 (内存), 重启 = 全体重连 + SYNC 补增量 (推拉协议兜底)。
package main

import (
	"context"
	"crypto/tls"
	"flag"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	etcd "github.com/kitex-contrib/registry-etcd"
	"go.uber.org/zap"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/comet"
	"github.com/yim/internal/config"
	"github.com/yim/internal/kitexcfg"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/store"
	"github.com/yim/internal/trace"
	cometservice "github.com/yim/kitex_gen/yim/cometservice"
	messageservice "github.com/yim/kitex_gen/yim/messageservice"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
)

const serviceName = "yim.comet"

func main() {
	dev := flag.Bool("dev", true, "dev mode: console log + 100% sampling")
	selftest := flag.Bool("selftest", false, "dial TCP, verify handshake/upstream/idempotency and exit")
	flag.Parse()

	if err := logger.Init(*dev); err != nil {
		panic(err)
	}
	defer logger.Sync()

	cfg, err := config.Load()
	if err != nil {
		logger.L.Fatal("load config", zap.Error(err))
	}

	if *selftest {
		runCometSelftest(cfg)
		return
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	shutdownTP, err := trace.Init(ctx, trace.Config{
		Endpoint:    cfg.OTelEndpoint,
		ServiceName: "yim-comet",
		Dev:         *dev,
	}, logger.L)
	if err != nil {
		logger.L.Warn("otel disabled", zap.Error(err))
	}

	// ---------- 下游 client (消息上行 / 同步水位) ----------
	resolver, err := etcd.NewEtcdResolver(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd resolver", zap.Error(err))
	}
	msgCli, err := messageservice.NewClient("yim.message", kitexcfg.ClientOptions(resolver, "yim.message")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.message", zap.Error(err))
	}
	seqCli, err := seqservice.NewClient("yim.seq", kitexcfg.ClientOptions(resolver, "yim.seq")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.seq", zap.Error(err))
	}

	// ---------- 南向 TCP 接入层 ----------
	keeper := comet.NewKeeper()
	// 鉴权 (里程碑5): JWT 本地验签; AuthMode=dev 时放行 "dev.<uid>" (自检/联调)
	var auth comet.Authenticator = comet.NewJWTAuthenticator(cfg.JWTSecret, cfg.AuthMode == "dev")
	if cfg.AuthMode == "dev" {
		logger.L.Info("auth mode: dev (JWT + dev tokens accepted)")
	}
	// 缓存/路由 (里程碑8): comet 首次引入 Redis —— 水位快速读 + route:{uid} 登记。
	// 连不上只降级: 水位回退 seq RPC, 推送回退全实例广播
	var msgCache *cache.Cache
	if r, err := store.OpenRedis(ctx, cfg.RedisAddrs[0]); err != nil {
		logger.L.Warn("redis unavailable, comet running degraded (seq RPC watermark + broadcast push)",
			zap.Error(err), zap.String("addr", cfg.RedisAddrs[0]))
	} else {
		defer r.Close()
		msgCache = cache.New(r.Client)
	}
	handler := comet.NewHandler(auth, msgCli, seqCli, keeper, msgCache, cfg.CometRPCAddr)
	srv := comet.NewServer(keeper, handler)
	// 瞬态信令 (里程碑12): 输入中/已读回执, Redis PubSub 即发即弃。
	// Redis 未装配时跳过 (打字提示/回执缺席, 不影响消息功能)。
	if msgCache != nil {
		go comet.SubscribeEphemeralLoop(ctx, msgCache, keeper)
	}
	// 事件推侧 (里程碑10): 上线事件 + 全量消费 yim.relation.event 推给本地连接。
	// Kafka 未配置时全部不装配 = 退回里程碑9 纯拉取形态。
	if len(cfg.KafkaBrokers) > 0 {
		pub := comet.NewEventPublisher(cfg.KafkaBrokers)
		defer pub.Close()
		handler.SetEventPublisher(pub)
		// 下线: 本实例最后一条连接断开 且 路由表已无任何实例登记 → 离线事件
		srv.SetOfflineHook(func(uid int64) {
			if msgCache != nil && msgCache.RouteRemLast(context.Background(), uid, cfg.CometRPCAddr) {
				pub.PublishPresence(uid, false)
			}
		})
		go comet.ConsumeRelationEvents(ctx, cfg.KafkaBrokers, cfg.CometRPCAddr, keeper)
		logger.L.Info("relation event push enabled", zap.Strings("brokers", cfg.KafkaBrokers))
	} else {
		// 无 Kafka: 路由注销照常 (推送广播兜底), 只是没有在线事件
		if msgCache != nil {
			srv.SetOfflineHook(func(uid int64) {
				msgCache.RouteRem(context.Background(), uid, cfg.CometRPCAddr)
			})
		}
	}

	ln, err := net.Listen("tcp", cfg.CometTCP)
	if err != nil {
		logger.L.Fatal("listen tcp", zap.Error(err))
	}
	// 可选 TLS (里程碑14): YIM_TLS_CERT/YIM_TLS_KEY 配置后长连接走 tls.Server
	// 包装。注意: netpoll 路径 (Linux) 持有原始 fd 无法包 TLS, 配置了证书时
	// 必须走标准库回退路径 —— 目前实现即 wrap 标准 listener, 部署在 Linux 上
	// 若要 netpoll 零拷贝 + TLS 需求, 前置 TLS 卸载 (LVS/Envoy) 是更优解。
	if cfg.TLSCert != "" && cfg.TLSKey != "" {
		cert, cerr := tls.LoadX509KeyPair(cfg.TLSCert, cfg.TLSKey)
		if cerr != nil {
			logger.L.Fatal("load tls keypair", zap.Error(cerr))
		}
		ln = tls.NewListener(ln, &tls.Config{Certificates: []tls.Certificate{cert}})
		logger.L.Info("comet TLS enabled", zap.String("cert", cfg.TLSCert))
	}
	go func() {
		if err := srv.Serve(ln); err != nil {
			logger.L.Fatal("comet serve", zap.Error(err))
		}
	}()

	// ---------- 北向 Kitex server (注册 etcd, Job Svc 可发现) ----------
	reg, err := etcd.NewEtcdRegistry(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd registry", zap.Error(err))
	}
	svrOpts, err := kitexcfg.ServerOptions(serviceName, cfg.CometRPCAddr, reg)
	if err != nil {
		logger.L.Fatal("server options", zap.Error(err))
	}
	svr := cometservice.NewServer(&CometHandler{server: srv, keeper: keeper}, svrOpts...)

	logger.L.Info("yim-comet ready",
		zap.String("tcp", cfg.CometTCP),
		zap.String("rpc", cfg.CometRPCAddr),
		zap.Strings("etcd", cfg.EtcdEndpoints),
	)

	if err := svr.Run(); err != nil {
		logger.L.Fatal("kitex server", zap.Error(err))
	}

	logger.L.Info("yim-comet shutting down")
	_ = srv.Drain(3 * time.Second) // 优雅退出: 通知客户端重连其他实例
	if shutdownTP != nil {
		tctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		_ = shutdownTP(tctx)
	}
}

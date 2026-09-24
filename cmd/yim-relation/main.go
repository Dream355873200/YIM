// yim-relation: Relation Svc (里程碑9) —— 好友 / 群成员 / 用户资料 / 在线状态。
//
// 关系域数据全部落 yim_meta (与 users/conversations 同库)。
// 好友校验被 Message Svc CreateConv 同步调用 (fail-close), 所以本服务
// 可用性要求与 message 同级; Redis 不可用只降级缓存/presence, 功能不挂。
package main

import (
	"context"
	"flag"
	"os"
	"os/signal"
	"syscall"
	"time"

	etcd "github.com/kitex-contrib/registry-etcd"
	"go.uber.org/zap"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/config"
	"github.com/yim/internal/kitexcfg"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/relation"
	"github.com/yim/internal/store"
	"github.com/yim/internal/trace"
	relationservice "github.com/yim/kitex_gen/yim/relationservice"
)

const serviceName = "yim.relation"

func main() {
	dev := flag.Bool("dev", true, "dev mode: console log + 100% sampling")
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

	db, err := store.OpenMySQL(ctx, cfg.MySQLDSN)
	if err != nil {
		logger.L.Fatal("open mysql", zap.Error(err))
	}
	defer db.Close()

	// 缓存: 资料 profile:{uid} + presence route:{uid} + conv 失效;
	// Redis 不可用降级不 fatal (relation 的一致性锚点在 DB)
	var relCache *cache.Cache
	if c, err := cache.OpenRedis(ctx, cfg.RedisAddrs[0]); err != nil {
		logger.L.Warn("redis unavailable, running degraded (no profile cache / presence offline)",
			zap.Error(err), zap.String("addr", cfg.RedisAddrs[0]))
	} else {
		relCache = c
	}

	shutdownTP, err := trace.Init(ctx, trace.Config{
		Endpoint:    cfg.OTelEndpoint,
		ServiceName: "yim-relation",
		Dev:         *dev,
	}, logger.L)
	if err != nil {
		logger.L.Warn("otel disabled", zap.Error(err))
	}

	reg, err := etcd.NewEtcdRegistry(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd registry", zap.Error(err))
	}
	svrOpts, err := kitexcfg.ServerOptions(serviceName, cfg.RelationRPCAddr, reg)
	if err != nil {
		logger.L.Fatal("server options", zap.Error(err))
	}
	svc := relation.NewService(db, relCache)
	// 事件推侧 (里程碑10): 关系动作直发 + 在线事件补目标; Kafka 未配置 = 纯拉取
	if len(cfg.KafkaBrokers) > 0 {
		pub := relation.NewEventProducer(cfg.KafkaBrokers)
		defer pub.Close()
		svc.SetEventProducer(pub)
		go relation.EnrichPresence(ctx, cfg.KafkaBrokers, svc)
		logger.L.Info("relation event producer enabled", zap.Strings("brokers", cfg.KafkaBrokers))
	}
	svr := relationservice.NewServer(&RelationHandler{svc: svc}, svrOpts...)

	logger.L.Info("yim-relation ready",
		zap.String("rpc", cfg.RelationRPCAddr),
		zap.Strings("etcd", cfg.EtcdEndpoints),
	)

	if err := svr.Run(); err != nil {
		logger.L.Fatal("kitex server", zap.Error(err))
	}

	logger.L.Info("yim-relation shutting down")
	if shutdownTP != nil {
		tctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		_ = shutdownTP(tctx)
	}
}

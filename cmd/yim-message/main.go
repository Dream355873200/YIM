// yim-message: Message Svc (里程碑2 拆出的第一个独立进程)。
//
// Kitex server + protobuf + etcd 服务注册。
// 消息主链路的写路径全部收敛在这里: 幂等 → seq 分配 → 分片落库 → 投递。
// 网关 (yimd) / Comet (里程碑3) 通过 etcd 发现本服务, 走 Kitex RPC 调用。
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	etcd "github.com/kitex-contrib/registry-etcd"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/config"
	"github.com/yim/internal/kitexcfg"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/message"
	"github.com/yim/internal/store"
	"github.com/yim/internal/trace"
	messageservice "github.com/yim/kitex_gen/yim/messageservice"
	relationservice "github.com/yim/kitex_gen/yim/relationservice"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
)

const serviceName = "yim.message"

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

	// Seq Svc client: 发号是每条消息的必经路径, 走 etcd 发现
	resolver, err := etcd.NewEtcdResolver(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd resolver", zap.Error(err))
	}
	seqCli, err := seqservice.NewClient("yim.seq", kitexcfg.ClientOptions(resolver, "yim.seq")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.seq", zap.Error(err))
	}
	// Relation Svc client (里程碑9): 单聊好友校验 fail-close + 群成员 seed
	relCli, err := relationservice.NewClient("yim.relation", kitexcfg.ClientOptions(resolver, "yim.relation")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.relation", zap.Error(err))
	}

	shutdownTP, err := trace.Init(ctx, trace.Config{
		Endpoint:    cfg.OTelEndpoint,
		ServiceName: "yim-message",
		Dev:         *dev,
	}, logger.L)
	if err != nil {
		logger.L.Warn("otel disabled", zap.Error(err))
	}

	// 缓存层 (里程碑5): Redis 不可用只降级不 fatal, 主链路回退 DB 慢路径。
	// 保留原生 client (rdb) 供布隆重建订阅复用。
	var msgCache *cache.Cache
	var rdb *store.Redis
	if r, err := store.OpenRedis(ctx, cfg.RedisAddrs[0]); err != nil {
		logger.L.Warn("redis unavailable, running degraded (DB slow path)",
			zap.Error(err), zap.String("addr", cfg.RedisAddrs[0]))
	} else {
		rdb = r
		defer rdb.Close()
		msgCache = cache.New(rdb.Client)
	}

	// 投递层 (里程碑4 + Kafka 化): 标准形态走 Kafka (yim.push/yim.ack),
	// Job Svc 消费; YIM_KAFKA_BROKERS 未配置则降级进程内 channel。
	// 两种形态共用 Deliverer 核心, 切换只换队列实现不换投递逻辑。
	// 发号客户端: sync 水位走 Redis INCR (里程碑8 降密度), msg/conv 发号仍走
	// seq RPC; Redis 不可用时整体回退纯 RPC 形态 (接口不变, 业务代码零感知)
	seqClient := message.NewRedisSyncSeqClient(msgCache, message.NewRPCSeqClient(seqCli), db)

	cometCluster := message.NewCometCluster(resolver)
	// 路由本地缓存 (16 里程碑降密度, 进程内投递形态用): 同 yim-job ——
	// PushRouted 读进程内 map + route:change 失效流, miss 播种 Redis
	if msgCache != nil {
		rc := message.NewRouteCache()
		cometCluster.UseRouteCache(rc)
		go message.SubscribeRouteChanges(ctx, cfg.RedisAddrs[0], rc)
		logger.L.Info("route cache enabled", zap.String("redis", cfg.RedisAddrs[0]))
	}
	var (
		pusher message.Pusher
		acker  message.Acker
	)
	if len(cfg.KafkaBrokers) > 0 {
		kp := message.NewKafkaPusher(cfg.KafkaBrokers)
		defer kp.Close()
		pusher, acker = kp, kp
		logger.L.Info("delivery via kafka", zap.Strings("brokers", cfg.KafkaBrokers))
	} else {
		jp := message.NewJobPusher(db, seqClient, cometCluster, msgCache)
		jp.Run(message.DeliverWorkers) // conv-hash 分片全启 (保序 + 并行)
		defer jp.Close()
		jp.UseTimer(message.DefaultRetryTimer())
		pusher, acker = jp, jp
		logger.L.Info("delivery via in-process channel (kafka not configured)")
	}
	msgSvc := message.NewService(db, seqClient, pusher, msgCache)
	msgSvc.UseRelation(message.NewRelationAdapter(relCli))

	// 布隆预热 (幂等粗筛): 异步装载近期 client_msg_id;
	// 每日重建由调度系统广播触发 (subscribeBloomRebuild), 这里只做启动预热
	if msgSvc.Bloom() != nil {
		go func() {
			bctx, bcancel := context.WithTimeout(context.Background(), 30*time.Second)
			defer bcancel()
			if err := msgSvc.WarmIdempotencyBloom(bctx, 7); err != nil {
				logger.L.Warn("bloom warm failed (perf hit only)", zap.Error(err))
			} else {
				logger.L.Info("idempotency bloom warmed")
			}
		}()
		if rdb != nil {
			go subscribeBloomRebuild(ctx, cfg.RedisAddrs[0], msgSvc)
		}
	}

	reg, err := etcd.NewEtcdRegistry(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd registry", zap.Error(err))
	}
	svrOpts, err := kitexcfg.ServerOptions(serviceName, cfg.MessageRPCAddr, reg)
	if err != nil {
		logger.L.Fatal("server options", zap.Error(err))
	}
	svr := messageservice.NewServer(&MessageHandler{svc: msgSvc, acker: acker, seqCli: seqCli, cache: msgCache}, svrOpts...)

	logger.L.Info("yim-message ready",
		zap.String("rpc", cfg.MessageRPCAddr),
		zap.Strings("etcd", cfg.EtcdEndpoints),
		zap.Int("seq_step", cfg.SeqStep),
	)

	if err := svr.Run(); err != nil {
		logger.L.Fatal("kitex server", zap.Error(err))
	}

	logger.L.Info("yim-message shutting down")
	if shutdownTP != nil {
		tctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		_ = shutdownTP(tctx)
	}
}

// subscribeBloomRebuild 消费调度系统的布隆重建广播 (里程碑6)。
// 布隆实例在本进程内存里, 调度系统只发信号不搬数据 —— 执行方自持幂等
// (Rebuild 影子代双写, 重建期间新旧两代同时收写, 建完原子换上)。
// 断线重连 (1s); 用专用连接 (ReadTimeout=-1): pub/sub 长阻塞
// 不能挂在缓存连接池的 100ms 读超时上。
func subscribeBloomRebuild(ctx context.Context, addr string, svc *message.Service) {
	for ctx.Err() == nil {
		c := redis.NewClient(&redis.Options{Addr: addr, ReadTimeout: -1})
		sub := c.Subscribe(ctx, message.BloomRebuildChannel)
		for {
			msg, err := sub.ReceiveMessage(ctx)
			if err != nil {
				if ctx.Err() != nil {
					_ = c.Close()
					return
				}
				logger.L.Warn("bloom rebuild pubsub broken, reconnecting", zap.Error(err))
				break
			}
			days := 7
			_, _ = fmt.Sscanf(msg.Payload, "%d", &days)
			logger.L.Info("bloom rebuild triggered by scheduler", zap.Int("days", days))
			go func() {
				bctx, cancel := context.WithTimeout(context.Background(), time.Minute)
				defer cancel()
				if err := svc.WarmIdempotencyBloom(bctx, days); err != nil {
					logger.L.Warn("bloom rebuild failed (perf hit only)", zap.Error(err))
				} else {
					logger.L.Info("idempotency bloom rebuilt")
				}
			}()
		}
		_ = sub.Close()
		_ = c.Close()
		time.Sleep(time.Second)
	}
}

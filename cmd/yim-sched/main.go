// yim-sched: 调度系统 (里程碑6) —— 旁路对账与补偿的独立进程。
//
// 职责: 周期触发旁路任务 (local_message 扫描补偿 / offline_box 对账 /
// 未读数校准 / 布隆重建信号 / local_message 清理)。
// 定位红线: 绝不进主链路 —— 本进程挂掉只影响补偿时延, 不影响任何收发;
// 它触发的每个任务都必须幂等 (重复执行无正确性代价)。
//
// 多实例形态: 全部实例对等跑 worker 抢分片队列, etcd 选主决定谁触发;
// Redis 不可用时降级为 leader 单机内联执行 (任务幂等兜底正确性)。
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
	clientv3 "go.etcd.io/etcd/client/v3"
	"go.uber.org/zap"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/config"
	"github.com/yim/internal/kitexcfg"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/message"
	"github.com/yim/internal/sched"
	"github.com/yim/internal/store"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
)

func main() {
	dev := flag.Bool("dev", true, "dev mode: console log + 100% sampling")
	selftest := flag.Bool("selftest", false, "run every task once against the DB and verify effects, then exit")
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

	// Redis: 队列/锁/布隆信号都是优化组件, 不可用 → 降级 leader 内联执行
	var rdb *store.Redis
	if r, err := store.OpenRedis(ctx, cfg.RedisAddrs[0]); err != nil {
		logger.L.Warn("redis unavailable, scheduler degrades to leader-inline",
			zap.Error(err), zap.String("addr", cfg.RedisAddrs[0]))
	} else {
		rdb = r
		defer rdb.Close()
	}

	var msgCache *cache.Cache
	if rdb != nil {
		msgCache = cache.New(rdb.Client)
	}

	cli, err := clientv3.New(clientv3.Config{Endpoints: cfg.EtcdEndpoints, DialTimeout: 3 * time.Second})
	if err != nil {
		logger.L.Fatal("etcd client", zap.Error(err))
	}
	defer cli.Close()

	resolver, err := etcd.NewEtcdResolver(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd resolver", zap.Error(err))
	}
	seqCli, err := seqservice.NewClient("yim.seq", kitexcfg.ClientOptions(resolver, "yim.seq")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.seq", zap.Error(err))
	}

	// 扫描补偿复用投递核心 Deliverer (与 Job 消费同一实例逻辑)
	cometCluster := message.NewCometCluster(resolver)
	deliverer := message.NewDeliverer(db, message.NewRPCSeqClient(seqCli), cometCluster, msgCache)
	deliverer.UseTimer(message.DefaultRetryTimer())

	tasks := []sched.Task{
		message.NewScanCompensationTask(db, deliverer), // 防线3 本体
		message.NewOfflineBoxTask(db, cometCluster),
		message.NewUnreadReconcileTask(db),
		message.NewLocalMsgCleanupTask(db),
	}
	if rdb != nil {
		tasks = append(tasks, message.NewBloomRebuildTask(rdb.Client))
	}

	if *selftest {
		runSelftest(tasks, db)
		return
	}

	self := hostnamePID()
	var r *redis.Client
	if rdb != nil {
		r = rdb.Client
	}
	s := sched.New(cli, r, self, tasks...)
	logger.L.Info("yim-sched ready",
		zap.String("self", self),
		zap.Strings("etcd", cfg.EtcdEndpoints),
		zap.Bool("redis", rdb != nil),
	)
	s.Run(ctx)
	logger.L.Info("yim-sched shutting down")
}

func hostnamePID() string {
	h, err := os.Hostname()
	if err != nil {
		h = "unknown"
	}
	return fmt.Sprintf("%s:%d", h, os.Getpid())
}

// yim-seq: Seq Svc (对标微信 seqsvr 的独立发号服务)。
//
// 全集群唯一的发号进程: 会话 seq / 用户 sync seq / 实体 ID 都从这里出。
// 号段双 buffer 在内存里, DB (seq_segment 表) 只承担"领段"这一慢路径,
// 所以本服务的负载极低 —— 一万条消息才落一次 DB。
//
// GetSyncSeq 的精确性依赖"单进程持段": 发号进程只有这一个, 内存水位即全局水位。
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

	"github.com/yim/internal/config"
	"github.com/yim/internal/kitexcfg"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/seq"
	"github.com/yim/internal/store"
	"github.com/yim/internal/trace"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
)

const serviceName = "yim.seq"

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

	seqs := seq.NewPool(db.Meta, cfg.SeqStep)

	shutdownTP, err := trace.Init(ctx, trace.Config{
		Endpoint:    cfg.OTelEndpoint,
		ServiceName: "yim-seq",
		Dev:         *dev,
	}, logger.L)
	if err != nil {
		logger.L.Warn("otel disabled", zap.Error(err))
	}

	reg, err := etcd.NewEtcdRegistry(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd registry", zap.Error(err))
	}
	svrOpts, err := kitexcfg.ServerOptions(serviceName, cfg.SeqRPCAddr, reg)
	if err != nil {
		logger.L.Fatal("server options", zap.Error(err))
	}
	svr := seqservice.NewServer(&SeqHandler{pool: seqs}, svrOpts...)

	logger.L.Info("yim-seq ready",
		zap.String("rpc", cfg.SeqRPCAddr),
		zap.Strings("etcd", cfg.EtcdEndpoints),
		zap.Int("seq_step", cfg.SeqStep),
	)

	if err := svr.Run(); err != nil {
		logger.L.Fatal("kitex server", zap.Error(err))
	}

	logger.L.Info("yim-seq shutting down")
	if shutdownTP != nil {
		tctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		_ = shutdownTP(tctx)
	}
}

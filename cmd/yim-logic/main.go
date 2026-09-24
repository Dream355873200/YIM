// yim-logic: Logic Svc (里程碑5) —— 注册/登录/JWT 签发。
//
// 账号写路径收敛在此: 密码哈希不落任何其他服务, 登录态以无状态 JWT 下发,
// Comet 验签不回调本服务 (拆服务不拆调用方语义, 而是拆信任边界)。
package main

import (
	"context"
	"errors"
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
	"github.com/yim/internal/logic"
	"github.com/yim/internal/store"
	"github.com/yim/internal/trace"
	"github.com/yim/kitex_gen/yim"
	logicservice "github.com/yim/kitex_gen/yim/logicservice"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
)

const serviceName = "yim.logic"

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

	resolver, err := etcd.NewEtcdResolver(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd resolver", zap.Error(err))
	}
	seqCli, err := seqservice.NewClient("yim.seq", kitexcfg.ClientOptions(resolver, "yim.seq")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.seq", zap.Error(err))
	}

	shutdownTP, err := trace.Init(ctx, trace.Config{
		Endpoint:    cfg.OTelEndpoint,
		ServiceName: "yim-logic",
		Dev:         *dev,
	}, logger.L)
	if err != nil {
		logger.L.Warn("otel disabled", zap.Error(err))
	}

	reg, err := etcd.NewEtcdRegistry(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd registry", zap.Error(err))
	}
	svrOpts, err := kitexcfg.ServerOptions(serviceName, cfg.LogicRPCAddr, reg)
	if err != nil {
		logger.L.Fatal("server options", zap.Error(err))
	}

	svc := logic.NewService(db, &seqUIDs{cli: seqCli}, logic.NewTokenizer(cfg.JWTSecret))
	svr := logicservice.NewServer(&LogicHandler{svc: svc}, svrOpts...)

	logger.L.Info("yim-logic ready",
		zap.String("rpc", cfg.LogicRPCAddr),
		zap.Strings("etcd", cfg.EtcdEndpoints),
	)

	if err := svr.Run(); err != nil {
		logger.L.Fatal("kitex server", zap.Error(err))
	}

	logger.L.Info("yim-logic shutting down")
	if shutdownTP != nil {
		tctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		_ = shutdownTP(tctx)
	}
}

// seqUIDs UIDAllocator 适配: uid 走 Seq Svc 全局号段 (biz=uid)
type seqUIDs struct{ cli seqservice.Client }

func (s *seqUIDs) AllocUID(ctx context.Context) (int64, error) {
	rsp, err := s.cli.AllocId(ctx, &yim.AllocIdReq{Biz: "uid", KeyId: 0, Count: 1})
	if err != nil {
		return 0, err
	}
	return rsp.Start, nil
}

// LogicHandler implements yim.LogicService.
type LogicHandler struct {
	svc *logic.Service
}

func (h *LogicHandler) Register(ctx context.Context, req *yim.RegisterReq) (*yim.RegisterRsp, error) {
	r, err := h.svc.Register(ctx, req.GetNickname(), req.GetPassword())
	if err != nil {
		return &yim.RegisterRsp{Error: logicError(err)}, nil // 业务错误走 Error 字段, 不用 gRPC status
	}
	return &yim.RegisterRsp{Uid: r.UID}, nil
}

func (h *LogicHandler) Login(ctx context.Context, req *yim.LoginReq) (*yim.LoginRsp, error) {
	r, err := h.svc.Login(ctx, req.GetNickname(), req.GetPassword())
	if err != nil {
		return &yim.LoginRsp{Error: logicError(err)}, nil
	}
	return &yim.LoginRsp{Token: r.Token, Uid: r.UID, ExpireAtMs: r.ExpireAtMs}, nil
}

func logicError(err error) *yim.Error {
	code := int32(2) // 通用业务错误
	if errors.Is(err, logic.ErrNicknameTaken) {
		code = 10
	} else if errors.Is(err, logic.ErrBadCredential) {
		code = 11
	}
	return &yim.Error{Code: code, Msg: err.Error()}
}

// comet_cluster: 投递层对 comet 集群的推送客户端。
//
// 推送模型两档 (里程碑8 起):
//
//	路由表形态 (默认): route:{uid} Redis SET 记录 uid 在线实例, 定点推送,
//	                  O(持有该 uid 的实例数) —— goim 的 Router Svc 同款
//	广播形态 (回退):   路由 miss / Redis 不可用 → 广播全部实例本地判,
//	                  空查 N-1 次换"无路由状态负担", 小规模最稳
//
// 实例发现: 复用 etcd resolver, Resolve(ctx, "yim.comet") 拿全量实例列表,
// 周期刷新 (comet 上下线 5s 内生效); 每实例一个直连 client (带熔断隔离)。
package message

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/cloudwego/kitex/pkg/discovery"
	cometservice "github.com/yim/kitex_gen/yim/cometservice"
	"go.uber.org/zap"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/kitexcfg"
	"github.com/yim/internal/logger"
	"github.com/yim/kitex_gen/yim"
)

const (
	cometDest       = "yim.comet"
	instanceRefresh = 5 * time.Second
)

// cometCluster 并发安全。deliver goroutine 与实例刷新共用。
type cometCluster struct {
	resolver discovery.Resolver

	mu          sync.Mutex
	clients     map[string]cometservice.Client // addr → client (惰性创建, 熔断按实例隔离)
	instances   []string
	lastResolve time.Time

	routes *routeCache // 可为 nil: RouteGet 直查 Redis (原行为)
}

func NewCometCluster(resolver discovery.Resolver) *cometCluster {
	return &cometCluster{resolver: resolver, clients: make(map[string]cometservice.Client)}
}

// UseRouteCache 装配路由本地缓存 (16 里程碑): PushRouted 读进程内 map,
// miss 才播种 Redis。须配合 SubscribeRouteChanges 消费失效流。
func (c *cometCluster) UseRouteCache(rc *routeCache) { c.routes = rc }

// PushRouted 定点推送: 查路由表只推 uid 实际在线的实例。
// 路由 miss / Redis 故障 / cache 为 nil → 回退 PushAll 广播 (正确性同构,
// 只是多花 N-1 次空查) —— 路由表是优化组件, 不是正确性组件。
// 定点全失败 (陈旧 addr / 实例崩溃) 同样回退广播, 语义与 miss 一致。
func (c *cometCluster) PushRouted(ctx context.Context, rc *cache.Cache, uid, convID, maxSeq, fromUID, userSyncSeq int64) bool {
	addrs, ok := c.routes.get(ctx, rc, uid)
	if !ok {
		return c.PushAll(ctx, uid, convID, maxSeq, fromUID, userSyncSeq)
	}
	req := &yim.PushMessageReq{
		Uid: uid, ConvId: convID, MaxSeq: maxSeq,
		FromUid: fromUID, UserSyncSeq: userSyncSeq,
	}
	delivered := false
	for _, addr := range addrs {
		if c.pushOne(ctx, addr, req) {
			delivered = true
		}
	}
	if !delivered {
		return c.PushAll(ctx, uid, convID, maxSeq, fromUID, userSyncSeq)
	}
	return true
}

// PushAll 广播轻通知给全部 comet 实例。任一实例回 delivered=true 即视为在线。
func (c *cometCluster) PushAll(ctx context.Context, uid, convID, maxSeq, fromUID, userSyncSeq int64) bool {
	req := &yim.PushMessageReq{
		Uid: uid, ConvId: convID, MaxSeq: maxSeq,
		FromUid: fromUID, UserSyncSeq: userSyncSeq,
	}
	delivered := false
	for _, addr := range c.snapshotInstances() {
		if c.pushOne(ctx, addr, req) {
			delivered = true
		}
	}
	return delivered
}

// pushOne 单实例推送。失败记日志不阻断 —— 单实例故障不污染整体投递
// (熔断器会把持续故障的实例摘出流量)。
func (c *cometCluster) pushOne(ctx context.Context, addr string, req *yim.PushMessageReq) bool {
	cli, err := c.clientFor(addr)
	if err != nil {
		logger.L.Warn("comet client build", zap.String("addr", addr), zap.Error(err))
		return false
	}
	rsp, err := cli.PushMessage(ctx, req)
	if err != nil {
		logger.L.Warn("comet push rpc", zap.String("addr", addr), zap.Error(err))
		return false
	}
	return rsp.GetDelivered()
}

// snapshotInstances 实例列表 (5s 缓存; 解析失败沿用旧列表, 不因 etcd 抖动中断投递)
func (c *cometCluster) snapshotInstances() []string {
	c.mu.Lock()
	defer c.mu.Unlock()
	if time.Since(c.lastResolve) < instanceRefresh {
		return c.instances
	}
	result, err := c.resolver.Resolve(context.Background(), cometDest)
	if err != nil {
		logger.L.Warn("comet resolve", zap.Error(err))
		return c.instances
	}
	addrs := make([]string, 0, len(result.Instances))
	for _, ins := range result.Instances {
		addrs = append(addrs, ins.Address().String())
	}
	c.instances = addrs
	c.lastResolve = time.Now()
	return addrs
}

// clientFor 每实例独立 client: 熔断按实例隔离, 一台故障不污染其他
func (c *cometCluster) clientFor(addr string) (cometservice.Client, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if cli, ok := c.clients[addr]; ok {
		return cli, nil
	}
	cli, err := cometservice.NewClient(cometDest, kitexcfg.DirectClientOptions(addr)...)
	if err != nil {
		return nil, fmt.Errorf("new comet client %s: %w", addr, err)
	}
	c.clients[addr] = cli
	return cli, nil
}

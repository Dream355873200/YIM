// routeCache route:{uid} 的进程内读缓存 (16 里程碑降密度, 对账 OpenIM 在线
// 状态模型): 每接收者一次 RouteGet (Redis SMEMBERS) → 本地命中 0 次 Redis。
//
// 一致性模型:
//
//	写侧: comet RouteAdd/RouteRem 时 PUBLISH route:change (cache.go)
//	读侧: 本地 map → miss 播种 (Redis RouteGet, 兼容 pub 丢失/刚启动)
//	      → 再 miss → PushAll 广播回退 (路由是优化组件, 非正确性组件)
//	陈旧兜底: comet 实例崩溃无 RouteRem → 本地残留 addr 的推送
//	          Delivered=false / RPC 失败 → PushRouted 整体回退广播 (同构兜底);
//	          订阅断线重连时清空 map (pub 窗口的变更靠播种覆盖)
package message

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/logger"
)

type routeCache struct {
	mu sync.Mutex
	m  map[int64]map[string]struct{} // uid → 在线实例 addr 集合
}

func NewRouteCache() *routeCache {
	return &routeCache{m: make(map[int64]map[string]struct{})}
}

// get 取 uid 的在线实例列表: 本地命中 → Redis 播种 → miss。
// rc 为 nil 或 Redis 故障时走 PushAll 回退, 由调用方处理 (ok=false)。
func (r *routeCache) get(ctx context.Context, rc *cache.Cache, uid int64) ([]string, bool) {
	if r == nil {
		return rc.RouteGet(ctx, uid) // 未装配本地缓存: 原行为
	}
	r.mu.Lock()
	m := r.m[uid]
	r.mu.Unlock()
	if len(m) > 0 {
		addrs := make([]string, 0, len(m))
		for a := range m {
			addrs = append(addrs, a)
		}
		return addrs, true
	}
	addrs, ok := rc.RouteGet(ctx, uid) // 播种
	if ok {
		r.seed(uid, addrs)
	}
	return addrs, ok
}

func (r *routeCache) seed(uid int64, addrs []string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	m := make(map[string]struct{}, len(addrs))
	for _, a := range addrs {
		m[a] = struct{}{}
	}
	r.m[uid] = m
}

// apply 消费 route:change 事件 (op: add/rem)。
func (r *routeCache) apply(op string, uid int64, addr string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	switch op {
	case "add":
		m := r.m[uid]
		if m == nil {
			m = make(map[string]struct{})
			r.m[uid] = m
		}
		m[addr] = struct{}{}
	case "rem":
		if m := r.m[uid]; m != nil {
			delete(m, addr)
			if len(m) == 0 {
				delete(r.m, uid)
			}
		}
	}
}

// reset 清空本地缓存 (订阅断线重连时调用: pub 窗口的变更靠播种覆盖)。
func (r *routeCache) reset() {
	r.mu.Lock()
	r.m = make(map[int64]map[string]struct{})
	r.mu.Unlock()
}

// SubscribeRouteChanges 消费 route:change 失效流 (专用连接 ReadTimeout=-1,
// pub/sub 长阻塞不能挂在连接池的 100ms 读超时上 —— subscribeBloomRebuild 同款;
// 断线重连 1s, 重连先清空本地 map)。
func SubscribeRouteChanges(ctx context.Context, addr string, rc *routeCache) {
	for ctx.Err() == nil {
		c := redis.NewClient(&redis.Options{Addr: addr, ReadTimeout: -1})
		sub := c.Subscribe(ctx, cache.RouteChangeChannel)
		rc.reset()
		for {
			msg, err := sub.ReceiveMessage(ctx)
			if err != nil {
				if ctx.Err() != nil {
					_ = c.Close()
					return
				}
				logger.L.Warn("route change pubsub broken, reconnecting", zap.Error(err))
				break
			}
			var op string
			var uid int64
			var routeAddr string
			if _, err := fmt.Sscanf(msg.Payload, "%s %d %s", &op, &uid, &routeAddr); err == nil {
				rc.apply(op, uid, routeAddr)
			}
		}
		_ = sub.Close()
		_ = c.Close()
		time.Sleep(time.Second)
	}
}

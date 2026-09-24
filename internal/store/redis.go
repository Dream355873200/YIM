package store

import (
	"context"
	"time"

	"github.com/redis/go-redis/v9"
)

// Redis 开发期单实例, 接口按 Clusterable 设计 (NewClusterClient 可平替)。
type Redis struct {
	Client *redis.Client
}

func OpenRedis(ctx context.Context, addr string) (*Redis, error) {
	c := redis.NewClient(&redis.Options{
		Addr:         addr,
		DialTimeout:  2 * time.Second,
		ReadTimeout:  100 * time.Millisecond, // 缓存读超时收紧: 失败走DB, 不拖主链路
		WriteTimeout: 200 * time.Millisecond,
		PoolSize:     128,
	})
	if err := c.Ping(ctx).Err(); err != nil {
		return nil, err
	}
	return &Redis{Client: c}, nil
}

func (r *Redis) Close() { _ = r.Client.Close() }

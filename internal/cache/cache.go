// Package cache: Redis 缓存体系 (里程碑5)。
//
// 设计基调: 缓存是优化不是依赖 —— 任何缓存 miss/故障都回退 DB,
// DB 的唯一键约束才是正确性防线。nil *Cache 合法 (零值降级),
// 所有方法对 nil receiver 返回 miss, 进程无 Redis 也能跑。
//
// 键规划 (见 ARCHITECTURE.md §6):
//
//	idem:{conv_id}:{client_msg_id}   幂等精查 (SETNX + TTL), 值为已落库的 msg_id/seq
//	conv:{id}:members                会话成员 JSON (投递层扇出用)
//	conv:{id}:meta                   会话元数据 JSON (last_seq 等)
//	conv:{id}:recent                 ZSET 最近消息 (member=seq, score=seq)
package cache

import (
	"context"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"hash/fnv"
	"strconv"
	"time"

	"github.com/redis/go-redis/v9"

	"github.com/yim/internal/store"
)

const (
	idemTTL      = 24 * time.Hour // 幂等窗口: 超过它重复 client_msg_id 交给 DB 唯一键兜底
	membersTTL   = 10 * time.Minute
	metaTTL      = 10 * time.Minute
	recentTTL    = time.Hour
	recentMaxLen = 200 // ZSET 只留最近窗口, 防热会话撑爆内存
)

type Cache struct {
	rdb *redis.Client
}

// New 允许 rdb 为 nil (Redis 不可用时的降级形态)。
func New(rdb *redis.Client) *Cache {
	if rdb == nil {
		return nil
	}
	return &Cache{rdb: rdb}
}

// OpenRedis 便捷构造: addr 连不上返回 nil (降级不 fatal), err 只记日志用。
func OpenRedis(ctx context.Context, addr string) (*Cache, error) {
	r, err := store.OpenRedis(ctx, addr)
	if err != nil {
		return nil, err
	}
	return New(r.Client), nil
}

func idemKey(convID, clientMsgID int64) string {
	return fmt.Sprintf("idem:%d:%d", convID, clientMsgID)
}

// IdemPut 幂等标记: SETNX 成功 = 这是首次见到该 (conv, client_msg_id)。
// 第二参数 ok=false 表示键已存在 (重复消息, 值为上次落库结果)。
// 失败的插入必须调 IdemDel 回滚标记, 否则同 ID 的合法重试被误判重复。
func (c *Cache) IdemPut(ctx context.Context, convID, clientMsgID int64, v IdemValue) (ok bool, err error) {
	if c == nil {
		return true, nil // 无缓存: 直接放行, DB 唯一键兜底
	}
	b, _ := json.Marshal(v)
	set, err := c.rdb.SetNX(ctx, idemKey(convID, clientMsgID), b, idemTTL).Result()
	if err != nil {
		return true, err // Redis 故障: 放行走 DB 慢路径
	}
	return set, nil
}

// IdemGet 重复消息的快速返回: 拿到上次落库的 msg_id/seq 就不用查 DB。
func (c *Cache) IdemGet(ctx context.Context, convID, clientMsgID int64) (IdemValue, bool) {
	if c == nil {
		return IdemValue{}, false
	}
	b, err := c.rdb.Get(ctx, idemKey(convID, clientMsgID)).Bytes()
	if err != nil {
		return IdemValue{}, false
	}
	var v IdemValue
	if json.Unmarshal(b, &v) != nil {
		return IdemValue{}, false
	}
	return v, true
}

func (c *Cache) IdemDel(ctx context.Context, convID, clientMsgID int64) {
	if c == nil {
		return
	}
	c.rdb.Del(ctx, idemKey(convID, clientMsgID))
}

type IdemValue struct {
	MsgID int64 `json:"msg_id"`
	Seq   int64 `json:"seq"`
}

// ---- 会话成员 (投递层扇出热路径) ----

func (c *Cache) ConvMembers(ctx context.Context, db *store.MySQL, convID int64) ([]int64, error) {
	if c != nil {
		if raw, err := c.rdb.Get(ctx, fmt.Sprintf("conv:%d:members", convID)).Bytes(); err == nil {
			var m []int64
			if json.Unmarshal(raw, &m) == nil {
				return m, nil
			}
		} // miss/坏值: 回落 DB, 不阻塞主链路
	}

	var raw string
	if err := db.Meta.QueryRowContext(ctx,
		"SELECT member_uids FROM conversations WHERE conv_id = ?", convID).Scan(&raw); err != nil {
		return nil, fmt.Errorf("conv %d: %w", convID, err)
	}
	var members []int64
	if err := json.Unmarshal([]byte(raw), &members); err != nil {
		return nil, fmt.Errorf("parse member_uids conv %d: %w", convID, err)
	}
	if c != nil {
		c.rdb.Set(ctx, fmt.Sprintf("conv:%d:members", convID), raw, membersTTL)
	}
	return members, nil
}

func (c *Cache) InvalidateConv(ctx context.Context, convID int64) {
	if c == nil {
		return
	}
	c.rdb.Del(ctx, fmt.Sprintf("conv:%d:members", convID), fmt.Sprintf("conv:%d:meta", convID))
}

// ---- 会话元数据 ----

type ConvMeta struct {
	ConvID       int64   `json:"conv_id"`
	Type         int32   `json:"type"`
	MemberUIDs   []int64 `json:"member_uids"`
	LastSeq      int64   `json:"last_seq"`
	CreateTimeMs int64   `json:"create_time_ms"`
	Name         string  `json:"name"`   // 群名 (里程碑11, 单聊空)
	Avatar       string  `json:"avatar"` // 群头像相对 URL, 单聊空
}

// ConvMeta cache-aside; load 会话行是单点读, 命中率决定 DB 压力。
func (c *Cache) GetConvMeta(ctx context.Context, db *store.MySQL, convID int64) (*ConvMeta, error) {
	key := fmt.Sprintf("conv:%d:meta", convID)
	if c != nil {
		if raw, err := c.rdb.Get(ctx, key).Bytes(); err == nil {
			var m ConvMeta
			if json.Unmarshal(raw, &m) == nil {
				return &m, nil
			}
		}
	}

	var m ConvMeta
	var raw []byte
	// create_time 是 datetime(3): SQL 侧转毫秒。UNIX_TIMESTAMP 带小数秒参数时
	// 返回 DECIMAL (驱动扫成 []byte), 必须 CAST 成整数才能 Scan 进 int64
	if err := db.Meta.QueryRowContext(ctx,
		"SELECT conv_id, type, member_uids, last_seq, CAST(UNIX_TIMESTAMP(create_time)*1000 AS SIGNED), name, avatar FROM conversations WHERE conv_id = ?",
		convID).Scan(&m.ConvID, &m.Type, &raw, &m.LastSeq, &m.CreateTimeMs, &m.Name, &m.Avatar); err != nil {
		return nil, fmt.Errorf("conv %d: %w", convID, err)
	}
	if err := json.Unmarshal(raw, &m.MemberUIDs); err != nil {
		return nil, fmt.Errorf("conv %d member_uids: %w", convID, err)
	}
	if c != nil {
		if b, err := json.Marshal(&m); err == nil {
			c.rdb.Set(ctx, key, b, metaTTL)
		}
	}
	return &m, nil
}

func (c *Cache) SetConvMeta(ctx context.Context, m *ConvMeta) {
	if c == nil {
		return
	}
	if b, err := json.Marshal(m); err == nil {
		c.rdb.Set(ctx, fmt.Sprintf("conv:%d:meta", m.ConvID), b, metaTTL)
	}
}

// ---- 最近消息 ZSET ----

// RecentMsg 一条缓存的最近消息: member 为 ConvMessage 的 protojson,
// score = seq —— 会话内 seq 单调, ZSET 天然按 seq 有序, 最高分即最新一条。
func (c *Cache) RecentAdd(ctx context.Context, convID, seq int64, msg []byte) {
	if c == nil {
		return
	}
	pipe := c.rdb.Pipeline()
	pipe.ZAdd(ctx, recentKey(convID), redis.Z{Score: float64(seq), Member: msg})
	pipe.ZRemRangeByRank(ctx, recentKey(convID), 0, -(recentMaxLen + 1)) // 只留最近 recentMaxLen 条
	pipe.Expire(ctx, recentKey(convID), recentTTL)
	_, _ = pipe.Exec(ctx)
}

// RecentList 返回最近消息缓存 (升序), miss 返回 nil。
// 窗口语义: 只覆盖最近 recentMaxLen 条, 翻更早的页走 DB;
// 调用方以"缓存条数是否够一页"判断命中, 不够就整体回落 DB 重建。
func (c *Cache) RecentList(ctx context.Context, convID int64, count int64) [][]byte {
	if c == nil {
		return nil
	}
	vals, err := c.rdb.ZRevRange(ctx, recentKey(convID), 0, count-1).Result()
	if err != nil || int64(len(vals)) < count {
		return nil // 不满一页视为 miss: 避免部分命中时新旧来源拼接出错
	}
	// ZREVRANGE 倒序 (新→旧), 反转成旧→新
	for i, j := 0, len(vals)-1; i < j; i, j = i+1, j-1 {
		vals[i], vals[j] = vals[j], vals[i]
	}
	out := make([][]byte, len(vals))
	for i, v := range vals {
		out[i] = []byte(v)
	}
	return out
}

func recentKey(convID int64) string { return fmt.Sprintf("conv:%d:recent", convID) }

// RecentTop 取最近一条 (会话列表预览), miss 返回 nil。
func (c *Cache) RecentTop(ctx context.Context, convID int64) []byte {
	if c == nil {
		return nil
	}
	vals, err := c.rdb.ZRevRange(ctx, recentKey(convID), 0, 0).Result()
	if err != nil || len(vals) == 0 {
		return nil
	}
	return []byte(vals[0])
}

// ---- 已读水位 (user_conv_state 的读缓存) ----

func readKey(uid, convID int64) string { return fmt.Sprintf("read:%d:%d", uid, convID) }

// GetReadSeq found=false 表示缓存 miss (区别于真实的 0),
// 调用方决定回落 DB —— 已读水位错了只影响未读数显示。
func (c *Cache) GetReadSeq(ctx context.Context, uid, convID int64) (int64, bool) {
	if c == nil {
		return 0, false
	}
	v, err := c.rdb.Get(ctx, readKey(uid, convID)).Int64()
	if err != nil {
		return 0, false
	}
	return v, true
}

func (c *Cache) SetReadSeq(ctx context.Context, uid, convID, seq int64) {
	if c == nil {
		return
	}
	c.rdb.Set(ctx, readKey(uid, convID), strconv.FormatInt(seq, 10), metaTTL)
}

// BloomKey 幂等布隆的复合键: 幂等约束是 (conv_id, client_msg_id),
// 布隆键必须同构 —— 全局 client_msg_id 不保证唯一 (客户端各会话独立生成)。
func BloomKey(convID, clientMsgID int64) uint64 {
	var buf [16]byte
	binary.LittleEndian.PutUint64(buf[:8], uint64(convID))
	binary.LittleEndian.PutUint64(buf[8:], uint64(clientMsgID))
	h := fnv.New64a()
	_, _ = h.Write(buf[:])
	return h.Sum64()
}

// ---- sync 水位分配 (里程碑8: BumpSyncSeq 从 seq RPC 降到 Redis INCR) ----
//
// 水位 = 用户"有新事件"计数器, 只用于触发客户端 SYNC, 不是消息序号 ——
// 重复/跳号无害, 单调即可。所以可以放进 Redis: INCR 是原子单调的,
// 异步回写 DB (seq_segment, GREATEST 保单调) 后 seq svc 退化为降级路径。
// Redis 丢失的恢复: 按 floor 重新播种 (floor = DB 水位 + margin), 容忍空洞。

func syncSeqKey(uid int64) string { return fmt.Sprintf("syncseq:%d", uid) }

// syncSeqScript: INCR 后若低于 floor 则抬到 floor (冷启动播种防回归)。
// 多进程并发播种最坏重复一个值 —— 水位是提示不是序号, 可容忍。
var syncSeqScript = redis.NewScript(`
local v = redis.call('INCR', KEYS[1])
if v < tonumber(ARGV[1]) then
	redis.call('SET', KEYS[1], ARGV[1])
	v = tonumber(ARGV[1])
end
return v
`)

// SyncSeqBump 原子推进用户水位, 返回新值。floor = 本进程已知的安全下界
// (DB 水位 + 播种余量), 传 0 表示纯 INCR (键不存在时从 1 开始, 仅测试用)。
func (c *Cache) SyncSeqBump(ctx context.Context, uid, floor int64) (int64, error) {
	if c == nil {
		return 0, redis.ErrClosed
	}
	return syncSeqScript.Run(ctx, c.rdb, []string{syncSeqKey(uid)}, floor).Int64()
}

// SyncSeqGet 读当前水位, found=false = 键不存在或 Redis 故障 (调用方回退)。
func (c *Cache) SyncSeqGet(ctx context.Context, uid int64) (int64, bool) {
	if c == nil {
		return 0, false
	}
	v, err := c.rdb.Get(ctx, syncSeqKey(uid)).Int64()
	if err != nil {
		return 0, false
	}
	return v, true
}

// ---- comet 路由表 (里程碑8: route:{uid} 替换星型广播空查) ----
//
// route:{uid} = SET{comet RPC addr}: uid 的在线连接分布在哪些 comet 实例上。
// 值即实例地址, SREM 天然不会误删他实例的登记; 多端在不同实例 = SET 多成员。
// TTL 兜底泄漏 (心跳续期); Redis 不可用时投递侧回退全实例广播。

func routeKey(uid int64) string { return fmt.Sprintf("route:%d", uid) }

const routeTTL = 60 * time.Second // 心跳 30s, 双倍余量

// RouteChangeChannel 路由变更失效流 (16 里程碑: message/job 侧 routeCache
// 本地缓存的订阅频道)。发布 best-effort —— 丢失由读侧 miss 播种 + 推送
// 全败回退广播兜底, 与 TTL 兜底同构。
const RouteChangeChannel = "route:change"

// publishRouteChange 变更广播 (SADD/SREM 后调用, RouteTouch 不发 ——
// 心跳只续 TTL, 集合成员没变)。
func (c *Cache) publishRouteChange(ctx context.Context, op string, uid int64, addr string) {
	_ = c.rdb.Publish(ctx, RouteChangeChannel, fmt.Sprintf("%s %d %s", op, uid, addr)).Err()
}

// RouteAdd 登记 uid 在 addr 实例上在线 (首连时调用, 幂等)。
func (c *Cache) RouteAdd(ctx context.Context, uid int64, addr string) {
	if c == nil {
		return
	}
	c.rdb.SAdd(ctx, routeKey(uid), addr)
	c.rdb.Expire(ctx, routeKey(uid), routeTTL)
	c.publishRouteChange(ctx, "add", uid, addr)
}

// RouteTouch 心跳续期 (TTL 快到期的路由若不刷新, 投递侧会误回退广播)。
func (c *Cache) RouteTouch(ctx context.Context, uid int64) {
	if c == nil {
		return
	}
	c.rdb.Expire(ctx, routeKey(uid), routeTTL)
}

// RouteRem 注销 (末断时调用)。SREM 按成员值删, 只动自己实例的登记。
func (c *Cache) RouteRem(ctx context.Context, uid int64, addr string) {
	if c == nil {
		return
	}
	c.rdb.SRem(ctx, routeKey(uid), addr)
	c.publishRouteChange(ctx, "rem", uid, addr)
}

// RouteRemLast 注销并报告该 uid 是否已无任何实例登记 (最后一个实例的最后一
// 条连接断开 → 应发离线事件)。多端/多实例仍在线时返回 false。
func (c *Cache) RouteRemLast(ctx context.Context, uid int64, addr string) bool {
	if c == nil {
		return false
	}
	c.rdb.SRem(ctx, routeKey(uid), addr)
	c.publishRouteChange(ctx, "rem", uid, addr)
	n, err := c.rdb.SCard(ctx, routeKey(uid)).Result()
	return err == nil && n == 0
}

// RouteGet 查 uid 在线实例列表; ok=false = 键不存在/Redis 故障 (调用方回退广播)。
func (c *Cache) RouteGet(ctx context.Context, uid int64) ([]string, bool) {
	if c == nil {
		return nil, false
	}
	addrs, err := c.rdb.SMembers(ctx, routeKey(uid)).Result()
	if err != nil || len(addrs) == 0 {
		return nil, false
	}
	return addrs, true
}

// RouteOnlineBatch 批量在线判定 (Relation Svc GetPresence 用): key 存在即在线。
// nil-Cache / Redis 故障 → 全 false (显示保守, 不影响功能)。
func (c *Cache) RouteOnlineBatch(ctx context.Context, uids []int64) map[int64]bool {
	out := make(map[int64]bool, len(uids))
	if c == nil {
		return out
	}
	pipe := c.rdb.Pipeline()
	cmds := make([]*redis.IntCmd, len(uids))
	for i, uid := range uids {
		cmds[i] = pipe.Exists(ctx, routeKey(uid))
	}
	_, _ = pipe.Exec(ctx)
	for i, cmd := range cmds {
		out[uids[i]] = cmd.Err() == nil && cmd.Val() > 0
	}
	return out
}

// ---- 用户资料 (Relation Svc 读缓存) ----

// Profile 资料缓存值 (relation 域的 users 行投影; 与 yim.UserProfile 解耦,
// cache 包不依赖 kitex_gen)。
type Profile struct {
	Nickname string `json:"nickname"`
	Avatar   string `json:"avatar"`
}

func profileKey(uid int64) string { return fmt.Sprintf("profile:%d", uid) }

// GetProfile found=false = miss/Redis 故障 (调用方回源 DB)。
func (c *Cache) GetProfile(ctx context.Context, uid int64) (Profile, bool) {
	var p Profile
	if c == nil {
		return p, false
	}
	b, err := c.rdb.Get(ctx, profileKey(uid)).Bytes()
	if err != nil || json.Unmarshal(b, &p) != nil {
		return Profile{}, false
	}
	return p, true
}

func (c *Cache) SetProfile(ctx context.Context, uid int64, p Profile) {
	if c == nil {
		return
	}
	if b, err := json.Marshal(p); err == nil {
		c.rdb.Set(ctx, profileKey(uid), b, metaTTL)
	}
}

func (c *Cache) InvalidateProfile(ctx context.Context, uid int64) {
	if c == nil {
		return
	}
	c.rdb.Del(ctx, profileKey(uid))
}

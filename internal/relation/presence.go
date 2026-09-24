// presence.go 在线状态查询 (连接级, 查询制不做订阅推送)。
//
// 数据源 = route:{uid} Redis SET (comet 心跳续期 60s TTL): key 存在且非空
// = 该 uid 在某实例上有活跃连接。语义边界: 精确到"实例上有无活跃连接",
// 不含"隐身/最后在线时间" (扩展位)。
// 降级: cache 为 nil / Redis 故障 → 全部 OFFLINE (显示保守, 不影响功能)。
package relation

import (
	"context"

	"github.com/yim/kitex_gen/yim"
)

func (s *Service) GetPresence(ctx context.Context, uids []int64) ([]*yim.PresenceInfo, *yim.Error) {
	if len(uids) > 50 {
		uids = uids[:50]
	}
	online := s.cache.RouteOnlineBatch(ctx, uids) // nil/故障 → 全 false
	out := make([]*yim.PresenceInfo, 0, len(uids))
	for _, uid := range uids {
		p := yim.Presence_PRESENCE_OFFLINE
		if online[uid] {
			p = yim.Presence_PRESENCE_ONLINE
		}
		out = append(out, &yim.PresenceInfo{Uid: uid, Presence: p})
	}
	return out, nil
}

// sync.go: SYNC 增量同步 (推拉协议的"拉"侧)。
//
// 语义: 客户端带各会话本地水位 (ConvWatermark), 服务端按差集拉增量。
// 全量场景 (新设备/水位缺失): 客户端不传 watermarks, 只拿当前 user_sync_seq
// 后自行按会话列表逐个 PullHistory (分页) —— 大数据量不压在单个 RPC 里。
package message

import (
	"context"
	"fmt"

	"google.golang.org/protobuf/encoding/protojson"

	"github.com/yim/internal/store"
	"github.com/yim/kitex_gen/yim"
)

// syncMax 单会话增量条数上限, 超出进 overflow (客户端转分页历史拉取)
const syncMax = 200

// Sync 计算 uid 的增量消息。
// overflow 里的 conv_id + last_seq: 该会话剩余增量太多, 客户端以 last_seq
// 为起点走 PULL_PAGE_BACKWARD 分页拉取。
func (s *Service) Sync(ctx context.Context, uid int64, watermarks []*yim.ConvWatermark) ([]*yim.ConvMessage, []*yim.ConvWatermark, error) {
	var (
		msgs     []*yim.ConvMessage
		overflow []*yim.ConvWatermark
	)
	for _, wm := range watermarks {
		if wm.GetConvId() == 0 {
			continue
		}
		page, hasMore, err := s.pullIncrement(ctx, wm.GetConvId(), wm.GetLastSeq(), syncMax)
		if err != nil {
			return nil, nil, fmt.Errorf("sync conv %d: %w", wm.GetConvId(), err)
		}
		msgs = append(msgs, page...)
		if hasMore && len(page) > 0 {
			// overflow 的 last_seq = 已返回部分的最大 seq, 客户端从这里续拉
			overflow = append(overflow, &yim.ConvWatermark{
				ConvId: wm.GetConvId(), LastSeq: page[len(page)-1].GetSeq(),
			})
		}
	}
	return msgs, overflow, nil
}

// pullIncrement 按会话拉 (last_seq, last_seq+n] 的增量, 升序。
// 与 PullHistory 同一个主键扫描路径: (conv_id, seq) 聚簇范围查。
func (s *Service) pullIncrement(ctx context.Context, convID, afterSeq int64, limit int) ([]*yim.ConvMessage, bool, error) {
	shard := store.RouteMsg(convID)
	db := s.db.ShardDB(shard)

	rows, err := db.QueryContext(ctx, fmt.Sprintf(
		"SELECT msg_id, from_uid, seq, content, server_time_ms FROM %s WHERE conv_id = ? AND seq > ? ORDER BY seq ASC LIMIT ?",
		shard.Table()), convID, afterSeq, limit+1) // 多取一条判 hasMore
	if err != nil {
		return nil, false, fmt.Errorf("pull increment: %w", err)
	}
	defer rows.Close()

	msgs := make([]*yim.ConvMessage, 0, limit)
	for rows.Next() {
		var (
			m       yim.ConvMessage
			content []byte
		)
		if err := rows.Scan(&m.MsgId, &m.FromUid, &m.Seq, &content, &m.ServerTimeMs); err != nil {
			return nil, false, fmt.Errorf("scan message: %w", err)
		}
		c := &yim.ConvMsgContent{}
		if err := protojson.Unmarshal(content, c); err != nil {
			return nil, false, fmt.Errorf("unmarshal content (msg_id=%d): %w", m.MsgId, err)
		}
		m.ConvId = convID
		m.Content = c
		msgs = append(msgs, &m)
	}
	if err := rows.Err(); err != nil {
		return nil, false, err
	}
	hasMore := false
	if len(msgs) > limit {
		hasMore = true
		msgs = msgs[:limit]
	}
	return msgs, hasMore, nil
}

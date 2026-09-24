package message

import (
	"context"
	"fmt"

	"google.golang.org/protobuf/encoding/protojson"

	"github.com/yim/internal/store"
	"github.com/yim/kitex_gen/yim"
)

// PullHistory 按 seq 倒序拉取一页历史消息, 返回升序 (UI 渲染顺序)。
//
// 翻页游标就是 seq: beforeSeq=0 表示从最新开始。
// 主键 (conv_id, seq) 聚簇有序, 范围扫描天然免回表 —— 这是选它做主键的核心收益。
//
// 读路径 (里程碑5): beforeSeq=0 (首屏/下拉刷新, 绝大多数请求) 先查
// recent ZSET; 整页命中直接返回, miss 回落 DB 并回填缓存。
// beforeSeq>0 (向更早翻页) 超出缓存窗口, 直接走 DB 不碰缓存。
//
// 成员校验 (里程碑9): op_uid 必须是会话成员 —— 网关已加 JWT, 但"登录"不等于
// "能读任意会话", 这里按 conv meta 的 member_uids 复核, 非成员拒绝 (code 25)。
// op_uid=0 视为内部调用 (comet SYNC 路径自持成员语义), 跳过校验。
func (s *Service) PullHistory(ctx context.Context, opUID, convID, beforeSeq int64, limit int) ([]*yim.ConvMessage, error) {
	if limit <= 0 || limit > 100 {
		limit = 50
	}
	if opUID > 0 {
		meta, err := s.cache.GetConvMeta(ctx, s.db, convID)
		if err != nil {
			return nil, fmt.Errorf("conv meta %d: %w", convID, err)
		}
		isMember := false
		for _, m := range meta.MemberUIDs {
			if m == opUID {
				isMember = true
				break
			}
		}
		if !isMember {
			return nil, ErrNotMember
		}
	}
	if beforeSeq == 0 {
		if msgs := s.recentFromCache(ctx, convID, limit); msgs != nil {
			return msgs, nil
		}
	}

	msgs, err := s.pullHistoryDB(ctx, convID, beforeSeq, limit)
	if err != nil {
		return nil, err
	}
	// 回填: 只在拉"最新窗口"时灌缓存, 翻旧页不回填 (不属于 recent 语义)
	if beforeSeq == 0 {
		s.fillRecent(ctx, convID, msgs)
	}
	return msgs, nil
}

// recentFromCache 整页命中才返回, 部分命中当 miss (避免缓存+DB 两截拼接错序)。
func (s *Service) recentFromCache(ctx context.Context, convID int64, limit int) []*yim.ConvMessage {
	vals := s.cache.RecentList(ctx, convID, int64(limit))
	if len(vals) != limit {
		return nil
	}
	msgs := make([]*yim.ConvMessage, 0, limit)
	for _, v := range vals {
		m := &yim.ConvMessage{}
		if protojson.Unmarshal(v, m) != nil {
			return nil // 坏值: 整页回落 DB
		}
		msgs = append(msgs, m)
	}
	return msgs
}

func (s *Service) fillRecent(ctx context.Context, convID int64, msgs []*yim.ConvMessage) {
	for _, m := range msgs {
		if b, err := protojson.Marshal(m); err == nil {
			s.cache.RecentAdd(ctx, convID, m.Seq, b)
		}
	}
}

func (s *Service) pullHistoryDB(ctx context.Context, convID, beforeSeq int64, limit int) ([]*yim.ConvMessage, error) {
	shard := store.RouteMsg(convID)
	db := s.db.ShardDB(shard)

	q := fmt.Sprintf(
		"SELECT msg_id, from_uid, seq, content, server_time_ms FROM %s WHERE conv_id = ?",
		shard.Table())
	args := []any{convID}
	if beforeSeq > 0 {
		q += " AND seq < ?"
		args = append(args, beforeSeq)
	}
	q += " ORDER BY seq DESC LIMIT ?"
	args = append(args, limit)

	rows, err := db.QueryContext(ctx, q, args...)
	if err != nil {
		return nil, fmt.Errorf("pull history: %w", err)
	}
	defer rows.Close()

	msgs := make([]*yim.ConvMessage, 0, limit)
	for rows.Next() {
		var (
			m       yim.ConvMessage
			content []byte
		)
		if err := rows.Scan(&m.MsgId, &m.FromUid, &m.Seq, &content, &m.ServerTimeMs); err != nil {
			return nil, fmt.Errorf("scan message: %w", err)
		}
		c := &yim.ConvMsgContent{}
		if err := protojson.Unmarshal(content, c); err != nil {
			return nil, fmt.Errorf("unmarshal content (msg_id=%d): %w", m.MsgId, err)
		}
		m.ConvId = convID
		m.Content = c
		msgs = append(msgs, &m)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows: %w", err)
	}

	// 倒序取页 → 反转成升序返回
	for i, j := 0, len(msgs)-1; i < j; i, j = i+1, j-1 {
		msgs[i], msgs[j] = msgs[j], msgs[i]
	}
	return msgs, nil
}

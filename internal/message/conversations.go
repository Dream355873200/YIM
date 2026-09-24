// 会话生命周期与用户侧视图 (里程碑5): CreateConv / ListConversations / MarkRead。
//
// 存储模型: conversations.member_uids 是 JSON 列, 无法按 uid 反查;
// user_conversations(uid, conv_id) 是发消息路径冗余写的倒排索引,
// 换来会话列表一次索引扫描。冗余写与主行同事务, 无一致性风险。
package message

import (
	"context"
	"encoding/json"
	"fmt"
	"sort"
	"strings"
	"time"

	"google.golang.org/protobuf/encoding/protojson"

	"github.com/yim/internal/cache"
	"github.com/yim/kitex_gen/yim"
)

// RelationClient 好友/群成员依赖 (Relation Svc client 适配)。
// nil = 跳过校验 (老部署滚动升级兼容, 启动日志警告); 生产装配必填 ——
// 好友关系是产品边界不是优化项, 校验 fail-close (relation 不可用 = 拒绝建单聊)。
type RelationClient interface {
	CheckFriendship(ctx context.Context, aUID, bUID int64) (bool, *yim.Error)
	AddGroupMembers(ctx context.Context, convID int64, memberUIDs []int64, ownerUID int64) *yim.Error
}

// UseRelation 装配 Relation Svc 依赖 (里程碑9)。
func (s *Service) UseRelation(rc RelationClient) { s.rel = rc }

// CreateConv 建会话。单聊以 (min_uid, max_uid) 查 single_chat_index 去重,
// 重复建返回已有会话; 群聊直接发号建群, 事务后调 Relation Svc 写群成员 seed
// (幂等 upsert, 失败返回错误可重试 —— 群无去重索引, 重复重试会建重复群,
// 已知债务见 service_relation.proto 头注释)。
func (s *Service) CreateConv(ctx context.Context, typ yim.ConvType, members []int64, ownerUID int64, name string) (*yim.Conv, bool, error) {
	// 参数收敛: 去重 + 排序 (member_uids 存储约定升序)
	seen := make(map[int64]struct{}, len(members))
	uniq := members[:0]
	for _, uid := range members {
		if uid <= 0 {
			return nil, false, fmt.Errorf("invalid uid %d", uid)
		}
		if _, dup := seen[uid]; !dup {
			seen[uid] = struct{}{}
			uniq = append(uniq, uid)
		}
	}
	members = uniq
	if typ == yim.ConvType_CONV_SINGLE {
		if len(members) != 2 {
			return nil, false, fmt.Errorf("single conv needs exactly 2 members, got %d", len(members))
		}
		sort.Slice(members, func(i, j int) bool { return members[i] < members[j] })

		// 好友校验 (里程碑9): 服务端强制, 任何入口都绕不过 —— 网关前置校验
		// 只能保护 HTTP 路径, RPC 调用方 (comet/内部服务) 同样要拦
		if s.rel != nil {
			if ok, bizErr := s.rel.CheckFriendship(ctx, members[0], members[1]); bizErr != nil {
				return nil, false, ErrNotFriends // fail-close: relation 不可用即拒绝
			} else if !ok {
				return nil, false, ErrNotFriends
			}
		}

		// 单聊去重: 索引命中即返回已有会话
		var existID int64
		err := s.db.Meta.QueryRowContext(ctx,
			"SELECT conv_id FROM single_chat_index WHERE a_uid = ? AND b_uid = ?",
			members[0], members[1]).Scan(&existID)
		if err == nil {
			meta, merr := s.cache.GetConvMeta(ctx, s.db, existID)
			if merr != nil {
				return nil, false, fmt.Errorf("load exist conv %d: %w", existID, merr)
			}
			return metaToProto(meta), true, nil
		}
		if err.Error() != "sql: no rows in result set" {
			return nil, false, fmt.Errorf("single chat index: %w", err)
		}
	} else if len(members) < 2 {
		return nil, false, fmt.Errorf("conv needs >= 2 members, got %d", len(members))
	} else {
		// 群名收敛 (里程碑11): 裁剪 + 限长, 缺省 "N人群" 由客户端起名, 服务端只兜底
		name = strings.TrimSpace(name)
		if len([]rune(name)) > 32 {
			name = string([]rune(name)[:32])
		}
	}

	convID, err := s.seqs.AllocID(ctx, "conv_id", 0, 1)
	if err != nil {
		return nil, false, fmt.Errorf("alloc conv_id: %w", err)
	}

	// 同事务: 会话主行 + 每成员倒排索引 (+单聊唯一索引, 重复建撞主键即并发去重)
	memberJSON, _ := json.Marshal(members)
	tx, err := s.db.Meta.BeginTx(ctx, nil)
	if err != nil {
		return nil, false, err
	}
	defer func() { _ = tx.Rollback() }()

	now := timeNowMs()
	if _, err = tx.ExecContext(ctx,
		"INSERT INTO conversations (conv_id, type, member_uids, last_seq, name) VALUES (?,?,?,?,?)",
		convID, int32(typ), memberJSON, 0, name); err != nil {
		return nil, false, fmt.Errorf("insert conv: %w", err)
	}
	for _, uid := range members {
		if _, err = tx.ExecContext(ctx,
			"INSERT IGNORE INTO user_conversations (uid, conv_id, create_time_ms) VALUES (?,?,?)",
			uid, convID, now); err != nil {
			return nil, false, fmt.Errorf("insert user_conv index: %w", err)
		}
	}
	if typ == yim.ConvType_CONV_SINGLE {
		if _, err = tx.ExecContext(ctx,
			"INSERT INTO single_chat_index (a_uid, b_uid, conv_id) VALUES (?,?,?)",
			members[0], members[1], convID); err != nil {
			return nil, false, fmt.Errorf("insert single chat index: %w", err)
		}
	}
	if err = tx.Commit(); err != nil {
		return nil, false, err
	}

	meta := &cache.ConvMeta{ConvID: convID, Type: int32(typ), MemberUIDs: members, LastSeq: 0, CreateTimeMs: now, Name: name}
	s.cache.SetConvMeta(ctx, meta)

	// 群成员 seed (里程碑9): conv 事务提交后写 group_members (幂等 upsert),
	// owner 行 role=1。失败返回错误 —— 会话已建 (孤儿状态), 重试会建重复群
	// (群聊无去重索引), 已知债务标注在 relation 侧
	if typ == yim.ConvType_CONV_GROUP && s.rel != nil {
		if bizErr := s.rel.AddGroupMembers(ctx, convID, members, ownerUID); bizErr != nil {
			return nil, false, fmt.Errorf("seed group members (conv %d created, members missing): %s",
				convID, bizErr.GetMsg())
		}
	}
	return metaToProto(meta), false, nil
}

// ListConversations 用户会话列表: 倒排索引分页 → 逐会话 (元数据 + 未读 + 预览)。
// 逐会话查询是 N+1, 命中 conv meta 缓存后 DB 压力可接受;
// 批量化 (IN 一次取回) 留给压测里程碑。
func (s *Service) ListConversations(ctx context.Context, uid int64, pageNum, pageSize int32) ([]*yim.ConversationBrief, bool, error) {
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}
	if pageNum <= 0 {
		pageNum = 1
	}
	offset := (int(pageNum) - 1) * int(pageSize)

	rows, err := s.db.Meta.QueryContext(ctx,
		"SELECT conv_id FROM user_conversations WHERE uid = ? ORDER BY conv_id DESC LIMIT ? OFFSET ?",
		uid, pageSize+1, offset) // 多取一条判 has_more
	if err != nil {
		return nil, false, fmt.Errorf("list user convs: %w", err)
	}
	defer rows.Close()

	var convIDs []int64
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			return nil, false, err
		}
		convIDs = append(convIDs, id)
	}
	if err := rows.Err(); err != nil {
		return nil, false, err
	}
	hasMore := false
	if len(convIDs) > int(pageSize) {
		hasMore = true
		convIDs = convIDs[:pageSize]
	}

	briefs := make([]*yim.ConversationBrief, 0, len(convIDs))
	for _, convID := range convIDs {
		meta, err := s.cache.GetConvMeta(ctx, s.db, convID)
		if err != nil {
			return nil, false, err
		}
		readSeq := s.getReadSeq(ctx, uid, convID)
		unread := meta.LastSeq - readSeq
		if unread < 0 {
			unread = 0 // read_seq 超前 (缓存可错) 时钳零
		}

		brief := &yim.ConversationBrief{
			Conv:        metaToProto(meta),
			UnreadCount: unread,
		}
		if lm := s.lastMessage(ctx, convID); lm != nil {
			brief.LastMessage = lm
		}
		briefs = append(briefs, brief)
	}
	return briefs, hasMore, nil
}

// MarkRead 推进已读水位: 只更新 user_conv_state, 不产生消息。
// GREATEST 防乱序 ACK 回退水位; read_seq 超过 last_seq 钳到 last_seq (未读数不为负)。
// 已读回执 (里程碑12): 单聊另发 ephemeral READ 信令给对端 (即发即弃,
// 丢了只是对方少看到"已读", 重进会话可重拉 —— 第一轮不做对端读水位的拉取兜底)。
func (s *Service) MarkRead(ctx context.Context, uid, convID, readSeq int64) error {
	meta, err := s.cache.GetConvMeta(ctx, s.db, convID)
	if err != nil {
		return fmt.Errorf("conv %d: %w", convID, err)
	}
	if readSeq > meta.LastSeq {
		readSeq = meta.LastSeq
	}
	_, err = s.db.Meta.ExecContext(ctx,
		"INSERT INTO user_conv_state (uid, conv_id, read_seq, update_time_ms) VALUES (?,?,?,?) "+
			"ON DUPLICATE KEY UPDATE read_seq = GREATEST(read_seq, VALUES(read_seq)), update_time_ms = VALUES(update_time_ms)",
		uid, convID, readSeq, time.Now().UnixMilli())
	if err != nil {
		return fmt.Errorf("mark read: %w", err)
	}
	s.cache.SetReadSeq(ctx, uid, convID, readSeq)
	if meta.Type == int32(yim.ConvType_CONV_SINGLE) {
		for _, m := range meta.MemberUIDs {
			if m == uid {
				continue
			}
			s.cache.PublishEphemeral(ctx, cache.EphemeralMsg{
				T: "read", Conv: convID, From: uid, To: m, Seq: readSeq,
			})
		}
	}
	return nil
}

// ---- 内部工具 ----

func (s *Service) getReadSeq(ctx context.Context, uid, convID int64) int64 {
	if v, ok := s.cache.GetReadSeq(ctx, uid, convID); ok {
		return v
	}
	var seq int64
	if err := s.db.Meta.QueryRowContext(ctx,
		"SELECT read_seq FROM user_conv_state WHERE uid = ? AND conv_id = ?", uid, convID).Scan(&seq); err != nil {
		return 0 // 无记录 = 从未读过, 水位 0
	}
	s.cache.SetReadSeq(ctx, uid, convID, seq)
	return seq
}

// lastMessage 会话列表预览: recent ZSET 取最高 seq, miss 回落 DB 取最新一条。
func (s *Service) lastMessage(ctx context.Context, convID int64) *yim.ConvMessage {
	if b := s.cache.RecentTop(ctx, convID); b != nil {
		m := &yim.ConvMessage{}
		if protojson.Unmarshal(b, m) == nil {
			return m
		}
	}
	msgs, err := s.pullHistoryDB(ctx, convID, 0, 1)
	if err != nil || len(msgs) == 0 {
		return nil
	}
	return msgs[0]
}

func metaToProto(m *cache.ConvMeta) *yim.Conv {
	return &yim.Conv{
		ConvId:       m.ConvID,
		Type:         yim.ConvType(m.Type),
		MemberUids:   m.MemberUIDs,
		LastSeq:      m.LastSeq,
		CreateTimeMs: m.CreateTimeMs,
		Name:         m.Name,
		Avatar:       m.Avatar,
	}
}

// search.go (里程碑13): 全局消息全文搜索。
//
// 形态: 用户全部会话的 MSG_TEXT LIKE 扫描, 逐分片并行查 + 内存按时间归并。
// 分库分表下 content 是 JSON 列, MySQL FULLTEXT 用不上 (ngram 索引也建不进
// JSON), ES/倒排是规模里程碑的事 —— 搜索低频只读, limit 硬顶 20, 全表扫描
// 的代价可控。关键词做 LIKE 转义 (% _ \), 防注入与通配符误伤。
package message

import (
	"context"
	"fmt"
	"sort"
	"strings"

	"github.com/yim/internal/store"
	"github.com/yim/kitex_gen/yim"
	"google.golang.org/protobuf/encoding/protojson"
)

func (s *Service) SearchMessages(ctx context.Context, uid int64, keyword string, limit int32) ([]*yim.ConvMessage, bool, error) {
	keyword = strings.TrimSpace(keyword)
	runes := []rune(keyword)
	if len(runes) == 0 {
		return nil, false, fmt.Errorf("keyword required")
	}
	if limit <= 0 || limit > 20 {
		limit = 20
	}

	// 用户会话集合: 倒排索引 (uid 一次索引扫描), 上限 200 个最近会话 ——
	// 再多的会话用户多半已不活跃, 第一轮不追求全量召回
	rows, err := s.db.Meta.QueryContext(ctx,
		"SELECT conv_id FROM user_conversations WHERE uid = ? ORDER BY conv_id DESC LIMIT 200", uid)
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
	if len(convIDs) == 0 {
		return nil, false, nil
	}

	pattern := "%" + likeEscape(keyword) + "%"
	shards := store.AllMsgShards()
	out := make([]*yim.ConvMessage, 0, int(limit))
	truncated := false
	for _, shard := range shards {
		db := s.db.ShardDB(shard)
		shardRows, err := db.QueryContext(ctx, fmt.Sprintf(
			"SELECT msg_id, conv_id, from_uid, seq, server_time_ms, content FROM %s "+
				"WHERE conv_id IN (%s) AND msg_type = 1 AND content LIKE ? "+
				"ORDER BY server_time_ms DESC LIMIT %d",
			shard.Table(), placeholders(len(convIDs)), limit+1),
			args(convIDs, pattern)...)
		if err != nil {
			return nil, false, fmt.Errorf("search shard %d: %w", shard, err)
		}
		for shardRows.Next() {
			var msgID, convID, fromUID, seq, ts int64
			var content []byte
			if err := shardRows.Scan(&msgID, &convID, &fromUID, &seq, &ts, &content); err != nil {
				shardRows.Close()
				return nil, false, err
			}
			// 与 pullHistoryDB 同构: content 列存的是 ConvMsgContent JSON,
			// 不能直接 unmarshal 进 ConvMessage; 扫出的列必须显式赋值
			// (否则返回空壳 {}, 客户端拿到的是无字段的消息)
			m := &yim.ConvMessage{
				MsgId: msgID, ConvId: convID, FromUid: fromUID, Seq: seq, ServerTimeMs: ts,
			}
			c := &yim.ConvMsgContent{}
			if err := protojson.Unmarshal(content, c); err != nil {
				continue // 毒丸行跳过
			}
			m.Content = c
			out = append(out, m)
		}
		shardRows.Close()
	}

	sort.Slice(out, func(i, j int) bool {
		if out[i].GetServerTimeMs() != out[j].GetServerTimeMs() {
			return out[i].GetServerTimeMs() > out[j].GetServerTimeMs()
		}
		return out[i].GetMsgId() > out[j].GetMsgId() // 同毫秒稳定序
	})
	if len(out) > int(limit) {
		out = out[:limit]
		truncated = true
	}
	return out, truncated, nil
}

// likeEscape LIKE 通配符与转义符本身: \ % _
func likeEscape(s string) string {
	r := strings.NewReplacer(`\`, `\\`, `%`, `\%`, `_`, `\_`)
	return r.Replace(s)
}

func placeholders(n int) string {
	return strings.TrimSuffix(strings.Repeat("?,", n), ",")
}

// args uid 列表在前, pattern 收尾 (与 SQL 参数序一致)
func args(convIDs []int64, pattern string) []any {
	out := make([]any, 0, len(convIDs)+1)
	for _, id := range convIDs {
		out = append(out, id)
	}
	return append(out, pattern)
}

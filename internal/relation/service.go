// Package relation: 关系域 (里程碑9) —— 好友 / 群成员 / 用户资料 / 在线状态。
//
// 数据全部落 yim_meta (与 users/conversations 同库)。
// 已知债务: 踢人/退群直写 message 域的 user_conversations / conversations
// (member_uids JSON) —— 同库共表换解耦, 避免 relation↔message 双向 RPC 依赖,
// 后续里程碑收口归属 (proto 头注释同步声明)。
//
// 降级约定 (与 cache 包一致): cache 为 nil 时资料不缓存、presence 全离线、
// 会话缓存不失效 —— 功能可用, 只是慢/显示保守。
package relation

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/store"
	"github.com/yim/kitex_gen/yim"
)

// 业务错误码 (proto 头注释同步维护)
const (
	CodeInternal       = 1  // 服务端内部错误 (DB 故障等)
	CodeAlreadyFriends = 20
	CodeRequestInvalid = 21
	CodeNotFriends     = 22
	CodeNotOwner       = 23
	CodeAlreadyMember  = 24
	CodeNotMember      = 25
	CodeRequestHandled = 26
	CodeNicknameTaken  = 27
)

var codeMsg = map[int32]string{
	CodeInternal:       "internal error",
	CodeAlreadyFriends: "already friends",
	CodeRequestInvalid: "friend request not found or forbidden",
	CodeNotFriends:     "not friends",
	CodeNotOwner:       "owner permission required",
	CodeAlreadyMember:  "already a member",
	CodeNotMember:      "not a member",
	CodeRequestHandled: "request already handled",
	CodeNicknameTaken:  "nickname already taken",
}

func bizErr(code int32) *yim.Error {
	msg := codeMsg[code]
	if msg == "" {
		msg = "unknown relation error"
	}
	return &yim.Error{Code: code, Msg: msg}
}

// Service 关系域业务。db.Meta = yim_meta (关系表与 users/conversations 同库)。
type Service struct {
	db    *store.MySQL
	cache *cache.Cache // 可为 nil: 降级形态 (资料不缓存/presence 全离线)
	pub   *EventProducer // 可为 nil: 未装配 Kafka = 事件推侧缺席 (纯拉取)
}

func NewService(db *store.MySQL, c *cache.Cache) *Service {
	return &Service{db: db, cache: c}
}

// SetEventProducer 装配事件生产者 (main; 装配后好友/群/在线事件实时可推)。
func (s *Service) SetEventProducer(p *EventProducer) { s.pub = p }

func nowMs() int64 { return time.Now().UnixMilli() }

var errNoRows = sql.ErrNoRows

// isFriend 双向好友判定。
func (s *Service) isFriend(ctx context.Context, a, b int64) (bool, error) {
	var one int
	err := s.db.Meta.QueryRowContext(ctx,
		"SELECT 1 FROM friendships WHERE (uid=? AND friend_uid=?) OR (uid=? AND friend_uid=?) LIMIT 1",
		a, b, b, a).Scan(&one)
	if errors.Is(err, sql.ErrNoRows) {
		return false, nil
	}
	if err != nil {
		return false, fmt.Errorf("check friendship: %w", err)
	}
	return true, nil
}

// mutateConvMembers 在事务内更新 conversations.member_uids JSON
// (同库共表, 已知债务)。add 追加 (已存在不重复); remove>0 剔除。
// 缓存失效由调用方在 tx.Commit() 之后执行。
func mutateConvMembers(ctx context.Context, tx *sql.Tx, convID int64, add []int64, remove int64) error {
	var raw []byte
	if err := tx.QueryRowContext(ctx,
		"SELECT member_uids FROM conversations WHERE conv_id=?", convID).Scan(&raw); err != nil {
		return fmt.Errorf("load conv %d: %w", convID, err)
	}
	var members []int64
	if err := json.Unmarshal(raw, &members); err != nil {
		return fmt.Errorf("parse member_uids conv %d: %w", convID, err)
	}

	if remove > 0 {
		next := members[:0]
		for _, m := range members {
			if m != remove {
				next = append(next, m)
			}
		}
		members = next
	}
	for _, a := range add {
		exists := false
		for _, m := range members {
			if m == a {
				exists = true
				break
			}
		}
		if !exists {
			members = append(members, a)
		}
	}

	b, err := json.Marshal(members)
	if err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx,
		"UPDATE conversations SET member_uids=? WHERE conv_id=?", b, convID); err != nil {
		return fmt.Errorf("update member_uids conv %d: %w", convID, err)
	}
	// 缓存失效由调用方在 tx.Commit() 之后做 (提前失效会被并发读回灌旧值)
	return nil
}

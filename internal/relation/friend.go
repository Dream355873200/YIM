// friend.go 好友关系: 申请状态机 / 列表 / 删除 / 判定。
//
// 申请状态机 (friend_requests 行内翻转, 主键 (from_uid,to_uid) 天然幂等):
//
//	pending(0) --accept--> accepted(1)   (同事务写双向 friendships)
//	pending(0) --reject--> rejected(2)   (可重新申请, 翻回 pending)
//	重复申请: pending 幂等返回 / rejected 翻回 pending / accepted 不会到达
//	          (入口先查 friendships, 已是好友直接 code 20)
//	互为 pending: A→B 申请时发现 B→A 也 pending → 双双置 accepted + 写
//	              friendships (互相加对方的场景不需要两个人各点一次同意)
//	删好友: 删 friendships 双行, 申请历史保留 → 重加 = 正常申请流程
package relation

import (
	"context"
	"database/sql"
	"errors"

	"github.com/yim/kitex_gen/yim"
)

// SendFriendRequest 发申请。
func (s *Service) SendFriendRequest(ctx context.Context, fromUID, toUID int64, message string) *yim.Error {
	if fromUID == toUID {
		return &yim.Error{Code: CodeRequestInvalid, Msg: "cannot add yourself"}
	}
	// 已是好友 (双向查)
	if ok, err := s.isFriend(ctx, fromUID, toUID); err != nil {
		return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	} else if ok {
		return bizErr(CodeAlreadyFriends)
	}

	// 互为 pending → 自动合并 (B 已向 A 发过申请, A 这次申请等价于同意)
	var status int32
	err := s.db.Meta.QueryRowContext(ctx,
		"SELECT status FROM friend_requests WHERE from_uid=? AND to_uid=?",
		toUID, fromUID).Scan(&status)
	if err == nil && status == 0 {
		if biz := s.HandleFriendRequest(ctx, toUID, fromUID, true); biz != nil {
			return biz
		}
		return nil // 已互相成为好友
	}

	now := nowMs()
	_, err = s.db.Meta.ExecContext(ctx,
		"INSERT INTO friend_requests (from_uid,to_uid,message,status,create_time_ms,update_time_ms) "+
			"VALUES (?,?,?,0,?,?) "+
			"ON DUPLICATE KEY UPDATE status=IF(status=2,0,status), message=VALUES(message), update_time_ms=VALUES(update_time_ms)",
		fromUID, toUID, message, now, now)
	if err != nil {
		return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	}
	s.pub.Emit(EvFriendRequest, fromUID, 0, toUID) // 收件方实时角标 (推侧)
	return nil
}

// HandleFriendRequest 处理申请: 仅 to_uid 可操作 pending 行。
func (s *Service) HandleFriendRequest(ctx context.Context, opUID, fromUID int64, accept bool) *yim.Error {
	tx, err := s.db.Meta.BeginTx(ctx, nil)
	if err != nil {
		return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	}
	defer func() { _ = tx.Rollback() }()

	var status int32
	err = tx.QueryRowContext(ctx,
		"SELECT status FROM friend_requests WHERE from_uid=? AND to_uid=? FOR UPDATE",
		fromUID, opUID).Scan(&status)
	if errors.Is(err, sql.ErrNoRows) {
		return bizErr(CodeRequestInvalid)
	}
	if err != nil {
		return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	}
	if status != 0 {
		return bizErr(CodeRequestHandled)
	}

	next := int32(2) // rejected
	if accept {
		next = 1
	}
	if _, err := tx.ExecContext(ctx,
		"UPDATE friend_requests SET status=?, update_time_ms=? WHERE from_uid=? AND to_uid=?",
		next, nowMs(), fromUID, opUID); err != nil {
		return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	}
	if accept {
		// 双向 friendships, INSERT IGNORE (并发同意幂等)
		now := nowMs()
		for _, pair := range [][2]int64{{opUID, fromUID}, {fromUID, opUID}} {
			if _, err := tx.ExecContext(ctx,
				"INSERT IGNORE INTO friendships (uid,friend_uid,create_time_ms) VALUES (?,?,?)",
				pair[0], pair[1], now); err != nil {
				return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
			}
		}
	}
	if err := tx.Commit(); err != nil {
		return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	}
	if accept {
		// 申请人实时看到"已同意" → 好友列表刷新 (推侧)
		s.pub.Emit(EvFriendHandled, opUID, 0, fromUID)
	}
	return nil
}

// ListFriendRequests 申请列表: incoming=收到的 / 发出的。clamp 100。
func (s *Service) ListFriendRequests(ctx context.Context, uid int64, incoming bool) ([]*yim.FriendRequest, *yim.Error) {
	q := "SELECT from_uid,to_uid,message,status,create_time_ms FROM friend_requests WHERE "
	if incoming {
		q += "to_uid=?"
	} else {
		q += "from_uid=?"
	}
	q += " ORDER BY update_time_ms DESC LIMIT 100"
	rows, err := s.db.Meta.QueryContext(ctx, q, uid)
	if err != nil {
		return nil, &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	}
	defer rows.Close()

	out := make([]*yim.FriendRequest, 0, 16)
	for rows.Next() {
		var r yim.FriendRequest
		if err := rows.Scan(&r.FromUid, &r.ToUid, &r.Message, &r.Status, &r.CreateTimeMs); err != nil {
			return nil, &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
		}
		out = append(out, &r)
	}
	return out, nil
}

// ListFriends 好友列表 (PK 前缀), 附资料。
func (s *Service) ListFriends(ctx context.Context, uid int64, pageNum, pageSize int32) ([]*yim.FriendBrief, bool, *yim.Error) {
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 50
	}
	if pageNum <= 0 {
		pageNum = 1
	}
	rows, err := s.db.Meta.QueryContext(ctx,
		"SELECT friend_uid, create_time_ms FROM friendships WHERE uid=? ORDER BY create_time_ms DESC LIMIT ? OFFSET ?",
		uid, pageSize+1, (pageNum-1)*pageSize)
	if err != nil {
		return nil, false, &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	}
	defer rows.Close()

	uids := make([]int64, 0, pageSize)
	times := make(map[int64]int64)
	for rows.Next() {
		var fu, t int64
		if err := rows.Scan(&fu, &t); err != nil {
			return nil, false, &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
		}
		uids = append(uids, fu)
		times[fu] = t
	}
	hasMore := len(uids) > int(pageSize)
	if hasMore {
		uids = uids[:pageSize]
	}

	profiles, perr := s.GetProfiles(ctx, uids)
	if perr != nil {
		return nil, false, perr
	}
	byUID := make(map[int64]*yim.UserProfile, len(profiles))
	for _, p := range profiles {
		byUID[p.Uid] = p
	}
	out := make([]*yim.FriendBrief, 0, len(uids))
	for _, fu := range uids {
		b := &yim.FriendBrief{Uid: fu, CreateTimeMs: times[fu]}
		if p := byUID[fu]; p != nil {
			b.Nickname = p.Nickname
			b.Avatar = p.Avatar
		}
		out = append(out, b)
	}
	return out, hasMore, nil
}

// DeleteFriend 删好友: 双向行同事务删, 申请历史保留。
func (s *Service) DeleteFriend(ctx context.Context, opUID, friendUID int64) *yim.Error {
	tx, err := s.db.Meta.BeginTx(ctx, nil)
	if err != nil {
		return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	}
	defer func() { _ = tx.Rollback() }()
	for _, pair := range [][2]int64{{opUID, friendUID}, {friendUID, opUID}} {
		if _, err := tx.ExecContext(ctx,
			"DELETE FROM friendships WHERE uid=? AND friend_uid=?", pair[0], pair[1]); err != nil {
			return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
		}
	}
	if err := commitTx(tx); err != nil {
		return err
	}
	s.pub.Emit(EvFriendDeleted, opUID, 0, friendUID) // 被删方实时移除 (推侧)
	return nil
}

// CheckFriendship Message Svc CreateConv 单聊校验专用 (fail-close: 出错按非好友)。
func (s *Service) CheckFriendship(ctx context.Context, a, b int64) (bool, *yim.Error) {
	ok, err := s.isFriend(ctx, a, b)
	if err != nil {
		return false, &yim.Error{Code: CodeNotFriends, Msg: err.Error()}
	}
	return ok, nil
}

func commitTx(tx *sql.Tx) *yim.Error {
	if err := tx.Commit(); err != nil {
		return &yim.Error{Code: CodeRequestInvalid, Msg: err.Error()}
	}
	return nil
}

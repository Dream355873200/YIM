// group.go 群成员管理: 建群 seed / 拉人 / 踢人 / 退群 / 成员列表。
//
// 权限模型 (第一轮): 只有 owner(role=1) 能拉人/踢人; 群主不可退群
// (转让/解散是后续里程碑)。所有变更同事务同步 message 域的
// user_conversations + conversations.member_uids (同库共表, 已知债务),
// 保证投递扇出与会话列表立即可见。
package relation

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"

	"github.com/yim/kitex_gen/yim"
)

// AddGroupMembers 拉人 + 建群 seed 共用, 幂等 upsert。
// ownerUID = 操作者: 群尚无成员 (建群) 时操作者即群主, 其行 role=1;
// 群已存在时操作者必须是群主 (code 23) —— 拉人权限收口在这里,
// 网关只透传 token 身份。
func (s *Service) AddGroupMembers(ctx context.Context, convID int64, memberUIDs []int64, ownerUID int64) *yim.Error {
	tx, err := s.db.Meta.BeginTx(ctx, nil)
	if err != nil {
		return bizErrDB(err)
	}
	defer func() { _ = tx.Rollback() }()

	// 群是否已 seed (决定建群语义 vs 拉人权限校验)
	var count int
	if err := tx.QueryRowContext(ctx,
		"SELECT COUNT(*) FROM group_members WHERE conv_id=?", convID).Scan(&count); err != nil {
		return bizErrDB(err)
	}
	if count > 0 {
		role, rerr := s.memberRole(ctx, convID, ownerUID)
		if rerr != nil {
			return bizErrDB(rerr)
		}
		if role != 1 {
			return bizErr(CodeNotOwner)
		}
	}
	now := nowMs()
	for _, uid := range memberUIDs {
		role := int32(0)
		if count == 0 && uid == ownerUID {
			role = 1
		}
		if _, err := tx.ExecContext(ctx,
			"INSERT INTO group_members (conv_id,uid,role,join_time_ms) VALUES (?,?,?,?) "+
				"ON DUPLICATE KEY UPDATE role=GREATEST(role,VALUES(role))",
			convID, uid, role, now); err != nil {
			return bizErrDB(err)
		}
		// 会话倒排索引 (ListConversations 依赖), 幂等
		if _, err := tx.ExecContext(ctx,
			"INSERT IGNORE INTO user_conversations (uid,conv_id,create_time_ms) VALUES (?,?,?)",
			uid, convID, now); err != nil {
			return bizErrDB(err)
		}
	}
	if count == 0 {
		// 首次 seed: owner 必然在 member_uids 里 (CreateConv 传入), 兜底校验
		found := false
		for _, uid := range memberUIDs {
			if uid == ownerUID {
				found = true
				break
			}
		}
		if !found {
			return bizErr(CodeNotOwner)
		}
	}
	if err := mutateConvMembers(ctx, tx, convID, memberUIDs, 0); err != nil {
		return bizErrDB(err)
	}
	if err := tx.Commit(); err != nil {
		return bizErrDB(err)
	}
	s.cache.InvalidateConv(ctx, convID)
	// 全体成员 (含新拉的人) 实时刷新成员列表 (推侧)
	targets := append([]int64{ownerUID}, memberUIDs...)
	s.pub.Emit(EvGroupChanged, ownerUID, convID, targets...)
	return nil
}

// RemoveGroupMember 群主踢人。
func (s *Service) RemoveGroupMember(ctx context.Context, opUID, convID, targetUID int64) *yim.Error {
	if opUID == targetUID {
		// 自己退群走 QuitGroup (群主不可退语义在那边)
		return bizErr(CodeNotOwner)
	}
	role, err := s.memberRole(ctx, convID, opUID)
	if err != nil {
		return bizErrDB(err)
	}
	if role != 1 {
		return bizErr(CodeNotOwner)
	}
	if biz := s.removeMember(ctx, convID, targetUID); biz != nil {
		return biz
	}
	// 存量成员 + 被踢者 实时刷新 (推侧)
	s.pub.Emit(EvGroupChanged, opUID, convID, s.memberUIDsOf(ctx, convID, targetUID)...)
	return nil
}

// QuitGroup 退群: 群主不可退 (code 23)。
func (s *Service) QuitGroup(ctx context.Context, uid, convID int64) *yim.Error {
	role, err := s.memberRole(ctx, convID, uid)
	if err != nil {
		return bizErrDB(err)
	}
	if role == 1 {
		return bizErr(CodeNotOwner) // 群主不可退群
	}
	if role == 0 && !s.isMember(ctx, convID, uid) {
		return bizErr(CodeNotMember)
	}
	if biz := s.removeMember(ctx, convID, uid); biz != nil {
		return biz
	}
	// 存量成员 + 退群者 实时刷新 (推侧)
	s.pub.Emit(EvGroupChanged, uid, convID, s.memberUIDsOf(ctx, convID, uid)...)
	return nil
}

// removeMember 删成员三件套 (同事务): group_members 行 + user_conversations 行
// + conversations.member_uids JSON。
func (s *Service) removeMember(ctx context.Context, convID, uid int64) *yim.Error {
	tx, err := s.db.Meta.BeginTx(ctx, nil)
	if err != nil {
		return bizErrDB(err)
	}
	defer func() { _ = tx.Rollback() }()

	if _, err := tx.ExecContext(ctx,
		"DELETE FROM group_members WHERE conv_id=? AND uid=?", convID, uid); err != nil {
		return bizErrDB(err)
	}
	if _, err := tx.ExecContext(ctx,
		"DELETE FROM user_conversations WHERE uid=? AND conv_id=?", uid, convID); err != nil {
		return bizErrDB(err)
	}
	if err := mutateConvMembers(ctx, tx, convID, nil, uid); err != nil {
		return bizErrDB(err)
	}
	if err := tx.Commit(); err != nil {
		return bizErrDB(err)
	}
	s.cache.InvalidateConv(ctx, convID)
	return nil
}

// UpdateGroupInfo 改群信息 (里程碑11): 仅群主; 空串字段不覆盖 (protojson
// 缺省字段到 Go 也是零值, 语义约定为"不更新")。直写 message 域 conversations
// (同库共表, 已知债务), 写完 InvalidateConv 让 ConvMeta 缓存回源。
func (s *Service) UpdateGroupInfo(ctx context.Context, opUID, convID int64, name, avatar string) *yim.Error {
	role, err := s.memberRole(ctx, convID, opUID)
	if err != nil {
		return bizErrDB(err)
	}
	if role != 1 {
		return bizErr(CodeNotOwner)
	}
	name = strings.TrimSpace(name)
	if len([]rune(name)) > 32 {
		name = string([]rune(name)[:32]) // 与建群同策略: 裁剪不报错
	}
	if name == "" && avatar == "" {
		return nil // nothing to do
	}
	var res sql.Result
	if name != "" && avatar != "" {
		res, err = s.db.Meta.ExecContext(ctx,
			"UPDATE conversations SET name=?, avatar=? WHERE conv_id=?", name, avatar, convID)
	} else if name != "" {
		res, err = s.db.Meta.ExecContext(ctx,
			"UPDATE conversations SET name=? WHERE conv_id=?", name, convID)
	} else {
		res, err = s.db.Meta.ExecContext(ctx,
			"UPDATE conversations SET avatar=? WHERE conv_id=?", avatar, convID)
	}
	if err != nil {
		return bizErrDB(err)
	}
	if n, _ := res.RowsAffected(); n == 0 {
		return bizErr(CodeNotMember) // 群不存在
	}
	s.cache.InvalidateConv(ctx, convID)
	// 群信息变了 → 存量成员实时刷新会话列表/聊天头 (推侧)
	s.pub.Emit(EvGroupChanged, opUID, convID, s.memberUIDsOf(ctx, convID, 0)...)
	return nil
}

// ListGroupMembers 成员列表 (含 role 与资料)。
func (s *Service) ListGroupMembers(ctx context.Context, convID int64) ([]*yim.GroupMember, *yim.Error) {
	rows, err := s.db.Meta.QueryContext(ctx,
		"SELECT uid, role, join_time_ms FROM group_members WHERE conv_id=? ORDER BY role DESC, join_time_ms",
		convID)
	if err != nil {
		return nil, bizErrDB(err)
	}
	defer rows.Close()

	type rawMember struct {
		uid  int64
		role int32
		t    int64
	}
	raws := make([]rawMember, 0, 16)
	uids := make([]int64, 0, 16)
	for rows.Next() {
		var m rawMember
		if err := rows.Scan(&m.uid, &m.role, &m.t); err != nil {
			return nil, bizErrDB(err)
		}
		raws = append(raws, m)
		uids = append(uids, m.uid)
	}
	profiles, perr := s.GetProfiles(ctx, uids)
	if perr != nil {
		return nil, perr
	}
	byUID := make(map[int64]*yim.UserProfile, len(profiles))
	for _, p := range profiles {
		byUID[p.Uid] = p
	}
	out := make([]*yim.GroupMember, 0, len(raws))
	for _, m := range raws {
		gm := &yim.GroupMember{Uid: m.uid, Role: m.role, JoinTimeMs: m.t}
		if p := byUID[m.uid]; p != nil {
			gm.Nickname = p.Nickname
			gm.Avatar = p.Avatar
		}
		out = append(out, gm)
	}
	return out, nil
}

// memberRole 查成员角色; 非成员返回 0 (与普通成员同值, 需 isMember 区分)。
func (s *Service) memberRole(ctx context.Context, convID, uid int64) (int32, error) {
	var role int32
	err := s.db.Meta.QueryRowContext(ctx,
		"SELECT role FROM group_members WHERE conv_id=? AND uid=?", convID, uid).Scan(&role)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, nil
	}
	if err != nil {
		return 0, fmt.Errorf("member role: %w", err)
	}
	return role, nil
}

func (s *Service) isMember(ctx context.Context, convID, uid int64) bool {
	var one int
	err := s.db.Meta.QueryRowContext(ctx,
		"SELECT 1 FROM group_members WHERE conv_id=? AND uid=?", convID, uid).Scan(&one)
	return err == nil
}

func bizErrDB(err error) *yim.Error {
	return &yim.Error{Code: CodeInternal, Msg: err.Error()}
}

// profile.go 用户资料: 批量查 (会话列表/聊天头渲染) + 改 (昵称/头像)。
//
// 缓存: profile:{uid} JSON TTL 10min, UpdateProfile 主动失效
// (cache.go 的 Profile 结构, nil-Cache 降级直查 DB)。
package relation

import (
	"context"
	"database/sql"
	"errors"
	"strings"

	"github.com/go-sql-driver/mysql"
	"github.com/yim/internal/cache"
	"github.com/yim/kitex_gen/yim"
)

// GetProfiles 批量查资料, clamp 50。
func (s *Service) GetProfiles(ctx context.Context, uids []int64) ([]*yim.UserProfile, *yim.Error) {
	if len(uids) > 50 {
		uids = uids[:50]
	}
	out := make([]*yim.UserProfile, 0, len(uids))
	var missed []int64
	byUID := make(map[int64]*yim.UserProfile, len(uids))
	for _, uid := range uids {
		if uid <= 0 {
			continue
		}
		if p, ok := s.cache.GetProfile(ctx, uid); ok {
			byUID[uid] = &yim.UserProfile{Uid: uid, Nickname: p.Nickname, Avatar: p.Avatar}
		} else {
			missed = append(missed, uid)
		}
	}
	if len(missed) > 0 {
		args := make([]any, len(missed))
		ph := strings.TrimRight(strings.Repeat("?,", len(missed)), ",")
		for i, uid := range missed {
			args[i] = uid
		}
		rows, err := s.db.Meta.QueryContext(ctx,
			"SELECT uid, nickname, avatar FROM users WHERE uid IN ("+ph+")", args...)
		if err != nil {
			return nil, &yim.Error{Code: CodeInternal, Msg: err.Error()}
		}
		defer rows.Close()
		for rows.Next() {
			var uid int64
			var nick, avatar string
			if err := rows.Scan(&uid, &nick, &avatar); err != nil {
				return nil, &yim.Error{Code: CodeInternal, Msg: err.Error()}
			}
			p := &yim.UserProfile{Uid: uid, Nickname: nick, Avatar: avatar}
			byUID[uid] = p
			s.cache.SetProfile(ctx, uid, cache.Profile{Nickname: nick, Avatar: avatar})
		}
	}
	for _, uid := range uids {
		if p := byUID[uid]; p != nil {
			out = append(out, p)
		}
	}
	return out, nil
}

// SearchUsers 加好友搜索: 纯数字 keyword = uid 精确 OR 昵称前缀; 否则昵称前缀。
// 排除操作者自己, limit clamp 20, 空 keyword 返回空列表 (客户端展示"没有匹配")。
func (s *Service) SearchUsers(ctx context.Context, keyword string, opUID int64, limit int) ([]*yim.UserProfile, *yim.Error) {
	keyword = strings.TrimSpace(keyword)
	if keyword == "" {
		return []*yim.UserProfile{}, nil
	}
	if limit <= 0 || limit > 20 {
		limit = 20
	}
	// LIKE 转义 % _ \, 前缀匹配
	esc := strings.NewReplacer(`\`, `\\`, `%`, `\%`, `_`, `\_`).Replace(keyword)
	pattern := esc + "%"

	numeric := true
	for _, r := range keyword {
		if r < '0' || r > '9' {
			numeric = false
			break
		}
	}

	var (
		rows *sql.Rows
		err  error
	)
	if numeric {
		// uid 精确 OR 昵称前缀, 合并去重由 scan 层 map 完成
		rows, err = s.db.Meta.QueryContext(ctx,
			"SELECT uid, nickname, avatar FROM users WHERE (uid = ? OR nickname LIKE ?) AND uid <> ? LIMIT ?",
			keyword, pattern, opUID, limit)
	} else {
		rows, err = s.db.Meta.QueryContext(ctx,
			"SELECT uid, nickname, avatar FROM users WHERE nickname LIKE ? AND uid <> ? LIMIT ?",
			pattern, opUID, limit)
	}
	if err != nil {
		return nil, &yim.Error{Code: CodeInternal, Msg: err.Error()}
	}
	defer rows.Close()

	out := make([]*yim.UserProfile, 0, limit)
	seen := make(map[int64]struct{}, limit)
	for rows.Next() {
		var uid int64
		var nick, avatar string
		if err := rows.Scan(&uid, &nick, &avatar); err != nil {
			return nil, &yim.Error{Code: CodeInternal, Msg: err.Error()}
		}
		if _, dup := seen[uid]; dup {
			continue
		}
		seen[uid] = struct{}{}
		out = append(out, &yim.UserProfile{Uid: uid, Nickname: nick, Avatar: avatar})
		if len(out) >= limit {
			break
		}
	}
	return out, nil
}

// UpdateProfile 改昵称/头像 (空串 = 不改)。
func (s *Service) UpdateProfile(ctx context.Context, uid int64, nickname, avatar string) (*yim.UserProfile, *yim.Error) {
	sets := make([]string, 0, 2)
	args := make([]any, 0, 2)
	if nickname != "" {
		if len(nickname) > 64 {
			return nil, &yim.Error{Code: CodeNicknameTaken, Msg: "nickname too long (max 64)"}
		}
		sets = append(sets, "nickname=?")
		args = append(args, nickname)
	}
	if avatar != "" {
		if len(avatar) > 255 {
			return nil, &yim.Error{Code: CodeInternal, Msg: "avatar url too long"}
		}
		sets = append(sets, "avatar=?")
		args = append(args, avatar)
	}
	if len(sets) == 0 {
		// 无变更: 直接返回当前资料
		ps, perr := s.GetProfiles(ctx, []int64{uid})
		if perr != nil || len(ps) == 0 {
			return nil, perr
		}
		return ps[0], nil
	}
	args = append(args, uid)
	if _, err := s.db.Meta.ExecContext(ctx,
		"UPDATE users SET "+strings.Join(sets, ",")+" WHERE uid=?", args...); err != nil {
		var me *mysql.MySQLError
		if errors.As(err, &me) && me.Number == 1062 {
			return nil, bizErr(CodeNicknameTaken)
		}
		return nil, &yim.Error{Code: CodeInternal, Msg: err.Error()}
	}
	s.cache.InvalidateProfile(ctx, uid)
	ps, perr := s.GetProfiles(ctx, []int64{uid})
	if perr != nil || len(ps) == 0 {
		return nil, perr
	}
	return ps[0], nil
}

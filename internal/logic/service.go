// Package logic: 账号与登录态 (里程碑5)。
//
// 职责: 注册/登录/令牌签发 (ARCHITECTURE.md 架构图中的 Logic Svc)。
// 多端踢出、注销黑名单属同服务扩展, 当前由 Comet 同设备顶替承载。
//
// 密码: bcrypt (自带盐, 慢哈希抗暴力) —— 校验失败是常态不是异常。
// 登录失败统一 ErrBadCredential 口径, 不区分"用户不存在/密码错", 防用户名枚举。
// 令牌: JWT HS256, 无状态验签 —— Comet 收 CONNECT 本地验签, 不产生每连接一次的 RPC。
// 简化为 7 天长 token (无 refresh token 轮换, 扩展位)。
package logic

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"regexp"

	"github.com/go-sql-driver/mysql"
	"golang.org/x/crypto/bcrypt"

	"github.com/yim/internal/store"
)

var nicknameRe = regexp.MustCompile(`^[a-zA-Z0-9_\-\x{4e00}-\x{9fa5}]{2,32}$`)

var (
	ErrNicknameTaken = errors.New("nickname already taken")
	ErrBadCredential = errors.New("invalid nickname or password")
)

type Service struct {
	db    *store.MySQL
	uids  UIDAllocator // uid 发号走 Seq Svc 号段 (与消息 ID 同源)
	token *Tokenizer
}

// UIDAllocator 解耦对 Seq Svc 的依赖 (测试可注入假实现)
type UIDAllocator interface {
	AllocUID(ctx context.Context) (int64, error)
}

func NewService(db *store.MySQL, uids UIDAllocator, token *Tokenizer) *Service {
	return &Service{db: db, uids: uids, token: token}
}

type RegisterResult struct {
	UID int64
}

func (s *Service) Register(ctx context.Context, nickname, password string) (*RegisterResult, error) {
	if !nicknameRe.MatchString(nickname) {
		return nil, fmt.Errorf("nickname: 2-32位, 字母数字下划线连字符或中文")
	}
	if len(password) < 6 || len(password) > 64 {
		return nil, fmt.Errorf("password: 6-64位")
	}

	// uid 发号在 hash 计算前: bcrypt 是慢函数 (~100ms), 先占号, 失败弃号即可
	uid, err := s.uids.AllocUID(ctx)
	if err != nil {
		return nil, fmt.Errorf("alloc uid: %w", err)
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("bcrypt: %w", err)
	}

	_, err = s.db.Meta.ExecContext(ctx,
		"INSERT INTO users (uid, nickname, password_hash) VALUES (?,?,?)",
		uid, nickname, string(hash))
	if err != nil {
		// nickname 唯一键冲突 (1062): 并发注册同昵称
		if isDuplicate(err) {
			return nil, ErrNicknameTaken
		}
		return nil, fmt.Errorf("insert user: %w", err)
	}
	return &RegisterResult{UID: uid}, nil
}

type LoginResult struct {
	UID        int64
	Token      string
	ExpireAtMs int64
}

func (s *Service) Login(ctx context.Context, nickname, password string) (*LoginResult, error) {
	var uid int64
	var hash string
	err := s.db.Meta.QueryRowContext(ctx,
		"SELECT uid, password_hash FROM users WHERE nickname = ?", nickname).Scan(&uid, &hash)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrBadCredential
		}
		return nil, fmt.Errorf("query user: %w", err)
	}

	// bcrypt 校验: 恒定耗时路径, 不存在与密码错的报错口径一致
	if bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)) != nil {
		return nil, ErrBadCredential
	}

	token, expireAt, err := s.token.Issue(uid)
	if err != nil {
		return nil, fmt.Errorf("issue token: %w", err)
	}
	return &LoginResult{UID: uid, Token: token, ExpireAtMs: expireAt.UnixMilli()}, nil
}

func isDuplicate(err error) bool {
	var me *mysql.MySQLError
	return errors.As(err, &me) && me.Number == 1062
}

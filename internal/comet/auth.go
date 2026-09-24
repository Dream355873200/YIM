package comet

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"strconv"
	"strings"
	"time"
)

// Authenticator 连接鉴权抽象。里程碑3 的 DevAuthenticator 只做格式解析;
// 里程碑5 起 JWTAuthenticator 本地验签 (无状态, 不产生验签 RPC),
// dev 模式可同时放行 "dev.<uid>" 格式 (本地联调/自检)。
type Authenticator interface {
	Auth(ctx context.Context, token string) (uid int64, err error)
}

// DevAuthenticator dev 鉴权: token 形如 "dev.<uid>"。
// 只验证格式不验证签名 —— 本地联调用, 生产必须换真实现。
type DevAuthenticator struct{}

func (DevAuthenticator) Auth(_ context.Context, token string) (int64, error) {
	const p = "dev."
	if !strings.HasPrefix(token, p) {
		return 0, errors.New("invalid token format")
	}
	uid, err := strconv.ParseInt(token[len(p):], 10, 64)
	if err != nil || uid <= 0 {
		return 0, errors.New("invalid token uid")
	}
	return uid, nil
}

// JWTAuthenticator HS256 JWT 本地验签, 与 Logic Svc 的 Tokenizer 同构
// (签发在 Logic Svc, 这里只验: 复制实现而非共享包, 服务间只共享密钥配置)。
// alg 固定不读 header —— 防算法混淆攻击。
type JWTAuthenticator struct {
	secret   []byte
	allowDev bool // dev 模式: 同时接受 "dev.<uid>" (自检/本地联调)
}

func NewJWTAuthenticator(secret string, allowDev bool) *JWTAuthenticator {
	return &JWTAuthenticator{secret: []byte(secret), allowDev: allowDev}
}

func (a *JWTAuthenticator) Auth(_ context.Context, token string) (int64, error) {
	if a.allowDev && strings.HasPrefix(token, "dev.") {
		return DevAuthenticator{}.Auth(nil, token)
	}
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return 0, errors.New("malformed token")
	}
	want := a.sign(parts[0], parts[1])
	if !hmac.Equal([]byte(want), []byte(parts[2])) {
		return 0, errors.New("bad signature")
	}
	if parts[0] != jwtHeaderB64 {
		return 0, errors.New("unexpected alg")
	}
	payload, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return 0, errors.New("bad payload")
	}
	var c struct {
		UID int64 `json:"uid"`
		Exp int64 `json:"exp"`
	}
	if json.Unmarshal(payload, &c) != nil || c.UID <= 0 {
		return 0, errors.New("bad claims")
	}
	if time.Now().Unix() >= c.Exp {
		return 0, errors.New("token expired")
	}
	return c.UID, nil
}

var jwtHeaderB64 = func() string {
	b, _ := json.Marshal(map[string]string{"alg": "HS256", "typ": "JWT"})
	return base64.RawURLEncoding.EncodeToString(b)
}()

func (a *JWTAuthenticator) sign(header, payload string) string {
	h := hmac.New(sha256.New, a.secret)
	h.Write([]byte(header))
	h.Write([]byte("."))
	h.Write([]byte(payload))
	return base64.RawURLEncoding.EncodeToString(h.Sum(nil))
}

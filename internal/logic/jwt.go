// JWT 签发与验签 (HS256)。手写实现约 80 行: 头/载荷 base64url + HMAC-SHA256 签名,
// 不引入 golang-jwt 依赖 —— 算法本身就是 JWT 规范 (RFC 7519) 的 JWS 紧凑序列化。
//
// 安全边界 (明确说清, 面试高频):
//   - HS256 对称密钥: 签发方与验签方共享密钥。服务内网单签发方 (Logic Svc) 够用;
//     若验签方多且不可信 (开放平台), 应换 RS256/ES256 非对称, 验签方只持公钥
//   - 无状态验签的代价: 注销/踢人在 token 过期前仍有效 → 生产补 Redis jti 黑名单
//     (校验时查一次, 可缓存), 当前多端互踢由 Comet 同设备顶替承载, 短板可接受
//   - alg 固定 HS256 不读 header: 防 alg=none / 算法混淆攻击 (经典 JWT 漏洞)
package logic

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"strings"
	"time"
)

const tokenTTL = 7 * 24 * time.Hour

var (
	ErrTokenExpired = errors.New("token expired")
	ErrTokenInvalid = errors.New("token invalid")
)

type Tokenizer struct {
	secret []byte
	now    func() time.Time // 可注入时钟 (测试)
}

func NewTokenizer(secret string) *Tokenizer {
	return &Tokenizer{secret: []byte(secret), now: time.Now}
}

// header 固定, 不解析客户端 header (防算法混淆)
var headerB64 = mustB64(map[string]string{"alg": "HS256", "typ": "JWT"})

type claims struct {
	UID int64 `json:"uid"`
	Exp int64 `json:"exp"` // 过期时间 (秒)
	Iat int64 `json:"iat"`
}

// Issue 签发 token: <header>.<payload>.<signature>
func (t *Tokenizer) Issue(uid int64) (string, time.Time, error) {
	now := t.now()
	exp := now.Add(tokenTTL)
	c, err := json.Marshal(claims{UID: uid, Exp: exp.Unix(), Iat: now.Unix()})
	if err != nil {
		return "", time.Time{}, err
	}
	payload := base64.RawURLEncoding.EncodeToString(c)
	sig := t.sign(headerB64, payload)
	return headerB64 + "." + payload + "." + sig, exp, nil
}

// Verify 验签 + 过期校验, 返回 uid。
// errors.Is 区分过期 (客户端该重新登录) 与伪造/损坏 (该踢下线)。
func (t *Tokenizer) Verify(token string) (int64, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return 0, ErrTokenInvalid
	}
	// 恒定时间比较签名, 防时序侧信道逐字节猜签名
	want := t.sign(parts[0], parts[1])
	if !hmac.Equal([]byte(want), []byte(parts[2])) {
		return 0, ErrTokenInvalid
	}
	if parts[0] != headerB64 {
		return 0, ErrTokenInvalid // alg 只认签发时的那个
	}
	cRaw, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return 0, ErrTokenInvalid
	}
	var c claims
	if err := json.Unmarshal(cRaw, &c); err != nil || c.UID <= 0 {
		return 0, ErrTokenInvalid
	}
	if t.now().Unix() >= c.Exp {
		return 0, ErrTokenExpired
	}
	return c.UID, nil
}

func (t *Tokenizer) sign(header, payload string) string {
	h := hmac.New(sha256.New, t.secret)
	h.Write([]byte(header))
	h.Write([]byte("."))
	h.Write([]byte(payload))
	return base64.RawURLEncoding.EncodeToString(h.Sum(nil))
}

func mustB64(v any) string {
	b, err := json.Marshal(v)
	if err != nil {
		panic(err)
	}
	return base64.RawURLEncoding.EncodeToString(b)
}

// Package middleware: HTTP 网关中间件。
//
// JWTAuth 网关鉴权 (里程碑9): 与 comet 的 JWTAuthenticator 同构自持
// (复制实现而非共享包 —— 服务间只共享密钥配置的既有信任边界, comet/auth.go
// 注释确立)。白名单路径豁免; dev 模式同时放行 "Bearer dev.<uid>" (与 comet
// 行为对称, selftest/curl/Flutter 联调不受影响)。
//
// 安全要点 (与 logic/jwt.go 一致): alg 固定 HS256 不读客户端 header (防算法
// 混淆); 恒定时间比较签名; 失败统一 401 不区分过期/伪造 (防探测)。
// 验签通过的 uid 写入 RequestContext, 后续 handler 从 c 取身份 ——
// 请求体里的 from_uid/op_uid 一律不可信。
package middleware

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

	"github.com/cloudwego/hertz/pkg/app"
)

var errInvalid = errors.New("invalid token")

// uidKey RequestContext 存储键 (c.Set/c.Get)。
const uidKey = "yim.uid"

// UID 从请求上下文取鉴权 uid (JWT 中间件注入)。
func UID(c *app.RequestContext) int64 {
	v, ok := c.Get(uidKey)
	if !ok {
		return 0
	}
	uid, _ := v.(int64)
	return uid
}

// JWTAuth 返回网关鉴权中间件。白名单精确匹配 method+path;
// /files/ 前缀整体豁免 (头像公开读)。
func JWTAuth(secret string, allowDev bool) app.HandlerFunc {
	j := &jwtVerifier{secret: []byte(secret), allowDev: allowDev}
	return func(ctx context.Context, c *app.RequestContext) {
		if isPublic(string(c.Method()), string(c.Path())) {
			c.Next(ctx)
			return
		}
		token := bearer(c)
		if token == "" {
			abort(c)
			return
		}
		uid, err := j.verify(token)
		if err != nil {
			abort(c)
			return
		}
		c.Set(uidKey, uid)
		c.Next(ctx)
	}
}

// isPublic 鉴权豁免: 注册/登录 + 头像静态读。
func isPublic(method, path string) bool {
	if method == "POST" && (path == "/api/v1/register" || path == "/api/v1/login") {
		return true
	}
	return strings.HasPrefix(path, "/files/")
}

// bearer 解析 Authorization: Bearer <token>。
func bearer(c *app.RequestContext) string {
	h := string(c.Request.Header.Get("Authorization"))
	const p = "Bearer "
	if !strings.HasPrefix(h, p) {
		return ""
	}
	return strings.TrimSpace(h[len(p):])
}

func abort(c *app.RequestContext) {
	c.AbortWithStatusJSON(401, map[string]string{"error": "unauthorized"})
}

// jwtVerifier HS256 验签, comet.JWTAuthenticator 同构 (只验不签)。
type jwtVerifier struct {
	secret   []byte
	allowDev bool
}

var jwtHeaderB64 = func() string {
	b, _ := json.Marshal(map[string]string{"alg": "HS256", "typ": "JWT"})
	return base64.RawURLEncoding.EncodeToString(b)
}()

func (v *jwtVerifier) verify(token string) (int64, error) {
	// dev 后门: "dev.<uid>" 明文 (与 comet.DevAuthenticator 同语义)
	if v.allowDev && strings.HasPrefix(token, "dev.") {
		uid, err := strconv.ParseInt(token[len("dev."):], 10, 64)
		if err != nil || uid <= 0 {
			return 0, err
		}
		return uid, nil
	}
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return 0, errInvalid
	}
	h := hmac.New(sha256.New, v.secret)
	h.Write([]byte(parts[0]))
	h.Write([]byte("."))
	h.Write([]byte(parts[1]))
	if !hmac.Equal([]byte(base64.RawURLEncoding.EncodeToString(h.Sum(nil))), []byte(parts[2])) {
		return 0, errInvalid
	}
	if parts[0] != jwtHeaderB64 {
		return 0, errInvalid
	}
	payload, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return 0, errInvalid
	}
	var c struct {
		UID int64 `json:"uid"`
		Exp int64 `json:"exp"`
	}
	if json.Unmarshal(payload, &c) != nil || c.UID <= 0 {
		return 0, errInvalid
	}
	if time.Now().Unix() >= c.Exp {
		return 0, errInvalid
	}
	return c.UID, nil
}

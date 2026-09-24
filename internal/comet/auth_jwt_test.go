package comet

import (
	"context"
	"testing"

	"github.com/yim/internal/logic"
)

// 跨服务契约: Logic Svc 签发的 JWT 必须能被 Comet 本地验签通过。
// 两边是复制实现 (共享密钥配置而非共享代码), 该测试守住两份实现的一致性。
func TestCrossPackageJWTCompatibility(t *testing.T) {
	tk := logic.NewTokenizer("shared-secret")
	token, _, err := tk.Issue(42)
	if err != nil {
		t.Fatal(err)
	}
	auth := NewJWTAuthenticator("shared-secret", false)
	uid, err := auth.Auth(context.Background(), token)
	if err != nil || uid != 42 {
		t.Fatalf("comet verify logic token: uid=%d err=%v", uid, err)
	}
}

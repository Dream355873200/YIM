package logic

import (
	"encoding/base64"
	"errors"
	"strings"
	"testing"
	"time"
)

func TestJWTSignVerify(t *testing.T) {
	tk := NewTokenizer("test-secret")
	token, exp, err := tk.Issue(42)
	if err != nil {
		t.Fatal(err)
	}
	if want := 3; len(strings.Split(token, ".")) != want {
		t.Fatalf("token parts = %d, want %d", len(strings.Split(token, ".")), want)
	}
	uid, err := tk.Verify(token)
	if err != nil || uid != 42 {
		t.Fatalf("verify: uid=%d err=%v", uid, err)
	}
	if time.Until(exp) < 24*time.Hour {
		t.Fatalf("expire too soon: %v", exp)
	}
}

func TestJWTTamperAndWrongSecret(t *testing.T) {
	tk := NewTokenizer("test-secret")
	token, _, _ := tk.Issue(42)

	if _, err := NewTokenizer("other-secret").Verify(token); !errors.Is(err, ErrTokenInvalid) {
		t.Fatalf("wrong secret: want ErrTokenInvalid, got %v", err)
	}

	// 篡改 payload (uid 42 → 43): 签名对不上
	parts := strings.Split(token, ".")
	evil := []byte(`{"uid":43,"exp":9999999999}`)
	parts[1] = base64RawURL(evil)
	if _, err := tk.Verify(strings.Join(parts, ".")); !errors.Is(err, ErrTokenInvalid) {
		t.Fatalf("tampered payload: want ErrTokenInvalid, got %v", err)
	}
}

func TestJWTExpired(t *testing.T) {
	tk := NewTokenizer("test-secret")
	token, _, _ := tk.Issue(42)
	// 时钟前移 8 天 → 过期
	future := time.Now().Add(8 * 24 * time.Hour)
	tk2 := &Tokenizer{secret: tk.secret, now: func() time.Time { return future }}
	if _, err := tk2.Verify(token); !errors.Is(err, ErrTokenExpired) {
		t.Fatalf("expired: want ErrTokenExpired, got %v", err)
	}
}

// alg 混淆攻击: 伪造 header {"alg":"none"} + 空签名, 必须拒绝
func TestJWTAlgConfusionRejected(t *testing.T) {
	tk := NewTokenizer("test-secret")
	forged := base64RawURL([]byte(`{"alg":"none","typ":"JWT"}`)) + "." +
		base64RawURL([]byte(`{"uid":42,"exp":9999999999}`)) + "."
	if _, err := tk.Verify(forged); !errors.Is(err, ErrTokenInvalid) {
		t.Fatalf("alg=none: want ErrTokenInvalid, got %v", err)
	}
}

func base64RawURL(b []byte) string {
	return base64.RawURLEncoding.EncodeToString(b)
}

// files.go 头像文件接入 (里程碑9): 上传落盘 + 静态读。
//
// 设计: 网关负责文件接入层 (multipart/魔数/落盘), Relation Svc 只管 DB 的
// avatar URL —— 将来换对象存储 (S3/OSS 直传签名) 只改网关, DB 路径不变。
// 内容寻址 (sha1): 同图不重复存, URL 即校验和, 客户端可 immutable 缓存。
// 安全: 类型白名单走魔数 (不信任 Content-Type 头); 静态读路径白名单
// ([0-9a-f]{2}/sha1.ext) 天然防路径穿越; 大小限制在 Content-Length 与
// multipart 双层卡。
package main

import (
	"context"
	"crypto/sha1"
	"encoding/hex"
	"fmt"
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/cloudwego/hertz/pkg/app"
	"github.com/cloudwego/hertz/pkg/app/server"
	"go.uber.org/zap"

	"github.com/yim/internal/config"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/middleware"
	relationservice "github.com/yim/kitex_gen/yim/relationservice"
	"github.com/yim/kitex_gen/yim"
)

// 上传上限/魔数 (config 注入大小, 白名单固定)
var avatarExtByMagic = map[string]string{
	"\x89PNG\r\n\x1a\n": "png",      // PNG
	"\xFF\xD8\xFF":      "jpg",      // JPEG
	"RIFF":              "webp",     // RIFF....WEBP (还需偏移 8 校验 WEBP)
}

var staticPathRe = regexp.MustCompile(`^/?(avatar|img)/[0-9a-f]{2}/[0-9a-f]{40}\.(png|jpg|webp)$`)

// registerAvatarRoutes 挂上传 + 静态读。relCli 供写 avatar URL。
func registerAvatarRoutes(hz *server.Hertz, cfg *config.Config, relCli relationservice.Client) {
	api := hz.Group("/api/v1")
	api.POST("/files/avatar", func(ctx context.Context, c *app.RequestContext) {
		uid := middleware.UID(c)
		fh, limit := uploadFile(c, cfg, cfg.MaxAvatarBytes)
		if limit {
			writeErr(c, 413, "file too large")
			return
		}
		if fh == nil {
			return // uploadFile 已写 400
		}
		src, err := fh.Open()
		if err != nil {
			writeErr(c, 400, "cannot read upload")
			return
		}
		defer src.Close()
		url, uerr := storeImage(cfg.FilesDir, "avatar", src, fh.Size)
		if uerr != nil {
			logger.C(ctx).Warn("avatar store", zap.Error(uerr), zap.Int64("uid", uid))
			writeErr(c, 400, uerr.Error()) // 魔数/大小类用户可读; IO 类也 400 简化
			return
		}
		rsp, err := relCli.UpdateProfile(ctx, &yim.UpdateProfileReq{Uid: uid, Avatar: url})
		if err != nil {
			logger.C(ctx).Error("avatar update profile rpc", zap.Error(err))
			writeErr(c, 500, "save avatar failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 聊天图片上传 (里程碑10): 与头像同魔数白名单/内容寻址, 落 img/ 子目录。
	// 成功返回 JSON {url, size} —— 客户端拼进 MSG_IMAGE 的 media 元数据随消息落库。
	api.POST("/files/image", func(ctx context.Context, c *app.RequestContext) {
		uid := middleware.UID(c)
		fh, limit := uploadFile(c, cfg, cfg.MaxImageBytes)
		if limit {
			writeErr(c, 413, "file too large")
			return
		}
		if fh == nil {
			return
		}
		src, err := fh.Open()
		if err != nil {
			writeErr(c, 400, "cannot read upload")
			return
		}
		defer src.Close()
		url, uerr := storeImage(cfg.FilesDir, "img", src, fh.Size)
		if uerr != nil {
			logger.C(ctx).Warn("image store", zap.Error(uerr), zap.Int64("uid", uid))
			writeErr(c, 400, uerr.Error())
			return
		}
		logger.C(ctx).Info("image uploaded", zap.Int64("uid", uid), zap.String("url", url))
		c.JSON(200, map[string]any{"url": url, "size": fh.Size})
	})

	// 静态读 (公开, JWT 豁免在 middleware.isPublic): /files/{avatar|img}/<2>/<40>.<ext>
	hz.GET("/files/*filepath", func(ctx context.Context, c *app.RequestContext) {
		p := string(c.Param("filepath"))
		if !staticPathRe.MatchString(p) {
			logger.C(ctx).Warn("static file rejected", zap.String("path", p))
			writeErr(c, 404, "not found")
			return
		}
		c.Header("Cache-Control", "public, max-age=31536000, immutable") // 内容寻址: URL 即版本
		c.File(filepath.Join(cfg.FilesDir, filepath.FromSlash(p)))
	})
}

// uploadFile 提取 multipart 'file': 大小双层卡 (Content-Length + fh.Size)。
// 返回 limit=true 表示超限 (已写 413); fh=nil 表示已写 400。
func uploadFile(c *app.RequestContext, cfg *config.Config, maxFileBytes int64) (fh *multipart.FileHeader, limit bool) {
	if int64(c.Request.Header.ContentLength()) > cfg.MaxUploadBytes {
		limit = true
		return
	}
	var err error
	fh, err = c.FormFile("file")
	if err != nil {
		writeErr(c, 400, "multipart field 'file' required")
		return
	}
	if fh.Size > maxFileBytes {
		limit = true
		return
	}
	return
}

// storeImage 魔数校验 → sha1 内容寻址落盘 → 返回相对 URL。
// subdir 区分用途 (avatar/img), 静态读白名单按前缀放行。
func storeImage(dir, subdir string, src multipart.File, size int64) (string, error) {
	if size <= 0 {
		return "", fmt.Errorf("empty file")
	}
	buf := make([]byte, size)
	if _, err := io.ReadFull(src, buf); err != nil {
		return "", fmt.Errorf("read upload: %w", err)
	}
	ext := ""
	for magic, e := range avatarExtByMagic {
		if len(buf) >= len(magic) && string(buf[:len(magic)]) == magic {
			if e == "webp" && (len(buf) < 12 || string(buf[8:12]) != "WEBP") {
				continue // RIFF 但不是 WEBP
			}
			ext = e
			break
		}
	}
	if ext == "" {
		return "", fmt.Errorf("unsupported image type (png/jpeg/webp only)")
	}
	sum := sha1.Sum(buf)
	name := hex.EncodeToString(sum[:])
	rel := fmt.Sprintf("/files/%s/%s/%s.%s", subdir, name[:2], name, ext)
	// URL 的 /files 前缀 = 对外路由, 落盘目录 = FilesDir 本身 (不重复拼 files)
	abs := filepath.Join(dir, filepath.FromSlash(strings.TrimPrefix(rel, "/files")))
	if err := os.MkdirAll(filepath.Dir(abs), 0o755); err != nil {
		return "", fmt.Errorf("mkdir: %w", err)
	}
	if _, err := os.Stat(abs); err == nil {
		return rel, nil // 同图已存在 (内容寻址幂等)
	}
	if err := os.WriteFile(abs, buf, 0o644); err != nil {
		return "", fmt.Errorf("write: %w", err)
	}
	return rel, nil
}

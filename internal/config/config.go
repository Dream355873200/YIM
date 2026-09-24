package config

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

// Config 单体阶段所有组件共用的配置。
// 拆微服务后按服务拆分为子结构, 此处先集中定义避免过早抽象。
type Config struct {
	HTTPAddr string // Hertz API 监听
	GRPCAddr string // 内部 gRPC 监听
	CometTCP string // Comet 长连接监听 (里程碑3启用)

	MySQLDSN   string
	RedisAddrs []string

	// 微服务发现 (里程碑2)
	EtcdEndpoints   []string
	MessageRPCAddr  string // Message Svc Kitex 监听
	SeqRPCAddr      string // Seq Svc Kitex 监听
	CometRPCAddr    string // Comet 北向 Kitex 监听 (里程碑3)
	LogicRPCAddr    string // Logic Svc Kitex 监听 (里程碑5)
	RelationRPCAddr string // Relation Svc Kitex 监听 (里程碑9: 好友/群成员/资料/在线)

	// 头像文件存储 (里程碑9): 本地磁盘内容寻址, 生产换对象存储只改网关
	FilesDir         string
	MaxAvatarBytes   int64
	MaxImageBytes    int64 // 聊天图片上限
	MaxUploadBytes   int64 // 整个 multipart body 上限 (含表单开销)

	// 可选 TLS (里程碑14): 证书/私钥 PEM 路径, 配置后 comet 长连接与
	// 网关 HTTP 同时升级 TLS (整进程一价: 同一份证书, 两端都不再收明文);
	// 也可以不配而由外部 LB/反代终止 TLS
	TLSCert string
	TLSKey  string

	// 鉴权 (里程碑5): JWT HS256 密钥; AuthMode=dev 时 Comet 额外放行 "dev.<uid>" token
	JWTSecret string
	AuthMode  string

	// 可观测性
	OTelEndpoint string // OTel Collector OTLP gRPC 地址, 如 "127.0.0.1:4317"

	// Kafka (投递层标准形态): 空 = 进程内 channel 形态 (降级, 优化组件可缺席)
	KafkaBrokers []string

	// Seq 号段配置
	SeqStep int // 每次从 DB 申请的号段长度
}

func Load() (*Config, error) {
	c := &Config{
		HTTPAddr:     envOr("YIM_HTTP_ADDR", ":8080"),
		GRPCAddr:     envOr("YIM_GRPC_ADDR", ":9000"),
		CometTCP:     envOr("YIM_COMET_TCP", ":8900"),
		MySQLDSN:     envOr("YIM_MYSQL_DSN", "root:root@tcp(127.0.0.1:3307)/yim?charset=utf8mb4&parseTime=true&loc=Local"),
		RedisAddrs:   []string{envOr("YIM_REDIS_ADDR", "127.0.0.1:6379")},
		OTelEndpoint: envOr("YIM_OTEL_ENDPOINT", "127.0.0.1:4317"),
	}
	c.EtcdEndpoints = []string{envOr("YIM_ETCD_ENDPOINTS", "127.0.0.1:2379")}
	c.MessageRPCAddr = envOr("YIM_MESSAGE_RPC_ADDR", ":9001")
	c.SeqRPCAddr = envOr("YIM_SEQ_RPC_ADDR", ":9002")
	c.CometRPCAddr = envOr("YIM_COMET_RPC_ADDR", ":9003")
	c.LogicRPCAddr = envOr("YIM_LOGIC_RPC_ADDR", ":9004")
	c.RelationRPCAddr = envOr("YIM_RELATION_RPC_ADDR", ":9005")
	c.FilesDir = envOr("YIM_FILES_DIR", "./data/files")
	maxAvatar, err := strconv.ParseInt(envOr("YIM_MAX_AVATAR_BYTES", "2097152"), 10, 64) // 2MB
	if err != nil {
		return nil, fmt.Errorf("YIM_MAX_AVATAR_BYTES: %w", err)
	}
	c.MaxAvatarBytes = maxAvatar
	maxImage, err := strconv.ParseInt(envOr("YIM_MAX_IMAGE_BYTES", "10485760"), 10, 64) // 10MB
	if err != nil {
		return nil, fmt.Errorf("YIM_MAX_IMAGE_BYTES: %w", err)
	}
	c.MaxImageBytes = maxImage
	c.MaxUploadBytes = maxImage + 64*1024 // multipart 开销余量 (图片比头像大, 取上限)
	c.TLSCert = os.Getenv("YIM_TLS_CERT")
	c.TLSKey = os.Getenv("YIM_TLS_KEY")
	c.JWTSecret = envOr("YIM_JWT_SECRET", "dev-secret-do-not-use-in-prod")
	c.AuthMode = envOr("YIM_AUTH_MODE", "dev")
	if v := os.Getenv("YIM_KAFKA_BROKERS"); v != "" {
		for _, b := range strings.Split(v, ",") {
			if b = strings.TrimSpace(b); b != "" {
				c.KafkaBrokers = append(c.KafkaBrokers, b)
			}
		}
	}
	var errSeq error
	if c.SeqStep, errSeq = strconv.Atoi(envOr("YIM_SEQ_STEP", "10000")); errSeq != nil {
		return nil, fmt.Errorf("YIM_SEQ_STEP: %w", errSeq)
	}
	return c, nil
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

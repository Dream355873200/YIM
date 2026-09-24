// yim-job: Job Svc —— 投递层的 Kafka 消费者 (标准形态, 里程碑4 的独立进程化)。
//
// 消费两个 topic (同一消费组 yim-job, at-least-once):
//
//	yim.push : Message Svc 事务提交后的投递事件 → Deliverer.Deliver
//	           (查成员 → 逐成员广播 comet → 在线重试/离线落箱)
//	yim.ack  : 客户端确认事件 (Comet→Message Svc 转发) → 取消重试定时
//
// 可靠性: 先处理后提交 offset (处理中崩溃 → 重投递, 重复由客户端按 seq
// 去重 + 离线箱 INSERT IGNORE 幂等); 消费失败不提交 → Kafka 重投;
// 全部漏网 → local_message 扫描补偿 (防线3)。
//
// 高可用: 消费者组水平扩展, 实例崩溃秒级 rebalance; 进程无持久状态,
// 重试注册表丢失的代价只是多重推几次 (去重兜底)。
package main

import (
	"context"
	"flag"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	etcd "github.com/kitex-contrib/registry-etcd"
	"github.com/segmentio/kafka-go"
	"go.uber.org/zap"
	"google.golang.org/protobuf/proto"

	"github.com/yim/internal/cache"
	"github.com/yim/internal/config"
	"github.com/yim/internal/kitexcfg"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/message"
	"github.com/yim/internal/store"
	"github.com/yim/internal/trace"
	"github.com/yim/kitex_gen/yim"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
)

const consumerGroup = "yim-job"

// ackConsumerGroup ack topic 独立消费组: kafka-go 的组内成员按 topic 订阅,
// 混合 topic 的组在分区多/成员多时分配器易抖动 (rebalance 风暴 → 消费停摆)。
// push/ack 各自独立组, 分区分配互不干扰。
const ackConsumerGroup = "yim-job-ack"

// consumerCount push 消费并行度 (YIM_KAFKA_CONSUMERS, 默认 8 = 分区数)。
// 超过分区数的 reader 空转 (broker 不会派分区), 设小了则分区富余。
func consumerCount() int {
	if n, err := strconv.Atoi(os.Getenv("YIM_KAFKA_CONSUMERS")); err == nil && n > 0 {
		return n
	}
	return 8
}

func main() {
	dev := flag.Bool("dev", true, "dev mode: console log + 100% sampling")
	flag.Parse()

	if err := logger.Init(*dev); err != nil {
		panic(err)
	}
	defer logger.Sync()

	cfg, err := config.Load()
	if err != nil {
		logger.L.Fatal("load config", zap.Error(err))
	}
	if len(cfg.KafkaBrokers) == 0 {
		logger.L.Fatal("YIM_KAFKA_BROKERS not configured (job svc is kafka-only)")
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	db, err := store.OpenMySQL(ctx, cfg.MySQLDSN)
	if err != nil {
		logger.L.Fatal("open mysql", zap.Error(err))
	}
	defer db.Close()

	var msgCache *cache.Cache
	if c, err := cache.OpenRedis(ctx, cfg.RedisAddrs[0]); err != nil {
		logger.L.Warn("redis unavailable, running degraded (DB slow path)",
			zap.Error(err), zap.String("addr", cfg.RedisAddrs[0]))
	} else {
		msgCache = c
	}

	_, err = trace.Init(ctx, trace.Config{
		Endpoint:    cfg.OTelEndpoint,
		ServiceName: "yim-job",
		Dev:         *dev,
	}, logger.L)
	if err != nil {
		logger.L.Warn("otel disabled", zap.Error(err))
	}

	// etcd 服务发现: comet 广播客户端 + seq client, 与进程内形态同一套依赖
	resolver, err := etcd.NewEtcdResolver(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd resolver", zap.Error(err))
	}
	seqCli, err := seqservice.NewClient("yim.seq", kitexcfg.ClientOptions(resolver, "yim.seq")...)
	if err != nil {
		logger.L.Fatal("kitex client yim.seq", zap.Error(err))
	}
	cometCluster := message.NewCometCluster(resolver)
	// 路由本地缓存 (16 里程碑降密度): PushRouted 读进程内 map, miss 播种 Redis,
	// 消费 route:change 失效流; Redis 不可用时跳过 (路由本就是优化组件,
	// 未装配 = 原逐次 RouteGet 行为)
	if msgCache != nil {
		rc := message.NewRouteCache()
		cometCluster.UseRouteCache(rc)
		go message.SubscribeRouteChanges(ctx, cfg.RedisAddrs[0], rc)
		logger.L.Info("route cache enabled", zap.String("redis", cfg.RedisAddrs[0]))
	}
	// sync 水位走 Redis INCR (里程碑8): 投递路径每接收者一次 Bump, 降掉最热的
	// seq RPC; Redis 不可用回退纯 RPC 形态
	deliverer := message.NewDeliverer(db,
		message.NewRedisSyncSeqClient(msgCache, message.NewRPCSeqClient(seqCli), db),
		cometCluster, msgCache)
	// 重试定时: 层级时间轮 (默认) / native (YIM_RETRY_TIMER=native, 压测对照)
	deliverer.UseTimer(message.DefaultRetryTimer())

	pushCount := consumerCount()
	pushReaders := make([]*kafka.Reader, pushCount)
	for i := range pushReaders {
		pushReaders[i] = newReader(cfg.KafkaBrokers, message.TopicPush, consumerGroup)
		defer pushReaders[i].Close()
	}
	ackReader := newReader(cfg.KafkaBrokers, message.TopicAck, ackConsumerGroup)
	defer ackReader.Close()

	// 消费并行度 = 分区数: 每个 reader 是独立消费组成员, broker 把分区
	// 派给它们。同分区串行 (会话内有序, key=conv_id 的红利), 跨分区并行
	// —— 投递吞吐 = 分区数 × 单链路时延倒数, 不再被单协程串行卡死。
	for _, r := range pushReaders {
		go consumeLoop(ctx, r, deliverer)
	}
	go consumeLoop(ctx, ackReader, deliverer)

	logger.L.Info("yim-job ready",
		zap.Strings("brokers", cfg.KafkaBrokers),
		zap.String("group", consumerGroup),
		zap.Int("push_consumers", pushCount),
		zap.Strings("topics", []string{message.TopicPush, message.TopicAck}),
	)

	<-ctx.Done()
	logger.L.Info("yim-job shutting down")
	// defer reader.Close() 会让阻塞中的 FetchMessage 返回, consumeLoop 随 ctx 退出
}

func newReader(brokers []string, topic, group string) *kafka.Reader {
	return kafka.NewReader(kafka.ReaderConfig{
		Brokers:     brokers,
		GroupID:     group,
		Topic:       topic,
		MinBytes:    1,
		MaxBytes:    1 << 20,
		StartOffset: kafka.FirstOffset, // 新消费组从头消费: at-least-once + 幂等去重, 宁多勿丢
	})
}

// consumeLoop 单 topic 消费循环: fetch → 处理 → 攒批 commit (at-least-once)。
// offset 每 64 条或 500ms 提交一次 —— 每条一 commit 在 500/s 下是每秒近千次
// broker RPC, 攒批的代价只是崩溃后多重投一小批 (客户端按 seq 去重兜底)。
// FetchMessage/CommitMessages 出错 (broker 抖动/rebalance) 记日志重试;
// reader Close 后 fetch 报错退出。
func consumeLoop(ctx context.Context, r *kafka.Reader, d *message.Deliverer) {
	const batch = 64
	const reportEvery = 512
	pending := make([]kafka.Message, 0, batch)
	lastCommit := time.Now()
	var nFetch, nHandle int64
	var accFetch, accHandle int64 // microseconds
	for {
		t0 := time.Now()
		m, err := r.FetchMessage(ctx)
		accFetch += int64(time.Since(t0) / time.Microsecond)
		nFetch++
		if nFetch%reportEvery == 0 {
			logger.L.Info("consume loop profile",
				zap.String("topic", r.Config().Topic),
				zap.Int64("fetch_avg_us", accFetch/reportEvery),
				zap.Int64("handle_avg_us", accHandle/max64(nHandle, 1)))
			accFetch, accHandle, nHandle = 0, 0, 0
		}
		if err != nil {
			if ctx.Err() != nil {
				return // 停机
			}
			logger.L.Warn("kafka fetch", zap.String("topic", r.Config().Topic), zap.Error(err))
			time.Sleep(500 * time.Millisecond)
			continue
		}
		t1 := time.Now()
		switch r.Config().Topic {
		case message.TopicPush:
			handlePush(m, d)
		case message.TopicAck:
			handleAck(m, d)
		}
		accHandle += int64(time.Since(t1) / time.Microsecond)
		nHandle++
		pending = append(pending, m)
		if len(pending) >= batch || time.Since(lastCommit) > 500*time.Millisecond {
			if err := r.CommitMessages(ctx, pending...); err != nil {
				logger.L.Warn("kafka commit (will redeliver, dedup by seq)", zap.Error(err))
			}
			pending = pending[:0]
			lastCommit = time.Now()
		}
	}
}

func max64(a, b int64) int64 {
	if a > b {
		return a
	}
	return b
}

func handlePush(m kafka.Message, d *message.Deliverer) {
	var ev yim.DeliveryEvent
	if err := proto.Unmarshal(m.Value, &ev); err != nil {
		// 坏消息跳过 (毒丸): 不阻塞分区
		logger.L.Error("unmarshal delivery event, skip", zap.Error(err))
		return
	}
	// produce → handle 的排队时延: 定位 e2e 延迟在 Kafka 段还是投递段
	if lat := time.Since(m.Time); lat > 200*time.Millisecond {
		logger.L.Warn("kafka transit latency",
			zap.Duration("produce_to_handle", lat), zap.Int("partition", m.Partition),
			zap.Int64("conv_id", ev.GetConvId()), zap.Int64("seq", ev.GetMaxSeq()))
	}
	d.Deliver(message.PushEvent{
		ConvID: ev.GetConvId(), MaxSeq: ev.GetMaxSeq(),
		FromUID: ev.GetFromUid(), UserSyncSeq: ev.GetUserSyncSeq(),
		MsgID: ev.GetMsgId(),
	})
}

func handleAck(m kafka.Message, d *message.Deliverer) {
	var ev yim.AckEvent
	if err := proto.Unmarshal(m.Value, &ev); err != nil {
		logger.L.Error("unmarshal ack event, skip", zap.Error(err))
		return
	}
	d.AckPush(ev.GetUid(), ev.GetConvId(), ev.GetAckSeq())
}

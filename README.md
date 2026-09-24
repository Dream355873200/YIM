# YIM · 高并发分布式 IM 系统

> Go 后端 + Flutter 双端。自研 TCP 长连接协议、微服务拆分、可靠投递三道防线、1024 slot 预分片、号段发号器、旁路调度补偿。
>
> 设计原则：**主链路全部为可水平扩展的无状态组件，可靠性靠分层兜底而非单一强依赖，一致性目标为最终一致。**

---

## 核心亮点

| 主题 | 做法 |
|---|---|
| **长连接网关** | 自研二进制协议帧（不用 WebSocket），Netpoll epoll 多路复用，心跳/多端会话/连接索引，Comet 实例间不互相通信（星型拓扑，Job 广播 + 本地索引查空） |
| **可靠投递三道防线** | ① 指数退避重试（200ms/800ms/3.2s，层级时间轮）→ ② 离线箱 → ③ `local_message` 扫表补偿。Kafka 消费者组 at-least-once + 客户端按 seq 去重 = 端到端恰好一次 |
| **不丢的锚点** | 消息与投递任务**同事务**落 `local_message`；Kafka 写失败/Job 崩溃都不丢——发送主链路已提交，扫表补偿兜底 |
| **数据分片** | 1024 slot 预分片 + slot→实例映射表 + 交叉落库映射（连续号段交替打两库）；消息表按 `(conv_id, seq)` 聚簇主键，范围拉取零回表 |
| **号段发号器** | 双 buffer 预领号段（DB 宕机仍可发号一段时间），三类 seq 语义（conv 消息序 / user 同步水位 / 各端独立已读位） |
| **幂等三道闸** | 布隆过滤 → Redis SETNX → DB 唯一键 `UNIQUE(conv_id, client_msg_id)`（优化层可缺席，唯一键是正确性来源） |
| **调度系统（旁路）** | etcd 选主 + window 时间桶 + Redis BLPop 抢占 + SETNX 执行锁四级防重；任务自身幂等，锁全失效也只重复执行不产生错误结果；**永不进主链路** |
| **可观测性** | OTel 全链路 trace 逐跳传播（含 TCP 连接级跨进程传递）+ zap 结构化日志 |

---

## 架构

```
客户端 (Flutter 多端)
   │ 长连接: 自研二进制协议 over TCP      │ HTTP: 登录/历史/关系
┌──▼─────────────┐              ┌───────▼─────────────┐
│ Comet 网关 ×N   │              │ API 网关 (Hertz)     │
│ 连接·编解码·心跳 │              │ 路由·限流·JWT·日志    │
└──┬─────────────┘              └───────┬─────────────┘
   │        Kitex RPC (gRPC 协议) + etcd 服务发现/负载均衡/熔断
┌──▼────────────────────────────────────▼──────────────┐
│ Logic(登录) · Message(收发/seq) · Relation(用户/好友/群) │
│ Seq Svc(双 buffer 发号) · Job Svc(Kafka 消费者组·投递)  │
│ Scheduler(选主+分片广播: 对账/补偿/清理)                  │
└──┬───────────────────────────────────────────────────┘
   │
存储: Kafka(削峰/投递) · Redis(缓存/在线态/幂等/未读)
      MySQL: 关系库(按 user_id) + 消息库(按 conv_id, 2库×4表)
```

完整设计（含 ADR 决策记录、协议帧定义、投递时序）见 **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**。

---

## 技术栈

`Go` · `Hertz`（API 网关）· `Kitex`（RPC，gRPC 协议 + protobuf）· `Netpoll`（长连接）· `etcd`（服务发现/选主）· `Kafka`（投递削峰）· `Redis`（缓存/幂等/未读）· `MySQL`（分库分表）· `OpenTelemetry` + `zap`（可观测）· `Flutter`（双端客户端）

---

## 快速开始

```bash
# 1. 依赖 (MySQL 8.0 → 3307, Redis → 6379, Kafka KRaft → 9092)
docker compose -f deploy/docker-compose.yml up -d

# 2. etcd
etcd   # 或 ~/go/bin/etcd.exe

# 3. 应用进程 (seq → logic → message → job → comet → sched → yimd)
make run
```

关键环境变量：

| 变量 | 说明 |
|---|---|
| `YIM_MYSQL_DSN` | 默认 `root:root@tcp(127.0.0.1:3307)/yim?...`（Docker MySQL） |
| `YIM_KAFKA_BROKERS` | 设置 `127.0.0.1:9092` 启用 Kafka 投递形态；不设 = 进程内 channel 降级形态（同一 Deliverer 核心） |
| `YIM_RETRY_TIMER` | `wheel`（默认，层级时间轮）/ `native`（time.AfterFunc，压测对照） |
| `YIM_KAFKA_CONSUMERS` | push 消费并行度，默认 8 = 分区数 |
| `YIM_DELIVER_TRACE` | `1` = 输出 deliver 分段耗时（瓶颈定位） |

### 验证

```bash
bin/yimd.exe --selftest        # 网关链路
bin/yim-comet.exe -selftest    # 九场景端到端
bin/yim-sched.exe --selftest   # 调度任务端到端（造现场 → 执行 → SQL 断言）
```

---

## 压测（真实链路，零 mock）

`cmd/yim-bench`：HTTP 发送 → seq → MySQL 落库 → Kafka → Job → Comet → TCP 收 PUSH 回 ACK，每一跳都是真实组件。

```bash
bin/yim-bench.exe -users 50 -convs 25 -total 10000 -rate 1000   # 1000 msg/s 端到端
bin/yim-bench.exe -total 10000 -rate 500 -ack=false             # 风暴模式: 永不 ACK, 打满三级重试
```

开发机单机实测（Windows，原生 MySQL 对照 Docker/WSL2 后）：

| 发送速率 | 投递率 | e2e p50 | e2e p99 | 说明 |
|---|---|---|---|---|
| 500 msg/s | 99.99% | **29.4ms** | 122ms | 稳态 |
| **1000 msg/s** | **100.00%** | **32.7ms** | 74.7ms | 零重复零丢失，投递完全跟上发送 |
| 2000 msg/s | 100% | 37.1ms | 78.8ms | 发送侧（HTTP+落库）先饱和于 ~1072/s |

> 同一代码同一机器，仅换 MySQL 部署形态：500 msg/s 下 e2e p50 从 658ms（Docker/WSL2）降到 32.7ms——**20 倍差距是虚拟化 I/O 环境税**，不是代码问题。
>
> 压测过程连挖三层瓶颈并修复：连接池 `MaxIdle` 过小导致连接 churn → Windows 临时端口耗尽；ACK 累积确认 O(N) 全局扫描形成"越忙越慢"反馈环；投递完成标记单条 UPDATE 占 handle 90% → 改为按 shard 攒批 multi-row UPDATE。

---

## 目录结构

```
cmd/            yimd(API网关) yim-logic yim-relation yim-message yim-seq
                yim-comet yim-job yim-sched yim-bench(压测)
internal/       cache comet config hashring kitexcfg logger logic message
                middleware relation sched seq store timewheel trace
api/proto/      proto 定义 (消息/协议/各服务)
kitex_gen/      Kitex 生成代码
clients/yim_app Flutter 客户端 (桌面 + 移动)
deploy/         docker-compose / otel-collector / prometheus / grafana
scripts/        schema.sql / 迁移脚本 / 启动脚本
docs/           架构设计文档
```

---

## 里程碑

1. ✅ 单体跑通：proto → 收发/存储/推送
2. ✅ 拆微服务：etcd + Kitex + Logic/Message/Relation 分离
3. ✅ Comet 网关：自研协议 + Netpoll + 心跳 + 多端路由
4. ✅ 可靠投递：seq 发号 + ACK + 时间轮 + 离线箱
5. ✅ 缓存与账号：Redis 缓存体系 + 布隆 + JWT + 会话列表/已读
6. ✅ 调度系统：选主 + 分片广播 + 对账/补偿/清理任务
7. ✅ 压测打磨：真实链路压测 + 瓶颈定位 + 层级时间轮

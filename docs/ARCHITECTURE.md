# YIM 架构设计文档

> 高并发分布式 IM 系统。Go / Hertz / Kitex(gRPC) / Netpoll / etcd / Kafka / Redis / MySQL / Flutter。
>
> 设计原则：主链路全部为可水平扩展的无状态组件，可靠性靠分层兜底而非单一强依赖，一致性目标为最终一致。

## 1. 总体架构

```
┌────────────────────────────────────────────────────┐
│                    客户端 (Flutter)                  │
│   桌面端 (Win/macOS)          移动端 (iOS/Android)   │
│   同一 Dart 代码库, 多端同时在线, 各端独立 seq 同步     │
└───────┬──────────────────────────┬─────────────────┘
        │ 长连接: 自研二进制协议 over TCP   │ HTTP: 登录/历史拉取/关系管理
        │ (Netpoll, protobuf 编解码)      │
┌───────▼──────────────┐   ┌─────────────▼───────────────┐
│  Comet 连接网关 ×N     │   │  API 网关 (Hertz)            │
│  连接管理·协议编解码    │   │  路由·令牌桶限流·JWT鉴权·日志   │
│  心跳·多端会话         │   │  只做请求转发, 不含业务逻辑     │
└───────┬──────────────┘   └──────┬──────────────────────┘
        │ Kitex RPC (gRPC 协议)    │ Kitex RPC (gRPC 协议)
        │      etcd 服务发现 + Kitex 负载均衡/熔断/重试
┌───────▼─────────────────────────▼──────────────────────┐
│                       业务服务层                          │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │
│  │ Logic Svc    │ │ Message Svc  │ │ Relation Svc │    │
│  │ 登录·多端踢出  │ │ 收发·seq申请  │ │ 用户·好友·群   │    │
│  └──────┬───────┘ └──────┬───────┘ └──────────────┘    │
│         │                │ 本地消息表 + Kafka (最终一致)   │
│  ┌──────▼───────────────▼───────┐  ┌───────────────┐   │
│  │ Job Svc (Kafka 消费者组)       │  │ Seq Svc       │   │
│  │ 投递路由·在线推送·离线箱写入     │  │ 会话号段发号器  │   │
│  │ 内置时间轮: 重试/超时定时       │  │ (双buffer)    │   │
│  └──────┬───────────────────────┘  └───────────────┘   │
│         │ 内部Kitex RPC                                  │
│  ┌──────▼───────┐  ┌──────────────────────────────┐    │
│  │ Comet Router │  │ Scheduler Svc (旁路批任务)      │   │
│  │ uid→comet路由 │  │ etcd选主+分片广播: 对账/迁移/清理 │    │
│  └──────────────┘  └──────────────────────────────┘    │
└────────────────────────────────────────────────────────┘
        │
┌───────▼────────────────────────────────────────────────┐
│  存储层                                                   │
│  Kafka(削峰/投递) · Redis(缓存/在线状态/幂等/未读)          │
│  MySQL: 关系库(按user_id分) + 消息库(按conv_id分, 2库×4表)  │
│  对象存储: 图片/文件 (客户端直传, HTTP只发元数据)             │
└────────────────────────────────────────────────────────┘
```

### 架构决策记录（ADR 摘要）

| 决策 | 选择 | 为什么不是另一个 |
|---|---|---|
| 端到网关传输 | 自研 TCP 二进制协议 | WebSocket 协议栈全现成，无技术体现；私有协议可控编解码、省流量 |
| 长连接实现 | CloudWeGo Netpoll | 与 Hertz 同属 CloudWeGo；epoll 多路复用、单机连接数天花板高 |
| 服务间通信 | Kitex (gRPC 协议 + protobuf) | 裸 grpc-go 治理能力要全自己搭（超时/重试/熔断/负载均衡/服务发现）；Kitex 内置且与 Hertz 同属 CloudWeGo，协议仍是标准 gRPC，跨语言互通不受影响 |
| 异步解耦 | Kafka | 消费者组水平扩展天然削峰；生态成熟。延迟需求由时间轮承担 |
| 延迟任务 | 内存时间轮 | 调度系统扫描延迟分钟级，进不了主链路 |
| 周期批任务 | 自研调度系统 | 周期触发 + 分片并行是调度系统的主场，MQ 做不了 |
| 分布式事务 | 不用 | 消息链路用本地消息表 + Kafka + 兜底对账实现最终一致 |
| 服务发现 | etcd | 选主、配置、任务分配复用同一套协调设施 |

## 2. 传输协议（端 ↔ Comet）

### 2.1 协议帧

```
+--------------+----------+----------+-------------+-----------+
| body length  | version  | flag     | command     | body      |
| 4 bytes BE   | 1 byte   | 1 byte   | 2 bytes     | protobuf  |
+--------------+----------+----------+-------------+-----------+
```

- 长度前缀拆包（自定义 Decoder 处理粘包/半包）
- flag 位：加密标记 / 压缩标记 / 心跳标记
- 握手流程：CONNECT(携带 device_id + 预留加密字段) → AUTH(token, 走 Logic Svc 校验) → AUTH_OK(下发 sync_seq)

### 2.2 指令集

| Command | 方向 | 用途 |
|---|---|---|
| HEARTBEAT | 双向 | 保活，间隔 30s，3 次超时判定断线 |
| MESSAGE_UP | C→S | 上行消息 |
| MESSAGE_PUSH | S→C | 下行推送（轻通知，仅含 conv_id + seq） |
| ACK | 双向 | 逐条确认 |
| SYNC | C→S | 带 last_seq 拉增量（断线重连/唤醒后） |
| SYNC_RSP | S→C | 增量消息列表 |
| KICK | S→C | 多端互踢通知 |

### 2.3 推拉结合同步（核心）

- 下行 MESSAGE_PUSH 只推"轻通知"（conv_id + seq），**不带消息体**
- 客户端收到后对比本地 seq，缺号则主动 SYNC 拉取
- 收益：推送可丢可重（丢了走 SYNC 补齐）、天然有序、多端同步只需维护各端 ack_seq

### 2.4 Comet 实现状态（里程碑3 已完成）

- `internal/comet`：protocol（帧编解码 + MaxBodySize 上限防恶意长度前缀）/ connection（写互斥 + CAS 幂等关闭 + 心跳水位）/ bucket（16 桶分片的 uid→device→conn 索引，goim 风格）/ server（pump 读循环 + 10s 心跳扫描判死 + Drain 排水）/ handler（帧分发，业务全部下沉 RPC）
- 鉴权：JWTAuthenticator（里程碑5）—— Logic Svc 签发 HS256 JWT，Comet 本地验签零 RPC；AuthMode=dev 时放行 "dev.<uid>"（自检/联调）
- 北向：Kitex 服务 "yim.comet"（PushMessage/Kick/Drain/Stats），Job Svc 推送时的 NOT_ONLINE 语义由 delivered=false 承载
- 同设备重连顶替：新连接 auth 后顶掉 keeper 槽位，旧连接收 KICK
- 自检：`bin/yim-comet.exe -selftest`（真实 TCP：握手→上行→分片落库→幂等→心跳回显）

## 3. 消息可靠投递（三道防线）— 里程碑4 已落地（进程内 Job 形态）

**当前形态**：Kafka 未接入（Docker 代理未通），投递层为进程内 channel 消费（`internal/message/delivery.go`）。契约已按 Kafka 形态设计：`Push()` 入参 PushEvent 即未来写 Kafka 的事件，`deliver()` 即消费者逻辑，切 Kafka 只换实现不换契约。channel 满丢弃 → 防线3 兜底。

```
正常路径 (已实测):
  Client A ──MESSAGE_UP──▶ Comet ──Kitex──▶ Message Svc
                                            │ ① 幂等: UNIQUE(conv_id, client_msg_id) (布隆/Redis 前置筛为里程碑5)
                                            │ ② seq (Seq Svc) → ③ 消息 + local_message 同事务落库
                                            ▼
                                    JobPusher 消费 (deliver)
                                            │ ④ 查会话成员 (conversations.member_uids) → 逐成员
                                            │    接收者 sync seq +1 (重连判漏依据)
                                            │ ⑤ 广播全部 comet 实例 PushMessage
                                            │    (goim 模型: 不维护路由表, comet 本地判在线;
                                            │     实例列表 etcd resolve 5s 刷新, 每实例独立 client+熔断)
                                            ▼
                                       在线推送完成
  防线1: 重试定时     200ms → 800ms → 3.2s (time.AfterFunc; 压测里程碑换层级时间轮)
                      客户端 ACK_FOR_PUSH → Comet → AckPush RPC → 取消注册表 (累积确认 seq<=ack_seq)
  防线2: 离线箱       3 次未确认 或 目标离线 → offline_box (INSERT IGNORE 幂等), SYNC/重连补拉
  防线3: 调度系统扫描  里程碑6: 扫 local_message/offline_box 积压对账
```

- **不丢**：local_message 同事务 + 重试/离线箱 + 扫描补偿；**不重**：服务端 at-least-once，客户端按 seq 去重；**有序**：会话内 seq 单调
- 实测记录：不 ACK 的推送 200ms/800ms/3.2s 三次重推后落箱；ACK 后零重推；离线目标直接落箱

## 4. Seq Svc 发号器（对标微信 seqsvr）

- 每会话独立序列，号段模式：一次从 DB 申请一段（如 1~10000），内存分配
- **双 buffer**：当前号段用到 10% 时异步加载下一段，DB 宕机可继续发号一段时间
- 会话级分配避免全局 seq 热点；同一会话天然单调

## 5. 分布式调度系统（旁路批任务平台）

**职责边界：只承载周期性、批量、运维性质的任务，不出现在消息主链路。**

架构：etcd 选主（leader 触发调度）+ 任务分片广播（shard 按 uid/conv_id 取模）+ worker 抢占执行 + Redis SETNX 执行幂等。

| 任务 | 周期 | 分片键 |
|---|---|---|
| 离线箱积压扫描补偿 | 1min | uid |
| 未读数对账重算 | 10min | uid |
| 布隆过滤器双buffer重建 | 每日 | 单实例 |
| 冷消息在线迁移 | 低峰触发 | conv_id |
| 僵尸连接清理 | 1min | comet 实例 |

## 6. 存储与分片

- **关系库**：user_id hash → 2 库 × 4 表
- **消息库**：conversation_id hash → 2 库 × 4 表（消息量占 95%，分片的真正目标）；同一会话必落同一分片保证 seq 连续
- **分布式 ID**：消息主键用双 buffer 号段；conversation_id 嵌入创建者分片基因，避免跨分片二次路由
- **Redis 结构（里程碑5 已落地）**：
  - `idem:{conv_id}:{client_msg_id}` → SETNX 幂等精查（TTL 24h, 值=已落库 msg_id/seq, 快速返回不碰 DB）
  - `conv:{id}:members` → 会话成员 JSON（投递扇出热路径, cache-aside 10min）
  - `conv:{id}:meta` → 会话元数据（last_seq 等; 发送后失效）
  - `conv:{id}:recent` → ZSET 最近消息（member=protojson, score=seq; 只留最近 200 条）
  - `read:{uid}:{conv_id}` → 已读水位（未读数= last_seq - read_seq 的减数）
  - `route:{uid}` → comet 实例（多端 Hash, 预留）
  - `conv:{id}:seq` → 当前 seq（Seq Svc 后备, 预留）
- **布隆过滤器（进程内双 buffer）**：幂等正向粗筛——说"肯定没见过"才省 Redis 往返，假阳性/假阴性的代价都被 UNIQUE 约束兜住，可随时丢弃降级；影子代先挂再装载，装载期间 Add 双写两代
- **缓存策略**：Cache Aside + 过期时间 + nil 降级（Redis 不可用全走 DB 慢路径，优化组件可缺席）
- **在线扩容路径**：双写 → 调度系统分片迁移历史数据 → 对账校验 → 读切流 → 停旧写（整个迁移是调度系统的一个分片任务，进度记在 etcd）
- **跨库一致性实例（conv.last_seq）**：消息在分片库、conversations 在元库，last_seq 无法同事务推进——事务外 `UPDATE ... AND last_seq < ?` 单调推进 + 失效缓存，未读数短暂偏差由对账任务修正（最终一致的标准姿势）

## 7. Flutter 双端

- 单一代码库，feature-first 分包（features/chat, features/contact…）
- 平台差异：桌面端窗口管理/快捷键/系统托盘 + 多窗口；移动端后台保活/厂商推送兜底（架构上预留 PushProvider 接口，实现可 mock）
- 本地存储 SQLite 按会话存消息 + 本地 seq，断网可用、重连走 SYNC 补增量
- 长连接重连：指数退避 + 网络切换监听（connectivity）触发快速重连 + 重连即 SYNC

## 8. 可观测性与运维

- OpenTelemetry trace 贯穿 Client → Comet → Kitex RPC → Kafka → Job，一条消息全链路可查
  - HTTP 层：Hertz middleware 收发 W3C traceparent；RPC 层：kitex-contrib obs-opentelemetry Suite（TTHeader transport + metainfo 承载）
  - 坑位记录：Kitex server 的 endpoint middleware 拿到的 ctx 不含 transport 层 incoming metadata，自制传播中间件会静默丢 trace，必须走官方 Suite 的 stats.Tracer 钩子
- 核心指标：在线连接数、投递 P99 延迟、时间轮重试率、离线箱积压深度、号段水位
- 优雅发布：Comet 排水（停止收新连接 → 发 DISCONNECT 通知重连 → 超时强制断开 → 客户端重连至新实例 + SYNC 补增量）
- 传输层平台抽象（里程碑3 实测发现）：Netpoll 仅支持 Linux/macOS，v0.7.5 在 Windows 上 NewEventLoop 返回 (nil, nil) 不报错；Comet 参照 Hertz 的 network lib 抽象做法，同一 stream 接口（阻塞 Peek/Skip/Write）下 Linux 走 Netpoll 零拷贝、Windows 开发机走标准库回退，协议编解码层完全无感知

## 9. 压测实测（真实链路零 mock，开发机单机）

压测工具 `cmd/yim-bench`：HTTP 发送 → seq → 落库 → Kafka → Job → Comet → TCP 收 PUSH 回 ACK，无任何 mock。

| 指标 | 实测 |
|---|---|
| 端到端投递 P99（在线） | **74.7ms @ 1000 msg/s**（p50 32.7ms） |
| 单机稳定吞吐 | 1000 msg/s 投递完全跟上（零重复零丢失）；2000 msg/s 时发送侧先饱和于 ~1072/s |
| 环境税对照 | 同代码同机器，500 msg/s 下 e2e p50：Docker/WSL2 658ms → 原生 MySQL 32.7ms（20 倍） |

压测连挖三层瓶颈并修复：DB 池 `MaxIdleConns` 过小 → 连接 churn → Windows 临时端口耗尽（`bind: invalid argument`）；ACK 累积确认 O(N) 全局扫描 → "越忙越慢"反馈环（改按 (uid, conv_id) 分桶）；投递完成标记单条 UPDATE 占 handle 90% → 按 shard 攒批 multi-row UPDATE。

> 集群吞吐目标 ≥ 5万 msg/s 为多机扩展目标：无状态层（Comet/Job/网关）加机器线性扩，有状态点（seq/存储）按 conv 分片，扩展因子 = 分区数 × 消费组实例 × 存储实例 × 攒批系数。

## 10. 开发里程碑

1. **单体跑通**：proto 定义 → 单体内实现收发/存储/推送（先有能跑的系统）✅
2. **拆微服务**：etcd 服务发现 + Kitex(gRPC 协议) + Logic/Message/Relation 分离 ✅
3. **Comet 网关**：自研协议 + Netpoll + 心跳 + 多端路由 ✅
4. **可靠投递**：seq 发号器 + ACK + 时间轮 + 离线箱 ✅
5. **缓存与账号**：Redis 缓存体系 + 布隆 + JWT 鉴权(Logic Svc) + 会话列表/已读/建会话 ✅
6. **调度系统**：选主 + 分片广播 + 旁路任务接入 ✅
7. **打磨**：压测、在线迁移演示、Flutter 双端体验 ✅（压测：真实链路零 mock + 三层瓶颈定位 + 层级时间轮）

## 11. Relation Svc 关系域（里程碑9-10）

好友 / 群成员 / 用户资料 / 在线状态，数据落 yim_meta（与 users/conversations 同库）。

- **好友**：`friend_requests` (from,to) 主键行内状态机（0 pending / 1 accepted / 2 rejected），
  重复申请幂等；accept 同事务写 `friendships` 双向行。删除 = 删双行，重加走正常申请。
- **群**：`group_members(conv_id, uid, role)`，群主 role=1；踢人/退群同事务删
  `user_conversations` + 改 `conversations.member_uids`（relation 直写 message 域表
  = 已知债务：与"message→relation 好友校验"会成双向 RPC 依赖，第一轮以同库共表换解耦）。
  群名/群头像落 `conversations.name/avatar`（仅群主可改）。
- **资料**：`profile:{uid}` 缓存 10min，改资料失效；头像经网关 `/files/image` 上传
  （魔数白名单 + sha1 内容寻址落盘，路径白名单防穿越）。
- **在线状态**：`route:{uid}` SET 的存在性即"连接级在线"（60s TTL 心跳续期），查询制不订阅。
- **好友校验 fail-close**：CreateConv 单聊必须过 CheckFriendship——服务端强制而非网关前置
  （RPC 调用方同样要拦），relation 不可用 = 拒绝建单聊。
- **事件推侧（里程碑10，topic `yim.relation.event`）**：
  - relation 直发关系动作（申请/同意/删除/群变更），targets = 应通知用户
  - comet 发原始 PRESENCE（targets 空）→ relation 的 EnrichPresence 消费者补齐好友列表
    发回同 topic（topic 自解耦，避免 relation↔comet RPC 环）
  - 每个 comet 实例全量消费（per-instance consumer group），按 targets 过滤本地连接推
    `CMD_EVENT`；at-least-once 可重，丢失由客户端拉取制兜底（事件只说"发生了什么"）
  - Kafka 未配置 = 纯拉取形态（nil producer no-op），功能不挂
- **瞬态信令（里程碑12，Redis PubSub `yim.ephemeral`）**：输入中提示 / 单聊已读回执。
  与 Kafka 事件分工：Kafka 承载"必须尽量送达"的关系事件，PubSub 承载"丢了无所谓"的
  瞬态信令（不落库无消费组，延迟最低）；comet 收 CMD_TYPING 查 Redis 热键成员表扇出。

## 12. 消息搜索与撤回（里程碑13）

- **全文搜索** `SearchMessages`：用户全部会话（user_conversations 倒排，上限 200）
  的 MSG_TEXT LIKE 扫描，逐分片查 + 内存按时间归并，limit 硬顶 20。
  分库分表下 content 是 JSON 列，FULLTEXT 用不上；搜索低频只读，规模上去后演进 ES/倒排。
- **撤回** `RevokeMessage`：只能撤自己 2 分钟内的消息（服务端校验）；成功 = 复用
  SendMessage 写一条 MSG_REVOKE（走正常 seq/推送/幂等链路，对端经既有推送收到撤回事实）。
  原消息行保留（撤回是追加事实不是改写历史），客户端按 `ext.ref_msg_id` 隐藏原行。
  撤回消息的 client_msg_id = 原消息 msg_id → 重复撤回天然幂等。
- **回复引用 / 输入中 / 已读回执**（客户端 + 协议层）：回复 = `ext.ref_msg_id` +
  引用预览兜底；输入中 = CMD_TYPING 即发即弃；已读 = MarkRead 成功后发 ephemeral
  READ 信令（仅单聊，群聊回执噪音大）。

## 13. 运维环境变量

| 变量 | 缺省 | 说明 |
|---|---|---|
| `YIM_HTTP_ADDR` | `:8080` | 网关 Hertz 监听 |
| `YIM_COMET_TCP` | `:8900` | Comet 长连接监听 |
| `YIM_MESSAGE_RPC_ADDR` | `:9001` | Message Svc Kitex |
| `YIM_SEQ_RPC_ADDR` | `:9002` | Seq Svc Kitex |
| `YIM_COMET_RPC_ADDR` | `:9003` | Comet 北向 RPC |
| `YIM_LOGIC_RPC_ADDR` | `:9004` | Logic Svc (登录/JWT) |
| `YIM_RELATION_RPC_ADDR` | `:9005` | Relation Svc (好友/群/资料) |
| `YIM_MYSQL_DSN` | 127.0.0.1 元库 | yim_meta（分片库同机按序号） |
| `YIM_REDIS_ADDR` | `127.0.0.1:6379` | 缓存/幂等/水位/路由；不可用全降级走 DB |
| `YIM_ETCD_ENDPOINTS` | `127.0.0.1:2379` | 服务发现 |
| `YIM_KAFKA_BROKERS` | 空 | 空 = 降级形态（进程内投递 + 纯拉取事件） |
| `YIM_OTEL_ENDPOINT` | `127.0.0.1:4317` | OTLP gRPC |
| `YIM_JWT_SECRET` | dev 密钥 | **生产必改** |
| `YIM_AUTH_MODE` | `dev` | dev 放行 `dev.<uid>` token（压测/自测后门），生产必设其他值 |
| `YIM_FILES_DIR` | `./data/files` | 头像/聊天图片落盘根目录 |
| `YIM_MAX_AVATAR_BYTES` | 2MB | 头像上限 |
| `YIM_MAX_IMAGE_BYTES` | 10MB | 聊天图片上限（multipart body 上限 = 此值 + 64KB） |
| `YIM_SEQ_STEP` | 10000 | 号段步长 |

数据库迁移：增量 SQL 在 `scripts/migrate_m*.sql`（m9 好友/群/头像表，m11 群名/群头像列），
新环境直接跑 `scripts/schema.sql` + 依序补 migrate。

## 14. 打包发布（里程碑14）

- **图标**：`build_assets/` 生成脚本 (Pillow) → `windows/runner/resources/app_icon.ico`
  + Android `mipmap-*/ic_launcher(.round)`。换图标 = 改脚本重跑。
- **Android 签名**：上传密钥 `android/key/yim-upload.jks`（gitignored，含
  `key/key.properties`；密钥口令见该文件，生产环境重新生成）。
  gradle release 签名配置在 `android/app/build.gradle.kts`，配置缺失自动回退
  debug 签名保证 CI 可编译。`flutter build apk --release` 即出签名包。
  Windows 侧 release 签名（signtool + 代码签名证书）留待分发需求出现再接。
- **TLS**：`YIM_TLS_CERT` / `YIM_TLS_KEY` 指向 PEM 证书/私钥，配置后 comet 长连接
  listener 自动升级 `tls.Server`，**网关（Hertz）同步整体升级 HTTPS**（一价开关，
  两端都不再收明文）。自签开发证书用 `scripts/gen-tls.cmd` 生成
  （SAN 覆盖 localhost/127.0.0.1，产出 `deploy/tls/`，同时打印客户端 pin 用
  sha256 指纹）。客户端 `--dart-define YIM_TLS=1 YIM_API=https://... YIM_TLS_PIN=<指纹hex>`：
  长连接走 `SecureSocket`，Dio 挂 `badCertificateCallback`，pin 比对证书 sha256
  （留空 = 放行任意证书，仅限内网联调）。限制：netpoll 路径（Linux）持有原始 fd
  无法包 TLS——生产形态推荐前置 LB（LVS/Envoy/Nginx）做 TLS 卸载，内部链路保持
  明文（内网信任域）。
- **dev 后门**：服务端 `YIM_AUTH_MODE=dev` 时放行 `dev.<uid>` token（压测/联调），
  生产必设其他值 + 改 `YIM_JWT_SECRET`。客户端 UI 无绕过入口。

-- YIM 里程碑1 schema
-- 执行: mysql -h127.0.0.1 -uroot -proot < scripts/schema.sql
-- 幂等: 全部 IF NOT EXISTS

-- ========== 元库 (不分片) ==========
CREATE DATABASE IF NOT EXISTS yim_meta DEFAULT CHARACTER SET utf8mb4;
USE yim_meta;

-- 号段表 (seq.Pool 的持久层)
CREATE TABLE IF NOT EXISTS seq_segment (
  biz        varchar(16) NOT NULL COMMENT 'conv/sync/msg/uid/conv_id',
  key_id     bigint      NOT NULL,
  max_id     bigint      NOT NULL DEFAULT 0,
  step       int         NOT NULL,
  version    bigint      NOT NULL DEFAULT 0,
  updated_at timestamp   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (biz, key_id)
) ENGINE=InnoDB;

-- slot 映射表 (预留: 当前映射为代码内确定性计算, 扩容时启用此表)
CREATE TABLE IF NOT EXISTS slot_mapping (
  slot      smallint unsigned NOT NULL,
  db_index  tinyint  unsigned NOT NULL,
  table_index tinyint unsigned NOT NULL,
  PRIMARY KEY (slot)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
  uid           bigint      NOT NULL,
  nickname      varchar(64) NOT NULL DEFAULT '',
  password_hash varchar(100) NOT NULL DEFAULT '' COMMENT 'bcrypt, 里程碑5',
  create_time datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (uid),
  UNIQUE KEY uk_nickname (nickname)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS conversations (
  conv_id     bigint      NOT NULL,
  type        tinyint     NOT NULL COMMENT '1单聊 2群聊',
  member_uids json        NOT NULL,
  last_seq    bigint      NOT NULL DEFAULT 0,
  create_time datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (conv_id)
) ENGINE=InnoDB;

-- ========== 消息库 (2库 × 4表, 对应 store.MsgShard) ==========
-- 主键 (conv_id, seq): 聚簇即会话内有序, 按 seq 范围拉取免回表;
-- 无自增主键: msg_id 来自号段, 分布式部署不冲突。

-- 表模板 (先建, 供 LIKE 复制; 用完可 DROP)
CREATE TABLE IF NOT EXISTS _message_template (
  msg_id        bigint      NOT NULL,
  conv_id       bigint      NOT NULL,
  from_uid      bigint      NOT NULL,
  seq           bigint      NOT NULL COMMENT '会话内单调',
  msg_type      tinyint     NOT NULL,
  content       json        NOT NULL,
  client_msg_id bigint      NOT NULL COMMENT '幂等键',
  server_time_ms bigint     NOT NULL,
  PRIMARY KEY (conv_id, seq),
  UNIQUE KEY uk_client_msg (conv_id, client_msg_id),
  KEY idx_msg_id (conv_id, msg_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS _local_message_template (
  msg_id         bigint    NOT NULL,
  conv_id        bigint    NOT NULL,
  status         tinyint   NOT NULL DEFAULT 0 COMMENT '0待投递 1已投递 2离线',
  create_time_ms bigint    NOT NULL,
  PRIMARY KEY (conv_id, msg_id)
) ENGINE=InnoDB;

CREATE DATABASE IF NOT EXISTS yim_msg_0 DEFAULT CHARACTER SET utf8mb4;
CREATE DATABASE IF NOT EXISTS yim_msg_1 DEFAULT CHARACTER SET utf8mb4;

USE yim_msg_0;
CREATE TABLE IF NOT EXISTS message_00 LIKE yim_meta._message_template;
CREATE TABLE IF NOT EXISTS message_01 LIKE yim_meta._message_template;
CREATE TABLE IF NOT EXISTS message_02 LIKE yim_meta._message_template;
CREATE TABLE IF NOT EXISTS message_03 LIKE yim_meta._message_template;
CREATE TABLE IF NOT EXISTS local_message LIKE yim_meta._local_message_template;

USE yim_msg_1;
CREATE TABLE IF NOT EXISTS message_00 LIKE yim_meta._message_template;
CREATE TABLE IF NOT EXISTS message_01 LIKE yim_meta._message_template;
CREATE TABLE IF NOT EXISTS message_02 LIKE yim_meta._message_template;
CREATE TABLE IF NOT EXISTS message_03 LIKE yim_meta._message_template;
CREATE TABLE IF NOT EXISTS local_message LIKE yim_meta._local_message_template;

USE yim_meta;

-- ========== 离线箱 (防线: 推送不在线时落箱, 调度系统扫描补偿) ==========
CREATE TABLE IF NOT EXISTS yim_meta.offline_box (
  uid         bigint  NOT NULL COMMENT '投递目标',
  conv_id     bigint  NOT NULL,
  msg_id      bigint  NOT NULL,
  seq         bigint  NOT NULL COMMENT '会话内 seq, 客户端 SYNC 拉取起点',
  status      tinyint NOT NULL DEFAULT 0 COMMENT '0待补偿 1已补偿(已拉取)',
  create_time_ms bigint NOT NULL,
  PRIMARY KEY (uid, conv_id, seq)
) ENGINE=InnoDB;

-- ========== 里程碑5: 会话状态/用户索引 ==========
-- 已读水位: unread = conversations.last_seq - read_seq (对账任务兜底重算)
CREATE TABLE IF NOT EXISTS yim_meta.user_conv_state (
  uid            bigint NOT NULL,
  conv_id        bigint NOT NULL,
  read_seq       bigint NOT NULL DEFAULT 0,
  update_time_ms bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (uid, conv_id)
) ENGINE=InnoDB;

-- 用户→会话索引: member_uids 是 JSON 列无法按 uid 反查, 发消息时冗余写此表
CREATE TABLE IF NOT EXISTS yim_meta.user_conversations (
  uid            bigint NOT NULL,
  conv_id        bigint NOT NULL,
  create_time_ms bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (uid, conv_id)
) ENGINE=InnoDB;

-- 单聊唯一索引: (min_uid, max_uid) → conv_id, 同对用户重复建单聊返回已有会话
CREATE TABLE IF NOT EXISTS yim_meta.single_chat_index (
  a_uid   bigint NOT NULL COMMENT 'min(uid)',
  b_uid   bigint NOT NULL COMMENT 'max(uid)',
  conv_id bigint NOT NULL,
  PRIMARY KEY (a_uid, b_uid)
) ENGINE=InnoDB;

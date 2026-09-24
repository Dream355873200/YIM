-- 里程碑9 迁移: 关系域 (Relation Svc)
-- 执行: mysql -h127.0.0.1 -uroot -proot < scripts/migrate_m9.sql
-- 说明: schema.sql 保持幂等建表; MySQL 无 ADD COLUMN IF NOT EXISTS,
-- ALTER 类变更独立放本脚本 (见 13-ops.md "IF NOT EXISTS 不会补列"的坑)

USE yim_meta;

-- 用户资料扩展: 头像 (相对 URL, /files/avatar/..)
ALTER TABLE users
  ADD COLUMN avatar varchar(255) NOT NULL DEFAULT '' COMMENT '相对URL /files/avatar/xx.png';

-- 好友关系: 双向行 (uid→friend_uid 各一行), 列表查询走 PK 前缀
CREATE TABLE IF NOT EXISTS friendships (
  uid            bigint      NOT NULL,
  friend_uid     bigint      NOT NULL,
  remark         varchar(64) NOT NULL DEFAULT '' COMMENT '好友备注, 预留',
  create_time_ms bigint      NOT NULL,
  PRIMARY KEY (uid, friend_uid)
) ENGINE=InnoDB;

-- 好友申请: 一行/有向对, 状态机在行内翻转 (天然幂等, 无需发号)
CREATE TABLE IF NOT EXISTS friend_requests (
  from_uid       bigint       NOT NULL,
  to_uid         bigint       NOT NULL,
  message        varchar(255) NOT NULL DEFAULT '',
  status         tinyint      NOT NULL DEFAULT 0 COMMENT '0 pending 1 accepted 2 rejected',
  create_time_ms bigint       NOT NULL,
  update_time_ms bigint       NOT NULL,
  PRIMARY KEY (from_uid, to_uid),
  KEY idx_to_status (to_uid, status, update_time_ms) COMMENT '收件箱列表'
) ENGINE=InnoDB;

-- 群成员: role 0 member / 1 owner (2 admin 预留)
CREATE TABLE IF NOT EXISTS group_members (
  conv_id      bigint  NOT NULL,
  uid          bigint  NOT NULL,
  role         tinyint NOT NULL DEFAULT 0,
  join_time_ms bigint  NOT NULL,
  PRIMARY KEY (conv_id, uid),
  KEY idx_uid (uid) COMMENT '我加入的群'
) ENGINE=InnoDB;

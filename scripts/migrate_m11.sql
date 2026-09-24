-- 里程碑11: 群聊完整化 —— 群名 + 群头像
-- conversations 加群元数据列 (单聊两列恒空串, 不查询区分)
USE yim_meta;

ALTER TABLE conversations
    ADD COLUMN name   VARCHAR(64)  NOT NULL DEFAULT '',
    ADD COLUMN avatar VARCHAR(255) NOT NULL DEFAULT '';

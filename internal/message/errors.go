// 业务哨兵错误: handler 层据此映射 proto Error{code,msg}。
// 码段分配: 20-27 归 Relation 域 (见 service_relation.proto 注释),
// message 域复用 22 (非好友) / 25 (非成员)。
package message

import "errors"

// ErrNotMember PullHistory 成员校验失败: 发起者不是会话成员 (里程碑9 越权防护)。
var ErrNotMember = errors.New("not a member of this conversation")

// ErrNotFriends CreateConv 单聊好友校验失败 (里程碑9; 含 relation 不可用 fail-close)。
var ErrNotFriends = errors.New("not friends")

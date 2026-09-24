// relation_client.go RelationClient 的 Kitex 客户端适配 (里程碑9)。
// 接口在 conversations.go 定义 (message 域只依赖最小面), 这里接 kitex 生成码。
// fail-close 语义: RPC 传输层错误 (超时/不可达) 一律按校验失败返回 ——
// 好友关系是产品边界, relation 抖动时宁可拒绝建单聊也不放行。
package message

import (
	"context"

	"github.com/yim/kitex_gen/yim"
	relationservice "github.com/yim/kitex_gen/yim/relationservice"
)

type relationAdapter struct {
	cli relationservice.Client
}

func NewRelationAdapter(cli relationservice.Client) RelationClient {
	return &relationAdapter{cli: cli}
}

func (a *relationAdapter) CheckFriendship(ctx context.Context, aUID, bUID int64) (bool, *yim.Error) {
	rsp, err := a.cli.CheckFriendship(ctx, &yim.CheckFriendshipReq{AUid: aUID, BUid: bUID})
	if err != nil {
		return false, &yim.Error{Code: 22, Msg: err.Error()}
	}
	return rsp.GetIsFriend(), nil
}

func (a *relationAdapter) AddGroupMembers(ctx context.Context, convID int64, memberUIDs []int64, ownerUID int64) *yim.Error {
	rsp, err := a.cli.AddGroupMembers(ctx, &yim.AddGroupMembersReq{
		ConvId: convID, MemberUids: memberUIDs, OwnerUid: ownerUID})
	if err != nil {
		return &yim.Error{Code: 1, Msg: err.Error()}
	}
	return rsp.Error
}

// RelationHandler: Kitex gRPC handler 适配层 —— proto 契约 ↔ internal/relation。
// 只做参数搬运; 业务错误以 rsp.Error (Error{code,msg}) 表达, 不走 gRPC status。
package main

import (
	"context"

	"github.com/yim/internal/relation"
	"github.com/yim/kitex_gen/yim"
)

// RelationHandler implements yim.RelationService.
type RelationHandler struct {
	svc *relation.Service
}

func (h *RelationHandler) SendFriendRequest(ctx context.Context, req *yim.SendFriendRequestReq) (*yim.SendFriendRequestRsp, error) {
	return &yim.SendFriendRequestRsp{Error: h.svc.SendFriendRequest(ctx, req.GetFromUid(), req.GetToUid(), req.GetMessage())}, nil
}

func (h *RelationHandler) HandleFriendRequest(ctx context.Context, req *yim.HandleFriendRequestReq) (*yim.HandleFriendRequestRsp, error) {
	return &yim.HandleFriendRequestRsp{Error: h.svc.HandleFriendRequest(ctx, req.GetOpUid(), req.GetFromUid(), req.GetAccept())}, nil
}

func (h *RelationHandler) ListFriendRequests(ctx context.Context, req *yim.ListFriendRequestsReq) (*yim.ListFriendRequestsRsp, error) {
	reqs, bizErr := h.svc.ListFriendRequests(ctx, req.GetUid(), req.GetIncoming())
	return &yim.ListFriendRequestsRsp{Requests: reqs, Error: bizErr}, nil
}

func (h *RelationHandler) ListFriends(ctx context.Context, req *yim.ListFriendsReq) (*yim.ListFriendsRsp, error) {
	var pageNum, pageSize int32
	if p := req.GetPage(); p != nil {
		pageNum, pageSize = p.PageNum, p.PageSize
	}
	friends, hasMore, bizErr := h.svc.ListFriends(ctx, req.GetUid(), pageNum, pageSize)
	return &yim.ListFriendsRsp{Friends: friends, HasMore: hasMore, Error: bizErr}, nil
}

func (h *RelationHandler) DeleteFriend(ctx context.Context, req *yim.DeleteFriendReq) (*yim.DeleteFriendRsp, error) {
	return &yim.DeleteFriendRsp{Error: h.svc.DeleteFriend(ctx, req.GetOpUid(), req.GetFriendUid())}, nil
}

func (h *RelationHandler) CheckFriendship(ctx context.Context, req *yim.CheckFriendshipReq) (*yim.CheckFriendshipRsp, error) {
	ok, bizErr := h.svc.CheckFriendship(ctx, req.GetAUid(), req.GetBUid())
	if bizErr != nil {
		return &yim.CheckFriendshipRsp{IsFriend: false}, nil
	}
	return &yim.CheckFriendshipRsp{IsFriend: ok}, nil
}

func (h *RelationHandler) AddGroupMembers(ctx context.Context, req *yim.AddGroupMembersReq) (*yim.AddGroupMembersRsp, error) {
	return &yim.AddGroupMembersRsp{Error: h.svc.AddGroupMembers(ctx, req.GetConvId(), req.GetMemberUids(), req.GetOwnerUid())}, nil
}

func (h *RelationHandler) RemoveGroupMember(ctx context.Context, req *yim.RemoveGroupMemberReq) (*yim.RemoveGroupMemberRsp, error) {
	return &yim.RemoveGroupMemberRsp{Error: h.svc.RemoveGroupMember(ctx, req.GetOpUid(), req.GetConvId(), req.GetTargetUid())}, nil
}

func (h *RelationHandler) QuitGroup(ctx context.Context, req *yim.QuitGroupReq) (*yim.QuitGroupRsp, error) {
	return &yim.QuitGroupRsp{Error: h.svc.QuitGroup(ctx, req.GetUid(), req.GetConvId())}, nil
}

func (h *RelationHandler) ListGroupMembers(ctx context.Context, req *yim.ListGroupMembersReq) (*yim.ListGroupMembersRsp, error) {
	members, bizErr := h.svc.ListGroupMembers(ctx, req.GetConvId())
	return &yim.ListGroupMembersRsp{Members: members, Error: bizErr}, nil
}

func (h *RelationHandler) UpdateGroupInfo(ctx context.Context, req *yim.UpdateGroupInfoReq) (*yim.UpdateGroupInfoRsp, error) {
	return &yim.UpdateGroupInfoRsp{
		Error: h.svc.UpdateGroupInfo(ctx, req.GetOpUid(), req.GetConvId(), req.GetName(), req.GetAvatar()),
	}, nil
}

func (h *RelationHandler) GetProfiles(ctx context.Context, req *yim.GetProfilesReq) (*yim.GetProfilesRsp, error) {
	profiles, bizErr := h.svc.GetProfiles(ctx, req.GetUids())
	return &yim.GetProfilesRsp{Profiles: profiles, Error: bizErr}, nil
}

func (h *RelationHandler) SearchUsers(ctx context.Context, req *yim.SearchUsersReq) (*yim.SearchUsersRsp, error) {
	users, bizErr := h.svc.SearchUsers(ctx, req.GetKeyword(), req.GetOpUid(), int(req.GetLimit()))
	return &yim.SearchUsersRsp{Profiles: users, Error: bizErr}, nil
}

func (h *RelationHandler) UpdateProfile(ctx context.Context, req *yim.UpdateProfileReq) (*yim.UpdateProfileRsp, error) {
	p, bizErr := h.svc.UpdateProfile(ctx, req.GetUid(), req.GetNickname(), req.GetAvatar())
	return &yim.UpdateProfileRsp{Profile: p, Error: bizErr}, nil
}

func (h *RelationHandler) GetPresence(ctx context.Context, req *yim.GetPresenceReq) (*yim.GetPresenceRsp, error) {
	presences, bizErr := h.svc.GetPresence(ctx, req.GetUids())
	return &yim.GetPresenceRsp{Presences: presences, Error: bizErr}, nil
}

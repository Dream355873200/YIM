// This is a generated file - do not edit.
//
// Generated from service_relation.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'service_relation.pb.dart' as $1;
import 'service_relation.pbjson.dart';

export 'service_relation.pb.dart';

abstract class RelationServiceBase extends $pb.GeneratedService {
  $async.Future<$1.SendFriendRequestRsp> sendFriendRequest(
      $pb.ServerContext ctx, $1.SendFriendRequestReq request);
  $async.Future<$1.HandleFriendRequestRsp> handleFriendRequest(
      $pb.ServerContext ctx, $1.HandleFriendRequestReq request);
  $async.Future<$1.ListFriendRequestsRsp> listFriendRequests(
      $pb.ServerContext ctx, $1.ListFriendRequestsReq request);
  $async.Future<$1.ListFriendsRsp> listFriends(
      $pb.ServerContext ctx, $1.ListFriendsReq request);
  $async.Future<$1.DeleteFriendRsp> deleteFriend(
      $pb.ServerContext ctx, $1.DeleteFriendReq request);
  $async.Future<$1.CheckFriendshipRsp> checkFriendship(
      $pb.ServerContext ctx, $1.CheckFriendshipReq request);
  $async.Future<$1.AddGroupMembersRsp> addGroupMembers(
      $pb.ServerContext ctx, $1.AddGroupMembersReq request);
  $async.Future<$1.RemoveGroupMemberRsp> removeGroupMember(
      $pb.ServerContext ctx, $1.RemoveGroupMemberReq request);
  $async.Future<$1.QuitGroupRsp> quitGroup(
      $pb.ServerContext ctx, $1.QuitGroupReq request);
  $async.Future<$1.ListGroupMembersRsp> listGroupMembers(
      $pb.ServerContext ctx, $1.ListGroupMembersReq request);
  $async.Future<$1.UpdateGroupInfoRsp> updateGroupInfo(
      $pb.ServerContext ctx, $1.UpdateGroupInfoReq request);
  $async.Future<$1.GetProfilesRsp> getProfiles(
      $pb.ServerContext ctx, $1.GetProfilesReq request);
  $async.Future<$1.SearchUsersRsp> searchUsers(
      $pb.ServerContext ctx, $1.SearchUsersReq request);
  $async.Future<$1.UpdateProfileRsp> updateProfile(
      $pb.ServerContext ctx, $1.UpdateProfileReq request);
  $async.Future<$1.GetPresenceRsp> getPresence(
      $pb.ServerContext ctx, $1.GetPresenceReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SendFriendRequest':
        return $1.SendFriendRequestReq();
      case 'HandleFriendRequest':
        return $1.HandleFriendRequestReq();
      case 'ListFriendRequests':
        return $1.ListFriendRequestsReq();
      case 'ListFriends':
        return $1.ListFriendsReq();
      case 'DeleteFriend':
        return $1.DeleteFriendReq();
      case 'CheckFriendship':
        return $1.CheckFriendshipReq();
      case 'AddGroupMembers':
        return $1.AddGroupMembersReq();
      case 'RemoveGroupMember':
        return $1.RemoveGroupMemberReq();
      case 'QuitGroup':
        return $1.QuitGroupReq();
      case 'ListGroupMembers':
        return $1.ListGroupMembersReq();
      case 'UpdateGroupInfo':
        return $1.UpdateGroupInfoReq();
      case 'GetProfiles':
        return $1.GetProfilesReq();
      case 'SearchUsers':
        return $1.SearchUsersReq();
      case 'UpdateProfile':
        return $1.UpdateProfileReq();
      case 'GetPresence':
        return $1.GetPresenceReq();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SendFriendRequest':
        return sendFriendRequest(ctx, request as $1.SendFriendRequestReq);
      case 'HandleFriendRequest':
        return handleFriendRequest(ctx, request as $1.HandleFriendRequestReq);
      case 'ListFriendRequests':
        return listFriendRequests(ctx, request as $1.ListFriendRequestsReq);
      case 'ListFriends':
        return listFriends(ctx, request as $1.ListFriendsReq);
      case 'DeleteFriend':
        return deleteFriend(ctx, request as $1.DeleteFriendReq);
      case 'CheckFriendship':
        return checkFriendship(ctx, request as $1.CheckFriendshipReq);
      case 'AddGroupMembers':
        return addGroupMembers(ctx, request as $1.AddGroupMembersReq);
      case 'RemoveGroupMember':
        return removeGroupMember(ctx, request as $1.RemoveGroupMemberReq);
      case 'QuitGroup':
        return quitGroup(ctx, request as $1.QuitGroupReq);
      case 'ListGroupMembers':
        return listGroupMembers(ctx, request as $1.ListGroupMembersReq);
      case 'UpdateGroupInfo':
        return updateGroupInfo(ctx, request as $1.UpdateGroupInfoReq);
      case 'GetProfiles':
        return getProfiles(ctx, request as $1.GetProfilesReq);
      case 'SearchUsers':
        return searchUsers(ctx, request as $1.SearchUsersReq);
      case 'UpdateProfile':
        return updateProfile(ctx, request as $1.UpdateProfileReq);
      case 'GetPresence':
        return getPresence(ctx, request as $1.GetPresenceReq);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => RelationServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => RelationServiceBase$messageJson;
}

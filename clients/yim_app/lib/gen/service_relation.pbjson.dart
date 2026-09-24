// This is a generated file - do not edit.
//
// Generated from service_relation.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'common.pbjson.dart' as $0;

@$core.Deprecated('Use presenceDescriptor instead')
const Presence$json = {
  '1': 'Presence',
  '2': [
    {'1': 'PRESENCE_UNKNOWN', '2': 0},
    {'1': 'PRESENCE_OFFLINE', '2': 1},
    {'1': 'PRESENCE_ONLINE', '2': 2},
  ],
};

/// Descriptor for `Presence`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List presenceDescriptor = $convert.base64Decode(
    'CghQcmVzZW5jZRIUChBQUkVTRU5DRV9VTktOT1dOEAASFAoQUFJFU0VOQ0VfT0ZGTElORRABEh'
    'MKD1BSRVNFTkNFX09OTElORRAC');

@$core.Deprecated('Use sendFriendRequestReqDescriptor instead')
const SendFriendRequestReq$json = {
  '1': 'SendFriendRequestReq',
  '2': [
    {'1': 'from_uid', '3': 1, '4': 1, '5': 3, '10': 'fromUid'},
    {'1': 'to_uid', '3': 2, '4': 1, '5': 3, '10': 'toUid'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SendFriendRequestReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendFriendRequestReqDescriptor = $convert.base64Decode(
    'ChRTZW5kRnJpZW5kUmVxdWVzdFJlcRIZCghmcm9tX3VpZBgBIAEoA1IHZnJvbVVpZBIVCgZ0b1'
    '91aWQYAiABKANSBXRvVWlkEhgKB21lc3NhZ2UYAyABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use sendFriendRequestRspDescriptor instead')
const SendFriendRequestRsp$json = {
  '1': 'SendFriendRequestRsp',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `SendFriendRequestRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendFriendRequestRspDescriptor = $convert.base64Decode(
    'ChRTZW5kRnJpZW5kUmVxdWVzdFJzcBIgCgVlcnJvchgBIAEoCzIKLnlpbS5FcnJvclIFZXJyb3'
    'I=');

@$core.Deprecated('Use handleFriendRequestReqDescriptor instead')
const HandleFriendRequestReq$json = {
  '1': 'HandleFriendRequestReq',
  '2': [
    {'1': 'op_uid', '3': 1, '4': 1, '5': 3, '10': 'opUid'},
    {'1': 'from_uid', '3': 2, '4': 1, '5': 3, '10': 'fromUid'},
    {'1': 'accept', '3': 3, '4': 1, '5': 8, '10': 'accept'},
  ],
};

/// Descriptor for `HandleFriendRequestReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handleFriendRequestReqDescriptor =
    $convert.base64Decode(
        'ChZIYW5kbGVGcmllbmRSZXF1ZXN0UmVxEhUKBm9wX3VpZBgBIAEoA1IFb3BVaWQSGQoIZnJvbV'
        '91aWQYAiABKANSB2Zyb21VaWQSFgoGYWNjZXB0GAMgASgIUgZhY2NlcHQ=');

@$core.Deprecated('Use handleFriendRequestRspDescriptor instead')
const HandleFriendRequestRsp$json = {
  '1': 'HandleFriendRequestRsp',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `HandleFriendRequestRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handleFriendRequestRspDescriptor =
    $convert.base64Decode(
        'ChZIYW5kbGVGcmllbmRSZXF1ZXN0UnNwEiAKBWVycm9yGAEgASgLMgoueWltLkVycm9yUgVlcn'
        'Jvcg==');

@$core.Deprecated('Use friendRequestDescriptor instead')
const FriendRequest$json = {
  '1': 'FriendRequest',
  '2': [
    {'1': 'from_uid', '3': 1, '4': 1, '5': 3, '10': 'fromUid'},
    {'1': 'to_uid', '3': 2, '4': 1, '5': 3, '10': 'toUid'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'status', '3': 4, '4': 1, '5': 5, '10': 'status'},
    {'1': 'create_time_ms', '3': 5, '4': 1, '5': 3, '10': 'createTimeMs'},
  ],
};

/// Descriptor for `FriendRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendRequestDescriptor = $convert.base64Decode(
    'Cg1GcmllbmRSZXF1ZXN0EhkKCGZyb21fdWlkGAEgASgDUgdmcm9tVWlkEhUKBnRvX3VpZBgCIA'
    'EoA1IFdG9VaWQSGAoHbWVzc2FnZRgDIAEoCVIHbWVzc2FnZRIWCgZzdGF0dXMYBCABKAVSBnN0'
    'YXR1cxIkCg5jcmVhdGVfdGltZV9tcxgFIAEoA1IMY3JlYXRlVGltZU1z');

@$core.Deprecated('Use listFriendRequestsReqDescriptor instead')
const ListFriendRequestsReq$json = {
  '1': 'ListFriendRequestsReq',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'incoming', '3': 2, '4': 1, '5': 8, '10': 'incoming'},
  ],
};

/// Descriptor for `ListFriendRequestsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFriendRequestsReqDescriptor = $convert.base64Decode(
    'ChVMaXN0RnJpZW5kUmVxdWVzdHNSZXESEAoDdWlkGAEgASgDUgN1aWQSGgoIaW5jb21pbmcYAi'
    'ABKAhSCGluY29taW5n');

@$core.Deprecated('Use listFriendRequestsRspDescriptor instead')
const ListFriendRequestsRsp$json = {
  '1': 'ListFriendRequestsRsp',
  '2': [
    {
      '1': 'requests',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yim.FriendRequest',
      '10': 'requests'
    },
    {'1': 'error', '3': 2, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `ListFriendRequestsRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFriendRequestsRspDescriptor = $convert.base64Decode(
    'ChVMaXN0RnJpZW5kUmVxdWVzdHNSc3ASLgoIcmVxdWVzdHMYASADKAsyEi55aW0uRnJpZW5kUm'
    'VxdWVzdFIIcmVxdWVzdHMSIAoFZXJyb3IYAiABKAsyCi55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use friendBriefDescriptor instead')
const FriendBrief$json = {
  '1': 'FriendBrief',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'create_time_ms', '3': 4, '4': 1, '5': 3, '10': 'createTimeMs'},
  ],
};

/// Descriptor for `FriendBrief`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendBriefDescriptor = $convert.base64Decode(
    'CgtGcmllbmRCcmllZhIQCgN1aWQYASABKANSA3VpZBIaCghuaWNrbmFtZRgCIAEoCVIIbmlja2'
    '5hbWUSFgoGYXZhdGFyGAMgASgJUgZhdmF0YXISJAoOY3JlYXRlX3RpbWVfbXMYBCABKANSDGNy'
    'ZWF0ZVRpbWVNcw==');

@$core.Deprecated('Use listFriendsReqDescriptor instead')
const ListFriendsReq$json = {
  '1': 'ListFriendsReq',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'page', '3': 2, '4': 1, '5': 11, '6': '.yim.PageInfo', '10': 'page'},
  ],
};

/// Descriptor for `ListFriendsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFriendsReqDescriptor = $convert.base64Decode(
    'Cg5MaXN0RnJpZW5kc1JlcRIQCgN1aWQYASABKANSA3VpZBIhCgRwYWdlGAIgASgLMg0ueWltLl'
    'BhZ2VJbmZvUgRwYWdl');

@$core.Deprecated('Use listFriendsRspDescriptor instead')
const ListFriendsRsp$json = {
  '1': 'ListFriendsRsp',
  '2': [
    {
      '1': 'friends',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yim.FriendBrief',
      '10': 'friends'
    },
    {'1': 'has_more', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
    {'1': 'error', '3': 3, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `ListFriendsRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFriendsRspDescriptor = $convert.base64Decode(
    'Cg5MaXN0RnJpZW5kc1JzcBIqCgdmcmllbmRzGAEgAygLMhAueWltLkZyaWVuZEJyaWVmUgdmcm'
    'llbmRzEhkKCGhhc19tb3JlGAIgASgIUgdoYXNNb3JlEiAKBWVycm9yGAMgASgLMgoueWltLkVy'
    'cm9yUgVlcnJvcg==');

@$core.Deprecated('Use deleteFriendReqDescriptor instead')
const DeleteFriendReq$json = {
  '1': 'DeleteFriendReq',
  '2': [
    {'1': 'op_uid', '3': 1, '4': 1, '5': 3, '10': 'opUid'},
    {'1': 'friend_uid', '3': 2, '4': 1, '5': 3, '10': 'friendUid'},
  ],
};

/// Descriptor for `DeleteFriendReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFriendReqDescriptor = $convert.base64Decode(
    'Cg9EZWxldGVGcmllbmRSZXESFQoGb3BfdWlkGAEgASgDUgVvcFVpZBIdCgpmcmllbmRfdWlkGA'
    'IgASgDUglmcmllbmRVaWQ=');

@$core.Deprecated('Use deleteFriendRspDescriptor instead')
const DeleteFriendRsp$json = {
  '1': 'DeleteFriendRsp',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `DeleteFriendRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFriendRspDescriptor = $convert.base64Decode(
    'Cg9EZWxldGVGcmllbmRSc3ASIAoFZXJyb3IYASABKAsyCi55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use checkFriendshipReqDescriptor instead')
const CheckFriendshipReq$json = {
  '1': 'CheckFriendshipReq',
  '2': [
    {'1': 'a_uid', '3': 1, '4': 1, '5': 3, '10': 'aUid'},
    {'1': 'b_uid', '3': 2, '4': 1, '5': 3, '10': 'bUid'},
  ],
};

/// Descriptor for `CheckFriendshipReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkFriendshipReqDescriptor = $convert.base64Decode(
    'ChJDaGVja0ZyaWVuZHNoaXBSZXESEwoFYV91aWQYASABKANSBGFVaWQSEwoFYl91aWQYAiABKA'
    'NSBGJVaWQ=');

@$core.Deprecated('Use checkFriendshipRspDescriptor instead')
const CheckFriendshipRsp$json = {
  '1': 'CheckFriendshipRsp',
  '2': [
    {'1': 'is_friend', '3': 1, '4': 1, '5': 8, '10': 'isFriend'},
  ],
};

/// Descriptor for `CheckFriendshipRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkFriendshipRspDescriptor =
    $convert.base64Decode(
        'ChJDaGVja0ZyaWVuZHNoaXBSc3ASGwoJaXNfZnJpZW5kGAEgASgIUghpc0ZyaWVuZA==');

@$core.Deprecated('Use addGroupMembersReqDescriptor instead')
const AddGroupMembersReq$json = {
  '1': 'AddGroupMembersReq',
  '2': [
    {'1': 'conv_id', '3': 1, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'member_uids', '3': 2, '4': 3, '5': 3, '10': 'memberUids'},
    {'1': 'owner_uid', '3': 3, '4': 1, '5': 3, '10': 'ownerUid'},
  ],
};

/// Descriptor for `AddGroupMembersReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGroupMembersReqDescriptor = $convert.base64Decode(
    'ChJBZGRHcm91cE1lbWJlcnNSZXESFwoHY29udl9pZBgBIAEoA1IGY29udklkEh8KC21lbWJlcl'
    '91aWRzGAIgAygDUgptZW1iZXJVaWRzEhsKCW93bmVyX3VpZBgDIAEoA1IIb3duZXJVaWQ=');

@$core.Deprecated('Use addGroupMembersRspDescriptor instead')
const AddGroupMembersRsp$json = {
  '1': 'AddGroupMembersRsp',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `AddGroupMembersRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGroupMembersRspDescriptor = $convert.base64Decode(
    'ChJBZGRHcm91cE1lbWJlcnNSc3ASIAoFZXJyb3IYASABKAsyCi55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use removeGroupMemberReqDescriptor instead')
const RemoveGroupMemberReq$json = {
  '1': 'RemoveGroupMemberReq',
  '2': [
    {'1': 'op_uid', '3': 1, '4': 1, '5': 3, '10': 'opUid'},
    {'1': 'conv_id', '3': 2, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'target_uid', '3': 3, '4': 1, '5': 3, '10': 'targetUid'},
  ],
};

/// Descriptor for `RemoveGroupMemberReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGroupMemberReqDescriptor = $convert.base64Decode(
    'ChRSZW1vdmVHcm91cE1lbWJlclJlcRIVCgZvcF91aWQYASABKANSBW9wVWlkEhcKB2NvbnZfaW'
    'QYAiABKANSBmNvbnZJZBIdCgp0YXJnZXRfdWlkGAMgASgDUgl0YXJnZXRVaWQ=');

@$core.Deprecated('Use removeGroupMemberRspDescriptor instead')
const RemoveGroupMemberRsp$json = {
  '1': 'RemoveGroupMemberRsp',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `RemoveGroupMemberRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGroupMemberRspDescriptor = $convert.base64Decode(
    'ChRSZW1vdmVHcm91cE1lbWJlclJzcBIgCgVlcnJvchgBIAEoCzIKLnlpbS5FcnJvclIFZXJyb3'
    'I=');

@$core.Deprecated('Use quitGroupReqDescriptor instead')
const QuitGroupReq$json = {
  '1': 'QuitGroupReq',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'conv_id', '3': 2, '4': 1, '5': 3, '10': 'convId'},
  ],
};

/// Descriptor for `QuitGroupReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quitGroupReqDescriptor = $convert.base64Decode(
    'CgxRdWl0R3JvdXBSZXESEAoDdWlkGAEgASgDUgN1aWQSFwoHY29udl9pZBgCIAEoA1IGY29udk'
    'lk');

@$core.Deprecated('Use quitGroupRspDescriptor instead')
const QuitGroupRsp$json = {
  '1': 'QuitGroupRsp',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `QuitGroupRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quitGroupRspDescriptor = $convert.base64Decode(
    'CgxRdWl0R3JvdXBSc3ASIAoFZXJyb3IYASABKAsyCi55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use groupMemberDescriptor instead')
const GroupMember$json = {
  '1': 'GroupMember',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'role', '3': 2, '4': 1, '5': 5, '10': 'role'},
    {'1': 'nickname', '3': 3, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar', '3': 4, '4': 1, '5': 9, '10': 'avatar'},
    {'1': 'join_time_ms', '3': 5, '4': 1, '5': 3, '10': 'joinTimeMs'},
  ],
};

/// Descriptor for `GroupMember`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMemberDescriptor = $convert.base64Decode(
    'CgtHcm91cE1lbWJlchIQCgN1aWQYASABKANSA3VpZBISCgRyb2xlGAIgASgFUgRyb2xlEhoKCG'
    '5pY2tuYW1lGAMgASgJUghuaWNrbmFtZRIWCgZhdmF0YXIYBCABKAlSBmF2YXRhchIgCgxqb2lu'
    'X3RpbWVfbXMYBSABKANSCmpvaW5UaW1lTXM=');

@$core.Deprecated('Use listGroupMembersReqDescriptor instead')
const ListGroupMembersReq$json = {
  '1': 'ListGroupMembersReq',
  '2': [
    {'1': 'conv_id', '3': 1, '4': 1, '5': 3, '10': 'convId'},
  ],
};

/// Descriptor for `ListGroupMembersReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGroupMembersReqDescriptor =
    $convert.base64Decode(
        'ChNMaXN0R3JvdXBNZW1iZXJzUmVxEhcKB2NvbnZfaWQYASABKANSBmNvbnZJZA==');

@$core.Deprecated('Use listGroupMembersRspDescriptor instead')
const ListGroupMembersRsp$json = {
  '1': 'ListGroupMembersRsp',
  '2': [
    {
      '1': 'members',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yim.GroupMember',
      '10': 'members'
    },
    {'1': 'error', '3': 2, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `ListGroupMembersRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGroupMembersRspDescriptor = $convert.base64Decode(
    'ChNMaXN0R3JvdXBNZW1iZXJzUnNwEioKB21lbWJlcnMYASADKAsyEC55aW0uR3JvdXBNZW1iZX'
    'JSB21lbWJlcnMSIAoFZXJyb3IYAiABKAsyCi55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use updateGroupInfoReqDescriptor instead')
const UpdateGroupInfoReq$json = {
  '1': 'UpdateGroupInfoReq',
  '2': [
    {'1': 'op_uid', '3': 1, '4': 1, '5': 3, '10': 'opUid'},
    {'1': 'conv_id', '3': 2, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 4, '4': 1, '5': 9, '10': 'avatar'},
  ],
};

/// Descriptor for `UpdateGroupInfoReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupInfoReqDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVHcm91cEluZm9SZXESFQoGb3BfdWlkGAEgASgDUgVvcFVpZBIXCgdjb252X2lkGA'
    'IgASgDUgZjb252SWQSEgoEbmFtZRgDIAEoCVIEbmFtZRIWCgZhdmF0YXIYBCABKAlSBmF2YXRh'
    'cg==');

@$core.Deprecated('Use updateGroupInfoRspDescriptor instead')
const UpdateGroupInfoRsp$json = {
  '1': 'UpdateGroupInfoRsp',
  '2': [
    {'1': 'error', '3': 1, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `UpdateGroupInfoRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupInfoRspDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVHcm91cEluZm9Sc3ASIAoFZXJyb3IYASABKAsyCi55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use getProfilesReqDescriptor instead')
const GetProfilesReq$json = {
  '1': 'GetProfilesReq',
  '2': [
    {'1': 'uids', '3': 1, '4': 3, '5': 3, '10': 'uids'},
  ],
};

/// Descriptor for `GetProfilesReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProfilesReqDescriptor =
    $convert.base64Decode('Cg5HZXRQcm9maWxlc1JlcRISCgR1aWRzGAEgAygDUgR1aWRz');

@$core.Deprecated('Use getProfilesRspDescriptor instead')
const GetProfilesRsp$json = {
  '1': 'GetProfilesRsp',
  '2': [
    {
      '1': 'profiles',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yim.UserProfile',
      '10': 'profiles'
    },
    {'1': 'error', '3': 2, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `GetProfilesRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProfilesRspDescriptor = $convert.base64Decode(
    'Cg5HZXRQcm9maWxlc1JzcBIsCghwcm9maWxlcxgBIAMoCzIQLnlpbS5Vc2VyUHJvZmlsZVIIcH'
    'JvZmlsZXMSIAoFZXJyb3IYAiABKAsyCi55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use searchUsersReqDescriptor instead')
const SearchUsersReq$json = {
  '1': 'SearchUsersReq',
  '2': [
    {'1': 'keyword', '3': 1, '4': 1, '5': 9, '10': 'keyword'},
    {'1': 'op_uid', '3': 2, '4': 1, '5': 3, '10': 'opUid'},
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `SearchUsersReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersReqDescriptor = $convert.base64Decode(
    'Cg5TZWFyY2hVc2Vyc1JlcRIYCgdrZXl3b3JkGAEgASgJUgdrZXl3b3JkEhUKBm9wX3VpZBgCIA'
    'EoA1IFb3BVaWQSFAoFbGltaXQYAyABKAVSBWxpbWl0');

@$core.Deprecated('Use searchUsersRspDescriptor instead')
const SearchUsersRsp$json = {
  '1': 'SearchUsersRsp',
  '2': [
    {
      '1': 'profiles',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yim.UserProfile',
      '10': 'profiles'
    },
    {'1': 'error', '3': 2, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `SearchUsersRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersRspDescriptor = $convert.base64Decode(
    'Cg5TZWFyY2hVc2Vyc1JzcBIsCghwcm9maWxlcxgBIAMoCzIQLnlpbS5Vc2VyUHJvZmlsZVIIcH'
    'JvZmlsZXMSIAoFZXJyb3IYAiABKAsyCi55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use userProfileDescriptor instead')
const UserProfile$json = {
  '1': 'UserProfile',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
  ],
};

/// Descriptor for `UserProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userProfileDescriptor = $convert.base64Decode(
    'CgtVc2VyUHJvZmlsZRIQCgN1aWQYASABKANSA3VpZBIaCghuaWNrbmFtZRgCIAEoCVIIbmlja2'
    '5hbWUSFgoGYXZhdGFyGAMgASgJUgZhdmF0YXI=');

@$core.Deprecated('Use updateProfileReqDescriptor instead')
const UpdateProfileReq$json = {
  '1': 'UpdateProfileReq',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar', '3': 3, '4': 1, '5': 9, '10': 'avatar'},
  ],
};

/// Descriptor for `UpdateProfileReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProfileReqDescriptor = $convert.base64Decode(
    'ChBVcGRhdGVQcm9maWxlUmVxEhAKA3VpZBgBIAEoA1IDdWlkEhoKCG5pY2tuYW1lGAIgASgJUg'
    'huaWNrbmFtZRIWCgZhdmF0YXIYAyABKAlSBmF2YXRhcg==');

@$core.Deprecated('Use updateProfileRspDescriptor instead')
const UpdateProfileRsp$json = {
  '1': 'UpdateProfileRsp',
  '2': [
    {
      '1': 'profile',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yim.UserProfile',
      '10': 'profile'
    },
    {'1': 'error', '3': 2, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `UpdateProfileRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProfileRspDescriptor = $convert.base64Decode(
    'ChBVcGRhdGVQcm9maWxlUnNwEioKB3Byb2ZpbGUYASABKAsyEC55aW0uVXNlclByb2ZpbGVSB3'
    'Byb2ZpbGUSIAoFZXJyb3IYAiABKAsyCi55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use getPresenceReqDescriptor instead')
const GetPresenceReq$json = {
  '1': 'GetPresenceReq',
  '2': [
    {'1': 'uids', '3': 1, '4': 3, '5': 3, '10': 'uids'},
  ],
};

/// Descriptor for `GetPresenceReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPresenceReqDescriptor =
    $convert.base64Decode('Cg5HZXRQcmVzZW5jZVJlcRISCgR1aWRzGAEgAygDUgR1aWRz');

@$core.Deprecated('Use presenceInfoDescriptor instead')
const PresenceInfo$json = {
  '1': 'PresenceInfo',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {
      '1': 'presence',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.yim.Presence',
      '10': 'presence'
    },
  ],
};

/// Descriptor for `PresenceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceInfoDescriptor = $convert.base64Decode(
    'CgxQcmVzZW5jZUluZm8SEAoDdWlkGAEgASgDUgN1aWQSKQoIcHJlc2VuY2UYAiABKA4yDS55aW'
    '0uUHJlc2VuY2VSCHByZXNlbmNl');

@$core.Deprecated('Use getPresenceRspDescriptor instead')
const GetPresenceRsp$json = {
  '1': 'GetPresenceRsp',
  '2': [
    {
      '1': 'presences',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yim.PresenceInfo',
      '10': 'presences'
    },
    {'1': 'error', '3': 2, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `GetPresenceRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPresenceRspDescriptor = $convert.base64Decode(
    'Cg5HZXRQcmVzZW5jZVJzcBIvCglwcmVzZW5jZXMYASADKAsyES55aW0uUHJlc2VuY2VJbmZvUg'
    'lwcmVzZW5jZXMSIAoFZXJyb3IYAiABKAsyCi55aW0uRXJyb3JSBWVycm9y');

const $core.Map<$core.String, $core.dynamic> RelationServiceBase$json = {
  '1': 'RelationService',
  '2': [
    {
      '1': 'SendFriendRequest',
      '2': '.yim.SendFriendRequestReq',
      '3': '.yim.SendFriendRequestRsp'
    },
    {
      '1': 'HandleFriendRequest',
      '2': '.yim.HandleFriendRequestReq',
      '3': '.yim.HandleFriendRequestRsp'
    },
    {
      '1': 'ListFriendRequests',
      '2': '.yim.ListFriendRequestsReq',
      '3': '.yim.ListFriendRequestsRsp'
    },
    {
      '1': 'ListFriends',
      '2': '.yim.ListFriendsReq',
      '3': '.yim.ListFriendsRsp'
    },
    {
      '1': 'DeleteFriend',
      '2': '.yim.DeleteFriendReq',
      '3': '.yim.DeleteFriendRsp'
    },
    {
      '1': 'CheckFriendship',
      '2': '.yim.CheckFriendshipReq',
      '3': '.yim.CheckFriendshipRsp'
    },
    {
      '1': 'AddGroupMembers',
      '2': '.yim.AddGroupMembersReq',
      '3': '.yim.AddGroupMembersRsp'
    },
    {
      '1': 'RemoveGroupMember',
      '2': '.yim.RemoveGroupMemberReq',
      '3': '.yim.RemoveGroupMemberRsp'
    },
    {'1': 'QuitGroup', '2': '.yim.QuitGroupReq', '3': '.yim.QuitGroupRsp'},
    {
      '1': 'ListGroupMembers',
      '2': '.yim.ListGroupMembersReq',
      '3': '.yim.ListGroupMembersRsp'
    },
    {
      '1': 'UpdateGroupInfo',
      '2': '.yim.UpdateGroupInfoReq',
      '3': '.yim.UpdateGroupInfoRsp'
    },
    {
      '1': 'GetProfiles',
      '2': '.yim.GetProfilesReq',
      '3': '.yim.GetProfilesRsp'
    },
    {
      '1': 'SearchUsers',
      '2': '.yim.SearchUsersReq',
      '3': '.yim.SearchUsersRsp'
    },
    {
      '1': 'UpdateProfile',
      '2': '.yim.UpdateProfileReq',
      '3': '.yim.UpdateProfileRsp'
    },
    {
      '1': 'GetPresence',
      '2': '.yim.GetPresenceReq',
      '3': '.yim.GetPresenceRsp'
    },
  ],
};

@$core.Deprecated('Use relationServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    RelationServiceBase$messageJson = {
  '.yim.SendFriendRequestReq': SendFriendRequestReq$json,
  '.yim.SendFriendRequestRsp': SendFriendRequestRsp$json,
  '.yim.Error': $0.Error$json,
  '.yim.HandleFriendRequestReq': HandleFriendRequestReq$json,
  '.yim.HandleFriendRequestRsp': HandleFriendRequestRsp$json,
  '.yim.ListFriendRequestsReq': ListFriendRequestsReq$json,
  '.yim.ListFriendRequestsRsp': ListFriendRequestsRsp$json,
  '.yim.FriendRequest': FriendRequest$json,
  '.yim.ListFriendsReq': ListFriendsReq$json,
  '.yim.PageInfo': $0.PageInfo$json,
  '.yim.ListFriendsRsp': ListFriendsRsp$json,
  '.yim.FriendBrief': FriendBrief$json,
  '.yim.DeleteFriendReq': DeleteFriendReq$json,
  '.yim.DeleteFriendRsp': DeleteFriendRsp$json,
  '.yim.CheckFriendshipReq': CheckFriendshipReq$json,
  '.yim.CheckFriendshipRsp': CheckFriendshipRsp$json,
  '.yim.AddGroupMembersReq': AddGroupMembersReq$json,
  '.yim.AddGroupMembersRsp': AddGroupMembersRsp$json,
  '.yim.RemoveGroupMemberReq': RemoveGroupMemberReq$json,
  '.yim.RemoveGroupMemberRsp': RemoveGroupMemberRsp$json,
  '.yim.QuitGroupReq': QuitGroupReq$json,
  '.yim.QuitGroupRsp': QuitGroupRsp$json,
  '.yim.ListGroupMembersReq': ListGroupMembersReq$json,
  '.yim.ListGroupMembersRsp': ListGroupMembersRsp$json,
  '.yim.GroupMember': GroupMember$json,
  '.yim.UpdateGroupInfoReq': UpdateGroupInfoReq$json,
  '.yim.UpdateGroupInfoRsp': UpdateGroupInfoRsp$json,
  '.yim.GetProfilesReq': GetProfilesReq$json,
  '.yim.GetProfilesRsp': GetProfilesRsp$json,
  '.yim.UserProfile': UserProfile$json,
  '.yim.SearchUsersReq': SearchUsersReq$json,
  '.yim.SearchUsersRsp': SearchUsersRsp$json,
  '.yim.UpdateProfileReq': UpdateProfileReq$json,
  '.yim.UpdateProfileRsp': UpdateProfileRsp$json,
  '.yim.GetPresenceReq': GetPresenceReq$json,
  '.yim.GetPresenceRsp': GetPresenceRsp$json,
  '.yim.PresenceInfo': PresenceInfo$json,
};

/// Descriptor for `RelationService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List relationServiceDescriptor = $convert.base64Decode(
    'Cg9SZWxhdGlvblNlcnZpY2USSQoRU2VuZEZyaWVuZFJlcXVlc3QSGS55aW0uU2VuZEZyaWVuZF'
    'JlcXVlc3RSZXEaGS55aW0uU2VuZEZyaWVuZFJlcXVlc3RSc3ASTwoTSGFuZGxlRnJpZW5kUmVx'
    'dWVzdBIbLnlpbS5IYW5kbGVGcmllbmRSZXF1ZXN0UmVxGhsueWltLkhhbmRsZUZyaWVuZFJlcX'
    'Vlc3RSc3ASTAoSTGlzdEZyaWVuZFJlcXVlc3RzEhoueWltLkxpc3RGcmllbmRSZXF1ZXN0c1Jl'
    'cRoaLnlpbS5MaXN0RnJpZW5kUmVxdWVzdHNSc3ASNwoLTGlzdEZyaWVuZHMSEy55aW0uTGlzdE'
    'ZyaWVuZHNSZXEaEy55aW0uTGlzdEZyaWVuZHNSc3ASOgoMRGVsZXRlRnJpZW5kEhQueWltLkRl'
    'bGV0ZUZyaWVuZFJlcRoULnlpbS5EZWxldGVGcmllbmRSc3ASQwoPQ2hlY2tGcmllbmRzaGlwEh'
    'cueWltLkNoZWNrRnJpZW5kc2hpcFJlcRoXLnlpbS5DaGVja0ZyaWVuZHNoaXBSc3ASQwoPQWRk'
    'R3JvdXBNZW1iZXJzEhcueWltLkFkZEdyb3VwTWVtYmVyc1JlcRoXLnlpbS5BZGRHcm91cE1lbW'
    'JlcnNSc3ASSQoRUmVtb3ZlR3JvdXBNZW1iZXISGS55aW0uUmVtb3ZlR3JvdXBNZW1iZXJSZXEa'
    'GS55aW0uUmVtb3ZlR3JvdXBNZW1iZXJSc3ASMQoJUXVpdEdyb3VwEhEueWltLlF1aXRHcm91cF'
    'JlcRoRLnlpbS5RdWl0R3JvdXBSc3ASRgoQTGlzdEdyb3VwTWVtYmVycxIYLnlpbS5MaXN0R3Jv'
    'dXBNZW1iZXJzUmVxGhgueWltLkxpc3RHcm91cE1lbWJlcnNSc3ASQwoPVXBkYXRlR3JvdXBJbm'
    'ZvEhcueWltLlVwZGF0ZUdyb3VwSW5mb1JlcRoXLnlpbS5VcGRhdGVHcm91cEluZm9Sc3ASNwoL'
    'R2V0UHJvZmlsZXMSEy55aW0uR2V0UHJvZmlsZXNSZXEaEy55aW0uR2V0UHJvZmlsZXNSc3ASNw'
    'oLU2VhcmNoVXNlcnMSEy55aW0uU2VhcmNoVXNlcnNSZXEaEy55aW0uU2VhcmNoVXNlcnNSc3AS'
    'PQoNVXBkYXRlUHJvZmlsZRIVLnlpbS5VcGRhdGVQcm9maWxlUmVxGhUueWltLlVwZGF0ZVByb2'
    'ZpbGVSc3ASNwoLR2V0UHJlc2VuY2USEy55aW0uR2V0UHJlc2VuY2VSZXEaEy55aW0uR2V0UHJl'
    'c2VuY2VSc3A=');

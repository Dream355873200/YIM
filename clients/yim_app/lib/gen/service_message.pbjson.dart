// This is a generated file - do not edit.
//
// Generated from service_message.proto.

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

import 'common.pbjson.dart' as $1;
import 'message.pbjson.dart' as $0;
import 'protocol.pbjson.dart' as $2;

@$core.Deprecated('Use pullModeDescriptor instead')
const PullMode$json = {
  '1': 'PullMode',
  '2': [
    {'1': 'PULL_UNKNOWN', '2': 0},
    {'1': 'PULL_SEQ_RANGE', '2': 1},
    {'1': 'PULL_PAGE_BACKWARD', '2': 2},
  ],
};

/// Descriptor for `PullMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pullModeDescriptor = $convert.base64Decode(
    'CghQdWxsTW9kZRIQCgxQVUxMX1VOS05PV04QABISCg5QVUxMX1NFUV9SQU5HRRABEhYKElBVTE'
    'xfUEFHRV9CQUNLV0FSRBAC');

@$core.Deprecated('Use sendMessageReqDescriptor instead')
const SendMessageReq$json = {
  '1': 'SendMessageReq',
  '2': [
    {'1': 'client_msg_id', '3': 1, '4': 1, '5': 4, '10': 'clientMsgId'},
    {'1': 'conv_id', '3': 2, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'from_uid', '3': 3, '4': 1, '5': 3, '10': 'fromUid'},
    {
      '1': 'content',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.yim.ConvMsgContent',
      '10': 'content'
    },
  ],
};

/// Descriptor for `SendMessageReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageReqDescriptor = $convert.base64Decode(
    'Cg5TZW5kTWVzc2FnZVJlcRIiCg1jbGllbnRfbXNnX2lkGAEgASgEUgtjbGllbnRNc2dJZBIXCg'
    'djb252X2lkGAIgASgDUgZjb252SWQSGQoIZnJvbV91aWQYAyABKANSB2Zyb21VaWQSLQoHY29u'
    'dGVudBgEIAEoCzITLnlpbS5Db252TXNnQ29udGVudFIHY29udGVudA==');

@$core.Deprecated('Use sendMessageRspDescriptor instead')
const SendMessageRsp$json = {
  '1': 'SendMessageRsp',
  '2': [
    {'1': 'msg_id', '3': 1, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'seq', '3': 2, '4': 1, '5': 3, '10': 'seq'},
    {'1': 'server_time_ms', '3': 3, '4': 1, '5': 3, '10': 'serverTimeMs'},
    {'1': 'error', '3': 4, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `SendMessageRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageRspDescriptor = $convert.base64Decode(
    'Cg5TZW5kTWVzc2FnZVJzcBIVCgZtc2dfaWQYASABKANSBW1zZ0lkEhAKA3NlcRgCIAEoA1IDc2'
    'VxEiQKDnNlcnZlcl90aW1lX21zGAMgASgDUgxzZXJ2ZXJUaW1lTXMSIAoFZXJyb3IYBCABKAsy'
    'Ci55aW0uRXJyb3JSBWVycm9y');

@$core.Deprecated('Use pullHistoryReqDescriptor instead')
const PullHistoryReq$json = {
  '1': 'PullHistoryReq',
  '2': [
    {'1': 'conv_id', '3': 1, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'mode', '3': 2, '4': 1, '5': 14, '6': '.yim.PullMode', '10': 'mode'},
    {'1': 'from_seq', '3': 3, '4': 1, '5': 3, '10': 'fromSeq'},
    {'1': 'to_seq', '3': 4, '4': 1, '5': 3, '10': 'toSeq'},
    {'1': 'before_seq', '3': 5, '4': 1, '5': 3, '10': 'beforeSeq'},
    {'1': 'limit', '3': 6, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'op_uid', '3': 7, '4': 1, '5': 3, '10': 'opUid'},
  ],
};

/// Descriptor for `PullHistoryReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullHistoryReqDescriptor = $convert.base64Decode(
    'Cg5QdWxsSGlzdG9yeVJlcRIXCgdjb252X2lkGAEgASgDUgZjb252SWQSIQoEbW9kZRgCIAEoDj'
    'INLnlpbS5QdWxsTW9kZVIEbW9kZRIZCghmcm9tX3NlcRgDIAEoA1IHZnJvbVNlcRIVCgZ0b19z'
    'ZXEYBCABKANSBXRvU2VxEh0KCmJlZm9yZV9zZXEYBSABKANSCWJlZm9yZVNlcRIUCgVsaW1pdB'
    'gGIAEoBVIFbGltaXQSFQoGb3BfdWlkGAcgASgDUgVvcFVpZA==');

@$core.Deprecated('Use pullHistoryRspDescriptor instead')
const PullHistoryRsp$json = {
  '1': 'PullHistoryRsp',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yim.ConvMessage',
      '10': 'messages'
    },
    {'1': 'has_more', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
    {'1': 'min_seq', '3': 3, '4': 1, '5': 3, '10': 'minSeq'},
    {'1': 'error', '3': 4, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `PullHistoryRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullHistoryRspDescriptor = $convert.base64Decode(
    'Cg5QdWxsSGlzdG9yeVJzcBIsCghtZXNzYWdlcxgBIAMoCzIQLnlpbS5Db252TWVzc2FnZVIIbW'
    'Vzc2FnZXMSGQoIaGFzX21vcmUYAiABKAhSB2hhc01vcmUSFwoHbWluX3NlcRgDIAEoA1IGbWlu'
    'U2VxEiAKBWVycm9yGAQgASgLMgoueWltLkVycm9yUgVlcnJvcg==');

@$core.Deprecated('Use syncReq2Descriptor instead')
const SyncReq2$json = {
  '1': 'SyncReq2',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'user_sync_seq', '3': 2, '4': 1, '5': 3, '10': 'userSyncSeq'},
    {
      '1': 'watermarks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.yim.ConvWatermark',
      '10': 'watermarks'
    },
  ],
};

/// Descriptor for `SyncReq2`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncReq2Descriptor = $convert.base64Decode(
    'CghTeW5jUmVxMhIQCgN1aWQYASABKANSA3VpZBIiCg11c2VyX3N5bmNfc2VxGAIgASgDUgt1c2'
    'VyU3luY1NlcRIyCgp3YXRlcm1hcmtzGAMgAygLMhIueWltLkNvbnZXYXRlcm1hcmtSCndhdGVy'
    'bWFya3M=');

@$core.Deprecated('Use syncRsp2Descriptor instead')
const SyncRsp2$json = {
  '1': 'SyncRsp2',
  '2': [
    {'1': 'user_sync_seq', '3': 1, '4': 1, '5': 3, '10': 'userSyncSeq'},
    {
      '1': 'messages',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.yim.ConvMessage',
      '10': 'messages'
    },
    {
      '1': 'overflow',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.yim.ConvWatermark',
      '10': 'overflow'
    },
  ],
};

/// Descriptor for `SyncRsp2`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncRsp2Descriptor = $convert.base64Decode(
    'CghTeW5jUnNwMhIiCg11c2VyX3N5bmNfc2VxGAEgASgDUgt1c2VyU3luY1NlcRIsCghtZXNzYW'
    'dlcxgCIAMoCzIQLnlpbS5Db252TWVzc2FnZVIIbWVzc2FnZXMSLgoIb3ZlcmZsb3cYAyADKAsy'
    'Ei55aW0uQ29udldhdGVybWFya1IIb3ZlcmZsb3c=');

@$core.Deprecated('Use ackPushReqDescriptor instead')
const AckPushReq$json = {
  '1': 'AckPushReq',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'conv_id', '3': 2, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'ack_seq', '3': 3, '4': 1, '5': 3, '10': 'ackSeq'},
  ],
};

/// Descriptor for `AckPushReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ackPushReqDescriptor = $convert.base64Decode(
    'CgpBY2tQdXNoUmVxEhAKA3VpZBgBIAEoA1IDdWlkEhcKB2NvbnZfaWQYAiABKANSBmNvbnZJZB'
    'IXCgdhY2tfc2VxGAMgASgDUgZhY2tTZXE=');

@$core.Deprecated('Use ackPushRspDescriptor instead')
const AckPushRsp$json = {
  '1': 'AckPushRsp',
};

/// Descriptor for `AckPushRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ackPushRspDescriptor =
    $convert.base64Decode('CgpBY2tQdXNoUnNw');

@$core.Deprecated('Use revokeMessageReqDescriptor instead')
const RevokeMessageReq$json = {
  '1': 'RevokeMessageReq',
  '2': [
    {'1': 'msg_id', '3': 1, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'conv_id', '3': 2, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'op_uid', '3': 3, '4': 1, '5': 3, '10': 'opUid'},
  ],
};

/// Descriptor for `RevokeMessageReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeMessageReqDescriptor = $convert.base64Decode(
    'ChBSZXZva2VNZXNzYWdlUmVxEhUKBm1zZ19pZBgBIAEoA1IFbXNnSWQSFwoHY29udl9pZBgCIA'
    'EoA1IGY29udklkEhUKBm9wX3VpZBgDIAEoA1IFb3BVaWQ=');

@$core.Deprecated('Use revokeMessageRspDescriptor instead')
const RevokeMessageRsp$json = {
  '1': 'RevokeMessageRsp',
  '2': [
    {'1': 'revoke_msg_id', '3': 1, '4': 1, '5': 3, '10': 'revokeMsgId'},
    {'1': 'seq', '3': 2, '4': 1, '5': 3, '10': 'seq'},
    {'1': 'error', '3': 3, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `RevokeMessageRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeMessageRspDescriptor = $convert.base64Decode(
    'ChBSZXZva2VNZXNzYWdlUnNwEiIKDXJldm9rZV9tc2dfaWQYASABKANSC3Jldm9rZU1zZ0lkEh'
    'AKA3NlcRgCIAEoA1IDc2VxEiAKBWVycm9yGAMgASgLMgoueWltLkVycm9yUgVlcnJvcg==');

@$core.Deprecated('Use markReadReqDescriptor instead')
const MarkReadReq$json = {
  '1': 'MarkReadReq',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'conv_id', '3': 2, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'read_seq', '3': 3, '4': 1, '5': 3, '10': 'readSeq'},
  ],
};

/// Descriptor for `MarkReadReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markReadReqDescriptor = $convert.base64Decode(
    'CgtNYXJrUmVhZFJlcRIQCgN1aWQYASABKANSA3VpZBIXCgdjb252X2lkGAIgASgDUgZjb252SW'
    'QSGQoIcmVhZF9zZXEYAyABKANSB3JlYWRTZXE=');

@$core.Deprecated('Use markReadRspDescriptor instead')
const MarkReadRsp$json = {
  '1': 'MarkReadRsp',
};

/// Descriptor for `MarkReadRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markReadRspDescriptor =
    $convert.base64Decode('CgtNYXJrUmVhZFJzcA==');

@$core.Deprecated('Use listConversationsReqDescriptor instead')
const ListConversationsReq$json = {
  '1': 'ListConversationsReq',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'page', '3': 2, '4': 1, '5': 11, '6': '.yim.PageInfo', '10': 'page'},
  ],
};

/// Descriptor for `ListConversationsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConversationsReqDescriptor = $convert.base64Decode(
    'ChRMaXN0Q29udmVyc2F0aW9uc1JlcRIQCgN1aWQYASABKANSA3VpZBIhCgRwYWdlGAIgASgLMg'
    '0ueWltLlBhZ2VJbmZvUgRwYWdl');

@$core.Deprecated('Use conversationBriefDescriptor instead')
const ConversationBrief$json = {
  '1': 'ConversationBrief',
  '2': [
    {'1': 'conv', '3': 1, '4': 1, '5': 11, '6': '.yim.Conv', '10': 'conv'},
    {'1': 'unread_count', '3': 2, '4': 1, '5': 3, '10': 'unreadCount'},
    {
      '1': 'last_message',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.yim.ConvMessage',
      '10': 'lastMessage'
    },
  ],
};

/// Descriptor for `ConversationBrief`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationBriefDescriptor = $convert.base64Decode(
    'ChFDb252ZXJzYXRpb25CcmllZhIdCgRjb252GAEgASgLMgkueWltLkNvbnZSBGNvbnYSIQoMdW'
    '5yZWFkX2NvdW50GAIgASgDUgt1bnJlYWRDb3VudBIzCgxsYXN0X21lc3NhZ2UYAyABKAsyEC55'
    'aW0uQ29udk1lc3NhZ2VSC2xhc3RNZXNzYWdl');

@$core.Deprecated('Use listConversationsRspDescriptor instead')
const ListConversationsRsp$json = {
  '1': 'ListConversationsRsp',
  '2': [
    {
      '1': 'conversations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yim.ConversationBrief',
      '10': 'conversations'
    },
    {'1': 'has_more', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `ListConversationsRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConversationsRspDescriptor = $convert.base64Decode(
    'ChRMaXN0Q29udmVyc2F0aW9uc1JzcBI8Cg1jb252ZXJzYXRpb25zGAEgAygLMhYueWltLkNvbn'
    'ZlcnNhdGlvbkJyaWVmUg1jb252ZXJzYXRpb25zEhkKCGhhc19tb3JlGAIgASgIUgdoYXNNb3Jl');

@$core.Deprecated('Use createConvReqDescriptor instead')
const CreateConvReq$json = {
  '1': 'CreateConvReq',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.yim.ConvType', '10': 'type'},
    {'1': 'member_uids', '3': 2, '4': 3, '5': 3, '10': 'memberUids'},
    {'1': 'owner_uid', '3': 3, '4': 1, '5': 3, '10': 'ownerUid'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `CreateConvReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createConvReqDescriptor = $convert.base64Decode(
    'Cg1DcmVhdGVDb252UmVxEiEKBHR5cGUYASABKA4yDS55aW0uQ29udlR5cGVSBHR5cGUSHwoLbW'
    'VtYmVyX3VpZHMYAiADKANSCm1lbWJlclVpZHMSGwoJb3duZXJfdWlkGAMgASgDUghvd25lclVp'
    'ZBISCgRuYW1lGAQgASgJUgRuYW1l');

@$core.Deprecated('Use createConvRspDescriptor instead')
const CreateConvRsp$json = {
  '1': 'CreateConvRsp',
  '2': [
    {'1': 'conv', '3': 1, '4': 1, '5': 11, '6': '.yim.Conv', '10': 'conv'},
    {'1': 'already_exist', '3': 2, '4': 1, '5': 8, '10': 'alreadyExist'},
    {'1': 'error', '3': 3, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
  ],
};

/// Descriptor for `CreateConvRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createConvRspDescriptor = $convert.base64Decode(
    'Cg1DcmVhdGVDb252UnNwEh0KBGNvbnYYASABKAsyCS55aW0uQ29udlIEY29udhIjCg1hbHJlYW'
    'R5X2V4aXN0GAIgASgIUgxhbHJlYWR5RXhpc3QSIAoFZXJyb3IYAyABKAsyCi55aW0uRXJyb3JS'
    'BWVycm9y');

@$core.Deprecated('Use searchMessagesReqDescriptor instead')
const SearchMessagesReq$json = {
  '1': 'SearchMessagesReq',
  '2': [
    {'1': 'uid', '3': 1, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'keyword', '3': 2, '4': 1, '5': 9, '10': 'keyword'},
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `SearchMessagesReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchMessagesReqDescriptor = $convert.base64Decode(
    'ChFTZWFyY2hNZXNzYWdlc1JlcRIQCgN1aWQYASABKANSA3VpZBIYCgdrZXl3b3JkGAIgASgJUg'
    'drZXl3b3JkEhQKBWxpbWl0GAMgASgFUgVsaW1pdA==');

@$core.Deprecated('Use searchMessagesRspDescriptor instead')
const SearchMessagesRsp$json = {
  '1': 'SearchMessagesRsp',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yim.ConvMessage',
      '10': 'messages'
    },
    {'1': 'truncated', '3': 2, '4': 1, '5': 8, '10': 'truncated'},
  ],
};

/// Descriptor for `SearchMessagesRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchMessagesRspDescriptor = $convert.base64Decode(
    'ChFTZWFyY2hNZXNzYWdlc1JzcBIsCghtZXNzYWdlcxgBIAMoCzIQLnlpbS5Db252TWVzc2FnZV'
    'IIbWVzc2FnZXMSHAoJdHJ1bmNhdGVkGAIgASgIUgl0cnVuY2F0ZWQ=');

const $core.Map<$core.String, $core.dynamic> MessageServiceBase$json = {
  '1': 'MessageService',
  '2': [
    {
      '1': 'SendMessage',
      '2': '.yim.SendMessageReq',
      '3': '.yim.SendMessageRsp'
    },
    {
      '1': 'PullHistory',
      '2': '.yim.PullHistoryReq',
      '3': '.yim.PullHistoryRsp'
    },
    {'1': 'Sync', '2': '.yim.SyncReq2', '3': '.yim.SyncRsp2'},
    {'1': 'AckPush', '2': '.yim.AckPushReq', '3': '.yim.AckPushRsp'},
    {
      '1': 'RevokeMessage',
      '2': '.yim.RevokeMessageReq',
      '3': '.yim.RevokeMessageRsp'
    },
    {'1': 'MarkRead', '2': '.yim.MarkReadReq', '3': '.yim.MarkReadRsp'},
    {
      '1': 'ListConversations',
      '2': '.yim.ListConversationsReq',
      '3': '.yim.ListConversationsRsp'
    },
    {
      '1': 'SearchMessages',
      '2': '.yim.SearchMessagesReq',
      '3': '.yim.SearchMessagesRsp'
    },
    {'1': 'CreateConv', '2': '.yim.CreateConvReq', '3': '.yim.CreateConvRsp'},
  ],
};

@$core.Deprecated('Use messageServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    MessageServiceBase$messageJson = {
  '.yim.SendMessageReq': SendMessageReq$json,
  '.yim.ConvMsgContent': $0.ConvMsgContent$json,
  '.yim.MediaMeta': $0.MediaMeta$json,
  '.yim.Ext': $0.Ext$json,
  '.yim.SendMessageRsp': SendMessageRsp$json,
  '.yim.Error': $1.Error$json,
  '.yim.PullHistoryReq': PullHistoryReq$json,
  '.yim.PullHistoryRsp': PullHistoryRsp$json,
  '.yim.ConvMessage': $0.ConvMessage$json,
  '.yim.SyncReq2': SyncReq2$json,
  '.yim.ConvWatermark': $2.ConvWatermark$json,
  '.yim.SyncRsp2': SyncRsp2$json,
  '.yim.AckPushReq': AckPushReq$json,
  '.yim.AckPushRsp': AckPushRsp$json,
  '.yim.RevokeMessageReq': RevokeMessageReq$json,
  '.yim.RevokeMessageRsp': RevokeMessageRsp$json,
  '.yim.MarkReadReq': MarkReadReq$json,
  '.yim.MarkReadRsp': MarkReadRsp$json,
  '.yim.ListConversationsReq': ListConversationsReq$json,
  '.yim.PageInfo': $1.PageInfo$json,
  '.yim.ListConversationsRsp': ListConversationsRsp$json,
  '.yim.ConversationBrief': ConversationBrief$json,
  '.yim.Conv': $0.Conv$json,
  '.yim.SearchMessagesReq': SearchMessagesReq$json,
  '.yim.SearchMessagesRsp': SearchMessagesRsp$json,
  '.yim.CreateConvReq': CreateConvReq$json,
  '.yim.CreateConvRsp': CreateConvRsp$json,
};

/// Descriptor for `MessageService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List messageServiceDescriptor = $convert.base64Decode(
    'Cg5NZXNzYWdlU2VydmljZRI3CgtTZW5kTWVzc2FnZRITLnlpbS5TZW5kTWVzc2FnZVJlcRoTLn'
    'lpbS5TZW5kTWVzc2FnZVJzcBI3CgtQdWxsSGlzdG9yeRITLnlpbS5QdWxsSGlzdG9yeVJlcRoT'
    'LnlpbS5QdWxsSGlzdG9yeVJzcBIkCgRTeW5jEg0ueWltLlN5bmNSZXEyGg0ueWltLlN5bmNSc3'
    'AyEisKB0Fja1B1c2gSDy55aW0uQWNrUHVzaFJlcRoPLnlpbS5BY2tQdXNoUnNwEj0KDVJldm9r'
    'ZU1lc3NhZ2USFS55aW0uUmV2b2tlTWVzc2FnZVJlcRoVLnlpbS5SZXZva2VNZXNzYWdlUnNwEi'
    '4KCE1hcmtSZWFkEhAueWltLk1hcmtSZWFkUmVxGhAueWltLk1hcmtSZWFkUnNwEkkKEUxpc3RD'
    'b252ZXJzYXRpb25zEhkueWltLkxpc3RDb252ZXJzYXRpb25zUmVxGhkueWltLkxpc3RDb252ZX'
    'JzYXRpb25zUnNwEkAKDlNlYXJjaE1lc3NhZ2VzEhYueWltLlNlYXJjaE1lc3NhZ2VzUmVxGhYu'
    'eWltLlNlYXJjaE1lc3NhZ2VzUnNwEjQKCkNyZWF0ZUNvbnYSEi55aW0uQ3JlYXRlQ29udlJlcR'
    'oSLnlpbS5DcmVhdGVDb252UnNw');

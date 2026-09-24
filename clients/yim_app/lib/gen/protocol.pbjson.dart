// This is a generated file - do not edit.
//
// Generated from protocol.proto.

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

@$core.Deprecated('Use commandDescriptor instead')
const Command$json = {
  '1': 'Command',
  '2': [
    {'1': 'CMD_UNKNOWN', '2': 0},
    {'1': 'CMD_CONNECT', '2': 1},
    {'1': 'CMD_CONNECT_RSP', '2': 2},
    {'1': 'CMD_HEARTBEAT', '2': 3},
    {'1': 'CMD_KICK', '2': 4},
    {'1': 'CMD_DISCONNECT', '2': 5},
    {'1': 'CMD_MESSAGE_UP', '2': 10},
    {'1': 'CMD_MESSAGE_UP_RSP', '2': 11},
    {'1': 'CMD_MESSAGE_PUSH', '2': 12},
    {'1': 'CMD_ACK', '2': 13},
    {'1': 'CMD_SYNC', '2': 14},
    {'1': 'CMD_SYNC_RSP', '2': 15},
    {'1': 'CMD_EVENT', '2': 16},
    {'1': 'CMD_TYPING', '2': 17},
  ],
};

/// Descriptor for `Command`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List commandDescriptor = $convert.base64Decode(
    'CgdDb21tYW5kEg8KC0NNRF9VTktOT1dOEAASDwoLQ01EX0NPTk5FQ1QQARITCg9DTURfQ09OTk'
    'VDVF9SU1AQAhIRCg1DTURfSEVBUlRCRUFUEAMSDAoIQ01EX0tJQ0sQBBISCg5DTURfRElTQ09O'
    'TkVDVBAFEhIKDkNNRF9NRVNTQUdFX1VQEAoSFgoSQ01EX01FU1NBR0VfVVBfUlNQEAsSFAoQQ0'
    '1EX01FU1NBR0VfUFVTSBAMEgsKB0NNRF9BQ0sQDRIMCghDTURfU1lOQxAOEhAKDENNRF9TWU5D'
    'X1JTUBAPEg0KCUNNRF9FVkVOVBAQEg4KCkNNRF9UWVBJTkcQEQ==');

@$core.Deprecated('Use ackTargetDescriptor instead')
const AckTarget$json = {
  '1': 'AckTarget',
  '2': [
    {'1': 'ACK_UNKNOWN', '2': 0},
    {'1': 'ACK_FOR_UP', '2': 1},
    {'1': 'ACK_FOR_PUSH', '2': 2},
  ],
};

/// Descriptor for `AckTarget`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List ackTargetDescriptor = $convert.base64Decode(
    'CglBY2tUYXJnZXQSDwoLQUNLX1VOS05PV04QABIOCgpBQ0tfRk9SX1VQEAESEAoMQUNLX0ZPUl'
    '9QVVNIEAI=');

@$core.Deprecated('Use frameDescriptor instead')
const Frame$json = {
  '1': 'Frame',
  '2': [
    {'1': 'frame_id', '3': 1, '4': 1, '5': 13, '10': 'frameId'},
    {'1': 'cmd', '3': 2, '4': 1, '5': 14, '6': '.yim.Command', '10': 'cmd'},
    {'1': 'error', '3': 3, '4': 1, '5': 11, '6': '.yim.Error', '10': 'error'},
    {
      '1': 'connect',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.yim.ConnectReq',
      '9': 0,
      '10': 'connect'
    },
    {
      '1': 'connect_rsp',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.yim.ConnectRsp',
      '9': 0,
      '10': 'connectRsp'
    },
    {
      '1': 'heartbeat',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.yim.Heartbeat',
      '9': 0,
      '10': 'heartbeat'
    },
    {
      '1': 'kick',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.yim.Kick',
      '9': 0,
      '10': 'kick'
    },
    {
      '1': 'disconnect',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.yim.Disconnect',
      '9': 0,
      '10': 'disconnect'
    },
    {
      '1': 'message_up',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.yim.MessageUpReq',
      '9': 0,
      '10': 'messageUp'
    },
    {
      '1': 'message_up_rsp',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.yim.MessageUpRsp',
      '9': 0,
      '10': 'messageUpRsp'
    },
    {
      '1': 'message_push',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.yim.MessagePush',
      '9': 0,
      '10': 'messagePush'
    },
    {
      '1': 'ack',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.yim.Ack',
      '9': 0,
      '10': 'ack'
    },
    {
      '1': 'sync',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.yim.SyncReq',
      '9': 0,
      '10': 'sync'
    },
    {
      '1': 'sync_rsp',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.yim.SyncRsp',
      '9': 0,
      '10': 'syncRsp'
    },
    {
      '1': 'event',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.yim.EventFrame',
      '9': 0,
      '10': 'event'
    },
    {
      '1': 'typing',
      '3': 27,
      '4': 1,
      '5': 11,
      '6': '.yim.Typing',
      '9': 0,
      '10': 'typing'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `Frame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List frameDescriptor = $convert.base64Decode(
    'CgVGcmFtZRIZCghmcmFtZV9pZBgBIAEoDVIHZnJhbWVJZBIeCgNjbWQYAiABKA4yDC55aW0uQ2'
    '9tbWFuZFIDY21kEiAKBWVycm9yGAMgASgLMgoueWltLkVycm9yUgVlcnJvchIrCgdjb25uZWN0'
    'GAogASgLMg8ueWltLkNvbm5lY3RSZXFIAFIHY29ubmVjdBIyCgtjb25uZWN0X3JzcBgLIAEoCz'
    'IPLnlpbS5Db25uZWN0UnNwSABSCmNvbm5lY3RSc3ASLgoJaGVhcnRiZWF0GAwgASgLMg4ueWlt'
    'LkhlYXJ0YmVhdEgAUgloZWFydGJlYXQSHwoEa2ljaxgNIAEoCzIJLnlpbS5LaWNrSABSBGtpY2'
    'sSMQoKZGlzY29ubmVjdBgOIAEoCzIPLnlpbS5EaXNjb25uZWN0SABSCmRpc2Nvbm5lY3QSMgoK'
    'bWVzc2FnZV91cBgUIAEoCzIRLnlpbS5NZXNzYWdlVXBSZXFIAFIJbWVzc2FnZVVwEjkKDm1lc3'
    'NhZ2VfdXBfcnNwGBUgASgLMhEueWltLk1lc3NhZ2VVcFJzcEgAUgxtZXNzYWdlVXBSc3ASNQoM'
    'bWVzc2FnZV9wdXNoGBYgASgLMhAueWltLk1lc3NhZ2VQdXNoSABSC21lc3NhZ2VQdXNoEhwKA2'
    'FjaxgXIAEoCzIILnlpbS5BY2tIAFIDYWNrEiIKBHN5bmMYGCABKAsyDC55aW0uU3luY1JlcUgA'
    'UgRzeW5jEikKCHN5bmNfcnNwGBkgASgLMgwueWltLlN5bmNSc3BIAFIHc3luY1JzcBInCgVldm'
    'VudBgaIAEoCzIPLnlpbS5FdmVudEZyYW1lSABSBWV2ZW50EiUKBnR5cGluZxgbIAEoCzILLnlp'
    'bS5UeXBpbmdIAFIGdHlwaW5nQgkKB3BheWxvYWQ=');

@$core.Deprecated('Use connectReqDescriptor instead')
const ConnectReq$json = {
  '1': 'ConnectReq',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {
      '1': 'device',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.yim.DeviceInfo',
      '10': 'device'
    },
  ],
};

/// Descriptor for `ConnectReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectReqDescriptor = $convert.base64Decode(
    'CgpDb25uZWN0UmVxEhQKBXRva2VuGAEgASgJUgV0b2tlbhInCgZkZXZpY2UYAiABKAsyDy55aW'
    '0uRGV2aWNlSW5mb1IGZGV2aWNl');

@$core.Deprecated('Use connectRspDescriptor instead')
const ConnectRsp$json = {
  '1': 'ConnectRsp',
  '2': [
    {'1': 'server_time_ms', '3': 1, '4': 1, '5': 3, '10': 'serverTimeMs'},
    {'1': 'user_sync_seq', '3': 2, '4': 1, '5': 3, '10': 'userSyncSeq'},
  ],
};

/// Descriptor for `ConnectRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectRspDescriptor = $convert.base64Decode(
    'CgpDb25uZWN0UnNwEiQKDnNlcnZlcl90aW1lX21zGAEgASgDUgxzZXJ2ZXJUaW1lTXMSIgoNdX'
    'Nlcl9zeW5jX3NlcRgCIAEoA1ILdXNlclN5bmNTZXE=');

@$core.Deprecated('Use heartbeatDescriptor instead')
const Heartbeat$json = {
  '1': 'Heartbeat',
  '2': [
    {'1': 'last_frame_id', '3': 1, '4': 1, '5': 4, '10': 'lastFrameId'},
  ],
};

/// Descriptor for `Heartbeat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatDescriptor = $convert.base64Decode(
    'CglIZWFydGJlYXQSIgoNbGFzdF9mcmFtZV9pZBgBIAEoBFILbGFzdEZyYW1lSWQ=');

@$core.Deprecated('Use kickDescriptor instead')
const Kick$json = {
  '1': 'Kick',
  '2': [
    {'1': 'reason', '3': 1, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'user_sync_seq', '3': 2, '4': 1, '5': 3, '10': 'userSyncSeq'},
  ],
};

/// Descriptor for `Kick`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List kickDescriptor = $convert.base64Decode(
    'CgRLaWNrEhYKBnJlYXNvbhgBIAEoCVIGcmVhc29uEiIKDXVzZXJfc3luY19zZXEYAiABKANSC3'
    'VzZXJTeW5jU2Vx');

@$core.Deprecated('Use disconnectDescriptor instead')
const Disconnect$json = {
  '1': 'Disconnect',
  '2': [
    {'1': 'reason', '3': 1, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'retry_after_ms', '3': 2, '4': 1, '5': 5, '10': 'retryAfterMs'},
  ],
};

/// Descriptor for `Disconnect`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disconnectDescriptor = $convert.base64Decode(
    'CgpEaXNjb25uZWN0EhYKBnJlYXNvbhgBIAEoCVIGcmVhc29uEiQKDnJldHJ5X2FmdGVyX21zGA'
    'IgASgFUgxyZXRyeUFmdGVyTXM=');

@$core.Deprecated('Use messageUpReqDescriptor instead')
const MessageUpReq$json = {
  '1': 'MessageUpReq',
  '2': [
    {'1': 'client_msg_id', '3': 1, '4': 1, '5': 4, '10': 'clientMsgId'},
    {'1': 'conv_id', '3': 2, '4': 1, '5': 3, '10': 'convId'},
    {
      '1': 'content',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.yim.ConvMsgContent',
      '10': 'content'
    },
  ],
};

/// Descriptor for `MessageUpReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageUpReqDescriptor = $convert.base64Decode(
    'CgxNZXNzYWdlVXBSZXESIgoNY2xpZW50X21zZ19pZBgBIAEoBFILY2xpZW50TXNnSWQSFwoHY2'
    '9udl9pZBgCIAEoA1IGY29udklkEi0KB2NvbnRlbnQYAyABKAsyEy55aW0uQ29udk1zZ0NvbnRl'
    'bnRSB2NvbnRlbnQ=');

@$core.Deprecated('Use messageUpRspDescriptor instead')
const MessageUpRsp$json = {
  '1': 'MessageUpRsp',
  '2': [
    {'1': 'client_msg_id', '3': 1, '4': 1, '5': 4, '10': 'clientMsgId'},
    {'1': 'msg_id', '3': 2, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'seq', '3': 3, '4': 1, '5': 3, '10': 'seq'},
    {'1': 'server_time_ms', '3': 4, '4': 1, '5': 3, '10': 'serverTimeMs'},
  ],
};

/// Descriptor for `MessageUpRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageUpRspDescriptor = $convert.base64Decode(
    'CgxNZXNzYWdlVXBSc3ASIgoNY2xpZW50X21zZ19pZBgBIAEoBFILY2xpZW50TXNnSWQSFQoGbX'
    'NnX2lkGAIgASgDUgVtc2dJZBIQCgNzZXEYAyABKANSA3NlcRIkCg5zZXJ2ZXJfdGltZV9tcxgE'
    'IAEoA1IMc2VydmVyVGltZU1z');

@$core.Deprecated('Use messagePushDescriptor instead')
const MessagePush$json = {
  '1': 'MessagePush',
  '2': [
    {'1': 'conv_id', '3': 1, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'max_seq', '3': 2, '4': 1, '5': 3, '10': 'maxSeq'},
    {'1': 'from_uid', '3': 3, '4': 1, '5': 3, '10': 'fromUid'},
    {'1': 'user_sync_seq', '3': 4, '4': 1, '5': 3, '10': 'userSyncSeq'},
  ],
};

/// Descriptor for `MessagePush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messagePushDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlUHVzaBIXCgdjb252X2lkGAEgASgDUgZjb252SWQSFwoHbWF4X3NlcRgCIAEoA1'
    'IGbWF4U2VxEhkKCGZyb21fdWlkGAMgASgDUgdmcm9tVWlkEiIKDXVzZXJfc3luY19zZXEYBCAB'
    'KANSC3VzZXJTeW5jU2Vx');

@$core.Deprecated('Use ackDescriptor instead')
const Ack$json = {
  '1': 'Ack',
  '2': [
    {'1': 'conv_id', '3': 1, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'ack_seq', '3': 2, '4': 1, '5': 3, '10': 'ackSeq'},
    {'1': 'client_msg_id', '3': 3, '4': 1, '5': 4, '10': 'clientMsgId'},
    {
      '1': 'target',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.yim.AckTarget',
      '10': 'target'
    },
  ],
};

/// Descriptor for `Ack`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ackDescriptor = $convert.base64Decode(
    'CgNBY2sSFwoHY29udl9pZBgBIAEoA1IGY29udklkEhcKB2Fja19zZXEYAiABKANSBmFja1NlcR'
    'IiCg1jbGllbnRfbXNnX2lkGAMgASgEUgtjbGllbnRNc2dJZBImCgZ0YXJnZXQYBCABKA4yDi55'
    'aW0uQWNrVGFyZ2V0UgZ0YXJnZXQ=');

@$core.Deprecated('Use syncReqDescriptor instead')
const SyncReq$json = {
  '1': 'SyncReq',
  '2': [
    {'1': 'user_sync_seq', '3': 1, '4': 1, '5': 3, '10': 'userSyncSeq'},
    {
      '1': 'watermarks',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.yim.ConvWatermark',
      '10': 'watermarks'
    },
  ],
};

/// Descriptor for `SyncReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncReqDescriptor = $convert.base64Decode(
    'CgdTeW5jUmVxEiIKDXVzZXJfc3luY19zZXEYASABKANSC3VzZXJTeW5jU2VxEjIKCndhdGVybW'
    'Fya3MYAiADKAsyEi55aW0uQ29udldhdGVybWFya1IKd2F0ZXJtYXJrcw==');

@$core.Deprecated('Use convWatermarkDescriptor instead')
const ConvWatermark$json = {
  '1': 'ConvWatermark',
  '2': [
    {'1': 'conv_id', '3': 1, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'last_seq', '3': 2, '4': 1, '5': 3, '10': 'lastSeq'},
  ],
};

/// Descriptor for `ConvWatermark`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List convWatermarkDescriptor = $convert.base64Decode(
    'Cg1Db252V2F0ZXJtYXJrEhcKB2NvbnZfaWQYASABKANSBmNvbnZJZBIZCghsYXN0X3NlcRgCIA'
    'EoA1IHbGFzdFNlcQ==');

@$core.Deprecated('Use syncRspDescriptor instead')
const SyncRsp$json = {
  '1': 'SyncRsp',
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

/// Descriptor for `SyncRsp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncRspDescriptor = $convert.base64Decode(
    'CgdTeW5jUnNwEiIKDXVzZXJfc3luY19zZXEYASABKANSC3VzZXJTeW5jU2VxEiwKCG1lc3NhZ2'
    'VzGAIgAygLMhAueWltLkNvbnZNZXNzYWdlUghtZXNzYWdlcxIuCghvdmVyZmxvdxgDIAMoCzIS'
    'LnlpbS5Db252V2F0ZXJtYXJrUghvdmVyZmxvdw==');

@$core.Deprecated('Use eventFrameDescriptor instead')
const EventFrame$json = {
  '1': 'EventFrame',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'uid', '3': 2, '4': 1, '5': 3, '10': 'uid'},
    {'1': 'conv_id', '3': 3, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'online', '3': 4, '4': 1, '5': 8, '10': 'online'},
    {'1': 'seq', '3': 5, '4': 1, '5': 3, '10': 'seq'},
  ],
};

/// Descriptor for `EventFrame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventFrameDescriptor = $convert.base64Decode(
    'CgpFdmVudEZyYW1lEhIKBHR5cGUYASABKAlSBHR5cGUSEAoDdWlkGAIgASgDUgN1aWQSFwoHY2'
    '9udl9pZBgDIAEoA1IGY29udklkEhYKBm9ubGluZRgEIAEoCFIGb25saW5lEhAKA3NlcRgFIAEo'
    'A1IDc2Vx');

@$core.Deprecated('Use typingDescriptor instead')
const Typing$json = {
  '1': 'Typing',
  '2': [
    {'1': 'conv_id', '3': 1, '4': 1, '5': 3, '10': 'convId'},
  ],
};

/// Descriptor for `Typing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingDescriptor =
    $convert.base64Decode('CgZUeXBpbmcSFwoHY29udl9pZBgBIAEoA1IGY29udklk');

@$core.Deprecated('Use relationEventDescriptor instead')
const RelationEvent$json = {
  '1': 'RelationEvent',
  '2': [
    {
      '1': 'event',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yim.EventFrame',
      '10': 'event'
    },
    {'1': 'targets', '3': 2, '4': 3, '5': 3, '10': 'targets'},
  ],
};

/// Descriptor for `RelationEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List relationEventDescriptor = $convert.base64Decode(
    'Cg1SZWxhdGlvbkV2ZW50EiUKBWV2ZW50GAEgASgLMg8ueWltLkV2ZW50RnJhbWVSBWV2ZW50Eh'
    'gKB3RhcmdldHMYAiADKANSB3RhcmdldHM=');

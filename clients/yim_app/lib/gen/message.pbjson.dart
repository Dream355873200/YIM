// This is a generated file - do not edit.
//
// Generated from message.proto.

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

@$core.Deprecated('Use convTypeDescriptor instead')
const ConvType$json = {
  '1': 'ConvType',
  '2': [
    {'1': 'CONV_UNKNOWN', '2': 0},
    {'1': 'CONV_SINGLE', '2': 1},
    {'1': 'CONV_GROUP', '2': 2},
  ],
};

/// Descriptor for `ConvType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List convTypeDescriptor = $convert.base64Decode(
    'CghDb252VHlwZRIQCgxDT05WX1VOS05PV04QABIPCgtDT05WX1NJTkdMRRABEg4KCkNPTlZfR1'
    'JPVVAQAg==');

@$core.Deprecated('Use msgTypeDescriptor instead')
const MsgType$json = {
  '1': 'MsgType',
  '2': [
    {'1': 'MSG_UNKNOWN', '2': 0},
    {'1': 'MSG_TEXT', '2': 1},
    {'1': 'MSG_IMAGE', '2': 2},
    {'1': 'MSG_FILE', '2': 3},
    {'1': 'MSG_AUDIO', '2': 4},
    {'1': 'MSG_REVOKE', '2': 10},
    {'1': 'MSG_SYSTEM', '2': 11},
  ],
};

/// Descriptor for `MsgType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List msgTypeDescriptor = $convert.base64Decode(
    'CgdNc2dUeXBlEg8KC01TR19VTktOT1dOEAASDAoITVNHX1RFWFQQARINCglNU0dfSU1BR0UQAh'
    'IMCghNU0dfRklMRRADEg0KCU1TR19BVURJTxAEEg4KCk1TR19SRVZPS0UQChIOCgpNU0dfU1lT'
    'VEVNEAs=');

@$core.Deprecated('Use sendStateDescriptor instead')
const SendState$json = {
  '1': 'SendState',
  '2': [
    {'1': 'SEND_UNKNOWN', '2': 0},
    {'1': 'SEND_PENDING', '2': 1},
    {'1': 'SEND_OK', '2': 2},
    {'1': 'SEND_FAILED', '2': 3},
  ],
};

/// Descriptor for `SendState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sendStateDescriptor = $convert.base64Decode(
    'CglTZW5kU3RhdGUSEAoMU0VORF9VTktOT1dOEAASEAoMU0VORF9QRU5ESU5HEAESCwoHU0VORF'
    '9PSxACEg8KC1NFTkRfRkFJTEVEEAM=');

@$core.Deprecated('Use convDescriptor instead')
const Conv$json = {
  '1': 'Conv',
  '2': [
    {'1': 'conv_id', '3': 1, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'type', '3': 2, '4': 1, '5': 14, '6': '.yim.ConvType', '10': 'type'},
    {'1': 'member_uids', '3': 3, '4': 3, '5': 3, '10': 'memberUids'},
    {'1': 'create_time_ms', '3': 4, '4': 1, '5': 3, '10': 'createTimeMs'},
    {'1': 'last_seq', '3': 5, '4': 1, '5': 3, '10': 'lastSeq'},
    {'1': 'name', '3': 6, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar', '3': 7, '4': 1, '5': 9, '10': 'avatar'},
  ],
};

/// Descriptor for `Conv`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List convDescriptor = $convert.base64Decode(
    'CgRDb252EhcKB2NvbnZfaWQYASABKANSBmNvbnZJZBIhCgR0eXBlGAIgASgOMg0ueWltLkNvbn'
    'ZUeXBlUgR0eXBlEh8KC21lbWJlcl91aWRzGAMgAygDUgptZW1iZXJVaWRzEiQKDmNyZWF0ZV90'
    'aW1lX21zGAQgASgDUgxjcmVhdGVUaW1lTXMSGQoIbGFzdF9zZXEYBSABKANSB2xhc3RTZXESEg'
    'oEbmFtZRgGIAEoCVIEbmFtZRIWCgZhdmF0YXIYByABKAlSBmF2YXRhcg==');

@$core.Deprecated('Use convMsgContentDescriptor instead')
const ConvMsgContent$json = {
  '1': 'ConvMsgContent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.yim.MsgType', '10': 'type'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'media',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.yim.MediaMeta',
      '10': 'media'
    },
    {'1': 'ext', '3': 4, '4': 1, '5': 11, '6': '.yim.Ext', '10': 'ext'},
  ],
};

/// Descriptor for `ConvMsgContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List convMsgContentDescriptor = $convert.base64Decode(
    'Cg5Db252TXNnQ29udGVudBIgCgR0eXBlGAEgASgOMgwueWltLk1zZ1R5cGVSBHR5cGUSEgoEdG'
    'V4dBgCIAEoCVIEdGV4dBIkCgVtZWRpYRgDIAEoCzIOLnlpbS5NZWRpYU1ldGFSBW1lZGlhEhoK'
    'A2V4dBgEIAEoCzIILnlpbS5FeHRSA2V4dA==');

@$core.Deprecated('Use mediaMetaDescriptor instead')
const MediaMeta$json = {
  '1': 'MediaMeta',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'size', '3': 2, '4': 1, '5': 3, '10': 'size'},
    {'1': 'width', '3': 3, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 4, '4': 1, '5': 5, '10': 'height'},
    {'1': 'duration_ms', '3': 5, '4': 1, '5': 5, '10': 'durationMs'},
  ],
};

/// Descriptor for `MediaMeta`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaMetaDescriptor = $convert.base64Decode(
    'CglNZWRpYU1ldGESEAoDdXJsGAEgASgJUgN1cmwSEgoEc2l6ZRgCIAEoA1IEc2l6ZRIUCgV3aW'
    'R0aBgDIAEoBVIFd2lkdGgSFgoGaGVpZ2h0GAQgASgFUgZoZWlnaHQSHwoLZHVyYXRpb25fbXMY'
    'BSABKAVSCmR1cmF0aW9uTXM=');

@$core.Deprecated('Use extDescriptor instead')
const Ext$json = {
  '1': 'Ext',
  '2': [
    {'1': 'ref_msg_id', '3': 1, '4': 1, '5': 3, '10': 'refMsgId'},
    {'1': 'op_uid', '3': 2, '4': 1, '5': 3, '10': 'opUid'},
    {'1': 'json', '3': 3, '4': 1, '5': 9, '10': 'json'},
    {'1': 'ref_text', '3': 4, '4': 1, '5': 9, '10': 'refText'},
  ],
};

/// Descriptor for `Ext`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extDescriptor = $convert.base64Decode(
    'CgNFeHQSHAoKcmVmX21zZ19pZBgBIAEoA1IIcmVmTXNnSWQSFQoGb3BfdWlkGAIgASgDUgVvcF'
    'VpZBISCgRqc29uGAMgASgJUgRqc29uEhkKCHJlZl90ZXh0GAQgASgJUgdyZWZUZXh0');

@$core.Deprecated('Use convMessageDescriptor instead')
const ConvMessage$json = {
  '1': 'ConvMessage',
  '2': [
    {'1': 'msg_id', '3': 1, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'conv_id', '3': 2, '4': 1, '5': 3, '10': 'convId'},
    {'1': 'from_uid', '3': 3, '4': 1, '5': 3, '10': 'fromUid'},
    {'1': 'seq', '3': 4, '4': 1, '5': 3, '10': 'seq'},
    {'1': 'server_time_ms', '3': 5, '4': 1, '5': 3, '10': 'serverTimeMs'},
    {
      '1': 'content',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.yim.ConvMsgContent',
      '10': 'content'
    },
  ],
};

/// Descriptor for `ConvMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List convMessageDescriptor = $convert.base64Decode(
    'CgtDb252TWVzc2FnZRIVCgZtc2dfaWQYASABKANSBW1zZ0lkEhcKB2NvbnZfaWQYAiABKANSBm'
    'NvbnZJZBIZCghmcm9tX3VpZBgDIAEoA1IHZnJvbVVpZBIQCgNzZXEYBCABKANSA3NlcRIkCg5z'
    'ZXJ2ZXJfdGltZV9tcxgFIAEoA1IMc2VydmVyVGltZU1zEi0KB2NvbnRlbnQYBiABKAsyEy55aW'
    '0uQ29udk1zZ0NvbnRlbnRSB2NvbnRlbnQ=');

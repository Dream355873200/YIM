// This is a generated file - do not edit.
//
// Generated from common.proto.

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

@$core.Deprecated('Use deviceTypeDescriptor instead')
const DeviceType$json = {
  '1': 'DeviceType',
  '2': [
    {'1': 'DEVICE_UNKNOWN', '2': 0},
    {'1': 'DEVICE_MOBILE', '2': 1},
    {'1': 'DEVICE_DESKTOP', '2': 2},
    {'1': 'DEVICE_WEB', '2': 3},
  ],
};

/// Descriptor for `DeviceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deviceTypeDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VUeXBlEhIKDkRFVklDRV9VTktOT1dOEAASEQoNREVWSUNFX01PQklMRRABEhIKDk'
    'RFVklDRV9ERVNLVE9QEAISDgoKREVWSUNFX1dFQhAD');

@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = {
  '1': 'DeviceInfo',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yim.DeviceType',
      '10': 'type'
    },
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'client_version', '3': 3, '4': 1, '5': 9, '10': 'clientVersion'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VJbmZvEiMKBHR5cGUYASABKA4yDy55aW0uRGV2aWNlVHlwZVIEdHlwZRIbCglkZX'
    'ZpY2VfaWQYAiABKAlSCGRldmljZUlkEiUKDmNsaWVudF92ZXJzaW9uGAMgASgJUg1jbGllbnRW'
    'ZXJzaW9u');

@$core.Deprecated('Use errorDescriptor instead')
const Error$json = {
  '1': 'Error',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'retry_after_ms', '3': 3, '4': 1, '5': 3, '10': 'retryAfterMs'},
  ],
};

/// Descriptor for `Error`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorDescriptor = $convert.base64Decode(
    'CgVFcnJvchISCgRjb2RlGAEgASgFUgRjb2RlEhAKA21zZxgCIAEoCVIDbXNnEiQKDnJldHJ5X2'
    'FmdGVyX21zGAMgASgDUgxyZXRyeUFmdGVyTXM=');

@$core.Deprecated('Use pageInfoDescriptor instead')
const PageInfo$json = {
  '1': 'PageInfo',
  '2': [
    {'1': 'page_num', '3': 1, '4': 1, '5': 5, '10': 'pageNum'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `PageInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pageInfoDescriptor = $convert.base64Decode(
    'CghQYWdlSW5mbxIZCghwYWdlX251bRgBIAEoBVIHcGFnZU51bRIbCglwYWdlX3NpemUYAiABKA'
    'VSCHBhZ2VTaXpl');

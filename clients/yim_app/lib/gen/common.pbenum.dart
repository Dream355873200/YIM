// This is a generated file - do not edit.
//
// Generated from common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class DeviceType extends $pb.ProtobufEnum {
  static const DeviceType DEVICE_UNKNOWN =
      DeviceType._(0, _omitEnumNames ? '' : 'DEVICE_UNKNOWN');
  static const DeviceType DEVICE_MOBILE =
      DeviceType._(1, _omitEnumNames ? '' : 'DEVICE_MOBILE');
  static const DeviceType DEVICE_DESKTOP =
      DeviceType._(2, _omitEnumNames ? '' : 'DEVICE_DESKTOP');
  static const DeviceType DEVICE_WEB =
      DeviceType._(3, _omitEnumNames ? '' : 'DEVICE_WEB');

  static const $core.List<DeviceType> values = <DeviceType>[
    DEVICE_UNKNOWN,
    DEVICE_MOBILE,
    DEVICE_DESKTOP,
    DEVICE_WEB,
  ];

  static final $core.List<DeviceType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static DeviceType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeviceType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');

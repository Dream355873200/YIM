// This is a generated file - do not edit.
//
// Generated from service_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PullMode extends $pb.ProtobufEnum {
  static const PullMode PULL_UNKNOWN =
      PullMode._(0, _omitEnumNames ? '' : 'PULL_UNKNOWN');
  static const PullMode PULL_SEQ_RANGE =
      PullMode._(1, _omitEnumNames ? '' : 'PULL_SEQ_RANGE');
  static const PullMode PULL_PAGE_BACKWARD =
      PullMode._(2, _omitEnumNames ? '' : 'PULL_PAGE_BACKWARD');

  static const $core.List<PullMode> values = <PullMode>[
    PULL_UNKNOWN,
    PULL_SEQ_RANGE,
    PULL_PAGE_BACKWARD,
  ];

  static final $core.List<PullMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static PullMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PullMode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');

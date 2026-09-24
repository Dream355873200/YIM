// This is a generated file - do not edit.
//
// Generated from service_relation.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Presence extends $pb.ProtobufEnum {
  static const Presence PRESENCE_UNKNOWN =
      Presence._(0, _omitEnumNames ? '' : 'PRESENCE_UNKNOWN');
  static const Presence PRESENCE_OFFLINE =
      Presence._(1, _omitEnumNames ? '' : 'PRESENCE_OFFLINE');
  static const Presence PRESENCE_ONLINE =
      Presence._(2, _omitEnumNames ? '' : 'PRESENCE_ONLINE');

  static const $core.List<Presence> values = <Presence>[
    PRESENCE_UNKNOWN,
    PRESENCE_OFFLINE,
    PRESENCE_ONLINE,
  ];

  static final $core.List<Presence?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Presence? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Presence._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');

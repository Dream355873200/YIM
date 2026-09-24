// This is a generated file - do not edit.
//
// Generated from message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ConvType extends $pb.ProtobufEnum {
  static const ConvType CONV_UNKNOWN =
      ConvType._(0, _omitEnumNames ? '' : 'CONV_UNKNOWN');
  static const ConvType CONV_SINGLE =
      ConvType._(1, _omitEnumNames ? '' : 'CONV_SINGLE');
  static const ConvType CONV_GROUP =
      ConvType._(2, _omitEnumNames ? '' : 'CONV_GROUP');

  static const $core.List<ConvType> values = <ConvType>[
    CONV_UNKNOWN,
    CONV_SINGLE,
    CONV_GROUP,
  ];

  static final $core.List<ConvType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ConvType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ConvType._(super.value, super.name);
}

class MsgType extends $pb.ProtobufEnum {
  static const MsgType MSG_UNKNOWN =
      MsgType._(0, _omitEnumNames ? '' : 'MSG_UNKNOWN');
  static const MsgType MSG_TEXT =
      MsgType._(1, _omitEnumNames ? '' : 'MSG_TEXT');
  static const MsgType MSG_IMAGE =
      MsgType._(2, _omitEnumNames ? '' : 'MSG_IMAGE');
  static const MsgType MSG_FILE =
      MsgType._(3, _omitEnumNames ? '' : 'MSG_FILE');
  static const MsgType MSG_AUDIO =
      MsgType._(4, _omitEnumNames ? '' : 'MSG_AUDIO');
  static const MsgType MSG_REVOKE =
      MsgType._(10, _omitEnumNames ? '' : 'MSG_REVOKE');
  static const MsgType MSG_SYSTEM =
      MsgType._(11, _omitEnumNames ? '' : 'MSG_SYSTEM');

  static const $core.List<MsgType> values = <MsgType>[
    MSG_UNKNOWN,
    MSG_TEXT,
    MSG_IMAGE,
    MSG_FILE,
    MSG_AUDIO,
    MSG_REVOKE,
    MSG_SYSTEM,
  ];

  static final $core.Map<$core.int, MsgType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static MsgType? valueOf($core.int value) => _byValue[value];

  const MsgType._(super.value, super.name);
}

/// 发送者视角的消息状态机(仅上行未落库阶段有用, 落库后由 seq 决定)
class SendState extends $pb.ProtobufEnum {
  static const SendState SEND_UNKNOWN =
      SendState._(0, _omitEnumNames ? '' : 'SEND_UNKNOWN');
  static const SendState SEND_PENDING =
      SendState._(1, _omitEnumNames ? '' : 'SEND_PENDING');
  static const SendState SEND_OK =
      SendState._(2, _omitEnumNames ? '' : 'SEND_OK');
  static const SendState SEND_FAILED =
      SendState._(3, _omitEnumNames ? '' : 'SEND_FAILED');

  static const $core.List<SendState> values = <SendState>[
    SEND_UNKNOWN,
    SEND_PENDING,
    SEND_OK,
    SEND_FAILED,
  ];

  static final $core.List<SendState?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SendState? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SendState._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');

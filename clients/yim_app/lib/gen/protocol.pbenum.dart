// This is a generated file - do not edit.
//
// Generated from protocol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Command extends $pb.ProtobufEnum {
  static const Command CMD_UNKNOWN =
      Command._(0, _omitEnumNames ? '' : 'CMD_UNKNOWN');

  /// 连接生命周期
  static const Command CMD_CONNECT =
      Command._(1, _omitEnumNames ? '' : 'CMD_CONNECT');
  static const Command CMD_CONNECT_RSP =
      Command._(2, _omitEnumNames ? '' : 'CMD_CONNECT_RSP');
  static const Command CMD_HEARTBEAT =
      Command._(3, _omitEnumNames ? '' : 'CMD_HEARTBEAT');
  static const Command CMD_KICK =
      Command._(4, _omitEnumNames ? '' : 'CMD_KICK');
  static const Command CMD_DISCONNECT =
      Command._(5, _omitEnumNames ? '' : 'CMD_DISCONNECT');

  /// 消息收发 (推拉结合: 推送只带轻通知, 不带消息体)
  static const Command CMD_MESSAGE_UP =
      Command._(10, _omitEnumNames ? '' : 'CMD_MESSAGE_UP');
  static const Command CMD_MESSAGE_UP_RSP =
      Command._(11, _omitEnumNames ? '' : 'CMD_MESSAGE_UP_RSP');
  static const Command CMD_MESSAGE_PUSH =
      Command._(12, _omitEnumNames ? '' : 'CMD_MESSAGE_PUSH');
  static const Command CMD_ACK = Command._(13, _omitEnumNames ? '' : 'CMD_ACK');

  /// 同步 (断线重连/唤醒/发现缺号时)
  static const Command CMD_SYNC =
      Command._(14, _omitEnumNames ? '' : 'CMD_SYNC');
  static const Command CMD_SYNC_RSP =
      Command._(15, _omitEnumNames ? '' : 'CMD_SYNC_RSP');

  /// 业务事件通知 (里程碑10): 好友/群/在线状态的"推"侧。
  /// 推保证实时, 拉保证可靠 —— 事件可丢可重, 客户端收到后局部重拉。
  static const Command CMD_EVENT =
      Command._(16, _omitEnumNames ? '' : 'CMD_EVENT');
  static const Command CMD_TYPING =
      Command._(17, _omitEnumNames ? '' : 'CMD_TYPING');

  static const $core.List<Command> values = <Command>[
    CMD_UNKNOWN,
    CMD_CONNECT,
    CMD_CONNECT_RSP,
    CMD_HEARTBEAT,
    CMD_KICK,
    CMD_DISCONNECT,
    CMD_MESSAGE_UP,
    CMD_MESSAGE_UP_RSP,
    CMD_MESSAGE_PUSH,
    CMD_ACK,
    CMD_SYNC,
    CMD_SYNC_RSP,
    CMD_EVENT,
    CMD_TYPING,
  ];

  static final $core.List<Command?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 17);
  static Command? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Command._(super.value, super.name);
}

class AckTarget extends $pb.ProtobufEnum {
  static const AckTarget ACK_UNKNOWN =
      AckTarget._(0, _omitEnumNames ? '' : 'ACK_UNKNOWN');
  static const AckTarget ACK_FOR_UP =
      AckTarget._(1, _omitEnumNames ? '' : 'ACK_FOR_UP');
  static const AckTarget ACK_FOR_PUSH =
      AckTarget._(2, _omitEnumNames ? '' : 'ACK_FOR_PUSH');

  static const $core.List<AckTarget> values = <AckTarget>[
    ACK_UNKNOWN,
    ACK_FOR_UP,
    ACK_FOR_PUSH,
  ];

  static final $core.List<AckTarget?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static AckTarget? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AckTarget._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');

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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $0;
import 'message.pb.dart' as $1;
import 'protocol.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'protocol.pbenum.dart';

enum Frame_Payload {
  connect,
  connectRsp,
  heartbeat,
  kick,
  disconnect,
  messageUp,
  messageUpRsp,
  messagePush,
  ack,
  sync,
  syncRsp,
  event,
  typing,
  notSet
}

/// 连接级统一信封
class Frame extends $pb.GeneratedMessage {
  factory Frame({
    $core.int? frameId,
    Command? cmd,
    $0.Error? error,
    ConnectReq? connect,
    ConnectRsp? connectRsp,
    Heartbeat? heartbeat,
    Kick? kick,
    Disconnect? disconnect,
    MessageUpReq? messageUp,
    MessageUpRsp? messageUpRsp,
    MessagePush? messagePush,
    Ack? ack,
    SyncReq? sync,
    SyncRsp? syncRsp,
    EventFrame? event,
    Typing? typing,
  }) {
    final result = Frame._();
    if (frameId != null) result.frameId = frameId;
    if (cmd != null) result.cmd = cmd;
    if (error != null) result.error = error;
    if (connect != null) result.connect = connect;
    if (connectRsp != null) result.connectRsp = connectRsp;
    if (heartbeat != null) result.heartbeat = heartbeat;
    if (kick != null) result.kick = kick;
    if (disconnect != null) result.disconnect = disconnect;
    if (messageUp != null) result.messageUp = messageUp;
    if (messageUpRsp != null) result.messageUpRsp = messageUpRsp;
    if (messagePush != null) result.messagePush = messagePush;
    if (ack != null) result.ack = ack;
    if (sync != null) result.sync = sync;
    if (syncRsp != null) result.syncRsp = syncRsp;
    if (event != null) result.event = event;
    if (typing != null) result.typing = typing;
    return result;
  }

  Frame._();

  factory Frame.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Frame()..mergeFromBuffer(data, registry);
  factory Frame.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Frame()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Frame_Payload> _Frame_PayloadByTag = {
    10: Frame_Payload.connect,
    11: Frame_Payload.connectRsp,
    12: Frame_Payload.heartbeat,
    13: Frame_Payload.kick,
    14: Frame_Payload.disconnect,
    20: Frame_Payload.messageUp,
    21: Frame_Payload.messageUpRsp,
    22: Frame_Payload.messagePush,
    23: Frame_Payload.ack,
    24: Frame_Payload.sync,
    25: Frame_Payload.syncRsp,
    26: Frame_Payload.event,
    27: Frame_Payload.typing,
    0: Frame_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Frame',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: Frame.$_createMessage)
    ..oo(0, [10, 11, 12, 13, 14, 20, 21, 22, 23, 24, 25, 26, 27])
    ..aI(1, _omitFieldNames ? '' : 'frameId', fieldType: $pb.PbFieldType.OU3)
    ..aE<Command>(2, _omitFieldNames ? '' : 'cmd', enumValues: Command.values)
    ..aOM<$0.Error>(3, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..aOM<ConnectReq>(10, _omitFieldNames ? '' : 'connect',
        subBuilder: ConnectReq.$_createMessage)
    ..aOM<ConnectRsp>(11, _omitFieldNames ? '' : 'connectRsp',
        subBuilder: ConnectRsp.$_createMessage)
    ..aOM<Heartbeat>(12, _omitFieldNames ? '' : 'heartbeat',
        subBuilder: Heartbeat.$_createMessage)
    ..aOM<Kick>(13, _omitFieldNames ? '' : 'kick',
        subBuilder: Kick.$_createMessage)
    ..aOM<Disconnect>(14, _omitFieldNames ? '' : 'disconnect',
        subBuilder: Disconnect.$_createMessage)
    ..aOM<MessageUpReq>(20, _omitFieldNames ? '' : 'messageUp',
        subBuilder: MessageUpReq.$_createMessage)
    ..aOM<MessageUpRsp>(21, _omitFieldNames ? '' : 'messageUpRsp',
        subBuilder: MessageUpRsp.$_createMessage)
    ..aOM<MessagePush>(22, _omitFieldNames ? '' : 'messagePush',
        subBuilder: MessagePush.$_createMessage)
    ..aOM<Ack>(23, _omitFieldNames ? '' : 'ack',
        subBuilder: Ack.$_createMessage)
    ..aOM<SyncReq>(24, _omitFieldNames ? '' : 'sync',
        subBuilder: SyncReq.$_createMessage)
    ..aOM<SyncRsp>(25, _omitFieldNames ? '' : 'syncRsp',
        subBuilder: SyncRsp.$_createMessage)
    ..aOM<EventFrame>(26, _omitFieldNames ? '' : 'event',
        subBuilder: EventFrame.$_createMessage)
    ..aOM<Typing>(27, _omitFieldNames ? '' : 'typing',
        subBuilder: Typing.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Frame clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Frame copyWith(void Function(Frame) updates) =>
      super.copyWith((message) => updates(message as Frame)) as Frame;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Frame() / Frame.new instead')
  static Frame create() => Frame._();
  static $pb.GeneratedMessage $_createMessage() => Frame._();
  @$core.override
  Frame createEmptyInstance() => Frame._();
  @$core.pragma('dart2js:noInline')
  static Frame getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Frame>(Frame.$_createMessage);
  static Frame? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  Frame_Payload whichPayload() => _Frame_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get frameId => $_getIZ(0);
  @$pb.TagNumber(1)
  set frameId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFrameId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrameId() => $_clearField(1);

  @$pb.TagNumber(2)
  Command get cmd => $_getN(1);
  @$pb.TagNumber(2)
  set cmd(Command value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCmd() => $_has(1);
  @$pb.TagNumber(2)
  void clearCmd() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Error get error => $_getN(2);
  @$pb.TagNumber(3)
  set error($0.Error value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Error ensureError() => $_ensure(2);

  @$pb.TagNumber(10)
  ConnectReq get connect => $_getN(3);
  @$pb.TagNumber(10)
  set connect(ConnectReq value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasConnect() => $_has(3);
  @$pb.TagNumber(10)
  void clearConnect() => $_clearField(10);
  @$pb.TagNumber(10)
  ConnectReq ensureConnect() => $_ensure(3);

  @$pb.TagNumber(11)
  ConnectRsp get connectRsp => $_getN(4);
  @$pb.TagNumber(11)
  set connectRsp(ConnectRsp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasConnectRsp() => $_has(4);
  @$pb.TagNumber(11)
  void clearConnectRsp() => $_clearField(11);
  @$pb.TagNumber(11)
  ConnectRsp ensureConnectRsp() => $_ensure(4);

  @$pb.TagNumber(12)
  Heartbeat get heartbeat => $_getN(5);
  @$pb.TagNumber(12)
  set heartbeat(Heartbeat value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasHeartbeat() => $_has(5);
  @$pb.TagNumber(12)
  void clearHeartbeat() => $_clearField(12);
  @$pb.TagNumber(12)
  Heartbeat ensureHeartbeat() => $_ensure(5);

  @$pb.TagNumber(13)
  Kick get kick => $_getN(6);
  @$pb.TagNumber(13)
  set kick(Kick value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasKick() => $_has(6);
  @$pb.TagNumber(13)
  void clearKick() => $_clearField(13);
  @$pb.TagNumber(13)
  Kick ensureKick() => $_ensure(6);

  @$pb.TagNumber(14)
  Disconnect get disconnect => $_getN(7);
  @$pb.TagNumber(14)
  set disconnect(Disconnect value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasDisconnect() => $_has(7);
  @$pb.TagNumber(14)
  void clearDisconnect() => $_clearField(14);
  @$pb.TagNumber(14)
  Disconnect ensureDisconnect() => $_ensure(7);

  @$pb.TagNumber(20)
  MessageUpReq get messageUp => $_getN(8);
  @$pb.TagNumber(20)
  set messageUp(MessageUpReq value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasMessageUp() => $_has(8);
  @$pb.TagNumber(20)
  void clearMessageUp() => $_clearField(20);
  @$pb.TagNumber(20)
  MessageUpReq ensureMessageUp() => $_ensure(8);

  @$pb.TagNumber(21)
  MessageUpRsp get messageUpRsp => $_getN(9);
  @$pb.TagNumber(21)
  set messageUpRsp(MessageUpRsp value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasMessageUpRsp() => $_has(9);
  @$pb.TagNumber(21)
  void clearMessageUpRsp() => $_clearField(21);
  @$pb.TagNumber(21)
  MessageUpRsp ensureMessageUpRsp() => $_ensure(9);

  @$pb.TagNumber(22)
  MessagePush get messagePush => $_getN(10);
  @$pb.TagNumber(22)
  set messagePush(MessagePush value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasMessagePush() => $_has(10);
  @$pb.TagNumber(22)
  void clearMessagePush() => $_clearField(22);
  @$pb.TagNumber(22)
  MessagePush ensureMessagePush() => $_ensure(10);

  @$pb.TagNumber(23)
  Ack get ack => $_getN(11);
  @$pb.TagNumber(23)
  set ack(Ack value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasAck() => $_has(11);
  @$pb.TagNumber(23)
  void clearAck() => $_clearField(23);
  @$pb.TagNumber(23)
  Ack ensureAck() => $_ensure(11);

  @$pb.TagNumber(24)
  SyncReq get sync => $_getN(12);
  @$pb.TagNumber(24)
  set sync(SyncReq value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasSync() => $_has(12);
  @$pb.TagNumber(24)
  void clearSync() => $_clearField(24);
  @$pb.TagNumber(24)
  SyncReq ensureSync() => $_ensure(12);

  @$pb.TagNumber(25)
  SyncRsp get syncRsp => $_getN(13);
  @$pb.TagNumber(25)
  set syncRsp(SyncRsp value) => $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasSyncRsp() => $_has(13);
  @$pb.TagNumber(25)
  void clearSyncRsp() => $_clearField(25);
  @$pb.TagNumber(25)
  SyncRsp ensureSyncRsp() => $_ensure(13);

  @$pb.TagNumber(26)
  EventFrame get event => $_getN(14);
  @$pb.TagNumber(26)
  set event(EventFrame value) => $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasEvent() => $_has(14);
  @$pb.TagNumber(26)
  void clearEvent() => $_clearField(26);
  @$pb.TagNumber(26)
  EventFrame ensureEvent() => $_ensure(14);

  @$pb.TagNumber(27)
  Typing get typing => $_getN(15);
  @$pb.TagNumber(27)
  set typing(Typing value) => $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasTyping() => $_has(15);
  @$pb.TagNumber(27)
  void clearTyping() => $_clearField(27);
  @$pb.TagNumber(27)
  Typing ensureTyping() => $_ensure(15);
}

class ConnectReq extends $pb.GeneratedMessage {
  factory ConnectReq({
    $core.String? token,
    $0.DeviceInfo? device,
  }) {
    final result = ConnectReq._();
    if (token != null) result.token = token;
    if (device != null) result.device = device;
    return result;
  }

  ConnectReq._();

  factory ConnectReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectReq()..mergeFromBuffer(data, registry);
  factory ConnectReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ConnectReq.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aOM<$0.DeviceInfo>(2, _omitFieldNames ? '' : 'device',
        subBuilder: $0.DeviceInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectReq copyWith(void Function(ConnectReq) updates) =>
      super.copyWith((message) => updates(message as ConnectReq)) as ConnectReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConnectReq() / ConnectReq.new instead')
  static ConnectReq create() => ConnectReq._();
  static $pb.GeneratedMessage $_createMessage() => ConnectReq._();
  @$core.override
  ConnectReq createEmptyInstance() => ConnectReq._();
  @$core.pragma('dart2js:noInline')
  static ConnectReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectReq>(ConnectReq.$_createMessage);
  static ConnectReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.DeviceInfo get device => $_getN(1);
  @$pb.TagNumber(2)
  set device($0.DeviceInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDevice() => $_has(1);
  @$pb.TagNumber(2)
  void clearDevice() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.DeviceInfo ensureDevice() => $_ensure(1);
}

class ConnectRsp extends $pb.GeneratedMessage {
  factory ConnectRsp({
    $fixnum.Int64? serverTimeMs,
    $fixnum.Int64? userSyncSeq,
  }) {
    final result = ConnectRsp._();
    if (serverTimeMs != null) result.serverTimeMs = serverTimeMs;
    if (userSyncSeq != null) result.userSyncSeq = userSyncSeq;
    return result;
  }

  ConnectRsp._();

  factory ConnectRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectRsp()..mergeFromBuffer(data, registry);
  factory ConnectRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ConnectRsp.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'serverTimeMs')
    ..aInt64(2, _omitFieldNames ? '' : 'userSyncSeq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectRsp copyWith(void Function(ConnectRsp) updates) =>
      super.copyWith((message) => updates(message as ConnectRsp)) as ConnectRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConnectRsp() / ConnectRsp.new instead')
  static ConnectRsp create() => ConnectRsp._();
  static $pb.GeneratedMessage $_createMessage() => ConnectRsp._();
  @$core.override
  ConnectRsp createEmptyInstance() => ConnectRsp._();
  @$core.pragma('dart2js:noInline')
  static ConnectRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectRsp>(ConnectRsp.$_createMessage);
  static ConnectRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get serverTimeMs => $_getI64(0);
  @$pb.TagNumber(1)
  set serverTimeMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasServerTimeMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearServerTimeMs() => $_clearField(1);

  /// 用户级变更序号快照: 客户端若落后则立即发起 SYNC
  @$pb.TagNumber(2)
  $fixnum.Int64 get userSyncSeq => $_getI64(1);
  @$pb.TagNumber(2)
  set userSyncSeq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserSyncSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserSyncSeq() => $_clearField(2);
}

class Heartbeat extends $pb.GeneratedMessage {
  factory Heartbeat({
    $fixnum.Int64? lastFrameId,
  }) {
    final result = Heartbeat._();
    if (lastFrameId != null) result.lastFrameId = lastFrameId;
    return result;
  }

  Heartbeat._();

  factory Heartbeat.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Heartbeat()..mergeFromBuffer(data, registry);
  factory Heartbeat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Heartbeat()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Heartbeat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: Heartbeat.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'lastFrameId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Heartbeat clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Heartbeat copyWith(void Function(Heartbeat) updates) =>
      super.copyWith((message) => updates(message as Heartbeat)) as Heartbeat;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Heartbeat() / Heartbeat.new instead')
  static Heartbeat create() => Heartbeat._();
  static $pb.GeneratedMessage $_createMessage() => Heartbeat._();
  @$core.override
  Heartbeat createEmptyInstance() => Heartbeat._();
  @$core.pragma('dart2js:noInline')
  static Heartbeat getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Heartbeat>(Heartbeat.$_createMessage);
  static Heartbeat? _defaultInstance;

  /// 携带上行流水水位, 便于服务端检测客户端丢包/假活
  @$pb.TagNumber(1)
  $fixnum.Int64 get lastFrameId => $_getI64(0);
  @$pb.TagNumber(1)
  set lastFrameId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLastFrameId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastFrameId() => $_clearField(1);
}

class Kick extends $pb.GeneratedMessage {
  factory Kick({
    $core.String? reason,
    $fixnum.Int64? userSyncSeq,
  }) {
    final result = Kick._();
    if (reason != null) result.reason = reason;
    if (userSyncSeq != null) result.userSyncSeq = userSyncSeq;
    return result;
  }

  Kick._();

  factory Kick.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Kick()..mergeFromBuffer(data, registry);
  factory Kick.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Kick()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Kick',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: Kick.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'reason')
    ..aInt64(2, _omitFieldNames ? '' : 'userSyncSeq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Kick clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Kick copyWith(void Function(Kick) updates) =>
      super.copyWith((message) => updates(message as Kick)) as Kick;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Kick() / Kick.new instead')
  static Kick create() => Kick._();
  static $pb.GeneratedMessage $_createMessage() => Kick._();
  @$core.override
  Kick createEmptyInstance() => Kick._();
  @$core.pragma('dart2js:noInline')
  static Kick getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Kick>(Kick.$_createMessage);
  static Kick? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reason => $_getSZ(0);
  @$pb.TagNumber(1)
  set reason($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReason() => $_has(0);
  @$pb.TagNumber(1)
  void clearReason() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userSyncSeq => $_getI64(1);
  @$pb.TagNumber(2)
  set userSyncSeq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserSyncSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserSyncSeq() => $_clearField(2);
}

class Disconnect extends $pb.GeneratedMessage {
  factory Disconnect({
    $core.String? reason,
    $core.int? retryAfterMs,
  }) {
    final result = Disconnect._();
    if (reason != null) result.reason = reason;
    if (retryAfterMs != null) result.retryAfterMs = retryAfterMs;
    return result;
  }

  Disconnect._();

  factory Disconnect.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Disconnect()..mergeFromBuffer(data, registry);
  factory Disconnect.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Disconnect()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Disconnect',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: Disconnect.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'reason')
    ..aI(2, _omitFieldNames ? '' : 'retryAfterMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Disconnect clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Disconnect copyWith(void Function(Disconnect) updates) =>
      super.copyWith((message) => updates(message as Disconnect)) as Disconnect;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Disconnect() / Disconnect.new instead')
  static Disconnect create() => Disconnect._();
  static $pb.GeneratedMessage $_createMessage() => Disconnect._();
  @$core.override
  Disconnect createEmptyInstance() => Disconnect._();
  @$core.pragma('dart2js:noInline')
  static Disconnect getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Disconnect>(Disconnect.$_createMessage);
  static Disconnect? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reason => $_getSZ(0);
  @$pb.TagNumber(1)
  set reason($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReason() => $_has(0);
  @$pb.TagNumber(1)
  void clearReason() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get retryAfterMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set retryAfterMs($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRetryAfterMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearRetryAfterMs() => $_clearField(2);
}

class MessageUpReq extends $pb.GeneratedMessage {
  factory MessageUpReq({
    $fixnum.Int64? clientMsgId,
    $fixnum.Int64? convId,
    $1.ConvMsgContent? content,
  }) {
    final result = MessageUpReq._();
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (convId != null) result.convId = convId;
    if (content != null) result.content = content;
    return result;
  }

  MessageUpReq._();

  factory MessageUpReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageUpReq()..mergeFromBuffer(data, registry);
  factory MessageUpReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageUpReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageUpReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: MessageUpReq.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'clientMsgId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(2, _omitFieldNames ? '' : 'convId')
    ..aOM<$1.ConvMsgContent>(3, _omitFieldNames ? '' : 'content',
        subBuilder: $1.ConvMsgContent.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageUpReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageUpReq copyWith(void Function(MessageUpReq) updates) =>
      super.copyWith((message) => updates(message as MessageUpReq))
          as MessageUpReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MessageUpReq() / MessageUpReq.new instead')
  static MessageUpReq create() => MessageUpReq._();
  static $pb.GeneratedMessage $_createMessage() => MessageUpReq._();
  @$core.override
  MessageUpReq createEmptyInstance() => MessageUpReq._();
  @$core.pragma('dart2js:noInline')
  static MessageUpReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageUpReq>(
          MessageUpReq.$_createMessage);
  static MessageUpReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get clientMsgId => $_getI64(0);
  @$pb.TagNumber(1)
  set clientMsgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get convId => $_getI64(1);
  @$pb.TagNumber(2)
  set convId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConvId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConvId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.ConvMsgContent get content => $_getN(2);
  @$pb.TagNumber(3)
  set content($1.ConvMsgContent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.ConvMsgContent ensureContent() => $_ensure(2);
}

class MessageUpRsp extends $pb.GeneratedMessage {
  factory MessageUpRsp({
    $fixnum.Int64? clientMsgId,
    $fixnum.Int64? msgId,
    $fixnum.Int64? seq,
    $fixnum.Int64? serverTimeMs,
  }) {
    final result = MessageUpRsp._();
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (msgId != null) result.msgId = msgId;
    if (seq != null) result.seq = seq;
    if (serverTimeMs != null) result.serverTimeMs = serverTimeMs;
    return result;
  }

  MessageUpRsp._();

  factory MessageUpRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageUpRsp()..mergeFromBuffer(data, registry);
  factory MessageUpRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageUpRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageUpRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: MessageUpRsp.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'clientMsgId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(2, _omitFieldNames ? '' : 'msgId')
    ..aInt64(3, _omitFieldNames ? '' : 'seq')
    ..aInt64(4, _omitFieldNames ? '' : 'serverTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageUpRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageUpRsp copyWith(void Function(MessageUpRsp) updates) =>
      super.copyWith((message) => updates(message as MessageUpRsp))
          as MessageUpRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MessageUpRsp() / MessageUpRsp.new instead')
  static MessageUpRsp create() => MessageUpRsp._();
  static $pb.GeneratedMessage $_createMessage() => MessageUpRsp._();
  @$core.override
  MessageUpRsp createEmptyInstance() => MessageUpRsp._();
  @$core.pragma('dart2js:noInline')
  static MessageUpRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageUpRsp>(
          MessageUpRsp.$_createMessage);
  static MessageUpRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get clientMsgId => $_getI64(0);
  @$pb.TagNumber(1)
  set clientMsgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get msgId => $_getI64(1);
  @$pb.TagNumber(2)
  set msgId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get seq => $_getI64(2);
  @$pb.TagNumber(3)
  set seq($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeq() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeq() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get serverTimeMs => $_getI64(3);
  @$pb.TagNumber(4)
  set serverTimeMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasServerTimeMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearServerTimeMs() => $_clearField(4);
}

/// 轻通知: 不含消息体。客户端发现本地 seq < max_seq 时发 SYNC 拉取。
/// 设计依据: 推送可丢可重, 丢失由 SYNC 补齐 —— 推保证实时, 拉保证可靠。
class MessagePush extends $pb.GeneratedMessage {
  factory MessagePush({
    $fixnum.Int64? convId,
    $fixnum.Int64? maxSeq,
    $fixnum.Int64? fromUid,
    $fixnum.Int64? userSyncSeq,
  }) {
    final result = MessagePush._();
    if (convId != null) result.convId = convId;
    if (maxSeq != null) result.maxSeq = maxSeq;
    if (fromUid != null) result.fromUid = fromUid;
    if (userSyncSeq != null) result.userSyncSeq = userSyncSeq;
    return result;
  }

  MessagePush._();

  factory MessagePush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessagePush()..mergeFromBuffer(data, registry);
  factory MessagePush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessagePush()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessagePush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: MessagePush.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'convId')
    ..aInt64(2, _omitFieldNames ? '' : 'maxSeq')
    ..aInt64(3, _omitFieldNames ? '' : 'fromUid')
    ..aInt64(4, _omitFieldNames ? '' : 'userSyncSeq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessagePush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessagePush copyWith(void Function(MessagePush) updates) =>
      super.copyWith((message) => updates(message as MessagePush))
          as MessagePush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MessagePush() / MessagePush.new instead')
  static MessagePush create() => MessagePush._();
  static $pb.GeneratedMessage $_createMessage() => MessagePush._();
  @$core.override
  MessagePush createEmptyInstance() => MessagePush._();
  @$core.pragma('dart2js:noInline')
  static MessagePush getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessagePush>(
          MessagePush.$_createMessage);
  static MessagePush? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get convId => $_getI64(0);
  @$pb.TagNumber(1)
  set convId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConvId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConvId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get maxSeq => $_getI64(1);
  @$pb.TagNumber(2)
  set maxSeq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxSeq() => $_clearField(2);

  /// 群聊时发送者 uid, 用于客户端决定是否拉取(可按免打扰跳过)
  @$pb.TagNumber(3)
  $fixnum.Int64 get fromUid => $_getI64(2);
  @$pb.TagNumber(3)
  set fromUid($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromUid() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get userSyncSeq => $_getI64(3);
  @$pb.TagNumber(4)
  set userSyncSeq($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUserSyncSeq() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserSyncSeq() => $_clearField(4);
}

class Ack extends $pb.GeneratedMessage {
  factory Ack({
    $fixnum.Int64? convId,
    $fixnum.Int64? ackSeq,
    $fixnum.Int64? clientMsgId,
    AckTarget? target,
  }) {
    final result = Ack._();
    if (convId != null) result.convId = convId;
    if (ackSeq != null) result.ackSeq = ackSeq;
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (target != null) result.target = target;
    return result;
  }

  Ack._();

  factory Ack.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ack()..mergeFromBuffer(data, registry);
  factory Ack.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ack()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ack',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: Ack.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'convId')
    ..aInt64(2, _omitFieldNames ? '' : 'ackSeq')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'clientMsgId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aE<AckTarget>(4, _omitFieldNames ? '' : 'target',
        enumValues: AckTarget.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ack clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ack copyWith(void Function(Ack) updates) =>
      super.copyWith((message) => updates(message as Ack)) as Ack;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Ack() / Ack.new instead')
  static Ack create() => Ack._();
  static $pb.GeneratedMessage $_createMessage() => Ack._();
  @$core.override
  Ack createEmptyInstance() => Ack._();
  @$core.pragma('dart2js:noInline')
  static Ack getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Ack>(Ack.$_createMessage);
  static Ack? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get convId => $_getI64(0);
  @$pb.TagNumber(1)
  set convId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConvId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConvId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get ackSeq => $_getI64(1);
  @$pb.TagNumber(2)
  set ackSeq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAckSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearAckSeq() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get clientMsgId => $_getI64(2);
  @$pb.TagNumber(3)
  set clientMsgId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClientMsgId() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientMsgId() => $_clearField(3);

  @$pb.TagNumber(4)
  AckTarget get target => $_getN(3);
  @$pb.TagNumber(4)
  set target(AckTarget value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTarget() => $_has(3);
  @$pb.TagNumber(4)
  void clearTarget() => $_clearField(4);
}

class SyncReq extends $pb.GeneratedMessage {
  factory SyncReq({
    $fixnum.Int64? userSyncSeq,
    $core.Iterable<ConvWatermark>? watermarks,
  }) {
    final result = SyncReq._();
    if (userSyncSeq != null) result.userSyncSeq = userSyncSeq;
    if (watermarks != null) result.watermarks.addAll(watermarks);
    return result;
  }

  SyncReq._();

  factory SyncReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncReq()..mergeFromBuffer(data, registry);
  factory SyncReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SyncReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'userSyncSeq')
    ..pPM<ConvWatermark>(2, _omitFieldNames ? '' : 'watermarks',
        subBuilder: ConvWatermark.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncReq copyWith(void Function(SyncReq) updates) =>
      super.copyWith((message) => updates(message as SyncReq)) as SyncReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncReq() / SyncReq.new instead')
  static SyncReq create() => SyncReq._();
  static $pb.GeneratedMessage $_createMessage() => SyncReq._();
  @$core.override
  SyncReq createEmptyInstance() => SyncReq._();
  @$core.pragma('dart2js:noInline')
  static SyncReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncReq>(SyncReq.$_createMessage);
  static SyncReq? _defaultInstance;

  /// 用户级水位: ConnectRsp 下发的 user_sync_seq
  @$pb.TagNumber(1)
  $fixnum.Int64 get userSyncSeq => $_getI64(0);
  @$pb.TagNumber(1)
  set userSyncSeq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserSyncSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserSyncSeq() => $_clearField(1);

  /// 客户端已知的各会话水位, 服务端按差集算增量
  /// (只传有本地数据的会话, 新设备不传 = 全量同步)
  @$pb.TagNumber(2)
  $pb.PbList<ConvWatermark> get watermarks => $_getList(1);
}

class ConvWatermark extends $pb.GeneratedMessage {
  factory ConvWatermark({
    $fixnum.Int64? convId,
    $fixnum.Int64? lastSeq,
  }) {
    final result = ConvWatermark._();
    if (convId != null) result.convId = convId;
    if (lastSeq != null) result.lastSeq = lastSeq;
    return result;
  }

  ConvWatermark._();

  factory ConvWatermark.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvWatermark()..mergeFromBuffer(data, registry);
  factory ConvWatermark.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvWatermark()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConvWatermark',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ConvWatermark.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'convId')
    ..aInt64(2, _omitFieldNames ? '' : 'lastSeq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvWatermark clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvWatermark copyWith(void Function(ConvWatermark) updates) =>
      super.copyWith((message) => updates(message as ConvWatermark))
          as ConvWatermark;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConvWatermark() / ConvWatermark.new instead')
  static ConvWatermark create() => ConvWatermark._();
  static $pb.GeneratedMessage $_createMessage() => ConvWatermark._();
  @$core.override
  ConvWatermark createEmptyInstance() => ConvWatermark._();
  @$core.pragma('dart2js:noInline')
  static ConvWatermark getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConvWatermark>(
          ConvWatermark.$_createMessage);
  static ConvWatermark? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get convId => $_getI64(0);
  @$pb.TagNumber(1)
  set convId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConvId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConvId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastSeq => $_getI64(1);
  @$pb.TagNumber(2)
  set lastSeq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastSeq() => $_clearField(2);
}

class SyncRsp extends $pb.GeneratedMessage {
  factory SyncRsp({
    $fixnum.Int64? userSyncSeq,
    $core.Iterable<$1.ConvMessage>? messages,
    $core.Iterable<ConvWatermark>? overflow,
  }) {
    final result = SyncRsp._();
    if (userSyncSeq != null) result.userSyncSeq = userSyncSeq;
    if (messages != null) result.messages.addAll(messages);
    if (overflow != null) result.overflow.addAll(overflow);
    return result;
  }

  SyncRsp._();

  factory SyncRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncRsp()..mergeFromBuffer(data, registry);
  factory SyncRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SyncRsp.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'userSyncSeq')
    ..pPM<$1.ConvMessage>(2, _omitFieldNames ? '' : 'messages',
        subBuilder: $1.ConvMessage.$_createMessage)
    ..pPM<ConvWatermark>(3, _omitFieldNames ? '' : 'overflow',
        subBuilder: ConvWatermark.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncRsp copyWith(void Function(SyncRsp) updates) =>
      super.copyWith((message) => updates(message as SyncRsp)) as SyncRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncRsp() / SyncRsp.new instead')
  static SyncRsp create() => SyncRsp._();
  static $pb.GeneratedMessage $_createMessage() => SyncRsp._();
  @$core.override
  SyncRsp createEmptyInstance() => SyncRsp._();
  @$core.pragma('dart2js:noInline')
  static SyncRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncRsp>(SyncRsp.$_createMessage);
  static SyncRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userSyncSeq => $_getI64(0);
  @$pb.TagNumber(1)
  set userSyncSeq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserSyncSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserSyncSeq() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$1.ConvMessage> get messages => $_getList(1);

  /// 增量过大的会话只返回水位, 客户端走分页历史拉取
  @$pb.TagNumber(3)
  $pb.PbList<ConvWatermark> get overflow => $_getList(2);
}

/// S→C 业务事件通知: 客户端按 type 局部重拉对应列表 (事件不带业务全量数据)。
class EventFrame extends $pb.GeneratedMessage {
  factory EventFrame({
    $core.String? type,
    $fixnum.Int64? uid,
    $fixnum.Int64? convId,
    $core.bool? online,
    $fixnum.Int64? seq,
  }) {
    final result = EventFrame._();
    if (type != null) result.type = type;
    if (uid != null) result.uid = uid;
    if (convId != null) result.convId = convId;
    if (online != null) result.online = online;
    if (seq != null) result.seq = seq;
    return result;
  }

  EventFrame._();

  factory EventFrame.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EventFrame()..mergeFromBuffer(data, registry);
  factory EventFrame.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EventFrame()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EventFrame',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: EventFrame.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'uid')
    ..aInt64(3, _omitFieldNames ? '' : 'convId')
    ..aOB(4, _omitFieldNames ? '' : 'online')
    ..aInt64(5, _omitFieldNames ? '' : 'seq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventFrame clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventFrame copyWith(void Function(EventFrame) updates) =>
      super.copyWith((message) => updates(message as EventFrame)) as EventFrame;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EventFrame() / EventFrame.new instead')
  static EventFrame create() => EventFrame._();
  static $pb.GeneratedMessage $_createMessage() => EventFrame._();
  @$core.override
  EventFrame createEmptyInstance() => EventFrame._();
  @$core.pragma('dart2js:noInline')
  static EventFrame getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EventFrame>(EventFrame.$_createMessage);
  static EventFrame? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get uid => $_getI64(1);
  @$pb.TagNumber(2)
  set uid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearUid() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get convId => $_getI64(2);
  @$pb.TagNumber(3)
  set convId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConvId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConvId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get online => $_getBF(3);
  @$pb.TagNumber(4)
  set online($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOnline() => $_has(3);
  @$pb.TagNumber(4)
  void clearOnline() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get seq => $_getI64(4);
  @$pb.TagNumber(5)
  set seq($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSeq() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeq() => $_clearField(5);
}

/// 输入中 (里程碑12): C→S 只带会话, from_uid 以连接身份为准; 服务端经
/// Redis ephemeral 通道扇出给会话其他成员, 即发即弃不落库。
class Typing extends $pb.GeneratedMessage {
  factory Typing({
    $fixnum.Int64? convId,
  }) {
    final result = Typing._();
    if (convId != null) result.convId = convId;
    return result;
  }

  Typing._();

  factory Typing.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Typing()..mergeFromBuffer(data, registry);
  factory Typing.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Typing()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Typing',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: Typing.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'convId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Typing clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Typing copyWith(void Function(Typing) updates) =>
      super.copyWith((message) => updates(message as Typing)) as Typing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Typing() / Typing.new instead')
  static Typing create() => Typing._();
  static $pb.GeneratedMessage $_createMessage() => Typing._();
  @$core.override
  Typing createEmptyInstance() => Typing._();
  @$core.pragma('dart2js:noInline')
  static Typing getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Typing>(Typing.$_createMessage);
  static Typing? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get convId => $_getI64(0);
  @$pb.TagNumber(1)
  set convId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConvId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConvId() => $_clearField(1);
}

/// Kafka yim.relation.event 事件体。
///   关系域事件: relation svc 直发 (targets = 应通知的用户)
///   在线事件:   comet 发原始 PRESENCE (targets 空) → relation 补齐好友列表再发回本 topic
/// comet 每实例全量消费本 topic, 按 targets 过滤本地在线连接推送 (事件量级低, 无需分区路由)。
class RelationEvent extends $pb.GeneratedMessage {
  factory RelationEvent({
    EventFrame? event,
    $core.Iterable<$fixnum.Int64>? targets,
  }) {
    final result = RelationEvent._();
    if (event != null) result.event = event;
    if (targets != null) result.targets.addAll(targets);
    return result;
  }

  RelationEvent._();

  factory RelationEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RelationEvent()..mergeFromBuffer(data, registry);
  factory RelationEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RelationEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RelationEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: RelationEvent.$_createMessage)
    ..aOM<EventFrame>(1, _omitFieldNames ? '' : 'event',
        subBuilder: EventFrame.$_createMessage)
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'targets', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationEvent copyWith(void Function(RelationEvent) updates) =>
      super.copyWith((message) => updates(message as RelationEvent))
          as RelationEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RelationEvent() / RelationEvent.new instead')
  static RelationEvent create() => RelationEvent._();
  static $pb.GeneratedMessage $_createMessage() => RelationEvent._();
  @$core.override
  RelationEvent createEmptyInstance() => RelationEvent._();
  @$core.pragma('dart2js:noInline')
  static RelationEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RelationEvent>(
          RelationEvent.$_createMessage);
  static RelationEvent? _defaultInstance;

  @$pb.TagNumber(1)
  EventFrame get event => $_getN(0);
  @$pb.TagNumber(1)
  set event(EventFrame value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => $_clearField(1);
  @$pb.TagNumber(1)
  EventFrame ensureEvent() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get targets => $_getList(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');

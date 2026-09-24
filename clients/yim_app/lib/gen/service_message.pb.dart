// This is a generated file - do not edit.
//
// Generated from service_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'message.pb.dart' as $0;
import 'protocol.pb.dart' as $2;
import 'service_message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'service_message.pbenum.dart';

class SendMessageReq extends $pb.GeneratedMessage {
  factory SendMessageReq({
    $fixnum.Int64? clientMsgId,
    $fixnum.Int64? convId,
    $fixnum.Int64? fromUid,
    $0.ConvMsgContent? content,
  }) {
    final result = SendMessageReq._();
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (convId != null) result.convId = convId;
    if (fromUid != null) result.fromUid = fromUid;
    if (content != null) result.content = content;
    return result;
  }

  SendMessageReq._();

  factory SendMessageReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendMessageReq()..mergeFromBuffer(data, registry);
  factory SendMessageReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendMessageReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SendMessageReq.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'clientMsgId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(2, _omitFieldNames ? '' : 'convId')
    ..aInt64(3, _omitFieldNames ? '' : 'fromUid')
    ..aOM<$0.ConvMsgContent>(4, _omitFieldNames ? '' : 'content',
        subBuilder: $0.ConvMsgContent.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageReq copyWith(void Function(SendMessageReq) updates) =>
      super.copyWith((message) => updates(message as SendMessageReq))
          as SendMessageReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendMessageReq() / SendMessageReq.new instead')
  static SendMessageReq create() => SendMessageReq._();
  static $pb.GeneratedMessage $_createMessage() => SendMessageReq._();
  @$core.override
  SendMessageReq createEmptyInstance() => SendMessageReq._();
  @$core.pragma('dart2js:noInline')
  static SendMessageReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendMessageReq>(
          SendMessageReq.$_createMessage);
  static SendMessageReq? _defaultInstance;

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
  $fixnum.Int64 get fromUid => $_getI64(2);
  @$pb.TagNumber(3)
  set fromUid($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromUid() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.ConvMsgContent get content => $_getN(3);
  @$pb.TagNumber(4)
  set content($0.ConvMsgContent value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.ConvMsgContent ensureContent() => $_ensure(3);
}

class SendMessageRsp extends $pb.GeneratedMessage {
  factory SendMessageRsp({
    $fixnum.Int64? msgId,
    $fixnum.Int64? seq,
    $fixnum.Int64? serverTimeMs,
    $1.Error? error,
  }) {
    final result = SendMessageRsp._();
    if (msgId != null) result.msgId = msgId;
    if (seq != null) result.seq = seq;
    if (serverTimeMs != null) result.serverTimeMs = serverTimeMs;
    if (error != null) result.error = error;
    return result;
  }

  SendMessageRsp._();

  factory SendMessageRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendMessageRsp()..mergeFromBuffer(data, registry);
  factory SendMessageRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendMessageRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SendMessageRsp.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'msgId')
    ..aInt64(2, _omitFieldNames ? '' : 'seq')
    ..aInt64(3, _omitFieldNames ? '' : 'serverTimeMs')
    ..aOM<$1.Error>(4, _omitFieldNames ? '' : 'error',
        subBuilder: $1.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageRsp copyWith(void Function(SendMessageRsp) updates) =>
      super.copyWith((message) => updates(message as SendMessageRsp))
          as SendMessageRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendMessageRsp() / SendMessageRsp.new instead')
  static SendMessageRsp create() => SendMessageRsp._();
  static $pb.GeneratedMessage $_createMessage() => SendMessageRsp._();
  @$core.override
  SendMessageRsp createEmptyInstance() => SendMessageRsp._();
  @$core.pragma('dart2js:noInline')
  static SendMessageRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendMessageRsp>(
          SendMessageRsp.$_createMessage);
  static SendMessageRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get msgId => $_getI64(0);
  @$pb.TagNumber(1)
  set msgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get seq => $_getI64(1);
  @$pb.TagNumber(2)
  set seq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeq() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get serverTimeMs => $_getI64(2);
  @$pb.TagNumber(3)
  set serverTimeMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasServerTimeMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearServerTimeMs() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Error get error => $_getN(3);
  @$pb.TagNumber(4)
  set error($1.Error value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Error ensureError() => $_ensure(3);
}

class PullHistoryReq extends $pb.GeneratedMessage {
  factory PullHistoryReq({
    $fixnum.Int64? convId,
    PullMode? mode,
    $fixnum.Int64? fromSeq,
    $fixnum.Int64? toSeq,
    $fixnum.Int64? beforeSeq,
    $core.int? limit,
    $fixnum.Int64? opUid,
  }) {
    final result = PullHistoryReq._();
    if (convId != null) result.convId = convId;
    if (mode != null) result.mode = mode;
    if (fromSeq != null) result.fromSeq = fromSeq;
    if (toSeq != null) result.toSeq = toSeq;
    if (beforeSeq != null) result.beforeSeq = beforeSeq;
    if (limit != null) result.limit = limit;
    if (opUid != null) result.opUid = opUid;
    return result;
  }

  PullHistoryReq._();

  factory PullHistoryReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PullHistoryReq()..mergeFromBuffer(data, registry);
  factory PullHistoryReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PullHistoryReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullHistoryReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: PullHistoryReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'convId')
    ..aE<PullMode>(2, _omitFieldNames ? '' : 'mode',
        enumValues: PullMode.values)
    ..aInt64(3, _omitFieldNames ? '' : 'fromSeq')
    ..aInt64(4, _omitFieldNames ? '' : 'toSeq')
    ..aInt64(5, _omitFieldNames ? '' : 'beforeSeq')
    ..aI(6, _omitFieldNames ? '' : 'limit')
    ..aInt64(7, _omitFieldNames ? '' : 'opUid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullHistoryReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullHistoryReq copyWith(void Function(PullHistoryReq) updates) =>
      super.copyWith((message) => updates(message as PullHistoryReq))
          as PullHistoryReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PullHistoryReq() / PullHistoryReq.new instead')
  static PullHistoryReq create() => PullHistoryReq._();
  static $pb.GeneratedMessage $_createMessage() => PullHistoryReq._();
  @$core.override
  PullHistoryReq createEmptyInstance() => PullHistoryReq._();
  @$core.pragma('dart2js:noInline')
  static PullHistoryReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PullHistoryReq>(
          PullHistoryReq.$_createMessage);
  static PullHistoryReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get convId => $_getI64(0);
  @$pb.TagNumber(1)
  set convId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConvId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConvId() => $_clearField(1);

  /// 二选一: 按 seq 精确拉段, 或倒序分页
  @$pb.TagNumber(2)
  PullMode get mode => $_getN(1);
  @$pb.TagNumber(2)
  set mode(PullMode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get fromSeq => $_getI64(2);
  @$pb.TagNumber(3)
  set fromSeq($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromSeq() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromSeq() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get toSeq => $_getI64(3);
  @$pb.TagNumber(4)
  set toSeq($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasToSeq() => $_has(3);
  @$pb.TagNumber(4)
  void clearToSeq() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get beforeSeq => $_getI64(4);
  @$pb.TagNumber(5)
  set beforeSeq($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBeforeSeq() => $_has(4);
  @$pb.TagNumber(5)
  void clearBeforeSeq() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get limit => $_getIZ(5);
  @$pb.TagNumber(6)
  set limit($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLimit() => $_has(5);
  @$pb.TagNumber(6)
  void clearLimit() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get opUid => $_getI64(6);
  @$pb.TagNumber(7)
  set opUid($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOpUid() => $_has(6);
  @$pb.TagNumber(7)
  void clearOpUid() => $_clearField(7);
}

class PullHistoryRsp extends $pb.GeneratedMessage {
  factory PullHistoryRsp({
    $core.Iterable<$0.ConvMessage>? messages,
    $core.bool? hasMore,
    $fixnum.Int64? minSeq,
    $1.Error? error,
  }) {
    final result = PullHistoryRsp._();
    if (messages != null) result.messages.addAll(messages);
    if (hasMore != null) result.hasMore = hasMore;
    if (minSeq != null) result.minSeq = minSeq;
    if (error != null) result.error = error;
    return result;
  }

  PullHistoryRsp._();

  factory PullHistoryRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PullHistoryRsp()..mergeFromBuffer(data, registry);
  factory PullHistoryRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PullHistoryRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullHistoryRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: PullHistoryRsp.$_createMessage)
    ..pPM<$0.ConvMessage>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: $0.ConvMessage.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'hasMore')
    ..aInt64(3, _omitFieldNames ? '' : 'minSeq')
    ..aOM<$1.Error>(4, _omitFieldNames ? '' : 'error',
        subBuilder: $1.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullHistoryRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullHistoryRsp copyWith(void Function(PullHistoryRsp) updates) =>
      super.copyWith((message) => updates(message as PullHistoryRsp))
          as PullHistoryRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PullHistoryRsp() / PullHistoryRsp.new instead')
  static PullHistoryRsp create() => PullHistoryRsp._();
  static $pb.GeneratedMessage $_createMessage() => PullHistoryRsp._();
  @$core.override
  PullHistoryRsp createEmptyInstance() => PullHistoryRsp._();
  @$core.pragma('dart2js:noInline')
  static PullHistoryRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PullHistoryRsp>(
          PullHistoryRsp.$_createMessage);
  static PullHistoryRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.ConvMessage> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(2)
  set hasMore($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasMore() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get minSeq => $_getI64(2);
  @$pb.TagNumber(3)
  set minSeq($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMinSeq() => $_has(2);
  @$pb.TagNumber(3)
  void clearMinSeq() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Error get error => $_getN(3);
  @$pb.TagNumber(4)
  set error($1.Error value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Error ensureError() => $_ensure(3);
}

/// SyncReq2/SyncRsp2: 与 protocol.proto 的 SYNC 指令 body 同构,
/// 但作为 gRPC 接口服务端可返回更多信息(overflow 等)
class SyncReq2 extends $pb.GeneratedMessage {
  factory SyncReq2({
    $fixnum.Int64? uid,
    $fixnum.Int64? userSyncSeq,
    $core.Iterable<$2.ConvWatermark>? watermarks,
  }) {
    final result = SyncReq2._();
    if (uid != null) result.uid = uid;
    if (userSyncSeq != null) result.userSyncSeq = userSyncSeq;
    if (watermarks != null) result.watermarks.addAll(watermarks);
    return result;
  }

  SyncReq2._();

  factory SyncReq2.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncReq2()..mergeFromBuffer(data, registry);
  factory SyncReq2.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncReq2()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncReq2',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SyncReq2.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aInt64(2, _omitFieldNames ? '' : 'userSyncSeq')
    ..pPM<$2.ConvWatermark>(3, _omitFieldNames ? '' : 'watermarks',
        subBuilder: $2.ConvWatermark.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncReq2 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncReq2 copyWith(void Function(SyncReq2) updates) =>
      super.copyWith((message) => updates(message as SyncReq2)) as SyncReq2;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncReq2() / SyncReq2.new instead')
  static SyncReq2 create() => SyncReq2._();
  static $pb.GeneratedMessage $_createMessage() => SyncReq2._();
  @$core.override
  SyncReq2 createEmptyInstance() => SyncReq2._();
  @$core.pragma('dart2js:noInline')
  static SyncReq2 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncReq2>(SyncReq2.$_createMessage);
  static SyncReq2? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userSyncSeq => $_getI64(1);
  @$pb.TagNumber(2)
  set userSyncSeq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserSyncSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserSyncSeq() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$2.ConvWatermark> get watermarks => $_getList(2);
}

class SyncRsp2 extends $pb.GeneratedMessage {
  factory SyncRsp2({
    $fixnum.Int64? userSyncSeq,
    $core.Iterable<$0.ConvMessage>? messages,
    $core.Iterable<$2.ConvWatermark>? overflow,
  }) {
    final result = SyncRsp2._();
    if (userSyncSeq != null) result.userSyncSeq = userSyncSeq;
    if (messages != null) result.messages.addAll(messages);
    if (overflow != null) result.overflow.addAll(overflow);
    return result;
  }

  SyncRsp2._();

  factory SyncRsp2.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncRsp2()..mergeFromBuffer(data, registry);
  factory SyncRsp2.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncRsp2()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncRsp2',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SyncRsp2.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'userSyncSeq')
    ..pPM<$0.ConvMessage>(2, _omitFieldNames ? '' : 'messages',
        subBuilder: $0.ConvMessage.$_createMessage)
    ..pPM<$2.ConvWatermark>(3, _omitFieldNames ? '' : 'overflow',
        subBuilder: $2.ConvWatermark.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncRsp2 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncRsp2 copyWith(void Function(SyncRsp2) updates) =>
      super.copyWith((message) => updates(message as SyncRsp2)) as SyncRsp2;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncRsp2() / SyncRsp2.new instead')
  static SyncRsp2 create() => SyncRsp2._();
  static $pb.GeneratedMessage $_createMessage() => SyncRsp2._();
  @$core.override
  SyncRsp2 createEmptyInstance() => SyncRsp2._();
  @$core.pragma('dart2js:noInline')
  static SyncRsp2 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncRsp2>(SyncRsp2.$_createMessage);
  static SyncRsp2? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userSyncSeq => $_getI64(0);
  @$pb.TagNumber(1)
  set userSyncSeq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserSyncSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserSyncSeq() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$0.ConvMessage> get messages => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$2.ConvWatermark> get overflow => $_getList(2);
}

class AckPushReq extends $pb.GeneratedMessage {
  factory AckPushReq({
    $fixnum.Int64? uid,
    $fixnum.Int64? convId,
    $fixnum.Int64? ackSeq,
  }) {
    final result = AckPushReq._();
    if (uid != null) result.uid = uid;
    if (convId != null) result.convId = convId;
    if (ackSeq != null) result.ackSeq = ackSeq;
    return result;
  }

  AckPushReq._();

  factory AckPushReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AckPushReq()..mergeFromBuffer(data, registry);
  factory AckPushReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AckPushReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AckPushReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: AckPushReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aInt64(2, _omitFieldNames ? '' : 'convId')
    ..aInt64(3, _omitFieldNames ? '' : 'ackSeq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AckPushReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AckPushReq copyWith(void Function(AckPushReq) updates) =>
      super.copyWith((message) => updates(message as AckPushReq)) as AckPushReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AckPushReq() / AckPushReq.new instead')
  static AckPushReq create() => AckPushReq._();
  static $pb.GeneratedMessage $_createMessage() => AckPushReq._();
  @$core.override
  AckPushReq createEmptyInstance() => AckPushReq._();
  @$core.pragma('dart2js:noInline')
  static AckPushReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AckPushReq>(AckPushReq.$_createMessage);
  static AckPushReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get convId => $_getI64(1);
  @$pb.TagNumber(2)
  set convId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConvId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConvId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get ackSeq => $_getI64(2);
  @$pb.TagNumber(3)
  set ackSeq($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAckSeq() => $_has(2);
  @$pb.TagNumber(3)
  void clearAckSeq() => $_clearField(3);
}

class AckPushRsp extends $pb.GeneratedMessage {
  factory AckPushRsp() => AckPushRsp._();

  AckPushRsp._();

  factory AckPushRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AckPushRsp()..mergeFromBuffer(data, registry);
  factory AckPushRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AckPushRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AckPushRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: AckPushRsp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AckPushRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AckPushRsp copyWith(void Function(AckPushRsp) updates) =>
      super.copyWith((message) => updates(message as AckPushRsp)) as AckPushRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AckPushRsp() / AckPushRsp.new instead')
  static AckPushRsp create() => AckPushRsp._();
  static $pb.GeneratedMessage $_createMessage() => AckPushRsp._();
  @$core.override
  AckPushRsp createEmptyInstance() => AckPushRsp._();
  @$core.pragma('dart2js:noInline')
  static AckPushRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AckPushRsp>(AckPushRsp.$_createMessage);
  static AckPushRsp? _defaultInstance;
}

class RevokeMessageReq extends $pb.GeneratedMessage {
  factory RevokeMessageReq({
    $fixnum.Int64? msgId,
    $fixnum.Int64? convId,
    $fixnum.Int64? opUid,
  }) {
    final result = RevokeMessageReq._();
    if (msgId != null) result.msgId = msgId;
    if (convId != null) result.convId = convId;
    if (opUid != null) result.opUid = opUid;
    return result;
  }

  RevokeMessageReq._();

  factory RevokeMessageReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeMessageReq()..mergeFromBuffer(data, registry);
  factory RevokeMessageReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeMessageReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeMessageReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: RevokeMessageReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'msgId')
    ..aInt64(2, _omitFieldNames ? '' : 'convId')
    ..aInt64(3, _omitFieldNames ? '' : 'opUid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeMessageReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeMessageReq copyWith(void Function(RevokeMessageReq) updates) =>
      super.copyWith((message) => updates(message as RevokeMessageReq))
          as RevokeMessageReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RevokeMessageReq() / RevokeMessageReq.new instead')
  static RevokeMessageReq create() => RevokeMessageReq._();
  static $pb.GeneratedMessage $_createMessage() => RevokeMessageReq._();
  @$core.override
  RevokeMessageReq createEmptyInstance() => RevokeMessageReq._();
  @$core.pragma('dart2js:noInline')
  static RevokeMessageReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeMessageReq>(
          RevokeMessageReq.$_createMessage);
  static RevokeMessageReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get msgId => $_getI64(0);
  @$pb.TagNumber(1)
  set msgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get convId => $_getI64(1);
  @$pb.TagNumber(2)
  set convId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConvId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConvId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get opUid => $_getI64(2);
  @$pb.TagNumber(3)
  set opUid($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOpUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearOpUid() => $_clearField(3);
}

class RevokeMessageRsp extends $pb.GeneratedMessage {
  factory RevokeMessageRsp({
    $fixnum.Int64? revokeMsgId,
    $fixnum.Int64? seq,
    $1.Error? error,
  }) {
    final result = RevokeMessageRsp._();
    if (revokeMsgId != null) result.revokeMsgId = revokeMsgId;
    if (seq != null) result.seq = seq;
    if (error != null) result.error = error;
    return result;
  }

  RevokeMessageRsp._();

  factory RevokeMessageRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeMessageRsp()..mergeFromBuffer(data, registry);
  factory RevokeMessageRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RevokeMessageRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeMessageRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: RevokeMessageRsp.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'revokeMsgId')
    ..aInt64(2, _omitFieldNames ? '' : 'seq')
    ..aOM<$1.Error>(3, _omitFieldNames ? '' : 'error',
        subBuilder: $1.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeMessageRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeMessageRsp copyWith(void Function(RevokeMessageRsp) updates) =>
      super.copyWith((message) => updates(message as RevokeMessageRsp))
          as RevokeMessageRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RevokeMessageRsp() / RevokeMessageRsp.new instead')
  static RevokeMessageRsp create() => RevokeMessageRsp._();
  static $pb.GeneratedMessage $_createMessage() => RevokeMessageRsp._();
  @$core.override
  RevokeMessageRsp createEmptyInstance() => RevokeMessageRsp._();
  @$core.pragma('dart2js:noInline')
  static RevokeMessageRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeMessageRsp>(
          RevokeMessageRsp.$_createMessage);
  static RevokeMessageRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get revokeMsgId => $_getI64(0);
  @$pb.TagNumber(1)
  set revokeMsgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevokeMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevokeMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get seq => $_getI64(1);
  @$pb.TagNumber(2)
  set seq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeq() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Error get error => $_getN(2);
  @$pb.TagNumber(3)
  set error($1.Error value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Error ensureError() => $_ensure(2);
}

class MarkReadReq extends $pb.GeneratedMessage {
  factory MarkReadReq({
    $fixnum.Int64? uid,
    $fixnum.Int64? convId,
    $fixnum.Int64? readSeq,
  }) {
    final result = MarkReadReq._();
    if (uid != null) result.uid = uid;
    if (convId != null) result.convId = convId;
    if (readSeq != null) result.readSeq = readSeq;
    return result;
  }

  MarkReadReq._();

  factory MarkReadReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarkReadReq()..mergeFromBuffer(data, registry);
  factory MarkReadReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarkReadReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkReadReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: MarkReadReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aInt64(2, _omitFieldNames ? '' : 'convId')
    ..aInt64(3, _omitFieldNames ? '' : 'readSeq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkReadReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkReadReq copyWith(void Function(MarkReadReq) updates) =>
      super.copyWith((message) => updates(message as MarkReadReq))
          as MarkReadReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarkReadReq() / MarkReadReq.new instead')
  static MarkReadReq create() => MarkReadReq._();
  static $pb.GeneratedMessage $_createMessage() => MarkReadReq._();
  @$core.override
  MarkReadReq createEmptyInstance() => MarkReadReq._();
  @$core.pragma('dart2js:noInline')
  static MarkReadReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarkReadReq>(
          MarkReadReq.$_createMessage);
  static MarkReadReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get convId => $_getI64(1);
  @$pb.TagNumber(2)
  set convId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConvId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConvId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get readSeq => $_getI64(2);
  @$pb.TagNumber(3)
  set readSeq($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReadSeq() => $_has(2);
  @$pb.TagNumber(3)
  void clearReadSeq() => $_clearField(3);
}

class MarkReadRsp extends $pb.GeneratedMessage {
  factory MarkReadRsp() => MarkReadRsp._();

  MarkReadRsp._();

  factory MarkReadRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarkReadRsp()..mergeFromBuffer(data, registry);
  factory MarkReadRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MarkReadRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkReadRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: MarkReadRsp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkReadRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkReadRsp copyWith(void Function(MarkReadRsp) updates) =>
      super.copyWith((message) => updates(message as MarkReadRsp))
          as MarkReadRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MarkReadRsp() / MarkReadRsp.new instead')
  static MarkReadRsp create() => MarkReadRsp._();
  static $pb.GeneratedMessage $_createMessage() => MarkReadRsp._();
  @$core.override
  MarkReadRsp createEmptyInstance() => MarkReadRsp._();
  @$core.pragma('dart2js:noInline')
  static MarkReadRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MarkReadRsp>(
          MarkReadRsp.$_createMessage);
  static MarkReadRsp? _defaultInstance;
}

class ListConversationsReq extends $pb.GeneratedMessage {
  factory ListConversationsReq({
    $fixnum.Int64? uid,
    $1.PageInfo? page,
  }) {
    final result = ListConversationsReq._();
    if (uid != null) result.uid = uid;
    if (page != null) result.page = page;
    return result;
  }

  ListConversationsReq._();

  factory ListConversationsReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListConversationsReq()..mergeFromBuffer(data, registry);
  factory ListConversationsReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListConversationsReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConversationsReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ListConversationsReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aOM<$1.PageInfo>(2, _omitFieldNames ? '' : 'page',
        subBuilder: $1.PageInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConversationsReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConversationsReq copyWith(void Function(ListConversationsReq) updates) =>
      super.copyWith((message) => updates(message as ListConversationsReq))
          as ListConversationsReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListConversationsReq() / ListConversationsReq.new instead')
  static ListConversationsReq create() => ListConversationsReq._();
  static $pb.GeneratedMessage $_createMessage() => ListConversationsReq._();
  @$core.override
  ListConversationsReq createEmptyInstance() => ListConversationsReq._();
  @$core.pragma('dart2js:noInline')
  static ListConversationsReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConversationsReq>(
          ListConversationsReq.$_createMessage);
  static ListConversationsReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.PageInfo get page => $_getN(1);
  @$pb.TagNumber(2)
  set page($1.PageInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.PageInfo ensurePage() => $_ensure(1);
}

class ConversationBrief extends $pb.GeneratedMessage {
  factory ConversationBrief({
    $0.Conv? conv,
    $fixnum.Int64? unreadCount,
    $0.ConvMessage? lastMessage,
  }) {
    final result = ConversationBrief._();
    if (conv != null) result.conv = conv;
    if (unreadCount != null) result.unreadCount = unreadCount;
    if (lastMessage != null) result.lastMessage = lastMessage;
    return result;
  }

  ConversationBrief._();

  factory ConversationBrief.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConversationBrief()..mergeFromBuffer(data, registry);
  factory ConversationBrief.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConversationBrief()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConversationBrief',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ConversationBrief.$_createMessage)
    ..aOM<$0.Conv>(1, _omitFieldNames ? '' : 'conv',
        subBuilder: $0.Conv.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'unreadCount')
    ..aOM<$0.ConvMessage>(3, _omitFieldNames ? '' : 'lastMessage',
        subBuilder: $0.ConvMessage.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationBrief clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConversationBrief copyWith(void Function(ConversationBrief) updates) =>
      super.copyWith((message) => updates(message as ConversationBrief))
          as ConversationBrief;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConversationBrief() / ConversationBrief.new instead')
  static ConversationBrief create() => ConversationBrief._();
  static $pb.GeneratedMessage $_createMessage() => ConversationBrief._();
  @$core.override
  ConversationBrief createEmptyInstance() => ConversationBrief._();
  @$core.pragma('dart2js:noInline')
  static ConversationBrief getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConversationBrief>(
          ConversationBrief.$_createMessage);
  static ConversationBrief? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Conv get conv => $_getN(0);
  @$pb.TagNumber(1)
  set conv($0.Conv value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConv() => $_has(0);
  @$pb.TagNumber(1)
  void clearConv() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Conv ensureConv() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get unreadCount => $_getI64(1);
  @$pb.TagNumber(2)
  set unreadCount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnreadCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnreadCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.ConvMessage get lastMessage => $_getN(2);
  @$pb.TagNumber(3)
  set lastMessage($0.ConvMessage value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLastMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastMessage() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.ConvMessage ensureLastMessage() => $_ensure(2);
}

class ListConversationsRsp extends $pb.GeneratedMessage {
  factory ListConversationsRsp({
    $core.Iterable<ConversationBrief>? conversations,
    $core.bool? hasMore,
  }) {
    final result = ListConversationsRsp._();
    if (conversations != null) result.conversations.addAll(conversations);
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  ListConversationsRsp._();

  factory ListConversationsRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListConversationsRsp()..mergeFromBuffer(data, registry);
  factory ListConversationsRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListConversationsRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConversationsRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ListConversationsRsp.$_createMessage)
    ..pPM<ConversationBrief>(1, _omitFieldNames ? '' : 'conversations',
        subBuilder: ConversationBrief.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConversationsRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConversationsRsp copyWith(void Function(ListConversationsRsp) updates) =>
      super.copyWith((message) => updates(message as ListConversationsRsp))
          as ListConversationsRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListConversationsRsp() / ListConversationsRsp.new instead')
  static ListConversationsRsp create() => ListConversationsRsp._();
  static $pb.GeneratedMessage $_createMessage() => ListConversationsRsp._();
  @$core.override
  ListConversationsRsp createEmptyInstance() => ListConversationsRsp._();
  @$core.pragma('dart2js:noInline')
  static ListConversationsRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConversationsRsp>(
          ListConversationsRsp.$_createMessage);
  static ListConversationsRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ConversationBrief> get conversations => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(2)
  set hasMore($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasMore() => $_clearField(2);
}

class CreateConvReq extends $pb.GeneratedMessage {
  factory CreateConvReq({
    $0.ConvType? type,
    $core.Iterable<$fixnum.Int64>? memberUids,
    $fixnum.Int64? ownerUid,
    $core.String? name,
  }) {
    final result = CreateConvReq._();
    if (type != null) result.type = type;
    if (memberUids != null) result.memberUids.addAll(memberUids);
    if (ownerUid != null) result.ownerUid = ownerUid;
    if (name != null) result.name = name;
    return result;
  }

  CreateConvReq._();

  factory CreateConvReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateConvReq()..mergeFromBuffer(data, registry);
  factory CreateConvReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateConvReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateConvReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: CreateConvReq.$_createMessage)
    ..aE<$0.ConvType>(1, _omitFieldNames ? '' : 'type',
        enumValues: $0.ConvType.values)
    ..p<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'memberUids', $pb.PbFieldType.K6)
    ..aInt64(3, _omitFieldNames ? '' : 'ownerUid')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateConvReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateConvReq copyWith(void Function(CreateConvReq) updates) =>
      super.copyWith((message) => updates(message as CreateConvReq))
          as CreateConvReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateConvReq() / CreateConvReq.new instead')
  static CreateConvReq create() => CreateConvReq._();
  static $pb.GeneratedMessage $_createMessage() => CreateConvReq._();
  @$core.override
  CreateConvReq createEmptyInstance() => CreateConvReq._();
  @$core.pragma('dart2js:noInline')
  static CreateConvReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateConvReq>(
          CreateConvReq.$_createMessage);
  static CreateConvReq? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ConvType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type($0.ConvType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get memberUids => $_getList(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get ownerUid => $_getI64(2);
  @$pb.TagNumber(3)
  set ownerUid($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOwnerUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearOwnerUid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);
}

class CreateConvRsp extends $pb.GeneratedMessage {
  factory CreateConvRsp({
    $0.Conv? conv,
    $core.bool? alreadyExist,
    $1.Error? error,
  }) {
    final result = CreateConvRsp._();
    if (conv != null) result.conv = conv;
    if (alreadyExist != null) result.alreadyExist = alreadyExist;
    if (error != null) result.error = error;
    return result;
  }

  CreateConvRsp._();

  factory CreateConvRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateConvRsp()..mergeFromBuffer(data, registry);
  factory CreateConvRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateConvRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateConvRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: CreateConvRsp.$_createMessage)
    ..aOM<$0.Conv>(1, _omitFieldNames ? '' : 'conv',
        subBuilder: $0.Conv.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'alreadyExist')
    ..aOM<$1.Error>(3, _omitFieldNames ? '' : 'error',
        subBuilder: $1.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateConvRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateConvRsp copyWith(void Function(CreateConvRsp) updates) =>
      super.copyWith((message) => updates(message as CreateConvRsp))
          as CreateConvRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateConvRsp() / CreateConvRsp.new instead')
  static CreateConvRsp create() => CreateConvRsp._();
  static $pb.GeneratedMessage $_createMessage() => CreateConvRsp._();
  @$core.override
  CreateConvRsp createEmptyInstance() => CreateConvRsp._();
  @$core.pragma('dart2js:noInline')
  static CreateConvRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateConvRsp>(
          CreateConvRsp.$_createMessage);
  static CreateConvRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Conv get conv => $_getN(0);
  @$pb.TagNumber(1)
  set conv($0.Conv value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConv() => $_has(0);
  @$pb.TagNumber(1)
  void clearConv() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Conv ensureConv() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get alreadyExist => $_getBF(1);
  @$pb.TagNumber(2)
  set alreadyExist($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlreadyExist() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlreadyExist() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Error get error => $_getN(2);
  @$pb.TagNumber(3)
  set error($1.Error value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Error ensureError() => $_ensure(2);
}

class SearchMessagesReq extends $pb.GeneratedMessage {
  factory SearchMessagesReq({
    $fixnum.Int64? uid,
    $core.String? keyword,
    $core.int? limit,
  }) {
    final result = SearchMessagesReq._();
    if (uid != null) result.uid = uid;
    if (keyword != null) result.keyword = keyword;
    if (limit != null) result.limit = limit;
    return result;
  }

  SearchMessagesReq._();

  factory SearchMessagesReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchMessagesReq()..mergeFromBuffer(data, registry);
  factory SearchMessagesReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchMessagesReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchMessagesReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SearchMessagesReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aOS(2, _omitFieldNames ? '' : 'keyword')
    ..aI(3, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesReq copyWith(void Function(SearchMessagesReq) updates) =>
      super.copyWith((message) => updates(message as SearchMessagesReq))
          as SearchMessagesReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SearchMessagesReq() / SearchMessagesReq.new instead')
  static SearchMessagesReq create() => SearchMessagesReq._();
  static $pb.GeneratedMessage $_createMessage() => SearchMessagesReq._();
  @$core.override
  SearchMessagesReq createEmptyInstance() => SearchMessagesReq._();
  @$core.pragma('dart2js:noInline')
  static SearchMessagesReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchMessagesReq>(
          SearchMessagesReq.$_createMessage);
  static SearchMessagesReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get keyword => $_getSZ(1);
  @$pb.TagNumber(2)
  set keyword($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKeyword() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeyword() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class SearchMessagesRsp extends $pb.GeneratedMessage {
  factory SearchMessagesRsp({
    $core.Iterable<$0.ConvMessage>? messages,
    $core.bool? truncated,
  }) {
    final result = SearchMessagesRsp._();
    if (messages != null) result.messages.addAll(messages);
    if (truncated != null) result.truncated = truncated;
    return result;
  }

  SearchMessagesRsp._();

  factory SearchMessagesRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchMessagesRsp()..mergeFromBuffer(data, registry);
  factory SearchMessagesRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchMessagesRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchMessagesRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SearchMessagesRsp.$_createMessage)
    ..pPM<$0.ConvMessage>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: $0.ConvMessage.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'truncated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesRsp copyWith(void Function(SearchMessagesRsp) updates) =>
      super.copyWith((message) => updates(message as SearchMessagesRsp))
          as SearchMessagesRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SearchMessagesRsp() / SearchMessagesRsp.new instead')
  static SearchMessagesRsp create() => SearchMessagesRsp._();
  static $pb.GeneratedMessage $_createMessage() => SearchMessagesRsp._();
  @$core.override
  SearchMessagesRsp createEmptyInstance() => SearchMessagesRsp._();
  @$core.pragma('dart2js:noInline')
  static SearchMessagesRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchMessagesRsp>(
          SearchMessagesRsp.$_createMessage);
  static SearchMessagesRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.ConvMessage> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get truncated => $_getBF(1);
  @$pb.TagNumber(2)
  set truncated($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTruncated() => $_has(1);
  @$pb.TagNumber(2)
  void clearTruncated() => $_clearField(2);
}

class MessageServiceApi {
  final $pb.RpcClient _client;

  MessageServiceApi(this._client);

  /// 上行消息 (Comet 转发客户端 CMD_MESSAGE_UP)
  $async.Future<SendMessageRsp> sendMessage(
          $pb.ClientContext? ctx, SendMessageReq request) =>
      _client.invoke<SendMessageRsp>(
          ctx, 'MessageService', 'SendMessage', request, SendMessageRsp());

  /// 会话内历史消息, 按 seq 区间/倒序分页
  /// 读路径: Redis ZSET(conv:{id}:recent) 未命中 → 从库
  $async.Future<PullHistoryRsp> pullHistory(
          $pb.ClientContext? ctx, PullHistoryReq request) =>
      _client.invoke<PullHistoryRsp>(
          ctx, 'MessageService', 'PullHistory', request, PullHistoryRsp());

  /// SYNC 增量同步 (Comet 转发 CMD_SYNC)
  /// 按 user_sync_seq 找变更会话集合 → 各会话按 watermark 差集拉增量
  $async.Future<SyncRsp2> sync($pb.ClientContext? ctx, SyncReq2 request) =>
      _client.invoke<SyncRsp2>(
          ctx, 'MessageService', 'Sync', request, SyncRsp2());

  /// 推送 ACK 回路: Comet 收到客户端 ACK_FOR_PUSH 后转发到这里,
  /// 取消该消息的投递重试定时 (时间轮), 并推进投递水位。
  $async.Future<AckPushRsp> ackPush(
          $pb.ClientContext? ctx, AckPushReq request) =>
      _client.invoke<AckPushRsp>(
          ctx, 'MessageService', 'AckPush', request, AckPushRsp());

  /// 撤回: 写一条 MSG_REVOKE 消息(复用投递链路), 校验时间窗口与权限
  $async.Future<RevokeMessageRsp> revokeMessage(
          $pb.ClientContext? ctx, RevokeMessageReq request) =>
      _client.invoke<RevokeMessageRsp>(
          ctx, 'MessageService', 'RevokeMessage', request, RevokeMessageRsp());

  /// 已读回执: 不产生消息, 只推进 conv_id 的 read_seq
  /// 未读数 = last_seq - max(read_seq, 同步水位), 对账任务兜底修正
  $async.Future<MarkReadRsp> markRead(
          $pb.ClientContext? ctx, MarkReadReq request) =>
      _client.invoke<MarkReadRsp>(
          ctx, 'MessageService', 'MarkRead', request, MarkReadRsp());

  /// 会话列表: conv 元数据 + last_seq + 未读数, 走缓存
  $async.Future<ListConversationsRsp> listConversations(
          $pb.ClientContext? ctx, ListConversationsReq request) =>
      _client.invoke<ListConversationsRsp>(ctx, 'MessageService',
          'ListConversations', request, ListConversationsRsp());

  /// 全文搜索 (里程碑13): 用户全部会话的 MSG_TEXT LIKE 扫描, 按时间倒序。
  /// 分库分表下不走 MySQL FULLTEXT (内容是 JSON 列), 逐分片 LIKE + 内存归并,
  /// 规模上去后演进 ES/倒排索引 —— 搜索是低频只读操作, DB 扫描可接受
  $async.Future<SearchMessagesRsp> searchMessages(
          $pb.ClientContext? ctx, SearchMessagesReq request) =>
      _client.invoke<SearchMessagesRsp>(ctx, 'MessageService', 'SearchMessages',
          request, SearchMessagesRsp());

  /// 建会话: 单聊 (去重) / 群聊。里程碑5 临时归属 Message Svc,
  /// 好友关系/群管理落地 Relation Svc 后迁移。
  $async.Future<CreateConvRsp> createConv(
          $pb.ClientContext? ctx, CreateConvReq request) =>
      _client.invoke<CreateConvRsp>(
          ctx, 'MessageService', 'CreateConv', request, CreateConvRsp());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');

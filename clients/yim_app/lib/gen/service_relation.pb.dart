// This is a generated file - do not edit.
//
// Generated from service_relation.proto.

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

import 'common.pb.dart' as $0;
import 'service_relation.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'service_relation.pbenum.dart';

class SendFriendRequestReq extends $pb.GeneratedMessage {
  factory SendFriendRequestReq({
    $fixnum.Int64? fromUid,
    $fixnum.Int64? toUid,
    $core.String? message,
  }) {
    final result = SendFriendRequestReq._();
    if (fromUid != null) result.fromUid = fromUid;
    if (toUid != null) result.toUid = toUid;
    if (message != null) result.message = message;
    return result;
  }

  SendFriendRequestReq._();

  factory SendFriendRequestReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendFriendRequestReq()..mergeFromBuffer(data, registry);
  factory SendFriendRequestReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendFriendRequestReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendFriendRequestReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SendFriendRequestReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'fromUid')
    ..aInt64(2, _omitFieldNames ? '' : 'toUid')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendFriendRequestReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendFriendRequestReq copyWith(void Function(SendFriendRequestReq) updates) =>
      super.copyWith((message) => updates(message as SendFriendRequestReq))
          as SendFriendRequestReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SendFriendRequestReq() / SendFriendRequestReq.new instead')
  static SendFriendRequestReq create() => SendFriendRequestReq._();
  static $pb.GeneratedMessage $_createMessage() => SendFriendRequestReq._();
  @$core.override
  SendFriendRequestReq createEmptyInstance() => SendFriendRequestReq._();
  @$core.pragma('dart2js:noInline')
  static SendFriendRequestReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendFriendRequestReq>(
          SendFriendRequestReq.$_createMessage);
  static SendFriendRequestReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get fromUid => $_getI64(0);
  @$pb.TagNumber(1)
  set fromUid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get toUid => $_getI64(1);
  @$pb.TagNumber(2)
  set toUid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearToUid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);
}

class SendFriendRequestRsp extends $pb.GeneratedMessage {
  factory SendFriendRequestRsp({
    $0.Error? error,
  }) {
    final result = SendFriendRequestRsp._();
    if (error != null) result.error = error;
    return result;
  }

  SendFriendRequestRsp._();

  factory SendFriendRequestRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendFriendRequestRsp()..mergeFromBuffer(data, registry);
  factory SendFriendRequestRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendFriendRequestRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendFriendRequestRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SendFriendRequestRsp.$_createMessage)
    ..aOM<$0.Error>(1, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendFriendRequestRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendFriendRequestRsp copyWith(void Function(SendFriendRequestRsp) updates) =>
      super.copyWith((message) => updates(message as SendFriendRequestRsp))
          as SendFriendRequestRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SendFriendRequestRsp() / SendFriendRequestRsp.new instead')
  static SendFriendRequestRsp create() => SendFriendRequestRsp._();
  static $pb.GeneratedMessage $_createMessage() => SendFriendRequestRsp._();
  @$core.override
  SendFriendRequestRsp createEmptyInstance() => SendFriendRequestRsp._();
  @$core.pragma('dart2js:noInline')
  static SendFriendRequestRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendFriendRequestRsp>(
          SendFriendRequestRsp.$_createMessage);
  static SendFriendRequestRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error($0.Error value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Error ensureError() => $_ensure(0);
}

class HandleFriendRequestReq extends $pb.GeneratedMessage {
  factory HandleFriendRequestReq({
    $fixnum.Int64? opUid,
    $fixnum.Int64? fromUid,
    $core.bool? accept,
  }) {
    final result = HandleFriendRequestReq._();
    if (opUid != null) result.opUid = opUid;
    if (fromUid != null) result.fromUid = fromUid;
    if (accept != null) result.accept = accept;
    return result;
  }

  HandleFriendRequestReq._();

  factory HandleFriendRequestReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HandleFriendRequestReq()..mergeFromBuffer(data, registry);
  factory HandleFriendRequestReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HandleFriendRequestReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HandleFriendRequestReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: HandleFriendRequestReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'opUid')
    ..aInt64(2, _omitFieldNames ? '' : 'fromUid')
    ..aOB(3, _omitFieldNames ? '' : 'accept')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HandleFriendRequestReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HandleFriendRequestReq copyWith(
          void Function(HandleFriendRequestReq) updates) =>
      super.copyWith((message) => updates(message as HandleFriendRequestReq))
          as HandleFriendRequestReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use HandleFriendRequestReq() / HandleFriendRequestReq.new instead')
  static HandleFriendRequestReq create() => HandleFriendRequestReq._();
  static $pb.GeneratedMessage $_createMessage() => HandleFriendRequestReq._();
  @$core.override
  HandleFriendRequestReq createEmptyInstance() => HandleFriendRequestReq._();
  @$core.pragma('dart2js:noInline')
  static HandleFriendRequestReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HandleFriendRequestReq>(
          HandleFriendRequestReq.$_createMessage);
  static HandleFriendRequestReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get opUid => $_getI64(0);
  @$pb.TagNumber(1)
  set opUid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOpUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearOpUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get fromUid => $_getI64(1);
  @$pb.TagNumber(2)
  set fromUid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromUid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get accept => $_getBF(2);
  @$pb.TagNumber(3)
  set accept($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccept() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccept() => $_clearField(3);
}

class HandleFriendRequestRsp extends $pb.GeneratedMessage {
  factory HandleFriendRequestRsp({
    $0.Error? error,
  }) {
    final result = HandleFriendRequestRsp._();
    if (error != null) result.error = error;
    return result;
  }

  HandleFriendRequestRsp._();

  factory HandleFriendRequestRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HandleFriendRequestRsp()..mergeFromBuffer(data, registry);
  factory HandleFriendRequestRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HandleFriendRequestRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HandleFriendRequestRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: HandleFriendRequestRsp.$_createMessage)
    ..aOM<$0.Error>(1, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HandleFriendRequestRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HandleFriendRequestRsp copyWith(
          void Function(HandleFriendRequestRsp) updates) =>
      super.copyWith((message) => updates(message as HandleFriendRequestRsp))
          as HandleFriendRequestRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use HandleFriendRequestRsp() / HandleFriendRequestRsp.new instead')
  static HandleFriendRequestRsp create() => HandleFriendRequestRsp._();
  static $pb.GeneratedMessage $_createMessage() => HandleFriendRequestRsp._();
  @$core.override
  HandleFriendRequestRsp createEmptyInstance() => HandleFriendRequestRsp._();
  @$core.pragma('dart2js:noInline')
  static HandleFriendRequestRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HandleFriendRequestRsp>(
          HandleFriendRequestRsp.$_createMessage);
  static HandleFriendRequestRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error($0.Error value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Error ensureError() => $_ensure(0);
}

class FriendRequest extends $pb.GeneratedMessage {
  factory FriendRequest({
    $fixnum.Int64? fromUid,
    $fixnum.Int64? toUid,
    $core.String? message,
    $core.int? status,
    $fixnum.Int64? createTimeMs,
  }) {
    final result = FriendRequest._();
    if (fromUid != null) result.fromUid = fromUid;
    if (toUid != null) result.toUid = toUid;
    if (message != null) result.message = message;
    if (status != null) result.status = status;
    if (createTimeMs != null) result.createTimeMs = createTimeMs;
    return result;
  }

  FriendRequest._();

  factory FriendRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FriendRequest()..mergeFromBuffer(data, registry);
  factory FriendRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FriendRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FriendRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: FriendRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'fromUid')
    ..aInt64(2, _omitFieldNames ? '' : 'toUid')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..aI(4, _omitFieldNames ? '' : 'status')
    ..aInt64(5, _omitFieldNames ? '' : 'createTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendRequest copyWith(void Function(FriendRequest) updates) =>
      super.copyWith((message) => updates(message as FriendRequest))
          as FriendRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FriendRequest() / FriendRequest.new instead')
  static FriendRequest create() => FriendRequest._();
  static $pb.GeneratedMessage $_createMessage() => FriendRequest._();
  @$core.override
  FriendRequest createEmptyInstance() => FriendRequest._();
  @$core.pragma('dart2js:noInline')
  static FriendRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendRequest>(
          FriendRequest.$_createMessage);
  static FriendRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get fromUid => $_getI64(0);
  @$pb.TagNumber(1)
  set fromUid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get toUid => $_getI64(1);
  @$pb.TagNumber(2)
  set toUid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearToUid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get status => $_getIZ(3);
  @$pb.TagNumber(4)
  set status($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createTimeMs => $_getI64(4);
  @$pb.TagNumber(5)
  set createTimeMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreateTimeMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreateTimeMs() => $_clearField(5);
}

class ListFriendRequestsReq extends $pb.GeneratedMessage {
  factory ListFriendRequestsReq({
    $fixnum.Int64? uid,
    $core.bool? incoming,
  }) {
    final result = ListFriendRequestsReq._();
    if (uid != null) result.uid = uid;
    if (incoming != null) result.incoming = incoming;
    return result;
  }

  ListFriendRequestsReq._();

  factory ListFriendRequestsReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFriendRequestsReq()..mergeFromBuffer(data, registry);
  factory ListFriendRequestsReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFriendRequestsReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFriendRequestsReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ListFriendRequestsReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aOB(2, _omitFieldNames ? '' : 'incoming')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFriendRequestsReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFriendRequestsReq copyWith(
          void Function(ListFriendRequestsReq) updates) =>
      super.copyWith((message) => updates(message as ListFriendRequestsReq))
          as ListFriendRequestsReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListFriendRequestsReq() / ListFriendRequestsReq.new instead')
  static ListFriendRequestsReq create() => ListFriendRequestsReq._();
  static $pb.GeneratedMessage $_createMessage() => ListFriendRequestsReq._();
  @$core.override
  ListFriendRequestsReq createEmptyInstance() => ListFriendRequestsReq._();
  @$core.pragma('dart2js:noInline')
  static ListFriendRequestsReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFriendRequestsReq>(
          ListFriendRequestsReq.$_createMessage);
  static ListFriendRequestsReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get incoming => $_getBF(1);
  @$pb.TagNumber(2)
  set incoming($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIncoming() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncoming() => $_clearField(2);
}

class ListFriendRequestsRsp extends $pb.GeneratedMessage {
  factory ListFriendRequestsRsp({
    $core.Iterable<FriendRequest>? requests,
    $0.Error? error,
  }) {
    final result = ListFriendRequestsRsp._();
    if (requests != null) result.requests.addAll(requests);
    if (error != null) result.error = error;
    return result;
  }

  ListFriendRequestsRsp._();

  factory ListFriendRequestsRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFriendRequestsRsp()..mergeFromBuffer(data, registry);
  factory ListFriendRequestsRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFriendRequestsRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFriendRequestsRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ListFriendRequestsRsp.$_createMessage)
    ..pPM<FriendRequest>(1, _omitFieldNames ? '' : 'requests',
        subBuilder: FriendRequest.$_createMessage)
    ..aOM<$0.Error>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFriendRequestsRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFriendRequestsRsp copyWith(
          void Function(ListFriendRequestsRsp) updates) =>
      super.copyWith((message) => updates(message as ListFriendRequestsRsp))
          as ListFriendRequestsRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListFriendRequestsRsp() / ListFriendRequestsRsp.new instead')
  static ListFriendRequestsRsp create() => ListFriendRequestsRsp._();
  static $pb.GeneratedMessage $_createMessage() => ListFriendRequestsRsp._();
  @$core.override
  ListFriendRequestsRsp createEmptyInstance() => ListFriendRequestsRsp._();
  @$core.pragma('dart2js:noInline')
  static ListFriendRequestsRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFriendRequestsRsp>(
          ListFriendRequestsRsp.$_createMessage);
  static ListFriendRequestsRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FriendRequest> get requests => $_getList(0);

  @$pb.TagNumber(2)
  $0.Error get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($0.Error value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Error ensureError() => $_ensure(1);
}

class FriendBrief extends $pb.GeneratedMessage {
  factory FriendBrief({
    $fixnum.Int64? uid,
    $core.String? nickname,
    $core.String? avatar,
    $fixnum.Int64? createTimeMs,
  }) {
    final result = FriendBrief._();
    if (uid != null) result.uid = uid;
    if (nickname != null) result.nickname = nickname;
    if (avatar != null) result.avatar = avatar;
    if (createTimeMs != null) result.createTimeMs = createTimeMs;
    return result;
  }

  FriendBrief._();

  factory FriendBrief.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FriendBrief()..mergeFromBuffer(data, registry);
  factory FriendBrief.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FriendBrief()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FriendBrief',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: FriendBrief.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..aInt64(4, _omitFieldNames ? '' : 'createTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendBrief clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendBrief copyWith(void Function(FriendBrief) updates) =>
      super.copyWith((message) => updates(message as FriendBrief))
          as FriendBrief;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FriendBrief() / FriendBrief.new instead')
  static FriendBrief create() => FriendBrief._();
  static $pb.GeneratedMessage $_createMessage() => FriendBrief._();
  @$core.override
  FriendBrief createEmptyInstance() => FriendBrief._();
  @$core.pragma('dart2js:noInline')
  static FriendBrief getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendBrief>(
          FriendBrief.$_createMessage);
  static FriendBrief? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get createTimeMs => $_getI64(3);
  @$pb.TagNumber(4)
  set createTimeMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreateTimeMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreateTimeMs() => $_clearField(4);
}

class ListFriendsReq extends $pb.GeneratedMessage {
  factory ListFriendsReq({
    $fixnum.Int64? uid,
    $0.PageInfo? page,
  }) {
    final result = ListFriendsReq._();
    if (uid != null) result.uid = uid;
    if (page != null) result.page = page;
    return result;
  }

  ListFriendsReq._();

  factory ListFriendsReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFriendsReq()..mergeFromBuffer(data, registry);
  factory ListFriendsReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFriendsReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFriendsReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ListFriendsReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aOM<$0.PageInfo>(2, _omitFieldNames ? '' : 'page',
        subBuilder: $0.PageInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFriendsReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFriendsReq copyWith(void Function(ListFriendsReq) updates) =>
      super.copyWith((message) => updates(message as ListFriendsReq))
          as ListFriendsReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListFriendsReq() / ListFriendsReq.new instead')
  static ListFriendsReq create() => ListFriendsReq._();
  static $pb.GeneratedMessage $_createMessage() => ListFriendsReq._();
  @$core.override
  ListFriendsReq createEmptyInstance() => ListFriendsReq._();
  @$core.pragma('dart2js:noInline')
  static ListFriendsReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListFriendsReq>(
          ListFriendsReq.$_createMessage);
  static ListFriendsReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.PageInfo get page => $_getN(1);
  @$pb.TagNumber(2)
  set page($0.PageInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.PageInfo ensurePage() => $_ensure(1);
}

class ListFriendsRsp extends $pb.GeneratedMessage {
  factory ListFriendsRsp({
    $core.Iterable<FriendBrief>? friends,
    $core.bool? hasMore,
    $0.Error? error,
  }) {
    final result = ListFriendsRsp._();
    if (friends != null) result.friends.addAll(friends);
    if (hasMore != null) result.hasMore = hasMore;
    if (error != null) result.error = error;
    return result;
  }

  ListFriendsRsp._();

  factory ListFriendsRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFriendsRsp()..mergeFromBuffer(data, registry);
  factory ListFriendsRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFriendsRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFriendsRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ListFriendsRsp.$_createMessage)
    ..pPM<FriendBrief>(1, _omitFieldNames ? '' : 'friends',
        subBuilder: FriendBrief.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'hasMore')
    ..aOM<$0.Error>(3, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFriendsRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFriendsRsp copyWith(void Function(ListFriendsRsp) updates) =>
      super.copyWith((message) => updates(message as ListFriendsRsp))
          as ListFriendsRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListFriendsRsp() / ListFriendsRsp.new instead')
  static ListFriendsRsp create() => ListFriendsRsp._();
  static $pb.GeneratedMessage $_createMessage() => ListFriendsRsp._();
  @$core.override
  ListFriendsRsp createEmptyInstance() => ListFriendsRsp._();
  @$core.pragma('dart2js:noInline')
  static ListFriendsRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListFriendsRsp>(
          ListFriendsRsp.$_createMessage);
  static ListFriendsRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FriendBrief> get friends => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(2)
  set hasMore($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasMore() => $_clearField(2);

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
}

class DeleteFriendReq extends $pb.GeneratedMessage {
  factory DeleteFriendReq({
    $fixnum.Int64? opUid,
    $fixnum.Int64? friendUid,
  }) {
    final result = DeleteFriendReq._();
    if (opUid != null) result.opUid = opUid;
    if (friendUid != null) result.friendUid = friendUid;
    return result;
  }

  DeleteFriendReq._();

  factory DeleteFriendReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFriendReq()..mergeFromBuffer(data, registry);
  factory DeleteFriendReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFriendReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFriendReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: DeleteFriendReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'opUid')
    ..aInt64(2, _omitFieldNames ? '' : 'friendUid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFriendReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFriendReq copyWith(void Function(DeleteFriendReq) updates) =>
      super.copyWith((message) => updates(message as DeleteFriendReq))
          as DeleteFriendReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteFriendReq() / DeleteFriendReq.new instead')
  static DeleteFriendReq create() => DeleteFriendReq._();
  static $pb.GeneratedMessage $_createMessage() => DeleteFriendReq._();
  @$core.override
  DeleteFriendReq createEmptyInstance() => DeleteFriendReq._();
  @$core.pragma('dart2js:noInline')
  static DeleteFriendReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFriendReq>(
          DeleteFriendReq.$_createMessage);
  static DeleteFriendReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get opUid => $_getI64(0);
  @$pb.TagNumber(1)
  set opUid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOpUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearOpUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get friendUid => $_getI64(1);
  @$pb.TagNumber(2)
  set friendUid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFriendUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearFriendUid() => $_clearField(2);
}

class DeleteFriendRsp extends $pb.GeneratedMessage {
  factory DeleteFriendRsp({
    $0.Error? error,
  }) {
    final result = DeleteFriendRsp._();
    if (error != null) result.error = error;
    return result;
  }

  DeleteFriendRsp._();

  factory DeleteFriendRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFriendRsp()..mergeFromBuffer(data, registry);
  factory DeleteFriendRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFriendRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFriendRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: DeleteFriendRsp.$_createMessage)
    ..aOM<$0.Error>(1, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFriendRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFriendRsp copyWith(void Function(DeleteFriendRsp) updates) =>
      super.copyWith((message) => updates(message as DeleteFriendRsp))
          as DeleteFriendRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteFriendRsp() / DeleteFriendRsp.new instead')
  static DeleteFriendRsp create() => DeleteFriendRsp._();
  static $pb.GeneratedMessage $_createMessage() => DeleteFriendRsp._();
  @$core.override
  DeleteFriendRsp createEmptyInstance() => DeleteFriendRsp._();
  @$core.pragma('dart2js:noInline')
  static DeleteFriendRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFriendRsp>(
          DeleteFriendRsp.$_createMessage);
  static DeleteFriendRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error($0.Error value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Error ensureError() => $_ensure(0);
}

class CheckFriendshipReq extends $pb.GeneratedMessage {
  factory CheckFriendshipReq({
    $fixnum.Int64? aUid,
    $fixnum.Int64? bUid,
  }) {
    final result = CheckFriendshipReq._();
    if (aUid != null) result.aUid = aUid;
    if (bUid != null) result.bUid = bUid;
    return result;
  }

  CheckFriendshipReq._();

  factory CheckFriendshipReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckFriendshipReq()..mergeFromBuffer(data, registry);
  factory CheckFriendshipReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckFriendshipReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckFriendshipReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: CheckFriendshipReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'aUid')
    ..aInt64(2, _omitFieldNames ? '' : 'bUid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckFriendshipReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckFriendshipReq copyWith(void Function(CheckFriendshipReq) updates) =>
      super.copyWith((message) => updates(message as CheckFriendshipReq))
          as CheckFriendshipReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckFriendshipReq() / CheckFriendshipReq.new instead')
  static CheckFriendshipReq create() => CheckFriendshipReq._();
  static $pb.GeneratedMessage $_createMessage() => CheckFriendshipReq._();
  @$core.override
  CheckFriendshipReq createEmptyInstance() => CheckFriendshipReq._();
  @$core.pragma('dart2js:noInline')
  static CheckFriendshipReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckFriendshipReq>(
          CheckFriendshipReq.$_createMessage);
  static CheckFriendshipReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get aUid => $_getI64(0);
  @$pb.TagNumber(1)
  set aUid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearAUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get bUid => $_getI64(1);
  @$pb.TagNumber(2)
  set bUid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearBUid() => $_clearField(2);
}

class CheckFriendshipRsp extends $pb.GeneratedMessage {
  factory CheckFriendshipRsp({
    $core.bool? isFriend,
  }) {
    final result = CheckFriendshipRsp._();
    if (isFriend != null) result.isFriend = isFriend;
    return result;
  }

  CheckFriendshipRsp._();

  factory CheckFriendshipRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckFriendshipRsp()..mergeFromBuffer(data, registry);
  factory CheckFriendshipRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CheckFriendshipRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckFriendshipRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: CheckFriendshipRsp.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'isFriend')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckFriendshipRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckFriendshipRsp copyWith(void Function(CheckFriendshipRsp) updates) =>
      super.copyWith((message) => updates(message as CheckFriendshipRsp))
          as CheckFriendshipRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CheckFriendshipRsp() / CheckFriendshipRsp.new instead')
  static CheckFriendshipRsp create() => CheckFriendshipRsp._();
  static $pb.GeneratedMessage $_createMessage() => CheckFriendshipRsp._();
  @$core.override
  CheckFriendshipRsp createEmptyInstance() => CheckFriendshipRsp._();
  @$core.pragma('dart2js:noInline')
  static CheckFriendshipRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckFriendshipRsp>(
          CheckFriendshipRsp.$_createMessage);
  static CheckFriendshipRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isFriend => $_getBF(0);
  @$pb.TagNumber(1)
  set isFriend($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsFriend() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsFriend() => $_clearField(1);
}

class AddGroupMembersReq extends $pb.GeneratedMessage {
  factory AddGroupMembersReq({
    $fixnum.Int64? convId,
    $core.Iterable<$fixnum.Int64>? memberUids,
    $fixnum.Int64? ownerUid,
  }) {
    final result = AddGroupMembersReq._();
    if (convId != null) result.convId = convId;
    if (memberUids != null) result.memberUids.addAll(memberUids);
    if (ownerUid != null) result.ownerUid = ownerUid;
    return result;
  }

  AddGroupMembersReq._();

  factory AddGroupMembersReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddGroupMembersReq()..mergeFromBuffer(data, registry);
  factory AddGroupMembersReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddGroupMembersReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGroupMembersReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: AddGroupMembersReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'convId')
    ..p<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'memberUids', $pb.PbFieldType.K6)
    ..aInt64(3, _omitFieldNames ? '' : 'ownerUid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersReq copyWith(void Function(AddGroupMembersReq) updates) =>
      super.copyWith((message) => updates(message as AddGroupMembersReq))
          as AddGroupMembersReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AddGroupMembersReq() / AddGroupMembersReq.new instead')
  static AddGroupMembersReq create() => AddGroupMembersReq._();
  static $pb.GeneratedMessage $_createMessage() => AddGroupMembersReq._();
  @$core.override
  AddGroupMembersReq createEmptyInstance() => AddGroupMembersReq._();
  @$core.pragma('dart2js:noInline')
  static AddGroupMembersReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGroupMembersReq>(
          AddGroupMembersReq.$_createMessage);
  static AddGroupMembersReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get convId => $_getI64(0);
  @$pb.TagNumber(1)
  set convId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConvId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConvId() => $_clearField(1);

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
}

class AddGroupMembersRsp extends $pb.GeneratedMessage {
  factory AddGroupMembersRsp({
    $0.Error? error,
  }) {
    final result = AddGroupMembersRsp._();
    if (error != null) result.error = error;
    return result;
  }

  AddGroupMembersRsp._();

  factory AddGroupMembersRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddGroupMembersRsp()..mergeFromBuffer(data, registry);
  factory AddGroupMembersRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddGroupMembersRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGroupMembersRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: AddGroupMembersRsp.$_createMessage)
    ..aOM<$0.Error>(1, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersRsp copyWith(void Function(AddGroupMembersRsp) updates) =>
      super.copyWith((message) => updates(message as AddGroupMembersRsp))
          as AddGroupMembersRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AddGroupMembersRsp() / AddGroupMembersRsp.new instead')
  static AddGroupMembersRsp create() => AddGroupMembersRsp._();
  static $pb.GeneratedMessage $_createMessage() => AddGroupMembersRsp._();
  @$core.override
  AddGroupMembersRsp createEmptyInstance() => AddGroupMembersRsp._();
  @$core.pragma('dart2js:noInline')
  static AddGroupMembersRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGroupMembersRsp>(
          AddGroupMembersRsp.$_createMessage);
  static AddGroupMembersRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error($0.Error value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Error ensureError() => $_ensure(0);
}

class RemoveGroupMemberReq extends $pb.GeneratedMessage {
  factory RemoveGroupMemberReq({
    $fixnum.Int64? opUid,
    $fixnum.Int64? convId,
    $fixnum.Int64? targetUid,
  }) {
    final result = RemoveGroupMemberReq._();
    if (opUid != null) result.opUid = opUid;
    if (convId != null) result.convId = convId;
    if (targetUid != null) result.targetUid = targetUid;
    return result;
  }

  RemoveGroupMemberReq._();

  factory RemoveGroupMemberReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveGroupMemberReq()..mergeFromBuffer(data, registry);
  factory RemoveGroupMemberReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveGroupMemberReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveGroupMemberReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: RemoveGroupMemberReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'opUid')
    ..aInt64(2, _omitFieldNames ? '' : 'convId')
    ..aInt64(3, _omitFieldNames ? '' : 'targetUid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberReq copyWith(void Function(RemoveGroupMemberReq) updates) =>
      super.copyWith((message) => updates(message as RemoveGroupMemberReq))
          as RemoveGroupMemberReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RemoveGroupMemberReq() / RemoveGroupMemberReq.new instead')
  static RemoveGroupMemberReq create() => RemoveGroupMemberReq._();
  static $pb.GeneratedMessage $_createMessage() => RemoveGroupMemberReq._();
  @$core.override
  RemoveGroupMemberReq createEmptyInstance() => RemoveGroupMemberReq._();
  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveGroupMemberReq>(
          RemoveGroupMemberReq.$_createMessage);
  static RemoveGroupMemberReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get opUid => $_getI64(0);
  @$pb.TagNumber(1)
  set opUid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOpUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearOpUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get convId => $_getI64(1);
  @$pb.TagNumber(2)
  set convId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConvId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConvId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get targetUid => $_getI64(2);
  @$pb.TagNumber(3)
  set targetUid($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetUid() => $_clearField(3);
}

class RemoveGroupMemberRsp extends $pb.GeneratedMessage {
  factory RemoveGroupMemberRsp({
    $0.Error? error,
  }) {
    final result = RemoveGroupMemberRsp._();
    if (error != null) result.error = error;
    return result;
  }

  RemoveGroupMemberRsp._();

  factory RemoveGroupMemberRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveGroupMemberRsp()..mergeFromBuffer(data, registry);
  factory RemoveGroupMemberRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveGroupMemberRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveGroupMemberRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: RemoveGroupMemberRsp.$_createMessage)
    ..aOM<$0.Error>(1, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberRsp copyWith(void Function(RemoveGroupMemberRsp) updates) =>
      super.copyWith((message) => updates(message as RemoveGroupMemberRsp))
          as RemoveGroupMemberRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RemoveGroupMemberRsp() / RemoveGroupMemberRsp.new instead')
  static RemoveGroupMemberRsp create() => RemoveGroupMemberRsp._();
  static $pb.GeneratedMessage $_createMessage() => RemoveGroupMemberRsp._();
  @$core.override
  RemoveGroupMemberRsp createEmptyInstance() => RemoveGroupMemberRsp._();
  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveGroupMemberRsp>(
          RemoveGroupMemberRsp.$_createMessage);
  static RemoveGroupMemberRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error($0.Error value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Error ensureError() => $_ensure(0);
}

class QuitGroupReq extends $pb.GeneratedMessage {
  factory QuitGroupReq({
    $fixnum.Int64? uid,
    $fixnum.Int64? convId,
  }) {
    final result = QuitGroupReq._();
    if (uid != null) result.uid = uid;
    if (convId != null) result.convId = convId;
    return result;
  }

  QuitGroupReq._();

  factory QuitGroupReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuitGroupReq()..mergeFromBuffer(data, registry);
  factory QuitGroupReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuitGroupReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuitGroupReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: QuitGroupReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aInt64(2, _omitFieldNames ? '' : 'convId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuitGroupReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuitGroupReq copyWith(void Function(QuitGroupReq) updates) =>
      super.copyWith((message) => updates(message as QuitGroupReq))
          as QuitGroupReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use QuitGroupReq() / QuitGroupReq.new instead')
  static QuitGroupReq create() => QuitGroupReq._();
  static $pb.GeneratedMessage $_createMessage() => QuitGroupReq._();
  @$core.override
  QuitGroupReq createEmptyInstance() => QuitGroupReq._();
  @$core.pragma('dart2js:noInline')
  static QuitGroupReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuitGroupReq>(
          QuitGroupReq.$_createMessage);
  static QuitGroupReq? _defaultInstance;

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
}

class QuitGroupRsp extends $pb.GeneratedMessage {
  factory QuitGroupRsp({
    $0.Error? error,
  }) {
    final result = QuitGroupRsp._();
    if (error != null) result.error = error;
    return result;
  }

  QuitGroupRsp._();

  factory QuitGroupRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuitGroupRsp()..mergeFromBuffer(data, registry);
  factory QuitGroupRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      QuitGroupRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuitGroupRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: QuitGroupRsp.$_createMessage)
    ..aOM<$0.Error>(1, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuitGroupRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuitGroupRsp copyWith(void Function(QuitGroupRsp) updates) =>
      super.copyWith((message) => updates(message as QuitGroupRsp))
          as QuitGroupRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use QuitGroupRsp() / QuitGroupRsp.new instead')
  static QuitGroupRsp create() => QuitGroupRsp._();
  static $pb.GeneratedMessage $_createMessage() => QuitGroupRsp._();
  @$core.override
  QuitGroupRsp createEmptyInstance() => QuitGroupRsp._();
  @$core.pragma('dart2js:noInline')
  static QuitGroupRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuitGroupRsp>(
          QuitGroupRsp.$_createMessage);
  static QuitGroupRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error($0.Error value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Error ensureError() => $_ensure(0);
}

class GroupMember extends $pb.GeneratedMessage {
  factory GroupMember({
    $fixnum.Int64? uid,
    $core.int? role,
    $core.String? nickname,
    $core.String? avatar,
    $fixnum.Int64? joinTimeMs,
  }) {
    final result = GroupMember._();
    if (uid != null) result.uid = uid;
    if (role != null) result.role = role;
    if (nickname != null) result.nickname = nickname;
    if (avatar != null) result.avatar = avatar;
    if (joinTimeMs != null) result.joinTimeMs = joinTimeMs;
    return result;
  }

  GroupMember._();

  factory GroupMember.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GroupMember()..mergeFromBuffer(data, registry);
  factory GroupMember.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GroupMember()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupMember',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: GroupMember.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aI(2, _omitFieldNames ? '' : 'role')
    ..aOS(3, _omitFieldNames ? '' : 'nickname')
    ..aOS(4, _omitFieldNames ? '' : 'avatar')
    ..aInt64(5, _omitFieldNames ? '' : 'joinTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMember clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMember copyWith(void Function(GroupMember) updates) =>
      super.copyWith((message) => updates(message as GroupMember))
          as GroupMember;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GroupMember() / GroupMember.new instead')
  static GroupMember create() => GroupMember._();
  static $pb.GeneratedMessage $_createMessage() => GroupMember._();
  @$core.override
  GroupMember createEmptyInstance() => GroupMember._();
  @$core.pragma('dart2js:noInline')
  static GroupMember getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupMember>(
          GroupMember.$_createMessage);
  static GroupMember? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get role => $_getIZ(1);
  @$pb.TagNumber(2)
  set role($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nickname => $_getSZ(2);
  @$pb.TagNumber(3)
  set nickname($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNickname() => $_has(2);
  @$pb.TagNumber(3)
  void clearNickname() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get joinTimeMs => $_getI64(4);
  @$pb.TagNumber(5)
  set joinTimeMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasJoinTimeMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearJoinTimeMs() => $_clearField(5);
}

class ListGroupMembersReq extends $pb.GeneratedMessage {
  factory ListGroupMembersReq({
    $fixnum.Int64? convId,
  }) {
    final result = ListGroupMembersReq._();
    if (convId != null) result.convId = convId;
    return result;
  }

  ListGroupMembersReq._();

  factory ListGroupMembersReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListGroupMembersReq()..mergeFromBuffer(data, registry);
  factory ListGroupMembersReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListGroupMembersReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListGroupMembersReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ListGroupMembersReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'convId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGroupMembersReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGroupMembersReq copyWith(void Function(ListGroupMembersReq) updates) =>
      super.copyWith((message) => updates(message as ListGroupMembersReq))
          as ListGroupMembersReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ListGroupMembersReq() / ListGroupMembersReq.new instead')
  static ListGroupMembersReq create() => ListGroupMembersReq._();
  static $pb.GeneratedMessage $_createMessage() => ListGroupMembersReq._();
  @$core.override
  ListGroupMembersReq createEmptyInstance() => ListGroupMembersReq._();
  @$core.pragma('dart2js:noInline')
  static ListGroupMembersReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListGroupMembersReq>(
          ListGroupMembersReq.$_createMessage);
  static ListGroupMembersReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get convId => $_getI64(0);
  @$pb.TagNumber(1)
  set convId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConvId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConvId() => $_clearField(1);
}

class ListGroupMembersRsp extends $pb.GeneratedMessage {
  factory ListGroupMembersRsp({
    $core.Iterable<GroupMember>? members,
    $0.Error? error,
  }) {
    final result = ListGroupMembersRsp._();
    if (members != null) result.members.addAll(members);
    if (error != null) result.error = error;
    return result;
  }

  ListGroupMembersRsp._();

  factory ListGroupMembersRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListGroupMembersRsp()..mergeFromBuffer(data, registry);
  factory ListGroupMembersRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListGroupMembersRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListGroupMembersRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ListGroupMembersRsp.$_createMessage)
    ..pPM<GroupMember>(1, _omitFieldNames ? '' : 'members',
        subBuilder: GroupMember.$_createMessage)
    ..aOM<$0.Error>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGroupMembersRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGroupMembersRsp copyWith(void Function(ListGroupMembersRsp) updates) =>
      super.copyWith((message) => updates(message as ListGroupMembersRsp))
          as ListGroupMembersRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ListGroupMembersRsp() / ListGroupMembersRsp.new instead')
  static ListGroupMembersRsp create() => ListGroupMembersRsp._();
  static $pb.GeneratedMessage $_createMessage() => ListGroupMembersRsp._();
  @$core.override
  ListGroupMembersRsp createEmptyInstance() => ListGroupMembersRsp._();
  @$core.pragma('dart2js:noInline')
  static ListGroupMembersRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListGroupMembersRsp>(
          ListGroupMembersRsp.$_createMessage);
  static ListGroupMembersRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GroupMember> get members => $_getList(0);

  @$pb.TagNumber(2)
  $0.Error get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($0.Error value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Error ensureError() => $_ensure(1);
}

/// 改群信息 (里程碑11): 仅群主 (code 23); 字段按传入与否覆盖 (空串=不改名, 用
/// update_mask 语义简化为"字段级可选", protojson 缺省字段不覆盖)
class UpdateGroupInfoReq extends $pb.GeneratedMessage {
  factory UpdateGroupInfoReq({
    $fixnum.Int64? opUid,
    $fixnum.Int64? convId,
    $core.String? name,
    $core.String? avatar,
  }) {
    final result = UpdateGroupInfoReq._();
    if (opUid != null) result.opUid = opUid;
    if (convId != null) result.convId = convId;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    return result;
  }

  UpdateGroupInfoReq._();

  factory UpdateGroupInfoReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateGroupInfoReq()..mergeFromBuffer(data, registry);
  factory UpdateGroupInfoReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateGroupInfoReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGroupInfoReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: UpdateGroupInfoReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'opUid')
    ..aInt64(2, _omitFieldNames ? '' : 'convId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'avatar')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupInfoReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupInfoReq copyWith(void Function(UpdateGroupInfoReq) updates) =>
      super.copyWith((message) => updates(message as UpdateGroupInfoReq))
          as UpdateGroupInfoReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateGroupInfoReq() / UpdateGroupInfoReq.new instead')
  static UpdateGroupInfoReq create() => UpdateGroupInfoReq._();
  static $pb.GeneratedMessage $_createMessage() => UpdateGroupInfoReq._();
  @$core.override
  UpdateGroupInfoReq createEmptyInstance() => UpdateGroupInfoReq._();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupInfoReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGroupInfoReq>(
          UpdateGroupInfoReq.$_createMessage);
  static UpdateGroupInfoReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get opUid => $_getI64(0);
  @$pb.TagNumber(1)
  set opUid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOpUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearOpUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get convId => $_getI64(1);
  @$pb.TagNumber(2)
  set convId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConvId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConvId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatar($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatar() => $_clearField(4);
}

class UpdateGroupInfoRsp extends $pb.GeneratedMessage {
  factory UpdateGroupInfoRsp({
    $0.Error? error,
  }) {
    final result = UpdateGroupInfoRsp._();
    if (error != null) result.error = error;
    return result;
  }

  UpdateGroupInfoRsp._();

  factory UpdateGroupInfoRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateGroupInfoRsp()..mergeFromBuffer(data, registry);
  factory UpdateGroupInfoRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateGroupInfoRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGroupInfoRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: UpdateGroupInfoRsp.$_createMessage)
    ..aOM<$0.Error>(1, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupInfoRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupInfoRsp copyWith(void Function(UpdateGroupInfoRsp) updates) =>
      super.copyWith((message) => updates(message as UpdateGroupInfoRsp))
          as UpdateGroupInfoRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateGroupInfoRsp() / UpdateGroupInfoRsp.new instead')
  static UpdateGroupInfoRsp create() => UpdateGroupInfoRsp._();
  static $pb.GeneratedMessage $_createMessage() => UpdateGroupInfoRsp._();
  @$core.override
  UpdateGroupInfoRsp createEmptyInstance() => UpdateGroupInfoRsp._();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupInfoRsp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGroupInfoRsp>(
          UpdateGroupInfoRsp.$_createMessage);
  static UpdateGroupInfoRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error($0.Error value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Error ensureError() => $_ensure(0);
}

class GetProfilesReq extends $pb.GeneratedMessage {
  factory GetProfilesReq({
    $core.Iterable<$fixnum.Int64>? uids,
  }) {
    final result = GetProfilesReq._();
    if (uids != null) result.uids.addAll(uids);
    return result;
  }

  GetProfilesReq._();

  factory GetProfilesReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetProfilesReq()..mergeFromBuffer(data, registry);
  factory GetProfilesReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetProfilesReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProfilesReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: GetProfilesReq.$_createMessage)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'uids', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfilesReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfilesReq copyWith(void Function(GetProfilesReq) updates) =>
      super.copyWith((message) => updates(message as GetProfilesReq))
          as GetProfilesReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetProfilesReq() / GetProfilesReq.new instead')
  static GetProfilesReq create() => GetProfilesReq._();
  static $pb.GeneratedMessage $_createMessage() => GetProfilesReq._();
  @$core.override
  GetProfilesReq createEmptyInstance() => GetProfilesReq._();
  @$core.pragma('dart2js:noInline')
  static GetProfilesReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProfilesReq>(
          GetProfilesReq.$_createMessage);
  static GetProfilesReq? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get uids => $_getList(0);
}

class GetProfilesRsp extends $pb.GeneratedMessage {
  factory GetProfilesRsp({
    $core.Iterable<UserProfile>? profiles,
    $0.Error? error,
  }) {
    final result = GetProfilesRsp._();
    if (profiles != null) result.profiles.addAll(profiles);
    if (error != null) result.error = error;
    return result;
  }

  GetProfilesRsp._();

  factory GetProfilesRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetProfilesRsp()..mergeFromBuffer(data, registry);
  factory GetProfilesRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetProfilesRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProfilesRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: GetProfilesRsp.$_createMessage)
    ..pPM<UserProfile>(1, _omitFieldNames ? '' : 'profiles',
        subBuilder: UserProfile.$_createMessage)
    ..aOM<$0.Error>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfilesRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProfilesRsp copyWith(void Function(GetProfilesRsp) updates) =>
      super.copyWith((message) => updates(message as GetProfilesRsp))
          as GetProfilesRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetProfilesRsp() / GetProfilesRsp.new instead')
  static GetProfilesRsp create() => GetProfilesRsp._();
  static $pb.GeneratedMessage $_createMessage() => GetProfilesRsp._();
  @$core.override
  GetProfilesRsp createEmptyInstance() => GetProfilesRsp._();
  @$core.pragma('dart2js:noInline')
  static GetProfilesRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProfilesRsp>(
          GetProfilesRsp.$_createMessage);
  static GetProfilesRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UserProfile> get profiles => $_getList(0);

  @$pb.TagNumber(2)
  $0.Error get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($0.Error value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Error ensureError() => $_ensure(1);
}

class SearchUsersReq extends $pb.GeneratedMessage {
  factory SearchUsersReq({
    $core.String? keyword,
    $fixnum.Int64? opUid,
    $core.int? limit,
  }) {
    final result = SearchUsersReq._();
    if (keyword != null) result.keyword = keyword;
    if (opUid != null) result.opUid = opUid;
    if (limit != null) result.limit = limit;
    return result;
  }

  SearchUsersReq._();

  factory SearchUsersReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchUsersReq()..mergeFromBuffer(data, registry);
  factory SearchUsersReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchUsersReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUsersReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SearchUsersReq.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'keyword')
    ..aInt64(2, _omitFieldNames ? '' : 'opUid')
    ..aI(3, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersReq copyWith(void Function(SearchUsersReq) updates) =>
      super.copyWith((message) => updates(message as SearchUsersReq))
          as SearchUsersReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SearchUsersReq() / SearchUsersReq.new instead')
  static SearchUsersReq create() => SearchUsersReq._();
  static $pb.GeneratedMessage $_createMessage() => SearchUsersReq._();
  @$core.override
  SearchUsersReq createEmptyInstance() => SearchUsersReq._();
  @$core.pragma('dart2js:noInline')
  static SearchUsersReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchUsersReq>(
          SearchUsersReq.$_createMessage);
  static SearchUsersReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get keyword => $_getSZ(0);
  @$pb.TagNumber(1)
  set keyword($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeyword() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeyword() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get opUid => $_getI64(1);
  @$pb.TagNumber(2)
  set opUid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOpUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearOpUid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class SearchUsersRsp extends $pb.GeneratedMessage {
  factory SearchUsersRsp({
    $core.Iterable<UserProfile>? profiles,
    $0.Error? error,
  }) {
    final result = SearchUsersRsp._();
    if (profiles != null) result.profiles.addAll(profiles);
    if (error != null) result.error = error;
    return result;
  }

  SearchUsersRsp._();

  factory SearchUsersRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchUsersRsp()..mergeFromBuffer(data, registry);
  factory SearchUsersRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchUsersRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUsersRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: SearchUsersRsp.$_createMessage)
    ..pPM<UserProfile>(1, _omitFieldNames ? '' : 'profiles',
        subBuilder: UserProfile.$_createMessage)
    ..aOM<$0.Error>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersRsp copyWith(void Function(SearchUsersRsp) updates) =>
      super.copyWith((message) => updates(message as SearchUsersRsp))
          as SearchUsersRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SearchUsersRsp() / SearchUsersRsp.new instead')
  static SearchUsersRsp create() => SearchUsersRsp._();
  static $pb.GeneratedMessage $_createMessage() => SearchUsersRsp._();
  @$core.override
  SearchUsersRsp createEmptyInstance() => SearchUsersRsp._();
  @$core.pragma('dart2js:noInline')
  static SearchUsersRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchUsersRsp>(
          SearchUsersRsp.$_createMessage);
  static SearchUsersRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UserProfile> get profiles => $_getList(0);

  @$pb.TagNumber(2)
  $0.Error get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($0.Error value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Error ensureError() => $_ensure(1);
}

class UserProfile extends $pb.GeneratedMessage {
  factory UserProfile({
    $fixnum.Int64? uid,
    $core.String? nickname,
    $core.String? avatar,
  }) {
    final result = UserProfile._();
    if (uid != null) result.uid = uid;
    if (nickname != null) result.nickname = nickname;
    if (avatar != null) result.avatar = avatar;
    return result;
  }

  UserProfile._();

  factory UserProfile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UserProfile()..mergeFromBuffer(data, registry);
  factory UserProfile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UserProfile()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserProfile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: UserProfile.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserProfile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserProfile copyWith(void Function(UserProfile) updates) =>
      super.copyWith((message) => updates(message as UserProfile))
          as UserProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UserProfile() / UserProfile.new instead')
  static UserProfile create() => UserProfile._();
  static $pb.GeneratedMessage $_createMessage() => UserProfile._();
  @$core.override
  UserProfile createEmptyInstance() => UserProfile._();
  @$core.pragma('dart2js:noInline')
  static UserProfile getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserProfile>(
          UserProfile.$_createMessage);
  static UserProfile? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);
}

class UpdateProfileReq extends $pb.GeneratedMessage {
  factory UpdateProfileReq({
    $fixnum.Int64? uid,
    $core.String? nickname,
    $core.String? avatar,
  }) {
    final result = UpdateProfileReq._();
    if (uid != null) result.uid = uid;
    if (nickname != null) result.nickname = nickname;
    if (avatar != null) result.avatar = avatar;
    return result;
  }

  UpdateProfileReq._();

  factory UpdateProfileReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProfileReq()..mergeFromBuffer(data, registry);
  factory UpdateProfileReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProfileReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProfileReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: UpdateProfileReq.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aOS(3, _omitFieldNames ? '' : 'avatar')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileReq copyWith(void Function(UpdateProfileReq) updates) =>
      super.copyWith((message) => updates(message as UpdateProfileReq))
          as UpdateProfileReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateProfileReq() / UpdateProfileReq.new instead')
  static UpdateProfileReq create() => UpdateProfileReq._();
  static $pb.GeneratedMessage $_createMessage() => UpdateProfileReq._();
  @$core.override
  UpdateProfileReq createEmptyInstance() => UpdateProfileReq._();
  @$core.pragma('dart2js:noInline')
  static UpdateProfileReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProfileReq>(
          UpdateProfileReq.$_createMessage);
  static UpdateProfileReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatar => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatar($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatar() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatar() => $_clearField(3);
}

class UpdateProfileRsp extends $pb.GeneratedMessage {
  factory UpdateProfileRsp({
    UserProfile? profile,
    $0.Error? error,
  }) {
    final result = UpdateProfileRsp._();
    if (profile != null) result.profile = profile;
    if (error != null) result.error = error;
    return result;
  }

  UpdateProfileRsp._();

  factory UpdateProfileRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProfileRsp()..mergeFromBuffer(data, registry);
  factory UpdateProfileRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateProfileRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProfileRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: UpdateProfileRsp.$_createMessage)
    ..aOM<UserProfile>(1, _omitFieldNames ? '' : 'profile',
        subBuilder: UserProfile.$_createMessage)
    ..aOM<$0.Error>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProfileRsp copyWith(void Function(UpdateProfileRsp) updates) =>
      super.copyWith((message) => updates(message as UpdateProfileRsp))
          as UpdateProfileRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateProfileRsp() / UpdateProfileRsp.new instead')
  static UpdateProfileRsp create() => UpdateProfileRsp._();
  static $pb.GeneratedMessage $_createMessage() => UpdateProfileRsp._();
  @$core.override
  UpdateProfileRsp createEmptyInstance() => UpdateProfileRsp._();
  @$core.pragma('dart2js:noInline')
  static UpdateProfileRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProfileRsp>(
          UpdateProfileRsp.$_createMessage);
  static UpdateProfileRsp? _defaultInstance;

  @$pb.TagNumber(1)
  UserProfile get profile => $_getN(0);
  @$pb.TagNumber(1)
  set profile(UserProfile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => $_clearField(1);
  @$pb.TagNumber(1)
  UserProfile ensureProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Error get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($0.Error value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Error ensureError() => $_ensure(1);
}

class GetPresenceReq extends $pb.GeneratedMessage {
  factory GetPresenceReq({
    $core.Iterable<$fixnum.Int64>? uids,
  }) {
    final result = GetPresenceReq._();
    if (uids != null) result.uids.addAll(uids);
    return result;
  }

  GetPresenceReq._();

  factory GetPresenceReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPresenceReq()..mergeFromBuffer(data, registry);
  factory GetPresenceReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPresenceReq()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPresenceReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: GetPresenceReq.$_createMessage)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'uids', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPresenceReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPresenceReq copyWith(void Function(GetPresenceReq) updates) =>
      super.copyWith((message) => updates(message as GetPresenceReq))
          as GetPresenceReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPresenceReq() / GetPresenceReq.new instead')
  static GetPresenceReq create() => GetPresenceReq._();
  static $pb.GeneratedMessage $_createMessage() => GetPresenceReq._();
  @$core.override
  GetPresenceReq createEmptyInstance() => GetPresenceReq._();
  @$core.pragma('dart2js:noInline')
  static GetPresenceReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPresenceReq>(
          GetPresenceReq.$_createMessage);
  static GetPresenceReq? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get uids => $_getList(0);
}

class PresenceInfo extends $pb.GeneratedMessage {
  factory PresenceInfo({
    $fixnum.Int64? uid,
    Presence? presence,
  }) {
    final result = PresenceInfo._();
    if (uid != null) result.uid = uid;
    if (presence != null) result.presence = presence;
    return result;
  }

  PresenceInfo._();

  factory PresenceInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PresenceInfo()..mergeFromBuffer(data, registry);
  factory PresenceInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PresenceInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresenceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: PresenceInfo.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'uid')
    ..aE<Presence>(2, _omitFieldNames ? '' : 'presence',
        enumValues: Presence.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceInfo copyWith(void Function(PresenceInfo) updates) =>
      super.copyWith((message) => updates(message as PresenceInfo))
          as PresenceInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PresenceInfo() / PresenceInfo.new instead')
  static PresenceInfo create() => PresenceInfo._();
  static $pb.GeneratedMessage $_createMessage() => PresenceInfo._();
  @$core.override
  PresenceInfo createEmptyInstance() => PresenceInfo._();
  @$core.pragma('dart2js:noInline')
  static PresenceInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresenceInfo>(
          PresenceInfo.$_createMessage);
  static PresenceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get uid => $_getI64(0);
  @$pb.TagNumber(1)
  set uid($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => $_clearField(1);

  @$pb.TagNumber(2)
  Presence get presence => $_getN(1);
  @$pb.TagNumber(2)
  set presence(Presence value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPresence() => $_has(1);
  @$pb.TagNumber(2)
  void clearPresence() => $_clearField(2);
}

class GetPresenceRsp extends $pb.GeneratedMessage {
  factory GetPresenceRsp({
    $core.Iterable<PresenceInfo>? presences,
    $0.Error? error,
  }) {
    final result = GetPresenceRsp._();
    if (presences != null) result.presences.addAll(presences);
    if (error != null) result.error = error;
    return result;
  }

  GetPresenceRsp._();

  factory GetPresenceRsp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPresenceRsp()..mergeFromBuffer(data, registry);
  factory GetPresenceRsp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPresenceRsp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPresenceRsp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: GetPresenceRsp.$_createMessage)
    ..pPM<PresenceInfo>(1, _omitFieldNames ? '' : 'presences',
        subBuilder: PresenceInfo.$_createMessage)
    ..aOM<$0.Error>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $0.Error.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPresenceRsp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPresenceRsp copyWith(void Function(GetPresenceRsp) updates) =>
      super.copyWith((message) => updates(message as GetPresenceRsp))
          as GetPresenceRsp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetPresenceRsp() / GetPresenceRsp.new instead')
  static GetPresenceRsp create() => GetPresenceRsp._();
  static $pb.GeneratedMessage $_createMessage() => GetPresenceRsp._();
  @$core.override
  GetPresenceRsp createEmptyInstance() => GetPresenceRsp._();
  @$core.pragma('dart2js:noInline')
  static GetPresenceRsp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPresenceRsp>(
          GetPresenceRsp.$_createMessage);
  static GetPresenceRsp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PresenceInfo> get presences => $_getList(0);

  @$pb.TagNumber(2)
  $0.Error get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($0.Error value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Error ensureError() => $_ensure(1);
}

class RelationServiceApi {
  final $pb.RpcClient _client;

  RelationServiceApi(this._client);

  /// 发好友申请: (from,to) 行内状态机, 重复申请幂等;
  /// 互为 pending 自动合并为互相接受
  $async.Future<SendFriendRequestRsp> sendFriendRequest(
          $pb.ClientContext? ctx, SendFriendRequestReq request) =>
      _client.invoke<SendFriendRequestRsp>(ctx, 'RelationService',
          'SendFriendRequest', request, SendFriendRequestRsp());

  /// 处理收到的申请: accept 同事务写双向 friendships
  $async.Future<HandleFriendRequestRsp> handleFriendRequest(
          $pb.ClientContext? ctx, HandleFriendRequestReq request) =>
      _client.invoke<HandleFriendRequestRsp>(ctx, 'RelationService',
          'HandleFriendRequest', request, HandleFriendRequestRsp());

  /// 申请列表: direction=in 收到的 / out 发出的
  $async.Future<ListFriendRequestsRsp> listFriendRequests(
          $pb.ClientContext? ctx, ListFriendRequestsReq request) =>
      _client.invoke<ListFriendRequestsRsp>(ctx, 'RelationService',
          'ListFriendRequests', request, ListFriendRequestsRsp());

  /// 好友列表 (含资料), PK 前缀分页
  $async.Future<ListFriendsRsp> listFriends(
          $pb.ClientContext? ctx, ListFriendsReq request) =>
      _client.invoke<ListFriendsRsp>(
          ctx, 'RelationService', 'ListFriends', request, ListFriendsRsp());

  /// 删除好友: 删双向 friendships 行, 申请历史保留
  $async.Future<DeleteFriendRsp> deleteFriend(
          $pb.ClientContext? ctx, DeleteFriendReq request) =>
      _client.invoke<DeleteFriendRsp>(
          ctx, 'RelationService', 'DeleteFriend', request, DeleteFriendRsp());

  /// 好友关系判定: Message Svc CreateConv 单聊校验专用 (fail-close)
  $async.Future<CheckFriendshipRsp> checkFriendship(
          $pb.ClientContext? ctx, CheckFriendshipReq request) =>
      _client.invoke<CheckFriendshipRsp>(ctx, 'RelationService',
          'CheckFriendship', request, CheckFriendshipRsp());

  /// 加群成员: 建群 seed + 拉人共用, 幂等 upsert (重复拉已在校成员不报错)。
  /// owner_uid = 操作者: 建群 (群尚无成员) 时操作者即群主 (其行 role=1);
  /// 群已存在时操作者必须是群主 (code 23)
  $async.Future<AddGroupMembersRsp> addGroupMembers(
          $pb.ClientContext? ctx, AddGroupMembersReq request) =>
      _client.invoke<AddGroupMembersRsp>(ctx, 'RelationService',
          'AddGroupMembers', request, AddGroupMembersRsp());

  /// 踢人: 仅群主 (role=1); 同步删 message 域的会话索引
  $async.Future<RemoveGroupMemberRsp> removeGroupMember(
          $pb.ClientContext? ctx, RemoveGroupMemberReq request) =>
      _client.invoke<RemoveGroupMemberRsp>(ctx, 'RelationService',
          'RemoveGroupMember', request, RemoveGroupMemberRsp());

  /// 退群: 群主不可退 (先转让/解散, 后续里程碑)
  $async.Future<QuitGroupRsp> quitGroup(
          $pb.ClientContext? ctx, QuitGroupReq request) =>
      _client.invoke<QuitGroupRsp>(
          ctx, 'RelationService', 'QuitGroup', request, QuitGroupRsp());

  /// 群成员列表 (含 role 与资料)
  $async.Future<ListGroupMembersRsp> listGroupMembers(
          $pb.ClientContext? ctx, ListGroupMembersReq request) =>
      _client.invoke<ListGroupMembersRsp>(ctx, 'RelationService',
          'ListGroupMembers', request, ListGroupMembersRsp());

  /// 改群信息 (群名/群头像, 里程碑11): 仅群主; 直写 message 域 conversations
  /// + InvalidateConv (同上已知债务: 同库共表换解耦)
  $async.Future<UpdateGroupInfoRsp> updateGroupInfo(
          $pb.ClientContext? ctx, UpdateGroupInfoReq request) =>
      _client.invoke<UpdateGroupInfoRsp>(ctx, 'RelationService',
          'UpdateGroupInfo', request, UpdateGroupInfoRsp());

  /// 批量查用户资料 (会话列表/聊天头渲染用), clamp 50
  $async.Future<GetProfilesRsp> getProfiles(
          $pb.ClientContext? ctx, GetProfilesReq request) =>
      _client.invoke<GetProfilesRsp>(
          ctx, 'RelationService', 'GetProfiles', request, GetProfilesRsp());

  /// 搜索用户 (加好友预览: uid 精确 / 昵称前缀), 返回脱敏资料, clamp 20
  $async.Future<SearchUsersRsp> searchUsers(
          $pb.ClientContext? ctx, SearchUsersReq request) =>
      _client.invoke<SearchUsersRsp>(
          ctx, 'RelationService', 'SearchUsers', request, SearchUsersRsp());

  /// 改资料: nickname 冲突 code 27; avatar 由网关上传接口写入
  $async.Future<UpdateProfileRsp> updateProfile(
          $pb.ClientContext? ctx, UpdateProfileReq request) =>
      _client.invoke<UpdateProfileRsp>(
          ctx, 'RelationService', 'UpdateProfile', request, UpdateProfileRsp());

  /// 在线状态查询 (连接级): EXISTS route:{uid} —— 60s TTL 心跳续期,
  /// 心跳断档即离线; 查询制不做订阅推送
  $async.Future<GetPresenceRsp> getPresence(
          $pb.ClientContext? ctx, GetPresenceReq request) =>
      _client.invoke<GetPresenceRsp>(
          ctx, 'RelationService', 'GetPresence', request, GetPresenceRsp());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');

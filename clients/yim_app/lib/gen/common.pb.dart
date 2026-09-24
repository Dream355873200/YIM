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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'common.pbenum.dart';

/// 多端在线策略: 手机+桌面各一条连接, 消息双推, 各端独立 ack
class DeviceInfo extends $pb.GeneratedMessage {
  factory DeviceInfo({
    DeviceType? type,
    $core.String? deviceId,
    $core.String? clientVersion,
  }) {
    final result = DeviceInfo._();
    if (type != null) result.type = type;
    if (deviceId != null) result.deviceId = deviceId;
    if (clientVersion != null) result.clientVersion = clientVersion;
    return result;
  }

  DeviceInfo._();

  factory DeviceInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceInfo()..mergeFromBuffer(data, registry);
  factory DeviceInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: DeviceInfo.$_createMessage)
    ..aE<DeviceType>(1, _omitFieldNames ? '' : 'type',
        enumValues: DeviceType.values)
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'clientVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceInfo copyWith(void Function(DeviceInfo) updates) =>
      super.copyWith((message) => updates(message as DeviceInfo)) as DeviceInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeviceInfo() / DeviceInfo.new instead')
  static DeviceInfo create() => DeviceInfo._();
  static $pb.GeneratedMessage $_createMessage() => DeviceInfo._();
  @$core.override
  DeviceInfo createEmptyInstance() => DeviceInfo._();
  @$core.pragma('dart2js:noInline')
  static DeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceInfo>(DeviceInfo.$_createMessage);
  static DeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  DeviceType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(DeviceType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get clientVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set clientVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClientVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientVersion() => $_clearField(3);
}

/// 统一响应头, 业务错误不使用 gRPC status 传递业务语义
/// (gRPC status 只表达传输层错误: 不可达/超时/取消)
class Error extends $pb.GeneratedMessage {
  factory Error({
    $core.int? code,
    $core.String? msg,
    $fixnum.Int64? retryAfterMs,
  }) {
    final result = Error._();
    if (code != null) result.code = code;
    if (msg != null) result.msg = msg;
    if (retryAfterMs != null) result.retryAfterMs = retryAfterMs;
    return result;
  }

  Error._();

  factory Error.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Error()..mergeFromBuffer(data, registry);
  factory Error.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Error()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Error',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: Error.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aInt64(3, _omitFieldNames ? '' : 'retryAfterMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Error clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Error copyWith(void Function(Error) updates) =>
      super.copyWith((message) => updates(message as Error)) as Error;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Error() / Error.new instead')
  static Error create() => Error._();
  static $pb.GeneratedMessage $_createMessage() => Error._();
  @$core.override
  Error createEmptyInstance() => Error._();
  @$core.pragma('dart2js:noInline')
  static Error getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Error>(Error.$_createMessage);
  static Error? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => $_clearField(2);

  /// 可选的重试指引: 非零时客户端按毫秒延迟重试
  @$pb.TagNumber(3)
  $fixnum.Int64 get retryAfterMs => $_getI64(2);
  @$pb.TagNumber(3)
  set retryAfterMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRetryAfterMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearRetryAfterMs() => $_clearField(3);
}

class PageInfo extends $pb.GeneratedMessage {
  factory PageInfo({
    $core.int? pageNum,
    $core.int? pageSize,
  }) {
    final result = PageInfo._();
    if (pageNum != null) result.pageNum = pageNum;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  PageInfo._();

  factory PageInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageInfo()..mergeFromBuffer(data, registry);
  factory PageInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PageInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: PageInfo.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'pageNum')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageInfo copyWith(void Function(PageInfo) updates) =>
      super.copyWith((message) => updates(message as PageInfo)) as PageInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PageInfo() / PageInfo.new instead')
  static PageInfo create() => PageInfo._();
  static $pb.GeneratedMessage $_createMessage() => PageInfo._();
  @$core.override
  PageInfo createEmptyInstance() => PageInfo._();
  @$core.pragma('dart2js:noInline')
  static PageInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PageInfo>(PageInfo.$_createMessage);
  static PageInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageNum => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageNum($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageNum() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageNum() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');

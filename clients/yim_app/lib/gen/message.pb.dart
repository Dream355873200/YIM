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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'message.pbenum.dart';

/// conv_id 生成规则: 号段分配 + 嵌入创建者分片基因
/// 结构: [1bit标志][41bit时间戳][12bit分片基因][10bit自增]
/// 分片基因 = 创建者 uid 对分片数取模 → 关系查询可直路由, 免二次hash
class Conv extends $pb.GeneratedMessage {
  factory Conv({
    $fixnum.Int64? convId,
    ConvType? type,
    $core.Iterable<$fixnum.Int64>? memberUids,
    $fixnum.Int64? createTimeMs,
    $fixnum.Int64? lastSeq,
    $core.String? name,
    $core.String? avatar,
  }) {
    final result = Conv._();
    if (convId != null) result.convId = convId;
    if (type != null) result.type = type;
    if (memberUids != null) result.memberUids.addAll(memberUids);
    if (createTimeMs != null) result.createTimeMs = createTimeMs;
    if (lastSeq != null) result.lastSeq = lastSeq;
    if (name != null) result.name = name;
    if (avatar != null) result.avatar = avatar;
    return result;
  }

  Conv._();

  factory Conv.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Conv()..mergeFromBuffer(data, registry);
  factory Conv.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Conv()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Conv',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: Conv.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'convId')
    ..aE<ConvType>(2, _omitFieldNames ? '' : 'type',
        enumValues: ConvType.values)
    ..p<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'memberUids', $pb.PbFieldType.K6)
    ..aInt64(4, _omitFieldNames ? '' : 'createTimeMs')
    ..aInt64(5, _omitFieldNames ? '' : 'lastSeq')
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aOS(7, _omitFieldNames ? '' : 'avatar')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conv clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conv copyWith(void Function(Conv) updates) =>
      super.copyWith((message) => updates(message as Conv)) as Conv;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Conv() / Conv.new instead')
  static Conv create() => Conv._();
  static $pb.GeneratedMessage $_createMessage() => Conv._();
  @$core.override
  Conv createEmptyInstance() => Conv._();
  @$core.pragma('dart2js:noInline')
  static Conv getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Conv>(Conv.$_createMessage);
  static Conv? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get convId => $_getI64(0);
  @$pb.TagNumber(1)
  set convId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConvId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConvId() => $_clearField(1);

  @$pb.TagNumber(2)
  ConvType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ConvType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  /// 单聊: 两端 uid, 存储时约定小 uid 在前保证同一单聊唯一
  @$pb.TagNumber(3)
  $pb.PbList<$fixnum.Int64> get memberUids => $_getList(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get createTimeMs => $_getI64(3);
  @$pb.TagNumber(4)
  set createTimeMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreateTimeMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreateTimeMs() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get lastSeq => $_getI64(4);
  @$pb.TagNumber(5)
  set lastSeq($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLastSeq() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastSeq() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get avatar => $_getSZ(6);
  @$pb.TagNumber(7)
  set avatar($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAvatar() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvatar() => $_clearField(7);
}

class ConvMsgContent extends $pb.GeneratedMessage {
  factory ConvMsgContent({
    MsgType? type,
    $core.String? text,
    MediaMeta? media,
    Ext? ext,
  }) {
    final result = ConvMsgContent._();
    if (type != null) result.type = type;
    if (text != null) result.text = text;
    if (media != null) result.media = media;
    if (ext != null) result.ext = ext;
    return result;
  }

  ConvMsgContent._();

  factory ConvMsgContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvMsgContent()..mergeFromBuffer(data, registry);
  factory ConvMsgContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvMsgContent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConvMsgContent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ConvMsgContent.$_createMessage)
    ..aE<MsgType>(1, _omitFieldNames ? '' : 'type', enumValues: MsgType.values)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOM<MediaMeta>(3, _omitFieldNames ? '' : 'media',
        subBuilder: MediaMeta.$_createMessage)
    ..aOM<Ext>(4, _omitFieldNames ? '' : 'ext', subBuilder: Ext.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvMsgContent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvMsgContent copyWith(void Function(ConvMsgContent) updates) =>
      super.copyWith((message) => updates(message as ConvMsgContent))
          as ConvMsgContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConvMsgContent() / ConvMsgContent.new instead')
  static ConvMsgContent create() => ConvMsgContent._();
  static $pb.GeneratedMessage $_createMessage() => ConvMsgContent._();
  @$core.override
  ConvMsgContent createEmptyInstance() => ConvMsgContent._();
  @$core.pragma('dart2js:noInline')
  static ConvMsgContent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConvMsgContent>(
          ConvMsgContent.$_createMessage);
  static ConvMsgContent? _defaultInstance;

  @$pb.TagNumber(1)
  MsgType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(MsgType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  /// 图片/文件/语音走对象存储客户端直传, 这里只存元数据
  @$pb.TagNumber(3)
  MediaMeta get media => $_getN(2);
  @$pb.TagNumber(3)
  set media(MediaMeta value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMedia() => $_has(2);
  @$pb.TagNumber(3)
  void clearMedia() => $_clearField(3);
  @$pb.TagNumber(3)
  MediaMeta ensureMedia() => $_ensure(2);

  /// 撤回/系统类消息的扩展字段
  @$pb.TagNumber(4)
  Ext get ext => $_getN(3);
  @$pb.TagNumber(4)
  set ext(Ext value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasExt() => $_has(3);
  @$pb.TagNumber(4)
  void clearExt() => $_clearField(4);
  @$pb.TagNumber(4)
  Ext ensureExt() => $_ensure(3);
}

class MediaMeta extends $pb.GeneratedMessage {
  factory MediaMeta({
    $core.String? url,
    $fixnum.Int64? size,
    $core.int? width,
    $core.int? height,
    $core.int? durationMs,
  }) {
    final result = MediaMeta._();
    if (url != null) result.url = url;
    if (size != null) result.size = size;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (durationMs != null) result.durationMs = durationMs;
    return result;
  }

  MediaMeta._();

  factory MediaMeta.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MediaMeta()..mergeFromBuffer(data, registry);
  factory MediaMeta.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MediaMeta()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MediaMeta',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: MediaMeta.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aInt64(2, _omitFieldNames ? '' : 'size')
    ..aI(3, _omitFieldNames ? '' : 'width')
    ..aI(4, _omitFieldNames ? '' : 'height')
    ..aI(5, _omitFieldNames ? '' : 'durationMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaMeta clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaMeta copyWith(void Function(MediaMeta) updates) =>
      super.copyWith((message) => updates(message as MediaMeta)) as MediaMeta;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MediaMeta() / MediaMeta.new instead')
  static MediaMeta create() => MediaMeta._();
  static $pb.GeneratedMessage $_createMessage() => MediaMeta._();
  @$core.override
  MediaMeta createEmptyInstance() => MediaMeta._();
  @$core.pragma('dart2js:noInline')
  static MediaMeta getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MediaMeta>(MediaMeta.$_createMessage);
  static MediaMeta? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get size => $_getI64(1);
  @$pb.TagNumber(2)
  set size($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get durationMs => $_getIZ(4);
  @$pb.TagNumber(5)
  set durationMs($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDurationMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearDurationMs() => $_clearField(5);
}

class Ext extends $pb.GeneratedMessage {
  factory Ext({
    $fixnum.Int64? refMsgId,
    $fixnum.Int64? opUid,
    $core.String? json,
    $core.String? refText,
  }) {
    final result = Ext._();
    if (refMsgId != null) result.refMsgId = refMsgId;
    if (opUid != null) result.opUid = opUid;
    if (json != null) result.json = json;
    if (refText != null) result.refText = refText;
    return result;
  }

  Ext._();

  factory Ext.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ext()..mergeFromBuffer(data, registry);
  factory Ext.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Ext()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ext',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: Ext.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'refMsgId')
    ..aInt64(2, _omitFieldNames ? '' : 'opUid')
    ..aOS(3, _omitFieldNames ? '' : 'json')
    ..aOS(4, _omitFieldNames ? '' : 'refText')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ext clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ext copyWith(void Function(Ext) updates) =>
      super.copyWith((message) => updates(message as Ext)) as Ext;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Ext() / Ext.new instead')
  static Ext create() => Ext._();
  static $pb.GeneratedMessage $_createMessage() => Ext._();
  @$core.override
  Ext createEmptyInstance() => Ext._();
  @$core.pragma('dart2js:noInline')
  static Ext getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Ext>(Ext.$_createMessage);
  static Ext? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get refMsgId => $_getI64(0);
  @$pb.TagNumber(1)
  set refMsgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRefMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get opUid => $_getI64(1);
  @$pb.TagNumber(2)
  set opUid($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOpUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearOpUid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get json => $_getSZ(2);
  @$pb.TagNumber(3)
  set json($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearJson() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get refText => $_getSZ(3);
  @$pb.TagNumber(4)
  set refText($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRefText() => $_has(3);
  @$pb.TagNumber(4)
  void clearRefText() => $_clearField(4);
}

/// 存储行结构(服务端内部/同步响应共用)
class ConvMessage extends $pb.GeneratedMessage {
  factory ConvMessage({
    $fixnum.Int64? msgId,
    $fixnum.Int64? convId,
    $fixnum.Int64? fromUid,
    $fixnum.Int64? seq,
    $fixnum.Int64? serverTimeMs,
    ConvMsgContent? content,
  }) {
    final result = ConvMessage._();
    if (msgId != null) result.msgId = msgId;
    if (convId != null) result.convId = convId;
    if (fromUid != null) result.fromUid = fromUid;
    if (seq != null) result.seq = seq;
    if (serverTimeMs != null) result.serverTimeMs = serverTimeMs;
    if (content != null) result.content = content;
    return result;
  }

  ConvMessage._();

  factory ConvMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvMessage()..mergeFromBuffer(data, registry);
  factory ConvMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConvMessage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConvMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'yim'),
      createEmptyInstance: ConvMessage.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'msgId')
    ..aInt64(2, _omitFieldNames ? '' : 'convId')
    ..aInt64(3, _omitFieldNames ? '' : 'fromUid')
    ..aInt64(4, _omitFieldNames ? '' : 'seq')
    ..aInt64(5, _omitFieldNames ? '' : 'serverTimeMs')
    ..aOM<ConvMsgContent>(6, _omitFieldNames ? '' : 'content',
        subBuilder: ConvMsgContent.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConvMessage copyWith(void Function(ConvMessage) updates) =>
      super.copyWith((message) => updates(message as ConvMessage))
          as ConvMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConvMessage() / ConvMessage.new instead')
  static ConvMessage create() => ConvMessage._();
  static $pb.GeneratedMessage $_createMessage() => ConvMessage._();
  @$core.override
  ConvMessage createEmptyInstance() => ConvMessage._();
  @$core.pragma('dart2js:noInline')
  static ConvMessage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConvMessage>(
          ConvMessage.$_createMessage);
  static ConvMessage? _defaultInstance;

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
  $fixnum.Int64 get fromUid => $_getI64(2);
  @$pb.TagNumber(3)
  set fromUid($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromUid() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromUid() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get seq => $_getI64(3);
  @$pb.TagNumber(4)
  set seq($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSeq() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeq() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get serverTimeMs => $_getI64(4);
  @$pb.TagNumber(5)
  set serverTimeMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasServerTimeMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearServerTimeMs() => $_clearField(5);

  @$pb.TagNumber(6)
  ConvMsgContent get content => $_getN(5);
  @$pb.TagNumber(6)
  set content(ConvMsgContent value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasContent() => $_has(5);
  @$pb.TagNumber(6)
  void clearContent() => $_clearField(6);
  @$pb.TagNumber(6)
  ConvMsgContent ensureContent() => $_ensure(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');

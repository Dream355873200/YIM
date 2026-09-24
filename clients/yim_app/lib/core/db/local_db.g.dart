// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _msgIdMeta = const VerificationMeta('msgId');
  @override
  late final GeneratedColumn<int> msgId = GeneratedColumn<int>(
    'msg_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _convIdMeta = const VerificationMeta('convId');
  @override
  late final GeneratedColumn<int> convId = GeneratedColumn<int>(
    'conv_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromUidMeta = const VerificationMeta(
    'fromUid',
  );
  @override
  late final GeneratedColumn<int> fromUid = GeneratedColumn<int>(
    'from_uid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMsMeta = const VerificationMeta('timeMs');
  @override
  late final GeneratedColumn<int> timeMs = GeneratedColumn<int>(
    'time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageLocalMeta = const VerificationMeta(
    'imageLocal',
  );
  @override
  late final GeneratedColumn<String> imageLocal = GeneratedColumn<String>(
    'image_local',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _refMsgIdMeta = const VerificationMeta(
    'refMsgId',
  );
  @override
  late final GeneratedColumn<int> refMsgId = GeneratedColumn<int>(
    'ref_msg_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _refTextMeta = const VerificationMeta(
    'refText',
  );
  @override
  late final GeneratedColumn<String> refText = GeneratedColumn<String>(
    'ref_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _revokedMeta = const VerificationMeta(
    'revoked',
  );
  @override
  late final GeneratedColumn<bool> revoked = GeneratedColumn<bool>(
    'revoked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("revoked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    msgId,
    convId,
    fromUid,
    seq,
    timeMs,
    body,
    imageUrl,
    imageLocal,
    refMsgId,
    refText,
    revoked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('msg_id')) {
      context.handle(
        _msgIdMeta,
        msgId.isAcceptableOrUnknown(data['msg_id']!, _msgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_msgIdMeta);
    }
    if (data.containsKey('conv_id')) {
      context.handle(
        _convIdMeta,
        convId.isAcceptableOrUnknown(data['conv_id']!, _convIdMeta),
      );
    } else if (isInserting) {
      context.missing(_convIdMeta);
    }
    if (data.containsKey('from_uid')) {
      context.handle(
        _fromUidMeta,
        fromUid.isAcceptableOrUnknown(data['from_uid']!, _fromUidMeta),
      );
    } else if (isInserting) {
      context.missing(_fromUidMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('time_ms')) {
      context.handle(
        _timeMsMeta,
        timeMs.isAcceptableOrUnknown(data['time_ms']!, _timeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMsMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('image_local')) {
      context.handle(
        _imageLocalMeta,
        imageLocal.isAcceptableOrUnknown(data['image_local']!, _imageLocalMeta),
      );
    }
    if (data.containsKey('ref_msg_id')) {
      context.handle(
        _refMsgIdMeta,
        refMsgId.isAcceptableOrUnknown(data['ref_msg_id']!, _refMsgIdMeta),
      );
    }
    if (data.containsKey('ref_text')) {
      context.handle(
        _refTextMeta,
        refText.isAcceptableOrUnknown(data['ref_text']!, _refTextMeta),
      );
    }
    if (data.containsKey('revoked')) {
      context.handle(
        _revokedMeta,
        revoked.isAcceptableOrUnknown(data['revoked']!, _revokedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {convId, msgId};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      msgId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}msg_id'],
      )!,
      convId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conv_id'],
      )!,
      fromUid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_uid'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      timeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_ms'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      imageLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_local'],
      )!,
      refMsgId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_msg_id'],
      )!,
      refText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_text'],
      )!,
      revoked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}revoked'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int msgId;
  final int convId;
  final int fromUid;
  final int seq;
  final int timeMs;
  final String body;
  final String imageUrl;
  final String imageLocal;
  final int refMsgId;
  final String refText;
  final bool revoked;
  const Message({
    required this.msgId,
    required this.convId,
    required this.fromUid,
    required this.seq,
    required this.timeMs,
    required this.body,
    required this.imageUrl,
    required this.imageLocal,
    required this.refMsgId,
    required this.refText,
    required this.revoked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['msg_id'] = Variable<int>(msgId);
    map['conv_id'] = Variable<int>(convId);
    map['from_uid'] = Variable<int>(fromUid);
    map['seq'] = Variable<int>(seq);
    map['time_ms'] = Variable<int>(timeMs);
    map['body'] = Variable<String>(body);
    map['image_url'] = Variable<String>(imageUrl);
    map['image_local'] = Variable<String>(imageLocal);
    map['ref_msg_id'] = Variable<int>(refMsgId);
    map['ref_text'] = Variable<String>(refText);
    map['revoked'] = Variable<bool>(revoked);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      msgId: Value(msgId),
      convId: Value(convId),
      fromUid: Value(fromUid),
      seq: Value(seq),
      timeMs: Value(timeMs),
      body: Value(body),
      imageUrl: Value(imageUrl),
      imageLocal: Value(imageLocal),
      refMsgId: Value(refMsgId),
      refText: Value(refText),
      revoked: Value(revoked),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      msgId: serializer.fromJson<int>(json['msgId']),
      convId: serializer.fromJson<int>(json['convId']),
      fromUid: serializer.fromJson<int>(json['fromUid']),
      seq: serializer.fromJson<int>(json['seq']),
      timeMs: serializer.fromJson<int>(json['timeMs']),
      body: serializer.fromJson<String>(json['body']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      imageLocal: serializer.fromJson<String>(json['imageLocal']),
      refMsgId: serializer.fromJson<int>(json['refMsgId']),
      refText: serializer.fromJson<String>(json['refText']),
      revoked: serializer.fromJson<bool>(json['revoked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'msgId': serializer.toJson<int>(msgId),
      'convId': serializer.toJson<int>(convId),
      'fromUid': serializer.toJson<int>(fromUid),
      'seq': serializer.toJson<int>(seq),
      'timeMs': serializer.toJson<int>(timeMs),
      'body': serializer.toJson<String>(body),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'imageLocal': serializer.toJson<String>(imageLocal),
      'refMsgId': serializer.toJson<int>(refMsgId),
      'refText': serializer.toJson<String>(refText),
      'revoked': serializer.toJson<bool>(revoked),
    };
  }

  Message copyWith({
    int? msgId,
    int? convId,
    int? fromUid,
    int? seq,
    int? timeMs,
    String? body,
    String? imageUrl,
    String? imageLocal,
    int? refMsgId,
    String? refText,
    bool? revoked,
  }) => Message(
    msgId: msgId ?? this.msgId,
    convId: convId ?? this.convId,
    fromUid: fromUid ?? this.fromUid,
    seq: seq ?? this.seq,
    timeMs: timeMs ?? this.timeMs,
    body: body ?? this.body,
    imageUrl: imageUrl ?? this.imageUrl,
    imageLocal: imageLocal ?? this.imageLocal,
    refMsgId: refMsgId ?? this.refMsgId,
    refText: refText ?? this.refText,
    revoked: revoked ?? this.revoked,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      msgId: data.msgId.present ? data.msgId.value : this.msgId,
      convId: data.convId.present ? data.convId.value : this.convId,
      fromUid: data.fromUid.present ? data.fromUid.value : this.fromUid,
      seq: data.seq.present ? data.seq.value : this.seq,
      timeMs: data.timeMs.present ? data.timeMs.value : this.timeMs,
      body: data.body.present ? data.body.value : this.body,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      imageLocal: data.imageLocal.present
          ? data.imageLocal.value
          : this.imageLocal,
      refMsgId: data.refMsgId.present ? data.refMsgId.value : this.refMsgId,
      refText: data.refText.present ? data.refText.value : this.refText,
      revoked: data.revoked.present ? data.revoked.value : this.revoked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('msgId: $msgId, ')
          ..write('convId: $convId, ')
          ..write('fromUid: $fromUid, ')
          ..write('seq: $seq, ')
          ..write('timeMs: $timeMs, ')
          ..write('body: $body, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageLocal: $imageLocal, ')
          ..write('refMsgId: $refMsgId, ')
          ..write('refText: $refText, ')
          ..write('revoked: $revoked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    msgId,
    convId,
    fromUid,
    seq,
    timeMs,
    body,
    imageUrl,
    imageLocal,
    refMsgId,
    refText,
    revoked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.msgId == this.msgId &&
          other.convId == this.convId &&
          other.fromUid == this.fromUid &&
          other.seq == this.seq &&
          other.timeMs == this.timeMs &&
          other.body == this.body &&
          other.imageUrl == this.imageUrl &&
          other.imageLocal == this.imageLocal &&
          other.refMsgId == this.refMsgId &&
          other.refText == this.refText &&
          other.revoked == this.revoked);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> msgId;
  final Value<int> convId;
  final Value<int> fromUid;
  final Value<int> seq;
  final Value<int> timeMs;
  final Value<String> body;
  final Value<String> imageUrl;
  final Value<String> imageLocal;
  final Value<int> refMsgId;
  final Value<String> refText;
  final Value<bool> revoked;
  final Value<int> rowid;
  const MessagesCompanion({
    this.msgId = const Value.absent(),
    this.convId = const Value.absent(),
    this.fromUid = const Value.absent(),
    this.seq = const Value.absent(),
    this.timeMs = const Value.absent(),
    this.body = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.imageLocal = const Value.absent(),
    this.refMsgId = const Value.absent(),
    this.refText = const Value.absent(),
    this.revoked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required int msgId,
    required int convId,
    required int fromUid,
    required int seq,
    required int timeMs,
    required String body,
    this.imageUrl = const Value.absent(),
    this.imageLocal = const Value.absent(),
    this.refMsgId = const Value.absent(),
    this.refText = const Value.absent(),
    this.revoked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : msgId = Value(msgId),
       convId = Value(convId),
       fromUid = Value(fromUid),
       seq = Value(seq),
       timeMs = Value(timeMs),
       body = Value(body);
  static Insertable<Message> custom({
    Expression<int>? msgId,
    Expression<int>? convId,
    Expression<int>? fromUid,
    Expression<int>? seq,
    Expression<int>? timeMs,
    Expression<String>? body,
    Expression<String>? imageUrl,
    Expression<String>? imageLocal,
    Expression<int>? refMsgId,
    Expression<String>? refText,
    Expression<bool>? revoked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (msgId != null) 'msg_id': msgId,
      if (convId != null) 'conv_id': convId,
      if (fromUid != null) 'from_uid': fromUid,
      if (seq != null) 'seq': seq,
      if (timeMs != null) 'time_ms': timeMs,
      if (body != null) 'body': body,
      if (imageUrl != null) 'image_url': imageUrl,
      if (imageLocal != null) 'image_local': imageLocal,
      if (refMsgId != null) 'ref_msg_id': refMsgId,
      if (refText != null) 'ref_text': refText,
      if (revoked != null) 'revoked': revoked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? msgId,
    Value<int>? convId,
    Value<int>? fromUid,
    Value<int>? seq,
    Value<int>? timeMs,
    Value<String>? body,
    Value<String>? imageUrl,
    Value<String>? imageLocal,
    Value<int>? refMsgId,
    Value<String>? refText,
    Value<bool>? revoked,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      msgId: msgId ?? this.msgId,
      convId: convId ?? this.convId,
      fromUid: fromUid ?? this.fromUid,
      seq: seq ?? this.seq,
      timeMs: timeMs ?? this.timeMs,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      imageLocal: imageLocal ?? this.imageLocal,
      refMsgId: refMsgId ?? this.refMsgId,
      refText: refText ?? this.refText,
      revoked: revoked ?? this.revoked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (msgId.present) {
      map['msg_id'] = Variable<int>(msgId.value);
    }
    if (convId.present) {
      map['conv_id'] = Variable<int>(convId.value);
    }
    if (fromUid.present) {
      map['from_uid'] = Variable<int>(fromUid.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (timeMs.present) {
      map['time_ms'] = Variable<int>(timeMs.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (imageLocal.present) {
      map['image_local'] = Variable<String>(imageLocal.value);
    }
    if (refMsgId.present) {
      map['ref_msg_id'] = Variable<int>(refMsgId.value);
    }
    if (refText.present) {
      map['ref_text'] = Variable<String>(refText.value);
    }
    if (revoked.present) {
      map['revoked'] = Variable<bool>(revoked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('msgId: $msgId, ')
          ..write('convId: $convId, ')
          ..write('fromUid: $fromUid, ')
          ..write('seq: $seq, ')
          ..write('timeMs: $timeMs, ')
          ..write('body: $body, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageLocal: $imageLocal, ')
          ..write('refMsgId: $refMsgId, ')
          ..write('refText: $refText, ')
          ..write('revoked: $revoked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _convIdMeta = const VerificationMeta('convId');
  @override
  late final GeneratedColumn<int> convId = GeneratedColumn<int>(
    'conv_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberUidsMeta = const VerificationMeta(
    'memberUids',
  );
  @override
  late final GeneratedColumn<String> memberUids = GeneratedColumn<String>(
    'member_uids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeqMeta = const VerificationMeta(
    'lastSeq',
  );
  @override
  late final GeneratedColumn<int> lastSeq = GeneratedColumn<int>(
    'last_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unreadMeta = const VerificationMeta('unread');
  @override
  late final GeneratedColumn<int> unread = GeneratedColumn<int>(
    'unread',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _previewMeta = const VerificationMeta(
    'preview',
  );
  @override
  late final GeneratedColumn<String> preview = GeneratedColumn<String>(
    'preview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updateTimeMsMeta = const VerificationMeta(
    'updateTimeMs',
  );
  @override
  late final GeneratedColumn<int> updateTimeMs = GeneratedColumn<int>(
    'update_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    convId,
    type,
    memberUids,
    lastSeq,
    unread,
    preview,
    updateTimeMs,
    name,
    avatar,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conv_id')) {
      context.handle(
        _convIdMeta,
        convId.isAcceptableOrUnknown(data['conv_id']!, _convIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('member_uids')) {
      context.handle(
        _memberUidsMeta,
        memberUids.isAcceptableOrUnknown(data['member_uids']!, _memberUidsMeta),
      );
    } else if (isInserting) {
      context.missing(_memberUidsMeta);
    }
    if (data.containsKey('last_seq')) {
      context.handle(
        _lastSeqMeta,
        lastSeq.isAcceptableOrUnknown(data['last_seq']!, _lastSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeqMeta);
    }
    if (data.containsKey('unread')) {
      context.handle(
        _unreadMeta,
        unread.isAcceptableOrUnknown(data['unread']!, _unreadMeta),
      );
    }
    if (data.containsKey('preview')) {
      context.handle(
        _previewMeta,
        preview.isAcceptableOrUnknown(data['preview']!, _previewMeta),
      );
    }
    if (data.containsKey('update_time_ms')) {
      context.handle(
        _updateTimeMsMeta,
        updateTimeMs.isAcceptableOrUnknown(
          data['update_time_ms']!,
          _updateTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {convId};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      convId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conv_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      memberUids: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_uids'],
      )!,
      lastSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seq'],
      )!,
      unread: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread'],
      )!,
      preview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview'],
      ),
      updateTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}update_time_ms'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final int convId;
  final String type;
  final String memberUids;
  final int lastSeq;
  final int unread;
  final String? preview;
  final int updateTimeMs;
  final String name;
  final String avatar;
  const Conversation({
    required this.convId,
    required this.type,
    required this.memberUids,
    required this.lastSeq,
    required this.unread,
    this.preview,
    required this.updateTimeMs,
    required this.name,
    required this.avatar,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conv_id'] = Variable<int>(convId);
    map['type'] = Variable<String>(type);
    map['member_uids'] = Variable<String>(memberUids);
    map['last_seq'] = Variable<int>(lastSeq);
    map['unread'] = Variable<int>(unread);
    if (!nullToAbsent || preview != null) {
      map['preview'] = Variable<String>(preview);
    }
    map['update_time_ms'] = Variable<int>(updateTimeMs);
    map['name'] = Variable<String>(name);
    map['avatar'] = Variable<String>(avatar);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      convId: Value(convId),
      type: Value(type),
      memberUids: Value(memberUids),
      lastSeq: Value(lastSeq),
      unread: Value(unread),
      preview: preview == null && nullToAbsent
          ? const Value.absent()
          : Value(preview),
      updateTimeMs: Value(updateTimeMs),
      name: Value(name),
      avatar: Value(avatar),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      convId: serializer.fromJson<int>(json['convId']),
      type: serializer.fromJson<String>(json['type']),
      memberUids: serializer.fromJson<String>(json['memberUids']),
      lastSeq: serializer.fromJson<int>(json['lastSeq']),
      unread: serializer.fromJson<int>(json['unread']),
      preview: serializer.fromJson<String?>(json['preview']),
      updateTimeMs: serializer.fromJson<int>(json['updateTimeMs']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String>(json['avatar']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'convId': serializer.toJson<int>(convId),
      'type': serializer.toJson<String>(type),
      'memberUids': serializer.toJson<String>(memberUids),
      'lastSeq': serializer.toJson<int>(lastSeq),
      'unread': serializer.toJson<int>(unread),
      'preview': serializer.toJson<String?>(preview),
      'updateTimeMs': serializer.toJson<int>(updateTimeMs),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String>(avatar),
    };
  }

  Conversation copyWith({
    int? convId,
    String? type,
    String? memberUids,
    int? lastSeq,
    int? unread,
    Value<String?> preview = const Value.absent(),
    int? updateTimeMs,
    String? name,
    String? avatar,
  }) => Conversation(
    convId: convId ?? this.convId,
    type: type ?? this.type,
    memberUids: memberUids ?? this.memberUids,
    lastSeq: lastSeq ?? this.lastSeq,
    unread: unread ?? this.unread,
    preview: preview.present ? preview.value : this.preview,
    updateTimeMs: updateTimeMs ?? this.updateTimeMs,
    name: name ?? this.name,
    avatar: avatar ?? this.avatar,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      convId: data.convId.present ? data.convId.value : this.convId,
      type: data.type.present ? data.type.value : this.type,
      memberUids: data.memberUids.present
          ? data.memberUids.value
          : this.memberUids,
      lastSeq: data.lastSeq.present ? data.lastSeq.value : this.lastSeq,
      unread: data.unread.present ? data.unread.value : this.unread,
      preview: data.preview.present ? data.preview.value : this.preview,
      updateTimeMs: data.updateTimeMs.present
          ? data.updateTimeMs.value
          : this.updateTimeMs,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('convId: $convId, ')
          ..write('type: $type, ')
          ..write('memberUids: $memberUids, ')
          ..write('lastSeq: $lastSeq, ')
          ..write('unread: $unread, ')
          ..write('preview: $preview, ')
          ..write('updateTimeMs: $updateTimeMs, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    convId,
    type,
    memberUids,
    lastSeq,
    unread,
    preview,
    updateTimeMs,
    name,
    avatar,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.convId == this.convId &&
          other.type == this.type &&
          other.memberUids == this.memberUids &&
          other.lastSeq == this.lastSeq &&
          other.unread == this.unread &&
          other.preview == this.preview &&
          other.updateTimeMs == this.updateTimeMs &&
          other.name == this.name &&
          other.avatar == this.avatar);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> convId;
  final Value<String> type;
  final Value<String> memberUids;
  final Value<int> lastSeq;
  final Value<int> unread;
  final Value<String?> preview;
  final Value<int> updateTimeMs;
  final Value<String> name;
  final Value<String> avatar;
  const ConversationsCompanion({
    this.convId = const Value.absent(),
    this.type = const Value.absent(),
    this.memberUids = const Value.absent(),
    this.lastSeq = const Value.absent(),
    this.unread = const Value.absent(),
    this.preview = const Value.absent(),
    this.updateTimeMs = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.convId = const Value.absent(),
    required String type,
    required String memberUids,
    required int lastSeq,
    this.unread = const Value.absent(),
    this.preview = const Value.absent(),
    this.updateTimeMs = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
  }) : type = Value(type),
       memberUids = Value(memberUids),
       lastSeq = Value(lastSeq);
  static Insertable<Conversation> custom({
    Expression<int>? convId,
    Expression<String>? type,
    Expression<String>? memberUids,
    Expression<int>? lastSeq,
    Expression<int>? unread,
    Expression<String>? preview,
    Expression<int>? updateTimeMs,
    Expression<String>? name,
    Expression<String>? avatar,
  }) {
    return RawValuesInsertable({
      if (convId != null) 'conv_id': convId,
      if (type != null) 'type': type,
      if (memberUids != null) 'member_uids': memberUids,
      if (lastSeq != null) 'last_seq': lastSeq,
      if (unread != null) 'unread': unread,
      if (preview != null) 'preview': preview,
      if (updateTimeMs != null) 'update_time_ms': updateTimeMs,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
    });
  }

  ConversationsCompanion copyWith({
    Value<int>? convId,
    Value<String>? type,
    Value<String>? memberUids,
    Value<int>? lastSeq,
    Value<int>? unread,
    Value<String?>? preview,
    Value<int>? updateTimeMs,
    Value<String>? name,
    Value<String>? avatar,
  }) {
    return ConversationsCompanion(
      convId: convId ?? this.convId,
      type: type ?? this.type,
      memberUids: memberUids ?? this.memberUids,
      lastSeq: lastSeq ?? this.lastSeq,
      unread: unread ?? this.unread,
      preview: preview ?? this.preview,
      updateTimeMs: updateTimeMs ?? this.updateTimeMs,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (convId.present) {
      map['conv_id'] = Variable<int>(convId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (memberUids.present) {
      map['member_uids'] = Variable<String>(memberUids.value);
    }
    if (lastSeq.present) {
      map['last_seq'] = Variable<int>(lastSeq.value);
    }
    if (unread.present) {
      map['unread'] = Variable<int>(unread.value);
    }
    if (preview.present) {
      map['preview'] = Variable<String>(preview.value);
    }
    if (updateTimeMs.present) {
      map['update_time_ms'] = Variable<int>(updateTimeMs.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('convId: $convId, ')
          ..write('type: $type, ')
          ..write('memberUids: $memberUids, ')
          ..write('lastSeq: $lastSeq, ')
          ..write('unread: $unread, ')
          ..write('preview: $preview, ')
          ..write('updateTimeMs: $updateTimeMs, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar')
          ..write(')'))
        .toString();
  }
}

abstract class _$YimDb extends GeneratedDatabase {
  _$YimDb(QueryExecutor e) : super(e);
  $YimDbManager get managers => $YimDbManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [messages, conversations];
}

typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required int msgId,
      required int convId,
      required int fromUid,
      required int seq,
      required int timeMs,
      required String body,
      Value<String> imageUrl,
      Value<String> imageLocal,
      Value<int> refMsgId,
      Value<String> refText,
      Value<bool> revoked,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> msgId,
      Value<int> convId,
      Value<int> fromUid,
      Value<int> seq,
      Value<int> timeMs,
      Value<String> body,
      Value<String> imageUrl,
      Value<String> imageLocal,
      Value<int> refMsgId,
      Value<String> refText,
      Value<bool> revoked,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer extends Composer<_$YimDb, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get msgId => $composableBuilder(
    column: $table.msgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get convId => $composableBuilder(
    column: $table.convId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromUid => $composableBuilder(
    column: $table.fromUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageLocal => $composableBuilder(
    column: $table.imageLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refMsgId => $composableBuilder(
    column: $table.refMsgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refText => $composableBuilder(
    column: $table.refText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get revoked => $composableBuilder(
    column: $table.revoked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$YimDb, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get msgId => $composableBuilder(
    column: $table.msgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get convId => $composableBuilder(
    column: $table.convId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromUid => $composableBuilder(
    column: $table.fromUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageLocal => $composableBuilder(
    column: $table.imageLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refMsgId => $composableBuilder(
    column: $table.refMsgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refText => $composableBuilder(
    column: $table.refText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get revoked => $composableBuilder(
    column: $table.revoked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$YimDb, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get msgId =>
      $composableBuilder(column: $table.msgId, builder: (column) => column);

  GeneratedColumn<int> get convId =>
      $composableBuilder(column: $table.convId, builder: (column) => column);

  GeneratedColumn<int> get fromUid =>
      $composableBuilder(column: $table.fromUid, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<int> get timeMs =>
      $composableBuilder(column: $table.timeMs, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get imageLocal => $composableBuilder(
    column: $table.imageLocal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refMsgId =>
      $composableBuilder(column: $table.refMsgId, builder: (column) => column);

  GeneratedColumn<String> get refText =>
      $composableBuilder(column: $table.refText, builder: (column) => column);

  GeneratedColumn<bool> get revoked =>
      $composableBuilder(column: $table.revoked, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$YimDb,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$YimDb, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$YimDb db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> msgId = const Value.absent(),
                Value<int> convId = const Value.absent(),
                Value<int> fromUid = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<int> timeMs = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String> imageLocal = const Value.absent(),
                Value<int> refMsgId = const Value.absent(),
                Value<String> refText = const Value.absent(),
                Value<bool> revoked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                msgId: msgId,
                convId: convId,
                fromUid: fromUid,
                seq: seq,
                timeMs: timeMs,
                body: body,
                imageUrl: imageUrl,
                imageLocal: imageLocal,
                refMsgId: refMsgId,
                refText: refText,
                revoked: revoked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int msgId,
                required int convId,
                required int fromUid,
                required int seq,
                required int timeMs,
                required String body,
                Value<String> imageUrl = const Value.absent(),
                Value<String> imageLocal = const Value.absent(),
                Value<int> refMsgId = const Value.absent(),
                Value<String> refText = const Value.absent(),
                Value<bool> revoked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                msgId: msgId,
                convId: convId,
                fromUid: fromUid,
                seq: seq,
                timeMs: timeMs,
                body: body,
                imageUrl: imageUrl,
                imageLocal: imageLocal,
                refMsgId: refMsgId,
                refText: refText,
                revoked: revoked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$YimDb,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$YimDb, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> convId,
      required String type,
      required String memberUids,
      required int lastSeq,
      Value<int> unread,
      Value<String?> preview,
      Value<int> updateTimeMs,
      Value<String> name,
      Value<String> avatar,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> convId,
      Value<String> type,
      Value<String> memberUids,
      Value<int> lastSeq,
      Value<int> unread,
      Value<String?> preview,
      Value<int> updateTimeMs,
      Value<String> name,
      Value<String> avatar,
    });

class $$ConversationsTableFilterComposer
    extends Composer<_$YimDb, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get convId => $composableBuilder(
    column: $table.convId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberUids => $composableBuilder(
    column: $table.memberUids,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeq => $composableBuilder(
    column: $table.lastSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unread => $composableBuilder(
    column: $table.unread,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preview => $composableBuilder(
    column: $table.preview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updateTimeMs => $composableBuilder(
    column: $table.updateTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$YimDb, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get convId => $composableBuilder(
    column: $table.convId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberUids => $composableBuilder(
    column: $table.memberUids,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeq => $composableBuilder(
    column: $table.lastSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unread => $composableBuilder(
    column: $table.unread,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preview => $composableBuilder(
    column: $table.preview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updateTimeMs => $composableBuilder(
    column: $table.updateTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$YimDb, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get convId =>
      $composableBuilder(column: $table.convId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get memberUids => $composableBuilder(
    column: $table.memberUids,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeq =>
      $composableBuilder(column: $table.lastSeq, builder: (column) => column);

  GeneratedColumn<int> get unread =>
      $composableBuilder(column: $table.unread, builder: (column) => column);

  GeneratedColumn<String> get preview =>
      $composableBuilder(column: $table.preview, builder: (column) => column);

  GeneratedColumn<int> get updateTimeMs => $composableBuilder(
    column: $table.updateTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$YimDb,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (
            Conversation,
            BaseReferences<_$YimDb, $ConversationsTable, Conversation>,
          ),
          Conversation,
          PrefetchHooks Function()
        > {
  $$ConversationsTableTableManager(_$YimDb db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> convId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> memberUids = const Value.absent(),
                Value<int> lastSeq = const Value.absent(),
                Value<int> unread = const Value.absent(),
                Value<String?> preview = const Value.absent(),
                Value<int> updateTimeMs = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> avatar = const Value.absent(),
              }) => ConversationsCompanion(
                convId: convId,
                type: type,
                memberUids: memberUids,
                lastSeq: lastSeq,
                unread: unread,
                preview: preview,
                updateTimeMs: updateTimeMs,
                name: name,
                avatar: avatar,
              ),
          createCompanionCallback:
              ({
                Value<int> convId = const Value.absent(),
                required String type,
                required String memberUids,
                required int lastSeq,
                Value<int> unread = const Value.absent(),
                Value<String?> preview = const Value.absent(),
                Value<int> updateTimeMs = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> avatar = const Value.absent(),
              }) => ConversationsCompanion.insert(
                convId: convId,
                type: type,
                memberUids: memberUids,
                lastSeq: lastSeq,
                unread: unread,
                preview: preview,
                updateTimeMs: updateTimeMs,
                name: name,
                avatar: avatar,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$YimDb,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (
        Conversation,
        BaseReferences<_$YimDb, $ConversationsTable, Conversation>,
      ),
      Conversation,
      PrefetchHooks Function()
    >;

class $YimDbManager {
  final _$YimDb _db;
  $YimDbManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
}

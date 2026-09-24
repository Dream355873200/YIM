// 本地消息库 (drift/sqlite, 里程碑11): 消息与会话列表落盘 —— 聊天窗秒开、
// 离线可看已拉过的历史、未读数不丢。数据可信度以服务端为准, 本地只是缓存:
// 所有写入都来自网络回包或其衍生 (内存态), 从不产生"只有本地有"的事实。
//
// 一账号一库文件 (yim_{uid}.db): 切换账号天然隔离, 登出只关连接不删数据,
// 重新登录秒开历史。清理入口: 系统卸载/清数据。
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../storage/session_store.dart';

part 'local_db.g.dart';

class Messages extends Table {
  IntColumn get msgId => integer()();
  IntColumn get convId => integer()();
  IntColumn get fromUid => integer()();
  IntColumn get seq => integer()();
  IntColumn get timeMs => integer()();
  TextColumn get body => text()(); // 文本内容 (列名避开 drift Table.text 方法)
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  TextColumn get imageLocal => text().withDefault(const Constant(''))();
  IntColumn get refMsgId => integer().withDefault(const Constant(0))(); // 回复引用
  TextColumn get refText => text().withDefault(const Constant(''))();
  BoolColumn get revoked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {convId, msgId};
}

class Conversations extends Table {
  IntColumn get convId => integer()();
  TextColumn get type => text()(); // CONV_SINGLE / CONV_GROUP
  TextColumn get memberUids => text()(); // JSON int list
  IntColumn get lastSeq => integer()();
  IntColumn get unread => integer().withDefault(const Constant(0))();
  TextColumn get preview => text().nullable()();
  IntColumn get updateTimeMs => integer().withDefault(const Constant(0))();
  TextColumn get name => text().withDefault(const Constant(''))(); // 群名
  TextColumn get avatar => text().withDefault(const Constant(''))(); // 群头像 URL

  @override
  Set<Column> get primaryKey => {convId};
}

@DriftDatabase(tables: [Messages, Conversations])
class YimDb extends _$YimDb {
  YimDb(File file)
      : super(LazyDatabase(() async => NativeDatabase.createInBackground(file)));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        // v1→v2: 群聊完整化, conversations 加群名/群头像列
        if (from < 2) {
          await m.addColumn(conversations, conversations.name);
          await m.addColumn(conversations, conversations.avatar);
        }
        // v2→v3: 消息增强, messages 加回复引用列
        if (from < 3) {
          await m.addColumn(messages, messages.refMsgId);
          await m.addColumn(messages, messages.refText);
        }
      });

  // ---- 消息 ----

  /// 某会话最近 limit 条 (旧→新), 秒开首屏用
  Future<List<Message>> newestMessages(int convId, int limit) {
    final q = select(messages)
      ..where((t) => t.convId.equals(convId))
      ..orderBy([(t) => OrderingTerm.desc(t.seq)])
      ..limit(limit);
    return q.get().then((rows) => rows.reversed.toList());
  }

  /// 比 seq 更早的 limit 条 (旧→新), 本地翻页用
  Future<List<Message>> olderThan(int convId, int seq, int limit) {
    final q = select(messages)
      ..where((t) => t.convId.equals(convId) & t.seq.isSmallerThanValue(seq))
      ..orderBy([(t) => OrderingTerm.desc(t.seq)])
      ..limit(limit);
    return q.get().then((rows) => rows.reversed.toList());
  }

  Future<void> upsertMessages(List<MessagesCompanion> rows) async {
    if (rows.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(messages, rows));
  }

  // ---- 会话 ----

  /// 全部会话 (按最后消息时间倒序), 启动秒开列表用
  Future<List<Conversation>> allConversations() {
    final q = select(conversations)
      ..orderBy([(t) => OrderingTerm.desc(t.updateTimeMs)]);
    return q.get();
  }

  Future<void> saveConversations(List<ConversationsCompanion> rows) async {
    if (rows.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(conversations, rows));
  }

  /// 以服务端列表为准全量覆盖 (本地缓存是服务端投影)。
  /// 增量 upsert 会把服务端已不存在的行永久留下 (如账号重建后的幽灵会话)。
  Future<void> replaceConversations(List<ConversationsCompanion> rows) {
    return transaction(() async {
      await delete(conversations).go();
      if (rows.isNotEmpty) {
        await batch(
            (b) => b.insertAllOnConflictUpdate(conversations, rows));
      }
    });
  }

  /// PUSH 到达: 推进水位 + 刷新排序时间 (行不存在则静默, 等网络 reload 落全量)
  Future<void> touchConversation(int convId, int lastSeq) => customUpdate(
      'UPDATE conversations SET last_seq = ?, update_time_ms = ? WHERE conv_id = ?',
      variables: [
        Variable(lastSeq),
        Variable(DateTime.now().millisecondsSinceEpoch),
        Variable(convId)
      ]);

  Future<void> bumpUnread(int convId) => customUpdate(
      'UPDATE conversations SET unread = unread + 1 WHERE conv_id = ?',
      variables: [Variable(convId)]);

  Future<void> setUnread(int convId, int v) => customUpdate(
      'UPDATE conversations SET unread = ? WHERE conv_id = ?',
      variables: [Variable(v), Variable(convId)]);
}

/// 库管理: 按 sessionStore.uid 懒开/换库 (登录后 uid 就绪, get() 前已 setIdentity)。
class LocalDb {
  YimDb? _db;
  int? _uid;

  Future<YimDb> get() async {
    final uid = sessionStore.uid ?? 0;
    if (uid == 0) throw StateError('local db: not logged in');
    if (_db != null && _uid == uid) return _db!;
    await _db?.close();
    _uid = uid;
    final dir = await getApplicationSupportDirectory();
    _db = YimDb(File(p.join(dir.path, 'yim_$uid.db')));
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _uid = null;
  }
}

final localDbProvider = Provider<LocalDb>((ref) {
  final d = LocalDb();
  ref.onDispose(d.close);
  return d;
});

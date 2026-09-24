// 应用状态: Riverpod Notifiers。
// 数据流: 本地库秒开 (消息/会话) + HTTP 首拉合并 + 长连接事件增量 (PUSH→拉增量,
// UP_RSP→发送状态翻转)。本地库只是服务端的缓存投影, 冲突时网络数据覆盖。
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/local_db.dart';
import '../core/network/api.dart';
import '../core/notifications/notification_service.dart';
import '../core/socket/yim_socket.dart';
import '../core/storage/session_store.dart';

// ============================================================
// 模型
// ============================================================

class Profile {
  final int uid;
  final String nickname;
  final String avatar;
  Profile(this.uid, this.nickname, this.avatar);
  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
      G.i(m['uid']), G.s(m['nickname']), G.s(m['avatar']));
  /// uid<=0 的占位 (群聊无对端): 空资料, UI 按"无 profile"渲染
  static final Profile empty = Profile(0, '', '');
}

class ConvItem {
  final int convId;
  final String type; // CONV_SINGLE / CONV_GROUP
  final List<int> memberUids;
  int lastSeq;
  int unread;
  String? preview;
  int lastTimeMs; // 最后消息时间 (本地库排序用)
  final String name; // 群名 (单聊空串, 显示走对端昵称)
  final String avatar; // 群头像相对 URL (单聊空串)
  ConvItem(this.convId, this.type, this.memberUids, this.lastSeq,
      {this.unread = 0,
      this.preview,
      this.lastTimeMs = 0,
      this.name = '',
      this.avatar = ''});

  /// 群显示名 (无群名回退 convId)
  String get groupTitle => name.isNotEmpty ? name : '群聊 $convId';
}

enum MsgStatus { sending, ok, failed }

class ChatMsg {
  final int msgId;
  final int convId;
  final int fromUid;
  final int seq;
  final int timeMs;
  final String text;
  final String imageUrl; // MSG_IMAGE: 相对 URL (/files/img/...)
  final String imageLocal; // 本机发送时: 图片原路径 (渲染优先于 imageUrl)
  final int refMsgId; // 回复引用的目标消息 id (0 = 非回复)
  final String refText; // 引用预览兜底 (本地找不到原消息时显示)
  MsgStatus status;
  final bool revoked;
  // 本地发送消息被确认的时刻 (ms): 成功对勾展示到 settledAtMs+2.5s 后隐藏
  final int settledAtMs;
  ChatMsg(
      {required this.msgId,
      required this.convId,
      required this.fromUid,
      required this.seq,
      required this.timeMs,
      required this.text,
      this.imageUrl = '',
      this.imageLocal = '',
      this.refMsgId = 0,
      this.refText = '',
      this.status = MsgStatus.ok,
      this.revoked = false,
      this.settledAtMs = 0});

  bool get isImage => imageUrl.isNotEmpty || imageLocal.isNotEmpty;
}

// ---- 本地库映射 (ChatMsg ↔ Messages 行): 只落已确认行 (msgId>0),
// sending/failed 的乐观回显是纯内存态, 不持久化 ----
extension ChatMsgDb on ChatMsg {
  MessagesCompanion toRow() => MessagesCompanion.insert(
      msgId: msgId,
      convId: convId,
      fromUid: fromUid,
      seq: seq,
      timeMs: timeMs,
      body: text,
      imageUrl: Value(imageUrl),
      imageLocal: Value(imageLocal),
      refMsgId: Value(refMsgId),
      refText: Value(refText),
      revoked: Value(revoked));
}

ChatMsg chatMsgFromRow(Message r) => ChatMsg(
    msgId: r.msgId,
    convId: r.convId,
    fromUid: r.fromUid,
    seq: r.seq,
    timeMs: r.timeMs,
    text: r.body,
    imageUrl: r.imageUrl,
    imageLocal: r.imageLocal,
    refMsgId: r.refMsgId,
    refText: r.refText,
    revoked: r.revoked);

// ============================================================
// SocketBus: socket 事件 → 各 Notifier 的广播桥
// (family Notifier 生命周期不定, 由各自订阅)
// ============================================================

class SocketBus {
  final _push = StreamController<PushEvent>.broadcast();
  final _upAck = StreamController<UpAckEvent>.broadcast();
  final _kicked = StreamController<KickedEvent>.broadcast();
  final _rel = StreamController<RelationEventNotice>.broadcast();
  final _syncDone = StreamController<void>.broadcast();
  final _state = StreamController<SocketState>.broadcast();
  Stream<PushEvent> get pushes => _push.stream;
  Stream<UpAckEvent> get upAcks => _upAck.stream;
  Stream<KickedEvent> get kicked => _kicked.stream;
  Stream<RelationEventNotice> get relationEvents => _rel.stream;
  /// 每次长连接 SYNC 完成 (首连 + 每次重连): 上层据此以服务端为准重拉
  Stream<void> get syncDone => _syncDone.stream;
  /// 连接状态机变化 (横幅 UI 消费)
  Stream<SocketState> get connStates => _state.stream;
  YimSocket? sock;

  void attach(YimSocket s) {
    sock = s;
    s.events.listen((e) {
      if (e is PushEvent) _push.add(e);
      if (e is UpAckEvent) _upAck.add(e);
      if (e is KickedEvent) _kicked.add(e);
      if (e is RelationEventNotice) _rel.add(e);
      if (e is SyncDoneEvent) _syncDone.add(null);
      if (e is StateEvent) _state.add(e.state);
    });
  }

  void close() {
    sock?.logout();
    sock = null;
    _state.add(SocketState.disconnected);
  }
}

final socketBusProvider = Provider<SocketBus>((ref) {
  final bus = SocketBus();
  ref.onDispose(bus.close);
  return bus;
});

/// 长连接状态 (未登录时 disconnected): 驱动壳层顶部横幅
final connStateProvider = NotifierProvider<ConnStateNotifier, SocketState>(
    ConnStateNotifier.new);

class ConnStateNotifier extends Notifier<SocketState> {
  StreamSubscription? _sub;
  @override
  SocketState build() {
    _sub?.cancel();
    final bus = ref.watch(socketBusProvider);
    _sub = bus.connStates.listen((s) => state = s);
    ref.onDispose(() => _sub?.cancel());
    // 首帧: 取 socket 当前状态, 不等下一次状态变化
    return bus.sock?.state ?? SocketState.disconnected;
  }
}

// ============================================================
// 认证
// ============================================================

enum AuthStatus { boot, loggedOut, loggedIn }

class AuthState {
  final AuthStatus status;
  final int uid;
  final String nickname;
  const AuthState(this.status, {this.uid = 0, this.nickname = ''});
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // 不做静默免登: 打开 App 停在登录页 (记住的账号密码已预填),
    // 用户点"登录"才建会话 —— 静默恢复会让账号失效/换号难以察觉。
    return const AuthState(AuthStatus.loggedOut);
  }

  Future<void> _startSocket(String token, int uid) async {
    final sock = YimSocket(token: token);
    // 重连 SYNC 前由 socket 回调取当前会话水位 (服务端只回差集);
    // 不注入的话空水位 = 近期消息全量重放, 白耗带宽还推一遍旧事件
    sock.watermarkSource = () =>
        {for (final c in ref.read(convListProvider)) c.convId: c.lastSeq};
    ref.read(socketBusProvider).attach(sock);
    await sock.connect(token, uid);
  }

  Future<String?> login(String nick, String pwd) async {
    try {
      final rsp = await Api.I.login(nick, pwd);
      final token = G.s(rsp['token']);
      final uid = G.i(rsp['uid']);
      await sessionStore.setToken(token);
      await sessionStore.setIdentity(uid, nick);
      await sessionStore.setSavedPassword(pwd); // 记住密码: 下次预填一键登录
      state = AsyncData(
          AuthState(AuthStatus.loggedIn, uid: uid, nickname: nick));
      await _startSocket(token, uid);
      ref.read(convListProvider.notifier).reload();
      return null;
    } on UnauthorizedError {
      return '登录已失效, 请重新登录';
    } on ApiError catch (e) {
      return e.msg;
    } catch (e) {
      return '网络错误: $e';
    }
  }

  Future<String?> register(String nick, String pwd) async {
    try {
      await Api.I.register(nick, pwd);
      return await login(nick, pwd);
    } on ApiError catch (e) {
      return e.msg;
    } catch (e) {
      return '网络错误: $e';
    }
  }

  /// 改昵称后同步本地身份缓存
  Future<void> refreshMe(String nickname) async {
    final cur = state.value;
    if (cur == null) return;
    await sessionStore.setIdentity(cur.uid, nickname);
    state = AsyncData(AuthState(AuthStatus.loggedIn,
        uid: cur.uid, nickname: nickname));
  }

  Future<void> logout() async {
    await sessionStore.setToken(null);
    await sessionStore.setSavedPassword(null); // 换号不留凭据
    await sessionStore.clearIdentity();
    ref.read(socketBusProvider).close();
    await ref.read(localDbProvider).close(); // 本地库按账号隔离, 换号自动换库
    ref.read(convListProvider.notifier).reset();
    state = const AsyncData(AuthState(AuthStatus.loggedOut));
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// 当前打开的聊天页 conv_id (未读抑制用)
final currentChatProvider = StateProvider<int>((_) => 0);

// 桌面三栏详情列选中的会话 (0 = 未选中)
final selectedConvProvider = StateProvider<int>((_) => 0);

// ============================================================
// 主题模式 (跟随系统/浅色/深色), SharedPreferences 持久化
// ============================================================

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    switch (sessionStore.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode m) async {
    state = m;
    await sessionStore.setThemeMode(m.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ============================================================
// 会话列表
// ============================================================

class ConvListNotifier extends Notifier<List<ConvItem>> {
  StreamSubscription? _sub;
  StreamSubscription? _evSub;
  StreamSubscription? _syncSub;

  @override
  List<ConvItem> build() {
    _sub?.cancel();
    _sub = ref.read(socketBusProvider).pushes.listen((e) => onPush(e));
    // 群成员变更 → 重拉会话列表 (member_uids 可能变了)
    _evSub?.cancel();
    _evSub = ref.read(socketBusProvider).relationEvents.listen((e) {
      if (e.type == 'GROUP_CHANGED') reload();
    });
    // 长连接 SYNC 完成 (首连/重连) → 重拉列表: 离线期间攒的未读数、
    // 水位、新会话都以服务端为准收敛 (PUSH 只能覆盖在线增量)
    _syncSub?.cancel();
    _syncSub = ref.read(socketBusProvider).syncDone.listen((_) => reload());
    ref.onDispose(() {
      _sub?.cancel();
      _evSub?.cancel();
      _syncSub?.cancel();
    });
    // 秒开: 先读本地库, 网络 reload 到达后覆盖
    Future.microtask(_loadLocal);
    return [];
  }

  Future<void> _loadLocal() async {
    try {
      final db = await ref.read(localDbProvider).get();
      final rows = await db.allConversations();
      if (state.isNotEmpty || rows.isEmpty) return;
      state = [
        for (final r in rows)
          ConvItem(r.convId, r.type,
              (jsonDecode(r.memberUids) as List).cast<int>(), r.lastSeq,
              unread: r.unread,
              preview: r.preview,
              lastTimeMs: r.updateTimeMs,
              name: r.name,
              avatar: r.avatar)
      ];
    } catch (e) {
      debugPrint('load local convs: $e');
    }
  }

  Future<void> reload() async {
    try {
      final rsp = await Api.I.listConversations();
      final old = {for (final c in state) c.convId: c};
      final items = G.l(rsp['conversations']).map((raw) {
        final m = G.m(raw);
        final conv = G.m(m['conv']);
        final id = G.i(conv['conv_id']);
        final last = G.m(m['last_message']);
        final content = G.m(last['content']);
        final item = ConvItem(
            id,
            G.s(conv['type'], 'CONV_SINGLE'),
            G.l(conv['member_uids']).map(G.i).toList(),
            G.i(conv['last_seq']),
            unread: G.i(m['unread_count']),
            preview: content.isEmpty
                ? null
                : (G.s(content['type']) == 'MSG_REVOKE'
                    ? '消息已撤回'
                    : G.s(content['type']) == 'MSG_IMAGE'
                        ? '[图片]'
                        : G.s(content['text'])),
            lastTimeMs: G.i(last['server_time_ms']),
            name: G.s(conv['name']),
            avatar: G.s(conv['avatar']));
        // 本轮内存态未读 (本地累计) 优先于服务端快照;
        // 正在打开的会话强制 0 (用户就在窗里, markRead 在途, 快照是旧的)
        final prev = old[id];
        if (ref.read(currentChatProvider) == id) {
          item.unread = 0;
        } else if (prev != null && prev.unread > item.unread) {
          item.unread = prev.unread;
        }
        return item;
      }).toList();
      state = items;
      _saveLocal(items);
    } catch (e) {
      debugPrint('load convs: $e');
    }
  }

  void _saveLocal(List<ConvItem> items) {
    () async {
      try {
        final db = await ref.read(localDbProvider).get();
        // 全量覆盖而非增量 upsert: 服务端为唯一真值源, 已消失的会话随之清除
        await db.replaceConversations([
          for (final c in items)
            ConversationsCompanion.insert(
                convId: Value(c.convId),
                type: c.type,
                memberUids: jsonEncode(c.memberUids),
                lastSeq: c.lastSeq,
                unread: Value(c.unread),
                preview: Value(c.preview),
                updateTimeMs: Value(c.lastTimeMs),
                name: Value(c.name),
                avatar: Value(c.avatar))
        ]);
      } catch (_) {}
    }();
  }

  void onPush(PushEvent e) {
    final idx = state.indexWhere((c) => c.convId == e.convId);
    if (idx < 0) {
      reload(); // 新会话: 重拉列表
      return;
    }
    final c = state[idx];
    // seq 不超前的一律忽略: 重连 SYNC 若带不上水位, 服务端会重放近期消息,
    // 旧消息重放再计一遍未读 → 每次断线重连未读凭空 +N
    if (e.maxSeq <= c.lastSeq) return;
    c.lastSeq = e.maxSeq;
    c.preview = null; // 聊天窗拉增量后回填
    // 自己发的消息回推不算未读 (发完立刻退出聊天窗时, PUSH 可能晚于 currentChat 清零到达)
    final me = ref.read(authProvider).value?.uid ?? 0;
    final bump = e.fromUid != me && ref.read(currentChatProvider) != e.convId;
    if (bump) {
      c.unread++;
      // 系统通知: 单聊标题取发送者昵称 (缓存 miss 回退泛化文案), 群聊用群名
      final title = c.type == 'CONV_GROUP'
          ? c.groupTitle
          : ref.read(profilesProvider(e.fromUid)).value?.nickname;
      NotificationService.I.showMessage(
          e.convId, (title?.isNotEmpty ?? false) ? title! : '新消息', '发来一条新消息');
    }
    state = [...state];
    // 本地库同步 (best-effort): 水位/排序时间/未读
    () async {
      try {
        final db = await ref.read(localDbProvider).get();
        await db.touchConversation(e.convId, e.maxSeq);
        if (bump) await db.bumpUnread(e.convId);
      } catch (_) {}
    }();
  }

  void setPreview(int convId, String preview) {
    final idx = state.indexWhere((c) => c.convId == convId);
    if (idx >= 0 && state[idx].preview != preview) {
      state[idx].preview = preview;
      state = [...state];
    }
  }

  void clearUnread(int convId) {
    final idx = state.indexWhere((c) => c.convId == convId);
    if (idx >= 0 && state[idx].unread != 0) {
      state[idx].unread = 0;
      state = [...state];
      () async {
        try {
          (await ref.read(localDbProvider).get()).setUnread(convId, 0);
        } catch (_) {}
      }();
    }
  }

  void reset() => state = [];
}

final convListProvider =
    NotifierProvider<ConvListNotifier, List<ConvItem>>(ConvListNotifier.new);

// ============================================================
// 聊天消息 (per-conv)
// ============================================================

class MessagesNotifier extends FamilyNotifier<List<ChatMsg>, int> {
  int get convId => arg;
  StreamSubscription? _pushSub;
  StreamSubscription? _ackSub;
  Timer? _poll; // 兜底轮询: 推送丢失时保证最终一致
  // 会话真实最大 seq (含被投影隐藏的 MSG_REVOKE 行)。已读回执必须报它:
  // 服务端 unread = last_seq - read_seq, 渲染列表 (投影后) 的末条 seq 在
  // 尾部是撤回行时比 last_seq 小 1~2, 报小了未读永远清不掉。
  int _rawMaxSeq = 0;

  void _bumpRawSeq(int seq) {
    if (seq > _rawMaxSeq) _rawMaxSeq = seq;
  }

  @override
  List<ChatMsg> build(int arg) {
    _pushSub?.cancel();
    _ackSub?.cancel();
    _pushSub = ref
        .read(socketBusProvider)
        .pushes
        .where((e) => e.convId == arg)
        .listen((e) => onPush(e));
    _ackSub =
        ref.read(socketBusProvider).upAcks.listen((e) => onUpAck(e));
    ref.onDispose(() {
      _pushSub?.cancel();
      _ackSub?.cancel();
      _poll?.cancel();
    });
    return [];
  }

  Future<void> loadInitial() async {
    // 秒开: 先读本地库 (启动/重开无网络也能看), 再拉网络增量合并覆盖
    try {
      final db = await ref.read(localDbProvider).get();
      final rows = await db.newestMessages(convId, 50);
      if (rows.isNotEmpty && state.isEmpty) {
        final raw = [for (final r in rows) chatMsgFromRow(r)]
          ..sort((a, b) => a.seq.compareTo(b.seq));
        for (final m in raw) {
          _bumpRawSeq(m.seq);
        }
        state = _projectRevocations(raw);
        _startPoll();
      }
    } catch (e) {
      debugPrint('load local history: $e');
    }
    try {
      final rsp = await Api.I.pullHistory(convId, 0, 50);
      final msgs = G.l(rsp['messages']).map(msgFromMap).toList()
        ..sort((a, b) => a.seq.compareTo(b.seq));
      _merge(msgs);
      _persist(msgs);
      _startPoll();
    } catch (e) {
      debugPrint('load history: $e');
    }
  }

  /// 网络回包落库 (只存已确认行, 失败/发送中不落)
  void _persist(List<ChatMsg> msgs) {
    final rows = [for (final m in msgs) if (m.msgId > 0) m.toRow()];
    if (rows.isEmpty) return;
    () async {
      try {
        (await ref.read(localDbProvider).get()).upsertMessages(rows);
      } catch (_) {}
    }();
  }

  void _startPoll() {
    _poll?.cancel();
    _poll =
        Timer.periodic(const Duration(seconds: 15), (_) => pullLatest());
  }

  /// 拉最新增量 (PUSH 到达 / 轮询 / 进入页面)
  Future<void> pullLatest() async {
    try {
      final rsp = await Api.I.pullHistory(convId, 0, 30);
      final msgs = G.l(rsp['messages']).map(msgFromMap).toList();
      _merge(msgs);
      _persist(msgs);
    } catch (_) {}
    // 打开期间持续上报已读: 进窗那次 markRead 若失败/与消息到达竞态,
    // 下一轮轮询补齐, 服务端 unread_count 收敛 0 (列表 reload 不再翻回未读)。
    // 必须以 currentChat 为闸 —— 本 provider 关窗后仍存活, 无条件报已读
    // 会把没看的会话也标成已读。
    if (ref.read(currentChatProvider) == convId) markRead();
  }

  /// 上滑翻页: 本地库优先 (库里有整页就不打网络), 缺口向服务端补。
  /// 返回是否还有更早的。
  Future<bool> loadOlder() async {
    if (state.isEmpty) return false;
    // 本地优先: 库里还有足够一页直接给
    try {
      final db = await ref.read(localDbProvider).get();
      final rows = await db.olderThan(convId, state.first.seq, 50);
      if (rows.isNotEmpty) {
        state = [...rows.map(chatMsgFromRow), ...state];
        if (rows.length >= 50) return true;
        // 库里只剩零头: 先垫上, 再向服务端补齐更早的
      }
    } catch (_) {}
    try {
      final rsp = await Api.I.pullHistory(convId, state.first.seq, 50);
      final older = G.l(rsp['messages']).map(msgFromMap).toList();
      if (older.isEmpty) return false;
      older.sort((a, b) => a.seq.compareTo(b.seq));
      state = [...older, ...state];
      _persist(older);
      return G.b(rsp['has_more']);
    } catch (_) {
      return false;
    }
  }

  void _merge(List<ChatMsg> incoming) {
    if (incoming.isEmpty) return;
    final bySeq = {for (final m in state) m.seq: m};
    for (final m in incoming) {
      final old = bySeq[m.seq];
      // 保留本地 sending 状态 (服务端还没确认的不覆盖)
      if (old != null && old.status == MsgStatus.sending && m.seq >= old.seq) {
        continue;
      }
      bySeq[m.seq] = m;
    }
    final merged = bySeq.values.toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
    for (final m in merged) {
      _bumpRawSeq(m.seq);
    }
    final visible = _projectRevocations(merged);
    state = visible;
    final last = merged.last;
    final preview = last.revoked
        ? '消息已撤回'
        : last.isImage
            ? '[图片]'
            : last.text;
    ref.read(convListProvider.notifier).setPreview(convId, preview);
  }

  /// 撤回投影: 服务端撤回是"追加事实" (一条 seq 更新的 MSG_REVOKE 行)。
  /// 渲染时把事实"回填"到原消息上 —— 原行原地变灰字占位, MSG_REVOKE 行
  /// 本身不渲染 (否则占位符出现在会话底部而非原消息的位置)。
  /// 原行不在拉取窗口内时保留 MSG_REVOKE 行兜底 (尾部灰字)。
  static List<ChatMsg> _projectRevocations(List<ChatMsg> merged) {
    final ids = {for (final m in merged) m.msgId};
    final revokedIds = {
      for (final m in merged)
        if (m.revoked && m.refMsgId > 0) m.refMsgId
    };
    final visible = <ChatMsg>[];
    for (final m in merged) {
      if (m.revoked && m.refMsgId > 0) {
        if (ids.contains(m.refMsgId)) continue; // 原行在窗口内, 已原地变灰
        visible.add(m); // 原行不在窗口: 保留占位
        continue;
      }
      if (revokedIds.contains(m.msgId)) {
        visible.add(ChatMsg(
            msgId: m.msgId,
            convId: m.convId,
            fromUid: m.fromUid,
            seq: m.seq,
            timeMs: m.timeMs,
            text: '',
            imageUrl: m.imageUrl,
            imageLocal: m.imageLocal,
            refMsgId: m.refMsgId,
            refText: m.refText,
            status: m.status,
            revoked: true));
        continue;
      }
      visible.add(m);
    }
    return visible;
  }

  void onPush(PushEvent e) {
    _bumpRawSeq(e.maxSeq); // 撤回行等隐藏事实也要进已读水位
    if (e.maxSeq > (state.isEmpty ? 0 : state.last.seq)) pullLatest();
  }

  /// 确认一条本地消息 (HTTP 回包或 socket UP_RSP 共用): 立即落定真实 seq,
  /// 状态展示 (对勾 1s / 失败叹号) 由 UI 层按 settledAtMs 管理。
  /// 已被另一条路径先落定 → 找不到 pending 行, no-op。
  void _settleLocal(int cmid, int msgId, int seq, {String imageUrl = ''}) {
    final idx = state.indexWhere((m) => -m.msgId == cmid);
    if (idx < 0) return;
    _replaceLocal(cmid, msgId, seq, imageUrl: imageUrl);
  }

  /// 本地回显发送 (乐观插入, HTTP/UP_RSP 先到哪个都翻转状态)
  /// [reply] 非空 = 回复引用: ext.ref_msg_id 指向原消息, refMeta 兜底预览
  Future<void> sendText(String text, {ChatMsg? reply}) async {
    final cmid = _nextCmid();
    final me = ref.read(authProvider).value?.uid ?? 0;
    final optimistic = ChatMsg(
        msgId: -cmid,
        convId: convId,
        fromUid: me,
        seq: 2147483647, // 排最底, UP_RSP 后归位
        timeMs: DateTime.now().millisecondsSinceEpoch,
        text: text,
        refMsgId: reply?.msgId ?? 0,
        refText: reply != null ? _quotePreview(reply) : '',
        status: MsgStatus.sending);
    state = [...state, optimistic];
    try {
      final rsp = await Api.I.sendMessage(cmid, convId, {
        'type': 'MSG_TEXT',
        'text': text,
        if (reply != null)
          'ext': {
            'refMsgId': G.s(reply.msgId),
            // ref_text 是 proto Ext 的强类型字段 (refMeta 不在 proto 里,
            // 会被网关 protojson 丢弃 —— 引用快照必须走 proto 字段才能落库)
            'refText': _quotePreview(reply),
          },
      });
      _settleLocal(cmid, G.i(rsp['msg_id']), G.i(rsp['seq']));
    } catch (_) {
      _failLocal(cmid);
    }
  }

  /// 引用预览: 图片 → [图片], 撤回 → 已撤回, 文本截 60 字
  String _quotePreview(ChatMsg m) {
    if (m.revoked) return '消息已撤回';
    if (m.isImage) return '[图片]';
    final t = m.text.trim();
    return t.length > 60 ? '${t.substring(0, 60)}…' : t;
  }

  /// 图片消息: 乐观插入 (本地图预览) → 上传 → 发 MSG_IMAGE
  Future<void> sendImage(String path) async {
    final cmid = _nextCmid();
    final me = ref.read(authProvider).value?.uid ?? 0;
    final optimistic = ChatMsg(
        msgId: -cmid,
        convId: convId,
        fromUid: me,
        seq: 2147483647,
        timeMs: DateTime.now().millisecondsSinceEpoch,
        text: '',
        imageLocal: path,
        status: MsgStatus.sending);
    state = [...state, optimistic];
    try {
      final up = await Api.I.uploadImage(path);
      final url = G.s(up['url']);
      final rsp = await Api.I.sendMessage(cmid, convId, {
        'type': 'MSG_IMAGE',
        'media': {'url': url, 'size': G.s(up['size'])},
      });
      _settleLocal(cmid, G.i(rsp['msg_id']), G.i(rsp['seq']), imageUrl: url);
    } catch (_) {
      _failLocal(cmid);
    }
  }

  int _nextCmid() =>
      DateTime.now().microsecondsSinceEpoch * 1000 + Random().nextInt(999);

  void _replaceLocal(int cmid, int msgId, int seq, {String imageUrl = ''}) {
    final next = <ChatMsg>[];
    for (final m in state) {
      if (-m.msgId == cmid) {
        next.add(ChatMsg(
            msgId: msgId,
            convId: m.convId,
            fromUid: m.fromUid,
            seq: seq,
            timeMs: m.timeMs,
            text: m.text,
            imageUrl: imageUrl.isNotEmpty ? imageUrl : m.imageUrl,
            imageLocal: m.imageLocal,
            refMsgId: m.refMsgId,
            refText: m.refText,
            status: MsgStatus.ok,
            settledAtMs: DateTime.now().millisecondsSinceEpoch));
      } else {
        next.add(m);
      }
    }
    state = next..sort((a, b) => a.seq.compareTo(b.seq));
    // 已确认行落库 (UP_RSP / HTTP 谁先到都走这里, upsert 幂等)
    _persist([
      for (final m in next)
        if (m.msgId == msgId && m.seq == seq) m
    ]);
  }

  /// 失败消息点击重发: 移除失败行, 按原文重新走发送流程 (图片重传, sha1 幂等)
  Future<void> retry(ChatMsg m) async {
    if (m.status != MsgStatus.failed) return;
    state = [for (final x in state) if (x.msgId != m.msgId) x];
    if (m.isImage && m.imageLocal.isNotEmpty) {
      await sendImage(m.imageLocal);
    } else {
      await sendText(m.text);
    }
  }

  void _failLocal(int cmid) {
    state = [
      for (final m in state)
        if (-m.msgId == cmid)
          ChatMsg(
              msgId: m.msgId,
              convId: m.convId,
              fromUid: m.fromUid,
              seq: m.seq,
              timeMs: m.timeMs,
              text: m.text,
              imageUrl: m.imageUrl,
              imageLocal: m.imageLocal,
              refMsgId: m.refMsgId,
              refText: m.refText,
              status: MsgStatus.failed)
        else
          m
    ];
  }

  /// socket UP_RSP: client_msg_id → 翻转状态 (同样走最小展示时长)
  void onUpAck(UpAckEvent e) {
    final idx = state.indexWhere((m) => -m.msgId == e.clientMsgId);
    if (idx < 0) return;
    _settleLocal(e.clientMsgId, e.msgId, e.seq);
  }

  /// 撤回: 成功返回 null, 失败返回错误文案 (UI 层弹 SnackBar,
  /// 不再静默吞掉 —— "点了没反应"多半就是这里被吞的 400)
  Future<String?> revoke(ChatMsg m) async {
    try {
      await Api.I.revokeMessage(convId, m.msgId);
      pullLatest();
      return null;
    } on ApiError catch (e) {
      return e.msg;
    } catch (_) {
      return '网络错误';
    }
  }

  Future<void> markRead() async {
    // 用原始最大 seq (含被投影隐藏的撤回行), 而非渲染列表末条 ——
    // 否则 unread = last_seq - read_seq 恒 > 0, 未读清不掉
    final seq = _rawMaxSeq > (state.isEmpty ? 0 : state.last.seq)
        ? _rawMaxSeq
        : state.last.seq;
    if (seq <= 0) return;
    try {
      await Api.I.markRead(convId, seq);
    } catch (_) {}
  }
}

ChatMsg msgFromMap(dynamic raw) {
  final m = G.m(raw);
  final content = G.m(m['content']);
  final revoked = G.s(content['type']) == 'MSG_REVOKE';
  final isImage = G.s(content['type']) == 'MSG_IMAGE';
  final ext = G.m(content['ext']);
  // protojson 序列化为 camelCase, 容错手拼的 snake_case
  final refId = G.i(ext['refMsgId']) != 0
      ? G.i(ext['refMsgId'])
      : G.i(ext['ref_msg_id']);
  String refText = '';
  if (refId != 0) {
    refText = G.s(ext['refText']);
    if (refText.isEmpty) refText = G.s(ext['ref_text']);
    // 旧数据兜底: refMeta 快照 (proto 未定义该字段, 仅历史行可能有)
    if (refText.isEmpty) refText = G.s(G.m(ext['refMeta'])['text']);
  }
  return ChatMsg(
      msgId: G.i(m['msg_id']),
      convId: G.i(m['conv_id']),
      fromUid: G.i(m['from_uid']),
      seq: G.i(m['seq']),
      timeMs: G.i(m['server_time_ms']),
      text: revoked ? '' : G.s(content['text']),
      imageUrl: isImage ? G.s(G.m(content['media'])['url']) : '',
      refMsgId: refId,
      refText: refText,
      revoked: revoked);
}

final messagesProvider = NotifierProvider.family<MessagesNotifier,
    List<ChatMsg>, int>(MessagesNotifier.new);

// ============================================================
// 资料 / 在线 / 好友
// ============================================================

class ProfilesNotifier extends FamilyNotifier<AsyncValue<Profile>, int> {
  @override
  AsyncValue<Profile> build(int arg) {
    Future.microtask(() => fetch(arg));
    return const AsyncLoading();
  }

  Future<void> fetch(int uid) async {
    if (uid <= 0) {
      // 群聊等场景会传占位 0 (没有对端 profile), 不发请求直接落定,
      // 否则 GET /users/profiles?uids=0 → 400 → .value 在 build 中重抛
      state = AsyncData(Profile.empty);
      return;
    }
    try {
      final rsp = await Api.I.getProfiles([uid]);
      final list = G.l(rsp['profiles']);
      if (list.isNotEmpty) {
        state = AsyncData(Profile.fromMap(G.m(list.first)));
      } else {
        state = AsyncError('no profile', StackTrace.current);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final profilesProvider = NotifierProvider.family<ProfilesNotifier,
    AsyncValue<Profile>, int>(ProfilesNotifier.new);

class PresenceNotifier extends FamilyNotifier<bool, int> {
  StreamSubscription? _evSub;

  @override
  bool build(int arg) {
    Future.microtask(() => fetch(arg));
    // 在线状态实时: PRESENCE 事件 (uid = 上/下线者)
    _evSub?.cancel();
    _evSub = ref.read(socketBusProvider).relationEvents.listen((e) {
      if (e.type == 'PRESENCE' && e.uid == arg) state = e.online;
    });
    ref.onDispose(() => _evSub?.cancel());
    return false;
  }

  Future<void> fetch(int uid) async {
    try {
      final rsp = await Api.I.getPresence([uid]);
      for (final raw in G.l(rsp['presences'])) {
        final p = G.m(raw);
        if (G.i(p['uid']) == uid) {
          state = G.s(p['presence']).contains('ONLINE');
        }
      }
    } catch (_) {}
  }
}

final presenceProvider =
    NotifierProvider.family<PresenceNotifier, bool, int>(PresenceNotifier.new);

class FriendsNotifier extends Notifier<List<Profile>> {
  StreamSubscription? _evSub;

  @override
  List<Profile> build() {
    Future.microtask(reload);
    // 好友/群事件实时刷新 (里程碑10 推侧): 任何好友类事件都全量重拉,
    // 事件轻量且低频, 换掉"进页才拉"的陈旧补丁
    _evSub?.cancel();
    _evSub = ref.read(socketBusProvider).relationEvents.listen((e) {
      switch (e.type) {
        case 'FRIEND_REQUEST':
        case 'FRIEND_HANDLED':
        case 'FRIEND_DELETED':
          reload();
          ref.read(friendRequestsProvider.notifier).reload();
      }
    });
    ref.onDispose(() => _evSub?.cancel());
    return [];
  }

  Future<void> reload() async {
    try {
      final rsp = await Api.I.listFriends();
      state = G.l(rsp['friends'])
          .map((f) => Profile.fromMap(G.m(f)))
          .toList();
    } catch (e) {
      debugPrint('load friends: $e');
    }
  }
}

final friendsProvider =
    NotifierProvider<FriendsNotifier, List<Profile>>(FriendsNotifier.new);

class FriendRequestsNotifier extends Notifier<List<Map<String, dynamic>>> {
  StreamSubscription? _evSub;

  @override
  List<Map<String, dynamic>> build() {
    Future.microtask(reload);
    // 收到申请 → 角标实时 (FriendsNotifier 的订阅也会连带重拉, 双保险幂等)
    _evSub?.cancel();
    _evSub = ref.read(socketBusProvider).relationEvents.listen((e) {
      if (e.type == 'FRIEND_REQUEST') reload();
    });
    ref.onDispose(() => _evSub?.cancel());
    return [];
  }

  Future<void> reload() async {
    try {
      final rsp = await Api.I.listFriendRequests(incoming: true);
      state = G.l(rsp['requests'])
          .map(G.m)
          .where((r) => G.i(r['status']) == 0)
          .toList();
    } catch (e) {
      debugPrint('load friend requests: $e');
    }
  }

  Future<String?> handle(int fromUid, bool accept) async {
    try {
      await Api.I.handleFriendRequest(fromUid, accept);
      await reload();
      ref.read(friendsProvider.notifier).reload();
      return null;
    } on ApiError catch (e) {
      return e.msg;
    }
  }
}

final friendRequestsProvider = NotifierProvider<FriendRequestsNotifier,
    List<Map<String, dynamic>>>(FriendRequestsNotifier.new);

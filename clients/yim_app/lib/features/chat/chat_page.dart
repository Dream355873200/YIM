// 聊天窗: 气泡流 (seq 排序, 连续消息合并), 发送状态 (时钟/双勾/已读/红叹号),
// 进入 MarkRead, 上滑翻页, 长按撤回/回复, 回复引用气泡, 输入中提示,
// 输入栏圆角 + 主色发送钮。
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../core/network/api.dart';
import '../../core/shell/app_shell.dart' show Avatar;
import '../../core/theme/app_theme.dart';

class ChatPage extends ConsumerStatefulWidget {
  final int convId;
  final bool embedded; // 桌面三栏内嵌 (无 AppBar 返回键)
  const ChatPage({super.key, required this.convId, required this.embedded});
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _loadingOlder = false;
  // initState 捕获 (dispose 中 ref 不可用, 只能用它做退出清理)
  StateController<int>? _currentChatCtrl;
  // 回复引用: 长按气泡设置, 发送/取消后清空
  ChatMsg? _reply;
  // 输入中提示 (对端 TYPING 事件): 展示到 _typingUntil
  DateTime? _typingUntil;
  Timer? _typingTimer;
  StreamSubscription? _evSub;
  int _peerReadSeq = 0; // 对端已读水位 (READ 回执, 会话级)
  Timer? _readPoll; // 对端已读兜底复查 (READ 瞬态事件丢失时)
  DateTime? _lastTypingSent; // 输入节流

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      _currentChatCtrl = ref.read(currentChatProvider.notifier);
      _currentChatCtrl!.state = widget.convId;
      ref.read(convListProvider.notifier).clearUnread(widget.convId);
      final n = ref.read(messagesProvider(widget.convId).notifier);
      // 已有内存缓存 → 只拉增量不整表重灌 (重开页面不闪烁)
      if (ref.read(messagesProvider(widget.convId)).isEmpty) {
        n.loadInitial();
      } else {
        n.pullLatest();
      }
      n.markRead();
      // 进窗拉对端已读水位 (READ 事件只有实时那条, 对端先读过的没事件):
      // 单聊取对端 read_seq 铺底, 群聊不显示已读 (服务端也不发群 READ 事件)
      await _fetchPeerRead();
      // READ 瞬态信令即发即弃: 丢了的话对端已读只能等重进窗。这里 5s 兜底
      // 复查, 只在"对端落后于我的最新已确认消息"时才真正发请求。
      _readPoll = Timer.periodic(const Duration(seconds: 5), (_) async {
        if (!mounted) return;
        final me = ref.read(authProvider).value?.uid ?? 0;
        ChatMsg? lastMine;
        for (final m in ref.read(messagesProvider(widget.convId))) {
          if (m.fromUid == me && m.status == MsgStatus.ok) lastMine = m;
        }
        if (lastMine == null || lastMine.seq <= _peerReadSeq) return;
        await _fetchPeerRead();
      });
      // 进窗重查对方在线状态 (presence family 缓存可能已陈旧)
      final me = ref.read(authProvider).value?.uid ?? 0;
      for (final c in ref.read(convListProvider)) {
        if (c.convId != widget.convId || c.type == 'CONV_GROUP') continue;
        final peer =
            c.memberUids.firstWhere((u) => u != me, orElse: () => 0);
        if (peer > 0) ref.read(presenceProvider(peer).notifier).fetch(peer);
      }
    });
    _scroll.addListener(_onScroll);
    // 瞬态信令 (里程碑12): 输入中 / 已读回执 (只关心本会话、非本人)
    Future.microtask(() {
      if (!mounted) return;
      _evSub = ref.read(socketBusProvider).relationEvents.listen((e) {
        if (!mounted || e.convId != widget.convId) return;
        final me = ref.read(authProvider).value?.uid ?? 0;
        if (e.uid == me) return;
        if (e.type == 'TYPING') {
          setState(() =>
              _typingUntil = DateTime.now().add(const Duration(seconds: 3)));
          _typingTimer?.cancel();
          _typingTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => _typingUntil = null);
          });
        } else if (e.type == 'READ' && e.seq > _peerReadSeq) {
          setState(() => _peerReadSeq = e.seq);
        }
      });
    });
  }

  /// 拉取对端已读水位 (GetReadState): 单聊 only, 群聊直接返回。
  /// READ 瞬态事件只覆盖 MarkRead 那一刻, 进窗铺底 / 丢事件兜底都靠这里。
  Future<void> _fetchPeerRead() async {
    final me = ref.read(authProvider).value?.uid ?? 0;
    final isSingle = ref.read(convListProvider).any(
        (c) => c.convId == widget.convId && c.type == 'CONV_SINGLE');
    if (!isSingle) return;
    try {
      final rsp = await Api.I.getReadStates(widget.convId);
      var maxPeerSeq = 0;
      for (final raw in G.l(rsp['states'])) {
        final st = G.m(raw);
        if (G.i(st['uid']) != me) {
          final seq = G.i(st['read_seq']);
          if (seq > maxPeerSeq) maxPeerSeq = seq;
        }
      }
      if (mounted && maxPeerSeq > _peerReadSeq) {
        setState(() => _peerReadSeq = maxPeerSeq);
      }
    } catch (_) {}
  }

  /// 输入变化 → 节流 2s 发 CMD_TYPING (即发即弃)
  void _onInputChanged() {
    if (_input.text.trim().isEmpty) return;
    final now = DateTime.now();
    if (_lastTypingSent != null &&
        now.difference(_lastTypingSent!) < const Duration(seconds: 2)) {
      return;
    }
    _lastTypingSent = now;
    ref.read(socketBusProvider).sock?.sendTyping(widget.convId);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    // dispose/unmount 阶段 ref 已不可用 → 延迟一帧再清 (此时订阅已解绑, 不炸)
    final ctrl = _currentChatCtrl;
    if (ctrl != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ctrl.state == widget.convId) ctrl.state = 0;
      });
    }
    _evSub?.cancel();
    _readPoll?.cancel();
    _typingTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 40 &&
        !_loadingOlder) {
      _loadingOlder = true;
      ref
          .read(messagesProvider(widget.convId).notifier)
          .loadOlder()
          .whenComplete(() => _loadingOlder = false);
    }
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    final reply = _reply;
    setState(() => _reply = null);
    ref
        .read(messagesProvider(widget.convId).notifier)
        .sendText(text, reply: reply);
  }

  Future<void> _pickAndSendImage() async {
    // 压缩到长边 ~1920 / 85 分辨率质量: 聊天图无需原图, 手机随手一张 5MB 直传太亏
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1920, imageQuality: 85);
    if (x == null) return;
    ref.read(messagesProvider(widget.convId).notifier).sendImage(x.path);
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(messagesProvider(widget.convId));
    final me = ref.watch(authProvider).value?.uid ?? 0;
    final convs = ref.watch(convListProvider);
    ConvItem? conv;
    for (final c in convs) {
      if (c.convId == widget.convId) {
        conv = c;
        break;
      }
    }
    final peer = conv != null && conv.type != 'CONV_GROUP'
        ? conv.memberUids.firstWhere((u) => u != me, orElse: () => 0)
        : 0;
    final profile = peer > 0 ? ref.watch(profilesProvider(peer)).value : null;
    final online = peer > 0 ? ref.watch(presenceProvider(peer)) : false;

    final isGroup = conv?.type == 'CONV_GROUP';
    final title = isGroup
        ? (conv?.groupTitle ?? '群聊')
        : (profile?.nickname ?? '…');
    final headerAvatar = isGroup ? (conv?.avatar ?? '') : (profile?.avatar ?? '');
    final typing =
        !isGroup && _typingUntil != null && _typingUntil!.isAfter(DateTime.now());
    String subtitleOf() => isGroup
        ? '群聊'
        : (typing ? '对方正在输入…' : (online ? '在线' : '离线'));

    final body = Column(
      children: [
        Expanded(
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? YimColors.chatBgDark
                : YimColors.chatBgLight,
            child: ListView.builder(
              controller: _scroll,
              reverse: true, // 底部锚定: 打开即最新一条, 新消息免跳滚, 重开不闪
              padding: const EdgeInsets.symmetric(
                  vertical: YimSpacing.l, horizontal: YimSpacing.l),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                // msgs 按 seq 升序; reverse 视图 i=0 = 最新 (贴底)
                final m = msgs[msgs.length - 1 - i];
                final above =
                    i + 1 < msgs.length ? msgs[msgs.length - 2 - i] : null;
                final grouped = above != null &&
                    above.fromUid == m.fromUid &&
                    !m.revoked &&
                    !above.revoked &&
                    m.timeMs - above.timeMs < 3 * 60 * 1000;
                return _Bubble(
                    msg: m,
                    mine: m.fromUid == me,
                    grouped: grouped,
                    isGroup: conv?.type == 'CONV_GROUP',
                    peerReadSeq: _peerReadSeq,
                    onReply: () => setState(() => _reply = m));
              },
            ),
          ),
        ),
        _InputBar(
            controller: _input,
            onSend: _send,
            onPickImage: _pickAndSendImage,
            onChanged: _onInputChanged,
            reply: _reply,
            onCancelReply: () => setState(() => _reply = null)),
      ],
    );

    if (widget.embedded) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _ChatHeader(
              title: title,
              subtitle: subtitleOf(),
              peer: peer,
              nickname: profile?.nickname ?? '',
              avatar: headerAvatar,
              isGroup: isGroup,
              convId: widget.convId),
        ),
        body: body,
      );
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _ChatHeaderInner(
            title: title,
            subtitle: subtitleOf(),
            peer: peer,
            nickname: profile?.nickname ?? '',
            avatar: headerAvatar,
            isGroup: isGroup,
            convId: widget.convId),
      ),
      body: body,
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final String title, subtitle, nickname, avatar;
  final int peer, convId;
  final bool isGroup;
  const _ChatHeader(
      {required this.title,
      required this.subtitle,
      required this.peer,
      required this.nickname,
      required this.avatar,
      required this.isGroup,
      required this.convId});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: _ChatHeaderInner(
          title: title,
          subtitle: subtitle,
          peer: peer,
          nickname: nickname,
          avatar: avatar,
          isGroup: isGroup,
          convId: convId),
    );
  }
}

class _ChatHeaderInner extends StatelessWidget {
  final String title, subtitle, nickname, avatar;
  final int peer, convId;
  final bool isGroup;
  const _ChatHeaderInner(
      {required this.title,
      required this.subtitle,
      required this.peer,
      required this.nickname,
      required this.avatar,
      required this.isGroup,
      required this.convId});
  @override
  Widget build(BuildContext context) {
    // 左侧留白: 避免头像紧贴与列表列的分隔线 (titleSpacing 0 时的默认贴边)
    return Padding(
      padding: const EdgeInsets.only(
          left: YimSpacing.l, right: YimSpacing.s),
      child: Row(
        children: [
          if (!isGroup && peer > 0)
            Avatar(uid: peer, nickname: nickname, avatar: avatar, size: 36)
          else
            Avatar(
                uid: convId,
                nickname: title.isNotEmpty ? title : '群',
                avatar: avatar,
                size: 36),
          const SizedBox(width: YimSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(subtitle,
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          if (isGroup)
            IconButton(
                tooltip: '群管理',
                onPressed: () => context.push('/groups/$convId/manage'),
                icon: const Icon(Icons.more_horiz)),
        ],
      ),
    );
  }
}

class _Bubble extends ConsumerWidget {
  final ChatMsg msg;
  final bool mine;
  final bool grouped; // 同发送者连续消息的后续条
  final bool isGroup;
  final int peerReadSeq; // 对端已读水位 (READ 回执)
  final VoidCallback onReply; // 长按/右键 → 引用回复
  const _Bubble(
      {required this.msg,
      required this.mine,
      required this.grouped,
      required this.isGroup,
      required this.peerReadSeq,
      required this.onReply});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Row 给子级的是无界宽度, 气泡上限必须在行根取真实约束
    // (挂在 Row 内时 LayoutBuilder 拿到 ∞ 走 320 兜底 → 手机窄屏溢出)
    return LayoutBuilder(builder: (context, cons) {
      final avail = cons.maxWidth.isFinite ? cons.maxWidth : 360.0;
      double maxW = (avail - 44) * 0.75; // 扣头像 36 + 间距 8
      if (maxW > 380) maxW = 380; // 宽屏封顶, 免得气泡拉满一整行
      return _body(context, ref, maxW);
    });
  }

  Widget _body(BuildContext context, WidgetRef ref, double bubbleMax) {
    // 群聊发送者名: 按消息的 fromUid 查资料 (单聊不需要, 撤回提示也用它)
    final senderName = ref.watch(profilesProvider(msg.fromUid)).value?.nickname ??
        'uid ${msg.fromUid}';
    if (msg.revoked) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: YimSpacing.xs),
        child: Center(
            child: Text(mine ? '你撤回了一条消息' : '$senderName 撤回了一条消息',
                style: Theme.of(context).textTheme.labelSmall)),
      );
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = mine
        ? (dark ? YimColors.myBubbleDark : YimColors.myBubbleLight)
        : (dark ? YimColors.otherBubbleDark : YimColors.otherBubbleLight);
    // 我方气泡: 浅色 = accent 实底白字; 深色 = 亮 accent 上黑字 (Fluent 惯例)
    final textColor = mine
        ? (dark ? YimColors.onAccentDark : Colors.white)
        : Theme.of(context).textTheme.bodyMedium!.color ??
            YimColors.textLight;
    // 气泡全靠填充分层: 我方 accent 实底, 对方白卡 — 无描边灰线
    final borderColor = Colors.transparent;

    // 气泡宽度上限 = build 根部按真实行宽算出的 bubbleMax
    // 回复引用 (里程碑12): 引用条渲染在气泡体内, 左侧 accent 竖线
    Widget bubble = msg.isImage
        ? _ImageBubble(msg: msg, maxW: bubbleMax)
        : Container(
            constraints: BoxConstraints(maxWidth: bubbleMax),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: bubbleColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(YimRadius.bubble),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.refMsgId > 0)
                    Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: (mine
                                    ? (dark ? Colors.black : Colors.white)
                                    : YimColors.primary)
                                .withValues(alpha: 0.08),
                            border: Border(
                                left: BorderSide(
                                    width: 2,
                                    color: mine
                                        ? textColor.withValues(alpha: 0.5)
                                        : YimColors.primary))),
                        child: Text(msg.refText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: textColor.withValues(alpha: 0.75)))),
                  Text(msg.text,
                      style: TextStyle(
                          color: textColor, fontSize: 15, height: 1.35)),
                ]),
          );

    // 布局: 头像槽每条都渲染 (微信式, 显示恒定), 槽宽固定保证气泡边线对齐。
    final avatarSlot = SizedBox(
      width: 36,
      height: 36,
      child: mine
          ? const _MeAvatar()
          : GestureDetector(
              onTap: () => context.push('/users/${msg.fromUid}'),
              child: _PeerAvatar(uid: msg.fromUid),
            ),
    );

    final bubbleArea = Column(
      crossAxisAlignment:
          mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 群聊: 组内首条显示发送者名
        if (isGroup && !mine && !grouped)
          Padding(
            padding: const EdgeInsets.only(left: YimSpacing.xs, bottom: 2),
            child: Text(senderName,
                style: Theme.of(context).textTheme.labelSmall),
          ),
        GestureDetector(
          // QQ 式浮层菜单: 长按/右键都在按压位置弹出 (复制/回复/撤回),
          // 不再用底部抽屉 —— 抽屉打断视线且与桌面右键行为不一致
          onLongPressStart: (d) => _bubbleMenu(context, ref, d.globalPosition),
          onSecondaryTapUp: (d) => _bubbleMenu(context, ref, d.globalPosition),
          child: bubble,
        ),
      ],
    );

    // 双方结构对称: 头像与气泡首行顶对齐, 行下方均预留等高状态槽
    // (我方 16px 内放发送状态, 对方空占位) → 左右节奏一致, 图标出现/消失不跳动
    final row = mine
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bubbleArea,
                  const SizedBox(width: YimSpacing.s),
                  avatarSlot,
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 44),
                child: SizedBox(
                  height: 14,
                  child: _SendStatus(
                      msg: msg,
                      read: mine && !isGroup && msg.seq <= peerReadSeq,
                      onRetry: () => ref
                          .read(messagesProvider(msg.convId).notifier)
                          .retry(msg)),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatarSlot,
                  const SizedBox(width: YimSpacing.s),
                  bubbleArea,
                ],
              ),
              const SizedBox(height: 16), // 对称空槽 (2 top + 14 = 我方状态槽高)
            ],
          );
    return Padding(
      padding: const EdgeInsets.only(top: YimSpacing.m),
      child: row,
    );
  }

  bool get _canRevoke =>
      mine &&
      !msg.revoked &&
      DateTime.now().millisecondsSinceEpoch - msg.timeMs < 2 * 60 * 1000;

  /// 长按/右键 → 按压位置弹浮层菜单 (QQ 式): 复制 / 回复 / 撤回 (2 分钟内)。
  /// 图片消息没有"复制"。
  void _bubbleMenu(BuildContext context, WidgetRef ref, Offset pos) {
    final canRevoke = _canRevoke;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 1, pos.dy + 1),
      items: [
        if (msg.text.isNotEmpty)
          const PopupMenuItem(
              value: 'copy',
              height: 36,
              child: Text('复制', style: TextStyle(fontSize: 13))),
        const PopupMenuItem(
            value: 'reply',
            height: 36,
            child: Text('回复', style: TextStyle(fontSize: 13))),
        if (canRevoke)
          const PopupMenuItem(
              value: 'revoke',
              height: 36,
              child: Text('撤回', style: TextStyle(fontSize: 13))),
      ],
    ).then((v) {
      if (!context.mounted || v == null) return;
      switch (v) {
        case 'copy':
          Clipboard.setData(ClipboardData(text: msg.text));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('已复制'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(milliseconds: 800)));
        case 'reply':
          onReply();
        case 'revoke':
          _doRevoke(context, ref);
      }
    });
  }

  Future<void> _doRevoke(BuildContext context, WidgetRef ref) async {
    final err = await ref
        .read(messagesProvider(msg.convId).notifier)
        .revoke(msg);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('撤回失败: $err'),
          behavior: SnackBarBehavior.floating));
    }
  }

  /// 桌面右键与手机长按已统一走 _bubbleMenu (按压位置浮层菜单)
}

// 图片消息气泡: 本机发送优先渲染本地文件 (上传完成前), 否则按相对 URL 补全网络图。
// 点击全屏查看 (黑底 + InteractiveViewer 缩放)。
class _ImageBubble extends StatelessWidget {
  final ChatMsg msg;
  final double maxW;
  const _ImageBubble({required this.msg, required this.maxW});
  @override
  Widget build(BuildContext context) {
    final w = maxW.clamp(120.0, 320.0);
    Widget img;
    if (msg.imageLocal.isNotEmpty) {
      // 本地路径来自 image_picker 临时目录, 持久化行可能已失效 → 回退网络图
      img = Image.file(File(msg.imageLocal),
          fit: BoxFit.cover,
          width: w,
          cacheWidth: (w * 2).toInt(), // 2x 像素密度
          errorBuilder: (_, __, ___) => _netImg(w));
    } else {
      img = _netImg(w);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(YimRadius.bubble),
      child: GestureDetector(
        onTap: () => showImageViewer(context, msg),
        child: img,
      ),
    );
  }

  Widget _netImg(double w) => Image.network(Api.fileUrl(msg.imageUrl),
      fit: BoxFit.cover,
      width: w,
      cacheWidth: (w * 2).toInt(),
      loadingBuilder: (_, child, progress) {
    if (progress == null || progress.expectedTotalBytes == null ||
        progress.cumulativeBytesLoaded == progress.expectedTotalBytes) {
      return child;
    }
    return SizedBox(
        width: w,
        height: 160,
        child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2)));
  },
      errorBuilder: (_, __, ___) => _broken(w));

  Widget _broken(double w) => Container(
      width: w,
      height: 120,
      color: const Color(0x33888888),
      child: const Center(child: Icon(Icons.broken_image_outlined, size: 32)));
}

/// 全屏图片查看: 点任意处关闭, 可缩放拖动
void showImageViewer(BuildContext context, ChatMsg msg) {
  final img = msg.imageLocal.isNotEmpty
      ? Image.file(File(msg.imageLocal),
          errorBuilder: (_, __, ___) =>
              Image.network(Api.fileUrl(msg.imageUrl)))
      : Image.network(Api.fileUrl(msg.imageUrl));
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: InteractiveViewer(
        maxScale: 4,
        child: Center(child: img),
      ),
    ),
  );
}

class _MeAvatar extends ConsumerWidget {
  const _MeAvatar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).value;
    final profile = me != null && me.uid > 0
        ? ref.watch(profilesProvider(me.uid)).value
        : null;
    return Avatar(uid: me?.uid ?? 0, nickname: me?.nickname ?? '?',
        avatar: profile?.avatar ?? '', size: 36);
  }
}

class _PeerAvatar extends ConsumerWidget {
  final int uid;
  const _PeerAvatar({required this.uid});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profilesProvider(uid)).value;
    return Avatar(uid: uid, nickname: p?.nickname ?? '?',
        avatar: p?.avatar ?? '', size: 36);
  }
}

// 发送状态 (气泡外右下角):
//   sending → 在途 1s 内不显示 (正常发送很快); 超过 1s 升级为转圈 (慢网/重试)
//   ok      → 对勾展示 1s 后消失 (settledAtMs 起算)
//   failed  → 红叹号常驻, 点击重发
class _SendStatus extends StatefulWidget {
  final ChatMsg msg;
  final VoidCallback onRetry;
  final bool read; // 对端已读 (READ 回执) → '已读' 替代对勾
  const _SendStatus(
      {required this.msg, required this.onRetry, this.read = false});
  @override
  State<_SendStatus> createState() => _SendStatusState();
}

class _SendStatusState extends State<_SendStatus> {
  static const _spinnerAfter = Duration(milliseconds: 1000);
  static const _okHold = Duration(milliseconds: 1000);
  Timer? _timer;
  bool _spinner = false;
  bool _check = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_SendStatus old) {
    super.didUpdateWidget(old);
    if (old.msg != widget.msg) _sync();
  }

  void _sync() {
    _timer?.cancel();
    _timer = null;
    _spinner = false;
    _check = false;
    switch (widget.msg.status) {
      case MsgStatus.sending:
        _timer = Timer(_spinnerAfter, () {
          if (mounted) setState(() => _spinner = true);
        });
        break;
      case MsgStatus.ok:
        final remain = widget.msg.settledAtMs +
            _okHold.inMilliseconds -
            DateTime.now().millisecondsSinceEpoch;
        if (widget.msg.settledAtMs > 0 && remain > 0) {
          _check = true;
          _timer = Timer(Duration(milliseconds: remain), () {
            if (mounted) setState(() => _check = false);
          });
        }
        break;
      case MsgStatus.failed:
        break; // 常驻, 点击重试
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dim = Theme.of(context).textTheme.bodySmall?.color;
    if (widget.msg.status == MsgStatus.failed) {
      return Tooltip(
        message: '发送失败, 点击重发',
        child: GestureDetector(
          onTap: widget.onRetry,
          child: const Icon(Icons.error_outline,
              size: 14, color: YimColors.danger),
        ),
      );
    }
    if (widget.msg.status == MsgStatus.ok && widget.read) {
      return Text('已读',
          style: TextStyle(fontSize: 11, color: dim));
    }
    if (widget.msg.status == MsgStatus.ok && _check) {
      return Icon(Icons.done_all, size: 13, color: dim);
    }
    if (widget.msg.status == MsgStatus.sending && _spinner) {
      return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: dim));
    }
    return const SizedBox.shrink();
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onChanged; // 文本变化 → typing 节流发信令
  final ChatMsg? reply; // 回复引用预览条 (null = 无)
  final VoidCallback onCancelReply;
  const _InputBar(
      {required this.controller,
      required this.onSend,
      required this.onPickImage,
      required this.onChanged,
      required this.reply,
      required this.onCancelReply});
  @override
  Widget build(BuildContext context) {
    final me = reply != null; // 回复条占位
    return Container(
      padding: EdgeInsets.fromLTRB(YimSpacing.m, me ? 0 : YimSpacing.m,
          YimSpacing.m, YimSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
            top: BorderSide(color: Theme.of(context).dividerTheme.color!)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (reply != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('回复消息',
                          style: TextStyle(
                              fontSize: 12, color: YimColors.accentText)),
                      const SizedBox(height: 2),
                      Text(
                          reply!.revoked
                              ? '消息已撤回'
                              : (reply!.isImage
                                  ? '[图片]'
                                  : (reply!.text.trim().isEmpty
                                      ? '[消息]'
                                      : reply!.text)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
              ),
              IconButton(
                  tooltip: '取消回复',
                  visualDensity: VisualDensity.compact,
                  onPressed: onCancelReply,
                  icon: const Icon(Icons.close, size: 18)),
            ]),
          ),
        Row(
        children: [
          IconButton(
            tooltip: '发送图片',
            onPressed: onPickImage,
            icon: const Icon(Icons.image_outlined, size: 22),
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onChanged: (_) => onChanged(),
              onSubmitted: (_) => onSend(),
              decoration:
                  const InputDecoration(hintText: '输入消息…'),
            ),
          ),
          const SizedBox(width: YimSpacing.m),
          _SendButton(controller: controller, onSend: onSend),
        ],
        ),
      ]),
    );
  }
}

class _SendButton extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _SendButton({required this.controller, required this.onSend});
  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _hasText = false;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  void _changed() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: _hasText ? widget.onSend : null,
      icon: const Icon(Icons.arrow_upward, size: 20),
      style: IconButton.styleFrom(
        backgroundColor:
            _hasText ? YimColors.primary : Theme.of(context).dividerTheme.color,
      ),
    );
  }
}

// 时间格式化备用 (会话外时间分隔用)
String fmtTime(int ms) =>
    DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(ms));

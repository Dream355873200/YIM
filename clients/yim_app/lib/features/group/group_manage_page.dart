// 群资料页: 群名/群头像 (群主可改) + 成员列表 (role 徽标) / 拉人 / 踢人 (owner) / 退群。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_state.dart';
import '../../core/network/api.dart';
import '../../core/shell/app_shell.dart' show Avatar;
import '../../core/theme/app_theme.dart';

class GroupManagePage extends ConsumerStatefulWidget {
  final int convId;
  const GroupManagePage({super.key, required this.convId});
  @override
  ConsumerState<GroupManagePage> createState() => _GroupManagePageState();
}

class _GroupManagePageState extends ConsumerState<GroupManagePage> {
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;
  String? _error;

  /// 会话元数据 (群名/群头像), convListProvider 驱动
  ConvItem? get _conv {
    for (final c in ref.read(convListProvider)) {
      if (c.convId == widget.convId) return c;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final rsp = await Api.I.listGroupMembers(widget.convId);
      setState(() {
        _members = G.l(rsp['members']).map(G.m).toList();
        _loading = false;
      });
    } on ApiError catch (e) {
      setState(() { _error = e.msg; _loading = false; });
    } catch (e) {
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  bool get _isOwner => _members.any((m) =>
      G.i(m['uid']) == (ref.read(authProvider).value?.uid ?? 0) &&
      G.i(m['role']) == 1);

  /// 群主改群名
  Future<void> _rename() async {
    final conv = _conv;
    final controller = TextEditingController(text: conv?.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改群名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 32,
          decoration: const InputDecoration(hintText: '群名称'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('保存')),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == (conv?.name ?? '')) return;
    try {
      await Api.I.updateGroupInfo(widget.convId, name: name);
      ref.read(convListProvider.notifier).reload();
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.msg), behavior: SnackBarBehavior.floating));
      }
    }
  }

  /// 群主换群头像: 选图 → 上传 → PATCH info
  Future<void> _changeAvatar() async {
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (x == null) return;
    try {
      final up = await Api.I.uploadImage(x.path);
      await Api.I.updateGroupInfo(widget.convId, avatar: G.s(up['url']));
      ref.read(convListProvider.notifier).reload();
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.msg), behavior: SnackBarBehavior.floating));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('图片上传失败'),
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  /// 拉人: 从好友里多选 (排除已在群的), 替代手输 uid
  Future<void> _addMembers() async {
    final existing = _members.map((m) => G.i(m['uid'])).toSet();
    final friends = ref.read(friendsProvider);
    final candidates =
        friends.where((f) => !existing.contains(f.uid)).toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('没有可拉的好友 (都已入群)'),
          behavior: SnackBarBehavior.floating));
      return;
    }
    final picked = <int>{};
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('拉人入群'),
        content: SizedBox(
          width: 320,
          height: 360,
          child: StatefulBuilder(builder: (ctx, setD2) {
              void toggle(int uid) => setD2(() {
                    if (!picked.add(uid)) picked.remove(uid);
                  });
              return ListView(
                children: [
                  for (final f in candidates)
                    CheckboxListTile(
                        dense: true,
                        value: picked.contains(f.uid),
                        onChanged: (_) => toggle(f.uid),
                        title: Text(f.nickname),
                        secondary: Avatar(
                            uid: f.uid,
                            nickname: f.nickname,
                            avatar: f.avatar,
                            size: 36)),
                ],
              );
            }),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: picked.isEmpty
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: Text('添加 (${picked.length})')),
        ],
      ),
    );
    if (go != true || picked.isEmpty) return;
    try {
      await Api.I.addGroupMembers(widget.convId, picked.toList());
      await _load();
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.msg), behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _kick(int uid) async {
    try {
      await Api.I.removeGroupMember(widget.convId, uid);
      await _load();
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.msg), behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _quit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出群聊'),
        content: const Text('退出后不再接收该群消息, 确认?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: YimColors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('退出')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Api.I.quitGroup(widget.convId);
      ref.read(convListProvider.notifier).reload();
      if (mounted) context.go('/conversations');
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.msg), behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authProvider).value?.uid ?? 0;
    final conv = ref.watch(convListProvider).firstWhere(
        (c) => c.convId == widget.convId,
        orElse: () => ConvItem(widget.convId, 'CONV_GROUP', const [], 0));
    return Scaffold(
      appBar: AppBar(
        title: const Text('群资料'),
        actions: [
          if (_isOwner)
            IconButton(
                tooltip: '拉人入群',
                onPressed: _addMembers,
                icon: const Icon(Icons.person_add_alt)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!,
                  style: const TextStyle(color: YimColors.danger)))
              : ListView(
                  children: [
                    // 群信息头: 头像 + 群名 (群主可编辑)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: YimSpacing.l),
                      child: Row(children: [
                        const SizedBox(width: YimSpacing.l),
                        GestureDetector(
                          onTap: _isOwner ? _changeAvatar : null,
                          child: Stack(children: [
                            Avatar(
                                uid: widget.convId,
                                nickname: conv.name.isNotEmpty
                                    ? conv.name
                                    : '群',
                                avatar: conv.avatar,
                                size: 64),
                            if (_isOwner)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: YimColors.primary,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 12),
                                ),
                              ),
                          ]),
                        ),
                        const SizedBox(width: YimSpacing.m),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isOwner ? _rename : null,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Flexible(
                                      child: Text(
                                          conv.groupTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ),
                                    if (_isOwner) ...[
                                      const SizedBox(width: YimSpacing.s),
                                      const Icon(Icons.edit_outlined,
                                          size: 15,
                                          color: YimColors.textSecondary),
                                    ],
                                  ]),
                                  const SizedBox(height: 2),
                                  Text('${_members.length} 位成员',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ]),
                          ),
                        ),
                        const SizedBox(width: YimSpacing.l),
                      ]),
                    ),
                    const Divider(height: 1),
                    for (final m in _members)
                      _MemberTile(
                          m: m,
                          isMe: G.i(m['uid']) == me,
                          canKick: _isOwner && G.i(m['role']) != 1,
                          onKick: () => _kick(G.i(m['uid']))),
                    const Divider(height: YimSpacing.xxl),
                    if (!_isOwner)
                      ListTile(
                        leading:
                            const Icon(Icons.logout, color: YimColors.danger),
                        title: const Text('退出群聊',
                            style: TextStyle(color: YimColors.danger)),
                        onTap: _quit,
                      )
                    else
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('群主不可退群 (需先转让或解散)'),
                        subtitle: Text('转让/解散将在后续版本提供'),
                      ),
                  ],
                ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  final Map<String, dynamic> m;
  final bool isMe;
  final bool canKick;
  final VoidCallback onKick;
  const _MemberTile(
      {required this.m,
      required this.isMe,
      required this.canKick,
      required this.onKick});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = G.i(m['uid']);
    final nick = G.s(m['nickname'], 'uid $uid');
    final role = G.i(m['role']);
    return ListTile(
      leading: Avatar(uid: uid, nickname: nick, avatar: G.s(m['avatar'])),
      title: Text(nick + (isMe ? ' (我)' : '')),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (role == 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: YimColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: const Text('群主',
                style: TextStyle(color: YimColors.primary, fontSize: 11)),
          ),
        if (canKick) ...[
          const SizedBox(width: YimSpacing.s),
          IconButton(
              tooltip: '移出群聊',
              icon: const Icon(Icons.remove_circle_outline,
                  color: YimColors.danger),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('移出群聊'),
                    content: Text('将 $nick 移出本群?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('取消')),
                      FilledButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onKick();
                          },
                          child: const Text('移出')),
                    ],
                  ),
                );
              }),
        ],
      ]),
    );
  }
}

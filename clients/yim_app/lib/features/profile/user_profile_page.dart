// 他人资料: 加好友 / 删好友 / 发消息 (找到或建单聊会话)。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/network/api.dart';
import '../../core/shell/app_shell.dart' show Avatar;
import '../../core/theme/app_theme.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  final int uid;
  const UserProfilePage({super.key, required this.uid});
  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  bool _isFriend = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(profilesProvider(widget.uid).notifier);
      ref.read(presenceProvider(widget.uid).notifier);
      await _checkFriend();
    });
  }

  Future<void> _checkFriend() async {
    try {
      final friends = ref.read(friendsProvider);
      setState(() => _isFriend = friends.any((f) => f.uid == widget.uid));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(profilesProvider(widget.uid)).value;
    final online = ref.watch(presenceProvider(widget.uid));
    final me = ref.watch(authProvider).value?.uid ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('资料')),
      body: ListView(
        padding: const EdgeInsets.all(YimSpacing.xl),
        children: [
          Center(
              child: Avatar(
                  uid: widget.uid,
                  nickname: p?.nickname ?? '?',
                  avatar: p?.avatar ?? '',
                  size: 88)),
          const SizedBox(height: YimSpacing.l),
          Center(
              child: Text(p?.nickname ?? '…',
                  style: Theme.of(context).textTheme.displaySmall)),
          const SizedBox(height: YimSpacing.xs),
          Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: online ? const Color(0xFF34C759) : YimColors.textTertiary)),
            const SizedBox(width: YimSpacing.s),
            Text(online ? '在线' : '离线',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: YimSpacing.m),
            Text('uid ${widget.uid}',
                style: Theme.of(context).textTheme.labelSmall),
          ])),
          const SizedBox(height: YimSpacing.xxl),
          if (widget.uid != me) ...[
            FilledButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('发消息'),
            ),
            const SizedBox(height: YimSpacing.m),
            OutlinedButton.icon(
              onPressed: _isFriend ? _deleteFriend : _addFriend,
              icon: Icon(_isFriend
                  ? Icons.person_remove
                  : Icons.person_add_alt),
              label: Text(_isFriend ? '删除好友' : '添加好友'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _isFriend ? YimColors.danger : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addFriend() async {
    try {
      await Api.I.sendFriendRequest(widget.uid, '加个好友吧');
      // 互为 pending 时服务端自动合并为已同意 → 立即重拉
      ref.read(friendsProvider.notifier).reload();
      ref.read(friendRequestsProvider.notifier).reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('好友申请已发送'), behavior: SnackBarBehavior.floating));
      }
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.msg), behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _deleteFriend() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除好友'),
        content: const Text('删除后将同时清除会话, 确认?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: YimColors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Api.I.deleteFriend(widget.uid);
      ref.read(friendsProvider.notifier).reload();
      setState(() => _isFriend = false);
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.msg), behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _openChat() async {
    try {
      // 单聊去重: 重复创建返回同一 conv_id
      final rsp = await Api.I.createConv(
          'CONV_SINGLE', [widget.uid]);
      final convId = G.i(G.m(rsp['conv'])['conv_id']);
      ref.read(convListProvider.notifier).reload();
      ref.read(selectedConvProvider.notifier).state = convId;
      if (mounted) {
        if (MediaQuery.sizeOf(context).width >= 900) {
          context.go('/conversations');
        } else {
          context.push('/conversations/$convId');
        }
      }
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.msg), behavior: SnackBarBehavior.floating));
      }
    }
  }
}

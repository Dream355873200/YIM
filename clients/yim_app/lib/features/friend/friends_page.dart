// 好友页。两端原生, 不互为移植:
// 桌面 = 工具栏 (过滤框 + 分段切换) + 列表 | 右侧详情面板 (master-detail),
//        加好友走对话框内搜索 (SearchUsers 预览头像/昵称)。
// 移动 = AppBar + TabBar + 底部弹层加好友, 点击 push 全屏资料页。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/network/api.dart';
import '../../core/shell/app_shell.dart' show Avatar;
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hover_row.dart';
import '../../core/window/desktop_window.dart';

// 详情面板当前展示的好友 uid (0 = 未选中)
final selectedFriendUidProvider = StateProvider<int>((_) => 0);

class FriendsPage extends ConsumerStatefulWidget {
  const FriendsPage({super.key});
  @override
  ConsumerState<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage> {
  int _tab = 0; // 0 好友 1 申请 (桌面分段控制用)
  String _filter = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(friendsProvider.notifier).reload();
      ref.read(friendRequestsProvider.notifier).reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 900 && isDesktop
        ? _DesktopFriends(tab: _tab, onTab: (t) => setState(() => _tab = t),
            filter: _filter, onFilter: (v) => setState(() => _filter = v))
        : _MobileFriends();
  }
}

// ============================================================
// 桌面: 工具栏 + 列表 | 详情
// ============================================================

class _DesktopFriends extends ConsumerWidget {
  final int tab;
  final ValueChanged<int> onTab;
  final String filter;
  final ValueChanged<String> onFilter;
  const _DesktopFriends(
      {required this.tab,
      required this.onTab,
      required this.filter,
      required this.onFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final friends = ref.watch(friendsProvider);
    final requests = ref.watch(friendRequestsProvider);
    final count = tab == 0
        ? friends
            .where((f) =>
                filter.isEmpty ||
                f.nickname.toLowerCase().contains(filter.toLowerCase()))
            .length
        : requests.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- 工具栏: 与消息列表列头部同高 (56), 消除顶部空白错位 ----
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: YimSpacing.l),
          child: SizedBox(
            height: 56,
            child: LayoutBuilder(builder: (context, cons) {
              // 窄窗紧凑: 收起计数、按钮只留图标 (搜索框已是 Flexible)
              final compact = cons.maxWidth < 560;
              return Row(children: [
                Text('好友', style: theme.textTheme.titleMedium),
                if (!compact) ...[
                  const SizedBox(width: YimSpacing.s),
                  Text('$count', style: theme.textTheme.labelSmall),
                ],
                const Spacer(),
                // 弹性宽: 最宽 220, 窄窗时随剩余空间收缩而非溢出
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: SizedBox(
                      height: 34,
                      child: TextField(
                        onChanged: onFilter,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: '筛选好友…',
                          prefixIcon: Icon(Icons.search, size: 16),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: YimSpacing.m),
                _Segmented(
                    labels: const ['好友', '申请'],
                    badge: requests.length,
                    selected: tab,
                    onSelect: onTab),
                const SizedBox(width: YimSpacing.m),
                if (compact) ...[
                  SizedBox(
                    height: 34,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 34)),
                      onPressed: () => context.push('/groups/create'),
                      child: const Icon(Icons.group_add, size: 16),
                    ),
                  ),
                  const SizedBox(width: YimSpacing.s),
                  SizedBox(
                    height: 34,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 34)),
                      onPressed: () => showUserSearch(context, desktop: true),
                      child: const Icon(Icons.person_add_alt, size: 16),
                    ),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    style:
                        OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
                    onPressed: () => context.push('/groups/create'),
                    icon: const Icon(Icons.group_add, size: 16),
                    label: const Text('群聊', style: TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(width: YimSpacing.s),
                  OutlinedButton.icon(
                    style:
                        OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
                    onPressed: () => showUserSearch(context, desktop: true),
                    icon: const Icon(Icons.person_add_alt, size: 16),
                    label: const Text('添加', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ]);
            }),
          ),
        ),
        const Divider(height: 1),
        // ---- 列表 | 详情 ----
        // 桌面 shell 的 IndexedStack 会以 300px 隐藏布局本页 (消息 tab 时),
        // 窄容器退化为单列列表, 避免 340+详情 固定结构溢出
        Expanded(
          child: LayoutBuilder(builder: (context, cons) {
            final wide = cons.maxWidth >= 600;
            if (!wide) {
              return tab == 0
                  ? _FriendList(
                      friends: friends
                          .where((f) =>
                              filter.isEmpty ||
                              f.nickname
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()))
                          .toList())
                  : _RequestList(requests: requests);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 列表列浅色下灰底, 详情面板纯白
                SizedBox(
                  width: 340,
                  child: Container(
                    color: theme.brightness == Brightness.dark
                        ? YimColors.bgDark
                        : YimColors.sidebarLight,
                    child: tab == 0
                        ? _FriendList(
                            friends: friends
                                .where((f) =>
                                    filter.isEmpty ||
                                    f.nickname
                                        .toLowerCase()
                                        .contains(filter.toLowerCase()))
                                .toList())
                        : _RequestList(requests: requests),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _DetailPane(isRequestTab: tab == 1)),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// Fluent 式分段控制
class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int badge;
  final int selected;
  final ValueChanged<int> onSelect;
  const _Segmented(
      {required this.labels,
      required this.badge,
      required this.selected,
      required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerTheme.color!),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < labels.length; i++)
          InkWell(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: selected == i
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : null,
              child: Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(labels[i],
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected == i
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected == i
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodySmall?.color)),
                  if (i == 1 && badge > 0) ...[
                    const SizedBox(width: 4),
                    Text('$badge',
                        style: TextStyle(
                            fontSize: 11, color: theme.colorScheme.primary)),
                  ],
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

class _FriendList extends ConsumerWidget {
  final List<Profile> friends;
  const _FriendList({required this.friends});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (friends.isEmpty) {
      return _Empty(icon: Icons.person_outline, text: '暂无好友\n点右上「添加」搜索 uid 或昵称');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: YimSpacing.s),
      itemCount: friends.length,
      itemBuilder: (_, i) {
        final f = friends[i];
        final selected = ref.watch(selectedFriendUidProvider) == f.uid;
        return HoverRow(
          selected: selected,
          onTap: () =>
              ref.read(selectedFriendUidProvider.notifier).state = f.uid,
          child: Row(children: [
            Avatar(uid: f.uid, nickname: f.nickname, avatar: f.avatar, size: 34),
            const SizedBox(width: YimSpacing.m),
            Expanded(
              child: Text(f.nickname,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14)),
            ),
            _PresenceLabel(uid: f.uid),
          ]),
        );
      },
    );
  }
}

class _RequestList extends ConsumerWidget {
  final List<Map<String, dynamic>> requests;
  const _RequestList({required this.requests});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (requests.isEmpty) {
      return const _Empty(icon: Icons.mark_email_unread, text: '没有待处理的申请');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: YimSpacing.s),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final r = requests[i];
        final fromUid = G.i(r['from_uid']);
        final p = ref.watch(profilesProvider(fromUid)).value;
        final selected = ref.watch(selectedFriendUidProvider) == fromUid;
        return HoverRow(
          selected: selected,
          onTap: () =>
              ref.read(selectedFriendUidProvider.notifier).state = fromUid,
          child: Row(children: [
            Avatar(
                uid: fromUid,
                nickname: p?.nickname ?? '?',
                avatar: p?.avatar ?? '',
                size: 34),
            const SizedBox(width: YimSpacing.m),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p?.nickname ?? 'uid $fromUid',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14)),
                    if (G.s(r['message']).isNotEmpty)
                      Text(G.s(r['message']),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall),
                  ]),
            ),
            SizedBox(
              height: 28,
              child: FilledButton(
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(fontSize: 12)),
                  onPressed: () => ref
                      .read(friendRequestsProvider.notifier)
                      .handle(fromUid, true),
                  child: const Text('同意')),
            ),
            const SizedBox(width: YimSpacing.xs),
            SizedBox(
              height: 28,
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(fontSize: 12)),
                  onPressed: () => ref
                      .read(friendRequestsProvider.notifier)
                      .handle(fromUid, false),
                  child: const Text('拒绝')),
            ),
          ]),
        );
      },
    );
  }
}

// 桌面右侧详情面板
class _DetailPane extends ConsumerWidget {
  final bool isRequestTab;
  const _DetailPane({required this.isRequestTab});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(selectedFriendUidProvider);
    if (uid == 0) {
      return _Empty(icon: Icons.person_search_outlined, text: '选择左侧联系人查看资料');
    }
    final p = ref.watch(profilesProvider(uid)).value;
    final online = ref.watch(presenceProvider(uid));
    final friends = ref.watch(friendsProvider);
    final isFriend = friends.any((f) => f.uid == uid);
    final me = ref.watch(authProvider).value?.uid ?? 0;
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Avatar(uid: uid, nickname: p?.nickname ?? '?', avatar: p?.avatar ?? '', size: 88),
            const SizedBox(height: YimSpacing.l),
            Text(p?.nickname ?? 'uid $uid', style: theme.textTheme.titleMedium),
            const SizedBox(height: YimSpacing.xs),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: online ? const Color(0xFF34C759) : YimColors.textTertiary)),
              const SizedBox(width: YimSpacing.s),
              Text(online ? '在线' : '离线', style: theme.textTheme.bodySmall),
              const SizedBox(width: YimSpacing.m),
              Text('uid $uid', style: theme.textTheme.labelSmall),
            ]),
            const SizedBox(height: YimSpacing.xl),
            if (uid != me)
              Row(mainAxisSize: MainAxisSize.min, children: [
                FilledButton.icon(
                  onPressed: () => _openChat(context, ref, uid),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('发消息'),
                ),
                const SizedBox(width: YimSpacing.m),
                if (!isRequestTab)
                  OutlinedButton.icon(
                    onPressed: () => isFriend
                        ? _deleteFriend(context, ref, uid)
                        : _addFriend(context, ref, uid),
                    icon: Icon(isFriend ? Icons.person_remove : Icons.person_add_alt, size: 16),
                    label: Text(isFriend ? '删除好友' : '添加好友'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isFriend ? YimColors.danger : null,
                    ),
                  ),
              ]),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 移动: AppBar + TabBar
// ============================================================

class _MobileFriends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabBar = TabBar(
      tabs: const [Tab(text: '好友'), Tab(text: '申请')],
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.textTheme.bodySmall?.color,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: theme.dividerTheme.color,
    );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('好友'),
          actions: [
            IconButton(
              tooltip: '添加好友',
              onPressed: () => context.push('/friends/add'),
              icon: const Icon(Icons.person_add_alt, size: 20),
            )
          ],
          bottom: tabBar,
        ),
        body: TabBarView(children: [
          Consumer(builder: (_, ref, __) {
            final friends = ref.watch(friendsProvider);
            if (friends.isEmpty) {
              return _Empty(icon: Icons.person_outline, text: '还没有好友\n用右上角 + 搜索 uid 或昵称添加');
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(friendsProvider.notifier).reload(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: YimSpacing.s),
                itemCount: friends.length,
                separatorBuilder: (_, __) => const Divider(indent: 76, height: 1),
                itemBuilder: (_, i) {
                  final f = friends[i];
                  return HoverRow(
                    onTap: () => context.push('/users/${f.uid}'),
                    padding: const EdgeInsets.symmetric(
                        horizontal: YimSpacing.l, vertical: 10),
                    child: Row(children: [
                      Avatar(uid: f.uid, nickname: f.nickname, avatar: f.avatar),
                      const SizedBox(width: YimSpacing.l),
                      Expanded(
                        child: Text(f.nickname,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      _PresenceLabel(uid: f.uid),
                    ]),
                  );
                },
              ),
            );
          }),
          Consumer(builder: (_, ref, __) {
            final requests = ref.watch(friendRequestsProvider);
            if (requests.isEmpty) {
              return const _Empty(icon: Icons.mark_email_unread, text: '没有待处理的申请');
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: YimSpacing.s),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const Divider(indent: 76, height: 1),
              itemBuilder: (_, i) {
                final r = requests[i];
                final fromUid = G.i(r['from_uid']);
                final p = ref.watch(profilesProvider(fromUid)).value;
                return HoverRow(
                  padding: const EdgeInsets.symmetric(
                      horizontal: YimSpacing.l, vertical: 10),
                  child: Row(children: [
                    Avatar(
                        uid: fromUid,
                        nickname: p?.nickname ?? '?',
                        avatar: p?.avatar ?? ''),
                    const SizedBox(width: YimSpacing.l),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p?.nickname ?? 'uid $fromUid',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            G.s(r['message']).isEmpty
                                ? Text('想加你为好友',
                                    style: Theme.of(context).textTheme.bodySmall)
                                : Text(G.s(r['message']),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                          ]),
                    ),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                        height: 32,
                        child: FilledButton(
                            style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                minimumSize: Size.zero,
                                textStyle: const TextStyle(fontSize: 13)),
                            onPressed: () => ref
                                .read(friendRequestsProvider.notifier)
                                .handle(fromUid, true),
                            child: const Text('同意')),
                      ),
                      const SizedBox(width: YimSpacing.s),
                      SizedBox(
                        height: 32,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                minimumSize: Size.zero,
                                textStyle: const TextStyle(fontSize: 13)),
                            onPressed: () => ref
                                .read(friendRequestsProvider.notifier)
                                .handle(fromUid, false),
                            child: const Text('拒绝')),
                      ),
                    ]),
                  ]),
                );
              },
            );
          }),
        ]),
      ),
    );
  }
}

// ============================================================
// 通用: 动作 + 搜索 (SearchUsers: uid 精确 / 昵称前缀, 预览头像昵称)
// ============================================================

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Empty({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final sec = Theme.of(context).textTheme.bodySmall?.color;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: sec?.withValues(alpha: 0.4)),
          const SizedBox(height: YimSpacing.m),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: sec)),
        ],
      ),
    );
  }
}

// 行内在线状态: 绿点+在线 / 灰点+离线 (presenceProvider 进入列表即拉取)
class _PresenceLabel extends ConsumerWidget {
  final int uid;
  const _PresenceLabel({required this.uid});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(presenceProvider(uid));
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online ? const Color(0xFF34C759) : YimColors.textTertiary)),
      const SizedBox(width: 4),
      Text(online ? '在线' : '离线',
          style: Theme.of(context).textTheme.labelSmall),
    ]);
  }
}

Future<void> _addFriend(BuildContext context, WidgetRef ref, int uid) async {
  try {
    await Api.I.sendFriendRequest(uid, '加个好友吧');
    // 互为 pending 时服务端自动合并为已同意 → 立即重拉
    ref.read(friendsProvider.notifier).reload();
    ref.read(friendRequestsProvider.notifier).reload();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('已向 uid $uid 发送好友申请'),
          behavior: SnackBarBehavior.floating));
    }
  } on ApiError catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.msg), behavior: SnackBarBehavior.floating));
    }
  }
}

Future<void> _deleteFriend(BuildContext context, WidgetRef ref, int uid) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('删除好友'),
      content: const Text('删除后将同时清除会话, 确认?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
        FilledButton(
            style: FilledButton.styleFrom(backgroundColor: YimColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除')),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await Api.I.deleteFriend(uid);
    ref.read(friendsProvider.notifier).reload();
    ref.read(selectedFriendUidProvider.notifier).state = 0;
  } on ApiError catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.msg), behavior: SnackBarBehavior.floating));
    }
  }
}

Future<void> _openChat(BuildContext context, WidgetRef ref, int uid) async {
  try {
    final rsp = await Api.I.createConv('CONV_SINGLE', [uid]);
    final convId = G.i(G.m(rsp['conv'])['conv_id']);
    ref.read(convListProvider.notifier).reload();
    ref.read(selectedConvProvider.notifier).state = convId;
    if (context.mounted) {
      if (MediaQuery.sizeOf(context).width >= 900 && isDesktop) {
        context.go('/conversations');
      } else {
        context.push('/conversations/$convId');
      }
    }
  } on ApiError catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.msg), behavior: SnackBarBehavior.floating));
    }
  }
}

/// 加好友搜索: 桌面 = 对话框, 移动 = 全页路由 (/friends/add)。
/// 输入 uid 精确查 / 昵称前缀模糊查, 结果行预览头像+昵称。
Future<void> showUserSearch(BuildContext context, {bool desktop = false}) async {
  final content = _UserSearchPanel(desktop: desktop);
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('添加好友'),
      content: SizedBox(width: 360, child: content),
    ),
  );
}

/// 移动端加好友全页: 搜索框置顶 + 结果列表铺满, 替代底部弹层
class UserSearchPage extends StatelessWidget {
  const UserSearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加好友')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(YimSpacing.l),
          child: _UserSearchPanel(desktop: false),
        ),
      ),
    );
  }
}

class _UserSearchPanel extends ConsumerStatefulWidget {
  final bool desktop; // 桌面对话框: 不跳转资料页
  const _UserSearchPanel({required this.desktop});
  @override
  ConsumerState<_UserSearchPanel> createState() => _UserSearchPanelState();
}

class _UserSearchPanelState extends ConsumerState<_UserSearchPanel> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Profile>? _results;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String kw) {
    _debounce?.cancel();
    if (kw.trim().isEmpty) {
      setState(() {
        _results = null;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), _search);
  }

  Future<void> _search() async {
    final kw = _controller.text.trim();
    if (kw.isEmpty) return;
    setState(() => _busy = true);
    try {
      final rsp = await Api.I.searchUsers(kw);
      if (!mounted) return;
      setState(() {
        _results = G.l(rsp['profiles'])
            .map((raw) => Profile.fromMap(G.m(raw)))
            .toList();
        _error = _results!.isEmpty ? '没有匹配的用户' : null;
      });
    } on ApiError catch (e) {
      if (mounted) setState(() => _error = e.msg);
    } catch (e) {
      if (mounted) setState(() => _error = '网络错误');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(authProvider).value?.uid ?? 0;
    final friends = ref.watch(friendsProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          onSubmitted: (_) => _search(),
          decoration: const InputDecoration(
              hintText: '输入 uid 或昵称搜索'),
        ),
        const SizedBox(height: YimSpacing.m),
        if (_busy) const Padding(
            padding: EdgeInsets.all(YimSpacing.l),
            child: CircularProgressIndicator(strokeWidth: 2)),
        if (!_busy && _error != null)
          Padding(
            padding: const EdgeInsets.all(YimSpacing.l),
            child: Text(_error!, style: Theme.of(context).textTheme.bodySmall),
          ),
        if (!_busy && _results != null)
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results!.length,
              itemBuilder: (_, i) {
                final u = _results![i];
                final isMe = u.uid == myUid;
                final isFriend = friends.any((f) => f.uid == u.uid);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Avatar(uid: u.uid, nickname: u.nickname, avatar: u.avatar, size: 40),
                  title: Text(u.nickname,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('uid ${u.uid}',
                      style: Theme.of(context).textTheme.labelSmall),
                  trailing: isMe
                      ? Text('我自己', style: Theme.of(context).textTheme.labelSmall)
                      : isFriend
                          ? Text('已是好友',
                              style: Theme.of(context).textTheme.labelSmall)
                          : SizedBox(
                              height: 32,
                              child: FilledButton(
                                  style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      minimumSize: Size.zero,
                                      textStyle:
                                          const TextStyle(fontSize: 13)),
                                  onPressed: () => _addFriend(context, ref, u.uid),
                                  child: const Text('加好友')),
                            ),
                  onTap: !isMe && !widget.desktop
                      ? () {
                          Navigator.of(context).pop();
                          context.push('/users/${u.uid}');
                        }
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }
}

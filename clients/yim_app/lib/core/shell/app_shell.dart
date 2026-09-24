// 自适应壳: 断点 900。
// 桌面: [Rail 64 | 当前 tab | 详情列] —— tab0 会话列表时第三栏为聊天窗
// (selectedConvProvider 驱动); 其他 tab 详情列隐藏。
// 移动: shell + BottomNav, 聊天窗走顶层路由全屏。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../socket/yim_socket.dart' show SocketState;
import '../theme/app_theme.dart';
import '../network/api.dart';
import '../window/desktop_window.dart';
import '../../features/chat/chat_page.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.value?.status != AuthStatus.loggedIn) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (!wide) {
      return Scaffold(
        body: Column(children: [
          const _ConnBanner(),
          Expanded(child: shell),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => _openBranch(ref, shell, i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: '消息'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: '好友'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: '我的'),
          ],
        ),
      );
    }

    // 桌面三栏
    final idx = shell.currentIndex;
    final selectedConv = ref.watch(selectedConvProvider);
    final rail = NavigationRail(
      selectedIndex: idx,
      onDestinationSelected: (i) => _openBranch(ref, shell, i),
      labelType: NavigationRailLabelType.all,
      leading: const SizedBox(height: 8),
      destinations: const [
        NavigationRailDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: Text('消息')),
        NavigationRailDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('好友')),
        NavigationRailDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: Text('我的')),
      ],
    );

    final Widget content;
    if (idx == 0) {
      // 列表列浅色下灰底 (与纯白聊天区拉开层级), 深色保持窗底
      final listCol = Theme.of(context).brightness == Brightness.dark
          ? YimColors.bgDark
          : YimColors.sidebarLight;
      content = Row(
        children: [
          SizedBox(
              width: 300,
              child: Container(
                  color: listCol,
                  child: Column(children: [
                    _ShellHeader(title: '消息'),
                    Expanded(child: shell),
                  ]))),
          const VerticalDivider(),
          Expanded(
            child: selectedConv > 0
                // ValueKey: 切会话必须换 State —— 否则 Flutter 复用同一 State,
                // _peerReadSeq/_reply 等页内状态会从上个会话泄漏进新会话
                // (曾致: 上个单聊的已读水位显示在刚打开的群聊里)
                ? ChatPage(
                    key: ValueKey(selectedConv),
                    convId: selectedConv,
                    embedded: true)
                : _Placeholder(
                    icon: Icons.chat_bubble_outline, text: '选择一个会话开始聊天'),
          ),
        ],
      );
    } else {
      content = shell;
    }

    return Scaffold(
      body: Column(children: [
        const AppTitleBar(title: 'YIM'), // 无边框自绘标题栏 (移动端 no-op)
        const _ConnBanner(),
        Expanded(
          child: Row(children: [
            rail,
            const VerticalDivider(),
            Expanded(child: content),
          ]),
        ),
      ]),
    );
  }
}

/// 长连接状态横幅: 正常 (ready/syncing 完成) 不占位, 异常态才出现。
/// suspended/disconnected/connecting = 断开重连中, syncing = 同步中。
class _ConnBanner extends ConsumerWidget {
  const _ConnBanner();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(connStateProvider);
    final cs = ref.watch(authProvider).value?.status;
    if (cs != AuthStatus.loggedIn) return const SizedBox.shrink();
    final (text, color) = switch (st) {
      SocketState.suspended ||
      SocketState.disconnected ||
      SocketState.connecting =>
        ('连接断开, 正在重连…', YimColors.danger),
      SocketState.syncing => ('同步中…', const Color(0xFFB58A00)),
      _ => ('', Colors.transparent),
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Material(
      color: color.withValues(alpha: 0.12),
      child: SizedBox(
        width: double.infinity,
        height: 26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                    strokeWidth: 1.6, color: color)),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

/// 切 tab: 桌面/移动共用。好友 tab 常驻 IndexedStack (initState 只跑一次),
/// 进入时重拉好友+申请+在线状态 —— 拉取制下保证列表与在线点不陈旧。
void _openBranch(WidgetRef ref, StatefulNavigationShell shell, int i) {
  shell.goBranch(i, initialLocation: i == shell.currentIndex);
  if (i == 1) {
    ref.read(friendsProvider.notifier).reload().then((_) {
      // 好友列表刷新后, 逐个重查在线状态 (presence family 缓存不自动过期)
      for (final f in ref.read(friendsProvider)) {
        ref.read(presenceProvider(f.uid).notifier).fetch(f.uid);
      }
    });
    ref.read(friendRequestsProvider.notifier).reload();
  }
}

class _ShellHeader extends ConsumerWidget {
  final String title;
  const _ShellHeader({required this.title});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (title == '消息')
          IconButton(
              tooltip: '搜索消息',
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search, size: 20)),
      ]),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Placeholder({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final sec = Theme.of(context).textTheme.bodySmall?.color;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: sec?.withValues(alpha: 0.5)),
          const SizedBox(height: YimSpacing.m),
          Text(text, style: TextStyle(color: sec)),
        ],
      ),
    );
  }
}

// Avatar 小工具 (列表/聊天复用)
class Avatar extends StatelessWidget {
  final int uid;
  final String nickname;
  final String avatar;
  final double size;
  const Avatar(
      {super.key,
      required this.uid,
      required this.nickname,
      required this.avatar,
      this.size = 48});
  @override
  Widget build(BuildContext context) {
    // Fluent persona 色板 (低饱和), 底 15% 淡色 + 同系深字
    final colors = [
      const Color(0xFF0F6CBD), // 蓝
      const Color(0xFF038387), // 青
      const Color(0xFF8764B8), // 紫
      const Color(0xFFCA5010), // 赭
      const Color(0xFF107C10), // 绿
      const Color(0xFFB146C2), // 品红
    ];
    final c = colors[uid % colors.length];
    final initial = nickname.isEmpty ? '?' : nickname.characters.first;
    Widget inner = CircleAvatar(
      radius: size / 2,
      backgroundColor: c.withValues(alpha: 0.15),
      backgroundImage: avatar.isEmpty ? null : NetworkImage(Api.avatarUrl(avatar)),
      child: avatar.isEmpty
          ? Text(initial, style: TextStyle(color: c, fontSize: size * 0.4))
          : null,
    );
    return inner;
  }
}

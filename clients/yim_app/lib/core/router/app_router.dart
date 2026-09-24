// 路由: go_router + StatefulShellRoute。
// 宽 ≥900 (桌面): [Rail 64 | 列表 300 | 聊天窗 expand] 三栏; 窄 (移动):
// BottomNav 三 tab + push 全屏聊天。聊天窗桌面非路由 (selectedConvProvider
// 驱动详情列), 移动端是顶层路由全屏 push —— 保证分支导航器不被聊天页占据。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/chat/chat_page.dart';
import '../../features/conversation/conversation_list_page.dart';
import '../../features/friend/friends_page.dart';
import '../../features/group/create_group_page.dart';
import '../../features/group/group_manage_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/profile/user_profile_page.dart';
import '../../features/search/search_page.dart';
import '../shell/app_shell.dart';

final _rootNavKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/conversations',
    redirect: (ctx, st) {
      final auth = ref.read(authProvider);
      if (auth.value?.status == AuthStatus.boot) return null;
      final loggedIn = auth.value?.status == AuthStatus.loggedIn;
      final loggingIn =
          st.matchedLocation == '/login' || st.matchedLocation == '/register';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/conversations';
      return null;
    },
    refreshListenable: _AuthRefresh(ref),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(
          path: '/users/:uid',
          builder: (_, st) => UserProfilePage(
              uid: int.tryParse(st.pathParameters['uid'] ?? '') ?? 0)),
      // 移动端加好友全页 (桌面走好友页工具栏的对话框)
      GoRoute(path: '/friends/add', builder: (_, __) => const UserSearchPage()),
      GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
      GoRoute(
          path: '/groups/create',
          builder: (_, __) => const CreateGroupPage()),
      GoRoute(
          path: '/groups/:convId/manage',
          builder: (_, st) => GroupManagePage(
              convId: int.tryParse(st.pathParameters['convId'] ?? '') ?? 0)),
      // 移动端全屏聊天 (桌面端走详情列, 不进此路由)
      GoRoute(
          path: '/conversations/:convId',
          builder: (_, st) => ChatPage(
              convId: int.tryParse(st.pathParameters['convId'] ?? '') ?? 0,
              embedded: false)),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/conversations',
                builder: (_, __) => const ConversationListPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/friends', builder: (_, __) => const FriendsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/me', builder: (_, __) => const ProfilePage()),
          ]),
        ],
      ),
    ],
  );
});

/// auth 状态变化触发 redirect 重算
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

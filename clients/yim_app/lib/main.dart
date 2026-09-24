// YIM 客户端入口: ProviderScope + MaterialApp.router。
// 简约克制的 IM —— 浅色为主, 深色跟随系统; 桌面无边框自绘标题栏,
// 登录小窗 → 登录后展开三栏工作区。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'core/network/api.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/storage/session_store.dart';
import 'core/theme/app_theme.dart';
import 'core/window/desktop_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sessionStore.init();
  await NotificationService.I.init(); // 系统通知双端初始化 (失败仅降级不弹)
  await initDesktopWindow();
  runApp(const ProviderScope(child: YimApp()));
}

/// 根组件生命周期: 手机切后台 → 回前台时立即恢复长连接 (不等退避)
/// 并以服务端为准重拉会话列表, 补齐后台期间错过的增量。
class YimApp extends ConsumerStatefulWidget {
  const YimApp({super.key});
  @override
  ConsumerState<YimApp> createState() => _YimAppState();
}

class _YimAppState extends ConsumerState<YimApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final auth = ref.read(authProvider).value;
    if (auth?.status != AuthStatus.loggedIn) return;
    ref.read(socketBusProvider).sock?.resume();
    ref.read(convListProvider.notifier).reload();
  }

  @override
  Widget build(BuildContext context) {
    // boot: authProvider 初始化 (恢复 token → 长连接)
    ref.watch(authProvider);
    Api.I; // eager: Dio 拦截器就绪
    // 登录态 → 窗口尺寸切换 (桌面): 登录小窗 / 三栏工作区
    ref.listen(authProvider, (_, next) {
      final st = next.value;
      if (st != null) resizeForAuth(st.status == AuthStatus.loggedIn);
    });
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'YIM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      // 深浅切换动效: 整树颜色交叉渐变
      themeAnimationDuration: const Duration(milliseconds: 360),
      themeAnimationCurve: Curves.easeOutCubic,
      routerConfig: router,
    );
  }
}

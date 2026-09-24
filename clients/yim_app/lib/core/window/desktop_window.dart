// 桌面窗口管理: 无边框 (隐藏原生标题栏) + 自绘标题栏。
// 登录/注册 = 小窗 (420×600); 登录成功 = 三栏工作区 (1200×800)。
// 移动端全部 no-op。
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

bool get isDesktop =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// main() 里调用: 隐藏原生标题栏 + 初始小窗。
Future<void> initDesktopWindow() async {
  if (!isDesktop) return;
  await windowManager.ensureInitialized();
  const opts = WindowOptions(
    size: Size(420, 600),
    minimumSize: Size(360, 520),
    center: true,
    titleBarStyle: TitleBarStyle.hidden, // 无边框: 自绘标题栏
  );
  await windowManager.waitUntilReadyToShow(opts, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

/// 登录态切换时调整窗口尺寸 (YimApp 监听 authProvider 调用)。
Future<void> resizeForAuth(bool loggedIn) async {
  if (!isDesktop) return;
  if (loggedIn) {
    await windowManager.setMinimumSize(const Size(940, 620));
    final cur = await windowManager.getSize();
    if (cur.width < 1100 || cur.height < 720) {
      await windowManager.setBounds(const Rect.fromLTWH(0, 0, 1200, 800));
      await windowManager.center();
    }
  } else {
    await windowManager.setMinimumSize(const Size(360, 520));
    await windowManager.setBounds(const Rect.fromLTWH(0, 0, 420, 600));
    await windowManager.center();
  }
}

/// 自绘标题栏: 拖拽区 + 最小化/关闭。移动端不渲染。
class AppTitleBar extends StatelessWidget {
  final String title;
  final bool closable; // 登录前窗口小, 直接给关闭钮
  const AppTitleBar({super.key, required this.title, this.closable = true});
  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF202020) : const Color(0xFFF3F3F3);
    final fg = dark ? const Color(0xFFC8C8C8) : const Color(0xFF5D5D5D);
    return Container(
      height: 36,
      color: bg,
      child: Row(children: [
        const SizedBox(width: 12),
        Text(title,
            style: TextStyle(fontSize: 12, color: fg,
                fontWeight: FontWeight.w600)),
        Expanded(
          child: DragToMoveArea(
            child: GestureDetector(
              onDoubleTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
            ),
          ),
        ),
        _WinButton(
          icon: Icons.remove,
          color: fg,
          hoverColor: Theme.of(context).dividerTheme.color ?? fg,
          onTap: windowManager.minimize,
        ),
        if (closable)
          _WinButton(
            icon: Icons.close,
            color: fg,
            hoverColor: const Color(0xFFE5484D),
            onTap: windowManager.close,
          ),
        const SizedBox(width: 4),
      ]),
    );
  }
}

class _WinButton extends StatefulWidget {
  final IconData icon;
  final Color color, hoverColor;
  final VoidCallback onTap;
  const _WinButton(
      {required this.icon,
      required this.color,
      required this.hoverColor,
      required this.onTap});
  @override
  State<_WinButton> createState() => _WinButtonState();
}

class _WinButtonState extends State<_WinButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: 40,
          height: 36,
          color: _hover ? widget.hoverColor.withValues(alpha: 0.9) : null,
          child: Icon(widget.icon,
              size: 16,
              color: _hover && widget.hoverColor == const Color(0xFFE5484D)
                  ? Colors.white
                  : widget.color),
        ),
      ),
    );
  }
}

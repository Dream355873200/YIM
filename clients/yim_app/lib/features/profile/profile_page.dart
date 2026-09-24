// 我的资料/设置。两端原生:
// 桌面 = 左身份卡 (头像/昵称/uid) | 右设置行 (Fluent 式: 标题+描述+右侧控件),
//        外观区含主题切换 (跟随系统/浅色/深色), 动效由 MaterialApp 提供。
// 移动 = 分组卡片列表, 同样含外观设置。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_state.dart';
import '../../core/network/api.dart';
import '../../core/shell/app_shell.dart' show Avatar;
import '../../core/theme/app_theme.dart';
import '../../core/window/desktop_window.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 900 && isDesktop;
    return wide ? const _DesktopProfile() : _MobileProfile();
  }
}

// ============================================================
// 桌面: 身份卡 | 设置行
// ============================================================

class _DesktopProfile extends ConsumerWidget {
  const _DesktopProfile();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).value;
    final profile =
        me != null && me.uid > 0 ? ref.watch(profilesProvider(me.uid)).value : null;
    final theme = Theme.of(context);

    final identity = Column(
      children: [
        Stack(children: [
          Avatar(
              uid: me?.uid ?? 0,
              nickname: me?.nickname ?? '?',
              avatar: profile?.avatar ?? '',
              size: 88),
          Positioned(
            right: 0,
            bottom: 0,
            child: _HoverIcon(
              tooltip: '更换头像',
              icon: Icons.camera_alt,
              onTap: () => _pickAvatar(context, ref),
            ),
          ),
        ]),
        const SizedBox(height: YimSpacing.l),
        Text(profile?.nickname ?? me?.nickname ?? '…',
            style: theme.textTheme.titleMedium),
        const SizedBox(height: YimSpacing.xs),
        Text('uid ${me?.uid ?? '-'}', style: theme.textTheme.labelSmall),
        const SizedBox(height: YimSpacing.xl),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
          onPressed: () => _editNickname(
              context, ref, profile?.nickname ?? me?.nickname ?? ''),
          icon: const Icon(Icons.edit_outlined, size: 15),
          label: const Text('修改昵称', style: TextStyle(fontSize: 13)),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 280,
          child: Container(
            color: theme.brightness == Brightness.dark
                ? YimColors.surfaceDark
                : YimColors.surfaceLight,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(YimSpacing.xl),
                child: identity,
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: YimSpacing.xxl, vertical: YimSpacing.xl),
            children: [
              _SectionLabel('外观'),
              const _ThemeRow(),
              const SizedBox(height: YimSpacing.xl),
              _SectionLabel('账号'),
              _SettingRow(
                icon: Icons.badge_outlined,
                title: '昵称',
                subtitle: profile?.nickname ?? me?.nickname ?? '',
                onTap: () => _editNickname(
                    context, ref, profile?.nickname ?? me?.nickname ?? ''),
              ),
              _SettingRow(
                icon: Icons.tag,
                title: 'uid',
                subtitle: '${me?.uid ?? '-'}',
              ),
              const SizedBox(height: YimSpacing.xl),
              _SectionLabel('关于'),
              _SettingRow(
                  icon: Icons.info_outline, title: '版本', subtitle: '0.1.0'),
              const SizedBox(height: YimSpacing.xxl),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: YimColors.danger,
                    side: const BorderSide(color: YimColors.danger),
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('退出登录', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Fluent 设置行: 左图标+标题/描述, 右控件或箭头, hover 高亮
class _SettingRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _SettingRow(
      {required this.icon,
      required this.title,
      this.subtitle = '',
      this.onTap});
  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interactive = widget.onTap != null;
    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: YimSpacing.l, vertical: YimSpacing.m),
          decoration: BoxDecoration(
            color: _hover && interactive ? theme.hoverColor : null,
            border:
                Border(bottom: BorderSide(color: theme.dividerTheme.color!)),
          ),
          child: Row(children: [
            Icon(widget.icon, size: 20, color: theme.textTheme.bodySmall?.color),
            const SizedBox(width: YimSpacing.l),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 15)),
                    if (widget.subtitle.isNotEmpty)
                      Text(widget.subtitle,
                          style: theme.textTheme.bodySmall),
                  ]),
            ),
            if (interactive)
              Icon(Icons.chevron_right,
                  size: 18, color: theme.textTheme.bodySmall?.color),
          ]),
        ),
      ),
    );
  }
}

// 主题选择行: 跟随系统 / 浅色 / 深色
class _ThemeRow extends ConsumerWidget {
  const _ThemeRow();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: YimSpacing.l, vertical: YimSpacing.m),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).dividerTheme.color!))),
      child: Row(children: [
        Icon(Icons.contrast, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: YimSpacing.l),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('主题', style: TextStyle(fontSize: 15)),
                Text('切换动效随主题即时过渡', style: TextStyle(fontSize: 13, color: YimColors.textTertiary)),
              ]),
        ),
        SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            selectedForegroundColor: Theme.of(context).colorScheme.primary,
            visualDensity: VisualDensity.compact,
          ),
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('跟随系统', style: TextStyle(fontSize: 12))),
            ButtonSegment(value: ThemeMode.light, label: Text('浅色', style: TextStyle(fontSize: 12))),
            ButtonSegment(value: ThemeMode.dark, label: Text('深色', style: TextStyle(fontSize: 12))),
          ],
          selected: {mode},
          onSelectionChanged: (s) =>
              ref.read(themeModeProvider.notifier).set(s.first),
        ),
      ]),
    );
  }
}

class _HoverIcon extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  const _HoverIcon(
      {required this.tooltip, required this.icon, required this.onTap});
  @override
  State<_HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: CircleAvatar(
            radius: 14,
            backgroundColor:
                _hover ? Theme.of(context).colorScheme.primary : YimColors.primary,
            child: Icon(widget.icon, size: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? YimColors.onAccentDark
                    : Colors.white),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 移动: 分组卡片
// ============================================================

class _MobileProfile extends ConsumerWidget {
  const _MobileProfile();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider).value;
    final profile =
        me != null && me.uid > 0 ? ref.watch(profilesProvider(me.uid)).value : null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            YimSpacing.xl, YimSpacing.l, YimSpacing.xl, YimSpacing.xxl),
        children: [
          Column(children: [
            Stack(children: [
              Avatar(
                  uid: me?.uid ?? 0,
                  nickname: me?.nickname ?? '?',
                  avatar: profile?.avatar ?? '',
                  size: 88),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _pickAvatar(context, ref),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: YimColors.primary,
                    child: Icon(Icons.camera_alt,
                        size: 14,
                        color: theme.brightness == Brightness.dark
                            ? YimColors.onAccentDark
                            : Colors.white),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: YimSpacing.m),
            Text(profile?.nickname ?? me?.nickname ?? '…',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: YimSpacing.xs),
            Text('uid ${me?.uid ?? '-'}', style: theme.textTheme.labelSmall),
          ]),
          const SizedBox(height: YimSpacing.xxl),
          _SectionLabel('外观'),
          _Card([
            ListTile(
              leading: const Icon(Icons.contrast, size: 20),
              title: const Text('主题'),
              trailing: _ThemeDropdown(mode: ref.watch(themeModeProvider)),
            ),
          ]),
          const SizedBox(height: YimSpacing.xl),
          _SectionLabel('账号'),
          _Card([
            ListTile(
              leading: const Icon(Icons.badge_outlined, size: 20),
              title: const Text('昵称'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(profile?.nickname ?? me?.nickname ?? '',
                    style: theme.textTheme.bodySmall),
                const SizedBox(width: YimSpacing.s),
                Icon(Icons.chevron_right,
                    size: 18, color: theme.textTheme.bodySmall?.color),
              ]),
              onTap: () => _editNickname(
                  context, ref, profile?.nickname ?? me?.nickname ?? ''),
            ),
            const Divider(height: 1, indent: 52),
            ListTile(
              leading: const Icon(Icons.tag, size: 20),
              title: const Text('uid'),
              trailing: Text('${me?.uid ?? '-'}',
                  style: theme.textTheme.bodySmall),
            ),
          ]),
          const SizedBox(height: YimSpacing.xl),
          _SectionLabel('关于'),
          _Card([
            const ListTile(
              leading: Icon(Icons.info_outline, size: 20),
              title: Text('版本'),
              trailing: Text('0.1.0', style: TextStyle(fontSize: 13)),
            ),
          ]),
          const SizedBox(height: YimSpacing.xxl),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: YimColors.danger,
                side: const BorderSide(color: YimColors.danger),
              ),
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('退出登录'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeDropdown extends ConsumerWidget {
  final ThemeMode mode;
  const _ThemeDropdown({required this.mode});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<ThemeMode>(
      value: mode,
      underline: const SizedBox.shrink(),
      items: const [
        DropdownMenuItem(value: ThemeMode.system, child: Text('跟随系统')),
        DropdownMenuItem(value: ThemeMode.light, child: Text('浅色')),
        DropdownMenuItem(value: ThemeMode.dark, child: Text('深色')),
      ],
      onChanged: (m) {
        if (m != null) ref.read(themeModeProvider.notifier).set(m);
      },
    );
  }
}

// ============================================================
// 共用动作
// ============================================================

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: YimSpacing.s, left: YimSpacing.xs),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card(this.children);
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: dark ? YimColors.surfaceDark : YimColors.surfaceLight,
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
        borderRadius: BorderRadius.circular(YimRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
  final picker = ImagePicker();
  final x = await picker.pickImage(
      source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
  if (x == null) return;
  try {
    await Api.I.uploadAvatar(x.path);
    final me = ref.read(authProvider).value?.uid ?? 0;
    ref.read(profilesProvider(me).notifier).fetch(me);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('头像已更新'), behavior: SnackBarBehavior.floating));
    }
  } on ApiError catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.msg), behavior: SnackBarBehavior.floating));
    }
  }
}

Future<void> _editNickname(
    BuildContext context, WidgetRef ref, String current) async {
  final controller = TextEditingController(text: current);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('修改昵称'),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('保存')),
      ],
    ),
  );
  if (ok != true) return;
  final nick = controller.text.trim();
  if (nick.isEmpty) return;
  try {
    await Api.I.updateMe(nick);
    await ref.read(authProvider.notifier).refreshMe(nick);
    final me = ref.read(authProvider).value?.uid ?? 0;
    ref.read(profilesProvider(me).notifier).fetch(me);
  } on ApiError catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.msg), behavior: SnackBarBehavior.floating));
    }
  }
}

Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('退出登录'),
      content: const Text('退出后需要重新登录才能收发消息。'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消')),
        FilledButton(
            style: FilledButton.styleFrom(backgroundColor: YimColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('退出')),
      ],
    ),
  );
  if (ok == true) await ref.read(authProvider.notifier).logout();
}

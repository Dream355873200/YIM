// 注册: 成功即登录 (后端 register+login 幂等链路)。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/window/desktop_window.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nick = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy) return;
    if (_nick.text.trim().length < 2) {
      setState(() => _error = '昵称至少 2 个字符');
      return;
    }
    if (_pwd.text.length < 6) {
      setState(() => _error = '密码至少 6 位');
      return;
    }
    if (_pwd.text != _pwd2.text) {
      setState(() => _error = '两次密码不一致');
      return;
    }
    setState(() { _busy = true; _error = null; });
    final err = await ref
        .read(authProvider.notifier)
        .register(_nick.text.trim(), _pwd.text);
    if (!mounted) return;
    if (err != null) setState(() { _error = err; _busy = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const AppTitleBar(title: '注册新账号'),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Padding(
                padding: const EdgeInsets.all(YimSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 返回登录 (移动端用 AppBar 返回也行, 桌面无边框统一给显式入口)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('返回登录', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: YimSpacing.l),
                    TextField(
                      controller: _nick,
                      decoration: const InputDecoration(hintText: '昵称'),
                    ),
                    const SizedBox(height: YimSpacing.m),
                    TextField(
                      controller: _pwd,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: '密码 (至少 6 位)'),
                    ),
                    const SizedBox(height: YimSpacing.m),
                    TextField(
                      controller: _pwd2,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: '确认密码'),
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: YimSpacing.m),
                      Text(_error!,
                          style: const TextStyle(color: YimColors.danger)),
                    ],
                    const SizedBox(height: YimSpacing.xl),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('注册并登录'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

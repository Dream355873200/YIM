// 登录/注册: 极简两字段。dev.<uid> token 后门只存在于服务端 YIM_AUTH_MODE=dev,
// 客户端 UI 不内置任何绕过入口。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/storage/session_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/window/desktop_window.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _nick = TextEditingController();
  final _pwd = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // 预填记住的账号密码: 打开 App 停在本页, 点一下"登录"即进入
    () async {
      final pwd = await sessionStore.savedPassword();
      final nick = sessionStore.nickname;
      if (!mounted || (pwd == null && (nick == null || nick.isEmpty))) return;
      setState(() {
        if (nick != null && nick.isNotEmpty && _nick.text.isEmpty) {
          _nick.text = nick;
        }
        if (pwd != null && _pwd.text.isEmpty) _pwd.text = pwd;
      });
    }();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    final err = await ref
        .read(authProvider.notifier)
        .login(_nick.text.trim(), _pwd.text);
    if (!mounted) return;
    if (err != null) setState(() { _error = err; _busy = false; });
    // 成功: authProvider 状态翻转 → router redirect 自动跳转
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const AppTitleBar(title: 'YIM'),
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
                    Text('YIM',
                        style: Theme.of(context).textTheme.displaySmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: YimSpacing.xs),
                    Text('简单、克制的即时通讯',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: YimSpacing.xxl),
                    TextField(
                      controller: _nick,
                      decoration: const InputDecoration(hintText: '昵称'),
                      autofillHints: const [AutofillHints.username],
                    ),
                    const SizedBox(height: YimSpacing.m),
                    TextField(
                      controller: _pwd,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: '密码'),
                      autofillHints: const [AutofillHints.password],
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
                          : const Text('登录'),
                    ),
                    const SizedBox(height: YimSpacing.m),
                    OutlinedButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('注册新账号'),
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

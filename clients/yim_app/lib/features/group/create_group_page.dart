// 建群: 选好友 (多选) + 起群名 → CreateConv(CONV_GROUP)。
// 创建成功: 桌面端选中会话进三栏详情, 移动端全屏打开聊天。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/network/api.dart';
import '../../core/shell/app_shell.dart' show Avatar;
import '../../core/theme/app_theme.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});
  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final _name = TextEditingController();
  final _selected = <int>{};
  bool _creating = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_selected.length < 2) {
      setState(() => _error = '至少选择 2 位好友');
      return;
    }
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final me = ref.read(authProvider).value?.uid ?? 0;
      final rsp = await Api.I.createConv('CONV_GROUP',
          [me, ..._selected],
          name: _name.text.trim());
      final conv = G.m(rsp['conv']);
      final convId = G.i(conv['conv_id']);
      // 服务端建群到会话列表可见有延迟 (member seed), 主动重拉
      await ref.read(convListProvider.notifier).reload();
      if (!mounted) return;
      final wide = MediaQuery.sizeOf(context).width >= 900;
      if (wide) {
        ref.read(selectedConvProvider.notifier).state = convId;
        context.go('/conversations');
      } else {
        context.pushReplacement('/conversations/$convId');
      }
    } on ApiError catch (e) {
      setState(() {
        _creating = false;
        _error = e.msg;
      });
    } catch (e) {
      setState(() {
        _creating = false;
        _error = '网络错误: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final me = ref.watch(authProvider).value?.uid ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('发起群聊')),
      floatingActionButton: FloatingActionButton.extended(
              onPressed: _creating ? null : _create,
              icon: _creating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.group_add),
              label: Text(_creating
                  ? '创建中…'
                  : '创建 (${_selected.length + 1}人)')),
      body: friends.isEmpty
          ? Center(
              child: Text('还没有好友\n先去好友页添加吧',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall))
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      YimSpacing.l, YimSpacing.m, YimSpacing.l, 0),
                  child: TextField(
                    controller: _name,
                    maxLength: 32,
                    decoration: const InputDecoration(
                        labelText: '群名称',
                        hintText: '不填默认显示群聊 ID',
                        border: OutlineInputBorder(),
                        isDense: true),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        YimSpacing.l, YimSpacing.s, YimSpacing.l, 0),
                    child: Text(_error!,
                        style:
                            const TextStyle(color: YimColors.danger)),
                  ),
                const SizedBox(height: YimSpacing.s),
                for (final f in friends)
                  if (f.uid != me)
                    ListTile(
                      leading: Avatar(
                          uid: f.uid,
                          nickname: f.nickname,
                          avatar: f.avatar),
                      title: Text(f.nickname),
                      onTap: () => setState(() {
                        if (!_selected.add(f.uid)) _selected.remove(f.uid);
                      }),
                      trailing: Checkbox(
                          value: _selected.contains(f.uid),
                          onChanged: (_) => setState(() {
                                if (!_selected.add(f.uid)) {
                                  _selected.remove(f.uid);
                                }
                              })),
                    ),
              ],
            ),
    );
  }
}

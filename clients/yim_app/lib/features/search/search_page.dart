// 全局消息搜索 (里程碑13): 关键词查 MSG_TEXT, 服务端 LIKE 扫描按时间倒序。
// 结果按会话分组展示 → 点击进入会话 (第一轮不做锚点跳转定位, 结果页已带上下文)。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../core/network/api.dart';
import '../../core/shell/app_shell.dart' show Avatar;
import '../../core/theme/app_theme.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _Result {
  final int convId;
  final String text;
  final int timeMs;
  _Result(this.convId, this.text, this.timeMs);
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _kw = TextEditingController();
  Timer? _debounce;
  List<_Result> _results = [];
  bool _truncated = false;
  bool _searching = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _kw.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), _run);
  }

  Future<void> _run() async {
    final kw = _kw.text.trim();
    if (kw.isEmpty) return;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final rsp = await Api.I.searchMessages(kw);
      if (!mounted) return;
      setState(() {
        _searching = false;
        _truncated = G.b(rsp['truncated']);
        _results = [
          for (final raw in G.l(rsp['messages']))
            _Result(
                G.i(G.m(raw)['conv_id']),
                G.s(G.m(G.m(raw)['content'])['text']),
                G.i(G.m(raw)['server_time_ms'])),
        ];
      });
    } on ApiError catch (e) {
      if (mounted) setState(() { _searching = false; _error = e.msg; });
    } catch (e) {
      if (mounted) setState(() { _searching = false; _error = '网络错误: $e'; });
    }
  }

  void _open(int convId) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (wide) {
      ref.read(selectedConvProvider.notifier).state = convId;
      context.go('/conversations');
    } else {
      context.push('/conversations/$convId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final convs = ref.watch(convListProvider);
    final me = ref.watch(authProvider).value?.uid ?? 0;
    // 会话标题: 群 = 群名, 单聊 = 对端昵称 (不在会话列表时回退 id)
    String titleOf(int convId) {
      for (final c in convs) {
        if (c.convId != convId) continue;
        if (c.type == 'CONV_GROUP') return c.groupTitle;
        final peer = c.memberUids.firstWhere((u) => u != me, orElse: () => 0);
        final p = ref.watch(profilesProvider(peer)).value;
        return p?.nickname ?? 'uid $peer';
      }
      return '会话 $convId';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('搜索消息')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              YimSpacing.l, YimSpacing.m, YimSpacing.l, YimSpacing.s),
          child: TextField(
            controller: _kw,
            autofocus: true,
            onChanged: _onChanged,
            decoration: InputDecoration(
                hintText: '搜索所有聊天记录…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
        ),
        if (_searching)
          const Padding(
            padding: EdgeInsets.all(YimSpacing.l),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(YimSpacing.l),
            child: Text(_error!,
                style: const TextStyle(color: YimColors.danger)),
          ),
        if (_truncated)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: YimSpacing.l),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('仅显示最近的部分结果',
                    style: Theme.of(context).textTheme.labelSmall)),
          ),
        Expanded(
          child: _results.isEmpty && !_searching
              ? Center(
                  child: Text(
                      _kw.text.trim().isEmpty ? '输入关键词开始搜索' : '没有匹配的消息',
                      style: Theme.of(context).textTheme.bodySmall))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, i) {
                    final r = _results[i];
                    final t =
                        DateTime.fromMillisecondsSinceEpoch(r.timeMs);
                    final day = t.difference(DateTime.now()).inDays == 0
                        ? DateFormat('HH:mm').format(t)
                        : DateFormat('MM-dd HH:mm').format(t);
                    return ListTile(
                      onTap: () => _open(r.convId),
                      leading: Avatar(
                          uid: r.convId,
                          nickname: titleOf(r.convId),
                          avatar: ''),
                      title: Text(titleOf(r.convId),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(r.text,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Text(day,
                          style: Theme.of(context).textTheme.labelSmall),
                    );
                  }),
        ),
      ]),
    );
  }
}

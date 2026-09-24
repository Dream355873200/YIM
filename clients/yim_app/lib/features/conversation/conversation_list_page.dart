// 会话列表: 头像 + 标题 + 预览 + 未读角标; 下拉刷新。
// 桌面点击 → selectedConvProvider (三栏详情); 移动 → push 全屏聊天。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../core/shell/app_shell.dart' show Avatar;
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hover_row.dart';

class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});
  @override
  ConsumerState<ConversationListPage> createState() =>
      _ConversationListPageState();
}

class _ConversationListPageState extends ConsumerState<ConversationListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(convListProvider.notifier).reload());
  }

  void _open(ConvItem c) {
    final peer = c.memberUids.firstWhere(
        (u) => u != (ref.read(authProvider).value?.uid ?? 0),
        orElse: () => 0);
    ref.read(profilesProvider(peer).notifier);
    ref.read(selectedConvProvider.notifier).state = c.convId;
    if (MediaQuery.sizeOf(context).width < 900) {
      context.push('/conversations/${c.convId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final convs = ref.watch(convListProvider);
    final me = ref.watch(authProvider).value?.uid ?? 0;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final list = RefreshIndicator(
      onRefresh: () async {
        await ref.read(convListProvider.notifier).reload();
        ref.read(friendRequestsProvider.notifier).reload();
      },
      child: convs.isEmpty
          ? ListView(children: [
              const SizedBox(height: 120),
              Center(
                child: Text('还没有会话\n去好友页发起聊天吧',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ])
          : ListView.builder(
              itemCount: convs.length,
              itemBuilder: (_, i) {
                final c = convs[i];
                final isGroup = c.type == 'CONV_GROUP';
                final peer = isGroup
                    ? 0
                    : c.memberUids.firstWhere((u) => u != me,
                        orElse: () => 0);
                final profile = (!isGroup && peer > 0)
                    ? ref.watch(profilesProvider(peer)).value
                    : null;
                final title = isGroup
                    ? c.groupTitle
                    : (profile?.nickname ?? 'uid $peer');
                final selected =
                    MediaQuery.sizeOf(context).width >= 900 &&
                        ref.watch(selectedConvProvider) == c.convId;
                return HoverRow(
                  selected: selected,
                  onTap: () => _open(c),
                  child: Row(children: [
                    isGroup
                        ? Avatar(
                            uid: c.convId,
                            nickname: c.name.isNotEmpty ? c.name : '群',
                            avatar: c.avatar)
                        : Avatar(uid: peer,
                            nickname: profile?.nickname ?? '?',
                            avatar: profile?.avatar ?? ''),
                    const SizedBox(width: YimSpacing.m),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(c.preview ?? '…',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall),
                          ]),
                    ),
                    if (c.unread > 0) ...[
                      const SizedBox(width: YimSpacing.s),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: YimColors.primary,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                              c.unread > 99 ? '99+' : '${c.unread}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11))),
                    ],
                  ]),
                );
              },
            ),
    );

    // 桌面: 列表列头部由 shell 的 _ShellHeader 提供; 移动端自带头部
    if (wide) return list;
    return Scaffold(
      appBar: AppBar(title: const Text('消息'), actions: [
        IconButton(
            tooltip: '搜索消息',
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search)),
      ]),
      body: list,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/core/widgets/app_top_bar.dart';
import 'package:obee_mobile/src/features/chat/data/chat_conversation.dart';
import 'package:obee_mobile/src/features/chat/state/chat_hub_provider.dart';
import 'package:obee_mobile/src/features/chat/state/direct_chat_search_provider.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/channel_row.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/direct_conversation_row.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/direct_chat_search_field.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/unread_count_indicator.dart';

class ChatHubPage extends ConsumerStatefulWidget {
  const ChatHubPage({super.key});

  static const _minimumFloatingActionBottomInset = 96.0;

  @override
  ConsumerState<ChatHubPage> createState() => _ChatHubPageState();
}

class _ChatHubPageState extends ConsumerState<ChatHubPage> {
  final GlobalKey _directEntryMenuKey = GlobalKey();

  bool _isDirectEntryMenuOpen = false;
  double _directEntryMenuHeight = 0;

  void _setMenuOpen(bool value) {
    if (_isDirectEntryMenuOpen == value) {
      return;
    }

    setState(() {
      _isDirectEntryMenuOpen = value;
    });

    _scheduleMenuHeightMeasurement();
  }

  void _scheduleMenuHeightMeasurement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final renderBox =
          _directEntryMenuKey.currentContext?.findRenderObject() as RenderBox?;
      final measuredHeight = renderBox?.size.height ?? 0;
      if ((measuredHeight - _directEntryMenuHeight).abs() < 0.5) {
        return;
      }

      setState(() {
        _directEntryMenuHeight = measuredHeight;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(chatHubProvider.select((state) => state.errorMessage), (
      _,
      message,
    ) {
      if (message == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      ref.read(chatHubProvider.notifier).clearFeedback();
    });
    final hubState = ref.watch(chatHubProvider);
    final selectedTab = hubState.selectedTab;
    final generalUnreadCount = ref.watch(generalUnreadCountProvider);
    final directUnreadCount = ref.watch(directUnreadCountProvider);
    final directBottomInset = selectedTab == ChatHubTab.direct
        ? (_directEntryMenuHeight + 24).clamp(
            ChatHubPage._minimumFloatingActionBottomInset,
            double.infinity,
          )
        : ChatHubPage._minimumFloatingActionBottomInset;

    if (selectedTab == ChatHubTab.direct) {
      _scheduleMenuHeightMeasurement();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppTopBar(
        title: 'Trò chuyện',
        actions: [
          IconButton(
            key: const ValueKey('chat_hub_search_action'),
            tooltip: 'Tìm kiếm',
            icon: const Icon(Icons.search, size: 24),
            onPressed: () {
              if (selectedTab != ChatHubTab.direct) {
                ref.read(chatHubProvider.notifier).selectTab(ChatHubTab.direct);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    key: const ValueKey('chat_hub_page'),
                    children: [
                      _ChatHubTabBar(
                        activeTab: selectedTab,
                        generalUnreadCount: generalUnreadCount,
                        directUnreadCount: directUnreadCount,
                        onChanged: (tab) {
                          if (tab != ChatHubTab.direct) {
                            _setMenuOpen(false);
                          }

                          ref.read(chatHubProvider.notifier).selectTab(tab);
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () =>
                              ref.read(chatHubProvider.notifier).refresh(),
                          child: IndexedStack(
                            index: selectedTab.index,
                            children: [
                              _GeneralChannelPanel(
                                key: PageStorageKey('chat_hub_general_panel'),
                                contentKey: ValueKey(
                                  'chat_hub_general_content',
                                ),
                              ),
                              _DirectConversationPanel(
                                key: PageStorageKey('chat_hub_direct_panel'),
                                contentKey: ValueKey('chat_hub_direct_content'),
                                bottomInset: directBottomInset,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedTab == ChatHubTab.direct)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _DirectEntryMenu(
                      key: _directEntryMenuKey,
                      isOpen: _isDirectEntryMenuOpen,
                      onToggle: () => _setMenuOpen(!_isDirectEntryMenuOpen),
                      onOpenNewDirectChat: () {
                        _setMenuOpen(false);
                        context.push('/app/chat/new-direct');
                      },
                      onOpenGroupPreview: () {
                        _setMenuOpen(false);
                        context.push('/app/chat/prototype-group-creation');
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DirectConversationPanel extends ConsumerWidget {
  const _DirectConversationPanel({
    required this.contentKey,
    required this.bottomInset,
    super.key,
  });

  final Key contentKey;
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(directConversationsProvider);
    final query = ref.watch(directChatSearchProvider);
    final filteredConversations = ref.watch(
      filteredDirectConversationsProvider,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return conversationsAsync.when(
      data: (conversations) {
        return _DirectConversationList(
          contentKey: contentKey,
          conversations: filteredConversations,
          query: query,
          bottomInset: bottomInset,
          onQueryChanged: (value) =>
              ref.read(directChatSearchProvider.notifier).updateQuery(value),
          onResetSearch: () =>
              ref.read(directChatSearchProvider.notifier).clear(),
        );
      },
      loading: () => ListView(
        key: contentKey,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (error, stackTrace) => ListView(
        key: contentKey,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(
            'Không thể tải danh sách trò chuyện riêng.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectConversationList extends StatelessWidget {
  const _DirectConversationList({
    required this.contentKey,
    required this.conversations,
    required this.query,
    required this.bottomInset,
    required this.onQueryChanged,
    required this.onResetSearch,
  });

  final Key contentKey;
  final List<ChatConversation> conversations;
  final String query;
  final double bottomInset;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onResetSearch;

  @override
  Widget build(BuildContext context) {
    final hasNoConversations = query.isEmpty && conversations.isEmpty;
    final hasNoResults = query.isNotEmpty && conversations.isEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    if (hasNoConversations) {
      return _DirectConversationEmptyState(contentKey: contentKey);
    }

    return ListView.separated(
      key: contentKey,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomInset),
      itemCount: hasNoResults ? 2 : conversations.length + 1,
      separatorBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: 16);
        }

        return Divider(height: 1, color: colorScheme.outlineVariant);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              DirectChatSearchField(
                query: query,
                onChanged: onQueryChanged,
                onClear: onResetSearch,
              ),
            ],
          );
        }

        if (hasNoResults) {
          return _DirectConversationNoResults(
            query: query,
            onResetSearch: onResetSearch,
          );
        }

        final conversation = conversations[index - 1];

        return DirectConversationRow(
          conversation: conversation,
          onTap: () => context.push('/app/chat/thread/${conversation.id}'),
        );
      },
    );
  }
}

class _DirectConversationEmptyState extends StatelessWidget {
  const _DirectConversationEmptyState({required this.contentKey});

  final Key contentKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      key: contentKey,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      children: [
        Container(
          key: const ValueKey('direct_chat_empty_state'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chưa có cuộc trò chuyện nào.',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dùng nút ở góc dưới để bắt đầu trò chuyện hoặc xem thử tạo nhóm.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DirectEntryMenu extends StatelessWidget {
  const _DirectEntryMenu({
    required this.isOpen,
    required this.onToggle,
    required this.onOpenNewDirectChat,
    required this.onOpenGroupPreview,
    super.key,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onOpenNewDirectChat;
  final VoidCallback onOpenGroupPreview;

  @override
  Widget build(BuildContext context) {
    final triggerLabel = isOpen
        ? 'Đóng menu bắt đầu trò chuyện'
        : 'Mở menu bắt đầu trò chuyện';
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('chat_hub_entry_menu'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isOpen
              ? Column(
                  key: const ValueKey('chat_hub_entry_menu_actions'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _DirectEntryActionButton(
                      key: const ValueKey(
                        'chat_hub_group_creation_menu_action',
                      ),
                      icon: Icons.groups_2_outlined,
                      label: 'Tạo nhóm (Bản xem trước)',
                      onPressed: onOpenGroupPreview,
                    ),
                    const SizedBox(height: 12),
                    _DirectEntryActionButton(
                      key: const ValueKey('chat_hub_start_direct_menu_action'),
                      icon: Icons.chat_bubble_outline,
                      label: 'Bắt đầu trò chuyện',
                      onPressed: onOpenNewDirectChat,
                    ),
                    const SizedBox(height: 12),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        Semantics(
          button: true,
          label: triggerLabel,
          child: Tooltip(
            message: triggerLabel,
            child: Material(
              color: colorScheme.primary,
              elevation: 8,
              shadowColor: const Color(0x22000000),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const ValueKey('chat_hub_start_direct_fab'),
                onTap: onToggle,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Icon(
                      isOpen ? Icons.close_rounded : Icons.add_outlined,
                      key: ValueKey(isOpen),
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DirectEntryActionButton extends StatelessWidget {
  const _DirectEntryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary,
      elevation: 5,
      shadowColor: const Color(0x16000000),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.onPrimary),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectConversationNoResults extends StatelessWidget {
  const _DirectConversationNoResults({
    required this.query,
    required this.onResetSearch,
  });

  final String query;
  final VoidCallback onResetSearch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey('direct_chat_no_results'),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Không có cuộc trò chuyện phù hợp.',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Không tìm thấy cuộc trò chuyện nào khớp với "$query".',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            key: const ValueKey('direct_chat_no_results_reset_button'),
            onPressed: onResetSearch,
            child: const Text('Xóa tìm kiếm'),
          ),
        ],
      ),
    );
  }
}

class _GeneralChannelPanel extends ConsumerWidget {
  const _GeneralChannelPanel({required this.contentKey, super.key});

  final Key contentKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(generalChannelsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return channelsAsync.when(
      data: (channels) =>
          _GeneralChannelList(contentKey: contentKey, channels: channels),
      loading: () => ListView(
        key: contentKey,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (error, stackTrace) => ListView(
        key: contentKey,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(
            'Không thể tải danh sách kênh chung.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralChannelList extends StatelessWidget {
  const _GeneralChannelList({required this.contentKey, required this.channels});

  final Key contentKey;
  final List<ChatConversation> channels;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      key: contentKey,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: channels.length,
      separatorBuilder: (context, index) {
        return Divider(height: 1, color: colorScheme.outlineVariant);
      },
      itemBuilder: (context, index) {
        final channel = channels[index];

        return ChannelRow(
          channel: channel,
          onTap: () => context.push('/app/chat/thread/${channel.id}'),
        );
      },
    );
  }
}

class _ChatHubTabBar extends StatelessWidget {
  const _ChatHubTabBar({
    required this.activeTab,
    required this.generalUnreadCount,
    required this.directUnreadCount,
    required this.onChanged,
  });

  final ChatHubTab activeTab;
  final int? generalUnreadCount;
  final int? directUnreadCount;
  final ValueChanged<ChatHubTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ChatHubTabButton(
            key: const ValueKey('chat_hub_tab_general'),
            label: 'Chung',
            unreadCount: generalUnreadCount,
            selected: activeTab == ChatHubTab.general,
            onTap: () => onChanged(ChatHubTab.general),
          ),
          _ChatHubTabButton(
            key: const ValueKey('chat_hub_tab_direct'),
            label: 'Riêng tư',
            unreadCount: directUnreadCount,
            selected: activeTab == ChatHubTab.direct,
            onTap: () => onChanged(ChatHubTab.direct),
          ),
        ],
      ),
    );
  }
}

class _ChatHubTabButton extends StatelessWidget {
  const _ChatHubTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.unreadCount,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? unreadCount;

  @override
  Widget build(BuildContext context) {
    final hasUnreadCount = unreadCount != null && unreadCount! > 0;
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = selected
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: selected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          elevation: selected ? 1 : 0,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: foregroundColor,
                        ),
                      ),
                      if (hasUnreadCount)
                        UnreadCountIndicator(
                          count: unreadCount!,
                          dimmed: !selected,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

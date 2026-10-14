import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/core/widgets/standalone_page_header.dart';
import 'package:obee_mobile/src/features/chat/data/chat_coworker.dart';
import 'package:obee_mobile/src/features/chat/state/new_direct_chat_provider.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/direct_chat_search_field.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

class NewDirectChatPage extends ConsumerWidget {
  const NewDirectChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coworkersAsync = ref.watch(coworkerPickerProvider);
    final query = ref.watch(newDirectChatSearchProvider);
    final filteredCoworkers = ref.watch(filteredCoworkerPickerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: StandalonePageHeader(
        title: 'Bắt đầu trò chuyện',
        leading: HeaderActionButton(
          key: const ValueKey('new_direct_chat_back_button'),
          tooltip: 'Quay lại',
          icon: Icons.arrow_back_ios_new,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                key: const ValueKey('new_direct_chat_page'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn đồng nghiệp để mở lại cuộc trò chuyện 1:1 hiện có hoặc bắt đầu cuộc trò chuyện mới.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DirectChatSearchField(
                    query: query,
                    onChanged: (value) => ref
                        .read(newDirectChatSearchProvider.notifier)
                        .updateQuery(value),
                    onClear: () =>
                        ref.read(newDirectChatSearchProvider.notifier).clear(),
                    fieldKey: const ValueKey('new_direct_chat_search_field'),
                    resetButtonKey: const ValueKey(
                      'new_direct_chat_search_reset_button',
                    ),
                    hintText: 'Tìm đồng nghiệp',
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: coworkersAsync.when(
                      data: (coworkers) {
                        final hasNoResults =
                            query.isNotEmpty && filteredCoworkers.isEmpty;
                        if (hasNoResults) {
                          return _NewDirectChatNoResults(query: query);
                        }

                        final visibleCoworkers = query.isEmpty
                            ? coworkers
                            : filteredCoworkers;

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: visibleCoworkers.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: colorScheme.outlineVariant,
                          ),
                          itemBuilder: (context, index) {
                            final coworker = visibleCoworkers[index];

                            return _CoworkerRow(
                              coworker: coworker,
                              onTap: () async {
                                final conversationId = await ref
                                    .read(newDirectChatControllerProvider)
                                    .openConversationForCoworker(coworker.id);
                                if (!context.mounted) {
                                  return;
                                }

                                context.push(
                                  '/app/chat/thread/$conversationId',
                                );
                              },
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Không thể tải danh sách đồng nghiệp.\n$error',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoworkerRow extends StatelessWidget {
  const _CoworkerRow({required this.coworker, required this.onTap});

  final ChatCoworker coworker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      key: ValueKey('new_direct_chat_coworker_${coworker.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      leading: _CoworkerAvatar(coworker: coworker),
      title: Text(
        coworker.displayName,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        coworker.subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _CoworkerAvatar extends StatelessWidget {
  const _CoworkerAvatar({required this.coworker});

  final ChatCoworker coworker;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatar(
      key: ValueKey('new_direct_chat_avatar_${coworker.id}'),
      user: coworker.user,
      size: 44,
    );
  }
}

class _NewDirectChatNoResults extends StatelessWidget {
  const _NewDirectChatNoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Không tìm thấy đồng nghiệp phù hợp.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Không có đồng nghiệp nào khớp với "$query".',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

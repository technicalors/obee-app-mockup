import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/features/chat/data/chat_coworker.dart';
import 'package:obee_mobile/src/features/chat/state/group_creation_preview_provider.dart';
import 'package:obee_mobile/src/features/chat/state/new_direct_chat_provider.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/direct_chat_search_field.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

class GroupCreationPreviewPage extends ConsumerWidget {
  const GroupCreationPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewState = ref.watch(groupCreationPreviewProvider);
    final coworkersAsync = ref.watch(coworkerPickerProvider);
    final filteredCoworkers = ref.watch(
      filteredGroupCreationPreviewCoworkersProvider,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                key: const ValueKey('group_creation_preview_page'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        key: const ValueKey(
                          'group_creation_preview_back_button',
                        ),
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        tooltip: 'Quay lại',
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Tạo nhóm (Bản xem trước)',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chỉ để xem trước',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Luồng này chỉ để xem thử, chưa tạo nhóm thật trong bản phát hành này.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey('group_creation_preview_name_input'),
                    onChanged: (value) => ref
                        .read(groupCreationPreviewProvider.notifier)
                        .updateGroupName(value),
                    decoration: InputDecoration(
                      labelText: 'Tên nhóm',
                      hintText: 'Nhập tên nhóm để xem trước',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DirectChatSearchField(
                    query: previewState.searchQuery,
                    onChanged: (value) => ref
                        .read(groupCreationPreviewProvider.notifier)
                        .updateSearchQuery(value),
                    onClear: () => ref
                        .read(groupCreationPreviewProvider.notifier)
                        .clearSearch(),
                    fieldKey: const ValueKey(
                      'group_creation_preview_search_field',
                    ),
                    resetButtonKey: const ValueKey(
                      'group_creation_preview_search_reset_button',
                    ),
                    hintText: 'Tìm thành viên',
                    resetTooltip: 'Xóa tìm kiếm thành viên',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Đã chọn ${previewState.selectedCoworkerIds.length} thành viên',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: coworkersAsync.when(
                      data: (coworkers) {
                        if (previewState.searchQuery.isNotEmpty &&
                            filteredCoworkers.isEmpty) {
                          return _GroupCreationPreviewNoResults(
                            onResetSearch: () => ref
                                .read(groupCreationPreviewProvider.notifier)
                                .clearSearch(),
                          );
                        }

                        final visibleCoworkers =
                            previewState.searchQuery.isEmpty
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
                            final isSelected = previewState.selectedCoworkerIds
                                .contains(coworker.id);

                            return _GroupCreationCoworkerRow(
                              coworker: coworker,
                              isSelected: isSelected,
                              onTap: () => ref
                                  .read(groupCreationPreviewProvider.notifier)
                                  .toggleCoworker(coworker.id),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Không thể tải danh sách thành viên.\n$error',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: const ValueKey(
                        'group_creation_preview_submit_button',
                      ),
                      onPressed: null,
                      icon: const Icon(Icons.groups_2_outlined),
                      label: const Text('Tạo nhóm (Sắp có)'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hành động cuối hiện chưa hoạt động trong giai đoạn xem trước.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

class _GroupCreationCoworkerRow extends StatelessWidget {
  const _GroupCreationCoworkerRow({
    required this.coworker,
    required this.isSelected,
    required this.onTap,
  });

  final ChatCoworker coworker;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CheckboxListTile(
      key: ValueKey('group_creation_preview_member_${coworker.id}'),
      value: isSelected,
      onChanged: (_) => onTap(),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      secondary: ProfileAvatar(
        key: ValueKey('group_creation_preview_avatar_${coworker.id}'),
        user: coworker.user,
        size: 44,
      ),
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
    );
  }
}

class _GroupCreationPreviewNoResults extends StatelessWidget {
  const _GroupCreationPreviewNoResults({required this.onResetSearch});

  final VoidCallback onResetSearch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      key: const ValueKey('group_creation_preview_no_results'),
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Không tìm thấy thành viên phù hợp.',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Thử thay đổi từ khóa tìm kiếm để tiếp tục xem trước.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: const ValueKey(
              'group_creation_preview_no_results_reset_button',
            ),
            onPressed: onResetSearch,
            child: const Text('Xóa tìm kiếm'),
          ),
        ),
      ],
    );
  }
}

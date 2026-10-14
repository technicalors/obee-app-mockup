import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/core/widgets/standalone_page_header.dart';
import 'package:obee_mobile/src/features/chat/data/chat_group_info.dart';
import 'package:obee_mobile/src/features/chat/state/group_info_provider.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

class GroupInfoPage extends ConsumerWidget {
  const GroupInfoPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupInfoAsync = ref.watch(groupInfoProvider(conversationId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: StandalonePageHeader(
        title: 'Thông tin nhóm',
        leading: HeaderActionButton(
          key: const ValueKey('group_info_back_button'),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: groupInfoAsync.when(
                data: (groupInfo) => ListView(
                  key: const ValueKey('group_info_page'),
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      groupInfo.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${groupInfo.members.length} thành viên',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Thành viên',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final member in groupInfo.members)
                      _GroupMemberRow(member: member),
                    const SizedBox(height: 24),
                    Text(
                      'Tác vụ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const ValueKey('group_info_rename_action'),
                      onPressed: groupInfo.canRename ? () {} : null,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Đổi tên nhóm (Sắp có)'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const ValueKey('group_info_leave_action'),
                      onPressed: groupInfo.canLeave ? () {} : null,
                      icon: const Icon(Icons.logout),
                      label: const Text('Rời nhóm (Sắp có)'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Các tác vụ này hiện chỉ để xem trước trong giai đoạn này.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Không thể tải thông tin nhóm.\n$error',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
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

class _GroupMemberRow extends StatelessWidget {
  const _GroupMemberRow({required this.member});

  final ChatGroupMember member;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ProfileAvatar(
            key: ValueKey('group_info_avatar_${member.id}'),
            user: member.user,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  member.isCurrentUser
                      ? '${member.subtitle} • Bạn'
                      : member.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/chat/data/chat_conversation.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/chat_conversation_avatar.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/unread_count_indicator.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

class DirectConversationRow extends StatelessWidget {
  const DirectConversationRow({
    required this.conversation,
    this.onTap,
    super.key,
  });

  final ChatConversation conversation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label:
          '${conversation.title}, ${conversation.isGroupConversation ? 'cuộc trò chuyện nhóm' : 'cuộc trò chuyện 1:1'}, ${conversation.unreadStatusLabel}, ${conversation.timestampLabel}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('direct_conversation_${conversation.id}'),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DirectConversationAvatar(conversation: conversation),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        conversation.previewText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: conversation.hasUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      conversation.timestampLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: conversation.hasUnread
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: conversation.hasUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 20,
                      child: conversation.hasUnread
                          ? UnreadCountIndicator(
                              key: ValueKey(
                                'direct_conversation_unread_${conversation.id}',
                              ),
                              count: conversation.unreadCount,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DirectConversationAvatar extends StatelessWidget {
  const _DirectConversationAvatar({required this.conversation});

  final ChatConversation conversation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (conversation.avatarKind == ChatConversationAvatarKind.person) {
      return ProfileAvatar(
        key: ValueKey('direct_conversation_avatar_${conversation.id}'),
        user: conversation.participantUser!,
        size: 44,
      );
    }

    return ChatConversationAvatar(
      key: ValueKey('direct_conversation_avatar_${conversation.id}'),
      icon: Icons.group_outlined,
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
    );
  }
}

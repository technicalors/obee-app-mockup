import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/chat/data/chat_conversation.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/chat_conversation_avatar.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/unread_count_indicator.dart';

class ChannelRow extends StatelessWidget {
  const ChannelRow({required this.channel, this.onTap, super.key});

  final ChatConversation channel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label:
          '${channel.title}, ${channel.isReadOnly ? 'kênh chỉ đọc' : 'kênh có thể trả lời'}, '
          '${channel.hasUnread ? '${channel.unreadCount} chưa đọc' : 'không có tin chưa đọc'}, ${channel.timestampLabel}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('general_channel_${channel.id}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChannelAvatar(channel: channel),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              channel.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (channel.isReadOnly) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit_off_outlined,
                              key: ValueKey(
                                'general_channel_read_only_icon_${channel.id}',
                              ),
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        channel.previewText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: channel.hasUnread
                              ? FontWeight.w600
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
                      channel.timestampLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: channel.hasUnread
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: channel.hasUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 20,
                      child: channel.hasUnread
                          ? UnreadCountIndicator(
                              key: ValueKey(
                                'general_channel_unread_${channel.id}',
                              ),
                              count: channel.unreadCount,
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

class _ChannelAvatar extends StatelessWidget {
  const _ChannelAvatar({required this.channel});

  final ChatConversation channel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChatConversationAvatar(
      key: ValueKey('general_channel_avatar_${channel.id}'),
      icon: switch (channel.avatarKind) {
        ChatConversationAvatarKind.announcement => Icons.campaign_outlined,
        ChatConversationAvatarKind.organization => Icons.apartment_outlined,
        ChatConversationAvatarKind.group => Icons.group_outlined,
        ChatConversationAvatarKind.person => Icons.person_outline,
      },
      backgroundColor:
          channel.avatarKind == ChatConversationAvatarKind.announcement
          ? colorScheme.tertiaryContainer
          : colorScheme.primaryContainer,
      foregroundColor:
          channel.avatarKind == ChatConversationAvatarKind.announcement
          ? colorScheme.onTertiaryContainer
          : colorScheme.onPrimaryContainer,
    );
  }
}

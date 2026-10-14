import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/chat/data/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.showSenderLabel,
    super.key,
  });

  final ChatMessage message;
  final bool showSenderLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = message.isSelf
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final textColor = message.isSelf
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final alignment = message.isSelf
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final keyPrefix = message.isSelf
        ? 'chat_message_self_'
        : 'chat_message_other_';

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          key: ValueKey('$keyPrefix${message.id}'),
          crossAxisAlignment: message.isSelf
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!message.isSelf && showSenderLabel) ...[
              Text(
                key: ValueKey('chat_message_sender_${message.id}'),
                message.senderName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
            ],
            DecoratedBox(
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(
                  message.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

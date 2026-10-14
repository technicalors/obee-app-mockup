import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:obee_mobile/src/features/chat/data/chat_message.dart';
import 'package:obee_mobile/src/features/chat/data/chat_thread.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/chat_message_bubble.dart';

class ChatThreadList extends StatelessWidget {
  const ChatThreadList({
    required this.thread,
    required this.scrollController,
    super.key,
  });

  final ChatThread thread;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (thread.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Chưa có tin nhắn nào.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final entries = _buildEntries(thread.messages);

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];

        return switch (entry) {
          _DaySeparatorEntry(label: final label) => Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          _MessageEntry(message: final message) => ChatMessageBubble(
            message: message,
            showSenderLabel: thread.showsSenderLabels,
          ),
        };
      },
    );
  }

  List<_ThreadEntry> _buildEntries(List<ChatMessage> messages) {
    final entries = <_ThreadEntry>[];
    DateTime? lastDay;

    for (final message in messages) {
      final day = DateTime(
        message.sentAt.year,
        message.sentAt.month,
        message.sentAt.day,
      );

      if (lastDay != day) {
        entries.add(_DaySeparatorEntry(_labelForDay(day)));
        lastDay = day;
      }

      entries.add(_MessageEntry(message));
    }

    return entries;
  }

  String _labelForDay(DateTime day) {
    final today = DateTime(2026, 6, 14);
    final yesterday = DateTime(2026, 6, 13);

    if (day == today) {
      return 'Hôm nay';
    }

    if (day == yesterday) {
      return 'Hôm qua';
    }

    return DateFormat('d MMM', 'vi').format(day);
  }
}

sealed class _ThreadEntry {
  const _ThreadEntry();
}

class _DaySeparatorEntry extends _ThreadEntry {
  const _DaySeparatorEntry(this.label);

  final String label;
}

class _MessageEntry extends _ThreadEntry {
  const _MessageEntry(this.message);

  final ChatMessage message;
}

import 'package:flutter/material.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    required this.controller,
    required this.enabled,
    required this.onSend,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('chat_thread_composer_input'),
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(hintText: 'Nhập tin nhắn'),
            ),
          ),
          const SizedBox(width: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: enabled
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              key: const ValueKey('chat_thread_send_button'),
              onPressed: onSend,
              icon: Icon(
                Icons.send_rounded,
                color: enabled
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Gửi',
            ),
          ),
        ],
      ),
    );
  }
}

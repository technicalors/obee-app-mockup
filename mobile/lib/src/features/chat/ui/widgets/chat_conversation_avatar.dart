import 'package:flutter/material.dart';

class ChatConversationAvatar extends StatelessWidget {
  const ChatConversationAvatar({
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 22,
        color: foregroundColor ?? colorScheme.onPrimaryContainer,
      ),
    );
  }
}

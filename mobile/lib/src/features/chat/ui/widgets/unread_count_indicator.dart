import 'package:flutter/material.dart';

class UnreadCountIndicator extends StatelessWidget {
  const UnreadCountIndicator({
    required this.count,
    this.dimmed = false,
    super.key,
  });

  final int count;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: dimmed
            ? colorScheme.primary.withValues(alpha: 0.72)
            : colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: dimmed
                ? colorScheme.onSurfaceVariant
                : colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

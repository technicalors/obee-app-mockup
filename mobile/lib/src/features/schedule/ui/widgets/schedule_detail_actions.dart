import 'package:flutter/material.dart';

class ScheduleDetailActions extends StatelessWidget {
  const ScheduleDetailActions({
    required this.canReuse,
    required this.canEdit,
    required this.canDelete,
    required this.canJoin,
    required this.canLeave,
    required this.busy,
    required this.onBack,
    required this.onReuse,
    required this.onJoin,
    required this.onLeave,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  final bool canReuse;
  final bool canEdit;
  final bool canDelete;
  final bool canJoin;
  final bool canLeave;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onReuse;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outlinedStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 44),
      side: BorderSide(color: colorScheme.outlineVariant),
    );
    final destructiveStyle = FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 44),
      backgroundColor: colorScheme.error,
      foregroundColor: colorScheme.onError,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: busy ? null : onBack,
          style: outlinedStyle,
          child: const Text('Quay lại'),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canReuse && (canJoin || canLeave)) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: outlinedStyle,
                      onPressed: busy ? null : onReuse,
                      child: const Text('Dùng lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: canJoin
                        ? FilledButton(
                            style: fullWidthFilledButtonStyle,
                            onPressed: busy ? null : onJoin,
                            child: const Text('Tham gia'),
                          )
                        : OutlinedButton(
                            style: outlinedStyle,
                            onPressed: busy ? null : onLeave,
                            child: const Text('Rời lịch'),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (canReuse && !(canJoin || canLeave)) ...[
              OutlinedButton(
                style: outlinedStyle,
                onPressed: busy ? null : onReuse,
                child: const Text('Dùng lại'),
              ),
              const SizedBox(height: 12),
            ],
            if (canJoin && !canReuse) ...[
              FilledButton(
                style: fullWidthFilledButtonStyle,
                onPressed: busy ? null : onJoin,
                child: const Text('Tham gia'),
              ),
              const SizedBox(height: 12),
            ],
            if (canLeave && !canReuse) ...[
              OutlinedButton(
                style: outlinedStyle,
                onPressed: busy ? null : onLeave,
                child: const Text('Rời lịch'),
              ),
              const SizedBox(height: 12),
            ],
            if (canDelete) ...[
              FilledButton(
                style: destructiveStyle,
                onPressed: busy ? null : onDelete,
                child: const Text('Xóa'),
              ),
              const SizedBox(height: 12),
            ],
            if (canEdit) ...[
              FilledButton(
                style: fullWidthFilledButtonStyle,
                onPressed: busy ? null : onEdit,
                child: const Text('Chỉnh sửa'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

final fullWidthFilledButtonStyle = FilledButton.styleFrom(
  minimumSize: const Size(double.infinity, 44),
);

final fullWidthOutlinedButtonStyle = OutlinedButton.styleFrom(
  minimumSize: const Size(double.infinity, 44),
);

final dialogCancelButtonStyle = OutlinedButton.styleFrom(
  minimumSize: const Size(double.infinity, 44),
);

final destructiveFilledButtonStyle = FilledButton.styleFrom(
  minimumSize: const Size(double.infinity, 44),
);

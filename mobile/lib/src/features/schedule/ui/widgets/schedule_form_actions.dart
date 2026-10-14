import 'package:flutter/material.dart';

class ScheduleFormActionsSection extends StatelessWidget {
  const ScheduleFormActionsSection({
    super.key,
    required this.isSubmitting,
    required this.isEditing,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final bool isEditing;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          label: const Text('Hủy bỏ'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onSubmit,
          style: FilledButton.styleFrom(foregroundColor: colorScheme.onPrimary),
          child: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Lưu thay đổi' : 'Tạo lịch trình'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_form_controller.dart';

class ScheduleFormDetailsSection extends StatelessWidget {
  const ScheduleFormDetailsSection({
    super.key,
    required this.formState,
    required this.onAddressChanged,
    required this.onNoteChanged,
    required this.onPrivacyChanged,
    required this.onIsGeneralChanged,
    required this.onHasReminderChanged,
    required this.onRemindValueChanged,
    required this.onRemindRangeChanged,
  });

  final ScheduleFormState formState;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<ScheduleEventPrivacy?>? onPrivacyChanged;
  final ValueChanged<bool>? onIsGeneralChanged;
  final ValueChanged<bool>? onHasReminderChanged;
  final ValueChanged<String> onRemindValueChanged;
  final ValueChanged<ScheduleEventRemindRange?>? onRemindRangeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inputTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: formState.physicalAddress,
          style: inputTextStyle,
          decoration: const InputDecoration(labelText: 'Địa chỉ'),
          enabled: !formState.isSubmitting,
          onChanged: onAddressChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formState.note,
          style: inputTextStyle,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Ghi chú'),
          enabled: !formState.isSubmitting,
          onChanged: onNoteChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ScheduleEventPrivacy>(
          initialValue: formState.privacy,
          style: inputTextStyle,
          items: [
            for (final item in ScheduleEventPrivacy.values)
              DropdownMenuItem(value: item, child: Text(item.label)),
          ],
          onChanged: onPrivacyChanged,
          decoration: const InputDecoration(labelText: 'Quyền riêng tư'),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: formState.isGeneral,
          onChanged: onIsGeneralChanged,
          title: Text(
            'Lịch công ty',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: formState.hasReminder,
          onChanged: onHasReminderChanged,
          title: Text(
            'Bật nhắc lịch',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (formState.hasReminder) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: formState.remindValue,
                  style: inputTextStyle,
                  decoration: const InputDecoration(labelText: 'Giá trị'),
                  keyboardType: TextInputType.number,
                  enabled: !formState.isSubmitting,
                  onChanged: onRemindValueChanged,
                  validator: (value) {
                    if (!formState.hasReminder) {
                      return null;
                    }

                    if (value == null || value.isEmpty) {
                      return 'Nhập thời điểm nhắc lịch.';
                    }

                    final parsed = int.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Số phải lớn hơn 0.';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<ScheduleEventRemindRange>(
                  initialValue: formState.remindRange,
                  style: inputTextStyle,
                  items: [
                    for (final item in ScheduleEventRemindRange.values)
                      DropdownMenuItem(value: item, child: Text(item.label)),
                  ],
                  onChanged: onRemindRangeChanged,
                  decoration: const InputDecoration(labelText: 'Đơn vị'),
                  validator: (value) {
                    if (formState.hasReminder && value == null) {
                      return 'Chọn đơn vị.';
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

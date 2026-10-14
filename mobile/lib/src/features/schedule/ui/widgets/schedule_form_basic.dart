import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_form_controller.dart';

class ScheduleFormBasicSection extends StatelessWidget {
  const ScheduleFormBasicSection({
    super.key,
    required this.formState,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onScheduleTypeChanged,
  });

  final ScheduleFormState formState;
  final ValueChanged<ScheduleEventType?>? onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<ScheduleEventScheduleType?>? onScheduleTypeChanged;

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
        DropdownButtonFormField<ScheduleEventType>(
          initialValue: formState.type,
          style: inputTextStyle,
          items: [
            for (final item in ScheduleEventType.values)
              DropdownMenuItem(value: item, child: Text(item.label)),
          ],
          onChanged: onTypeChanged,
          decoration: const InputDecoration(labelText: 'Loại lịch trình'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formState.title,
          style: inputTextStyle,
          decoration: const InputDecoration(labelText: 'Tiêu đề'),
          onChanged: onTitleChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tiêu đề.';
            }

            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ScheduleEventScheduleType>(
          initialValue: formState.scheduleType,
          style: inputTextStyle,
          items: [
            for (final item in ScheduleEventScheduleType.values)
              DropdownMenuItem(value: item, child: Text(item.label)),
          ],
          onChanged: onScheduleTypeChanged,
          decoration: const InputDecoration(labelText: 'Kiểu lịch'),
        ),
      ],
    );
  }
}

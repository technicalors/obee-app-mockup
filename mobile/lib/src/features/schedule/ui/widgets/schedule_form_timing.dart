import 'package:flutter/material.dart';
import 'package:obee_mobile/src/core/widgets/date_picker_field.dart';
import 'package:obee_mobile/src/core/widgets/time_picker_field.dart';
import 'package:obee_mobile/src/core/widgets/tree_select.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_repeat_options.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_form_controller.dart';

class ScheduleFormTimingSection extends StatelessWidget {
  const ScheduleFormTimingSection({
    super.key,
    required this.formState,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onRepeatTypeChanged,
    required this.onRepeatPatternChanged,
  });

  final ScheduleFormState formState;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;
  final ValueChanged<ScheduleEventRepeatType?>? onRepeatTypeChanged;
  final ValueChanged<Set<String>> onRepeatPatternChanged;

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
        Row(
          children: [
            Expanded(
              child: DatePickerField(
                value: formState.startDate,
                labelText: 'Ngày bắt đầu',
                hintText: 'DD/MM/YYYY',
                enabled: !formState.isSubmitting,
                formatter: formatDisplayDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                onChanged: onStartDateChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DatePickerField(
                value: formState.endDate,
                hintText: 'DD/MM/YYYY',
                labelText: 'Ngày kết thúc',
                enabled: !formState.isSubmitting,
                formatter: formatDisplayDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                onChanged: onEndDateChanged,
              ),
            ),
          ],
        ),
        if (formState.scheduleType !=
            ScheduleEventScheduleType.multipleDays) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TimePickerField(
                  value: formState.startTime,
                  labelText: 'Thời điểm bắt đầu',
                  hintText: 'HH:mm',
                  enabled: !formState.isSubmitting,
                  formatter: formatApiTime,
                  onChanged: onStartTimeChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TimePickerField(
                  value: formState.endTime,
                  labelText: 'Thời điểm kết thúc',
                  hintText: 'HH:mm',
                  enabled: !formState.isSubmitting,
                  formatter: formatApiTime,
                  onChanged: onEndTimeChanged,
                ),
              ),
            ],
          ),
        ],
        if (formState.scheduleType == ScheduleEventScheduleType.repeat) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<ScheduleEventRepeatType>(
            initialValue: formState.repeatType,
            style: inputTextStyle,
            items: [
              for (final item in ScheduleEventRepeatType.values)
                DropdownMenuItem(value: item, child: Text(item.label)),
            ],
            onChanged: onRepeatTypeChanged,
            decoration: const InputDecoration(labelText: 'Chu kỳ lặp lại'),
          ),
          if (formState.repeatType == ScheduleEventRepeatType.weekly ||
              formState.repeatType == ScheduleEventRepeatType.monthly) ...[
            const SizedBox(height: 16),
            TreeSelect(
              fieldKey: const ValueKey('schedule-repeat-pattern-field'),
              sheetKey: const ValueKey('schedule-repeat-pattern-sheet'),
              searchFieldKey: const ValueKey('schedule-repeat-pattern-search'),
              clearButtonKey: const ValueKey('schedule-clear-repeat-pattern'),
              title: formState.repeatType == ScheduleEventRepeatType.weekly
                  ? 'Thứ lặp lại'
                  : 'Ngày lặp lại',
              searchHintText:
                  formState.repeatType == ScheduleEventRepeatType.weekly
                  ? 'Tìm thứ lặp lại'
                  : 'Tìm ngày lặp lại',
              groups: buildRepeatPatternGroups(formState.repeatType!),
              selectedIds: formState.repeatPattern,
              enabled: !formState.isSubmitting,
              emptyText: 'Không tìm thấy lựa chọn phù hợp.',
              onChanged: onRepeatPatternChanged,
              groupKeyBuilder: (group) =>
                  ValueKey('schedule-repeat-group-${group.id}'),
              itemKeyBuilder: (group, item) =>
                  ValueKey('schedule-repeat-item-${group.id}-${item.id}'),
            ),
          ],
        ],
      ],
    );
  }
}

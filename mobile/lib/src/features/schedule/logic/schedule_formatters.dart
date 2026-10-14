import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';

String formatApiDate(DateTime value) {
  final normalized = value;
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}

String formatApiDateTime(DateTime value) {
  final normalized = value;
  return '${formatApiDate(normalized)} '
      '${normalized.hour.toString().padLeft(2, '0')}:'
      '${normalized.minute.toString().padLeft(2, '0')}:00';
}

String formatApiTime(TimeOfDay value) {
  return '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

String formatDisplayDate(DateTime value) {
  final normalized = value;
  return '${normalized.day.toString().padLeft(2, '0')}/'
      '${normalized.month.toString().padLeft(2, '0')}/'
      '${normalized.year.toString().padLeft(4, '0')}';
}

String formatScheduleWeekday(DateTime value) {
  return switch (value.weekday) {
    DateTime.monday => 'Thứ Hai',
    DateTime.tuesday => 'Thứ Ba',
    DateTime.wednesday => 'Thứ Tư',
    DateTime.thursday => 'Thứ Năm',
    DateTime.friday => 'Thứ Sáu',
    DateTime.saturday => 'Thứ Bảy',
    DateTime.sunday => 'Chủ Nhật',
    _ => '',
  };
}

String formatScheduleDateWithWeekday(DateTime value) {
  return '${formatScheduleWeekday(value)}, ${formatDisplayDate(value)}';
}

String formatDisplayTime(TimeOfDay value) {
  return '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

String formatScheduleTime(DateTime value) {
  return formatDisplayTime(TimeOfDay.fromDateTime(value));
}

String formatTimelineDate(DateTime value) {
  final normalized = value;

  return '${normalized.day.toString().padLeft(2, '0')}/'
      '${normalized.month.toString().padLeft(2, '0')}';
}

final class ScheduleTimelineValue {
  const ScheduleTimelineValue({required this.primary, this.secondary});

  final String primary;
  final String? secondary;
}

List<ScheduleTimelineValue> formatScheduleTimelineValues(
  ScheduleModel schedule,
) {
  final start = schedule.start;
  final end = schedule.end;
  final spansMultipleDates =
      start.year != end.year ||
      start.month != end.month ||
      start.day != end.day;
  final isMultipleDay =
      schedule.event.scheduleType == ScheduleEventScheduleType.multipleDays;

  if (isMultipleDay) {
    final startDate = formatTimelineDate(start);
    final endDate = formatTimelineDate(end);

    if (startDate == endDate) {
      return [ScheduleTimelineValue(primary: startDate)];
    }

    return [
      ScheduleTimelineValue(primary: startDate),
      ScheduleTimelineValue(primary: endDate),
    ];
  }

  final startValue = ScheduleTimelineValue(
    primary: formatScheduleTime(start),
    secondary: spansMultipleDates ? formatTimelineDate(start) : null,
  );
  final endValue = ScheduleTimelineValue(
    primary: formatScheduleTime(end),
    secondary: spansMultipleDates ? formatTimelineDate(end) : null,
  );

  if (startValue.primary == endValue.primary &&
      startValue.secondary == endValue.secondary) {
    return [startValue];
  }

  return [startValue, endValue];
}

String formatScheduleMonthYear(DateTime value) {
  final normalized = value;

  return '${normalized.month.toString().padLeft(2, '0')}/${normalized.year}';
}

String formatScheduleSelectedDayLabel(DateTime value) {
  final normalized = value;

  return 'Lịch ngày ${normalized.day.toString().padLeft(2, '0')}/${normalized.month.toString().padLeft(2, '0')}';
}

String formatScheduleEventCountLabel(int count) {
  return '$count lịch trình';
}

String? formatScheduleRepeatSummary(ScheduleModel schedule) {
  if (schedule.event.scheduleType != ScheduleEventScheduleType.repeat) {
    return null;
  }

  final repeatType = schedule.event.repeatType;
  if (repeatType == null) {
    return null;
  }

  final startDate = formatDisplayDate(schedule.event.startDate);
  final endDate = formatDisplayDate(schedule.event.endDate);

  return '${repeatType.label} · $startDate - $endDate';
}

String formatScheduleUserListLabel({
  required String prefix,
  required List<ScheduleUserRef> users,
}) {
  return '$prefix: ${users.map((item) => item.name).join(', ')}';
}

String formatScheduleDateTimeRange(ScheduleModel schedule) {
  final start = schedule.start;
  final end = schedule.end;

  if (start == end) {
    return '${formatDisplayDate(start)} ${formatDisplayTime(TimeOfDay.fromDateTime(start))}';
  }

  final sameDate =
      start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;

  if (sameDate) {
    return '${formatDisplayDate(start)} '
        '${formatDisplayTime(TimeOfDay.fromDateTime(start))} - '
        '${formatDisplayTime(TimeOfDay.fromDateTime(end))}';
  }

  return '${formatDisplayDate(start)} '
      '${formatDisplayTime(TimeOfDay.fromDateTime(start))} - '
      '${formatDisplayDate(end)} '
      '${formatDisplayTime(TimeOfDay.fromDateTime(end))}';
}

import 'package:obee_mobile/src/core/time/business_time.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';

/// Represents one visible square in the month grid, including leading and
/// trailing days from adjacent months needed to render complete weeks.
final class ScheduleCalendarCell {
  const ScheduleCalendarCell({
    required this.date,
    required this.inCurrentMonth,
  });

  final DateTime date;
  final bool inCurrentMonth;
}

/// Normalizes any day in a month to that month's first day.
DateTime scheduleMonthAnchor(DateTime date) {
  return DateTime(date.year, date.month);
}

/// Strips the current time component because the schedule page reasons about
/// month and day selection, not live timestamps.
DateTime scheduleToday() {
  final now = businessNow();
  return DateTime(now.year, now.month, now.day);
}

/// Reproduces the web page's initial selection behavior: pick today for the
/// current month, otherwise select the first day of the navigated month.
DateTime initialScheduleSelectedDate(DateTime month, DateTime today) {
  if (month.year == today.year && month.month == today.month) {
    return today;
  }

  return month;
}

/// Builds a Monday-first grid that always spans whole weeks so the calendar
/// body has a stable rectangular layout.
List<ScheduleCalendarCell> buildScheduleCalendar(DateTime month) {
  final monthStart = DateTime(month.year, month.month);
  final monthEnd = DateTime(month.year, month.month + 1, 0);
  final startOffset = (monthStart.weekday + 6) % 7;
  final start = monthStart.subtract(Duration(days: startOffset));
  final provisionalEnd = start.add(const Duration(days: 34));
  final dayCount = provisionalEnd.isBefore(monthEnd) ? 42 : 35;

  final cells = <ScheduleCalendarCell>[];
  for (var index = 0; index < dayCount; index += 1) {
    final cursor = start.add(Duration(days: index));
    cells.add(
      ScheduleCalendarCell(
        date: DateTime(cursor.year, cursor.month, cursor.day),
        inCurrentMonth:
            cursor.year == monthStart.year && cursor.month == monthStart.month,
      ),
    );
  }

  return cells;
}

({DateTime end, DateTime start}) scheduleVisibleRange(DateTime month) {
  final cells = buildScheduleCalendar(month);
  if (cells.isEmpty) {
    throw StateError('Visible schedule range requires at least one cell.');
  }

  return (end: cells.last.date, start: cells.first.date);
}

bool isSameScheduleMonth(DateTime left, DateTime right) {
  return left.year == right.year && left.month == right.month;
}

/// Monday of the week containing [date], matching the Monday-first month grid.
DateTime scheduleWeekStart(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return DateTime(day.year, day.month, day.day - (day.weekday - 1));
}

/// The seven Monday-first days of the week containing [date].
List<DateTime> buildWeekDays(DateTime date) {
  final start = scheduleWeekStart(date);
  return [
    for (var offset = 0; offset < 7; offset += 1)
      DateTime(start.year, start.month, start.day + offset),
  ];
}

/// First day of each month in [year], used by the year overview.
List<DateTime> buildYearMonths(int year) {
  return [for (var month = 1; month <= 12; month += 1) DateTime(year, month)];
}

/// Date range the API must cover for the active view. Week and year views can
/// cross the month anchor, so they cannot reuse the month grid range.
({DateTime end, DateTime start}) scheduleRangeForView({
  required ScheduleViewMode mode,
  required DateTime month,
  required DateTime focusedDate,
}) {
  return switch (mode) {
    ScheduleViewMode.month => scheduleVisibleRange(month),
    ScheduleViewMode.week => (
      start: scheduleWeekStart(focusedDate),
      end: buildWeekDays(focusedDate).last,
    ),
    ScheduleViewMode.year => (
      start: DateTime(month.year),
      end: DateTime(month.year, 12, 31),
    ),
  };
}

/// Stable string key shared by the month grid and selected-day lookup map.
String scheduleDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Normalizes end boundaries before day grouping.
/// If an event ends exactly at midnight, treat that timestamp as the end of the
/// previous visible day so a range like `2026-06-10 00:00 -> 2026-06-12 00:00`
/// groups onto the 10th and 11th rather than spilling into an extra empty day.
DateTime _effectiveEnd(ScheduleModel schedule) {
  final end = schedule.end;
  if (end.hour == 0 &&
      end.minute == 0 &&
      end.second == 0 &&
      end.millisecond == 0 &&
      end.microsecond == 0 &&
      end.isAfter(schedule.start)) {
    return end.subtract(const Duration(milliseconds: 1));
  }

  return end;
}

DateTime _localCalendarDay(DateTime value) {
  final localValue = value;

  return DateTime(localValue.year, localValue.month, localValue.day);
}

/// Expands schedule rows into a date-indexed lookup for both month dots and
/// the selected-day event list.
Map<String, List<ScheduleModel>> groupSchedulesByDate(
  List<ScheduleModel> schedules,
) {
  final grouped = <String, List<ScheduleModel>>{};

  for (final schedule in schedules) {
    final isMultipleDay =
        schedule.event.scheduleType == ScheduleEventScheduleType.multipleDays;
    final firstDay = _localCalendarDay(
      isMultipleDay ? schedule.event.startDate : schedule.start,
    );
    final lastDay = _localCalendarDay(
      isMultipleDay ? schedule.event.endDate : _effectiveEnd(schedule),
    );

    for (
      var cursor = firstDay;
      !cursor.isAfter(lastDay);
      cursor = cursor.add(const Duration(days: 1))
    ) {
      final key = scheduleDateKey(cursor);
      grouped.putIfAbsent(key, () => <ScheduleModel>[]).add(schedule);
    }
  }

  for (final entry in grouped.entries) {
    entry.value.sort((left, right) => left.start.compareTo(right.start));
  }

  return grouped;
}

/// Creator-only checks drive edit and delete affordances in the detail sheet.
bool isScheduleCreator(ScheduleModel schedule, String currentUserId) {
  return schedule.event.createdBy == currentUserId;
}

/// Participant and observer helpers keep membership rules explicit and testable.
bool isScheduleParticipant(ScheduleModel schedule, String currentUserId) {
  return schedule.event.participants.any((item) => item.id == currentUserId);
}

bool isScheduleObserver(ScheduleModel schedule, String currentUserId) {
  return schedule.event.observers.any((item) => item.id == currentUserId);
}

bool canJoinSchedule(ScheduleModel schedule, String currentUserId) {
  return !isScheduleParticipant(schedule, currentUserId) &&
      isScheduleObserver(schedule, currentUserId);
}

bool canLeaveSchedule(ScheduleModel schedule, String currentUserId) {
  return isScheduleParticipant(schedule, currentUserId);
}

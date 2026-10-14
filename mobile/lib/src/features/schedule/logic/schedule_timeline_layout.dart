import 'dart:math' as math;

import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';

const _minutesPerDay = 24 * 60;
const _minBlockMinutes = 15;

/// One schedule positioned inside a single day column of the week time grid.
/// Minutes are clipped to the day, so overnight events render as two blocks.
final class ScheduleTimedBlock {
  const ScheduleTimedBlock({
    required this.schedule,
    required this.startMinute,
    required this.endMinute,
    required this.column,
    required this.columnCount,
  });

  final ScheduleModel schedule;
  final int startMinute;
  final int endMinute;
  final int column;
  final int columnCount;
}

/// Multi-day events and anything lasting a full day or longer belong in the
/// all-day strip instead of the hourly grid.
bool isAllDaySchedule(ScheduleModel schedule) {
  if (schedule.event.scheduleType == ScheduleEventScheduleType.multipleDays) {
    return true;
  }

  return schedule.end.difference(schedule.start).inMinutes >= _minutesPerDay;
}

/// Positions the timed schedules of [day] and splits overlapping ones into
/// side-by-side columns. Each cluster of transitively overlapping blocks
/// shares one column count so their widths line up.
List<ScheduleTimedBlock> layoutDaySchedules(
  DateTime day,
  List<ScheduleModel> schedules,
) {
  final dayStart = DateTime(day.year, day.month, day.day);
  final dayEnd = DateTime(day.year, day.month, day.day + 1);

  final spans = <({ScheduleModel schedule, int start, int end})>[];
  for (final schedule in schedules) {
    if (isAllDaySchedule(schedule)) {
      continue;
    }

    final start = schedule.start.isBefore(dayStart) ? dayStart : schedule.start;
    final end = schedule.end.isAfter(dayEnd) ? dayEnd : schedule.end;
    if (!end.isAfter(start) && schedule.end.isAfter(schedule.start)) {
      continue;
    }

    // Short and zero-length events still need a visible, tappable block.
    final startMinute = math.min(
      start.difference(dayStart).inMinutes,
      _minutesPerDay - _minBlockMinutes,
    );
    final endMinute = math.max(
      end.difference(dayStart).inMinutes,
      startMinute + _minBlockMinutes,
    );
    spans.add((schedule: schedule, start: startMinute, end: endMinute));
  }

  spans.sort((a, b) {
    final byStart = a.start.compareTo(b.start);
    return byStart != 0 ? byStart : b.end.compareTo(a.end);
  });

  final blocks = <ScheduleTimedBlock>[];
  var cluster = <({ScheduleModel schedule, int start, int end, int column})>[];
  var columnEnds = <int>[];
  var clusterEnd = -1;

  void flushCluster() {
    for (final item in cluster) {
      blocks.add(
        ScheduleTimedBlock(
          schedule: item.schedule,
          startMinute: item.start,
          endMinute: item.end,
          column: item.column,
          columnCount: columnEnds.length,
        ),
      );
    }
    cluster = [];
    columnEnds = [];
    clusterEnd = -1;
  }

  for (final span in spans) {
    if (span.start >= clusterEnd) {
      flushCluster();
    }

    var column = columnEnds.indexWhere((end) => end <= span.start);
    if (column == -1) {
      column = columnEnds.length;
      columnEnds.add(span.end);
    } else {
      columnEnds[column] = span.end;
    }

    cluster.add((
      schedule: span.schedule,
      start: span.start,
      end: span.end,
      column: column,
    ));
    if (span.end > clusterEnd) {
      clusterEnd = span.end;
    }
  }
  flushCluster();

  return blocks;
}

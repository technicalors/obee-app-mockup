import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_calendar.dart';

const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

const _eventTextStyle = TextStyle(
  fontSize: 9.5,
  fontWeight: FontWeight.w700,
  height: 1.15,
);

class ScheduleMonthCalendar extends StatelessWidget {
  const ScheduleMonthCalendar({
    required this.cells,
    required this.selectedKey,
    required this.today,
    required this.schedulesByDate,
    required this.onDaySelected,
    this.selectedWeekDate,
    super.key,
  });

  final List<ScheduleCalendarCell> cells;
  final String? selectedKey;
  final DateTime today;
  final Map<String, List<ScheduleModel>> schedulesByDate;
  final ValueChanged<DateTime> onDaySelected;
  final DateTime? selectedWeekDate;

  @override
  Widget build(BuildContext context) {
    final weekCount = (cells.length / 7).ceil();

    int? activeWeekIndex;
    if (selectedWeekDate != null) {
      for (var w = 0; w < weekCount; w++) {
        final weekCells = cells.sublist(w * 7, (w + 1) * 7);
        if (weekCells.any(
          (c) =>
              c.date.year == selectedWeekDate!.year &&
              c.date.month == selectedWeekDate!.month &&
              c.date.day == selectedWeekDate!.day,
        )) {
          activeWeekIndex = w;
          break;
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final cellWidth = totalWidth / 7;

        // 1. Build all segments across all weeks
        final allSegments = _buildAllCalendarSegments(
          cells: cells,
          schedulesByDate: schedulesByDate,
          cellWidth: cellWidth,
        );

        // Group segments by weekRow
        final segmentsByWeek = <int, List<CalendarEventSegment>>{};
        for (final seg in allSegments) {
          segmentsByWeek.putIfAbsent(seg.weekRow, () => []).add(seg);
        }

        // Assign lanes within each weekRow
        for (var w = 0; w < weekCount; w++) {
          final weekSegs = segmentsByWeek[w];
          if (weekSegs != null && weekSegs.isNotEmpty) {
            _assignSegmentLanes(weekSegs);
          }
        }

        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Weekday header row: T2 T3 T4 T5 T6 T7 CN
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    for (final label in _weekdayLabels)
                      Expanded(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
              ),
              // If in Week view, render only that 1 week row. Otherwise render all weeks.
              if (activeWeekIndex != null)
                _ScheduleCalendarWeekRow(
                  weekCells: cells.sublist(
                    activeWeekIndex * 7,
                    (activeWeekIndex + 1) * 7,
                  ),
                  segments: segmentsByWeek[activeWeekIndex] ?? const [],
                  selectedKey: selectedKey,
                  todayKey: scheduleDateKey(today),
                  onDaySelected: onDaySelected,
                  isFirstWeek: true,
                  isLastWeek: true,
                  cellWidth: cellWidth,
                )
              else if (constraints.maxHeight.isFinite)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, weekAreaConstraints) {
                      final weekAreaHeight = weekAreaConstraints.maxHeight;
                      final targetRowHeight = (weekAreaHeight / weekCount)
                          .clamp(64.0, 300.0);

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            for (var w = 0; w < weekCount; w++)
                              _ScheduleCalendarWeekRow(
                                weekCells: cells.sublist(w * 7, (w + 1) * 7),
                                segments: segmentsByWeek[w] ?? const [],
                                selectedKey: selectedKey,
                                todayKey: scheduleDateKey(today),
                                onDaySelected: onDaySelected,
                                isFirstWeek: w == 0,
                                isLastWeek: w == weekCount - 1,
                                cellWidth: cellWidth,
                                minRowHeight: targetRowHeight,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                for (var w = 0; w < weekCount; w++) ...[
                  _ScheduleCalendarWeekRow(
                    weekCells: cells.sublist(w * 7, (w + 1) * 7),
                    segments: segmentsByWeek[w] ?? const [],
                    selectedKey: selectedKey,
                    todayKey: scheduleDateKey(today),
                    onDaySelected: onDaySelected,
                    isFirstWeek: w == 0,
                    isLastWeek: w == weekCount - 1,
                    cellWidth: cellWidth,
                  ),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleCalendarWeekRow extends StatelessWidget {
  const _ScheduleCalendarWeekRow({
    required this.weekCells,
    required this.segments,
    required this.selectedKey,
    required this.todayKey,
    required this.onDaySelected,
    required this.isFirstWeek,
    required this.isLastWeek,
    required this.cellWidth,
    this.minRowHeight = _defaultMinRowHeight,
  });

  final List<ScheduleCalendarCell> weekCells;
  final List<CalendarEventSegment> segments;
  final String? selectedKey;
  final String todayKey;
  final ValueChanged<DateTime> onDaySelected;
  final bool isFirstWeek;
  final bool isLastWeek;
  final double cellWidth;
  final double minRowHeight;

  static const double _topPadding = 4.0;
  static const double _dayNumberHeight = 26.0;
  static const double _badgeHeight = 18.0;
  static const double _badgeSpacing = 3.0;
  static const double _bottomPadding = 6.0;
  static const double _defaultMinRowHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final maxLane = segments.isEmpty
        ? -1
        : segments.map((e) => e.lane).reduce((a, b) => a > b ? a : b);
    final laneCount = maxLane + 1;

    final eventsHeight = laneCount > 0
        ? (laneCount * _badgeHeight + (laneCount - 1) * _badgeSpacing)
        : 0.0;
    final naturalHeight =
        _topPadding + _dayNumberHeight + eventsHeight + _bottomPadding;
    final rowHeight = naturalHeight.clamp(minRowHeight, 300.0);

    return SizedBox(
      height: rowHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Grid Cells Layer
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var col = 0; col < 7; col++) ...[
                Expanded(
                  child: _CalendarDayCellBackground(
                    cell: weekCells[col],
                    dateKey: scheduleDateKey(weekCells[col].date),
                    isSelected:
                        selectedKey != null &&
                        scheduleDateKey(weekCells[col].date) == selectedKey,
                    isToday: scheduleDateKey(weekCells[col].date) == todayKey,
                    onTap: () => onDaySelected(weekCells[col].date),
                    showRightBorder: col < 6,
                    showBottomBorder: !isLastWeek,
                  ),
                ),
              ],
            ],
          ),
          // 2. Events Layer
          for (final segment in segments) ...[
            Positioned(
              top:
                  _topPadding +
                  _dayNumberHeight +
                  segment.lane * (_badgeHeight + _badgeSpacing),
              left: segment.startColumn * cellWidth + 2.0,
              width: segment.span * cellWidth - 4.0,
              height: _badgeHeight,
              child: _CalendarEventSegmentDetector(
                cellWidth: cellWidth,
                startColumn: segment.startColumn,
                span: segment.span,
                weekCells: weekCells,
                onDaySelected: onDaySelected,
                child: _CalendarEventSegmentBadge(segment: segment),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarEventSegmentDetector extends StatefulWidget {
  const _CalendarEventSegmentDetector({
    required this.cellWidth,
    required this.startColumn,
    required this.span,
    required this.weekCells,
    required this.onDaySelected,
    required this.child,
  });

  final double cellWidth;
  final int startColumn;
  final int span;
  final List<ScheduleCalendarCell> weekCells;
  final ValueChanged<DateTime> onDaySelected;
  final Widget child;

  @override
  State<_CalendarEventSegmentDetector> createState() =>
      _CalendarEventSegmentDetectorState();
}

class _CalendarEventSegmentDetectorState
    extends State<_CalendarEventSegmentDetector> {
  DateTime? _tappedDate;

  void _resolveTappedDate(Offset localPosition) {
    final colOffset = widget.cellWidth > 0
        ? (localPosition.dx / widget.cellWidth).floor().clamp(
            0,
            widget.span - 1,
          )
        : 0;
    final targetCol = (widget.startColumn + colOffset).clamp(0, 6);
    _tappedDate = widget.weekCells[targetCol].date;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _resolveTappedDate(details.localPosition),
      onTapUp: (details) => _resolveTappedDate(details.localPosition),
      onTap: () {
        final date = _tappedDate ?? widget.weekCells[widget.startColumn].date;
        widget.onDaySelected(date);
      },
      child: widget.child,
    );
  }
}

class _CalendarDayCellBackground extends StatelessWidget {
  const _CalendarDayCellBackground({
    required this.cell,
    required this.dateKey,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    required this.showRightBorder,
    required this.showBottomBorder,
  });

  final ScheduleCalendarCell cell;
  final String dateKey;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;
  final bool showRightBorder;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      key: ValueKey('schedule-day-$dateKey'),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: showRightBorder
                ? BorderSide(color: colorScheme.outlineVariant, width: 1.0)
                : BorderSide.none,
            bottom: showBottomBorder
                ? BorderSide(color: colorScheme.outlineVariant, width: 1.0)
                : BorderSide.none,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: isSelected
                ? Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                    ),
                    child: Center(
                      child: Text(
                        '${cell.date.day}',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  )
                : Text(
                    '${cell.date.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cell.inCurrentMonth
                          ? (isToday
                                ? colorScheme.primary
                                : colorScheme.onSurface)
                          : colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.38,
                            ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CalendarEventSegmentBadge extends StatelessWidget {
  const _CalendarEventSegmentBadge({required this.segment});

  final CalendarEventSegment segment;

  @override
  Widget build(BuildContext context) {
    final type = segment.schedule.event.type;
    final colorScheme = Theme.of(context).colorScheme;
    final badgeBg = type.backgroundColorFor(colorScheme);
    final badgeFg = type.foregroundColorFor(colorScheme);

    if (segment.isMultiDay) {
      return Container(
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.horizontal(
            left: segment.isFirstSegment
                ? const Radius.circular(4)
                : Radius.zero,
            right: segment.isLastSegment
                ? const Radius.circular(4)
                : Radius.zero,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            if (segment.isFirstSegment)
              Container(width: 3, color: type.harmonizedColor(colorScheme)),
            if (segment.text.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: Text(
                    segment.text,
                    style: _eventTextStyle.copyWith(color: badgeFg),
                    maxLines: 1,
                    overflow: segment.isLastSegment
                        ? TextOverflow.ellipsis
                        : TextOverflow.clip,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Single-day schedule: display ONLY the schedule type label
    return Container(
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        type.label,
        style: _eventTextStyle.copyWith(color: badgeFg),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Represents one weekly slice of an event in the calendar grid.
class CalendarEventSegment {
  CalendarEventSegment({
    required this.schedule,
    required this.weekRow,
    required this.startColumn,
    required this.endColumn,
    required this.span,
    required this.isFirstSegment,
    required this.isLastSegment,
    required this.isMultiDay,
    this.text = '',
  });

  final ScheduleModel schedule;
  final int weekRow;
  final int startColumn;
  final int endColumn;
  final int span;
  final bool isFirstSegment;
  final bool isLastSegment;
  final bool isMultiDay;
  String text;
  int lane = 0;
}

class TextSplitResult {
  const TextSplitResult({required this.fitted, required this.remaining});

  final String fitted;
  final String remaining;
}

TextSplitResult fitText({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required TextDirection textDirection,
}) {
  if (text.isEmpty) {
    return const TextSplitResult(fitted: '', remaining: '');
  }

  final words = text.split(RegExp(r'\s+'));
  String fitted = '';

  for (var i = 0; i < words.length; i++) {
    final candidate = fitted.isEmpty ? words[i] : '$fitted ${words[i]}';

    final painter = TextPainter(
      text: TextSpan(text: candidate, style: style),
      textDirection: textDirection,
    )..layout();

    final fits = painter.width <= maxWidth;
    painter.dispose();

    if (!fits) {
      if (fitted.isEmpty) {
        // Even the first word overflows maxWidth: place it in fitted so it's
        // not skipped, and pass the remaining words to next segment.
        return TextSplitResult(
          fitted: words[i],
          remaining: words.sublist(i + 1).join(' '),
        );
      }
      return TextSplitResult(
        fitted: fitted,
        remaining: words.sublist(i).join(' '),
      );
    }

    fitted = candidate;
  }

  return TextSplitResult(fitted: fitted, remaining: '');
}

List<CalendarEventSegment> _buildAllCalendarSegments({
  required List<ScheduleCalendarCell> cells,
  required Map<String, List<ScheduleModel>> schedulesByDate,
  required double cellWidth,
}) {
  final weekCount = (cells.length / 7).ceil();

  // Find all distinct schedules visible across all cells
  final seenScheduleIds = <String>{};
  final allSchedules = <ScheduleModel>[];

  for (final cell in cells) {
    final key = scheduleDateKey(cell.date);
    final dayList = schedulesByDate[key] ?? const [];
    for (final s in dayList) {
      if (seenScheduleIds.add(s.id)) {
        allSchedules.add(s);
      }
    }
  }

  final allSegments = <CalendarEventSegment>[];

  for (final schedule in allSchedules) {
    final isMulti = _isMultiDay(schedule);
    final eventStart = _effectiveEventStartDate(schedule);
    final eventEnd = _effectiveEventEndDate(schedule);

    // Split this schedule across each weekRow
    final scheduleSegments = <CalendarEventSegment>[];

    for (var w = 0; w < weekCount; w++) {
      final weekCells = cells.sublist(w * 7, (w + 1) * 7);
      final weekStart = DateTime(
        weekCells.first.date.year,
        weekCells.first.date.month,
        weekCells.first.date.day,
      );
      final weekEnd = DateTime(
        weekCells.last.date.year,
        weekCells.last.date.month,
        weekCells.last.date.day,
      );

      // Check if event overlaps this week
      if (eventStart.isAfter(weekEnd) || eventEnd.isBefore(weekStart)) {
        continue;
      }

      var startCol = 0;
      var endCol = 6;
      for (var i = 0; i < 7; i++) {
        final cellDate = DateTime(
          weekCells[i].date.year,
          weekCells[i].date.month,
          weekCells[i].date.day,
        );
        if (cellDate.isBefore(eventStart)) {
          startCol = i + 1;
        }
        if (cellDate.isAfter(eventEnd)) {
          endCol = i - 1;
          break;
        }
      }

      if (startCol < 0) startCol = 0;
      if (endCol > 6) endCol = 6;
      if (startCol > endCol) continue;

      final isFirst = !eventStart.isBefore(weekStart);
      final isLast = !eventEnd.isAfter(weekEnd);
      final span = endCol - startCol + 1;

      scheduleSegments.add(
        CalendarEventSegment(
          schedule: schedule,
          weekRow: w,
          startColumn: startCol,
          endColumn: endCol,
          span: span,
          isFirstSegment: isFirst,
          isLastSegment: isLast,
          isMultiDay: isMulti,
        ),
      );
    }

    if (!isMulti) {
      // Single-day event: text is always type.label
      for (final seg in scheduleSegments) {
        seg.text = schedule.event.type.label;
        allSegments.add(seg);
      }
      continue;
    }

    // Multi-day event: distribute title words across segments using fitText
    var remaining = schedule.event.title.trim();
    for (final segment in scheduleSegments) {
      if (remaining.isEmpty) {
        // Title has already been fully displayed in previous segments:
        // Keep segment.text as empty string -> renders empty card!
        segment.text = '';
      } else {
        final segmentWidth = segment.span * cellWidth - 4.0;
        final basePadding = segment.isFirstSegment ? 8.0 : 5.0;
        final safetyBuffer = segment.isLastSegment ? 0.0 : 4.0;
        final maxWidth = (segmentWidth - basePadding - safetyBuffer).clamp(
          0.0,
          10000.0,
        );

        final result = fitText(
          text: remaining,
          style: _eventTextStyle.copyWith(
            color: schedule.event.type.foregroundColor,
          ),
          maxWidth: maxWidth,
          textDirection: TextDirection.ltr,
        );

        segment.text = result.fitted;
        remaining = result.remaining;
      }

      allSegments.add(segment);
    }
  }

  return allSegments;
}

void _assignSegmentLanes(List<CalendarEventSegment> segments) {
  if (segments.length <= 1) {
    if (segments.length == 1) {
      segments.first.lane = 0;
    }
    return;
  }

  // Sort segments: multi-day first (longer span first, then startColumn), then single-day
  segments.sort((a, b) {
    if (a.isMultiDay && !b.isMultiDay) return -1;
    if (!a.isMultiDay && b.isMultiDay) return 1;
    if (a.isMultiDay && b.isMultiDay) {
      if (a.span != b.span) return b.span.compareTo(a.span);
      return a.startColumn.compareTo(b.startColumn);
    }
    if (a.startColumn != b.startColumn) {
      return a.startColumn.compareTo(b.startColumn);
    }
    return a.schedule.start.compareTo(b.schedule.start);
  });

  final occupied = <List<bool>>[];

  for (final seg in segments) {
    var assignedLane = -1;
    for (var lane = 0; lane < occupied.length; lane++) {
      var fits = true;
      for (var col = seg.startColumn; col <= seg.endColumn; col++) {
        if (occupied[lane][col]) {
          fits = false;
          break;
        }
      }
      if (fits) {
        assignedLane = lane;
        break;
      }
    }

    if (assignedLane == -1) {
      assignedLane = occupied.length;
      occupied.add(List<bool>.filled(7, false));
    }

    for (var col = seg.startColumn; col <= seg.endColumn; col++) {
      occupied[assignedLane][col] = true;
    }

    seg.lane = assignedLane;
  }
}

DateTime _effectiveEventStartDate(ScheduleModel schedule) {
  if (schedule.event.scheduleType == ScheduleEventScheduleType.multipleDays) {
    final d = schedule.event.startDate;
    return DateTime(d.year, d.month, d.day);
  }
  final d = schedule.start;
  return DateTime(d.year, d.month, d.day);
}

DateTime _effectiveEventEndDate(ScheduleModel schedule) {
  if (schedule.event.scheduleType == ScheduleEventScheduleType.multipleDays) {
    final d = schedule.event.endDate;
    return DateTime(d.year, d.month, d.day);
  }
  final d = schedule.end;
  if (d.hour == 0 &&
      d.minute == 0 &&
      d.second == 0 &&
      d.millisecond == 0 &&
      d.isAfter(schedule.start)) {
    final prev = d.subtract(const Duration(milliseconds: 1));
    return DateTime(prev.year, prev.month, prev.day);
  }
  return DateTime(d.year, d.month, d.day);
}

bool _isMultiDay(ScheduleModel schedule) {
  if (schedule.event.scheduleType == ScheduleEventScheduleType.multipleDays) {
    return true;
  }
  final s = _effectiveEventStartDate(schedule);
  final e = _effectiveEventEndDate(schedule);
  return s.year != e.year || s.month != e.month || s.day != e.day;
}

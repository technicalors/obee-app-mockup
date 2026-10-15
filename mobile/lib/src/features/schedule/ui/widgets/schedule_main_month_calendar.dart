import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_calendar.dart';

const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

const _eventTextStyle = TextStyle(
  fontSize: 10,
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
    this.rounded = false,
    super.key,
  });

  final List<ScheduleCalendarCell> cells;
  final String? selectedKey;
  final DateTime today;
  final Map<String, List<ScheduleModel>> schedulesByDate;
  final ValueChanged<DateTime> onDaySelected;
  final DateTime? selectedWeekDate;

  /// Google Calendar style used by the `/mobile2` layout: each day is a
  /// rounded tile with small gaps, today is a filled pill and events are
  /// solid rounded chips. The page behind should use `surfaceContainer`.
  final bool rounded;

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

        return DecoratedBox(
          decoration: BoxDecoration(
            color: rounded ? Colors.transparent : colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Weekday header row: T2 T3 T4 T5 T6 T7 CN
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Row(
                  children: [
                    for (var i = 0; i < _weekdayLabels.length; i++)
                      Expanded(
                        child: Text(
                          _weekdayLabels[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: i >= 5 && !rounded
                                ? colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  )
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
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
                  rounded: rounded,
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
                                rounded: rounded,
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
                    rounded: rounded,
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
    this.rounded = false,
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
  final bool rounded;

  static const double _topPadding = 4.0;
  static const double _dayNumberHeight = 28.0;
  static const double _badgeHeight = 18.0;
  static const double _badgeSpacing = 2.0;
  static const double _bottomPadding = 6.0;
  static const double _defaultMinRowHeight = 64.0;
  static const int _maxVisibleLanes = 3;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Lanes past the cap collapse into a per-day "+N" counter.
    final hiddenPerColumn = List<int>.filled(7, 0);
    var visibleLaneCount = 0;
    for (final segment in segments) {
      if (segment.lane < _maxVisibleLanes) {
        visibleLaneCount = math.max(visibleLaneCount, segment.lane + 1);
        continue;
      }
      for (var col = segment.startColumn; col <= segment.endColumn; col++) {
        hiddenPerColumn[col] += 1;
      }
    }
    final hasOverflow = hiddenPerColumn.any((count) => count > 0);
    final laneCount = visibleLaneCount + (hasOverflow ? 1 : 0);

    final eventsHeight = laneCount > 0
        ? (laneCount * _badgeHeight + (laneCount - 1) * _badgeSpacing)
        : 0.0;
    final naturalHeight =
        _topPadding + _dayNumberHeight + eventsHeight + _bottomPadding;
    final rowHeight = naturalHeight.clamp(minRowHeight, 300.0);

    double laneTop(int lane) =>
        _topPadding + _dayNumberHeight + lane * (_badgeHeight + _badgeSpacing);

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
                    isWeekend: col >= 5,
                    rounded: rounded,
                    onTap: () => onDaySelected(weekCells[col].date),
                    showBottomBorder: !isLastWeek && !rounded,
                  ),
                ),
              ],
            ],
          ),
          // 2. Events Layer
          for (final segment in segments)
            if (segment.lane < _maxVisibleLanes)
              Positioned(
                top: laneTop(segment.lane),
                // Rounded tiles have a gap, so chips sit a bit further in.
                left: segment.startColumn * cellWidth + (rounded ? 4.0 : 2.0),
                width: segment.span * cellWidth - (rounded ? 8.0 : 4.0),
                height: _badgeHeight,
                child: _CalendarEventSegmentDetector(
                  cellWidth: cellWidth,
                  startColumn: segment.startColumn,
                  span: segment.span,
                  weekCells: weekCells,
                  onDaySelected: onDaySelected,
                  child: _CalendarEventSegmentBadge(
                    segment: segment,
                    rounded: rounded,
                  ),
                ),
              ),
          // 3. Overflow counters
          for (var col = 0; col < 7; col++)
            if (hiddenPerColumn[col] > 0)
              Positioned(
                top: laneTop(visibleLaneCount),
                left: col * cellWidth + 2.0,
                width: cellWidth - 4.0,
                height: _badgeHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onDaySelected(weekCells[col].date),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '+${hiddenPerColumn[col]}',
                      key: ValueKey(
                        'schedule-day-more-'
                        '${scheduleDateKey(weekCells[col].date)}',
                      ),
                      style: _eventTextStyle.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
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
    required this.isWeekend,
    required this.rounded,
    required this.onTap,
    required this.showBottomBorder,
  });

  final ScheduleCalendarCell cell;
  final String dateKey;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final bool rounded;
  final VoidCallback onTap;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Today is a filled primary circle, selection a tonal one.
    final Color? circleColor = isToday
        ? colorScheme.primary
        : (isSelected ? colorScheme.primaryContainer : null);
    final Color textColor;
    if (isToday) {
      textColor = colorScheme.onPrimary;
    } else if (isSelected) {
      textColor = colorScheme.onPrimaryContainer;
    } else if (!cell.inCurrentMonth) {
      textColor = rounded
          ? colorScheme.onSurfaceVariant
          : colorScheme.onSurfaceVariant.withValues(alpha: 0.35);
    } else if (isWeekend && !rounded) {
      textColor = colorScheme.onSurfaceVariant;
    } else {
      textColor = colorScheme.onSurface;
    }

    if (rounded) {
      // Google Calendar tile: rounded card with a small gap, the day number
      // in a pill that is filled for today and tonal when selected.
      return Padding(
        padding: const EdgeInsets.all(1.5),
        child: Material(
          color: colorScheme.surfaceBright,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('schedule-day-$dateKey'),
            onTap: onTap,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 32,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: circleColor,
                  ),
                  child: Text(
                    '${cell.date.day}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return InkWell(
      key: ValueKey('schedule-day-$dateKey'),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.18)
              : null,
          border: Border(
            bottom: showBottomBorder
                ? BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 0.6,
                  )
                : BorderSide.none,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
              child: Text(
                '${cell.date.day}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: isToday || isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  height: 1.0,
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
  const _CalendarEventSegmentBadge({
    required this.segment,
    required this.rounded,
  });

  final CalendarEventSegment segment;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final type = segment.schedule.event.type;
    final colorScheme = Theme.of(context).colorScheme;
    final badgeBg = type.backgroundColorFor(colorScheme);
    final badgeFg = type.foregroundColorFor(colorScheme);

    if (rounded) {
      // Google Calendar style: solid type color with white text. Single-day
      // and multi-day events share the shape; multi-day bars are rounded only
      // on the ends that start or finish in this week.
      const radius = Radius.circular(4);
      return Container(
        decoration: BoxDecoration(
          color: type.harmonizedColor(colorScheme),
          borderRadius: BorderRadius.horizontal(
            left: segment.isFirstSegment ? radius : Radius.zero,
            right: segment.isLastSegment ? radius : Radius.zero,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.centerLeft,
        child: segment.text.isEmpty
            ? null
            : Text(
                segment.text,
                style: _eventTextStyle.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: segment.isLastSegment
                    ? TextOverflow.ellipsis
                    : TextOverflow.clip,
                softWrap: false,
              ),
      );
    }

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

    // Timed single-day schedule: colored dot plus title, Google Calendar
    // style, so it reads lighter than the filled multi-day bars.
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 2, right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: type.harmonizedColor(colorScheme),
          ),
        ),
        Expanded(
          child: Text(
            segment.text,
            style: _eventTextStyle.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ],
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
      // Single-day event: the cell shows the title next to a type dot.
      for (final seg in scheduleSegments) {
        seg.text = schedule.event.title.trim();
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

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:obee_mobile/src/core/time/business_time.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_calendar.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_timeline_layout.dart';

const _gutterWidth = 44.0;
const _hourHeight = 56.0;
const _allDayBarHeight = 18.0;
const _allDayBarSpacing = 2.0;

/// Hourly week view: day header, all-day strip, then a scrollable 24h grid
/// with side-by-side blocks for overlapping events and a live "now" line.
class ScheduleWeekTimeGrid extends StatefulWidget {
  const ScheduleWeekTimeGrid({
    required this.days,
    required this.today,
    required this.schedulesByDate,
    required this.onSchedulePressed,
    required this.onDaySelected,
    this.selectedDate,
    this.onSlotPressed,
    this.clock = businessNow,
    super.key,
  });

  final List<DateTime> days;
  final DateTime today;
  final DateTime? selectedDate;
  final Map<String, List<ScheduleModel>> schedulesByDate;
  final ValueChanged<ScheduleModel> onSchedulePressed;
  final ValueChanged<DateTime> onDaySelected;

  /// Null hides the tap-to-create affordance (no create permission).
  final ValueChanged<DateTime>? onSlotPressed;
  final DateTime Function() clock;

  @override
  State<ScheduleWeekTimeGrid> createState() => _ScheduleWeekTimeGridState();
}

class _ScheduleWeekTimeGridState extends State<ScheduleWeekTimeGrid> {
  late final ScrollController _scrollController;
  Timer? _ticker;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = widget.clock();
    // Open around the current hour, or the start of the working day.
    final anchorHour = _weekContainsToday ? math.max(_now.hour - 1, 0) : 7;
    _scrollController = ScrollController(
      initialScrollOffset: anchorHour * _hourHeight,
    );
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _now = widget.clock());
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _weekContainsToday => widget.days.any(
    (day) => scheduleDateKey(day) == scheduleDateKey(widget.today),
  );

  List<ScheduleModel> _schedulesFor(DateTime day) {
    return widget.schedulesByDate[scheduleDateKey(day)] ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allDayBars = _buildAllDayBars();
    final allDayLanes = allDayBars.isEmpty
        ? 0
        : allDayBars.map((bar) => bar.lane).reduce(math.max) + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - _gutterWidth) / 7;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WeekDayHeader(
              days: widget.days,
              today: widget.today,
              selectedDate: widget.selectedDate,
              onDaySelected: widget.onDaySelected,
            ),
            if (allDayLanes > 0)
              Container(
                key: const ValueKey('schedule-week-all-day'),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                height:
                    allDayLanes * (_allDayBarHeight + _allDayBarSpacing) + 8,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      width: _gutterWidth,
                      top: 2,
                      child: Text(
                        'Cả ngày',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    for (final bar in allDayBars)
                      Positioned(
                        top: bar.lane * (_allDayBarHeight + _allDayBarSpacing),
                        left: _gutterWidth + bar.startColumn * columnWidth + 1,
                        width:
                            (bar.endColumn - bar.startColumn + 1) *
                                columnWidth -
                            2,
                        height: _allDayBarHeight,
                        child: _AllDayBar(
                          schedule: bar.schedule,
                          onTap: () => widget.onSchedulePressed(bar.schedule),
                        ),
                      ),
                  ],
                ),
              )
            else
              Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey('schedule-week-scroll'),
                controller: _scrollController,
                child: SizedBox(
                  height: 24 * _hourHeight + 12,
                  child: Stack(
                    children: [
                      _buildHourLines(colorScheme),
                      for (var index = 0; index < widget.days.length; index++)
                        Positioned(
                          left: _gutterWidth + index * columnWidth,
                          width: columnWidth,
                          top: 6,
                          height: 24 * _hourHeight,
                          child: _buildDayColumn(
                            widget.days[index],
                            columnWidth,
                            colorScheme,
                          ),
                        ),
                      if (_weekContainsToday) _buildNowLine(columnWidth),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHourLines(ColorScheme colorScheme) {
    return Positioned.fill(
      top: 6,
      child: Column(
        children: [
          for (var hour = 0; hour < 24; hour++)
            SizedBox(
              height: _hourHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: _gutterWidth,
                    child: Transform.translate(
                      offset: const Offset(0, -6),
                      child: Text(
                        hour == 0
                            ? ''
                            : '${hour.toString().padLeft(2, '0')}:00',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 0.6,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(
    DateTime day,
    double columnWidth,
    ColorScheme colorScheme,
  ) {
    final blocks = layoutDaySchedules(day, _schedulesFor(day));
    final isWeekend = day.weekday >= DateTime.saturday;
    final onSlotPressed = widget.onSlotPressed;

    return GestureDetector(
      key: ValueKey('schedule-week-column-${scheduleDateKey(day)}'),
      behavior: HitTestBehavior.translucent,
      onTapUp: onSlotPressed == null
          ? null
          : (details) {
              final hour = (details.localPosition.dy / _hourHeight)
                  .floor()
                  .clamp(0, 23);
              onSlotPressed(DateTime(day.year, day.month, day.day, hour));
            },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isWeekend
              ? colorScheme.surfaceContainerLow.withValues(alpha: 0.5)
              : null,
          border: Border(
            left: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 0.6,
            ),
          ),
        ),
        child: Stack(
          children: [
            for (final block in blocks)
              Positioned(
                top: block.startMinute / 60 * _hourHeight,
                height: math.max(
                  (block.endMinute - block.startMinute) / 60 * _hourHeight - 1,
                  14,
                ),
                left: block.column * columnWidth / block.columnCount + 1,
                width: columnWidth / block.columnCount - 2,
                child: _TimedBlock(
                  key: ValueKey(
                    'schedule-week-block-${block.schedule.id}-'
                    '${scheduleDateKey(day)}',
                  ),
                  block: block,
                  onTap: () => widget.onSchedulePressed(block.schedule),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNowLine(double columnWidth) {
    final todayIndex = widget.days.indexWhere(
      (day) => scheduleDateKey(day) == scheduleDateKey(widget.today),
    );
    final top = 6 + (_now.hour * 60 + _now.minute) / 60 * _hourHeight;
    const color = Color(0xFFEA4335);

    return Positioned(
      key: const ValueKey('schedule-week-now-line'),
      top: top - 4,
      left: _gutterWidth + todayIndex * columnWidth - 4,
      width: columnWidth + 4,
      height: 8,
      child: IgnorePointer(
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            Expanded(child: Container(height: 2, color: color)),
          ],
        ),
      ),
    );
  }

  List<_AllDayBarSlot> _buildAllDayBars() {
    final seen = <String>{};
    final slots = <_AllDayBarSlot>[];

    for (var index = 0; index < widget.days.length; index++) {
      for (final schedule in _schedulesFor(widget.days[index])) {
        if (!isAllDaySchedule(schedule) || !seen.add(schedule.id)) {
          continue;
        }

        var endColumn = index;
        for (var next = index + 1; next < widget.days.length; next++) {
          final hasSchedule = _schedulesFor(
            widget.days[next],
          ).any((item) => item.id == schedule.id);
          if (!hasSchedule) {
            break;
          }
          endColumn = next;
        }
        slots.add(
          _AllDayBarSlot(
            schedule: schedule,
            startColumn: index,
            endColumn: endColumn,
          ),
        );
      }
    }

    // Greedy lanes, longest bars first, mirroring the month grid.
    slots.sort((a, b) {
      final bySpan = (b.endColumn - b.startColumn).compareTo(
        a.endColumn - a.startColumn,
      );
      return bySpan != 0 ? bySpan : a.startColumn.compareTo(b.startColumn);
    });
    final laneEnds = <int>[];
    for (final slot in slots) {
      var lane = laneEnds.indexWhere((end) => end < slot.startColumn);
      if (lane == -1) {
        lane = laneEnds.length;
        laneEnds.add(slot.endColumn);
      } else {
        laneEnds[lane] = slot.endColumn;
      }
      slot.lane = lane;
    }

    return slots;
  }
}

class _AllDayBarSlot {
  _AllDayBarSlot({
    required this.schedule,
    required this.startColumn,
    required this.endColumn,
  });

  final ScheduleModel schedule;
  final int startColumn;
  final int endColumn;
  int lane = 0;
}

class _WeekDayHeader extends StatelessWidget {
  const _WeekDayHeader({
    required this.days,
    required this.today,
    required this.selectedDate,
    required this.onDaySelected,
  });

  final List<DateTime> days;
  final DateTime today;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final todayKey = scheduleDateKey(today);
    final selectedKey = selectedDate == null
        ? null
        : scheduleDateKey(selectedDate!);

    return Padding(
      padding: const EdgeInsets.only(left: _gutterWidth, bottom: 6),
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: InkWell(
                key: ValueKey('schedule-week-day-${scheduleDateKey(day)}'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => onDaySelected(day),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    children: [
                      Text(
                        formatScheduleWeekdayShort(day),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: scheduleDateKey(day) == todayKey
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _DayNumber(
                        day: day,
                        isToday: scheduleDateKey(day) == todayKey,
                        isSelected: scheduleDateKey(day) == selectedKey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayNumber extends StatelessWidget {
  const _DayNumber({
    required this.day,
    required this.isToday,
    required this.isSelected,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday
            ? colorScheme.primary
            : (isSelected ? colorScheme.primaryContainer : null),
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 15,
          height: 1,
          fontWeight: FontWeight.w700,
          color: isToday
              ? colorScheme.onPrimary
              : (isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _TimedBlock extends StatelessWidget {
  const _TimedBlock({required this.block, required this.onTap, super.key});

  final ScheduleTimedBlock block;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final schedule = block.schedule;
    final type = schedule.event.type;
    final foreground = type.foregroundColorFor(colorScheme);

    return Material(
      color: type.backgroundColorFor(colorScheme),
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: type.harmonizedColor(colorScheme),
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(4, 2, 2, 2),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Narrow overlapping blocks keep whole words on one clipped
              // line instead of breaking titles mid-word.
              final isNarrow = constraints.maxWidth < 30;
              final showTime = !isNarrow && constraints.maxHeight >= 34;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      schedule.event.title,
                      maxLines: isNarrow ? 1 : null,
                      softWrap: !isNarrow,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                      overflow: isNarrow
                          ? TextOverflow.clip
                          : TextOverflow.fade,
                    ),
                  ),
                  if (showTime)
                    Text(
                      formatScheduleTime(schedule.start),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 9,
                        color: foreground.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AllDayBar extends StatelessWidget {
  const _AllDayBar({required this.schedule, required this.onTap});

  final ScheduleModel schedule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final type = schedule.event.type;

    return Material(
      color: type.harmonizedColor(colorScheme),
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              schedule.event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

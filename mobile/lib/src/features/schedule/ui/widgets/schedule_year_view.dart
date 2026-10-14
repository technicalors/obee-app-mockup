import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_calendar.dart';

const _miniWeekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// Year overview: twelve mini months where days with schedules get a dot.
/// Tapping a month opens it in the month view.
class ScheduleYearView extends StatelessWidget {
  const ScheduleYearView({
    required this.year,
    required this.today,
    required this.schedulesByDate,
    required this.onMonthSelected,
    super.key,
  });

  final int year;
  final DateTime today;
  final Map<String, List<ScheduleModel>> schedulesByDate;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 3;

        return GridView.builder(
          key: const ValueKey('schedule-year-grid'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 10,
            childAspectRatio: 0.78,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = buildYearMonths(year)[index];
            return _MiniMonth(
              month: month,
              today: today,
              schedulesByDate: schedulesByDate,
              onTap: () => onMonthSelected(month),
            );
          },
        );
      },
    );
  }
}

class _MiniMonth extends StatelessWidget {
  const _MiniMonth({
    required this.month,
    required this.today,
    required this.schedulesByDate,
    required this.onTap,
  });

  final DateTime month;
  final DateTime today;
  final Map<String, List<ScheduleModel>> schedulesByDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cells = buildScheduleCalendar(month);
    final todayKey = scheduleDateKey(today);
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;

    return InkWell(
      key: ValueKey('schedule-year-month-${month.month}'),
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 4),
              child: Text(
                'Tháng ${month.month}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCurrentMonth
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            Row(
              children: [
                for (final label in _miniWeekdayLabels)
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 7,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Column(
                children: [
                  for (var week = 0; week < 6; week++)
                    Expanded(
                      child: Row(
                        children: [
                          for (var col = 0; col < 7; col++)
                            Expanded(
                              child: week * 7 + col < cells.length
                                  ? _MiniDay(
                                      cell: cells[week * 7 + col],
                                      isToday:
                                          scheduleDateKey(
                                            cells[week * 7 + col].date,
                                          ) ==
                                          todayKey,
                                      hasSchedules:
                                          schedulesByDate[scheduleDateKey(
                                                cells[week * 7 + col].date,
                                              )]
                                              ?.isNotEmpty ==
                                          true,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniDay extends StatelessWidget {
  const _MiniDay({
    required this.cell,
    required this.isToday,
    required this.hasSchedules,
  });

  final ScheduleCalendarCell cell;
  final bool isToday;
  final bool hasSchedules;

  @override
  Widget build(BuildContext context) {
    if (!cell.inCurrentMonth) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    // Days with schedules get a tonal circle; today stays filled primary.
    final Color? fill = isToday
        ? colorScheme.primary
        : (hasSchedules ? colorScheme.primaryContainer : null);

    return Center(
      child: Container(
        width: 15,
        height: 15,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
        child: Text(
          '${cell.date.day}',
          style: TextStyle(
            fontSize: 8.5,
            height: 1,
            fontWeight: isToday || hasSchedules
                ? FontWeight.w700
                : FontWeight.w400,
            color: isToday
                ? colorScheme.onPrimary
                : (hasSchedules
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_timeline_tile.dart';

/// Schedules of the selected day, shown right under the month grid or the
/// week strip. Rendered as a plain column inside the page's scroll view.
class ScheduleV2DayAgenda extends StatelessWidget {
  const ScheduleV2DayAgenda({
    required this.date,
    required this.schedules,
    required this.isLoading,
    required this.onSchedulePressed,
    this.onCreatePressed,
    super.key,
  });

  final DateTime date;
  final List<ScheduleModel> schedules;
  final bool isLoading;
  final ValueChanged<ScheduleModel> onSchedulePressed;

  /// Null hides the empty-state create button (no create permission).
  final VoidCallback? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatScheduleWeekday(date)}, ${formatTimelineDate(date)}',
                  key: const ValueKey('schedule-v2-agenda-title'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (schedules.isNotEmpty)
                Text(
                  formatScheduleEventCountLabel(schedules.length),
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (schedules.isEmpty)
            _EmptyAgenda(onCreatePressed: onCreatePressed)
          else
            for (var index = 0; index < schedules.length; index++) ...[
              if (index > 0) const SizedBox(height: 12),
              ScheduleTimelineTile(
                schedule: schedules[index],
                isFirst: index == 0,
                isLast: index == schedules.length - 1,
                onTap: () => onSchedulePressed(schedules[index]),
              ),
            ],
        ],
      ),
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda({required this.onCreatePressed});

  final VoidCallback? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onCreatePressed = this.onCreatePressed;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 36,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'Không có lịch trình',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          if (onCreatePressed != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              key: const ValueKey('schedule-v2-empty-create'),
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add),
              label: const Text('Tạo lịch trình'),
            ),
          ],
        ],
      ),
    );
  }
}

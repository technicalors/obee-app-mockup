import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_timeline_tile.dart';

class ScheduleDayPanel extends StatelessWidget {
  const ScheduleDayPanel({
    required this.selectedDate,
    required this.daySchedules,
    required this.isLoading,
    required this.canCreateSchedule,
    required this.onCreatePressed,
    required this.onSchedulePressed,
    this.onClose,
    super.key,
  });

  final DateTime selectedDate;
  final List<ScheduleModel> daySchedules;
  final bool isLoading;
  final bool canCreateSchedule;
  final VoidCallback onCreatePressed;
  final ValueChanged<ScheduleModel> onSchedulePressed;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Lịch ngày dd/MM [Count] ... [Close Button]
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
            child: Row(
              children: [
                Text(
                  formatScheduleSelectedDayLabel(selectedDate),
                  key: const ValueKey('selected-day-label'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      '${daySchedules.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (onClose != null)
                  IconButton(
                    key: const ValueKey('schedule-day-panel-close'),
                    icon: Icon(
                      Icons.close,
                      size: 22,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Trở lại lịch tháng',
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
          // Content: No height restriction, scrolls smoothly
          Expanded(
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              itemCount: isLoading || daySchedules.isEmpty
                  ? 1
                  : daySchedules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (daySchedules.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: colorScheme.surfaceContainerLow,
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Text(
                        'Không có lịch trình cho ngày đã chọn.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }
                return ScheduleTimelineTile(
                  schedule: daySchedules[i],
                  isFirst: i == 0,
                  isLast: i == daySchedules.length - 1,
                  onTap: () => onSchedulePressed(daySchedules[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

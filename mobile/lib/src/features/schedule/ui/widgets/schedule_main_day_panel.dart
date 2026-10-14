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
          // Drag handle + header; swiping down returns to the full month.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragEnd: onClose == null
                ? null
                : (details) {
                    if ((details.primaryVelocity ?? 0) > 250) {
                      onClose!();
                    }
                  },
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 12, 6),
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
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 44,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Không có lịch trình cho ngày đã chọn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        if (canCreateSchedule) ...[
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            key: const ValueKey('schedule-day-empty-create'),
                            onPressed: onCreatePressed,
                            icon: const Icon(Icons.add),
                            label: const Text('Tạo lịch trình'),
                          ),
                        ],
                      ],
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

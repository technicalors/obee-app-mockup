import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_participants_text.dart';

class ScheduleTimelineTile extends StatelessWidget {
  const ScheduleTimelineTile({
    required this.schedule,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
    super.key,
  });

  final ScheduleModel schedule;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final type = schedule.event.type;
    final timelineValues = formatScheduleTimelineValues(schedule);
    final address = schedule.event.physicalAddress;
    final note = schedule.event.note;
    final isRepeat =
        schedule.event.scheduleType == ScheduleEventScheduleType.repeat;

    final isOnline =
        (address != null && address.toLowerCase().contains('online')) ||
        (note != null && note.toLowerCase().contains('online')) ||
        (note != null &&
            (note.toLowerCase().contains('meet.google') ||
                note.toLowerCase().contains('zoom')));

    final displayLocation =
        address ??
        (isOnline
            ? (note != null && note.isNotEmpty ? note : 'Online - Google Meet')
            : null);

    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      key: ValueKey('schedule-tile-${schedule.id}'),
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Time Column
          SizedBox(
            width: 48,
            child: _ScheduleTimeColumn(values: timelineValues),
          ),
          const SizedBox(width: 12),
          // Event card matching screenshot
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: type.harmonizedCardBackgroundColor(colorScheme),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top row: Title + Type Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          schedule.event.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: type.backgroundColorFor(colorScheme),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          type.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: type.foregroundColorFor(colorScheme),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Bottom Row: Location/Online (left) + Participants text (right)
                  if (displayLocation != null ||
                      schedule.event.participants.isNotEmpty ||
                      isRepeat) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (isRepeat) ...[
                          Icon(
                            Icons.repeat,
                            size: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (displayLocation != null) ...[
                          Icon(
                            isOnline
                                ? Icons.videocam_outlined
                                : Icons.location_on_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              displayLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                        if (displayLocation != null &&
                            schedule.event.participants.isNotEmpty)
                          const SizedBox(width: 8),
                        if (schedule.event.participants.isNotEmpty)
                          Expanded(
                            child: ScheduleParticipantsText(
                              participants: schedule.event.participants,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTimeColumn extends StatelessWidget {
  const _ScheduleTimeColumn({required this.values});

  final List<ScheduleTimelineValue> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final first = values.first;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            first.primary,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          if (first.secondary != null)
            Text(
              first.secondary!,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          if (values.length > 1) ...[
            const SizedBox(height: 2),
            Text(
              values[1].primary,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
            ),
            if (values[1].secondary != null)
              Text(
                values[1].secondary!,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

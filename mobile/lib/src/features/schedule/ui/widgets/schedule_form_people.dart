import 'package:flutter/material.dart';
import 'package:obee_mobile/src/core/widgets/tree_select.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_form_controller.dart';

class ScheduleFormPeopleSection extends StatelessWidget {
  const ScheduleFormPeopleSection({
    super.key,
    required this.formState,
    required this.isUsersLoading,
    required this.scheduleUserGroups,
    required this.onParticipantsChanged,
    required this.onObserversChanged,
  });

  final ScheduleFormState formState;
  final bool isUsersLoading;
  final List<TreeSelectGroup> scheduleUserGroups;
  final ValueChanged<Set<String>> onParticipantsChanged;
  final ValueChanged<Set<String>> onObserversChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TreeSelect(
          fieldKey: const ValueKey('schedule-participants-field'),
          sheetKey: const ValueKey('schedule-participants-sheet'),
          searchFieldKey: const ValueKey('schedule-participants-search'),
          clearButtonKey: const ValueKey('schedule-clear-participants'),
          searchHintText: 'Tìm người tham gia',
          title: 'Tham gia',
          loading: isUsersLoading,
          selectedIds: formState.participants,
          enabled: !formState.isSubmitting,
          groups: scheduleUserGroups,
          emptyText: 'Không tìm thấy người dùng phù hợp.',
          groupKeyBuilder: (group) =>
              ValueKey('schedule-user-group-${group.id}'),
          itemKeyBuilder: (group, item) =>
              ValueKey('schedule-user-${group.id}-${item.id}'),
          onChanged: onParticipantsChanged,
        ),
        const SizedBox(height: 16),
        TreeSelect(
          fieldKey: const ValueKey('schedule-observers-field'),
          sheetKey: const ValueKey('schedule-observers-sheet'),
          searchFieldKey: const ValueKey('schedule-observers-search'),
          clearButtonKey: const ValueKey('schedule-clear-observers'),
          searchHintText: 'Tìm người chia sẻ',
          title: 'Chia sẻ',
          loading: isUsersLoading,
          selectedIds: formState.observers,
          enabled: !formState.isSubmitting,
          groups: scheduleUserGroups,
          emptyText: 'Không tìm thấy người dùng phù hợp.',
          groupKeyBuilder: (group) =>
              ValueKey('schedule-user-group-${group.id}'),
          itemKeyBuilder: (group, item) =>
              ValueKey('schedule-user-${group.id}-${item.id}'),
          onChanged: onObserversChanged,
        ),
      ],
    );
  }
}

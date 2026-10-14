import 'package:obee_mobile/src/core/widgets/tree_select.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';

List<TreeSelectGroup> buildRepeatPatternGroups(
  ScheduleEventRepeatType repeatType,
) {
  return switch (repeatType) {
    ScheduleEventRepeatType.weekly => const [
      TreeSelectGroup(
        id: 'weekly',
        label: 'Thứ trong tuần',
        items: [
          TreeSelectItem(id: '0', label: 'Chủ nhật'),
          TreeSelectItem(id: '1', label: 'Thứ 2'),
          TreeSelectItem(id: '2', label: 'Thứ 3'),
          TreeSelectItem(id: '3', label: 'Thứ 4'),
          TreeSelectItem(id: '4', label: 'Thứ 5'),
          TreeSelectItem(id: '5', label: 'Thứ 6'),
          TreeSelectItem(id: '6', label: 'Thứ 7'),
        ],
      ),
    ],
    ScheduleEventRepeatType.monthly => [
      TreeSelectGroup(
        id: 'monthly',
        label: 'Ngày trong tháng',
        items: List<TreeSelectItem>.generate(31, (index) {
          final day = index + 1;

          return TreeSelectItem(id: '$day', label: '$day');
        }, growable: false),
      ),
    ],
    ScheduleEventRepeatType.daily => const [],
  };
}

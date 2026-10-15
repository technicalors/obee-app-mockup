import 'package:obee_mobile/src/features/tasks/data/task_models.dart';

/// Pseudo list id for the "starred" tab, which spans every list.
const starredTaskListId = '__starred__';

enum TaskSortOrder { myOrder, date, starredRecently }

extension TaskSortOrderX on TaskSortOrder {
  String get label => switch (this) {
    TaskSortOrder.myOrder => 'Thứ tự của tôi',
    TaskSortOrder.date => 'Ngày',
    TaskSortOrder.starredRecently => 'Gắn dấu sao gần đây',
  };
}

/// A top-level task with its open subtasks, as rendered in the list.
final class TaskEntry {
  const TaskEntry({required this.task, this.subtasks = const []});

  final TaskModel task;
  final List<TaskModel> subtasks;
}

/// A titled group of entries; the title is null for a single ungrouped list.
final class TaskSection {
  const TaskSection({
    required this.entries,
    this.title,
    this.isOverdue = false,
  });

  final String? title;
  final bool isOverdue;
  final List<TaskEntry> entries;
}

String formatTaskDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int _byPosition(TaskModel a, TaskModel b) {
  final byPosition = a.position.compareTo(b.position);
  return byPosition != 0 ? byPosition : a.createdAt.compareTo(b.createdAt);
}

/// Open tasks of [listId] grouped for display. The starred tab lists every
/// starred open task flat; regular lists nest open subtasks under parents.
List<TaskSection> buildOpenTaskSections({
  required List<TaskModel> tasks,
  required String listId,
  required TaskSortOrder sort,
  required DateTime today,
}) {
  final isStarredView = listId == starredTaskListId;
  final open = tasks.where((task) => !task.completed).toList();

  final List<TaskEntry> entries;
  if (isStarredView) {
    entries = [
      for (final task in open.where((task) => task.starred))
        TaskEntry(task: task),
    ];
  } else {
    final subtasksByParent = <String, List<TaskModel>>{};
    for (final task in open.where((task) => task.listId == listId)) {
      final parentId = task.parentId;
      if (parentId != null) {
        subtasksByParent.putIfAbsent(parentId, () => []).add(task);
      }
    }
    entries = [
      for (final task in open.where(
        (task) => task.listId == listId && !task.isSubtask,
      ))
        TaskEntry(
          task: task,
          subtasks: (subtasksByParent[task.id] ?? [])..sort(_byPosition),
        ),
    ];
  }

  switch (sort) {
    case TaskSortOrder.myOrder:
      entries.sort((a, b) => _byPosition(a.task, b.task));
      return [if (entries.isNotEmpty) TaskSection(entries: entries)];
    case TaskSortOrder.starredRecently:
      entries.sort((a, b) {
        final aStar = a.task.starred ? a.task.starredAt ?? '' : null;
        final bStar = b.task.starred ? b.task.starredAt ?? '' : null;
        if (aStar != null && bStar != null) return bStar.compareTo(aStar);
        if (aStar != null) return -1;
        if (bStar != null) return 1;
        return _byPosition(a.task, b.task);
      });
      return [if (entries.isNotEmpty) TaskSection(entries: entries)];
    case TaskSortOrder.date:
      return _groupByDueDate(entries, _dateOnly(today));
  }
}

List<TaskSection> _groupByDueDate(List<TaskEntry> entries, DateTime today) {
  final overdue = <TaskEntry>[];
  final byDay = <DateTime, List<TaskEntry>>{};
  final undated = <TaskEntry>[];

  for (final entry in entries) {
    final due = entry.task.due;
    if (due == null) {
      undated.add(entry);
    } else if (due.isBefore(today)) {
      overdue.add(entry);
    } else {
      byDay.putIfAbsent(_dateOnly(due), () => []).add(entry);
    }
  }

  int byDueThenPosition(TaskEntry a, TaskEntry b) {
    final byDue = (a.task.dueDate ?? '').compareTo(b.task.dueDate ?? '');
    return byDue != 0 ? byDue : _byPosition(a.task, b.task);
  }

  final days = byDay.keys.toList()..sort();
  return [
    if (overdue.isNotEmpty)
      TaskSection(
        title: 'Quá hạn',
        isOverdue: true,
        entries: overdue..sort(byDueThenPosition),
      ),
    for (final day in days)
      TaskSection(
        title: formatTaskDueLabel(day, today),
        entries: byDay[day]!..sort(byDueThenPosition),
      ),
    if (undated.isNotEmpty)
      TaskSection(
        title: 'Không có ngày',
        entries: undated..sort((a, b) => _byPosition(a.task, b.task)),
      ),
  ];
}

/// Completed tasks of [listId] (or every starred one), most recent first.
List<TaskModel> completedTasks({
  required List<TaskModel> tasks,
  required String listId,
}) {
  final isStarredView = listId == starredTaskListId;
  return tasks
      .where(
        (task) =>
            task.completed &&
            (isStarredView ? task.starred : task.listId == listId),
      )
      .toList()
    ..sort((a, b) => (b.completedAt ?? '').compareTo(a.completedAt ?? ''));
}

const _weekdayShort = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// Relative due label: `Hôm nay`, `Ngày mai`, `Hôm qua`, otherwise
/// `T2, 20/10` (with the year when it differs from today's).
String formatTaskDueLabel(DateTime due, DateTime today) {
  final day = _dateOnly(due);
  final difference = day.difference(_dateOnly(today)).inDays;
  if (difference == 0) return 'Hôm nay';
  if (difference == 1) return 'Ngày mai';
  if (difference == -1) return 'Hôm qua';

  final dayMonth =
      '${day.day.toString().padLeft(2, '0')}/'
      '${day.month.toString().padLeft(2, '0')}';
  final weekday = _weekdayShort[day.weekday - 1];
  return day.year == today.year
      ? '$weekday, $dayMonth'
      : '$weekday, $dayMonth/${day.year}';
}

bool isTaskOverdue(TaskModel task, DateTime today) {
  final due = task.due;
  return !task.completed && due != null && due.isBefore(_dateOnly(today));
}

import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/tasks/logic/task_logic.dart';

import 'support/fake_task_api.dart';

void main() {
  final today = DateTime(2026, 6, 10);

  final tasks = [
    fakeTask('a', 'Overdue', dueDate: '2026-06-08', position: 2),
    fakeTask('b', 'Today', dueDate: '2026-06-10', position: 0, starred: true),
    fakeTask('c', 'Tomorrow', dueDate: '2026-06-11', position: 1),
    fakeTask('d', 'No date', position: 3),
    fakeTask('d1', 'Sub open', parentId: 'd', position: 1),
    fakeTask('d2', 'Sub first', parentId: 'd', position: 0),
    fakeTask('d3', 'Sub done', parentId: 'd', completed: true),
    fakeTask('e', 'Done', completed: true, completedAt: '2026-06-09T08:00:00'),
    fakeTask('f', 'Other list', listId: 'list-project', starred: true),
  ];

  test('my order nests open subtasks under their parent', () {
    final sections = buildOpenTaskSections(
      tasks: tasks,
      listId: 'list-default',
      sort: TaskSortOrder.myOrder,
      today: today,
    );

    expect(sections, hasLength(1));
    expect(sections.single.title, isNull);
    expect(sections.single.entries.map((entry) => entry.task.id), [
      'b',
      'c',
      'a',
      'd',
    ]);
    expect(sections.single.entries.last.subtasks.map((task) => task.id), [
      'd2',
      'd1',
    ]);
  });

  test('date sort groups overdue, relative days and undated tasks', () {
    final sections = buildOpenTaskSections(
      tasks: tasks,
      listId: 'list-default',
      sort: TaskSortOrder.date,
      today: today,
    );

    expect(sections.map((section) => section.title), [
      'Quá hạn',
      'Hôm nay',
      'Ngày mai',
      'Không có ngày',
    ]);
    expect(sections.first.isOverdue, isTrue);
    expect(sections.last.entries.single.task.id, 'd');
  });

  test('starred view spans lists and shows starred tasks flat', () {
    final sections = buildOpenTaskSections(
      tasks: tasks,
      listId: starredTaskListId,
      sort: TaskSortOrder.myOrder,
      today: today,
    );

    expect(sections.single.entries.map((entry) => entry.task.id), ['b', 'f']);
  });

  test('starred recently puts starred tasks first, newest first', () {
    final sections = buildOpenTaskSections(
      tasks: [
        fakeTask('x', 'Old star', starred: true, starredAt: '2026-06-01'),
        fakeTask('y', 'Plain', position: -5),
        fakeTask('z', 'New star', starred: true, starredAt: '2026-06-09'),
      ],
      listId: 'list-default',
      sort: TaskSortOrder.starredRecently,
      today: today,
    );

    expect(sections.single.entries.map((entry) => entry.task.id), [
      'z',
      'x',
      'y',
    ]);
  });

  test('completed tasks include subtasks, most recent first', () {
    final done = completedTasks(tasks: tasks, listId: 'list-default');

    expect(done.map((task) => task.id), ['d3', 'e']);
  });

  test('due labels are relative near today', () {
    expect(formatTaskDueLabel(DateTime(2026, 6, 10), today), 'Hôm nay');
    expect(formatTaskDueLabel(DateTime(2026, 6, 11), today), 'Ngày mai');
    expect(formatTaskDueLabel(DateTime(2026, 6, 9), today), 'Hôm qua');
    expect(formatTaskDueLabel(DateTime(2026, 6, 15), today), 'T2, 15/06');
    expect(formatTaskDueLabel(DateTime(2027, 1, 4), today), 'T2, 04/01/2027');
  });

  test('overdue only applies to open tasks with a past due date', () {
    expect(isTaskOverdue(tasks[0], today), isTrue);
    expect(isTaskOverdue(tasks[1], today), isFalse);
    expect(
      isTaskOverdue(
        fakeTask('g', 'Done late', dueDate: '2026-06-01', completed: true),
        today,
      ),
      isFalse,
    );
  });
}

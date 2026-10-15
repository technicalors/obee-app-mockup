import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/tasks/data/task_api.dart';
import 'package:obee_mobile/src/features/tasks/logic/task_logic.dart';
import 'package:obee_mobile/src/features/tasks/state/tasks_controller.dart';

import 'support/fake_task_api.dart';

void main() {
  late FakeTaskApi api;
  late ProviderContainer container;

  TasksController controller() =>
      container.read(tasksControllerProvider.notifier);
  TasksState state() => container.read(tasksControllerProvider);

  setUp(() async {
    api = FakeTaskApi(
      tasks: [
        fakeTask('parent', 'Parent'),
        fakeTask('child-1', 'Child 1', parentId: 'parent'),
        fakeTask('child-2', 'Child 2', parentId: 'parent', position: 1),
        fakeTask('other', 'Other', position: 1),
      ],
    );
    container = ProviderContainer(
      overrides: [taskApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    await controller().load(now: DateTime(2026, 6, 10));
  });

  test('load selects the default list', () {
    expect(state().isLoading, isFalse);
    expect(state().selectedListId, 'list-default');
    expect(state().lists, hasLength(2));
  });

  test(
    'adding from the starred tab stars the task in the default list',
    () async {
      controller().selectList(starredTaskListId);
      await controller().addTask(title: '  Call client  ');

      final created = api.tasks.last;
      expect(created.title, 'Call client');
      expect(created.listId, 'list-default');
      expect(created.starred, isTrue);
      expect(
        state().tasks.any((task) => task.id.startsWith('pending')),
        isFalse,
      );
    },
  );

  test('subtasks inherit the parent list', () async {
    controller().selectList('list-project');
    await controller().addTask(title: 'Step', parentId: 'parent');

    expect(api.tasks.last.listId, 'list-default');
    expect(api.tasks.last.parentId, 'parent');
  });

  test('completing a parent completes its open subtasks', () async {
    await controller().toggleCompleted(state().taskById('parent')!);

    expect(
      [
        'parent',
        'child-1',
        'child-2',
      ].map((id) => state().taskById(id)!.completed),
      everyElement(isTrue),
    );
    expect(state().taskById('other')!.completed, isFalse);
    expect(state().completed, hasLength(3));
  });

  test('deleting a task removes its subtasks', () async {
    await controller().deleteTask(state().taskById('parent')!);

    expect(state().tasks.map((task) => task.id), ['other']);
    expect(api.tasks.map((task) => task.id), ['other']);
  });

  test('update sets and clears the due date', () async {
    final task = state().taskById('other')!;
    await controller().updateTask(task, due: DateTime(2026, 6, 12));
    expect(state().taskById('other')!.dueDate, '2026-06-12');

    await controller().updateTask(state().taskById('other')!, clearDue: true);
    expect(state().taskById('other')!.dueDate, isNull);
  });

  test('sort order is remembered per list', () {
    controller().setSort(TaskSortOrder.date);
    controller().selectList('list-project');
    expect(state().sort, TaskSortOrder.myOrder);
    controller().selectList('list-default');
    expect(state().sort, TaskSortOrder.date);
  });

  test('creating a list selects it; deleting returns to default', () async {
    await controller().createList('Cá nhân');
    final created = state().lists.last;
    expect(created.title, 'Cá nhân');
    expect(state().selectedListId, created.id);

    await controller().deleteList(created.id);
    expect(state().selectedListId, 'list-default');
    expect(state().lists.map((list) => list.id), isNot(contains(created.id)));
  });

  test('clear completed deletes only completed tasks of the list', () async {
    await controller().toggleCompleted(state().taskById('other')!);
    await controller().clearCompleted();

    expect(api.deletedTaskIds, ['other']);
    expect(state().taskById('parent'), isNotNull);
  });

  test('failed writes surface a message and reload server state', () async {
    api.failWrites = true;
    await controller().toggleStarred(state().taskById('other')!);

    expect(state().errorMessage, 'Không thể lưu thay đổi.');
    expect(state().taskById('other')!.starred, isFalse);
  });
}

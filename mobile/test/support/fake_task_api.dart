import 'package:obee_mobile/src/features/tasks/data/task_api.dart';
import 'package:obee_mobile/src/features/tasks/data/task_models.dart';

/// In-memory [TaskApi] with deterministic data for controller/widget tests.
class FakeTaskApi implements TaskApi {
  FakeTaskApi({List<TaskListModel>? lists, List<TaskModel>? tasks})
    : lists = lists ?? [defaultList, projectList],
      tasks = tasks ?? [];

  static const defaultList = TaskListModel(
    id: 'list-default',
    title: 'Công việc của tôi',
    isDefault: true,
  );
  static const projectList = TaskListModel(id: 'list-project', title: 'Dự án');

  List<TaskListModel> lists;
  List<TaskModel> tasks;
  bool failWrites = false;
  int _sequence = 0;
  final List<String> deletedTaskIds = [];

  void _checkWrite() {
    if (failWrites) throw StateError('write failed');
  }

  @override
  Future<List<TaskListModel>> fetchLists() async => List.of(lists);

  @override
  Future<List<TaskModel>> fetchTasks() async => List.of(tasks);

  @override
  Future<TaskListModel> createList(String title) async {
    _checkWrite();
    final list = TaskListModel(id: 'list-${++_sequence}', title: title);
    lists = [...lists, list];
    return list;
  }

  @override
  Future<TaskListModel> renameList(String id, String title) async {
    _checkWrite();
    final list = lists
        .firstWhere((item) => item.id == id)
        .copyWith(title: title);
    lists = [for (final item in lists) item.id == id ? list : item];
    return list;
  }

  @override
  Future<void> deleteList(String id) async {
    _checkWrite();
    lists = lists.where((list) => list.id != id).toList();
    tasks = tasks.where((task) => task.listId != id).toList();
  }

  @override
  Future<TaskModel> createTask(TaskDraft draft) async {
    _checkWrite();
    final task = TaskModel(
      id: 'task-new-${++_sequence}',
      listId: draft.listId,
      parentId: draft.parentId,
      title: draft.title,
      notes: draft.notes,
      dueDate: draft.dueDate,
      starred: draft.starred,
      starredAt: draft.starred ? '2026-06-10T09:00:00' : null,
      position: -_sequence,
      createdAt: '2026-06-10T09:00:00',
    );
    tasks = [...tasks, task];
    return task;
  }

  @override
  Future<TaskModel> updateTask(String id, Map<String, Object?> changes) async {
    _checkWrite();
    final json = {
      ...tasks.firstWhere((task) => task.id == id).toJson(),
      ...changes,
    };
    if (changes.containsKey('completed')) {
      json['completed_at'] = changes['completed'] == true
          ? '2026-06-10T10:00:00'
          : null;
    }
    if (changes.containsKey('starred')) {
      json['starred_at'] = changes['starred'] == true
          ? '2026-06-10T10:00:00'
          : null;
    }
    final updated = TaskModel.fromJson(json);
    tasks = [for (final task in tasks) task.id == id ? updated : task];
    return updated;
  }

  @override
  Future<void> deleteTask(String id) async {
    _checkWrite();
    deletedTaskIds.add(id);
    tasks = tasks
        .where((task) => task.id != id && task.parentId != id)
        .toList();
  }
}

TaskModel fakeTask(
  String id,
  String title, {
  String listId = 'list-default',
  String? parentId,
  String? notes,
  String? dueDate,
  bool starred = false,
  String? starredAt,
  bool completed = false,
  String? completedAt,
  int position = 0,
}) {
  return TaskModel(
    id: id,
    listId: listId,
    parentId: parentId,
    title: title,
    notes: notes,
    dueDate: dueDate,
    starred: starred,
    starredAt: starredAt ?? (starred ? '2026-06-01T09:00:00' : null),
    completed: completed,
    completedAt: completedAt ?? (completed ? '2026-06-09T09:00:00' : null),
    position: position,
    createdAt: '2026-06-01T09:00:00',
  );
}

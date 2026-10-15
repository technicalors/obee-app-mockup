import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/features/tasks/data/task_models.dart';

final taskApiProvider = Provider<TaskApi>((ref) {
  return MobileTaskApi(ref.watch(apiClientProvider));
});

abstract interface class TaskApi {
  Future<List<TaskListModel>> fetchLists();

  Future<TaskListModel> createList(String title);

  Future<TaskListModel> renameList(String id, String title);

  /// Deletes the list together with its tasks.
  Future<void> deleteList(String id);

  Future<List<TaskModel>> fetchTasks();

  Future<TaskModel> createTask(TaskDraft draft);

  /// Partial update; only the given keys change. Keys use the wire names
  /// (`title`, `notes`, `due_date`, `starred`, `completed`).
  Future<TaskModel> updateTask(String id, Map<String, Object?> changes);

  /// Deletes the task together with its subtasks.
  Future<void> deleteTask(String id);
}

final class MobileTaskApi implements TaskApi {
  const MobileTaskApi(this._api);

  final ApiClient _api;

  @override
  Future<List<TaskListModel>> fetchLists() async {
    final body = await _api.get<List<dynamic>>('/task-lists');
    return body
        .cast<Map<String, dynamic>>()
        .map(TaskListModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<TaskListModel> createList(String title) async {
    final body = await _api.post<Map<String, dynamic>>(
      '/task-lists',
      data: {'title': title},
    );
    return TaskListModel.fromJson(body);
  }

  @override
  Future<TaskListModel> renameList(String id, String title) async {
    final body = await _api.patch<Map<String, dynamic>>(
      '/task-lists/$id',
      data: {'title': title},
    );
    return TaskListModel.fromJson(body);
  }

  @override
  Future<void> deleteList(String id) => _api.delete('/task-lists/$id');

  @override
  Future<List<TaskModel>> fetchTasks() async {
    final body = await _api.get<List<dynamic>>('/tasks');
    return body
        .cast<Map<String, dynamic>>()
        .map(TaskModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<TaskModel> createTask(TaskDraft draft) async {
    final body = await _api.post<Map<String, dynamic>>(
      '/tasks',
      data: draft.toRequestJson(),
    );
    return TaskModel.fromJson(body);
  }

  @override
  Future<TaskModel> updateTask(String id, Map<String, Object?> changes) async {
    final body = await _api.patch<Map<String, dynamic>>(
      '/tasks/$id',
      data: changes,
    );
    return TaskModel.fromJson(body);
  }

  @override
  Future<void> deleteTask(String id) => _api.delete('/tasks/$id');
}

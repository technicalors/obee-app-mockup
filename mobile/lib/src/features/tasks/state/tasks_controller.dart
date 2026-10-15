import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/time/business_time.dart';
import 'package:obee_mobile/src/features/tasks/data/task_api.dart';
import 'package:obee_mobile/src/features/tasks/data/task_models.dart';
import 'package:obee_mobile/src/features/tasks/logic/task_logic.dart';

final tasksControllerProvider = NotifierProvider<TasksController, TasksState>(
  TasksController.new,
);

/// Google Tasks style state: lists, every task, the selected list and its
/// sort order. Mutations update the UI first and then reconcile with the
/// server response; failures surface a message and reload.
class TasksController extends Notifier<TasksState> {
  late TaskApi _api;
  int _tempSequence = 0;

  @override
  TasksState build() {
    _api = ref.watch(taskApiProvider);
    return TasksState.initial();
  }

  Future<void> load({DateTime? now}) async {
    final today = now ?? businessNow();
    state = state.copyWith(
      isLoading: true,
      today: DateTime(today.year, today.month, today.day),
      errorMessage: null,
    );
    try {
      final results = await Future.wait([_api.fetchLists(), _api.fetchTasks()]);
      if (!ref.mounted) return;
      final lists = results[0] as List<TaskListModel>;
      final tasks = results[1] as List<TaskModel>;
      final selected = _resolveSelectedList(lists, state.selectedListId);
      state = state.copyWith(
        isLoading: false,
        lists: lists,
        tasks: tasks,
        selectedListId: selected,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách công việc.',
      );
    }
  }

  void clearFeedback() => state = state.copyWith(errorMessage: null);

  void selectList(String listId) {
    state = state.copyWith(selectedListId: listId);
  }

  void setSort(TaskSortOrder sort) {
    state = state.copyWith(
      sortByList: {...state.sortByList, state.selectedListId: sort},
    );
  }

  Future<void> createList(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await _guard(() async {
      final list = await _api.createList(trimmed);
      state = state.copyWith(
        lists: [...state.lists, list],
        selectedListId: list.id,
      );
    });
  }

  Future<void> renameList(String listId, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await _guard(() async {
      final list = await _api.renameList(listId, trimmed);
      state = state.copyWith(
        lists: [
          for (final item in state.lists) item.id == listId ? list : item,
        ],
      );
    });
  }

  Future<void> deleteList(String listId) async {
    state = state.copyWith(
      lists: state.lists.where((list) => list.id != listId).toList(),
      tasks: state.tasks.where((task) => task.listId != listId).toList(),
      selectedListId: state.defaultListId,
    );
    await _guard(() => _api.deleteList(listId));
  }

  /// Adds a task to the selected list. From the starred tab the task goes to
  /// the default list and is starred, matching Google Tasks.
  Future<void> addTask({
    required String title,
    String? notes,
    DateTime? due,
    bool starred = false,
    String? parentId,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final parent = parentId == null ? null : state.taskById(parentId);
    final isStarredView = state.selectedListId == starredTaskListId;
    final listId =
        parent?.listId ??
        (isStarredView ? state.defaultListId : state.selectedListId);
    final draft = TaskDraft(
      listId: listId,
      parentId: parentId,
      title: trimmed,
      notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
      dueDate: due == null ? null : formatTaskDate(due),
      starred: starred || (isStarredView && parent == null),
    );

    final siblings = state.tasks.where(
      (task) => task.listId == listId && task.parentId == parentId,
    );
    final placeholder = TaskModel(
      id: 'pending-${++_tempSequence}',
      listId: listId,
      parentId: parentId,
      title: draft.title,
      notes: draft.notes,
      dueDate: draft.dueDate,
      starred: draft.starred,
      starredAt: draft.starred ? DateTime.now().toIso8601String() : null,
      position: parentId == null
          ? (siblings.isEmpty
                    ? 0
                    : siblings.map((t) => t.position).reduce(_min)) -
                1
          : siblings.length,
      createdAt: DateTime.now().toIso8601String(),
    );
    state = state.copyWith(tasks: [...state.tasks, placeholder]);

    await _guard(() async {
      final created = await _api.createTask(draft);
      _replace(placeholder.id, created);
    });
  }

  Future<void> updateTask(
    TaskModel task, {
    String? title,
    String? notes,
    DateTime? due,
    bool clearDue = false,
  }) async {
    final changes = <String, Object?>{
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      'notes': ?notes,
      if (due != null) 'due_date': formatTaskDate(due),
      if (clearDue) 'due_date': null,
    };
    if (changes.isEmpty) return;

    _replace(
      task.id,
      task.copyWith(
        title: changes['title'] as String? ?? task.title,
        notes: notes ?? task.notes,
        dueDate: changes.containsKey('due_date')
            ? changes['due_date'] as String?
            : task.dueDate,
      ),
    );
    await _guard(() async {
      _replace(task.id, await _api.updateTask(task.id, changes));
    });
  }

  /// Completing a parent also completes its open subtasks.
  Future<void> toggleCompleted(TaskModel task) async {
    final completed = !task.completed;
    final stamp = completed ? DateTime.now().toIso8601String() : null;
    final affected = [
      task,
      if (completed)
        ...state.tasks.where(
          (item) => item.parentId == task.id && !item.completed,
        ),
    ];

    for (final item in affected) {
      _replace(
        item.id,
        item.copyWith(completed: completed, completedAt: stamp),
      );
    }
    await _guard(() async {
      for (final item in affected) {
        _replace(
          item.id,
          await _api.updateTask(item.id, {'completed': completed}),
        );
      }
    });
  }

  Future<void> toggleStarred(TaskModel task) async {
    final starred = !task.starred;
    _replace(
      task.id,
      task.copyWith(
        starred: starred,
        starredAt: starred ? DateTime.now().toIso8601String() : null,
      ),
    );
    await _guard(() async {
      _replace(task.id, await _api.updateTask(task.id, {'starred': starred}));
    });
  }

  Future<void> deleteTask(TaskModel task) async {
    state = state.copyWith(
      tasks: state.tasks
          .where((item) => item.id != task.id && item.parentId != task.id)
          .toList(),
    );
    await _guard(() => _api.deleteTask(task.id));
  }

  /// Deletes every completed task of the selected list.
  Future<void> clearCompleted() async {
    final done = completedTasks(
      tasks: state.tasks,
      listId: state.selectedListId,
    );
    final ids = done.map((task) => task.id).toSet();
    state = state.copyWith(
      tasks: state.tasks
          .where(
            (task) => !ids.contains(task.id) && !ids.contains(task.parentId),
          )
          .toList(),
    );
    await _guard(() async {
      for (final task in done) {
        await _api.deleteTask(task.id);
      }
    });
  }

  void _replace(String id, TaskModel task) {
    state = state.copyWith(
      tasks: [for (final item in state.tasks) item.id == id ? task : item],
    );
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!ref.mounted) return;
      // Reload first: load() resets the message it starts with.
      await load(now: state.today);
      if (!ref.mounted) return;
      state = state.copyWith(errorMessage: 'Không thể lưu thay đổi.');
    }
  }

  String _resolveSelectedList(List<TaskListModel> lists, String current) {
    if (current == starredTaskListId ||
        lists.any((list) => list.id == current)) {
      return current;
    }
    return lists
            .where((list) => list.isDefault)
            .map((list) => list.id)
            .firstOrNull ??
        lists.firstOrNull?.id ??
        '';
  }
}

int _min(int a, int b) => a < b ? a : b;

class TasksState {
  const TasksState({
    required this.isLoading,
    required this.today,
    required this.lists,
    required this.tasks,
    required this.selectedListId,
    required this.sortByList,
    required this.errorMessage,
  });

  factory TasksState.initial() {
    final now = businessNow();
    return TasksState(
      isLoading: true,
      today: DateTime(now.year, now.month, now.day),
      lists: const [],
      tasks: const [],
      selectedListId: '',
      sortByList: const {},
      errorMessage: null,
    );
  }

  final bool isLoading;
  final DateTime today;
  final List<TaskListModel> lists;
  final List<TaskModel> tasks;
  final String selectedListId;
  final Map<String, TaskSortOrder> sortByList;
  final String? errorMessage;

  bool get isStarredView => selectedListId == starredTaskListId;

  TaskSortOrder get sort => sortByList[selectedListId] ?? TaskSortOrder.myOrder;

  String get defaultListId =>
      lists.where((list) => list.isDefault).firstOrNull?.id ??
      lists.firstOrNull?.id ??
      '';

  TaskListModel? get selectedList =>
      lists.where((list) => list.id == selectedListId).firstOrNull;

  TaskModel? taskById(String id) =>
      tasks.where((task) => task.id == id).firstOrNull;

  List<TaskModel> subtasksOf(String parentId) =>
      tasks.where((task) => task.parentId == parentId).toList()
        ..sort((a, b) => a.position.compareTo(b.position));

  List<TaskSection> get openSections => buildOpenTaskSections(
    tasks: tasks,
    listId: selectedListId,
    sort: sort,
    today: today,
  );

  List<TaskModel> get completed =>
      completedTasks(tasks: tasks, listId: selectedListId);

  TasksState copyWith({
    bool? isLoading,
    DateTime? today,
    List<TaskListModel>? lists,
    List<TaskModel>? tasks,
    String? selectedListId,
    Map<String, TaskSortOrder>? sortByList,
    Object? errorMessage = _notChanged,
  }) {
    return TasksState(
      isLoading: isLoading ?? this.isLoading,
      today: today ?? this.today,
      lists: lists ?? this.lists,
      tasks: tasks ?? this.tasks,
      selectedListId: selectedListId ?? this.selectedListId,
      sortByList: sortByList ?? this.sortByList,
      errorMessage: errorMessage == _notChanged
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _notChanged = Object();

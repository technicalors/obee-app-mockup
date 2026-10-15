import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/features/tasks/data/task_models.dart';
import 'package:obee_mobile/src/features/tasks/logic/task_logic.dart';
import 'package:obee_mobile/src/features/tasks/state/tasks_controller.dart';
import 'package:obee_mobile/src/features/tasks/ui/task_detail_page.dart';
import 'package:obee_mobile/src/features/tasks/ui/widgets/add_task_sheet.dart';
import 'package:obee_mobile/src/features/tasks/ui/widgets/task_list_tabs.dart';
import 'package:obee_mobile/src/features/tasks/ui/widgets/task_tile.dart';

enum _ListMenuAction { rename, delete, clearCompleted }

/// "Công việc" tab modelled on Google Tasks: list tabs, open tasks with
/// nested subtasks, sort options and a collapsible completed section.
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key, this.now});

  static const routePath = '/app/tasks';

  final DateTime? now;

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  bool _showCompleted = false;

  TasksController get _controller => ref.read(tasksControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    unawaited(Future<void>(() => _controller.load(now: widget.now)));
  }

  Future<void> _addTask() async {
    final state = ref.read(tasksControllerProvider);
    final result = await showAddTaskSheet(
      context,
      today: state.today,
      initiallyStarred: state.isStarredView,
    );
    if (result == null) return;
    await _controller.addTask(
      title: result.title,
      notes: result.notes,
      due: result.due,
      starred: result.starred,
    );
  }

  void _openTask(TaskModel task) {
    context.push(TaskDetailPage.location(task.id));
  }

  Future<String?> _askListName({
    required String title,
    String initialValue = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) =>
          _ListNameDialog(title: title, initialValue: initialValue),
    );
  }

  Future<void> _createList() async {
    final name = await _askListName(title: 'Tạo danh sách mới');
    if (name != null) await _controller.createList(name);
  }

  Future<void> _handleListMenu(_ListMenuAction action) async {
    final state = ref.read(tasksControllerProvider);
    final list = state.selectedList;
    switch (action) {
      case _ListMenuAction.rename:
        if (list == null) return;
        final name = await _askListName(
          title: 'Đổi tên danh sách',
          initialValue: list.title,
        );
        if (name != null) await _controller.renameList(list.id, name);
      case _ListMenuAction.delete:
        if (list == null) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xoá danh sách này?'),
            content: const Text(
              'Mọi việc trong danh sách cũng sẽ bị xoá vĩnh viễn.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Huỷ'),
              ),
              TextButton(
                key: const ValueKey('task-list-delete-confirm'),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xoá'),
              ),
            ],
          ),
        );
        if (confirmed == true) await _controller.deleteList(list.id);
      case _ListMenuAction.clearCompleted:
        await _controller.clearCompleted();
    }
  }

  Future<void> _chooseSort() async {
    final current = ref.read(tasksControllerProvider).sort;
    final sort = await showModalBottomSheet<TaskSortOrder>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Sắp xếp theo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            for (final option in TaskSortOrder.values)
              ListTile(
                key: ValueKey('task-sort-${option.name}'),
                leading: Icon(
                  option == current ? Icons.check : null,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(option.label),
                onTap: () => Navigator.of(context).pop(option),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (sort != null) _controller.setSort(sort);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<TasksState>(tasksControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        _controller.clearFeedback();
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('tasks-add-fab'),
        tooltip: 'Thêm việc',
        onPressed: state.lists.isEmpty ? null : _addTask,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 16, 6),
              child: Text(
                'Công việc',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            TaskListTabs(
              lists: state.lists,
              selectedListId: state.selectedListId,
              onSelected: _controller.selectList,
              onCreateList: _createList,
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _controller.load(now: widget.now),
                child: state.isLoading && state.lists.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTaskList(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(TasksState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final sections = state.openSections;
    final completed = state.completed;
    final list = state.selectedList;
    final title = state.isStarredView
        ? 'Có gắn dấu sao'
        : (list?.title ?? 'Công việc');

    return ListView(
      key: const ValueKey('tasks-scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  key: const ValueKey('tasks-list-title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('tasks-sort-button'),
                tooltip: 'Sắp xếp',
                onPressed: _chooseSort,
                icon: const Icon(Icons.swap_vert),
              ),
              PopupMenuButton<_ListMenuAction>(
                key: const ValueKey('tasks-list-menu'),
                tooltip: 'Tùy chọn danh sách',
                onSelected: _handleListMenu,
                itemBuilder: (context) => [
                  if (!state.isStarredView)
                    const PopupMenuItem(
                      key: ValueKey('tasks-list-menu-rename'),
                      value: _ListMenuAction.rename,
                      child: Text('Đổi tên danh sách'),
                    ),
                  if (!state.isStarredView && list?.isDefault == false)
                    const PopupMenuItem(
                      key: ValueKey('tasks-list-menu-delete'),
                      value: _ListMenuAction.delete,
                      child: Text('Xoá danh sách'),
                    ),
                  PopupMenuItem(
                    key: const ValueKey('tasks-list-menu-clear'),
                    value: _ListMenuAction.clearCompleted,
                    enabled: completed.isNotEmpty,
                    child: const Text('Xoá tất cả việc đã hoàn thành'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (sections.isEmpty)
          _EmptyState(
            isStarredView: state.isStarredView,
            allDone: completed.isNotEmpty,
          ),
        for (final section in sections) ...[
          if (section.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                section.title!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: section.isOverdue
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
              ),
            ),
          for (final entry in section.entries) ...[
            _tile(entry.task, state),
            for (final subtask in entry.subtasks)
              _tile(subtask, state, indent: true),
          ],
        ],
        if (completed.isNotEmpty) ...[
          Divider(
            height: 24,
            indent: 16,
            endIndent: 16,
            color: colorScheme.outlineVariant,
          ),
          InkWell(
            key: const ValueKey('tasks-completed-toggle'),
            onTap: () => setState(() => _showCompleted = !_showCompleted),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đã hoàn thành (${completed.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _showCompleted ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_showCompleted)
            for (final task in completed) _tile(task, state),
        ],
      ],
    );
  }

  Widget _tile(TaskModel task, TasksState state, {bool indent = false}) {
    return TaskTile(
      task: task,
      today: state.today,
      indent: indent,
      onTap: () => _openTask(task),
      onToggleCompleted: () => _controller.toggleCompleted(task),
      onToggleStarred: task.completed
          ? null
          : () => _controller.toggleStarred(task),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isStarredView, required this.allDone});

  final bool isStarredView;
  final bool allDone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, title, subtitle) = switch ((isStarredView, allDone)) {
      (true, _) => (
        Icons.star_border,
        'Chưa có việc nào được gắn dấu sao',
        'Gắn dấu sao cho việc quan trọng để xem nhanh tại đây.',
      ),
      (false, true) => (
        Icons.task_alt,
        'Đã hoàn thành tất cả công việc',
        'Làm tốt lắm!',
      ),
      (false, false) => (
        Icons.checklist,
        'Chưa có việc nào',
        'Thêm việc cần làm vào danh sách này.',
      ),
    };

    return Padding(
      key: const ValueKey('tasks-empty'),
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Owns its text controller so it outlives the dialog's exit animation.
class _ListNameDialog extends StatefulWidget {
  const _ListNameDialog({required this.title, required this.initialValue});

  final String title;
  final String initialValue;

  @override
  State<_ListNameDialog> createState() => _ListNameDialogState();
}

class _ListNameDialogState extends State<_ListNameDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const ValueKey('task-list-name-field'),
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nhập tên'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        TextButton(
          key: const ValueKey('task-list-name-save'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Xong'),
        ),
      ],
    );
  }
}

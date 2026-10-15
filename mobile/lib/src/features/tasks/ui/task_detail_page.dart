import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/features/tasks/data/task_models.dart';
import 'package:obee_mobile/src/features/tasks/state/tasks_controller.dart';
import 'package:obee_mobile/src/features/tasks/ui/widgets/task_tile.dart';

/// Task details in the Google Tasks layout: editable title and details,
/// due date, one level of subtasks, star/delete actions and a completion
/// toggle at the bottom. Text edits save shortly after typing stops.
class TaskDetailPage extends ConsumerStatefulWidget {
  const TaskDetailPage({required this.taskId, super.key});

  static String location(String taskId) => '/app/tasks/$taskId';

  final String taskId;

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  late final TasksController _controller = ref.read(
    tasksControllerProvider.notifier,
  );
  late final TextEditingController _title;
  late final TextEditingController _notes;
  final _subtaskInput = TextEditingController();
  bool _addingSubtask = false;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    final task = ref.read(tasksControllerProvider).taskById(widget.taskId);
    _title = TextEditingController(text: task?.title ?? '');
    _notes = TextEditingController(text: task?.notes ?? '');
  }

  @override
  void dispose() {
    _flushPendingSave();
    _title.dispose();
    _notes.dispose();
    _subtaskInput.dispose();
    super.dispose();
  }

  TaskModel? get _task =>
      ref.read(tasksControllerProvider).taskById(widget.taskId);

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _flushPendingSave);
  }

  void _flushPendingSave() {
    final timer = _saveTimer;
    if (timer == null) return;
    timer.cancel();
    _saveTimer = null;

    final task = _task;
    if (task == null) return;
    final title = _title.text.trim();
    final notes = _notes.text;
    if ((title.isEmpty || title == task.title) && notes == (task.notes ?? '')) {
      return;
    }
    unawaited(
      _controller.updateTask(
        task,
        title: title.isEmpty ? null : title,
        notes: notes == (task.notes ?? '') ? null : notes,
      ),
    );
  }

  Future<void> _pickDate(TaskModel task) async {
    final today = ref.read(tasksControllerProvider).today;
    final picked = await showDatePicker(
      context: context,
      initialDate: task.due ?? today,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) await _controller.updateTask(task, due: picked);
  }

  Future<void> _addSubtask(TaskModel task) async {
    final title = _subtaskInput.text.trim();
    if (title.isEmpty) return;
    _subtaskInput.clear();
    await _controller.addTask(title: title, parentId: task.id);
  }

  Future<void> _toggleCompleted(TaskModel task) async {
    _flushPendingSave();
    final completing = !task.completed;
    await _controller.toggleCompleted(task);
    if (completing && mounted) context.pop();
  }

  Future<void> _delete(TaskModel task) async {
    _saveTimer?.cancel();
    _saveTimer = null;
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    await _controller.deleteTask(task);
    messenger.showSnackBar(const SnackBar(content: Text('Đã xoá công việc.')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksControllerProvider);
    final task = state.taskById(widget.taskId);
    final colorScheme = Theme.of(context).colorScheme;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy công việc.')),
      );
    }

    final list = state.lists
        .where((item) => item.id == task.listId)
        .firstOrNull;
    final parent = task.parentId == null
        ? null
        : state.taskById(task.parentId!);
    final subtasks = state.subtasksOf(task.id);
    final due = task.due;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Quay lại',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            key: const ValueKey('task-detail-star'),
            tooltip: task.starred ? 'Bỏ gắn dấu sao' : 'Gắn dấu sao',
            onPressed: () => _controller.toggleStarred(task),
            icon: Icon(
              task.starred ? Icons.star : Icons.star_border,
              color: task.starred ? colorScheme.primary : null,
            ),
          ),
          IconButton(
            key: const ValueKey('task-detail-delete'),
            tooltip: 'Xoá',
            onPressed: () => _delete(task),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 0, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4),
            child: Text(
              parent != null
                  ? 'Việc con của: ${parent.title}'
                  : (list?.title ?? ''),
              style: TextStyle(color: colorScheme.primary, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: TextField(
              key: const ValueKey('task-detail-title'),
              controller: _title,
              maxLines: null,
              onChanged: (_) => _scheduleSave(),
              style: TextStyle(
                fontSize: 24,
                decoration: task.completed ? TextDecoration.lineThrough : null,
              ),
              decoration: const InputDecoration(
                hintText: 'Nhập tiêu đề',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          _DetailRow(
            icon: Icons.notes,
            child: TextField(
              key: const ValueKey('task-detail-notes'),
              controller: _notes,
              maxLines: null,
              onChanged: (_) => _scheduleSave(),
              decoration: const InputDecoration(
                hintText: 'Thêm chi tiết',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          _DetailRow(
            icon: Icons.event_outlined,
            child: Align(
              alignment: Alignment.centerLeft,
              child: due == null
                  ? TextButton(
                      key: const ValueKey('task-detail-due'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () => _pickDate(task),
                      child: const Text('Thêm ngày'),
                    )
                  : InkWell(
                      key: const ValueKey('task-detail-due'),
                      onTap: () => _pickDate(task),
                      child: TaskDueChip(
                        due: due,
                        today: state.today,
                        onDeleted: () =>
                            _controller.updateTask(task, clearDue: true),
                      ),
                    ),
            ),
          ),
          // Google Tasks allows a single level of subtasks.
          if (!task.isSubtask) ...[
            _DetailRow(
              icon: Icons.subdirectory_arrow_right,
              child: _addingSubtask
                  ? TextField(
                      key: const ValueKey('task-detail-subtask-input'),
                      controller: _subtaskInput,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addSubtask(task),
                      decoration: const InputDecoration(
                        hintText: 'Nhập tiêu đề việc con',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const ValueKey('task-detail-add-subtask'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () => setState(() => _addingSubtask = true),
                        child: const Text('Thêm việc con'),
                      ),
                    ),
            ),
            for (final subtask in subtasks)
              TaskTile(
                task: subtask,
                today: state.today,
                indent: true,
                onTap: () => context.push(TaskDetailPage.location(subtask.id)),
                onToggleCompleted: () => _controller.toggleCompleted(subtask),
              ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          // heightFactor keeps the bar from expanding over the body.
          child: Align(
            alignment: Alignment.centerRight,
            heightFactor: 1,
            child: TextButton(
              key: const ValueKey('task-detail-complete'),
              onPressed: () => _toggleCompleted(task),
              child: Text(
                task.completed
                    ? 'Đánh dấu là chưa hoàn thành'
                    : 'Đánh dấu là đã hoàn thành',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

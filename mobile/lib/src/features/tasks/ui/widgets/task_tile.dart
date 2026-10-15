import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/tasks/data/task_models.dart';
import 'package:obee_mobile/src/features/tasks/logic/task_logic.dart';

/// Google Tasks style row: round checkbox, title with notes and due chip,
/// and a star toggle. Subtasks are indented under their parent.
class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.task,
    required this.today,
    required this.onToggleCompleted,
    required this.onTap,
    this.onToggleStarred,
    this.indent = false,
    super.key,
  });

  final TaskModel task;
  final DateTime today;
  final VoidCallback onToggleCompleted;
  final VoidCallback onTap;

  /// Null hides the star (completed tasks).
  final VoidCallback? onToggleStarred;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notes = task.notes;
    final due = task.due;

    return InkWell(
      key: ValueKey('task-tile-${task.id}'),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: indent ? 40 : 4, right: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              key: ValueKey('task-check-${task.id}'),
              tooltip: task.completed
                  ? 'Đánh dấu là chưa hoàn thành'
                  : 'Đánh dấu là đã hoàn thành',
              onPressed: onToggleCompleted,
              icon: Icon(
                task.completed ? Icons.check : Icons.radio_button_unchecked,
                color: task.completed
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        color: task.completed
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (notes != null && notes.isNotEmpty && !task.completed)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (due != null && !task.completed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TaskDueChip(
                          due: due,
                          today: today,
                          isOverdue: isTaskOverdue(task, today),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (onToggleStarred != null)
              IconButton(
                key: ValueKey('task-star-${task.id}'),
                tooltip: task.starred ? 'Bỏ gắn dấu sao' : 'Gắn dấu sao',
                onPressed: onToggleStarred,
                icon: Icon(
                  task.starred ? Icons.star : Icons.star_border,
                  color: task.starred
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Outlined date pill; red when the task is overdue.
class TaskDueChip extends StatelessWidget {
  const TaskDueChip({
    required this.due,
    required this.today,
    this.isOverdue = false,
    this.onDeleted,
    super.key,
  });

  final DateTime due;
  final DateTime today;
  final bool isOverdue;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isOverdue ? colorScheme.error : colorScheme.onSurfaceVariant;
    final onDeleted = this.onDeleted;

    return Container(
      padding: EdgeInsets.fromLTRB(10, 4, onDeleted == null ? 10 : 4, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            formatTaskDueLabel(due, today),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          if (onDeleted != null)
            InkWell(
              key: const ValueKey('task-due-clear'),
              borderRadius: BorderRadius.circular(12),
              onTap: onDeleted,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.close, size: 14, color: color),
              ),
            ),
        ],
      ),
    );
  }
}

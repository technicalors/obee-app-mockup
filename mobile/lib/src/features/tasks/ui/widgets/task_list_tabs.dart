import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/tasks/data/task_models.dart';
import 'package:obee_mobile/src/features/tasks/logic/task_logic.dart';

/// Scrollable tab strip: starred, every list, then "+ Danh sách mới".
class TaskListTabs extends StatelessWidget {
  const TaskListTabs({
    required this.lists,
    required this.selectedListId,
    required this.onSelected,
    required this.onCreateList,
    super.key,
  });

  final List<TaskListModel> lists;
  final String selectedListId;
  final ValueChanged<String> onSelected;
  final VoidCallback onCreateList;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          // List tabs scroll; "Danh sách mới" stays pinned so it is never
          // pushed off screen by long list names.
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('task-list-tabs'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Tab(
                    key: const ValueKey('task-list-tab-starred'),
                    isSelected: selectedListId == starredTaskListId,
                    onTap: () => onSelected(starredTaskListId),
                    child: Icon(
                      selectedListId == starredTaskListId
                          ? Icons.star
                          : Icons.star_border,
                      size: 22,
                      semanticLabel: 'Có gắn dấu sao',
                    ),
                  ),
                  for (final list in lists)
                    _Tab(
                      key: ValueKey('task-list-tab-${list.id}'),
                      isSelected: selectedListId == list.id,
                      onTap: () => onSelected(list.id),
                      child: Text(list.title),
                    ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 24, color: colorScheme.outlineVariant),
          IconButton(
            key: const ValueKey('task-list-tab-new'),
            tooltip: 'Danh sách mới',
            onPressed: onCreateList,
            icon: Icon(Icons.add, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.isSelected,
    required this.onTap,
    required this.child,
    super.key,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    // Selected tab gets the primary color and an underline, like Google Tasks.
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: color),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

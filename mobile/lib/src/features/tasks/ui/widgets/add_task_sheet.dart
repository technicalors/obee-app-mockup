import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/tasks/ui/widgets/task_tile.dart';

final class AddTaskResult {
  const AddTaskResult({
    required this.title,
    this.notes,
    this.due,
    this.starred = false,
  });

  final String title;
  final String? notes;
  final DateTime? due;
  final bool starred;
}

/// Quick-add sheet like Google Tasks: title, then optional details, date
/// and star toggles on the action row.
Future<AddTaskResult?> showAddTaskSheet(
  BuildContext context, {
  required DateTime today,
  bool initiallyStarred = false,
}) {
  return showModalBottomSheet<AddTaskResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        _AddTaskSheet(today: today, initiallyStarred: initiallyStarred),
  );
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({required this.today, required this.initiallyStarred});

  final DateTime today;
  final bool initiallyStarred;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  bool _showNotes = false;
  DateTime? _due;
  late bool _starred = widget.initiallyStarred;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _canSave => _title.text.trim().isNotEmpty;

  void _save() {
    if (!_canSave) return;
    Navigator.of(context).pop(
      AddTaskResult(
        title: _title.text,
        notes: _notes.text,
        due: _due,
        starred: _starred,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? widget.today,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null && mounted) {
      setState(() => _due = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final due = _due;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const ValueKey('tasks-new-title'),
            controller: _title,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              hintText: 'Việc mới',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (_showNotes)
            TextField(
              key: const ValueKey('tasks-new-notes'),
              controller: _notes,
              maxLines: null,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Thêm chi tiết',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          if (due != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TaskDueChip(
                due: due,
                today: widget.today,
                onDeleted: () => setState(() => _due = null),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                key: const ValueKey('tasks-new-notes-toggle'),
                tooltip: 'Thêm chi tiết',
                onPressed: () => setState(() => _showNotes = true),
                icon: Icon(Icons.notes, color: colorScheme.primary),
              ),
              IconButton(
                key: const ValueKey('tasks-new-date'),
                tooltip: 'Thêm ngày',
                onPressed: _pickDate,
                icon: Icon(Icons.event_outlined, color: colorScheme.primary),
              ),
              IconButton(
                key: const ValueKey('tasks-new-star'),
                tooltip: _starred ? 'Bỏ gắn dấu sao' : 'Gắn dấu sao',
                onPressed: () => setState(() => _starred = !_starred),
                icon: Icon(
                  _starred ? Icons.star : Icons.star_border,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                key: const ValueKey('tasks-new-save'),
                onPressed: _canSave ? _save : null,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

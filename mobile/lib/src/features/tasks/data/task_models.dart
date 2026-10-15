// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_models.freezed.dart';
part 'task_models.g.dart';

@freezed
abstract class TaskListModel with _$TaskListModel {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory TaskListModel({
    required String id,
    required String title,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _TaskListModel;

  factory TaskListModel.fromJson(Map<String, dynamic> json) =>
      _$TaskListModelFromJson(json);
}

/// One task or subtask. `dueDate` is a date-only `yyyy-MM-dd` value and
/// timestamps are ISO-8601 strings, kept as strings to avoid timezone shifts.
@freezed
abstract class TaskModel with _$TaskModel {
  const TaskModel._();

  @JsonSerializable(checked: true, explicitToJson: true)
  const factory TaskModel({
    required String id,
    @JsonKey(name: 'list_id') required String listId,
    @JsonKey(name: 'parent_id') String? parentId,
    required String title,
    String? notes,
    @JsonKey(name: 'due_date') String? dueDate,
    @Default(false) bool starred,
    @JsonKey(name: 'starred_at') String? starredAt,
    @Default(false) bool completed,
    @JsonKey(name: 'completed_at') String? completedAt,
    @Default(0) int position,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  bool get isSubtask => parentId != null;

  DateTime? get due => dueDate == null ? null : DateTime.parse(dueDate!);
}

/// Fields for a new task; null values are omitted from the request.
final class TaskDraft {
  const TaskDraft({
    required this.listId,
    required this.title,
    this.parentId,
    this.notes,
    this.dueDate,
    this.starred = false,
  });

  final String listId;
  final String title;
  final String? parentId;
  final String? notes;
  final String? dueDate;
  final bool starred;

  Map<String, Object?> toRequestJson() => {
    'list_id': listId,
    'title': title,
    'parent_id': ?parentId,
    'notes': ?notes,
    'due_date': ?dueDate,
    'starred': starred,
  };
}

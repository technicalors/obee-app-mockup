// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskListModel _$TaskListModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TaskListModel', json, ($checkedConvert) {
      final val = _TaskListModel(
        id: $checkedConvert('id', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        isDefault: $checkedConvert('is_default', (v) => v as bool? ?? false),
      );
      return val;
    }, fieldKeyMap: const {'isDefault': 'is_default'});

Map<String, dynamic> _$TaskListModelToJson(_TaskListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'is_default': instance.isDefault,
    };

_TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_TaskModel',
  json,
  ($checkedConvert) {
    final val = _TaskModel(
      id: $checkedConvert('id', (v) => v as String),
      listId: $checkedConvert('list_id', (v) => v as String),
      parentId: $checkedConvert('parent_id', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String),
      notes: $checkedConvert('notes', (v) => v as String?),
      dueDate: $checkedConvert('due_date', (v) => v as String?),
      starred: $checkedConvert('starred', (v) => v as bool? ?? false),
      starredAt: $checkedConvert('starred_at', (v) => v as String?),
      completed: $checkedConvert('completed', (v) => v as bool? ?? false),
      completedAt: $checkedConvert('completed_at', (v) => v as String?),
      position: $checkedConvert('position', (v) => (v as num?)?.toInt() ?? 0),
      createdAt: $checkedConvert('created_at', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'listId': 'list_id',
    'parentId': 'parent_id',
    'dueDate': 'due_date',
    'starredAt': 'starred_at',
    'completedAt': 'completed_at',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$TaskModelToJson(_TaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'list_id': instance.listId,
      'parent_id': instance.parentId,
      'title': instance.title,
      'notes': instance.notes,
      'due_date': instance.dueDate,
      'starred': instance.starred,
      'starred_at': instance.starredAt,
      'completed': instance.completed,
      'completed_at': instance.completedAt,
      'position': instance.position,
      'created_at': instance.createdAt,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskListModel {

 String get id; String get title;@JsonKey(name: 'is_default') bool get isDefault;
/// Create a copy of TaskListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskListModelCopyWith<TaskListModel> get copyWith => _$TaskListModelCopyWithImpl<TaskListModel>(this as TaskListModel, _$identity);

  /// Serializes this TaskListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TaskListModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskListModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TaskListModel;
  return Object.hash(runtimeType,_this.id,_this.title,_this.isDefault);
}

@override
String toString() {
  final _this = this as TaskListModel;
  return 'TaskListModel(id: ${_this.id}, title: ${_this.title}, isDefault: ${_this.isDefault})';
}


}

/// @nodoc
abstract mixin class $TaskListModelCopyWith<$Res>  {
  factory $TaskListModelCopyWith(TaskListModel value, $Res Function(TaskListModel) _then) = _$TaskListModelCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'is_default') bool isDefault
});




}
/// @nodoc
class _$TaskListModelCopyWithImpl<$Res>
    implements $TaskListModelCopyWith<$Res> {
  _$TaskListModelCopyWithImpl(this._self, this._then);

  final TaskListModel _self;
  final $Res Function(TaskListModel) _then;

/// Create a copy of TaskListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? isDefault = null,}) {
  return _then(TaskListModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskListModel].
extension TaskListModelPatterns on TaskListModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskListModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskListModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskListModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskListModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskListModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'is_default')  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskListModel() when $default != null:
return $default(_that.id,_that.title,_that.isDefault);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'is_default')  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _TaskListModel():
return $default(_that.id,_that.title,_that.isDefault);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'is_default')  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _TaskListModel() when $default != null:
return $default(_that.id,_that.title,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _TaskListModel implements TaskListModel {
  const _TaskListModel({required this.id, required this.title, @JsonKey(name: 'is_default') this.isDefault = false});
  factory _TaskListModel.fromJson(Map<String, dynamic> json) => _$TaskListModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(name: 'is_default') final  bool isDefault;

/// Create a copy of TaskListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskListModelCopyWith<_TaskListModel> get copyWith => __$TaskListModelCopyWithImpl<_TaskListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskListModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,isDefault);
}

@override
String toString() {
    return 'TaskListModel(id: $id, title: $title, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$TaskListModelCopyWith<$Res> implements $TaskListModelCopyWith<$Res> {
  factory _$TaskListModelCopyWith(_TaskListModel value, $Res Function(_TaskListModel) _then) = __$TaskListModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'is_default') bool isDefault
});




}
/// @nodoc
class __$TaskListModelCopyWithImpl<$Res>
    implements _$TaskListModelCopyWith<$Res> {
  __$TaskListModelCopyWithImpl(this._self, this._then);

  final _TaskListModel _self;
  final $Res Function(_TaskListModel) _then;

/// Create a copy of TaskListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? isDefault = null,}) {
  return _then(_TaskListModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TaskModel {

 String get id;@JsonKey(name: 'list_id') String get listId;@JsonKey(name: 'parent_id') String? get parentId; String get title; String? get notes;@JsonKey(name: 'due_date') String? get dueDate; bool get starred;@JsonKey(name: 'starred_at') String? get starredAt; bool get completed;@JsonKey(name: 'completed_at') String? get completedAt; int get position;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskModelCopyWith<TaskModel> get copyWith => _$TaskModelCopyWithImpl<TaskModel>(this as TaskModel, _$identity);

  /// Serializes this TaskModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TaskModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.listId, _this.listId) || other.listId == _this.listId)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.starred, _this.starred) || other.starred == _this.starred)&&(identical(other.starredAt, _this.starredAt) || other.starredAt == _this.starredAt)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TaskModel;
  return Object.hash(runtimeType,_this.id,_this.listId,_this.parentId,_this.title,_this.notes,_this.dueDate,_this.starred,_this.starredAt,_this.completed,_this.completedAt,_this.position,_this.createdAt);
}

@override
String toString() {
  final _this = this as TaskModel;
  return 'TaskModel(id: ${_this.id}, listId: ${_this.listId}, parentId: ${_this.parentId}, title: ${_this.title}, notes: ${_this.notes}, dueDate: ${_this.dueDate}, starred: ${_this.starred}, starredAt: ${_this.starredAt}, completed: ${_this.completed}, completedAt: ${_this.completedAt}, position: ${_this.position}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $TaskModelCopyWith<$Res>  {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) _then) = _$TaskModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'list_id') String listId,@JsonKey(name: 'parent_id') String? parentId, String title, String? notes,@JsonKey(name: 'due_date') String? dueDate, bool starred,@JsonKey(name: 'starred_at') String? starredAt, bool completed,@JsonKey(name: 'completed_at') String? completedAt, int position,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$TaskModelCopyWithImpl<$Res>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._self, this._then);

  final TaskModel _self;
  final $Res Function(TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listId = null,Object? parentId = freezed,Object? title = null,Object? notes = freezed,Object? dueDate = freezed,Object? starred = null,Object? starredAt = freezed,Object? completed = null,Object? completedAt = freezed,Object? position = null,Object? createdAt = null,}) {
  return _then(TaskModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,starred: null == starred ? _self.starred : starred // ignore: cast_nullable_to_non_nullable
as bool,starredAt: freezed == starredAt ? _self.starredAt : starredAt // ignore: cast_nullable_to_non_nullable
as String?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskModel].
extension TaskModelPatterns on TaskModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'list_id')  String listId, @JsonKey(name: 'parent_id')  String? parentId,  String title,  String? notes, @JsonKey(name: 'due_date')  String? dueDate,  bool starred, @JsonKey(name: 'starred_at')  String? starredAt,  bool completed, @JsonKey(name: 'completed_at')  String? completedAt,  int position, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.listId,_that.parentId,_that.title,_that.notes,_that.dueDate,_that.starred,_that.starredAt,_that.completed,_that.completedAt,_that.position,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'list_id')  String listId, @JsonKey(name: 'parent_id')  String? parentId,  String title,  String? notes, @JsonKey(name: 'due_date')  String? dueDate,  bool starred, @JsonKey(name: 'starred_at')  String? starredAt,  bool completed, @JsonKey(name: 'completed_at')  String? completedAt,  int position, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _TaskModel():
return $default(_that.id,_that.listId,_that.parentId,_that.title,_that.notes,_that.dueDate,_that.starred,_that.starredAt,_that.completed,_that.completedAt,_that.position,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'list_id')  String listId, @JsonKey(name: 'parent_id')  String? parentId,  String title,  String? notes, @JsonKey(name: 'due_date')  String? dueDate,  bool starred, @JsonKey(name: 'starred_at')  String? starredAt,  bool completed, @JsonKey(name: 'completed_at')  String? completedAt,  int position, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.listId,_that.parentId,_that.title,_that.notes,_that.dueDate,_that.starred,_that.starredAt,_that.completed,_that.completedAt,_that.position,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _TaskModel extends TaskModel {
  const _TaskModel({required this.id, @JsonKey(name: 'list_id') required this.listId, @JsonKey(name: 'parent_id') this.parentId, required this.title, this.notes, @JsonKey(name: 'due_date') this.dueDate, this.starred = false, @JsonKey(name: 'starred_at') this.starredAt, this.completed = false, @JsonKey(name: 'completed_at') this.completedAt, this.position = 0, @JsonKey(name: 'created_at') required this.createdAt}): super._();
  factory _TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'list_id') final  String listId;
@override@JsonKey(name: 'parent_id') final  String? parentId;
@override final  String title;
@override final  String? notes;
@override@JsonKey(name: 'due_date') final  String? dueDate;
@override@JsonKey() final  bool starred;
@override@JsonKey(name: 'starred_at') final  String? starredAt;
@override@JsonKey() final  bool completed;
@override@JsonKey(name: 'completed_at') final  String? completedAt;
@override@JsonKey() final  int position;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskModelCopyWith<_TaskModel> get copyWith => __$TaskModelCopyWithImpl<_TaskModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskModel&&(identical(other.id, id) || other.id == id)&&(identical(other.listId, listId) || other.listId == listId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.starred, starred) || other.starred == starred)&&(identical(other.starredAt, starredAt) || other.starredAt == starredAt)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,listId,parentId,title,notes,dueDate,starred,starredAt,completed,completedAt,position,createdAt);
}

@override
String toString() {
    return 'TaskModel(id: $id, listId: $listId, parentId: $parentId, title: $title, notes: $notes, dueDate: $dueDate, starred: $starred, starredAt: $starredAt, completed: $completed, completedAt: $completedAt, position: $position, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TaskModelCopyWith<$Res> implements $TaskModelCopyWith<$Res> {
  factory _$TaskModelCopyWith(_TaskModel value, $Res Function(_TaskModel) _then) = __$TaskModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'list_id') String listId,@JsonKey(name: 'parent_id') String? parentId, String title, String? notes,@JsonKey(name: 'due_date') String? dueDate, bool starred,@JsonKey(name: 'starred_at') String? starredAt, bool completed,@JsonKey(name: 'completed_at') String? completedAt, int position,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$TaskModelCopyWithImpl<$Res>
    implements _$TaskModelCopyWith<$Res> {
  __$TaskModelCopyWithImpl(this._self, this._then);

  final _TaskModel _self;
  final $Res Function(_TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listId = null,Object? parentId = freezed,Object? title = null,Object? notes = freezed,Object? dueDate = freezed,Object? starred = null,Object? starredAt = freezed,Object? completed = null,Object? completedAt = freezed,Object? position = null,Object? createdAt = null,}) {
  return _then(_TaskModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,starred: null == starred ? _self.starred : starred // ignore: cast_nullable_to_non_nullable
as bool,starredAt: freezed == starredAt ? _self.starredAt : starredAt // ignore: cast_nullable_to_non_nullable
as String?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleUserRef {

 String get id; String get name; String? get avatar; String? get email;
/// Create a copy of ScheduleUserRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleUserRefCopyWith<ScheduleUserRef> get copyWith => _$ScheduleUserRefCopyWithImpl<ScheduleUserRef>(this as ScheduleUserRef, _$identity);

  /// Serializes this ScheduleUserRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScheduleUserRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleUserRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.avatar, _this.avatar) || other.avatar == _this.avatar)&&(identical(other.email, _this.email) || other.email == _this.email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScheduleUserRef;
  return Object.hash(runtimeType,_this.id,_this.name,_this.avatar,_this.email);
}

@override
String toString() {
  final _this = this as ScheduleUserRef;
  return 'ScheduleUserRef(id: ${_this.id}, name: ${_this.name}, avatar: ${_this.avatar}, email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $ScheduleUserRefCopyWith<$Res>  {
  factory $ScheduleUserRefCopyWith(ScheduleUserRef value, $Res Function(ScheduleUserRef) _then) = _$ScheduleUserRefCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? avatar, String? email
});




}
/// @nodoc
class _$ScheduleUserRefCopyWithImpl<$Res>
    implements $ScheduleUserRefCopyWith<$Res> {
  _$ScheduleUserRefCopyWithImpl(this._self, this._then);

  final ScheduleUserRef _self;
  final $Res Function(ScheduleUserRef) _then;

/// Create a copy of ScheduleUserRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatar = freezed,Object? email = freezed,}) {
  return _then(ScheduleUserRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleUserRef].
extension ScheduleUserRefPatterns on ScheduleUserRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleUserRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleUserRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleUserRef value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleUserRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleUserRef value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleUserRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? avatar,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleUserRef() when $default != null:
return $default(_that.id,_that.name,_that.avatar,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? avatar,  String? email)  $default,) {final _that = this;
switch (_that) {
case _ScheduleUserRef():
return $default(_that.id,_that.name,_that.avatar,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? avatar,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleUserRef() when $default != null:
return $default(_that.id,_that.name,_that.avatar,_that.email);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _ScheduleUserRef implements ScheduleUserRef {
  const _ScheduleUserRef({required this.id, required this.name, this.avatar, this.email});
  factory _ScheduleUserRef.fromJson(Map<String, dynamic> json) => _$ScheduleUserRefFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? avatar;
@override final  String? email;

/// Create a copy of ScheduleUserRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleUserRefCopyWith<_ScheduleUserRef> get copyWith => __$ScheduleUserRefCopyWithImpl<_ScheduleUserRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleUserRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleUserRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,avatar,email);
}

@override
String toString() {
    return 'ScheduleUserRef(id: $id, name: $name, avatar: $avatar, email: $email)';
}


}

/// @nodoc
abstract mixin class _$ScheduleUserRefCopyWith<$Res> implements $ScheduleUserRefCopyWith<$Res> {
  factory _$ScheduleUserRefCopyWith(_ScheduleUserRef value, $Res Function(_ScheduleUserRef) _then) = __$ScheduleUserRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? avatar, String? email
});




}
/// @nodoc
class __$ScheduleUserRefCopyWithImpl<$Res>
    implements _$ScheduleUserRefCopyWith<$Res> {
  __$ScheduleUserRefCopyWithImpl(this._self, this._then);

  final _ScheduleUserRef _self;
  final $Res Function(_ScheduleUserRef) _then;

/// Create a copy of ScheduleUserRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatar = freezed,Object? email = freezed,}) {
  return _then(_ScheduleUserRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ScheduleEventModel {

 String get id; String get title; ScheduleEventType get type;@JsonKey(name: 'schedule_type') ScheduleEventScheduleType get scheduleType;@JsonKey(name: 'start_date', fromJson: _dateOnlyFromJson) DateTime get startDate;@JsonKey(name: 'end_date', fromJson: _dateOnlyFromJson) DateTime get endDate;@JsonKey(name: 'repeat_type', required: true) ScheduleEventRepeatType? get repeatType;@JsonKey(name: 'repeat_pattern', required: true) List<int>? get repeatPattern;@JsonKey(name: 'start_time', required: true) String? get startTime;@JsonKey(name: 'end_time', required: true) String? get endTime;@JsonKey(required: true) String? get note;@JsonKey(name: 'physical_address', required: true) String? get physicalAddress; ScheduleEventPrivacy get privacy;@JsonKey(name: 'is_general') bool get isGeneral;@JsonKey(name: 'remind_range', required: true) ScheduleEventRemindRange? get remindRange;@JsonKey(name: 'remind_value', required: true) int? get remindValue;@JsonKey(name: 'created_by') String get createdBy;@JsonKey(name: 'updated_by', required: true) String? get updatedBy;@JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) DateTime get createdAt;@JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) DateTime get updatedAt; List<ScheduleUserRef> get participants; List<ScheduleUserRef> get observers;
/// Create a copy of ScheduleEventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleEventModelCopyWith<ScheduleEventModel> get copyWith => _$ScheduleEventModelCopyWithImpl<ScheduleEventModel>(this as ScheduleEventModel, _$identity);

  /// Serializes this ScheduleEventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScheduleEventModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleEventModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.scheduleType, _this.scheduleType) || other.scheduleType == _this.scheduleType)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.repeatType, _this.repeatType) || other.repeatType == _this.repeatType)&&const DeepCollectionEquality().equals(other.repeatPattern, _this.repeatPattern)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.physicalAddress, _this.physicalAddress) || other.physicalAddress == _this.physicalAddress)&&(identical(other.privacy, _this.privacy) || other.privacy == _this.privacy)&&(identical(other.isGeneral, _this.isGeneral) || other.isGeneral == _this.isGeneral)&&(identical(other.remindRange, _this.remindRange) || other.remindRange == _this.remindRange)&&(identical(other.remindValue, _this.remindValue) || other.remindValue == _this.remindValue)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.updatedBy, _this.updatedBy) || other.updatedBy == _this.updatedBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.participants, _this.participants)&&const DeepCollectionEquality().equals(other.observers, _this.observers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScheduleEventModel;
  return Object.hashAll([runtimeType,_this.id,_this.title,_this.type,_this.scheduleType,_this.startDate,_this.endDate,_this.repeatType,const DeepCollectionEquality().hash(_this.repeatPattern),_this.startTime,_this.endTime,_this.note,_this.physicalAddress,_this.privacy,_this.isGeneral,_this.remindRange,_this.remindValue,_this.createdBy,_this.updatedBy,_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.participants),const DeepCollectionEquality().hash(_this.observers)]);
}

@override
String toString() {
  final _this = this as ScheduleEventModel;
  return 'ScheduleEventModel(id: ${_this.id}, title: ${_this.title}, type: ${_this.type}, scheduleType: ${_this.scheduleType}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, repeatType: ${_this.repeatType}, repeatPattern: ${_this.repeatPattern}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, note: ${_this.note}, physicalAddress: ${_this.physicalAddress}, privacy: ${_this.privacy}, isGeneral: ${_this.isGeneral}, remindRange: ${_this.remindRange}, remindValue: ${_this.remindValue}, createdBy: ${_this.createdBy}, updatedBy: ${_this.updatedBy}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, participants: ${_this.participants}, observers: ${_this.observers})';
}


}

/// @nodoc
abstract mixin class $ScheduleEventModelCopyWith<$Res>  {
  factory $ScheduleEventModelCopyWith(ScheduleEventModel value, $Res Function(ScheduleEventModel) _then) = _$ScheduleEventModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, ScheduleEventType type,@JsonKey(name: 'schedule_type') ScheduleEventScheduleType scheduleType,@JsonKey(name: 'start_date', fromJson: _dateOnlyFromJson) DateTime startDate,@JsonKey(name: 'end_date', fromJson: _dateOnlyFromJson) DateTime endDate,@JsonKey(name: 'repeat_type', required: true) ScheduleEventRepeatType? repeatType,@JsonKey(name: 'repeat_pattern', required: true) List<int>? repeatPattern,@JsonKey(name: 'start_time', required: true) String? startTime,@JsonKey(name: 'end_time', required: true) String? endTime,@JsonKey(required: true) String? note,@JsonKey(name: 'physical_address', required: true) String? physicalAddress, ScheduleEventPrivacy privacy,@JsonKey(name: 'is_general') bool isGeneral,@JsonKey(name: 'remind_range', required: true) ScheduleEventRemindRange? remindRange,@JsonKey(name: 'remind_value', required: true) int? remindValue,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'updated_by', required: true) String? updatedBy,@JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) DateTime createdAt,@JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) DateTime updatedAt, List<ScheduleUserRef> participants, List<ScheduleUserRef> observers
});




}
/// @nodoc
class _$ScheduleEventModelCopyWithImpl<$Res>
    implements $ScheduleEventModelCopyWith<$Res> {
  _$ScheduleEventModelCopyWithImpl(this._self, this._then);

  final ScheduleEventModel _self;
  final $Res Function(ScheduleEventModel) _then;

/// Create a copy of ScheduleEventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? type = null,Object? scheduleType = null,Object? startDate = null,Object? endDate = null,Object? repeatType = freezed,Object? repeatPattern = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? note = freezed,Object? physicalAddress = freezed,Object? privacy = null,Object? isGeneral = null,Object? remindRange = freezed,Object? remindValue = freezed,Object? createdBy = null,Object? updatedBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? participants = null,Object? observers = null,}) {
  return _then(ScheduleEventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ScheduleEventType,scheduleType: null == scheduleType ? _self.scheduleType : scheduleType // ignore: cast_nullable_to_non_nullable
as ScheduleEventScheduleType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,repeatType: freezed == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as ScheduleEventRepeatType?,repeatPattern: freezed == repeatPattern ? _self.repeatPattern : repeatPattern // ignore: cast_nullable_to_non_nullable
as List<int>?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,physicalAddress: freezed == physicalAddress ? _self.physicalAddress : physicalAddress // ignore: cast_nullable_to_non_nullable
as String?,privacy: null == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as ScheduleEventPrivacy,isGeneral: null == isGeneral ? _self.isGeneral : isGeneral // ignore: cast_nullable_to_non_nullable
as bool,remindRange: freezed == remindRange ? _self.remindRange : remindRange // ignore: cast_nullable_to_non_nullable
as ScheduleEventRemindRange?,remindValue: freezed == remindValue ? _self.remindValue : remindValue // ignore: cast_nullable_to_non_nullable
as int?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<ScheduleUserRef>,observers: null == observers ? _self.observers : observers // ignore: cast_nullable_to_non_nullable
as List<ScheduleUserRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleEventModel].
extension ScheduleEventModelPatterns on ScheduleEventModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleEventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleEventModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleEventModel value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleEventModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleEventModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleEventModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  ScheduleEventType type, @JsonKey(name: 'schedule_type')  ScheduleEventScheduleType scheduleType, @JsonKey(name: 'start_date', fromJson: _dateOnlyFromJson)  DateTime startDate, @JsonKey(name: 'end_date', fromJson: _dateOnlyFromJson)  DateTime endDate, @JsonKey(name: 'repeat_type', required: true)  ScheduleEventRepeatType? repeatType, @JsonKey(name: 'repeat_pattern', required: true)  List<int>? repeatPattern, @JsonKey(name: 'start_time', required: true)  String? startTime, @JsonKey(name: 'end_time', required: true)  String? endTime, @JsonKey(required: true)  String? note, @JsonKey(name: 'physical_address', required: true)  String? physicalAddress,  ScheduleEventPrivacy privacy, @JsonKey(name: 'is_general')  bool isGeneral, @JsonKey(name: 'remind_range', required: true)  ScheduleEventRemindRange? remindRange, @JsonKey(name: 'remind_value', required: true)  int? remindValue, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'updated_by', required: true)  String? updatedBy, @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)  DateTime createdAt, @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)  DateTime updatedAt,  List<ScheduleUserRef> participants,  List<ScheduleUserRef> observers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleEventModel() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.scheduleType,_that.startDate,_that.endDate,_that.repeatType,_that.repeatPattern,_that.startTime,_that.endTime,_that.note,_that.physicalAddress,_that.privacy,_that.isGeneral,_that.remindRange,_that.remindValue,_that.createdBy,_that.updatedBy,_that.createdAt,_that.updatedAt,_that.participants,_that.observers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  ScheduleEventType type, @JsonKey(name: 'schedule_type')  ScheduleEventScheduleType scheduleType, @JsonKey(name: 'start_date', fromJson: _dateOnlyFromJson)  DateTime startDate, @JsonKey(name: 'end_date', fromJson: _dateOnlyFromJson)  DateTime endDate, @JsonKey(name: 'repeat_type', required: true)  ScheduleEventRepeatType? repeatType, @JsonKey(name: 'repeat_pattern', required: true)  List<int>? repeatPattern, @JsonKey(name: 'start_time', required: true)  String? startTime, @JsonKey(name: 'end_time', required: true)  String? endTime, @JsonKey(required: true)  String? note, @JsonKey(name: 'physical_address', required: true)  String? physicalAddress,  ScheduleEventPrivacy privacy, @JsonKey(name: 'is_general')  bool isGeneral, @JsonKey(name: 'remind_range', required: true)  ScheduleEventRemindRange? remindRange, @JsonKey(name: 'remind_value', required: true)  int? remindValue, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'updated_by', required: true)  String? updatedBy, @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)  DateTime createdAt, @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)  DateTime updatedAt,  List<ScheduleUserRef> participants,  List<ScheduleUserRef> observers)  $default,) {final _that = this;
switch (_that) {
case _ScheduleEventModel():
return $default(_that.id,_that.title,_that.type,_that.scheduleType,_that.startDate,_that.endDate,_that.repeatType,_that.repeatPattern,_that.startTime,_that.endTime,_that.note,_that.physicalAddress,_that.privacy,_that.isGeneral,_that.remindRange,_that.remindValue,_that.createdBy,_that.updatedBy,_that.createdAt,_that.updatedAt,_that.participants,_that.observers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  ScheduleEventType type, @JsonKey(name: 'schedule_type')  ScheduleEventScheduleType scheduleType, @JsonKey(name: 'start_date', fromJson: _dateOnlyFromJson)  DateTime startDate, @JsonKey(name: 'end_date', fromJson: _dateOnlyFromJson)  DateTime endDate, @JsonKey(name: 'repeat_type', required: true)  ScheduleEventRepeatType? repeatType, @JsonKey(name: 'repeat_pattern', required: true)  List<int>? repeatPattern, @JsonKey(name: 'start_time', required: true)  String? startTime, @JsonKey(name: 'end_time', required: true)  String? endTime, @JsonKey(required: true)  String? note, @JsonKey(name: 'physical_address', required: true)  String? physicalAddress,  ScheduleEventPrivacy privacy, @JsonKey(name: 'is_general')  bool isGeneral, @JsonKey(name: 'remind_range', required: true)  ScheduleEventRemindRange? remindRange, @JsonKey(name: 'remind_value', required: true)  int? remindValue, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'updated_by', required: true)  String? updatedBy, @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)  DateTime createdAt, @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)  DateTime updatedAt,  List<ScheduleUserRef> participants,  List<ScheduleUserRef> observers)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleEventModel() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.scheduleType,_that.startDate,_that.endDate,_that.repeatType,_that.repeatPattern,_that.startTime,_that.endTime,_that.note,_that.physicalAddress,_that.privacy,_that.isGeneral,_that.remindRange,_that.remindValue,_that.createdBy,_that.updatedBy,_that.createdAt,_that.updatedAt,_that.participants,_that.observers);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _ScheduleEventModel implements ScheduleEventModel {
  const _ScheduleEventModel({required this.id, required this.title, required this.type, @JsonKey(name: 'schedule_type') required this.scheduleType, @JsonKey(name: 'start_date', fromJson: _dateOnlyFromJson) required this.startDate, @JsonKey(name: 'end_date', fromJson: _dateOnlyFromJson) required this.endDate, @JsonKey(name: 'repeat_type', required: true) this.repeatType, @JsonKey(name: 'repeat_pattern', required: true)  List<int>? repeatPattern, @JsonKey(name: 'start_time', required: true) this.startTime, @JsonKey(name: 'end_time', required: true) this.endTime, @JsonKey(required: true) this.note, @JsonKey(name: 'physical_address', required: true) this.physicalAddress, required this.privacy, @JsonKey(name: 'is_general') required this.isGeneral, @JsonKey(name: 'remind_range', required: true) this.remindRange, @JsonKey(name: 'remind_value', required: true) this.remindValue, @JsonKey(name: 'created_by') required this.createdBy, @JsonKey(name: 'updated_by', required: true) this.updatedBy, @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) required this.createdAt, @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) required this.updatedAt, required  List<ScheduleUserRef> participants, required  List<ScheduleUserRef> observers}): _repeatPattern = repeatPattern,_participants = participants,_observers = observers;
  factory _ScheduleEventModel.fromJson(Map<String, dynamic> json) => _$ScheduleEventModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  ScheduleEventType type;
@override@JsonKey(name: 'schedule_type') final  ScheduleEventScheduleType scheduleType;
@override@JsonKey(name: 'start_date', fromJson: _dateOnlyFromJson) final  DateTime startDate;
@override@JsonKey(name: 'end_date', fromJson: _dateOnlyFromJson) final  DateTime endDate;
@override@JsonKey(name: 'repeat_type', required: true) final  ScheduleEventRepeatType? repeatType;
 final  List<int>? _repeatPattern;
@override@JsonKey(name: 'repeat_pattern', required: true) List<int>? get repeatPattern {
  final value = _repeatPattern;
  if (value == null) return null;
  if (_repeatPattern is EqualUnmodifiableListView) return _repeatPattern;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'start_time', required: true) final  String? startTime;
@override@JsonKey(name: 'end_time', required: true) final  String? endTime;
@override@JsonKey(required: true) final  String? note;
@override@JsonKey(name: 'physical_address', required: true) final  String? physicalAddress;
@override final  ScheduleEventPrivacy privacy;
@override@JsonKey(name: 'is_general') final  bool isGeneral;
@override@JsonKey(name: 'remind_range', required: true) final  ScheduleEventRemindRange? remindRange;
@override@JsonKey(name: 'remind_value', required: true) final  int? remindValue;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override@JsonKey(name: 'updated_by', required: true) final  String? updatedBy;
@override@JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) final  DateTime createdAt;
@override@JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) final  DateTime updatedAt;
 final  List<ScheduleUserRef> _participants;
@override List<ScheduleUserRef> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

 final  List<ScheduleUserRef> _observers;
@override List<ScheduleUserRef> get observers {
  if (_observers is EqualUnmodifiableListView) return _observers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_observers);
}


/// Create a copy of ScheduleEventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleEventModelCopyWith<_ScheduleEventModel> get copyWith => __$ScheduleEventModelCopyWithImpl<_ScheduleEventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleEventModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleEventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.scheduleType, scheduleType) || other.scheduleType == scheduleType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.repeatType, repeatType) || other.repeatType == repeatType)&&const DeepCollectionEquality().equals(other.repeatPattern, _repeatPattern)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.note, note) || other.note == note)&&(identical(other.physicalAddress, physicalAddress) || other.physicalAddress == physicalAddress)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&(identical(other.isGeneral, isGeneral) || other.isGeneral == isGeneral)&&(identical(other.remindRange, remindRange) || other.remindRange == remindRange)&&(identical(other.remindValue, remindValue) || other.remindValue == remindValue)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.participants, _participants)&&const DeepCollectionEquality().equals(other.observers, _observers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,title,type,scheduleType,startDate,endDate,repeatType,const DeepCollectionEquality().hash(_repeatPattern),startTime,endTime,note,physicalAddress,privacy,isGeneral,remindRange,remindValue,createdBy,updatedBy,createdAt,updatedAt,const DeepCollectionEquality().hash(_participants),const DeepCollectionEquality().hash(_observers)]);
}

@override
String toString() {
    return 'ScheduleEventModel(id: $id, title: $title, type: $type, scheduleType: $scheduleType, startDate: $startDate, endDate: $endDate, repeatType: $repeatType, repeatPattern: $repeatPattern, startTime: $startTime, endTime: $endTime, note: $note, physicalAddress: $physicalAddress, privacy: $privacy, isGeneral: $isGeneral, remindRange: $remindRange, remindValue: $remindValue, createdBy: $createdBy, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt, participants: $participants, observers: $observers)';
}


}

/// @nodoc
abstract mixin class _$ScheduleEventModelCopyWith<$Res> implements $ScheduleEventModelCopyWith<$Res> {
  factory _$ScheduleEventModelCopyWith(_ScheduleEventModel value, $Res Function(_ScheduleEventModel) _then) = __$ScheduleEventModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, ScheduleEventType type,@JsonKey(name: 'schedule_type') ScheduleEventScheduleType scheduleType,@JsonKey(name: 'start_date', fromJson: _dateOnlyFromJson) DateTime startDate,@JsonKey(name: 'end_date', fromJson: _dateOnlyFromJson) DateTime endDate,@JsonKey(name: 'repeat_type', required: true) ScheduleEventRepeatType? repeatType,@JsonKey(name: 'repeat_pattern', required: true) List<int>? repeatPattern,@JsonKey(name: 'start_time', required: true) String? startTime,@JsonKey(name: 'end_time', required: true) String? endTime,@JsonKey(required: true) String? note,@JsonKey(name: 'physical_address', required: true) String? physicalAddress, ScheduleEventPrivacy privacy,@JsonKey(name: 'is_general') bool isGeneral,@JsonKey(name: 'remind_range', required: true) ScheduleEventRemindRange? remindRange,@JsonKey(name: 'remind_value', required: true) int? remindValue,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'updated_by', required: true) String? updatedBy,@JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) DateTime createdAt,@JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) DateTime updatedAt, List<ScheduleUserRef> participants, List<ScheduleUserRef> observers
});




}
/// @nodoc
class __$ScheduleEventModelCopyWithImpl<$Res>
    implements _$ScheduleEventModelCopyWith<$Res> {
  __$ScheduleEventModelCopyWithImpl(this._self, this._then);

  final _ScheduleEventModel _self;
  final $Res Function(_ScheduleEventModel) _then;

/// Create a copy of ScheduleEventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? type = null,Object? scheduleType = null,Object? startDate = null,Object? endDate = null,Object? repeatType = freezed,Object? repeatPattern = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? note = freezed,Object? physicalAddress = freezed,Object? privacy = null,Object? isGeneral = null,Object? remindRange = freezed,Object? remindValue = freezed,Object? createdBy = null,Object? updatedBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? participants = null,Object? observers = null,}) {
  return _then(_ScheduleEventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ScheduleEventType,scheduleType: null == scheduleType ? _self.scheduleType : scheduleType // ignore: cast_nullable_to_non_nullable
as ScheduleEventScheduleType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,repeatType: freezed == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as ScheduleEventRepeatType?,repeatPattern: freezed == repeatPattern ? _self._repeatPattern : repeatPattern // ignore: cast_nullable_to_non_nullable
as List<int>?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,physicalAddress: freezed == physicalAddress ? _self.physicalAddress : physicalAddress // ignore: cast_nullable_to_non_nullable
as String?,privacy: null == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as ScheduleEventPrivacy,isGeneral: null == isGeneral ? _self.isGeneral : isGeneral // ignore: cast_nullable_to_non_nullable
as bool,remindRange: freezed == remindRange ? _self.remindRange : remindRange // ignore: cast_nullable_to_non_nullable
as ScheduleEventRemindRange?,remindValue: freezed == remindValue ? _self.remindValue : remindValue // ignore: cast_nullable_to_non_nullable
as int?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<ScheduleUserRef>,observers: null == observers ? _self._observers : observers // ignore: cast_nullable_to_non_nullable
as List<ScheduleUserRef>,
  ));
}


}


/// @nodoc
mixin _$ScheduleModel {

 String get id;@JsonKey(name: 'event_id') String get eventId;@JsonKey(fromJson: _dateTimeFromJson) DateTime get start;@JsonKey(fromJson: _dateTimeFromJson) DateTime get end;@JsonKey(name: 'one_day') bool get oneDay;@JsonKey(name: 'remind_at', required: true, fromJson: _nullableDateTimeFromJson) DateTime? get remindAt; ScheduleEventModel get event;
/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleModelCopyWith<ScheduleModel> get copyWith => _$ScheduleModelCopyWithImpl<ScheduleModel>(this as ScheduleModel, _$identity);

  /// Serializes this ScheduleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScheduleModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.oneDay, _this.oneDay) || other.oneDay == _this.oneDay)&&(identical(other.remindAt, _this.remindAt) || other.remindAt == _this.remindAt)&&(identical(other.event, _this.event) || other.event == _this.event));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScheduleModel;
  return Object.hash(runtimeType,_this.id,_this.eventId,_this.start,_this.end,_this.oneDay,_this.remindAt,_this.event);
}

@override
String toString() {
  final _this = this as ScheduleModel;
  return 'ScheduleModel(id: ${_this.id}, eventId: ${_this.eventId}, start: ${_this.start}, end: ${_this.end}, oneDay: ${_this.oneDay}, remindAt: ${_this.remindAt}, event: ${_this.event})';
}


}

/// @nodoc
abstract mixin class $ScheduleModelCopyWith<$Res>  {
  factory $ScheduleModelCopyWith(ScheduleModel value, $Res Function(ScheduleModel) _then) = _$ScheduleModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId,@JsonKey(fromJson: _dateTimeFromJson) DateTime start,@JsonKey(fromJson: _dateTimeFromJson) DateTime end,@JsonKey(name: 'one_day') bool oneDay,@JsonKey(name: 'remind_at', required: true, fromJson: _nullableDateTimeFromJson) DateTime? remindAt, ScheduleEventModel event
});


$ScheduleEventModelCopyWith<$Res> get event;

}
/// @nodoc
class _$ScheduleModelCopyWithImpl<$Res>
    implements $ScheduleModelCopyWith<$Res> {
  _$ScheduleModelCopyWithImpl(this._self, this._then);

  final ScheduleModel _self;
  final $Res Function(ScheduleModel) _then;

/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? start = null,Object? end = null,Object? oneDay = null,Object? remindAt = freezed,Object? event = null,}) {
  return _then(ScheduleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,oneDay: null == oneDay ? _self.oneDay : oneDay // ignore: cast_nullable_to_non_nullable
as bool,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as ScheduleEventModel,
  ));
}
/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduleEventModelCopyWith<$Res> get event {
  
  return $ScheduleEventModelCopyWith<$Res>(_self.event, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScheduleModel].
extension ScheduleModelPatterns on ScheduleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleModel value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(fromJson: _dateTimeFromJson)  DateTime start, @JsonKey(fromJson: _dateTimeFromJson)  DateTime end, @JsonKey(name: 'one_day')  bool oneDay, @JsonKey(name: 'remind_at', required: true, fromJson: _nullableDateTimeFromJson)  DateTime? remindAt,  ScheduleEventModel event)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleModel() when $default != null:
return $default(_that.id,_that.eventId,_that.start,_that.end,_that.oneDay,_that.remindAt,_that.event);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(fromJson: _dateTimeFromJson)  DateTime start, @JsonKey(fromJson: _dateTimeFromJson)  DateTime end, @JsonKey(name: 'one_day')  bool oneDay, @JsonKey(name: 'remind_at', required: true, fromJson: _nullableDateTimeFromJson)  DateTime? remindAt,  ScheduleEventModel event)  $default,) {final _that = this;
switch (_that) {
case _ScheduleModel():
return $default(_that.id,_that.eventId,_that.start,_that.end,_that.oneDay,_that.remindAt,_that.event);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(fromJson: _dateTimeFromJson)  DateTime start, @JsonKey(fromJson: _dateTimeFromJson)  DateTime end, @JsonKey(name: 'one_day')  bool oneDay, @JsonKey(name: 'remind_at', required: true, fromJson: _nullableDateTimeFromJson)  DateTime? remindAt,  ScheduleEventModel event)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleModel() when $default != null:
return $default(_that.id,_that.eventId,_that.start,_that.end,_that.oneDay,_that.remindAt,_that.event);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _ScheduleModel implements ScheduleModel {
  const _ScheduleModel({required this.id, @JsonKey(name: 'event_id') required this.eventId, @JsonKey(fromJson: _dateTimeFromJson) required this.start, @JsonKey(fromJson: _dateTimeFromJson) required this.end, @JsonKey(name: 'one_day') required this.oneDay, @JsonKey(name: 'remind_at', required: true, fromJson: _nullableDateTimeFromJson) this.remindAt, required this.event});
  factory _ScheduleModel.fromJson(Map<String, dynamic> json) => _$ScheduleModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'event_id') final  String eventId;
@override@JsonKey(fromJson: _dateTimeFromJson) final  DateTime start;
@override@JsonKey(fromJson: _dateTimeFromJson) final  DateTime end;
@override@JsonKey(name: 'one_day') final  bool oneDay;
@override@JsonKey(name: 'remind_at', required: true, fromJson: _nullableDateTimeFromJson) final  DateTime? remindAt;
@override final  ScheduleEventModel event;

/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleModelCopyWith<_ScheduleModel> get copyWith => __$ScheduleModelCopyWithImpl<_ScheduleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.oneDay, oneDay) || other.oneDay == oneDay)&&(identical(other.remindAt, remindAt) || other.remindAt == remindAt)&&(identical(other.event, event) || other.event == event));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,eventId,start,end,oneDay,remindAt,event);
}

@override
String toString() {
    return 'ScheduleModel(id: $id, eventId: $eventId, start: $start, end: $end, oneDay: $oneDay, remindAt: $remindAt, event: $event)';
}


}

/// @nodoc
abstract mixin class _$ScheduleModelCopyWith<$Res> implements $ScheduleModelCopyWith<$Res> {
  factory _$ScheduleModelCopyWith(_ScheduleModel value, $Res Function(_ScheduleModel) _then) = __$ScheduleModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId,@JsonKey(fromJson: _dateTimeFromJson) DateTime start,@JsonKey(fromJson: _dateTimeFromJson) DateTime end,@JsonKey(name: 'one_day') bool oneDay,@JsonKey(name: 'remind_at', required: true, fromJson: _nullableDateTimeFromJson) DateTime? remindAt, ScheduleEventModel event
});


@override $ScheduleEventModelCopyWith<$Res> get event;

}
/// @nodoc
class __$ScheduleModelCopyWithImpl<$Res>
    implements _$ScheduleModelCopyWith<$Res> {
  __$ScheduleModelCopyWithImpl(this._self, this._then);

  final _ScheduleModel _self;
  final $Res Function(_ScheduleModel) _then;

/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? start = null,Object? end = null,Object? oneDay = null,Object? remindAt = freezed,Object? event = null,}) {
  return _then(_ScheduleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,oneDay: null == oneDay ? _self.oneDay : oneDay // ignore: cast_nullable_to_non_nullable
as bool,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as ScheduleEventModel,
  ));
}

/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduleEventModelCopyWith<$Res> get event {
  
  return $ScheduleEventModelCopyWith<$Res>(_self.event, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}

/// @nodoc
mixin _$ScheduleDraft {

 String get title; ScheduleEventType get type; ScheduleEventScheduleType get scheduleType; DateTime get startDate; DateTime get endDate; ScheduleEventRepeatType? get repeatType; List<int>? get repeatPattern; String? get startTime; String? get endTime; String? get note; String? get physicalAddress; ScheduleEventPrivacy get privacy; bool get isGeneral; ScheduleEventRemindRange? get remindRange; int? get remindValue; List<String> get participants; List<String> get observers;
/// Create a copy of ScheduleDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleDraftCopyWith<ScheduleDraft> get copyWith => _$ScheduleDraftCopyWithImpl<ScheduleDraft>(this as ScheduleDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ScheduleDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleDraft&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.scheduleType, _this.scheduleType) || other.scheduleType == _this.scheduleType)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.repeatType, _this.repeatType) || other.repeatType == _this.repeatType)&&const DeepCollectionEquality().equals(other.repeatPattern, _this.repeatPattern)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.physicalAddress, _this.physicalAddress) || other.physicalAddress == _this.physicalAddress)&&(identical(other.privacy, _this.privacy) || other.privacy == _this.privacy)&&(identical(other.isGeneral, _this.isGeneral) || other.isGeneral == _this.isGeneral)&&(identical(other.remindRange, _this.remindRange) || other.remindRange == _this.remindRange)&&(identical(other.remindValue, _this.remindValue) || other.remindValue == _this.remindValue)&&const DeepCollectionEquality().equals(other.participants, _this.participants)&&const DeepCollectionEquality().equals(other.observers, _this.observers));
}


@override
int get hashCode {
  final _this = this as ScheduleDraft;
  return Object.hash(runtimeType,_this.title,_this.type,_this.scheduleType,_this.startDate,_this.endDate,_this.repeatType,const DeepCollectionEquality().hash(_this.repeatPattern),_this.startTime,_this.endTime,_this.note,_this.physicalAddress,_this.privacy,_this.isGeneral,_this.remindRange,_this.remindValue,const DeepCollectionEquality().hash(_this.participants),const DeepCollectionEquality().hash(_this.observers));
}

@override
String toString() {
  final _this = this as ScheduleDraft;
  return 'ScheduleDraft(title: ${_this.title}, type: ${_this.type}, scheduleType: ${_this.scheduleType}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, repeatType: ${_this.repeatType}, repeatPattern: ${_this.repeatPattern}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, note: ${_this.note}, physicalAddress: ${_this.physicalAddress}, privacy: ${_this.privacy}, isGeneral: ${_this.isGeneral}, remindRange: ${_this.remindRange}, remindValue: ${_this.remindValue}, participants: ${_this.participants}, observers: ${_this.observers})';
}


}

/// @nodoc
abstract mixin class $ScheduleDraftCopyWith<$Res>  {
  factory $ScheduleDraftCopyWith(ScheduleDraft value, $Res Function(ScheduleDraft) _then) = _$ScheduleDraftCopyWithImpl;
@useResult
$Res call({
 String title, ScheduleEventType type, ScheduleEventScheduleType scheduleType, DateTime startDate, DateTime endDate, ScheduleEventRepeatType? repeatType, List<int>? repeatPattern, String? startTime, String? endTime, String? note, String? physicalAddress, ScheduleEventPrivacy privacy, bool isGeneral, ScheduleEventRemindRange? remindRange, int? remindValue, List<String> participants, List<String> observers
});




}
/// @nodoc
class _$ScheduleDraftCopyWithImpl<$Res>
    implements $ScheduleDraftCopyWith<$Res> {
  _$ScheduleDraftCopyWithImpl(this._self, this._then);

  final ScheduleDraft _self;
  final $Res Function(ScheduleDraft) _then;

/// Create a copy of ScheduleDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? type = null,Object? scheduleType = null,Object? startDate = null,Object? endDate = null,Object? repeatType = freezed,Object? repeatPattern = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? note = freezed,Object? physicalAddress = freezed,Object? privacy = null,Object? isGeneral = null,Object? remindRange = freezed,Object? remindValue = freezed,Object? participants = null,Object? observers = null,}) {
  return _then(ScheduleDraft(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ScheduleEventType,scheduleType: null == scheduleType ? _self.scheduleType : scheduleType // ignore: cast_nullable_to_non_nullable
as ScheduleEventScheduleType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,repeatType: freezed == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as ScheduleEventRepeatType?,repeatPattern: freezed == repeatPattern ? _self.repeatPattern : repeatPattern // ignore: cast_nullable_to_non_nullable
as List<int>?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,physicalAddress: freezed == physicalAddress ? _self.physicalAddress : physicalAddress // ignore: cast_nullable_to_non_nullable
as String?,privacy: null == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as ScheduleEventPrivacy,isGeneral: null == isGeneral ? _self.isGeneral : isGeneral // ignore: cast_nullable_to_non_nullable
as bool,remindRange: freezed == remindRange ? _self.remindRange : remindRange // ignore: cast_nullable_to_non_nullable
as ScheduleEventRemindRange?,remindValue: freezed == remindValue ? _self.remindValue : remindValue // ignore: cast_nullable_to_non_nullable
as int?,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<String>,observers: null == observers ? _self.observers : observers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleDraft].
extension ScheduleDraftPatterns on ScheduleDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleDraft value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  ScheduleEventType type,  ScheduleEventScheduleType scheduleType,  DateTime startDate,  DateTime endDate,  ScheduleEventRepeatType? repeatType,  List<int>? repeatPattern,  String? startTime,  String? endTime,  String? note,  String? physicalAddress,  ScheduleEventPrivacy privacy,  bool isGeneral,  ScheduleEventRemindRange? remindRange,  int? remindValue,  List<String> participants,  List<String> observers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleDraft() when $default != null:
return $default(_that.title,_that.type,_that.scheduleType,_that.startDate,_that.endDate,_that.repeatType,_that.repeatPattern,_that.startTime,_that.endTime,_that.note,_that.physicalAddress,_that.privacy,_that.isGeneral,_that.remindRange,_that.remindValue,_that.participants,_that.observers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  ScheduleEventType type,  ScheduleEventScheduleType scheduleType,  DateTime startDate,  DateTime endDate,  ScheduleEventRepeatType? repeatType,  List<int>? repeatPattern,  String? startTime,  String? endTime,  String? note,  String? physicalAddress,  ScheduleEventPrivacy privacy,  bool isGeneral,  ScheduleEventRemindRange? remindRange,  int? remindValue,  List<String> participants,  List<String> observers)  $default,) {final _that = this;
switch (_that) {
case _ScheduleDraft():
return $default(_that.title,_that.type,_that.scheduleType,_that.startDate,_that.endDate,_that.repeatType,_that.repeatPattern,_that.startTime,_that.endTime,_that.note,_that.physicalAddress,_that.privacy,_that.isGeneral,_that.remindRange,_that.remindValue,_that.participants,_that.observers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  ScheduleEventType type,  ScheduleEventScheduleType scheduleType,  DateTime startDate,  DateTime endDate,  ScheduleEventRepeatType? repeatType,  List<int>? repeatPattern,  String? startTime,  String? endTime,  String? note,  String? physicalAddress,  ScheduleEventPrivacy privacy,  bool isGeneral,  ScheduleEventRemindRange? remindRange,  int? remindValue,  List<String> participants,  List<String> observers)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleDraft() when $default != null:
return $default(_that.title,_that.type,_that.scheduleType,_that.startDate,_that.endDate,_that.repeatType,_that.repeatPattern,_that.startTime,_that.endTime,_that.note,_that.physicalAddress,_that.privacy,_that.isGeneral,_that.remindRange,_that.remindValue,_that.participants,_that.observers);case _:
  return null;

}
}

}

/// @nodoc


class _ScheduleDraft implements ScheduleDraft {
  const _ScheduleDraft({required this.title, required this.type, required this.scheduleType, required this.startDate, required this.endDate, required this.repeatType, required  List<int>? repeatPattern, required this.startTime, required this.endTime, required this.note, required this.physicalAddress, required this.privacy, required this.isGeneral, required this.remindRange, required this.remindValue, required  List<String> participants, required  List<String> observers}): _repeatPattern = repeatPattern,_participants = participants,_observers = observers;
  

@override final  String title;
@override final  ScheduleEventType type;
@override final  ScheduleEventScheduleType scheduleType;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  ScheduleEventRepeatType? repeatType;
 final  List<int>? _repeatPattern;
@override List<int>? get repeatPattern {
  final value = _repeatPattern;
  if (value == null) return null;
  if (_repeatPattern is EqualUnmodifiableListView) return _repeatPattern;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? startTime;
@override final  String? endTime;
@override final  String? note;
@override final  String? physicalAddress;
@override final  ScheduleEventPrivacy privacy;
@override final  bool isGeneral;
@override final  ScheduleEventRemindRange? remindRange;
@override final  int? remindValue;
 final  List<String> _participants;
@override List<String> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

 final  List<String> _observers;
@override List<String> get observers {
  if (_observers is EqualUnmodifiableListView) return _observers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_observers);
}


/// Create a copy of ScheduleDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleDraftCopyWith<_ScheduleDraft> get copyWith => __$ScheduleDraftCopyWithImpl<_ScheduleDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.scheduleType, scheduleType) || other.scheduleType == scheduleType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.repeatType, repeatType) || other.repeatType == repeatType)&&const DeepCollectionEquality().equals(other.repeatPattern, _repeatPattern)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.note, note) || other.note == note)&&(identical(other.physicalAddress, physicalAddress) || other.physicalAddress == physicalAddress)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&(identical(other.isGeneral, isGeneral) || other.isGeneral == isGeneral)&&(identical(other.remindRange, remindRange) || other.remindRange == remindRange)&&(identical(other.remindValue, remindValue) || other.remindValue == remindValue)&&const DeepCollectionEquality().equals(other.participants, _participants)&&const DeepCollectionEquality().equals(other.observers, _observers));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,type,scheduleType,startDate,endDate,repeatType,const DeepCollectionEquality().hash(_repeatPattern),startTime,endTime,note,physicalAddress,privacy,isGeneral,remindRange,remindValue,const DeepCollectionEquality().hash(_participants),const DeepCollectionEquality().hash(_observers));
}

@override
String toString() {
    return 'ScheduleDraft(title: $title, type: $type, scheduleType: $scheduleType, startDate: $startDate, endDate: $endDate, repeatType: $repeatType, repeatPattern: $repeatPattern, startTime: $startTime, endTime: $endTime, note: $note, physicalAddress: $physicalAddress, privacy: $privacy, isGeneral: $isGeneral, remindRange: $remindRange, remindValue: $remindValue, participants: $participants, observers: $observers)';
}


}

/// @nodoc
abstract mixin class _$ScheduleDraftCopyWith<$Res> implements $ScheduleDraftCopyWith<$Res> {
  factory _$ScheduleDraftCopyWith(_ScheduleDraft value, $Res Function(_ScheduleDraft) _then) = __$ScheduleDraftCopyWithImpl;
@override @useResult
$Res call({
 String title, ScheduleEventType type, ScheduleEventScheduleType scheduleType, DateTime startDate, DateTime endDate, ScheduleEventRepeatType? repeatType, List<int>? repeatPattern, String? startTime, String? endTime, String? note, String? physicalAddress, ScheduleEventPrivacy privacy, bool isGeneral, ScheduleEventRemindRange? remindRange, int? remindValue, List<String> participants, List<String> observers
});




}
/// @nodoc
class __$ScheduleDraftCopyWithImpl<$Res>
    implements _$ScheduleDraftCopyWith<$Res> {
  __$ScheduleDraftCopyWithImpl(this._self, this._then);

  final _ScheduleDraft _self;
  final $Res Function(_ScheduleDraft) _then;

/// Create a copy of ScheduleDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? type = null,Object? scheduleType = null,Object? startDate = null,Object? endDate = null,Object? repeatType = freezed,Object? repeatPattern = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? note = freezed,Object? physicalAddress = freezed,Object? privacy = null,Object? isGeneral = null,Object? remindRange = freezed,Object? remindValue = freezed,Object? participants = null,Object? observers = null,}) {
  return _then(_ScheduleDraft(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ScheduleEventType,scheduleType: null == scheduleType ? _self.scheduleType : scheduleType // ignore: cast_nullable_to_non_nullable
as ScheduleEventScheduleType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,repeatType: freezed == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as ScheduleEventRepeatType?,repeatPattern: freezed == repeatPattern ? _self._repeatPattern : repeatPattern // ignore: cast_nullable_to_non_nullable
as List<int>?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,physicalAddress: freezed == physicalAddress ? _self.physicalAddress : physicalAddress // ignore: cast_nullable_to_non_nullable
as String?,privacy: null == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as ScheduleEventPrivacy,isGeneral: null == isGeneral ? _self.isGeneral : isGeneral // ignore: cast_nullable_to_non_nullable
as bool,remindRange: freezed == remindRange ? _self.remindRange : remindRange // ignore: cast_nullable_to_non_nullable
as ScheduleEventRemindRange?,remindValue: freezed == remindValue ? _self.remindValue : remindValue // ignore: cast_nullable_to_non_nullable
as int?,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<String>,observers: null == observers ? _self._observers : observers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AbsenceRequestUserRef {

 String get id; String get name;@JsonKey(name: 'username') String? get username; String? get email; String? get avatar;
/// Create a copy of AbsenceRequestUserRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AbsenceRequestUserRefCopyWith<AbsenceRequestUserRef> get copyWith => _$AbsenceRequestUserRefCopyWithImpl<AbsenceRequestUserRef>(this as AbsenceRequestUserRef, _$identity);

  /// Serializes this AbsenceRequestUserRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AbsenceRequestUserRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AbsenceRequestUserRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.avatar, _this.avatar) || other.avatar == _this.avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AbsenceRequestUserRef;
  return Object.hash(runtimeType,_this.id,_this.name,_this.username,_this.email,_this.avatar);
}

@override
String toString() {
  final _this = this as AbsenceRequestUserRef;
  return 'AbsenceRequestUserRef(id: ${_this.id}, name: ${_this.name}, username: ${_this.username}, email: ${_this.email}, avatar: ${_this.avatar})';
}


}

/// @nodoc
abstract mixin class $AbsenceRequestUserRefCopyWith<$Res>  {
  factory $AbsenceRequestUserRefCopyWith(AbsenceRequestUserRef value, $Res Function(AbsenceRequestUserRef) _then) = _$AbsenceRequestUserRefCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'username') String? username, String? email, String? avatar
});




}
/// @nodoc
class _$AbsenceRequestUserRefCopyWithImpl<$Res>
    implements $AbsenceRequestUserRefCopyWith<$Res> {
  _$AbsenceRequestUserRefCopyWithImpl(this._self, this._then);

  final AbsenceRequestUserRef _self;
  final $Res Function(AbsenceRequestUserRef) _then;

/// Create a copy of AbsenceRequestUserRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? username = freezed,Object? email = freezed,Object? avatar = freezed,}) {
  return _then(AbsenceRequestUserRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AbsenceRequestUserRef].
extension AbsenceRequestUserRefPatterns on AbsenceRequestUserRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AbsenceRequestUserRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AbsenceRequestUserRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AbsenceRequestUserRef value)  $default,){
final _that = this;
switch (_that) {
case _AbsenceRequestUserRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AbsenceRequestUserRef value)?  $default,){
final _that = this;
switch (_that) {
case _AbsenceRequestUserRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'username')  String? username,  String? email,  String? avatar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AbsenceRequestUserRef() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.email,_that.avatar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'username')  String? username,  String? email,  String? avatar)  $default,) {final _that = this;
switch (_that) {
case _AbsenceRequestUserRef():
return $default(_that.id,_that.name,_that.username,_that.email,_that.avatar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'username')  String? username,  String? email,  String? avatar)?  $default,) {final _that = this;
switch (_that) {
case _AbsenceRequestUserRef() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.email,_that.avatar);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AbsenceRequestUserRef implements AbsenceRequestUserRef {
  const _AbsenceRequestUserRef({required this.id, required this.name, @JsonKey(name: 'username') this.username, this.email, this.avatar});
  factory _AbsenceRequestUserRef.fromJson(Map<String, dynamic> json) => _$AbsenceRequestUserRefFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'username') final  String? username;
@override final  String? email;
@override final  String? avatar;

/// Create a copy of AbsenceRequestUserRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AbsenceRequestUserRefCopyWith<_AbsenceRequestUserRef> get copyWith => __$AbsenceRequestUserRefCopyWithImpl<_AbsenceRequestUserRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AbsenceRequestUserRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AbsenceRequestUserRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,username,email,avatar);
}

@override
String toString() {
    return 'AbsenceRequestUserRef(id: $id, name: $name, username: $username, email: $email, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class _$AbsenceRequestUserRefCopyWith<$Res> implements $AbsenceRequestUserRefCopyWith<$Res> {
  factory _$AbsenceRequestUserRefCopyWith(_AbsenceRequestUserRef value, $Res Function(_AbsenceRequestUserRef) _then) = __$AbsenceRequestUserRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'username') String? username, String? email, String? avatar
});




}
/// @nodoc
class __$AbsenceRequestUserRefCopyWithImpl<$Res>
    implements _$AbsenceRequestUserRefCopyWith<$Res> {
  __$AbsenceRequestUserRefCopyWithImpl(this._self, this._then);

  final _AbsenceRequestUserRef _self;
  final $Res Function(_AbsenceRequestUserRef) _then;

/// Create a copy of AbsenceRequestUserRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? username = freezed,Object? email = freezed,Object? avatar = freezed,}) {
  return _then(_AbsenceRequestUserRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AbsenceRequestModel {

 String get id; String? get code;@JsonKey(name: 'root_organization_id') String get rootOrganizationId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'leave_type') String get leaveTypeWire;@JsonKey(name: 'start_at') String get startAt;@JsonKey(name: 'end_at') String get endAt; String get reason; String? get address; String get status;@JsonKey(name: 'duration_days') double get durationDays;@JsonKey(name: 'reviewer_id') String get reviewerId; AbsenceRequestUserRef? get user; AbsenceRequestUserRef? get requester; AbsenceRequestUserRef? get reviewer;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'approved_at') String? get approvedAt;@JsonKey(name: 'rejected_at') String? get rejectedAt;@JsonKey(name: 'approval_note') String? get approvalNote;
/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AbsenceRequestModelCopyWith<AbsenceRequestModel> get copyWith => _$AbsenceRequestModelCopyWithImpl<AbsenceRequestModel>(this as AbsenceRequestModel, _$identity);

  /// Serializes this AbsenceRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AbsenceRequestModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AbsenceRequestModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.rootOrganizationId, _this.rootOrganizationId) || other.rootOrganizationId == _this.rootOrganizationId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.leaveTypeWire, _this.leaveTypeWire) || other.leaveTypeWire == _this.leaveTypeWire)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.durationDays, _this.durationDays) || other.durationDays == _this.durationDays)&&(identical(other.reviewerId, _this.reviewerId) || other.reviewerId == _this.reviewerId)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.requester, _this.requester) || other.requester == _this.requester)&&(identical(other.reviewer, _this.reviewer) || other.reviewer == _this.reviewer)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.approvedAt, _this.approvedAt) || other.approvedAt == _this.approvedAt)&&(identical(other.rejectedAt, _this.rejectedAt) || other.rejectedAt == _this.rejectedAt)&&(identical(other.approvalNote, _this.approvalNote) || other.approvalNote == _this.approvalNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AbsenceRequestModel;
  return Object.hashAll([runtimeType,_this.id,_this.code,_this.rootOrganizationId,_this.userId,_this.leaveTypeWire,_this.startAt,_this.endAt,_this.reason,_this.address,_this.status,_this.durationDays,_this.reviewerId,_this.user,_this.requester,_this.reviewer,_this.createdAt,_this.approvedAt,_this.rejectedAt,_this.approvalNote]);
}

@override
String toString() {
  final _this = this as AbsenceRequestModel;
  return 'AbsenceRequestModel(id: ${_this.id}, code: ${_this.code}, rootOrganizationId: ${_this.rootOrganizationId}, userId: ${_this.userId}, leaveTypeWire: ${_this.leaveTypeWire}, startAt: ${_this.startAt}, endAt: ${_this.endAt}, reason: ${_this.reason}, address: ${_this.address}, status: ${_this.status}, durationDays: ${_this.durationDays}, reviewerId: ${_this.reviewerId}, user: ${_this.user}, requester: ${_this.requester}, reviewer: ${_this.reviewer}, createdAt: ${_this.createdAt}, approvedAt: ${_this.approvedAt}, rejectedAt: ${_this.rejectedAt}, approvalNote: ${_this.approvalNote})';
}


}

/// @nodoc
abstract mixin class $AbsenceRequestModelCopyWith<$Res>  {
  factory $AbsenceRequestModelCopyWith(AbsenceRequestModel value, $Res Function(AbsenceRequestModel) _then) = _$AbsenceRequestModelCopyWithImpl;
@useResult
$Res call({
 String id, String? code,@JsonKey(name: 'root_organization_id') String rootOrganizationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'leave_type') String leaveTypeWire,@JsonKey(name: 'start_at') String startAt,@JsonKey(name: 'end_at') String endAt, String reason, String? address, String status,@JsonKey(name: 'duration_days') double durationDays,@JsonKey(name: 'reviewer_id') String reviewerId, AbsenceRequestUserRef? user, AbsenceRequestUserRef? requester, AbsenceRequestUserRef? reviewer,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'approved_at') String? approvedAt,@JsonKey(name: 'rejected_at') String? rejectedAt,@JsonKey(name: 'approval_note') String? approvalNote
});


$AbsenceRequestUserRefCopyWith<$Res>? get user;$AbsenceRequestUserRefCopyWith<$Res>? get requester;$AbsenceRequestUserRefCopyWith<$Res>? get reviewer;

}
/// @nodoc
class _$AbsenceRequestModelCopyWithImpl<$Res>
    implements $AbsenceRequestModelCopyWith<$Res> {
  _$AbsenceRequestModelCopyWithImpl(this._self, this._then);

  final AbsenceRequestModel _self;
  final $Res Function(AbsenceRequestModel) _then;

/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = freezed,Object? rootOrganizationId = null,Object? userId = null,Object? leaveTypeWire = null,Object? startAt = null,Object? endAt = null,Object? reason = null,Object? address = freezed,Object? status = null,Object? durationDays = null,Object? reviewerId = null,Object? user = freezed,Object? requester = freezed,Object? reviewer = freezed,Object? createdAt = freezed,Object? approvedAt = freezed,Object? rejectedAt = freezed,Object? approvalNote = freezed,}) {
  return _then(AbsenceRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,rootOrganizationId: null == rootOrganizationId ? _self.rootOrganizationId : rootOrganizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeWire: null == leaveTypeWire ? _self.leaveTypeWire : leaveTypeWire // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as double,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AbsenceRequestUserRef?,requester: freezed == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as AbsenceRequestUserRef?,reviewer: freezed == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as AbsenceRequestUserRef?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectedAt: freezed == rejectedAt ? _self.rejectedAt : rejectedAt // ignore: cast_nullable_to_non_nullable
as String?,approvalNote: freezed == approvalNote ? _self.approvalNote : approvalNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AbsenceRequestUserRefCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AbsenceRequestUserRefCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AbsenceRequestUserRefCopyWith<$Res>? get requester {
    if (_self.requester == null) {
    return null;
  }

  return $AbsenceRequestUserRefCopyWith<$Res>(_self.requester!, (value) {
    return _then(_self.copyWith(requester: value));
  });
}/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AbsenceRequestUserRefCopyWith<$Res>? get reviewer {
    if (_self.reviewer == null) {
    return null;
  }

  return $AbsenceRequestUserRefCopyWith<$Res>(_self.reviewer!, (value) {
    return _then(_self.copyWith(reviewer: value));
  });
}
}


/// Adds pattern-matching-related methods to [AbsenceRequestModel].
extension AbsenceRequestModelPatterns on AbsenceRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AbsenceRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AbsenceRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AbsenceRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _AbsenceRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AbsenceRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _AbsenceRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? code, @JsonKey(name: 'root_organization_id')  String rootOrganizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'leave_type')  String leaveTypeWire, @JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt,  String reason,  String? address,  String status, @JsonKey(name: 'duration_days')  double durationDays, @JsonKey(name: 'reviewer_id')  String reviewerId,  AbsenceRequestUserRef? user,  AbsenceRequestUserRef? requester,  AbsenceRequestUserRef? reviewer, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'approved_at')  String? approvedAt, @JsonKey(name: 'rejected_at')  String? rejectedAt, @JsonKey(name: 'approval_note')  String? approvalNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AbsenceRequestModel() when $default != null:
return $default(_that.id,_that.code,_that.rootOrganizationId,_that.userId,_that.leaveTypeWire,_that.startAt,_that.endAt,_that.reason,_that.address,_that.status,_that.durationDays,_that.reviewerId,_that.user,_that.requester,_that.reviewer,_that.createdAt,_that.approvedAt,_that.rejectedAt,_that.approvalNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? code, @JsonKey(name: 'root_organization_id')  String rootOrganizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'leave_type')  String leaveTypeWire, @JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt,  String reason,  String? address,  String status, @JsonKey(name: 'duration_days')  double durationDays, @JsonKey(name: 'reviewer_id')  String reviewerId,  AbsenceRequestUserRef? user,  AbsenceRequestUserRef? requester,  AbsenceRequestUserRef? reviewer, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'approved_at')  String? approvedAt, @JsonKey(name: 'rejected_at')  String? rejectedAt, @JsonKey(name: 'approval_note')  String? approvalNote)  $default,) {final _that = this;
switch (_that) {
case _AbsenceRequestModel():
return $default(_that.id,_that.code,_that.rootOrganizationId,_that.userId,_that.leaveTypeWire,_that.startAt,_that.endAt,_that.reason,_that.address,_that.status,_that.durationDays,_that.reviewerId,_that.user,_that.requester,_that.reviewer,_that.createdAt,_that.approvedAt,_that.rejectedAt,_that.approvalNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? code, @JsonKey(name: 'root_organization_id')  String rootOrganizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'leave_type')  String leaveTypeWire, @JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt,  String reason,  String? address,  String status, @JsonKey(name: 'duration_days')  double durationDays, @JsonKey(name: 'reviewer_id')  String reviewerId,  AbsenceRequestUserRef? user,  AbsenceRequestUserRef? requester,  AbsenceRequestUserRef? reviewer, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'approved_at')  String? approvedAt, @JsonKey(name: 'rejected_at')  String? rejectedAt, @JsonKey(name: 'approval_note')  String? approvalNote)?  $default,) {final _that = this;
switch (_that) {
case _AbsenceRequestModel() when $default != null:
return $default(_that.id,_that.code,_that.rootOrganizationId,_that.userId,_that.leaveTypeWire,_that.startAt,_that.endAt,_that.reason,_that.address,_that.status,_that.durationDays,_that.reviewerId,_that.user,_that.requester,_that.reviewer,_that.createdAt,_that.approvedAt,_that.rejectedAt,_that.approvalNote);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AbsenceRequestModel extends AbsenceRequestModel {
  const _AbsenceRequestModel({required this.id, this.code, @JsonKey(name: 'root_organization_id') required this.rootOrganizationId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'leave_type') required this.leaveTypeWire, @JsonKey(name: 'start_at') required this.startAt, @JsonKey(name: 'end_at') required this.endAt, required this.reason, this.address, required this.status, @JsonKey(name: 'duration_days') this.durationDays = 0.0, @JsonKey(name: 'reviewer_id') required this.reviewerId, this.user, this.requester, this.reviewer, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'approved_at') this.approvedAt, @JsonKey(name: 'rejected_at') this.rejectedAt, @JsonKey(name: 'approval_note') this.approvalNote}): super._();
  factory _AbsenceRequestModel.fromJson(Map<String, dynamic> json) => _$AbsenceRequestModelFromJson(json);

@override final  String id;
@override final  String? code;
@override@JsonKey(name: 'root_organization_id') final  String rootOrganizationId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'leave_type') final  String leaveTypeWire;
@override@JsonKey(name: 'start_at') final  String startAt;
@override@JsonKey(name: 'end_at') final  String endAt;
@override final  String reason;
@override final  String? address;
@override final  String status;
@override@JsonKey(name: 'duration_days') final  double durationDays;
@override@JsonKey(name: 'reviewer_id') final  String reviewerId;
@override final  AbsenceRequestUserRef? user;
@override final  AbsenceRequestUserRef? requester;
@override final  AbsenceRequestUserRef? reviewer;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'approved_at') final  String? approvedAt;
@override@JsonKey(name: 'rejected_at') final  String? rejectedAt;
@override@JsonKey(name: 'approval_note') final  String? approvalNote;

/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AbsenceRequestModelCopyWith<_AbsenceRequestModel> get copyWith => __$AbsenceRequestModelCopyWithImpl<_AbsenceRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AbsenceRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AbsenceRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.rootOrganizationId, rootOrganizationId) || other.rootOrganizationId == rootOrganizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.leaveTypeWire, leaveTypeWire) || other.leaveTypeWire == leaveTypeWire)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.address, address) || other.address == address)&&(identical(other.status, status) || other.status == status)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.user, user) || other.user == user)&&(identical(other.requester, requester) || other.requester == requester)&&(identical(other.reviewer, reviewer) || other.reviewer == reviewer)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.rejectedAt, rejectedAt) || other.rejectedAt == rejectedAt)&&(identical(other.approvalNote, approvalNote) || other.approvalNote == approvalNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,code,rootOrganizationId,userId,leaveTypeWire,startAt,endAt,reason,address,status,durationDays,reviewerId,user,requester,reviewer,createdAt,approvedAt,rejectedAt,approvalNote]);
}

@override
String toString() {
    return 'AbsenceRequestModel(id: $id, code: $code, rootOrganizationId: $rootOrganizationId, userId: $userId, leaveTypeWire: $leaveTypeWire, startAt: $startAt, endAt: $endAt, reason: $reason, address: $address, status: $status, durationDays: $durationDays, reviewerId: $reviewerId, user: $user, requester: $requester, reviewer: $reviewer, createdAt: $createdAt, approvedAt: $approvedAt, rejectedAt: $rejectedAt, approvalNote: $approvalNote)';
}


}

/// @nodoc
abstract mixin class _$AbsenceRequestModelCopyWith<$Res> implements $AbsenceRequestModelCopyWith<$Res> {
  factory _$AbsenceRequestModelCopyWith(_AbsenceRequestModel value, $Res Function(_AbsenceRequestModel) _then) = __$AbsenceRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? code,@JsonKey(name: 'root_organization_id') String rootOrganizationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'leave_type') String leaveTypeWire,@JsonKey(name: 'start_at') String startAt,@JsonKey(name: 'end_at') String endAt, String reason, String? address, String status,@JsonKey(name: 'duration_days') double durationDays,@JsonKey(name: 'reviewer_id') String reviewerId, AbsenceRequestUserRef? user, AbsenceRequestUserRef? requester, AbsenceRequestUserRef? reviewer,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'approved_at') String? approvedAt,@JsonKey(name: 'rejected_at') String? rejectedAt,@JsonKey(name: 'approval_note') String? approvalNote
});


@override $AbsenceRequestUserRefCopyWith<$Res>? get user;@override $AbsenceRequestUserRefCopyWith<$Res>? get requester;@override $AbsenceRequestUserRefCopyWith<$Res>? get reviewer;

}
/// @nodoc
class __$AbsenceRequestModelCopyWithImpl<$Res>
    implements _$AbsenceRequestModelCopyWith<$Res> {
  __$AbsenceRequestModelCopyWithImpl(this._self, this._then);

  final _AbsenceRequestModel _self;
  final $Res Function(_AbsenceRequestModel) _then;

/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = freezed,Object? rootOrganizationId = null,Object? userId = null,Object? leaveTypeWire = null,Object? startAt = null,Object? endAt = null,Object? reason = null,Object? address = freezed,Object? status = null,Object? durationDays = null,Object? reviewerId = null,Object? user = freezed,Object? requester = freezed,Object? reviewer = freezed,Object? createdAt = freezed,Object? approvedAt = freezed,Object? rejectedAt = freezed,Object? approvalNote = freezed,}) {
  return _then(_AbsenceRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,rootOrganizationId: null == rootOrganizationId ? _self.rootOrganizationId : rootOrganizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeWire: null == leaveTypeWire ? _self.leaveTypeWire : leaveTypeWire // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as double,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AbsenceRequestUserRef?,requester: freezed == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as AbsenceRequestUserRef?,reviewer: freezed == reviewer ? _self.reviewer : reviewer // ignore: cast_nullable_to_non_nullable
as AbsenceRequestUserRef?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String?,rejectedAt: freezed == rejectedAt ? _self.rejectedAt : rejectedAt // ignore: cast_nullable_to_non_nullable
as String?,approvalNote: freezed == approvalNote ? _self.approvalNote : approvalNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AbsenceRequestUserRefCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AbsenceRequestUserRefCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AbsenceRequestUserRefCopyWith<$Res>? get requester {
    if (_self.requester == null) {
    return null;
  }

  return $AbsenceRequestUserRefCopyWith<$Res>(_self.requester!, (value) {
    return _then(_self.copyWith(requester: value));
  });
}/// Create a copy of AbsenceRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AbsenceRequestUserRefCopyWith<$Res>? get reviewer {
    if (_self.reviewer == null) {
    return null;
  }

  return $AbsenceRequestUserRefCopyWith<$Res>(_self.reviewer!, (value) {
    return _then(_self.copyWith(reviewer: value));
  });
}
}


/// @nodoc
mixin _$LeaveBalanceModel {

 double get entitlement; double get used; double get remaining;@JsonKey(name: 'cycle_start') String? get cycleStart;@JsonKey(name: 'cycle_end') String? get cycleEnd;
/// Create a copy of LeaveBalanceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveBalanceModelCopyWith<LeaveBalanceModel> get copyWith => _$LeaveBalanceModelCopyWithImpl<LeaveBalanceModel>(this as LeaveBalanceModel, _$identity);

  /// Serializes this LeaveBalanceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LeaveBalanceModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveBalanceModel&&(identical(other.entitlement, _this.entitlement) || other.entitlement == _this.entitlement)&&(identical(other.used, _this.used) || other.used == _this.used)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.cycleStart, _this.cycleStart) || other.cycleStart == _this.cycleStart)&&(identical(other.cycleEnd, _this.cycleEnd) || other.cycleEnd == _this.cycleEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LeaveBalanceModel;
  return Object.hash(runtimeType,_this.entitlement,_this.used,_this.remaining,_this.cycleStart,_this.cycleEnd);
}

@override
String toString() {
  final _this = this as LeaveBalanceModel;
  return 'LeaveBalanceModel(entitlement: ${_this.entitlement}, used: ${_this.used}, remaining: ${_this.remaining}, cycleStart: ${_this.cycleStart}, cycleEnd: ${_this.cycleEnd})';
}


}

/// @nodoc
abstract mixin class $LeaveBalanceModelCopyWith<$Res>  {
  factory $LeaveBalanceModelCopyWith(LeaveBalanceModel value, $Res Function(LeaveBalanceModel) _then) = _$LeaveBalanceModelCopyWithImpl;
@useResult
$Res call({
 double entitlement, double used, double remaining,@JsonKey(name: 'cycle_start') String? cycleStart,@JsonKey(name: 'cycle_end') String? cycleEnd
});




}
/// @nodoc
class _$LeaveBalanceModelCopyWithImpl<$Res>
    implements $LeaveBalanceModelCopyWith<$Res> {
  _$LeaveBalanceModelCopyWithImpl(this._self, this._then);

  final LeaveBalanceModel _self;
  final $Res Function(LeaveBalanceModel) _then;

/// Create a copy of LeaveBalanceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entitlement = null,Object? used = null,Object? remaining = null,Object? cycleStart = freezed,Object? cycleEnd = freezed,}) {
  return _then(LeaveBalanceModel(
entitlement: null == entitlement ? _self.entitlement : entitlement // ignore: cast_nullable_to_non_nullable
as double,used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as double,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as double,cycleStart: freezed == cycleStart ? _self.cycleStart : cycleStart // ignore: cast_nullable_to_non_nullable
as String?,cycleEnd: freezed == cycleEnd ? _self.cycleEnd : cycleEnd // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveBalanceModel].
extension LeaveBalanceModelPatterns on LeaveBalanceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveBalanceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveBalanceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveBalanceModel value)  $default,){
final _that = this;
switch (_that) {
case _LeaveBalanceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveBalanceModel value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveBalanceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double entitlement,  double used,  double remaining, @JsonKey(name: 'cycle_start')  String? cycleStart, @JsonKey(name: 'cycle_end')  String? cycleEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveBalanceModel() when $default != null:
return $default(_that.entitlement,_that.used,_that.remaining,_that.cycleStart,_that.cycleEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double entitlement,  double used,  double remaining, @JsonKey(name: 'cycle_start')  String? cycleStart, @JsonKey(name: 'cycle_end')  String? cycleEnd)  $default,) {final _that = this;
switch (_that) {
case _LeaveBalanceModel():
return $default(_that.entitlement,_that.used,_that.remaining,_that.cycleStart,_that.cycleEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double entitlement,  double used,  double remaining, @JsonKey(name: 'cycle_start')  String? cycleStart, @JsonKey(name: 'cycle_end')  String? cycleEnd)?  $default,) {final _that = this;
switch (_that) {
case _LeaveBalanceModel() when $default != null:
return $default(_that.entitlement,_that.used,_that.remaining,_that.cycleStart,_that.cycleEnd);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _LeaveBalanceModel implements LeaveBalanceModel {
  const _LeaveBalanceModel({this.entitlement = 0.0, this.used = 0.0, this.remaining = 0.0, @JsonKey(name: 'cycle_start') this.cycleStart, @JsonKey(name: 'cycle_end') this.cycleEnd});
  factory _LeaveBalanceModel.fromJson(Map<String, dynamic> json) => _$LeaveBalanceModelFromJson(json);

@override@JsonKey() final  double entitlement;
@override@JsonKey() final  double used;
@override@JsonKey() final  double remaining;
@override@JsonKey(name: 'cycle_start') final  String? cycleStart;
@override@JsonKey(name: 'cycle_end') final  String? cycleEnd;

/// Create a copy of LeaveBalanceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveBalanceModelCopyWith<_LeaveBalanceModel> get copyWith => __$LeaveBalanceModelCopyWithImpl<_LeaveBalanceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveBalanceModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveBalanceModel&&(identical(other.entitlement, entitlement) || other.entitlement == entitlement)&&(identical(other.used, used) || other.used == used)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.cycleStart, cycleStart) || other.cycleStart == cycleStart)&&(identical(other.cycleEnd, cycleEnd) || other.cycleEnd == cycleEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entitlement,used,remaining,cycleStart,cycleEnd);
}

@override
String toString() {
    return 'LeaveBalanceModel(entitlement: $entitlement, used: $used, remaining: $remaining, cycleStart: $cycleStart, cycleEnd: $cycleEnd)';
}


}

/// @nodoc
abstract mixin class _$LeaveBalanceModelCopyWith<$Res> implements $LeaveBalanceModelCopyWith<$Res> {
  factory _$LeaveBalanceModelCopyWith(_LeaveBalanceModel value, $Res Function(_LeaveBalanceModel) _then) = __$LeaveBalanceModelCopyWithImpl;
@override @useResult
$Res call({
 double entitlement, double used, double remaining,@JsonKey(name: 'cycle_start') String? cycleStart,@JsonKey(name: 'cycle_end') String? cycleEnd
});




}
/// @nodoc
class __$LeaveBalanceModelCopyWithImpl<$Res>
    implements _$LeaveBalanceModelCopyWith<$Res> {
  __$LeaveBalanceModelCopyWithImpl(this._self, this._then);

  final _LeaveBalanceModel _self;
  final $Res Function(_LeaveBalanceModel) _then;

/// Create a copy of LeaveBalanceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entitlement = null,Object? used = null,Object? remaining = null,Object? cycleStart = freezed,Object? cycleEnd = freezed,}) {
  return _then(_LeaveBalanceModel(
entitlement: null == entitlement ? _self.entitlement : entitlement // ignore: cast_nullable_to_non_nullable
as double,used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as double,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as double,cycleStart: freezed == cycleStart ? _self.cycleStart : cycleStart // ignore: cast_nullable_to_non_nullable
as String?,cycleEnd: freezed == cycleEnd ? _self.cycleEnd : cycleEnd // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WorkShiftPeriodModel {

 String get id;@JsonKey(name: 'work_shift_id') String get workShiftId;@JsonKey(name: 'start_time') String get startTime;@JsonKey(name: 'end_time') String get endTime;@JsonKey(name: 'start_day_offset') int get startDayOffset;@JsonKey(name: 'end_day_offset') int get endDayOffset;
/// Create a copy of WorkShiftPeriodModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkShiftPeriodModelCopyWith<WorkShiftPeriodModel> get copyWith => _$WorkShiftPeriodModelCopyWithImpl<WorkShiftPeriodModel>(this as WorkShiftPeriodModel, _$identity);

  /// Serializes this WorkShiftPeriodModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkShiftPeriodModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkShiftPeriodModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.workShiftId, _this.workShiftId) || other.workShiftId == _this.workShiftId)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.startDayOffset, _this.startDayOffset) || other.startDayOffset == _this.startDayOffset)&&(identical(other.endDayOffset, _this.endDayOffset) || other.endDayOffset == _this.endDayOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkShiftPeriodModel;
  return Object.hash(runtimeType,_this.id,_this.workShiftId,_this.startTime,_this.endTime,_this.startDayOffset,_this.endDayOffset);
}

@override
String toString() {
  final _this = this as WorkShiftPeriodModel;
  return 'WorkShiftPeriodModel(id: ${_this.id}, workShiftId: ${_this.workShiftId}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, startDayOffset: ${_this.startDayOffset}, endDayOffset: ${_this.endDayOffset})';
}


}

/// @nodoc
abstract mixin class $WorkShiftPeriodModelCopyWith<$Res>  {
  factory $WorkShiftPeriodModelCopyWith(WorkShiftPeriodModel value, $Res Function(WorkShiftPeriodModel) _then) = _$WorkShiftPeriodModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'work_shift_id') String workShiftId,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime,@JsonKey(name: 'start_day_offset') int startDayOffset,@JsonKey(name: 'end_day_offset') int endDayOffset
});




}
/// @nodoc
class _$WorkShiftPeriodModelCopyWithImpl<$Res>
    implements $WorkShiftPeriodModelCopyWith<$Res> {
  _$WorkShiftPeriodModelCopyWithImpl(this._self, this._then);

  final WorkShiftPeriodModel _self;
  final $Res Function(WorkShiftPeriodModel) _then;

/// Create a copy of WorkShiftPeriodModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workShiftId = null,Object? startTime = null,Object? endTime = null,Object? startDayOffset = null,Object? endDayOffset = null,}) {
  return _then(WorkShiftPeriodModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workShiftId: null == workShiftId ? _self.workShiftId : workShiftId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,startDayOffset: null == startDayOffset ? _self.startDayOffset : startDayOffset // ignore: cast_nullable_to_non_nullable
as int,endDayOffset: null == endDayOffset ? _self.endDayOffset : endDayOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkShiftPeriodModel].
extension WorkShiftPeriodModelPatterns on WorkShiftPeriodModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkShiftPeriodModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkShiftPeriodModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkShiftPeriodModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkShiftPeriodModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkShiftPeriodModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkShiftPeriodModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'work_shift_id')  String workShiftId, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(name: 'start_day_offset')  int startDayOffset, @JsonKey(name: 'end_day_offset')  int endDayOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkShiftPeriodModel() when $default != null:
return $default(_that.id,_that.workShiftId,_that.startTime,_that.endTime,_that.startDayOffset,_that.endDayOffset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'work_shift_id')  String workShiftId, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(name: 'start_day_offset')  int startDayOffset, @JsonKey(name: 'end_day_offset')  int endDayOffset)  $default,) {final _that = this;
switch (_that) {
case _WorkShiftPeriodModel():
return $default(_that.id,_that.workShiftId,_that.startTime,_that.endTime,_that.startDayOffset,_that.endDayOffset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'work_shift_id')  String workShiftId, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime, @JsonKey(name: 'start_day_offset')  int startDayOffset, @JsonKey(name: 'end_day_offset')  int endDayOffset)?  $default,) {final _that = this;
switch (_that) {
case _WorkShiftPeriodModel() when $default != null:
return $default(_that.id,_that.workShiftId,_that.startTime,_that.endTime,_that.startDayOffset,_that.endDayOffset);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _WorkShiftPeriodModel implements WorkShiftPeriodModel {
  const _WorkShiftPeriodModel({required this.id, @JsonKey(name: 'work_shift_id') required this.workShiftId, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, @JsonKey(name: 'start_day_offset') required this.startDayOffset, @JsonKey(name: 'end_day_offset') required this.endDayOffset});
  factory _WorkShiftPeriodModel.fromJson(Map<String, dynamic> json) => _$WorkShiftPeriodModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'work_shift_id') final  String workShiftId;
@override@JsonKey(name: 'start_time') final  String startTime;
@override@JsonKey(name: 'end_time') final  String endTime;
@override@JsonKey(name: 'start_day_offset') final  int startDayOffset;
@override@JsonKey(name: 'end_day_offset') final  int endDayOffset;

/// Create a copy of WorkShiftPeriodModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkShiftPeriodModelCopyWith<_WorkShiftPeriodModel> get copyWith => __$WorkShiftPeriodModelCopyWithImpl<_WorkShiftPeriodModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkShiftPeriodModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkShiftPeriodModel&&(identical(other.id, id) || other.id == id)&&(identical(other.workShiftId, workShiftId) || other.workShiftId == workShiftId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.startDayOffset, startDayOffset) || other.startDayOffset == startDayOffset)&&(identical(other.endDayOffset, endDayOffset) || other.endDayOffset == endDayOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,workShiftId,startTime,endTime,startDayOffset,endDayOffset);
}

@override
String toString() {
    return 'WorkShiftPeriodModel(id: $id, workShiftId: $workShiftId, startTime: $startTime, endTime: $endTime, startDayOffset: $startDayOffset, endDayOffset: $endDayOffset)';
}


}

/// @nodoc
abstract mixin class _$WorkShiftPeriodModelCopyWith<$Res> implements $WorkShiftPeriodModelCopyWith<$Res> {
  factory _$WorkShiftPeriodModelCopyWith(_WorkShiftPeriodModel value, $Res Function(_WorkShiftPeriodModel) _then) = __$WorkShiftPeriodModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'work_shift_id') String workShiftId,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime,@JsonKey(name: 'start_day_offset') int startDayOffset,@JsonKey(name: 'end_day_offset') int endDayOffset
});




}
/// @nodoc
class __$WorkShiftPeriodModelCopyWithImpl<$Res>
    implements _$WorkShiftPeriodModelCopyWith<$Res> {
  __$WorkShiftPeriodModelCopyWithImpl(this._self, this._then);

  final _WorkShiftPeriodModel _self;
  final $Res Function(_WorkShiftPeriodModel) _then;

/// Create a copy of WorkShiftPeriodModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workShiftId = null,Object? startTime = null,Object? endTime = null,Object? startDayOffset = null,Object? endDayOffset = null,}) {
  return _then(_WorkShiftPeriodModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workShiftId: null == workShiftId ? _self.workShiftId : workShiftId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,startDayOffset: null == startDayOffset ? _self.startDayOffset : startDayOffset // ignore: cast_nullable_to_non_nullable
as int,endDayOffset: null == endDayOffset ? _self.endDayOffset : endDayOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WorkShiftModel {

 String get id;@JsonKey(name: 'root_organization_id') String get rootOrganizationId; String get name; List<WorkShiftPeriodModel> get periods;
/// Create a copy of WorkShiftModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkShiftModelCopyWith<WorkShiftModel> get copyWith => _$WorkShiftModelCopyWithImpl<WorkShiftModel>(this as WorkShiftModel, _$identity);

  /// Serializes this WorkShiftModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkShiftModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkShiftModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.rootOrganizationId, _this.rootOrganizationId) || other.rootOrganizationId == _this.rootOrganizationId)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.periods, _this.periods));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkShiftModel;
  return Object.hash(runtimeType,_this.id,_this.rootOrganizationId,_this.name,const DeepCollectionEquality().hash(_this.periods));
}

@override
String toString() {
  final _this = this as WorkShiftModel;
  return 'WorkShiftModel(id: ${_this.id}, rootOrganizationId: ${_this.rootOrganizationId}, name: ${_this.name}, periods: ${_this.periods})';
}


}

/// @nodoc
abstract mixin class $WorkShiftModelCopyWith<$Res>  {
  factory $WorkShiftModelCopyWith(WorkShiftModel value, $Res Function(WorkShiftModel) _then) = _$WorkShiftModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'root_organization_id') String rootOrganizationId, String name, List<WorkShiftPeriodModel> periods
});




}
/// @nodoc
class _$WorkShiftModelCopyWithImpl<$Res>
    implements $WorkShiftModelCopyWith<$Res> {
  _$WorkShiftModelCopyWithImpl(this._self, this._then);

  final WorkShiftModel _self;
  final $Res Function(WorkShiftModel) _then;

/// Create a copy of WorkShiftModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rootOrganizationId = null,Object? name = null,Object? periods = null,}) {
  return _then(WorkShiftModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rootOrganizationId: null == rootOrganizationId ? _self.rootOrganizationId : rootOrganizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,periods: null == periods ? _self.periods : periods // ignore: cast_nullable_to_non_nullable
as List<WorkShiftPeriodModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkShiftModel].
extension WorkShiftModelPatterns on WorkShiftModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkShiftModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkShiftModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkShiftModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkShiftModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkShiftModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkShiftModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'root_organization_id')  String rootOrganizationId,  String name,  List<WorkShiftPeriodModel> periods)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkShiftModel() when $default != null:
return $default(_that.id,_that.rootOrganizationId,_that.name,_that.periods);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'root_organization_id')  String rootOrganizationId,  String name,  List<WorkShiftPeriodModel> periods)  $default,) {final _that = this;
switch (_that) {
case _WorkShiftModel():
return $default(_that.id,_that.rootOrganizationId,_that.name,_that.periods);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'root_organization_id')  String rootOrganizationId,  String name,  List<WorkShiftPeriodModel> periods)?  $default,) {final _that = this;
switch (_that) {
case _WorkShiftModel() when $default != null:
return $default(_that.id,_that.rootOrganizationId,_that.name,_that.periods);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _WorkShiftModel implements WorkShiftModel {
  const _WorkShiftModel({required this.id, @JsonKey(name: 'root_organization_id') required this.rootOrganizationId, required this.name, required  List<WorkShiftPeriodModel> periods}): _periods = periods;
  factory _WorkShiftModel.fromJson(Map<String, dynamic> json) => _$WorkShiftModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'root_organization_id') final  String rootOrganizationId;
@override final  String name;
 final  List<WorkShiftPeriodModel> _periods;
@override List<WorkShiftPeriodModel> get periods {
  if (_periods is EqualUnmodifiableListView) return _periods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_periods);
}


/// Create a copy of WorkShiftModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkShiftModelCopyWith<_WorkShiftModel> get copyWith => __$WorkShiftModelCopyWithImpl<_WorkShiftModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkShiftModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkShiftModel&&(identical(other.id, id) || other.id == id)&&(identical(other.rootOrganizationId, rootOrganizationId) || other.rootOrganizationId == rootOrganizationId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.periods, _periods));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,rootOrganizationId,name,const DeepCollectionEquality().hash(_periods));
}

@override
String toString() {
    return 'WorkShiftModel(id: $id, rootOrganizationId: $rootOrganizationId, name: $name, periods: $periods)';
}


}

/// @nodoc
abstract mixin class _$WorkShiftModelCopyWith<$Res> implements $WorkShiftModelCopyWith<$Res> {
  factory _$WorkShiftModelCopyWith(_WorkShiftModel value, $Res Function(_WorkShiftModel) _then) = __$WorkShiftModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'root_organization_id') String rootOrganizationId, String name, List<WorkShiftPeriodModel> periods
});




}
/// @nodoc
class __$WorkShiftModelCopyWithImpl<$Res>
    implements _$WorkShiftModelCopyWith<$Res> {
  __$WorkShiftModelCopyWithImpl(this._self, this._then);

  final _WorkShiftModel _self;
  final $Res Function(_WorkShiftModel) _then;

/// Create a copy of WorkShiftModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rootOrganizationId = null,Object? name = null,Object? periods = null,}) {
  return _then(_WorkShiftModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rootOrganizationId: null == rootOrganizationId ? _self.rootOrganizationId : rootOrganizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,periods: null == periods ? _self._periods : periods // ignore: cast_nullable_to_non_nullable
as List<WorkShiftPeriodModel>,
  ));
}


}


/// @nodoc
mixin _$AssignedWorkPeriodModel {

@JsonKey(name: 'start_at') String get startAt;@JsonKey(name: 'end_at') String get endAt;
/// Create a copy of AssignedWorkPeriodModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedWorkPeriodModelCopyWith<AssignedWorkPeriodModel> get copyWith => _$AssignedWorkPeriodModelCopyWithImpl<AssignedWorkPeriodModel>(this as AssignedWorkPeriodModel, _$identity);

  /// Serializes this AssignedWorkPeriodModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AssignedWorkPeriodModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedWorkPeriodModel&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AssignedWorkPeriodModel;
  return Object.hash(runtimeType,_this.startAt,_this.endAt);
}

@override
String toString() {
  final _this = this as AssignedWorkPeriodModel;
  return 'AssignedWorkPeriodModel(startAt: ${_this.startAt}, endAt: ${_this.endAt})';
}


}

/// @nodoc
abstract mixin class $AssignedWorkPeriodModelCopyWith<$Res>  {
  factory $AssignedWorkPeriodModelCopyWith(AssignedWorkPeriodModel value, $Res Function(AssignedWorkPeriodModel) _then) = _$AssignedWorkPeriodModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'start_at') String startAt,@JsonKey(name: 'end_at') String endAt
});




}
/// @nodoc
class _$AssignedWorkPeriodModelCopyWithImpl<$Res>
    implements $AssignedWorkPeriodModelCopyWith<$Res> {
  _$AssignedWorkPeriodModelCopyWithImpl(this._self, this._then);

  final AssignedWorkPeriodModel _self;
  final $Res Function(AssignedWorkPeriodModel) _then;

/// Create a copy of AssignedWorkPeriodModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startAt = null,Object? endAt = null,}) {
  return _then(AssignedWorkPeriodModel(
startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignedWorkPeriodModel].
extension AssignedWorkPeriodModelPatterns on AssignedWorkPeriodModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignedWorkPeriodModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignedWorkPeriodModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignedWorkPeriodModel value)  $default,){
final _that = this;
switch (_that) {
case _AssignedWorkPeriodModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignedWorkPeriodModel value)?  $default,){
final _that = this;
switch (_that) {
case _AssignedWorkPeriodModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignedWorkPeriodModel() when $default != null:
return $default(_that.startAt,_that.endAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt)  $default,) {final _that = this;
switch (_that) {
case _AssignedWorkPeriodModel():
return $default(_that.startAt,_that.endAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt)?  $default,) {final _that = this;
switch (_that) {
case _AssignedWorkPeriodModel() when $default != null:
return $default(_that.startAt,_that.endAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _AssignedWorkPeriodModel implements AssignedWorkPeriodModel {
  const _AssignedWorkPeriodModel({@JsonKey(name: 'start_at') required this.startAt, @JsonKey(name: 'end_at') required this.endAt});
  factory _AssignedWorkPeriodModel.fromJson(Map<String, dynamic> json) => _$AssignedWorkPeriodModelFromJson(json);

@override@JsonKey(name: 'start_at') final  String startAt;
@override@JsonKey(name: 'end_at') final  String endAt;

/// Create a copy of AssignedWorkPeriodModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignedWorkPeriodModelCopyWith<_AssignedWorkPeriodModel> get copyWith => __$AssignedWorkPeriodModelCopyWithImpl<_AssignedWorkPeriodModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedWorkPeriodModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignedWorkPeriodModel&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,startAt,endAt);
}

@override
String toString() {
    return 'AssignedWorkPeriodModel(startAt: $startAt, endAt: $endAt)';
}


}

/// @nodoc
abstract mixin class _$AssignedWorkPeriodModelCopyWith<$Res> implements $AssignedWorkPeriodModelCopyWith<$Res> {
  factory _$AssignedWorkPeriodModelCopyWith(_AssignedWorkPeriodModel value, $Res Function(_AssignedWorkPeriodModel) _then) = __$AssignedWorkPeriodModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'start_at') String startAt,@JsonKey(name: 'end_at') String endAt
});




}
/// @nodoc
class __$AssignedWorkPeriodModelCopyWithImpl<$Res>
    implements _$AssignedWorkPeriodModelCopyWith<$Res> {
  __$AssignedWorkPeriodModelCopyWithImpl(this._self, this._then);

  final _AssignedWorkPeriodModel _self;
  final $Res Function(_AssignedWorkPeriodModel) _then;

/// Create a copy of AssignedWorkPeriodModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startAt = null,Object? endAt = null,}) {
  return _then(_AssignedWorkPeriodModel(
startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LeaveCoverageItemModel {

 String get date; String get status;@JsonKey(name: 'work_shift_id') String? get workShiftId; double get hours; double get days; String get note;
/// Create a copy of LeaveCoverageItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveCoverageItemModelCopyWith<LeaveCoverageItemModel> get copyWith => _$LeaveCoverageItemModelCopyWithImpl<LeaveCoverageItemModel>(this as LeaveCoverageItemModel, _$identity);

  /// Serializes this LeaveCoverageItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LeaveCoverageItemModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveCoverageItemModel&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.workShiftId, _this.workShiftId) || other.workShiftId == _this.workShiftId)&&(identical(other.hours, _this.hours) || other.hours == _this.hours)&&(identical(other.days, _this.days) || other.days == _this.days)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LeaveCoverageItemModel;
  return Object.hash(runtimeType,_this.date,_this.status,_this.workShiftId,_this.hours,_this.days,_this.note);
}

@override
String toString() {
  final _this = this as LeaveCoverageItemModel;
  return 'LeaveCoverageItemModel(date: ${_this.date}, status: ${_this.status}, workShiftId: ${_this.workShiftId}, hours: ${_this.hours}, days: ${_this.days}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $LeaveCoverageItemModelCopyWith<$Res>  {
  factory $LeaveCoverageItemModelCopyWith(LeaveCoverageItemModel value, $Res Function(LeaveCoverageItemModel) _then) = _$LeaveCoverageItemModelCopyWithImpl;
@useResult
$Res call({
 String date, String status,@JsonKey(name: 'work_shift_id') String? workShiftId, double hours, double days, String note
});




}
/// @nodoc
class _$LeaveCoverageItemModelCopyWithImpl<$Res>
    implements $LeaveCoverageItemModelCopyWith<$Res> {
  _$LeaveCoverageItemModelCopyWithImpl(this._self, this._then);

  final LeaveCoverageItemModel _self;
  final $Res Function(LeaveCoverageItemModel) _then;

/// Create a copy of LeaveCoverageItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? status = null,Object? workShiftId = freezed,Object? hours = null,Object? days = null,Object? note = null,}) {
  return _then(LeaveCoverageItemModel(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,workShiftId: freezed == workShiftId ? _self.workShiftId : workShiftId // ignore: cast_nullable_to_non_nullable
as String?,hours: null == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as double,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as double,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveCoverageItemModel].
extension LeaveCoverageItemModelPatterns on LeaveCoverageItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveCoverageItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveCoverageItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveCoverageItemModel value)  $default,){
final _that = this;
switch (_that) {
case _LeaveCoverageItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveCoverageItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveCoverageItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String status, @JsonKey(name: 'work_shift_id')  String? workShiftId,  double hours,  double days,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveCoverageItemModel() when $default != null:
return $default(_that.date,_that.status,_that.workShiftId,_that.hours,_that.days,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String status, @JsonKey(name: 'work_shift_id')  String? workShiftId,  double hours,  double days,  String note)  $default,) {final _that = this;
switch (_that) {
case _LeaveCoverageItemModel():
return $default(_that.date,_that.status,_that.workShiftId,_that.hours,_that.days,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String status, @JsonKey(name: 'work_shift_id')  String? workShiftId,  double hours,  double days,  String note)?  $default,) {final _that = this;
switch (_that) {
case _LeaveCoverageItemModel() when $default != null:
return $default(_that.date,_that.status,_that.workShiftId,_that.hours,_that.days,_that.note);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _LeaveCoverageItemModel implements LeaveCoverageItemModel {
  const _LeaveCoverageItemModel({required this.date, required this.status, @JsonKey(name: 'work_shift_id') this.workShiftId, required this.hours, required this.days, required this.note});
  factory _LeaveCoverageItemModel.fromJson(Map<String, dynamic> json) => _$LeaveCoverageItemModelFromJson(json);

@override final  String date;
@override final  String status;
@override@JsonKey(name: 'work_shift_id') final  String? workShiftId;
@override final  double hours;
@override final  double days;
@override final  String note;

/// Create a copy of LeaveCoverageItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveCoverageItemModelCopyWith<_LeaveCoverageItemModel> get copyWith => __$LeaveCoverageItemModelCopyWithImpl<_LeaveCoverageItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveCoverageItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveCoverageItemModel&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.workShiftId, workShiftId) || other.workShiftId == workShiftId)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.days, days) || other.days == days)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,status,workShiftId,hours,days,note);
}

@override
String toString() {
    return 'LeaveCoverageItemModel(date: $date, status: $status, workShiftId: $workShiftId, hours: $hours, days: $days, note: $note)';
}


}

/// @nodoc
abstract mixin class _$LeaveCoverageItemModelCopyWith<$Res> implements $LeaveCoverageItemModelCopyWith<$Res> {
  factory _$LeaveCoverageItemModelCopyWith(_LeaveCoverageItemModel value, $Res Function(_LeaveCoverageItemModel) _then) = __$LeaveCoverageItemModelCopyWithImpl;
@override @useResult
$Res call({
 String date, String status,@JsonKey(name: 'work_shift_id') String? workShiftId, double hours, double days, String note
});




}
/// @nodoc
class __$LeaveCoverageItemModelCopyWithImpl<$Res>
    implements _$LeaveCoverageItemModelCopyWith<$Res> {
  __$LeaveCoverageItemModelCopyWithImpl(this._self, this._then);

  final _LeaveCoverageItemModel _self;
  final $Res Function(_LeaveCoverageItemModel) _then;

/// Create a copy of LeaveCoverageItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? status = null,Object? workShiftId = freezed,Object? hours = null,Object? days = null,Object? note = null,}) {
  return _then(_LeaveCoverageItemModel(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,workShiftId: freezed == workShiftId ? _self.workShiftId : workShiftId // ignore: cast_nullable_to_non_nullable
as String?,hours: null == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as double,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as double,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LeaveCoveragePreviewModel {

@JsonKey(name: 'total_days') double get totalDays;@JsonKey(name: 'working_days') double get workingDays;@JsonKey(name: 'holiday_days') int get holidayDays;@JsonKey(name: 'off_days') int get offDays; List<LeaveCoverageItemModel> get items;
/// Create a copy of LeaveCoveragePreviewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveCoveragePreviewModelCopyWith<LeaveCoveragePreviewModel> get copyWith => _$LeaveCoveragePreviewModelCopyWithImpl<LeaveCoveragePreviewModel>(this as LeaveCoveragePreviewModel, _$identity);

  /// Serializes this LeaveCoveragePreviewModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LeaveCoveragePreviewModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveCoveragePreviewModel&&(identical(other.totalDays, _this.totalDays) || other.totalDays == _this.totalDays)&&(identical(other.workingDays, _this.workingDays) || other.workingDays == _this.workingDays)&&(identical(other.holidayDays, _this.holidayDays) || other.holidayDays == _this.holidayDays)&&(identical(other.offDays, _this.offDays) || other.offDays == _this.offDays)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LeaveCoveragePreviewModel;
  return Object.hash(runtimeType,_this.totalDays,_this.workingDays,_this.holidayDays,_this.offDays,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as LeaveCoveragePreviewModel;
  return 'LeaveCoveragePreviewModel(totalDays: ${_this.totalDays}, workingDays: ${_this.workingDays}, holidayDays: ${_this.holidayDays}, offDays: ${_this.offDays}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $LeaveCoveragePreviewModelCopyWith<$Res>  {
  factory $LeaveCoveragePreviewModelCopyWith(LeaveCoveragePreviewModel value, $Res Function(LeaveCoveragePreviewModel) _then) = _$LeaveCoveragePreviewModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_days') double totalDays,@JsonKey(name: 'working_days') double workingDays,@JsonKey(name: 'holiday_days') int holidayDays,@JsonKey(name: 'off_days') int offDays, List<LeaveCoverageItemModel> items
});




}
/// @nodoc
class _$LeaveCoveragePreviewModelCopyWithImpl<$Res>
    implements $LeaveCoveragePreviewModelCopyWith<$Res> {
  _$LeaveCoveragePreviewModelCopyWithImpl(this._self, this._then);

  final LeaveCoveragePreviewModel _self;
  final $Res Function(LeaveCoveragePreviewModel) _then;

/// Create a copy of LeaveCoveragePreviewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalDays = null,Object? workingDays = null,Object? holidayDays = null,Object? offDays = null,Object? items = null,}) {
  return _then(LeaveCoveragePreviewModel(
totalDays: null == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as double,workingDays: null == workingDays ? _self.workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as double,holidayDays: null == holidayDays ? _self.holidayDays : holidayDays // ignore: cast_nullable_to_non_nullable
as int,offDays: null == offDays ? _self.offDays : offDays // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<LeaveCoverageItemModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveCoveragePreviewModel].
extension LeaveCoveragePreviewModelPatterns on LeaveCoveragePreviewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveCoveragePreviewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveCoveragePreviewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveCoveragePreviewModel value)  $default,){
final _that = this;
switch (_that) {
case _LeaveCoveragePreviewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveCoveragePreviewModel value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveCoveragePreviewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_days')  double totalDays, @JsonKey(name: 'working_days')  double workingDays, @JsonKey(name: 'holiday_days')  int holidayDays, @JsonKey(name: 'off_days')  int offDays,  List<LeaveCoverageItemModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveCoveragePreviewModel() when $default != null:
return $default(_that.totalDays,_that.workingDays,_that.holidayDays,_that.offDays,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_days')  double totalDays, @JsonKey(name: 'working_days')  double workingDays, @JsonKey(name: 'holiday_days')  int holidayDays, @JsonKey(name: 'off_days')  int offDays,  List<LeaveCoverageItemModel> items)  $default,) {final _that = this;
switch (_that) {
case _LeaveCoveragePreviewModel():
return $default(_that.totalDays,_that.workingDays,_that.holidayDays,_that.offDays,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_days')  double totalDays, @JsonKey(name: 'working_days')  double workingDays, @JsonKey(name: 'holiday_days')  int holidayDays, @JsonKey(name: 'off_days')  int offDays,  List<LeaveCoverageItemModel> items)?  $default,) {final _that = this;
switch (_that) {
case _LeaveCoveragePreviewModel() when $default != null:
return $default(_that.totalDays,_that.workingDays,_that.holidayDays,_that.offDays,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _LeaveCoveragePreviewModel implements LeaveCoveragePreviewModel {
  const _LeaveCoveragePreviewModel({@JsonKey(name: 'total_days') required this.totalDays, @JsonKey(name: 'working_days') required this.workingDays, @JsonKey(name: 'holiday_days') required this.holidayDays, @JsonKey(name: 'off_days') required this.offDays, required  List<LeaveCoverageItemModel> items}): _items = items;
  factory _LeaveCoveragePreviewModel.fromJson(Map<String, dynamic> json) => _$LeaveCoveragePreviewModelFromJson(json);

@override@JsonKey(name: 'total_days') final  double totalDays;
@override@JsonKey(name: 'working_days') final  double workingDays;
@override@JsonKey(name: 'holiday_days') final  int holidayDays;
@override@JsonKey(name: 'off_days') final  int offDays;
 final  List<LeaveCoverageItemModel> _items;
@override List<LeaveCoverageItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of LeaveCoveragePreviewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveCoveragePreviewModelCopyWith<_LeaveCoveragePreviewModel> get copyWith => __$LeaveCoveragePreviewModelCopyWithImpl<_LeaveCoveragePreviewModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveCoveragePreviewModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveCoveragePreviewModel&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.workingDays, workingDays) || other.workingDays == workingDays)&&(identical(other.holidayDays, holidayDays) || other.holidayDays == holidayDays)&&(identical(other.offDays, offDays) || other.offDays == offDays)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,totalDays,workingDays,holidayDays,offDays,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'LeaveCoveragePreviewModel(totalDays: $totalDays, workingDays: $workingDays, holidayDays: $holidayDays, offDays: $offDays, items: $items)';
}


}

/// @nodoc
abstract mixin class _$LeaveCoveragePreviewModelCopyWith<$Res> implements $LeaveCoveragePreviewModelCopyWith<$Res> {
  factory _$LeaveCoveragePreviewModelCopyWith(_LeaveCoveragePreviewModel value, $Res Function(_LeaveCoveragePreviewModel) _then) = __$LeaveCoveragePreviewModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_days') double totalDays,@JsonKey(name: 'working_days') double workingDays,@JsonKey(name: 'holiday_days') int holidayDays,@JsonKey(name: 'off_days') int offDays, List<LeaveCoverageItemModel> items
});




}
/// @nodoc
class __$LeaveCoveragePreviewModelCopyWithImpl<$Res>
    implements _$LeaveCoveragePreviewModelCopyWith<$Res> {
  __$LeaveCoveragePreviewModelCopyWithImpl(this._self, this._then);

  final _LeaveCoveragePreviewModel _self;
  final $Res Function(_LeaveCoveragePreviewModel) _then;

/// Create a copy of LeaveCoveragePreviewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalDays = null,Object? workingDays = null,Object? holidayDays = null,Object? offDays = null,Object? items = null,}) {
  return _then(_LeaveCoveragePreviewModel(
totalDays: null == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as double,workingDays: null == workingDays ? _self.workingDays : workingDays // ignore: cast_nullable_to_non_nullable
as double,holidayDays: null == holidayDays ? _self.holidayDays : holidayDays // ignore: cast_nullable_to_non_nullable
as int,offDays: null == offDays ? _self.offDays : offDays // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<LeaveCoverageItemModel>,
  ));
}


}


/// @nodoc
mixin _$WorkUserShiftModel {

 String get id;@JsonKey(name: 'root_organization_id') String get rootOrganizationId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'work_shift_id') String get workShiftId;@JsonKey(name: 'work_date') String get workDate;@JsonKey(name: 'start_at') String get startAt;@JsonKey(name: 'end_at') String get endAt;@JsonKey(name: 'work_shift') WorkShiftModel get workShift;@JsonKey(name: 'work_periods') List<AssignedWorkPeriodModel> get workPeriods;
/// Create a copy of WorkUserShiftModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkUserShiftModelCopyWith<WorkUserShiftModel> get copyWith => _$WorkUserShiftModelCopyWithImpl<WorkUserShiftModel>(this as WorkUserShiftModel, _$identity);

  /// Serializes this WorkUserShiftModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkUserShiftModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkUserShiftModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.rootOrganizationId, _this.rootOrganizationId) || other.rootOrganizationId == _this.rootOrganizationId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.workShiftId, _this.workShiftId) || other.workShiftId == _this.workShiftId)&&(identical(other.workDate, _this.workDate) || other.workDate == _this.workDate)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.workShift, _this.workShift) || other.workShift == _this.workShift)&&const DeepCollectionEquality().equals(other.workPeriods, _this.workPeriods));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkUserShiftModel;
  return Object.hash(runtimeType,_this.id,_this.rootOrganizationId,_this.userId,_this.workShiftId,_this.workDate,_this.startAt,_this.endAt,_this.workShift,const DeepCollectionEquality().hash(_this.workPeriods));
}

@override
String toString() {
  final _this = this as WorkUserShiftModel;
  return 'WorkUserShiftModel(id: ${_this.id}, rootOrganizationId: ${_this.rootOrganizationId}, userId: ${_this.userId}, workShiftId: ${_this.workShiftId}, workDate: ${_this.workDate}, startAt: ${_this.startAt}, endAt: ${_this.endAt}, workShift: ${_this.workShift}, workPeriods: ${_this.workPeriods})';
}


}

/// @nodoc
abstract mixin class $WorkUserShiftModelCopyWith<$Res>  {
  factory $WorkUserShiftModelCopyWith(WorkUserShiftModel value, $Res Function(WorkUserShiftModel) _then) = _$WorkUserShiftModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'root_organization_id') String rootOrganizationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'work_shift_id') String workShiftId,@JsonKey(name: 'work_date') String workDate,@JsonKey(name: 'start_at') String startAt,@JsonKey(name: 'end_at') String endAt,@JsonKey(name: 'work_shift') WorkShiftModel workShift,@JsonKey(name: 'work_periods') List<AssignedWorkPeriodModel> workPeriods
});


$WorkShiftModelCopyWith<$Res> get workShift;

}
/// @nodoc
class _$WorkUserShiftModelCopyWithImpl<$Res>
    implements $WorkUserShiftModelCopyWith<$Res> {
  _$WorkUserShiftModelCopyWithImpl(this._self, this._then);

  final WorkUserShiftModel _self;
  final $Res Function(WorkUserShiftModel) _then;

/// Create a copy of WorkUserShiftModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rootOrganizationId = null,Object? userId = null,Object? workShiftId = null,Object? workDate = null,Object? startAt = null,Object? endAt = null,Object? workShift = null,Object? workPeriods = null,}) {
  return _then(WorkUserShiftModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rootOrganizationId: null == rootOrganizationId ? _self.rootOrganizationId : rootOrganizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,workShiftId: null == workShiftId ? _self.workShiftId : workShiftId // ignore: cast_nullable_to_non_nullable
as String,workDate: null == workDate ? _self.workDate : workDate // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,workShift: null == workShift ? _self.workShift : workShift // ignore: cast_nullable_to_non_nullable
as WorkShiftModel,workPeriods: null == workPeriods ? _self.workPeriods : workPeriods // ignore: cast_nullable_to_non_nullable
as List<AssignedWorkPeriodModel>,
  ));
}
/// Create a copy of WorkUserShiftModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkShiftModelCopyWith<$Res> get workShift {
  
  return $WorkShiftModelCopyWith<$Res>(_self.workShift, (value) {
    return _then(_self.copyWith(workShift: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkUserShiftModel].
extension WorkUserShiftModelPatterns on WorkUserShiftModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkUserShiftModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkUserShiftModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkUserShiftModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkUserShiftModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkUserShiftModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkUserShiftModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'root_organization_id')  String rootOrganizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'work_shift_id')  String workShiftId, @JsonKey(name: 'work_date')  String workDate, @JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt, @JsonKey(name: 'work_shift')  WorkShiftModel workShift, @JsonKey(name: 'work_periods')  List<AssignedWorkPeriodModel> workPeriods)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkUserShiftModel() when $default != null:
return $default(_that.id,_that.rootOrganizationId,_that.userId,_that.workShiftId,_that.workDate,_that.startAt,_that.endAt,_that.workShift,_that.workPeriods);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'root_organization_id')  String rootOrganizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'work_shift_id')  String workShiftId, @JsonKey(name: 'work_date')  String workDate, @JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt, @JsonKey(name: 'work_shift')  WorkShiftModel workShift, @JsonKey(name: 'work_periods')  List<AssignedWorkPeriodModel> workPeriods)  $default,) {final _that = this;
switch (_that) {
case _WorkUserShiftModel():
return $default(_that.id,_that.rootOrganizationId,_that.userId,_that.workShiftId,_that.workDate,_that.startAt,_that.endAt,_that.workShift,_that.workPeriods);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'root_organization_id')  String rootOrganizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'work_shift_id')  String workShiftId, @JsonKey(name: 'work_date')  String workDate, @JsonKey(name: 'start_at')  String startAt, @JsonKey(name: 'end_at')  String endAt, @JsonKey(name: 'work_shift')  WorkShiftModel workShift, @JsonKey(name: 'work_periods')  List<AssignedWorkPeriodModel> workPeriods)?  $default,) {final _that = this;
switch (_that) {
case _WorkUserShiftModel() when $default != null:
return $default(_that.id,_that.rootOrganizationId,_that.userId,_that.workShiftId,_that.workDate,_that.startAt,_that.endAt,_that.workShift,_that.workPeriods);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _WorkUserShiftModel implements WorkUserShiftModel {
  const _WorkUserShiftModel({required this.id, @JsonKey(name: 'root_organization_id') required this.rootOrganizationId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'work_shift_id') required this.workShiftId, @JsonKey(name: 'work_date') required this.workDate, @JsonKey(name: 'start_at') required this.startAt, @JsonKey(name: 'end_at') required this.endAt, @JsonKey(name: 'work_shift') required this.workShift, @JsonKey(name: 'work_periods') required  List<AssignedWorkPeriodModel> workPeriods}): _workPeriods = workPeriods;
  factory _WorkUserShiftModel.fromJson(Map<String, dynamic> json) => _$WorkUserShiftModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'root_organization_id') final  String rootOrganizationId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'work_shift_id') final  String workShiftId;
@override@JsonKey(name: 'work_date') final  String workDate;
@override@JsonKey(name: 'start_at') final  String startAt;
@override@JsonKey(name: 'end_at') final  String endAt;
@override@JsonKey(name: 'work_shift') final  WorkShiftModel workShift;
 final  List<AssignedWorkPeriodModel> _workPeriods;
@override@JsonKey(name: 'work_periods') List<AssignedWorkPeriodModel> get workPeriods {
  if (_workPeriods is EqualUnmodifiableListView) return _workPeriods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workPeriods);
}


/// Create a copy of WorkUserShiftModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkUserShiftModelCopyWith<_WorkUserShiftModel> get copyWith => __$WorkUserShiftModelCopyWithImpl<_WorkUserShiftModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkUserShiftModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkUserShiftModel&&(identical(other.id, id) || other.id == id)&&(identical(other.rootOrganizationId, rootOrganizationId) || other.rootOrganizationId == rootOrganizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.workShiftId, workShiftId) || other.workShiftId == workShiftId)&&(identical(other.workDate, workDate) || other.workDate == workDate)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.workShift, workShift) || other.workShift == workShift)&&const DeepCollectionEquality().equals(other.workPeriods, _workPeriods));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,rootOrganizationId,userId,workShiftId,workDate,startAt,endAt,workShift,const DeepCollectionEquality().hash(_workPeriods));
}

@override
String toString() {
    return 'WorkUserShiftModel(id: $id, rootOrganizationId: $rootOrganizationId, userId: $userId, workShiftId: $workShiftId, workDate: $workDate, startAt: $startAt, endAt: $endAt, workShift: $workShift, workPeriods: $workPeriods)';
}


}

/// @nodoc
abstract mixin class _$WorkUserShiftModelCopyWith<$Res> implements $WorkUserShiftModelCopyWith<$Res> {
  factory _$WorkUserShiftModelCopyWith(_WorkUserShiftModel value, $Res Function(_WorkUserShiftModel) _then) = __$WorkUserShiftModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'root_organization_id') String rootOrganizationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'work_shift_id') String workShiftId,@JsonKey(name: 'work_date') String workDate,@JsonKey(name: 'start_at') String startAt,@JsonKey(name: 'end_at') String endAt,@JsonKey(name: 'work_shift') WorkShiftModel workShift,@JsonKey(name: 'work_periods') List<AssignedWorkPeriodModel> workPeriods
});


@override $WorkShiftModelCopyWith<$Res> get workShift;

}
/// @nodoc
class __$WorkUserShiftModelCopyWithImpl<$Res>
    implements _$WorkUserShiftModelCopyWith<$Res> {
  __$WorkUserShiftModelCopyWithImpl(this._self, this._then);

  final _WorkUserShiftModel _self;
  final $Res Function(_WorkUserShiftModel) _then;

/// Create a copy of WorkUserShiftModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rootOrganizationId = null,Object? userId = null,Object? workShiftId = null,Object? workDate = null,Object? startAt = null,Object? endAt = null,Object? workShift = null,Object? workPeriods = null,}) {
  return _then(_WorkUserShiftModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rootOrganizationId: null == rootOrganizationId ? _self.rootOrganizationId : rootOrganizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,workShiftId: null == workShiftId ? _self.workShiftId : workShiftId // ignore: cast_nullable_to_non_nullable
as String,workDate: null == workDate ? _self.workDate : workDate // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as String,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as String,workShift: null == workShift ? _self.workShift : workShift // ignore: cast_nullable_to_non_nullable
as WorkShiftModel,workPeriods: null == workPeriods ? _self._workPeriods : workPeriods // ignore: cast_nullable_to_non_nullable
as List<AssignedWorkPeriodModel>,
  ));
}

/// Create a copy of WorkUserShiftModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkShiftModelCopyWith<$Res> get workShift {
  
  return $WorkShiftModelCopyWith<$Res>(_self.workShift, (value) {
    return _then(_self.copyWith(workShift: value));
  });
}
}

// dart format on

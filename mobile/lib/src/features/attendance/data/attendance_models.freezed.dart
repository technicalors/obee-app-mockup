// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceLocationIp {

 String get id;@JsonKey(name: 'ip_address') String get ipAddress;@JsonKey(name: 'attendance_location_id', required: true) String get attendanceLocationId;@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String get createdAt;@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String get updatedAt;
/// Create a copy of AttendanceLocationIp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceLocationIpCopyWith<AttendanceLocationIp> get copyWith => _$AttendanceLocationIpCopyWithImpl<AttendanceLocationIp>(this as AttendanceLocationIp, _$identity);

  /// Serializes this AttendanceLocationIp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceLocationIp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceLocationIp&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.ipAddress, _this.ipAddress) || other.ipAddress == _this.ipAddress)&&(identical(other.attendanceLocationId, _this.attendanceLocationId) || other.attendanceLocationId == _this.attendanceLocationId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceLocationIp;
  return Object.hash(runtimeType,_this.id,_this.ipAddress,_this.attendanceLocationId,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as AttendanceLocationIp;
  return 'AttendanceLocationIp(id: ${_this.id}, ipAddress: ${_this.ipAddress}, attendanceLocationId: ${_this.attendanceLocationId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $AttendanceLocationIpCopyWith<$Res>  {
  factory $AttendanceLocationIpCopyWith(AttendanceLocationIp value, $Res Function(AttendanceLocationIp) _then) = _$AttendanceLocationIpCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'ip_address') String ipAddress,@JsonKey(name: 'attendance_location_id', required: true) String attendanceLocationId,@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String createdAt,@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String updatedAt
});




}
/// @nodoc
class _$AttendanceLocationIpCopyWithImpl<$Res>
    implements $AttendanceLocationIpCopyWith<$Res> {
  _$AttendanceLocationIpCopyWithImpl(this._self, this._then);

  final AttendanceLocationIp _self;
  final $Res Function(AttendanceLocationIp) _then;

/// Create a copy of AttendanceLocationIp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ipAddress = null,Object? attendanceLocationId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(AttendanceLocationIp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,attendanceLocationId: null == attendanceLocationId ? _self.attendanceLocationId : attendanceLocationId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceLocationIp].
extension AttendanceLocationIpPatterns on AttendanceLocationIp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceLocationIp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceLocationIp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceLocationIp value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceLocationIp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceLocationIp value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceLocationIp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'ip_address')  String ipAddress, @JsonKey(name: 'attendance_location_id', required: true)  String attendanceLocationId, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceLocationIp() when $default != null:
return $default(_that.id,_that.ipAddress,_that.attendanceLocationId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'ip_address')  String ipAddress, @JsonKey(name: 'attendance_location_id', required: true)  String attendanceLocationId, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceLocationIp():
return $default(_that.id,_that.ipAddress,_that.attendanceLocationId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'ip_address')  String ipAddress, @JsonKey(name: 'attendance_location_id', required: true)  String attendanceLocationId, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceLocationIp() when $default != null:
return $default(_that.id,_that.ipAddress,_that.attendanceLocationId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AttendanceLocationIp implements AttendanceLocationIp {
  const _AttendanceLocationIp({required this.id, @JsonKey(name: 'ip_address') required this.ipAddress, @JsonKey(name: 'attendance_location_id', required: true) required this.attendanceLocationId, @JsonKey(name: 'created_at', required: true, disallowNullValue: true) required this.createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true) required this.updatedAt});
  factory _AttendanceLocationIp.fromJson(Map<String, dynamic> json) => _$AttendanceLocationIpFromJson(json);

@override final  String id;
@override@JsonKey(name: 'ip_address') final  String ipAddress;
@override@JsonKey(name: 'attendance_location_id', required: true) final  String attendanceLocationId;
@override@JsonKey(name: 'created_at', required: true, disallowNullValue: true) final  String createdAt;
@override@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) final  String updatedAt;

/// Create a copy of AttendanceLocationIp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceLocationIpCopyWith<_AttendanceLocationIp> get copyWith => __$AttendanceLocationIpCopyWithImpl<_AttendanceLocationIp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceLocationIpToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceLocationIp&&(identical(other.id, id) || other.id == id)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.attendanceLocationId, attendanceLocationId) || other.attendanceLocationId == attendanceLocationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,ipAddress,attendanceLocationId,createdAt,updatedAt);
}

@override
String toString() {
    return 'AttendanceLocationIp(id: $id, ipAddress: $ipAddress, attendanceLocationId: $attendanceLocationId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceLocationIpCopyWith<$Res> implements $AttendanceLocationIpCopyWith<$Res> {
  factory _$AttendanceLocationIpCopyWith(_AttendanceLocationIp value, $Res Function(_AttendanceLocationIp) _then) = __$AttendanceLocationIpCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'ip_address') String ipAddress,@JsonKey(name: 'attendance_location_id', required: true) String attendanceLocationId,@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String createdAt,@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String updatedAt
});




}
/// @nodoc
class __$AttendanceLocationIpCopyWithImpl<$Res>
    implements _$AttendanceLocationIpCopyWith<$Res> {
  __$AttendanceLocationIpCopyWithImpl(this._self, this._then);

  final _AttendanceLocationIp _self;
  final $Res Function(_AttendanceLocationIp) _then;

/// Create a copy of AttendanceLocationIp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ipAddress = null,Object? attendanceLocationId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AttendanceLocationIp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,attendanceLocationId: null == attendanceLocationId ? _self.attendanceLocationId : attendanceLocationId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AttendanceLocation {

 String get id; String get name; double get latitude; double get longitude;@JsonKey(name: 'radius_meters') double get radiusMeters;@JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) String get validationMode;@JsonKey(required: true, disallowNullValue: true) List<AttendanceLocationIp> get ips;@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String get createdAt;@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String get updatedAt;@JsonKey(required: true, disallowNullValue: true) List<AttendanceUserRef> get users;@JsonKey(required: true, disallowNullValue: true) List<OrganizationRef> get organizations;@JsonKey(name: 'excluded_users', required: true, disallowNullValue: true) List<AttendanceUserRef> get excludedUsers;
/// Create a copy of AttendanceLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceLocationCopyWith<AttendanceLocation> get copyWith => _$AttendanceLocationCopyWithImpl<AttendanceLocation>(this as AttendanceLocation, _$identity);

  /// Serializes this AttendanceLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceLocation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.radiusMeters, _this.radiusMeters) || other.radiusMeters == _this.radiusMeters)&&(identical(other.validationMode, _this.validationMode) || other.validationMode == _this.validationMode)&&const DeepCollectionEquality().equals(other.ips, _this.ips)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.users, _this.users)&&const DeepCollectionEquality().equals(other.organizations, _this.organizations)&&const DeepCollectionEquality().equals(other.excludedUsers, _this.excludedUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceLocation;
  return Object.hash(runtimeType,_this.id,_this.name,_this.latitude,_this.longitude,_this.radiusMeters,_this.validationMode,const DeepCollectionEquality().hash(_this.ips),_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.users),const DeepCollectionEquality().hash(_this.organizations),const DeepCollectionEquality().hash(_this.excludedUsers));
}

@override
String toString() {
  final _this = this as AttendanceLocation;
  return 'AttendanceLocation(id: ${_this.id}, name: ${_this.name}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, radiusMeters: ${_this.radiusMeters}, validationMode: ${_this.validationMode}, ips: ${_this.ips}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, users: ${_this.users}, organizations: ${_this.organizations}, excludedUsers: ${_this.excludedUsers})';
}


}

/// @nodoc
abstract mixin class $AttendanceLocationCopyWith<$Res>  {
  factory $AttendanceLocationCopyWith(AttendanceLocation value, $Res Function(AttendanceLocation) _then) = _$AttendanceLocationCopyWithImpl;
@useResult
$Res call({
 String id, String name, double latitude, double longitude,@JsonKey(name: 'radius_meters') double radiusMeters,@JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) String validationMode,@JsonKey(required: true, disallowNullValue: true) List<AttendanceLocationIp> ips,@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String createdAt,@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String updatedAt,@JsonKey(required: true, disallowNullValue: true) List<AttendanceUserRef> users,@JsonKey(required: true, disallowNullValue: true) List<OrganizationRef> organizations,@JsonKey(name: 'excluded_users', required: true, disallowNullValue: true) List<AttendanceUserRef> excludedUsers
});




}
/// @nodoc
class _$AttendanceLocationCopyWithImpl<$Res>
    implements $AttendanceLocationCopyWith<$Res> {
  _$AttendanceLocationCopyWithImpl(this._self, this._then);

  final AttendanceLocation _self;
  final $Res Function(AttendanceLocation) _then;

/// Create a copy of AttendanceLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? validationMode = null,Object? ips = null,Object? createdAt = null,Object? updatedAt = null,Object? users = null,Object? organizations = null,Object? excludedUsers = null,}) {
  return _then(AttendanceLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as double,validationMode: null == validationMode ? _self.validationMode : validationMode // ignore: cast_nullable_to_non_nullable
as String,ips: null == ips ? _self.ips : ips // ignore: cast_nullable_to_non_nullable
as List<AttendanceLocationIp>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<AttendanceUserRef>,organizations: null == organizations ? _self.organizations : organizations // ignore: cast_nullable_to_non_nullable
as List<OrganizationRef>,excludedUsers: null == excludedUsers ? _self.excludedUsers : excludedUsers // ignore: cast_nullable_to_non_nullable
as List<AttendanceUserRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceLocation].
extension AttendanceLocationPatterns on AttendanceLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceLocation value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceLocation value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude, @JsonKey(name: 'radius_meters')  double radiusMeters, @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson)  String validationMode, @JsonKey(required: true, disallowNullValue: true)  List<AttendanceLocationIp> ips, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt, @JsonKey(required: true, disallowNullValue: true)  List<AttendanceUserRef> users, @JsonKey(required: true, disallowNullValue: true)  List<OrganizationRef> organizations, @JsonKey(name: 'excluded_users', required: true, disallowNullValue: true)  List<AttendanceUserRef> excludedUsers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceLocation() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.radiusMeters,_that.validationMode,_that.ips,_that.createdAt,_that.updatedAt,_that.users,_that.organizations,_that.excludedUsers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude, @JsonKey(name: 'radius_meters')  double radiusMeters, @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson)  String validationMode, @JsonKey(required: true, disallowNullValue: true)  List<AttendanceLocationIp> ips, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt, @JsonKey(required: true, disallowNullValue: true)  List<AttendanceUserRef> users, @JsonKey(required: true, disallowNullValue: true)  List<OrganizationRef> organizations, @JsonKey(name: 'excluded_users', required: true, disallowNullValue: true)  List<AttendanceUserRef> excludedUsers)  $default,) {final _that = this;
switch (_that) {
case _AttendanceLocation():
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.radiusMeters,_that.validationMode,_that.ips,_that.createdAt,_that.updatedAt,_that.users,_that.organizations,_that.excludedUsers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double latitude,  double longitude, @JsonKey(name: 'radius_meters')  double radiusMeters, @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson)  String validationMode, @JsonKey(required: true, disallowNullValue: true)  List<AttendanceLocationIp> ips, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt, @JsonKey(required: true, disallowNullValue: true)  List<AttendanceUserRef> users, @JsonKey(required: true, disallowNullValue: true)  List<OrganizationRef> organizations, @JsonKey(name: 'excluded_users', required: true, disallowNullValue: true)  List<AttendanceUserRef> excludedUsers)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceLocation() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.radiusMeters,_that.validationMode,_that.ips,_that.createdAt,_that.updatedAt,_that.users,_that.organizations,_that.excludedUsers);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AttendanceLocation implements AttendanceLocation {
  const _AttendanceLocation({required this.id, required this.name, required this.latitude, required this.longitude, @JsonKey(name: 'radius_meters') required this.radiusMeters, @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) required this.validationMode, @JsonKey(required: true, disallowNullValue: true)  List<AttendanceLocationIp> ips = const <AttendanceLocationIp>[], @JsonKey(name: 'created_at', required: true, disallowNullValue: true) required this.createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true) required this.updatedAt, @JsonKey(required: true, disallowNullValue: true)  List<AttendanceUserRef> users = const <AttendanceUserRef>[], @JsonKey(required: true, disallowNullValue: true)  List<OrganizationRef> organizations = const <OrganizationRef>[], @JsonKey(name: 'excluded_users', required: true, disallowNullValue: true)  List<AttendanceUserRef> excludedUsers = const <AttendanceUserRef>[]}): _ips = ips,_users = users,_organizations = organizations,_excludedUsers = excludedUsers;
  factory _AttendanceLocation.fromJson(Map<String, dynamic> json) => _$AttendanceLocationFromJson(json);

@override final  String id;
@override final  String name;
@override final  double latitude;
@override final  double longitude;
@override@JsonKey(name: 'radius_meters') final  double radiusMeters;
@override@JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) final  String validationMode;
 final  List<AttendanceLocationIp> _ips;
@override@JsonKey(required: true, disallowNullValue: true) List<AttendanceLocationIp> get ips {
  if (_ips is EqualUnmodifiableListView) return _ips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ips);
}

@override@JsonKey(name: 'created_at', required: true, disallowNullValue: true) final  String createdAt;
@override@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) final  String updatedAt;
 final  List<AttendanceUserRef> _users;
@override@JsonKey(required: true, disallowNullValue: true) List<AttendanceUserRef> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}

 final  List<OrganizationRef> _organizations;
@override@JsonKey(required: true, disallowNullValue: true) List<OrganizationRef> get organizations {
  if (_organizations is EqualUnmodifiableListView) return _organizations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_organizations);
}

 final  List<AttendanceUserRef> _excludedUsers;
@override@JsonKey(name: 'excluded_users', required: true, disallowNullValue: true) List<AttendanceUserRef> get excludedUsers {
  if (_excludedUsers is EqualUnmodifiableListView) return _excludedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludedUsers);
}


/// Create a copy of AttendanceLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceLocationCopyWith<_AttendanceLocation> get copyWith => __$AttendanceLocationCopyWithImpl<_AttendanceLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceLocationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radiusMeters, radiusMeters) || other.radiusMeters == radiusMeters)&&(identical(other.validationMode, validationMode) || other.validationMode == validationMode)&&const DeepCollectionEquality().equals(other.ips, _ips)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.users, _users)&&const DeepCollectionEquality().equals(other.organizations, _organizations)&&const DeepCollectionEquality().equals(other.excludedUsers, _excludedUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,latitude,longitude,radiusMeters,validationMode,const DeepCollectionEquality().hash(_ips),createdAt,updatedAt,const DeepCollectionEquality().hash(_users),const DeepCollectionEquality().hash(_organizations),const DeepCollectionEquality().hash(_excludedUsers));
}

@override
String toString() {
    return 'AttendanceLocation(id: $id, name: $name, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, validationMode: $validationMode, ips: $ips, createdAt: $createdAt, updatedAt: $updatedAt, users: $users, organizations: $organizations, excludedUsers: $excludedUsers)';
}


}

/// @nodoc
abstract mixin class _$AttendanceLocationCopyWith<$Res> implements $AttendanceLocationCopyWith<$Res> {
  factory _$AttendanceLocationCopyWith(_AttendanceLocation value, $Res Function(_AttendanceLocation) _then) = __$AttendanceLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double latitude, double longitude,@JsonKey(name: 'radius_meters') double radiusMeters,@JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) String validationMode,@JsonKey(required: true, disallowNullValue: true) List<AttendanceLocationIp> ips,@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String createdAt,@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String updatedAt,@JsonKey(required: true, disallowNullValue: true) List<AttendanceUserRef> users,@JsonKey(required: true, disallowNullValue: true) List<OrganizationRef> organizations,@JsonKey(name: 'excluded_users', required: true, disallowNullValue: true) List<AttendanceUserRef> excludedUsers
});




}
/// @nodoc
class __$AttendanceLocationCopyWithImpl<$Res>
    implements _$AttendanceLocationCopyWith<$Res> {
  __$AttendanceLocationCopyWithImpl(this._self, this._then);

  final _AttendanceLocation _self;
  final $Res Function(_AttendanceLocation) _then;

/// Create a copy of AttendanceLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? validationMode = null,Object? ips = null,Object? createdAt = null,Object? updatedAt = null,Object? users = null,Object? organizations = null,Object? excludedUsers = null,}) {
  return _then(_AttendanceLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as double,validationMode: null == validationMode ? _self.validationMode : validationMode // ignore: cast_nullable_to_non_nullable
as String,ips: null == ips ? _self._ips : ips // ignore: cast_nullable_to_non_nullable
as List<AttendanceLocationIp>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<AttendanceUserRef>,organizations: null == organizations ? _self._organizations : organizations // ignore: cast_nullable_to_non_nullable
as List<OrganizationRef>,excludedUsers: null == excludedUsers ? _self._excludedUsers : excludedUsers // ignore: cast_nullable_to_non_nullable
as List<AttendanceUserRef>,
  ));
}


}


/// @nodoc
mixin _$AttendanceContext {

@JsonKey(name: 'ip_address') String? get ipAddress;@JsonKey(name: 'assigned_locations') List<AttendanceLocation> get assignedLocations;@JsonKey(name: 'has_shift_today', required: true, disallowNullValue: true) bool get hasShiftToday;@JsonKey(name: 'shift_start_at') String? get shiftStartAt;@JsonKey(name: 'shift_end_at') String? get shiftEndAt;@JsonKey(required: true, disallowNullValue: true) AttendanceUserRef get user;
/// Create a copy of AttendanceContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceContextCopyWith<AttendanceContext> get copyWith => _$AttendanceContextCopyWithImpl<AttendanceContext>(this as AttendanceContext, _$identity);

  /// Serializes this AttendanceContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceContext;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceContext&&(identical(other.ipAddress, _this.ipAddress) || other.ipAddress == _this.ipAddress)&&const DeepCollectionEquality().equals(other.assignedLocations, _this.assignedLocations)&&(identical(other.hasShiftToday, _this.hasShiftToday) || other.hasShiftToday == _this.hasShiftToday)&&(identical(other.shiftStartAt, _this.shiftStartAt) || other.shiftStartAt == _this.shiftStartAt)&&(identical(other.shiftEndAt, _this.shiftEndAt) || other.shiftEndAt == _this.shiftEndAt)&&(identical(other.user, _this.user) || other.user == _this.user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceContext;
  return Object.hash(runtimeType,_this.ipAddress,const DeepCollectionEquality().hash(_this.assignedLocations),_this.hasShiftToday,_this.shiftStartAt,_this.shiftEndAt,_this.user);
}

@override
String toString() {
  final _this = this as AttendanceContext;
  return 'AttendanceContext(ipAddress: ${_this.ipAddress}, assignedLocations: ${_this.assignedLocations}, hasShiftToday: ${_this.hasShiftToday}, shiftStartAt: ${_this.shiftStartAt}, shiftEndAt: ${_this.shiftEndAt}, user: ${_this.user})';
}


}

/// @nodoc
abstract mixin class $AttendanceContextCopyWith<$Res>  {
  factory $AttendanceContextCopyWith(AttendanceContext value, $Res Function(AttendanceContext) _then) = _$AttendanceContextCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'ip_address') String? ipAddress,@JsonKey(name: 'assigned_locations') List<AttendanceLocation> assignedLocations,@JsonKey(name: 'has_shift_today', required: true, disallowNullValue: true) bool hasShiftToday,@JsonKey(name: 'shift_start_at') String? shiftStartAt,@JsonKey(name: 'shift_end_at') String? shiftEndAt,@JsonKey(required: true, disallowNullValue: true) AttendanceUserRef user
});


$AttendanceUserRefCopyWith<$Res> get user;

}
/// @nodoc
class _$AttendanceContextCopyWithImpl<$Res>
    implements $AttendanceContextCopyWith<$Res> {
  _$AttendanceContextCopyWithImpl(this._self, this._then);

  final AttendanceContext _self;
  final $Res Function(AttendanceContext) _then;

/// Create a copy of AttendanceContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ipAddress = freezed,Object? assignedLocations = null,Object? hasShiftToday = null,Object? shiftStartAt = freezed,Object? shiftEndAt = freezed,Object? user = null,}) {
  return _then(AttendanceContext(
ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,assignedLocations: null == assignedLocations ? _self.assignedLocations : assignedLocations // ignore: cast_nullable_to_non_nullable
as List<AttendanceLocation>,hasShiftToday: null == hasShiftToday ? _self.hasShiftToday : hasShiftToday // ignore: cast_nullable_to_non_nullable
as bool,shiftStartAt: freezed == shiftStartAt ? _self.shiftStartAt : shiftStartAt // ignore: cast_nullable_to_non_nullable
as String?,shiftEndAt: freezed == shiftEndAt ? _self.shiftEndAt : shiftEndAt // ignore: cast_nullable_to_non_nullable
as String?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AttendanceUserRef,
  ));
}
/// Create a copy of AttendanceContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceUserRefCopyWith<$Res> get user {
  
  return $AttendanceUserRefCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceContext].
extension AttendanceContextPatterns on AttendanceContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceContext value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceContext value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'ip_address')  String? ipAddress, @JsonKey(name: 'assigned_locations')  List<AttendanceLocation> assignedLocations, @JsonKey(name: 'has_shift_today', required: true, disallowNullValue: true)  bool hasShiftToday, @JsonKey(name: 'shift_start_at')  String? shiftStartAt, @JsonKey(name: 'shift_end_at')  String? shiftEndAt, @JsonKey(required: true, disallowNullValue: true)  AttendanceUserRef user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceContext() when $default != null:
return $default(_that.ipAddress,_that.assignedLocations,_that.hasShiftToday,_that.shiftStartAt,_that.shiftEndAt,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'ip_address')  String? ipAddress, @JsonKey(name: 'assigned_locations')  List<AttendanceLocation> assignedLocations, @JsonKey(name: 'has_shift_today', required: true, disallowNullValue: true)  bool hasShiftToday, @JsonKey(name: 'shift_start_at')  String? shiftStartAt, @JsonKey(name: 'shift_end_at')  String? shiftEndAt, @JsonKey(required: true, disallowNullValue: true)  AttendanceUserRef user)  $default,) {final _that = this;
switch (_that) {
case _AttendanceContext():
return $default(_that.ipAddress,_that.assignedLocations,_that.hasShiftToday,_that.shiftStartAt,_that.shiftEndAt,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'ip_address')  String? ipAddress, @JsonKey(name: 'assigned_locations')  List<AttendanceLocation> assignedLocations, @JsonKey(name: 'has_shift_today', required: true, disallowNullValue: true)  bool hasShiftToday, @JsonKey(name: 'shift_start_at')  String? shiftStartAt, @JsonKey(name: 'shift_end_at')  String? shiftEndAt, @JsonKey(required: true, disallowNullValue: true)  AttendanceUserRef user)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceContext() when $default != null:
return $default(_that.ipAddress,_that.assignedLocations,_that.hasShiftToday,_that.shiftStartAt,_that.shiftEndAt,_that.user);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AttendanceContext implements AttendanceContext {
  const _AttendanceContext({@JsonKey(name: 'ip_address') this.ipAddress, @JsonKey(name: 'assigned_locations') required  List<AttendanceLocation> assignedLocations, @JsonKey(name: 'has_shift_today', required: true, disallowNullValue: true) this.hasShiftToday = true, @JsonKey(name: 'shift_start_at') this.shiftStartAt, @JsonKey(name: 'shift_end_at') this.shiftEndAt, @JsonKey(required: true, disallowNullValue: true) required this.user}): _assignedLocations = assignedLocations;
  factory _AttendanceContext.fromJson(Map<String, dynamic> json) => _$AttendanceContextFromJson(json);

@override@JsonKey(name: 'ip_address') final  String? ipAddress;
 final  List<AttendanceLocation> _assignedLocations;
@override@JsonKey(name: 'assigned_locations') List<AttendanceLocation> get assignedLocations {
  if (_assignedLocations is EqualUnmodifiableListView) return _assignedLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignedLocations);
}

@override@JsonKey(name: 'has_shift_today', required: true, disallowNullValue: true) final  bool hasShiftToday;
@override@JsonKey(name: 'shift_start_at') final  String? shiftStartAt;
@override@JsonKey(name: 'shift_end_at') final  String? shiftEndAt;
@override@JsonKey(required: true, disallowNullValue: true) final  AttendanceUserRef user;

/// Create a copy of AttendanceContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceContextCopyWith<_AttendanceContext> get copyWith => __$AttendanceContextCopyWithImpl<_AttendanceContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceContextToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceContext&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&const DeepCollectionEquality().equals(other.assignedLocations, _assignedLocations)&&(identical(other.hasShiftToday, hasShiftToday) || other.hasShiftToday == hasShiftToday)&&(identical(other.shiftStartAt, shiftStartAt) || other.shiftStartAt == shiftStartAt)&&(identical(other.shiftEndAt, shiftEndAt) || other.shiftEndAt == shiftEndAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ipAddress,const DeepCollectionEquality().hash(_assignedLocations),hasShiftToday,shiftStartAt,shiftEndAt,user);
}

@override
String toString() {
    return 'AttendanceContext(ipAddress: $ipAddress, assignedLocations: $assignedLocations, hasShiftToday: $hasShiftToday, shiftStartAt: $shiftStartAt, shiftEndAt: $shiftEndAt, user: $user)';
}


}

/// @nodoc
abstract mixin class _$AttendanceContextCopyWith<$Res> implements $AttendanceContextCopyWith<$Res> {
  factory _$AttendanceContextCopyWith(_AttendanceContext value, $Res Function(_AttendanceContext) _then) = __$AttendanceContextCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'ip_address') String? ipAddress,@JsonKey(name: 'assigned_locations') List<AttendanceLocation> assignedLocations,@JsonKey(name: 'has_shift_today', required: true, disallowNullValue: true) bool hasShiftToday,@JsonKey(name: 'shift_start_at') String? shiftStartAt,@JsonKey(name: 'shift_end_at') String? shiftEndAt,@JsonKey(required: true, disallowNullValue: true) AttendanceUserRef user
});


@override $AttendanceUserRefCopyWith<$Res> get user;

}
/// @nodoc
class __$AttendanceContextCopyWithImpl<$Res>
    implements _$AttendanceContextCopyWith<$Res> {
  __$AttendanceContextCopyWithImpl(this._self, this._then);

  final _AttendanceContext _self;
  final $Res Function(_AttendanceContext) _then;

/// Create a copy of AttendanceContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ipAddress = freezed,Object? assignedLocations = null,Object? hasShiftToday = null,Object? shiftStartAt = freezed,Object? shiftEndAt = freezed,Object? user = null,}) {
  return _then(_AttendanceContext(
ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,assignedLocations: null == assignedLocations ? _self._assignedLocations : assignedLocations // ignore: cast_nullable_to_non_nullable
as List<AttendanceLocation>,hasShiftToday: null == hasShiftToday ? _self.hasShiftToday : hasShiftToday // ignore: cast_nullable_to_non_nullable
as bool,shiftStartAt: freezed == shiftStartAt ? _self.shiftStartAt : shiftStartAt // ignore: cast_nullable_to_non_nullable
as String?,shiftEndAt: freezed == shiftEndAt ? _self.shiftEndAt : shiftEndAt // ignore: cast_nullable_to_non_nullable
as String?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AttendanceUserRef,
  ));
}

/// Create a copy of AttendanceContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceUserRefCopyWith<$Res> get user {
  
  return $AttendanceUserRefCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$AttendanceLog {

 String get id;@JsonKey(name: 'checked_at') String get checkedAt;@JsonKey(name: 'ip_address') String? get ipAddress; double? get latitude; double? get longitude; AttendanceLogLocation? get location;@JsonKey(name: 'user_id') String? get userId;@JsonKey(name: 'attendance_location_id', required: true) String? get attendanceLocationId;@JsonKey(required: true, disallowNullValue: true) String get source;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of AttendanceLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceLogCopyWith<AttendanceLog> get copyWith => _$AttendanceLogCopyWithImpl<AttendanceLog>(this as AttendanceLog, _$identity);

  /// Serializes this AttendanceLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceLog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceLog&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.checkedAt, _this.checkedAt) || other.checkedAt == _this.checkedAt)&&(identical(other.ipAddress, _this.ipAddress) || other.ipAddress == _this.ipAddress)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.attendanceLocationId, _this.attendanceLocationId) || other.attendanceLocationId == _this.attendanceLocationId)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceLog;
  return Object.hash(runtimeType,_this.id,_this.checkedAt,_this.ipAddress,_this.latitude,_this.longitude,_this.location,_this.userId,_this.attendanceLocationId,_this.source,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as AttendanceLog;
  return 'AttendanceLog(id: ${_this.id}, checkedAt: ${_this.checkedAt}, ipAddress: ${_this.ipAddress}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, location: ${_this.location}, userId: ${_this.userId}, attendanceLocationId: ${_this.attendanceLocationId}, source: ${_this.source}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $AttendanceLogCopyWith<$Res>  {
  factory $AttendanceLogCopyWith(AttendanceLog value, $Res Function(AttendanceLog) _then) = _$AttendanceLogCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'checked_at') String checkedAt,@JsonKey(name: 'ip_address') String? ipAddress, double? latitude, double? longitude, AttendanceLogLocation? location,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'attendance_location_id', required: true) String? attendanceLocationId,@JsonKey(required: true, disallowNullValue: true) String source,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});


$AttendanceLogLocationCopyWith<$Res>? get location;

}
/// @nodoc
class _$AttendanceLogCopyWithImpl<$Res>
    implements $AttendanceLogCopyWith<$Res> {
  _$AttendanceLogCopyWithImpl(this._self, this._then);

  final AttendanceLog _self;
  final $Res Function(AttendanceLog) _then;

/// Create a copy of AttendanceLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? checkedAt = null,Object? ipAddress = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? location = freezed,Object? userId = freezed,Object? attendanceLocationId = freezed,Object? source = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(AttendanceLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as String,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AttendanceLogLocation?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,attendanceLocationId: freezed == attendanceLocationId ? _self.attendanceLocationId : attendanceLocationId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AttendanceLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceLogLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $AttendanceLogLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttendanceLog].
extension AttendanceLogPatterns on AttendanceLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceLog value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceLog value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'checked_at')  String checkedAt, @JsonKey(name: 'ip_address')  String? ipAddress,  double? latitude,  double? longitude,  AttendanceLogLocation? location, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'attendance_location_id', required: true)  String? attendanceLocationId, @JsonKey(required: true, disallowNullValue: true)  String source, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceLog() when $default != null:
return $default(_that.id,_that.checkedAt,_that.ipAddress,_that.latitude,_that.longitude,_that.location,_that.userId,_that.attendanceLocationId,_that.source,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'checked_at')  String checkedAt, @JsonKey(name: 'ip_address')  String? ipAddress,  double? latitude,  double? longitude,  AttendanceLogLocation? location, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'attendance_location_id', required: true)  String? attendanceLocationId, @JsonKey(required: true, disallowNullValue: true)  String source, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceLog():
return $default(_that.id,_that.checkedAt,_that.ipAddress,_that.latitude,_that.longitude,_that.location,_that.userId,_that.attendanceLocationId,_that.source,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'checked_at')  String checkedAt, @JsonKey(name: 'ip_address')  String? ipAddress,  double? latitude,  double? longitude,  AttendanceLogLocation? location, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'attendance_location_id', required: true)  String? attendanceLocationId, @JsonKey(required: true, disallowNullValue: true)  String source, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceLog() when $default != null:
return $default(_that.id,_that.checkedAt,_that.ipAddress,_that.latitude,_that.longitude,_that.location,_that.userId,_that.attendanceLocationId,_that.source,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AttendanceLog implements AttendanceLog {
  const _AttendanceLog({required this.id, @JsonKey(name: 'checked_at') required this.checkedAt, @JsonKey(name: 'ip_address') this.ipAddress, this.latitude, this.longitude, this.location, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'attendance_location_id', required: true) this.attendanceLocationId, @JsonKey(required: true, disallowNullValue: true) required this.source, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _AttendanceLog.fromJson(Map<String, dynamic> json) => _$AttendanceLogFromJson(json);

@override final  String id;
@override@JsonKey(name: 'checked_at') final  String checkedAt;
@override@JsonKey(name: 'ip_address') final  String? ipAddress;
@override final  double? latitude;
@override final  double? longitude;
@override final  AttendanceLogLocation? location;
@override@JsonKey(name: 'user_id') final  String? userId;
@override@JsonKey(name: 'attendance_location_id', required: true) final  String? attendanceLocationId;
@override@JsonKey(required: true, disallowNullValue: true) final  String source;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of AttendanceLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceLogCopyWith<_AttendanceLog> get copyWith => __$AttendanceLogCopyWithImpl<_AttendanceLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceLogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceLog&&(identical(other.id, id) || other.id == id)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.location, location) || other.location == location)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.attendanceLocationId, attendanceLocationId) || other.attendanceLocationId == attendanceLocationId)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,checkedAt,ipAddress,latitude,longitude,location,userId,attendanceLocationId,source,createdAt,updatedAt);
}

@override
String toString() {
    return 'AttendanceLog(id: $id, checkedAt: $checkedAt, ipAddress: $ipAddress, latitude: $latitude, longitude: $longitude, location: $location, userId: $userId, attendanceLocationId: $attendanceLocationId, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceLogCopyWith<$Res> implements $AttendanceLogCopyWith<$Res> {
  factory _$AttendanceLogCopyWith(_AttendanceLog value, $Res Function(_AttendanceLog) _then) = __$AttendanceLogCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'checked_at') String checkedAt,@JsonKey(name: 'ip_address') String? ipAddress, double? latitude, double? longitude, AttendanceLogLocation? location,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'attendance_location_id', required: true) String? attendanceLocationId,@JsonKey(required: true, disallowNullValue: true) String source,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});


@override $AttendanceLogLocationCopyWith<$Res>? get location;

}
/// @nodoc
class __$AttendanceLogCopyWithImpl<$Res>
    implements _$AttendanceLogCopyWith<$Res> {
  __$AttendanceLogCopyWithImpl(this._self, this._then);

  final _AttendanceLog _self;
  final $Res Function(_AttendanceLog) _then;

/// Create a copy of AttendanceLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? checkedAt = null,Object? ipAddress = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? location = freezed,Object? userId = freezed,Object? attendanceLocationId = freezed,Object? source = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AttendanceLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as String,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AttendanceLogLocation?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,attendanceLocationId: freezed == attendanceLocationId ? _self.attendanceLocationId : attendanceLocationId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AttendanceLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceLogLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $AttendanceLogLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$AttendanceDayDetail {

 String get date;@JsonKey(name: 'total_work_seconds') int get totalWorkSeconds; List<AttendanceLog> get logs;@JsonKey(name: 'first_check_in_at', required: true) String? get firstCheckInAt;@JsonKey(name: 'last_check_out_at', required: true) String? get lastCheckOutAt;@JsonKey(name: 'is_late') bool get isLate;@JsonKey(name: 'shift_start_at') String? get shiftStartAt;@JsonKey(name: 'shift_end_at') String? get shiftEndAt;
/// Create a copy of AttendanceDayDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceDayDetailCopyWith<AttendanceDayDetail> get copyWith => _$AttendanceDayDetailCopyWithImpl<AttendanceDayDetail>(this as AttendanceDayDetail, _$identity);

  /// Serializes this AttendanceDayDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceDayDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceDayDetail&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.totalWorkSeconds, _this.totalWorkSeconds) || other.totalWorkSeconds == _this.totalWorkSeconds)&&const DeepCollectionEquality().equals(other.logs, _this.logs)&&(identical(other.firstCheckInAt, _this.firstCheckInAt) || other.firstCheckInAt == _this.firstCheckInAt)&&(identical(other.lastCheckOutAt, _this.lastCheckOutAt) || other.lastCheckOutAt == _this.lastCheckOutAt)&&(identical(other.isLate, _this.isLate) || other.isLate == _this.isLate)&&(identical(other.shiftStartAt, _this.shiftStartAt) || other.shiftStartAt == _this.shiftStartAt)&&(identical(other.shiftEndAt, _this.shiftEndAt) || other.shiftEndAt == _this.shiftEndAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceDayDetail;
  return Object.hash(runtimeType,_this.date,_this.totalWorkSeconds,const DeepCollectionEquality().hash(_this.logs),_this.firstCheckInAt,_this.lastCheckOutAt,_this.isLate,_this.shiftStartAt,_this.shiftEndAt);
}

@override
String toString() {
  final _this = this as AttendanceDayDetail;
  return 'AttendanceDayDetail(date: ${_this.date}, totalWorkSeconds: ${_this.totalWorkSeconds}, logs: ${_this.logs}, firstCheckInAt: ${_this.firstCheckInAt}, lastCheckOutAt: ${_this.lastCheckOutAt}, isLate: ${_this.isLate}, shiftStartAt: ${_this.shiftStartAt}, shiftEndAt: ${_this.shiftEndAt})';
}


}

/// @nodoc
abstract mixin class $AttendanceDayDetailCopyWith<$Res>  {
  factory $AttendanceDayDetailCopyWith(AttendanceDayDetail value, $Res Function(AttendanceDayDetail) _then) = _$AttendanceDayDetailCopyWithImpl;
@useResult
$Res call({
 String date,@JsonKey(name: 'total_work_seconds') int totalWorkSeconds, List<AttendanceLog> logs,@JsonKey(name: 'first_check_in_at', required: true) String? firstCheckInAt,@JsonKey(name: 'last_check_out_at', required: true) String? lastCheckOutAt,@JsonKey(name: 'is_late') bool isLate,@JsonKey(name: 'shift_start_at') String? shiftStartAt,@JsonKey(name: 'shift_end_at') String? shiftEndAt
});




}
/// @nodoc
class _$AttendanceDayDetailCopyWithImpl<$Res>
    implements $AttendanceDayDetailCopyWith<$Res> {
  _$AttendanceDayDetailCopyWithImpl(this._self, this._then);

  final AttendanceDayDetail _self;
  final $Res Function(AttendanceDayDetail) _then;

/// Create a copy of AttendanceDayDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? totalWorkSeconds = null,Object? logs = null,Object? firstCheckInAt = freezed,Object? lastCheckOutAt = freezed,Object? isLate = null,Object? shiftStartAt = freezed,Object? shiftEndAt = freezed,}) {
  return _then(AttendanceDayDetail(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,totalWorkSeconds: null == totalWorkSeconds ? _self.totalWorkSeconds : totalWorkSeconds // ignore: cast_nullable_to_non_nullable
as int,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<AttendanceLog>,firstCheckInAt: freezed == firstCheckInAt ? _self.firstCheckInAt : firstCheckInAt // ignore: cast_nullable_to_non_nullable
as String?,lastCheckOutAt: freezed == lastCheckOutAt ? _self.lastCheckOutAt : lastCheckOutAt // ignore: cast_nullable_to_non_nullable
as String?,isLate: null == isLate ? _self.isLate : isLate // ignore: cast_nullable_to_non_nullable
as bool,shiftStartAt: freezed == shiftStartAt ? _self.shiftStartAt : shiftStartAt // ignore: cast_nullable_to_non_nullable
as String?,shiftEndAt: freezed == shiftEndAt ? _self.shiftEndAt : shiftEndAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceDayDetail].
extension AttendanceDayDetailPatterns on AttendanceDayDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceDayDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceDayDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceDayDetail value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceDayDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceDayDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceDayDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'total_work_seconds')  int totalWorkSeconds,  List<AttendanceLog> logs, @JsonKey(name: 'first_check_in_at', required: true)  String? firstCheckInAt, @JsonKey(name: 'last_check_out_at', required: true)  String? lastCheckOutAt, @JsonKey(name: 'is_late')  bool isLate, @JsonKey(name: 'shift_start_at')  String? shiftStartAt, @JsonKey(name: 'shift_end_at')  String? shiftEndAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceDayDetail() when $default != null:
return $default(_that.date,_that.totalWorkSeconds,_that.logs,_that.firstCheckInAt,_that.lastCheckOutAt,_that.isLate,_that.shiftStartAt,_that.shiftEndAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'total_work_seconds')  int totalWorkSeconds,  List<AttendanceLog> logs, @JsonKey(name: 'first_check_in_at', required: true)  String? firstCheckInAt, @JsonKey(name: 'last_check_out_at', required: true)  String? lastCheckOutAt, @JsonKey(name: 'is_late')  bool isLate, @JsonKey(name: 'shift_start_at')  String? shiftStartAt, @JsonKey(name: 'shift_end_at')  String? shiftEndAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceDayDetail():
return $default(_that.date,_that.totalWorkSeconds,_that.logs,_that.firstCheckInAt,_that.lastCheckOutAt,_that.isLate,_that.shiftStartAt,_that.shiftEndAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date, @JsonKey(name: 'total_work_seconds')  int totalWorkSeconds,  List<AttendanceLog> logs, @JsonKey(name: 'first_check_in_at', required: true)  String? firstCheckInAt, @JsonKey(name: 'last_check_out_at', required: true)  String? lastCheckOutAt, @JsonKey(name: 'is_late')  bool isLate, @JsonKey(name: 'shift_start_at')  String? shiftStartAt, @JsonKey(name: 'shift_end_at')  String? shiftEndAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceDayDetail() when $default != null:
return $default(_that.date,_that.totalWorkSeconds,_that.logs,_that.firstCheckInAt,_that.lastCheckOutAt,_that.isLate,_that.shiftStartAt,_that.shiftEndAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AttendanceDayDetail implements AttendanceDayDetail {
  const _AttendanceDayDetail({required this.date, @JsonKey(name: 'total_work_seconds') required this.totalWorkSeconds, required  List<AttendanceLog> logs, @JsonKey(name: 'first_check_in_at', required: true) this.firstCheckInAt, @JsonKey(name: 'last_check_out_at', required: true) this.lastCheckOutAt, @JsonKey(name: 'is_late') this.isLate = false, @JsonKey(name: 'shift_start_at') this.shiftStartAt, @JsonKey(name: 'shift_end_at') this.shiftEndAt}): _logs = logs;
  factory _AttendanceDayDetail.fromJson(Map<String, dynamic> json) => _$AttendanceDayDetailFromJson(json);

@override final  String date;
@override@JsonKey(name: 'total_work_seconds') final  int totalWorkSeconds;
 final  List<AttendanceLog> _logs;
@override List<AttendanceLog> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

@override@JsonKey(name: 'first_check_in_at', required: true) final  String? firstCheckInAt;
@override@JsonKey(name: 'last_check_out_at', required: true) final  String? lastCheckOutAt;
@override@JsonKey(name: 'is_late') final  bool isLate;
@override@JsonKey(name: 'shift_start_at') final  String? shiftStartAt;
@override@JsonKey(name: 'shift_end_at') final  String? shiftEndAt;

/// Create a copy of AttendanceDayDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceDayDetailCopyWith<_AttendanceDayDetail> get copyWith => __$AttendanceDayDetailCopyWithImpl<_AttendanceDayDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceDayDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceDayDetail&&(identical(other.date, date) || other.date == date)&&(identical(other.totalWorkSeconds, totalWorkSeconds) || other.totalWorkSeconds == totalWorkSeconds)&&const DeepCollectionEquality().equals(other.logs, _logs)&&(identical(other.firstCheckInAt, firstCheckInAt) || other.firstCheckInAt == firstCheckInAt)&&(identical(other.lastCheckOutAt, lastCheckOutAt) || other.lastCheckOutAt == lastCheckOutAt)&&(identical(other.isLate, isLate) || other.isLate == isLate)&&(identical(other.shiftStartAt, shiftStartAt) || other.shiftStartAt == shiftStartAt)&&(identical(other.shiftEndAt, shiftEndAt) || other.shiftEndAt == shiftEndAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,totalWorkSeconds,const DeepCollectionEquality().hash(_logs),firstCheckInAt,lastCheckOutAt,isLate,shiftStartAt,shiftEndAt);
}

@override
String toString() {
    return 'AttendanceDayDetail(date: $date, totalWorkSeconds: $totalWorkSeconds, logs: $logs, firstCheckInAt: $firstCheckInAt, lastCheckOutAt: $lastCheckOutAt, isLate: $isLate, shiftStartAt: $shiftStartAt, shiftEndAt: $shiftEndAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceDayDetailCopyWith<$Res> implements $AttendanceDayDetailCopyWith<$Res> {
  factory _$AttendanceDayDetailCopyWith(_AttendanceDayDetail value, $Res Function(_AttendanceDayDetail) _then) = __$AttendanceDayDetailCopyWithImpl;
@override @useResult
$Res call({
 String date,@JsonKey(name: 'total_work_seconds') int totalWorkSeconds, List<AttendanceLog> logs,@JsonKey(name: 'first_check_in_at', required: true) String? firstCheckInAt,@JsonKey(name: 'last_check_out_at', required: true) String? lastCheckOutAt,@JsonKey(name: 'is_late') bool isLate,@JsonKey(name: 'shift_start_at') String? shiftStartAt,@JsonKey(name: 'shift_end_at') String? shiftEndAt
});




}
/// @nodoc
class __$AttendanceDayDetailCopyWithImpl<$Res>
    implements _$AttendanceDayDetailCopyWith<$Res> {
  __$AttendanceDayDetailCopyWithImpl(this._self, this._then);

  final _AttendanceDayDetail _self;
  final $Res Function(_AttendanceDayDetail) _then;

/// Create a copy of AttendanceDayDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? totalWorkSeconds = null,Object? logs = null,Object? firstCheckInAt = freezed,Object? lastCheckOutAt = freezed,Object? isLate = null,Object? shiftStartAt = freezed,Object? shiftEndAt = freezed,}) {
  return _then(_AttendanceDayDetail(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,totalWorkSeconds: null == totalWorkSeconds ? _self.totalWorkSeconds : totalWorkSeconds // ignore: cast_nullable_to_non_nullable
as int,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<AttendanceLog>,firstCheckInAt: freezed == firstCheckInAt ? _self.firstCheckInAt : firstCheckInAt // ignore: cast_nullable_to_non_nullable
as String?,lastCheckOutAt: freezed == lastCheckOutAt ? _self.lastCheckOutAt : lastCheckOutAt // ignore: cast_nullable_to_non_nullable
as String?,isLate: null == isLate ? _self.isLate : isLate // ignore: cast_nullable_to_non_nullable
as bool,shiftStartAt: freezed == shiftStartAt ? _self.shiftStartAt : shiftStartAt // ignore: cast_nullable_to_non_nullable
as String?,shiftEndAt: freezed == shiftEndAt ? _self.shiftEndAt : shiftEndAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AttendanceRangeSummary {

 String get date;@JsonKey(name: 'logs_count') int get logsCount;@JsonKey(name: 'on_leave', required: true, disallowNullValue: true) bool get onLeave;@JsonKey(name: 'first_check_in_at', required: true) String? get firstCheckInAt;@JsonKey(name: 'last_check_out_at', required: true) String? get lastCheckOutAt;@JsonKey(name: 'total_work_seconds') int get totalWorkSeconds;@JsonKey(name: 'is_late') bool get isLate;@JsonKey(name: 'shift_start_at') String? get shiftStartAt;@JsonKey(name: 'shift_end_at') String? get shiftEndAt;
/// Create a copy of AttendanceRangeSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceRangeSummaryCopyWith<AttendanceRangeSummary> get copyWith => _$AttendanceRangeSummaryCopyWithImpl<AttendanceRangeSummary>(this as AttendanceRangeSummary, _$identity);

  /// Serializes this AttendanceRangeSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceRangeSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceRangeSummary&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.logsCount, _this.logsCount) || other.logsCount == _this.logsCount)&&(identical(other.onLeave, _this.onLeave) || other.onLeave == _this.onLeave)&&(identical(other.firstCheckInAt, _this.firstCheckInAt) || other.firstCheckInAt == _this.firstCheckInAt)&&(identical(other.lastCheckOutAt, _this.lastCheckOutAt) || other.lastCheckOutAt == _this.lastCheckOutAt)&&(identical(other.totalWorkSeconds, _this.totalWorkSeconds) || other.totalWorkSeconds == _this.totalWorkSeconds)&&(identical(other.isLate, _this.isLate) || other.isLate == _this.isLate)&&(identical(other.shiftStartAt, _this.shiftStartAt) || other.shiftStartAt == _this.shiftStartAt)&&(identical(other.shiftEndAt, _this.shiftEndAt) || other.shiftEndAt == _this.shiftEndAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceRangeSummary;
  return Object.hash(runtimeType,_this.date,_this.logsCount,_this.onLeave,_this.firstCheckInAt,_this.lastCheckOutAt,_this.totalWorkSeconds,_this.isLate,_this.shiftStartAt,_this.shiftEndAt);
}

@override
String toString() {
  final _this = this as AttendanceRangeSummary;
  return 'AttendanceRangeSummary(date: ${_this.date}, logsCount: ${_this.logsCount}, onLeave: ${_this.onLeave}, firstCheckInAt: ${_this.firstCheckInAt}, lastCheckOutAt: ${_this.lastCheckOutAt}, totalWorkSeconds: ${_this.totalWorkSeconds}, isLate: ${_this.isLate}, shiftStartAt: ${_this.shiftStartAt}, shiftEndAt: ${_this.shiftEndAt})';
}


}

/// @nodoc
abstract mixin class $AttendanceRangeSummaryCopyWith<$Res>  {
  factory $AttendanceRangeSummaryCopyWith(AttendanceRangeSummary value, $Res Function(AttendanceRangeSummary) _then) = _$AttendanceRangeSummaryCopyWithImpl;
@useResult
$Res call({
 String date,@JsonKey(name: 'logs_count') int logsCount,@JsonKey(name: 'on_leave', required: true, disallowNullValue: true) bool onLeave,@JsonKey(name: 'first_check_in_at', required: true) String? firstCheckInAt,@JsonKey(name: 'last_check_out_at', required: true) String? lastCheckOutAt,@JsonKey(name: 'total_work_seconds') int totalWorkSeconds,@JsonKey(name: 'is_late') bool isLate,@JsonKey(name: 'shift_start_at') String? shiftStartAt,@JsonKey(name: 'shift_end_at') String? shiftEndAt
});




}
/// @nodoc
class _$AttendanceRangeSummaryCopyWithImpl<$Res>
    implements $AttendanceRangeSummaryCopyWith<$Res> {
  _$AttendanceRangeSummaryCopyWithImpl(this._self, this._then);

  final AttendanceRangeSummary _self;
  final $Res Function(AttendanceRangeSummary) _then;

/// Create a copy of AttendanceRangeSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? logsCount = null,Object? onLeave = null,Object? firstCheckInAt = freezed,Object? lastCheckOutAt = freezed,Object? totalWorkSeconds = null,Object? isLate = null,Object? shiftStartAt = freezed,Object? shiftEndAt = freezed,}) {
  return _then(AttendanceRangeSummary(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,logsCount: null == logsCount ? _self.logsCount : logsCount // ignore: cast_nullable_to_non_nullable
as int,onLeave: null == onLeave ? _self.onLeave : onLeave // ignore: cast_nullable_to_non_nullable
as bool,firstCheckInAt: freezed == firstCheckInAt ? _self.firstCheckInAt : firstCheckInAt // ignore: cast_nullable_to_non_nullable
as String?,lastCheckOutAt: freezed == lastCheckOutAt ? _self.lastCheckOutAt : lastCheckOutAt // ignore: cast_nullable_to_non_nullable
as String?,totalWorkSeconds: null == totalWorkSeconds ? _self.totalWorkSeconds : totalWorkSeconds // ignore: cast_nullable_to_non_nullable
as int,isLate: null == isLate ? _self.isLate : isLate // ignore: cast_nullable_to_non_nullable
as bool,shiftStartAt: freezed == shiftStartAt ? _self.shiftStartAt : shiftStartAt // ignore: cast_nullable_to_non_nullable
as String?,shiftEndAt: freezed == shiftEndAt ? _self.shiftEndAt : shiftEndAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceRangeSummary].
extension AttendanceRangeSummaryPatterns on AttendanceRangeSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceRangeSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceRangeSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceRangeSummary value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceRangeSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceRangeSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceRangeSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'logs_count')  int logsCount, @JsonKey(name: 'on_leave', required: true, disallowNullValue: true)  bool onLeave, @JsonKey(name: 'first_check_in_at', required: true)  String? firstCheckInAt, @JsonKey(name: 'last_check_out_at', required: true)  String? lastCheckOutAt, @JsonKey(name: 'total_work_seconds')  int totalWorkSeconds, @JsonKey(name: 'is_late')  bool isLate, @JsonKey(name: 'shift_start_at')  String? shiftStartAt, @JsonKey(name: 'shift_end_at')  String? shiftEndAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceRangeSummary() when $default != null:
return $default(_that.date,_that.logsCount,_that.onLeave,_that.firstCheckInAt,_that.lastCheckOutAt,_that.totalWorkSeconds,_that.isLate,_that.shiftStartAt,_that.shiftEndAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'logs_count')  int logsCount, @JsonKey(name: 'on_leave', required: true, disallowNullValue: true)  bool onLeave, @JsonKey(name: 'first_check_in_at', required: true)  String? firstCheckInAt, @JsonKey(name: 'last_check_out_at', required: true)  String? lastCheckOutAt, @JsonKey(name: 'total_work_seconds')  int totalWorkSeconds, @JsonKey(name: 'is_late')  bool isLate, @JsonKey(name: 'shift_start_at')  String? shiftStartAt, @JsonKey(name: 'shift_end_at')  String? shiftEndAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceRangeSummary():
return $default(_that.date,_that.logsCount,_that.onLeave,_that.firstCheckInAt,_that.lastCheckOutAt,_that.totalWorkSeconds,_that.isLate,_that.shiftStartAt,_that.shiftEndAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date, @JsonKey(name: 'logs_count')  int logsCount, @JsonKey(name: 'on_leave', required: true, disallowNullValue: true)  bool onLeave, @JsonKey(name: 'first_check_in_at', required: true)  String? firstCheckInAt, @JsonKey(name: 'last_check_out_at', required: true)  String? lastCheckOutAt, @JsonKey(name: 'total_work_seconds')  int totalWorkSeconds, @JsonKey(name: 'is_late')  bool isLate, @JsonKey(name: 'shift_start_at')  String? shiftStartAt, @JsonKey(name: 'shift_end_at')  String? shiftEndAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceRangeSummary() when $default != null:
return $default(_that.date,_that.logsCount,_that.onLeave,_that.firstCheckInAt,_that.lastCheckOutAt,_that.totalWorkSeconds,_that.isLate,_that.shiftStartAt,_that.shiftEndAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AttendanceRangeSummary implements AttendanceRangeSummary {
  const _AttendanceRangeSummary({required this.date, @JsonKey(name: 'logs_count') required this.logsCount, @JsonKey(name: 'on_leave', required: true, disallowNullValue: true) this.onLeave = false, @JsonKey(name: 'first_check_in_at', required: true) this.firstCheckInAt, @JsonKey(name: 'last_check_out_at', required: true) this.lastCheckOutAt, @JsonKey(name: 'total_work_seconds') required this.totalWorkSeconds, @JsonKey(name: 'is_late') this.isLate = false, @JsonKey(name: 'shift_start_at') this.shiftStartAt, @JsonKey(name: 'shift_end_at') this.shiftEndAt});
  factory _AttendanceRangeSummary.fromJson(Map<String, dynamic> json) => _$AttendanceRangeSummaryFromJson(json);

@override final  String date;
@override@JsonKey(name: 'logs_count') final  int logsCount;
@override@JsonKey(name: 'on_leave', required: true, disallowNullValue: true) final  bool onLeave;
@override@JsonKey(name: 'first_check_in_at', required: true) final  String? firstCheckInAt;
@override@JsonKey(name: 'last_check_out_at', required: true) final  String? lastCheckOutAt;
@override@JsonKey(name: 'total_work_seconds') final  int totalWorkSeconds;
@override@JsonKey(name: 'is_late') final  bool isLate;
@override@JsonKey(name: 'shift_start_at') final  String? shiftStartAt;
@override@JsonKey(name: 'shift_end_at') final  String? shiftEndAt;

/// Create a copy of AttendanceRangeSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceRangeSummaryCopyWith<_AttendanceRangeSummary> get copyWith => __$AttendanceRangeSummaryCopyWithImpl<_AttendanceRangeSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceRangeSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceRangeSummary&&(identical(other.date, date) || other.date == date)&&(identical(other.logsCount, logsCount) || other.logsCount == logsCount)&&(identical(other.onLeave, onLeave) || other.onLeave == onLeave)&&(identical(other.firstCheckInAt, firstCheckInAt) || other.firstCheckInAt == firstCheckInAt)&&(identical(other.lastCheckOutAt, lastCheckOutAt) || other.lastCheckOutAt == lastCheckOutAt)&&(identical(other.totalWorkSeconds, totalWorkSeconds) || other.totalWorkSeconds == totalWorkSeconds)&&(identical(other.isLate, isLate) || other.isLate == isLate)&&(identical(other.shiftStartAt, shiftStartAt) || other.shiftStartAt == shiftStartAt)&&(identical(other.shiftEndAt, shiftEndAt) || other.shiftEndAt == shiftEndAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,logsCount,onLeave,firstCheckInAt,lastCheckOutAt,totalWorkSeconds,isLate,shiftStartAt,shiftEndAt);
}

@override
String toString() {
    return 'AttendanceRangeSummary(date: $date, logsCount: $logsCount, onLeave: $onLeave, firstCheckInAt: $firstCheckInAt, lastCheckOutAt: $lastCheckOutAt, totalWorkSeconds: $totalWorkSeconds, isLate: $isLate, shiftStartAt: $shiftStartAt, shiftEndAt: $shiftEndAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceRangeSummaryCopyWith<$Res> implements $AttendanceRangeSummaryCopyWith<$Res> {
  factory _$AttendanceRangeSummaryCopyWith(_AttendanceRangeSummary value, $Res Function(_AttendanceRangeSummary) _then) = __$AttendanceRangeSummaryCopyWithImpl;
@override @useResult
$Res call({
 String date,@JsonKey(name: 'logs_count') int logsCount,@JsonKey(name: 'on_leave', required: true, disallowNullValue: true) bool onLeave,@JsonKey(name: 'first_check_in_at', required: true) String? firstCheckInAt,@JsonKey(name: 'last_check_out_at', required: true) String? lastCheckOutAt,@JsonKey(name: 'total_work_seconds') int totalWorkSeconds,@JsonKey(name: 'is_late') bool isLate,@JsonKey(name: 'shift_start_at') String? shiftStartAt,@JsonKey(name: 'shift_end_at') String? shiftEndAt
});




}
/// @nodoc
class __$AttendanceRangeSummaryCopyWithImpl<$Res>
    implements _$AttendanceRangeSummaryCopyWith<$Res> {
  __$AttendanceRangeSummaryCopyWithImpl(this._self, this._then);

  final _AttendanceRangeSummary _self;
  final $Res Function(_AttendanceRangeSummary) _then;

/// Create a copy of AttendanceRangeSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? logsCount = null,Object? onLeave = null,Object? firstCheckInAt = freezed,Object? lastCheckOutAt = freezed,Object? totalWorkSeconds = null,Object? isLate = null,Object? shiftStartAt = freezed,Object? shiftEndAt = freezed,}) {
  return _then(_AttendanceRangeSummary(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,logsCount: null == logsCount ? _self.logsCount : logsCount // ignore: cast_nullable_to_non_nullable
as int,onLeave: null == onLeave ? _self.onLeave : onLeave // ignore: cast_nullable_to_non_nullable
as bool,firstCheckInAt: freezed == firstCheckInAt ? _self.firstCheckInAt : firstCheckInAt // ignore: cast_nullable_to_non_nullable
as String?,lastCheckOutAt: freezed == lastCheckOutAt ? _self.lastCheckOutAt : lastCheckOutAt // ignore: cast_nullable_to_non_nullable
as String?,totalWorkSeconds: null == totalWorkSeconds ? _self.totalWorkSeconds : totalWorkSeconds // ignore: cast_nullable_to_non_nullable
as int,isLate: null == isLate ? _self.isLate : isLate // ignore: cast_nullable_to_non_nullable
as bool,shiftStartAt: freezed == shiftStartAt ? _self.shiftStartAt : shiftStartAt // ignore: cast_nullable_to_non_nullable
as String?,shiftEndAt: freezed == shiftEndAt ? _self.shiftEndAt : shiftEndAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AttendanceCoordinates {

 double get latitude; double get longitude;
/// Create a copy of AttendanceCoordinates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceCoordinatesCopyWith<AttendanceCoordinates> get copyWith => _$AttendanceCoordinatesCopyWithImpl<AttendanceCoordinates>(this as AttendanceCoordinates, _$identity);

  /// Serializes this AttendanceCoordinates to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceCoordinates;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceCoordinates&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceCoordinates;
  return Object.hash(runtimeType,_this.latitude,_this.longitude);
}

@override
String toString() {
  final _this = this as AttendanceCoordinates;
  return 'AttendanceCoordinates(latitude: ${_this.latitude}, longitude: ${_this.longitude})';
}


}

/// @nodoc
abstract mixin class $AttendanceCoordinatesCopyWith<$Res>  {
  factory $AttendanceCoordinatesCopyWith(AttendanceCoordinates value, $Res Function(AttendanceCoordinates) _then) = _$AttendanceCoordinatesCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude
});




}
/// @nodoc
class _$AttendanceCoordinatesCopyWithImpl<$Res>
    implements $AttendanceCoordinatesCopyWith<$Res> {
  _$AttendanceCoordinatesCopyWithImpl(this._self, this._then);

  final AttendanceCoordinates _self;
  final $Res Function(AttendanceCoordinates) _then;

/// Create a copy of AttendanceCoordinates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,}) {
  return _then(AttendanceCoordinates(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceCoordinates].
extension AttendanceCoordinatesPatterns on AttendanceCoordinates {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceCoordinates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceCoordinates() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceCoordinates value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceCoordinates():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceCoordinates value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceCoordinates() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceCoordinates() when $default != null:
return $default(_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude)  $default,) {final _that = this;
switch (_that) {
case _AttendanceCoordinates():
return $default(_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceCoordinates() when $default != null:
return $default(_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceCoordinates implements AttendanceCoordinates {
  const _AttendanceCoordinates({required this.latitude, required this.longitude});
  factory _AttendanceCoordinates.fromJson(Map<String, dynamic> json) => _$AttendanceCoordinatesFromJson(json);

@override final  double latitude;
@override final  double longitude;

/// Create a copy of AttendanceCoordinates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceCoordinatesCopyWith<_AttendanceCoordinates> get copyWith => __$AttendanceCoordinatesCopyWithImpl<_AttendanceCoordinates>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceCoordinatesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceCoordinates&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,latitude,longitude);
}

@override
String toString() {
    return 'AttendanceCoordinates(latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$AttendanceCoordinatesCopyWith<$Res> implements $AttendanceCoordinatesCopyWith<$Res> {
  factory _$AttendanceCoordinatesCopyWith(_AttendanceCoordinates value, $Res Function(_AttendanceCoordinates) _then) = __$AttendanceCoordinatesCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude
});




}
/// @nodoc
class __$AttendanceCoordinatesCopyWithImpl<$Res>
    implements _$AttendanceCoordinatesCopyWith<$Res> {
  __$AttendanceCoordinatesCopyWithImpl(this._self, this._then);

  final _AttendanceCoordinates _self;
  final $Res Function(_AttendanceCoordinates) _then;

/// Create a copy of AttendanceCoordinates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,}) {
  return _then(_AttendanceCoordinates(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$AttendanceUserRef {

 Object get id; String get name;
/// Create a copy of AttendanceUserRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceUserRefCopyWith<AttendanceUserRef> get copyWith => _$AttendanceUserRefCopyWithImpl<AttendanceUserRef>(this as AttendanceUserRef, _$identity);

  /// Serializes this AttendanceUserRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceUserRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceUserRef&&const DeepCollectionEquality().equals(other.id, _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceUserRef;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.id),_this.name);
}

@override
String toString() {
  final _this = this as AttendanceUserRef;
  return 'AttendanceUserRef(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $AttendanceUserRefCopyWith<$Res>  {
  factory $AttendanceUserRefCopyWith(AttendanceUserRef value, $Res Function(AttendanceUserRef) _then) = _$AttendanceUserRefCopyWithImpl;
@useResult
$Res call({
 Object id, String name
});




}
/// @nodoc
class _$AttendanceUserRefCopyWithImpl<$Res>
    implements $AttendanceUserRefCopyWith<$Res> {
  _$AttendanceUserRefCopyWithImpl(this._self, this._then);

  final AttendanceUserRef _self;
  final $Res Function(AttendanceUserRef) _then;

/// Create a copy of AttendanceUserRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(AttendanceUserRef(
id: null == id ? _self.id : id ,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceUserRef].
extension AttendanceUserRefPatterns on AttendanceUserRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceUserRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceUserRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceUserRef value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceUserRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceUserRef value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceUserRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Object id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceUserRef() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Object id,  String name)  $default,) {final _that = this;
switch (_that) {
case _AttendanceUserRef():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Object id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceUserRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AttendanceUserRef implements AttendanceUserRef {
  const _AttendanceUserRef({required this.id, required this.name});
  factory _AttendanceUserRef.fromJson(Map<String, dynamic> json) => _$AttendanceUserRefFromJson(json);

@override final  Object id;
@override final  String name;

/// Create a copy of AttendanceUserRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceUserRefCopyWith<_AttendanceUserRef> get copyWith => __$AttendanceUserRefCopyWithImpl<_AttendanceUserRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceUserRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceUserRef&&const DeepCollectionEquality().equals(other.id, id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(id),name);
}

@override
String toString() {
    return 'AttendanceUserRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$AttendanceUserRefCopyWith<$Res> implements $AttendanceUserRefCopyWith<$Res> {
  factory _$AttendanceUserRefCopyWith(_AttendanceUserRef value, $Res Function(_AttendanceUserRef) _then) = __$AttendanceUserRefCopyWithImpl;
@override @useResult
$Res call({
 Object id, String name
});




}
/// @nodoc
class __$AttendanceUserRefCopyWithImpl<$Res>
    implements _$AttendanceUserRefCopyWith<$Res> {
  __$AttendanceUserRefCopyWithImpl(this._self, this._then);

  final _AttendanceUserRef _self;
  final $Res Function(_AttendanceUserRef) _then;

/// Create a copy of AttendanceUserRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_AttendanceUserRef(
id: null == id ? _self.id : id ,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AttendanceLogLocation {

 String get id; String get name; double get latitude; double get longitude;@JsonKey(name: 'radius_meters') double get radiusMeters;@JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) String get validationMode;@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String get createdAt;@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String get updatedAt;
/// Create a copy of AttendanceLogLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceLogLocationCopyWith<AttendanceLogLocation> get copyWith => _$AttendanceLogLocationCopyWithImpl<AttendanceLogLocation>(this as AttendanceLogLocation, _$identity);

  /// Serializes this AttendanceLogLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceLogLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceLogLocation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.radiusMeters, _this.radiusMeters) || other.radiusMeters == _this.radiusMeters)&&(identical(other.validationMode, _this.validationMode) || other.validationMode == _this.validationMode)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceLogLocation;
  return Object.hash(runtimeType,_this.id,_this.name,_this.latitude,_this.longitude,_this.radiusMeters,_this.validationMode,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as AttendanceLogLocation;
  return 'AttendanceLogLocation(id: ${_this.id}, name: ${_this.name}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, radiusMeters: ${_this.radiusMeters}, validationMode: ${_this.validationMode}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $AttendanceLogLocationCopyWith<$Res>  {
  factory $AttendanceLogLocationCopyWith(AttendanceLogLocation value, $Res Function(AttendanceLogLocation) _then) = _$AttendanceLogLocationCopyWithImpl;
@useResult
$Res call({
 String id, String name, double latitude, double longitude,@JsonKey(name: 'radius_meters') double radiusMeters,@JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) String validationMode,@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String createdAt,@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String updatedAt
});




}
/// @nodoc
class _$AttendanceLogLocationCopyWithImpl<$Res>
    implements $AttendanceLogLocationCopyWith<$Res> {
  _$AttendanceLogLocationCopyWithImpl(this._self, this._then);

  final AttendanceLogLocation _self;
  final $Res Function(AttendanceLogLocation) _then;

/// Create a copy of AttendanceLogLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? validationMode = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(AttendanceLogLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as double,validationMode: null == validationMode ? _self.validationMode : validationMode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceLogLocation].
extension AttendanceLogLocationPatterns on AttendanceLogLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceLogLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceLogLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceLogLocation value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceLogLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceLogLocation value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceLogLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude, @JsonKey(name: 'radius_meters')  double radiusMeters, @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson)  String validationMode, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceLogLocation() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.radiusMeters,_that.validationMode,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude, @JsonKey(name: 'radius_meters')  double radiusMeters, @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson)  String validationMode, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceLogLocation():
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.radiusMeters,_that.validationMode,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double latitude,  double longitude, @JsonKey(name: 'radius_meters')  double radiusMeters, @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson)  String validationMode, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceLogLocation() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.radiusMeters,_that.validationMode,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _AttendanceLogLocation implements AttendanceLogLocation {
  const _AttendanceLogLocation({required this.id, required this.name, required this.latitude, required this.longitude, @JsonKey(name: 'radius_meters') required this.radiusMeters, @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) required this.validationMode, @JsonKey(name: 'created_at', required: true, disallowNullValue: true) required this.createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true) required this.updatedAt});
  factory _AttendanceLogLocation.fromJson(Map<String, dynamic> json) => _$AttendanceLogLocationFromJson(json);

@override final  String id;
@override final  String name;
@override final  double latitude;
@override final  double longitude;
@override@JsonKey(name: 'radius_meters') final  double radiusMeters;
@override@JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) final  String validationMode;
@override@JsonKey(name: 'created_at', required: true, disallowNullValue: true) final  String createdAt;
@override@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) final  String updatedAt;

/// Create a copy of AttendanceLogLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceLogLocationCopyWith<_AttendanceLogLocation> get copyWith => __$AttendanceLogLocationCopyWithImpl<_AttendanceLogLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceLogLocationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceLogLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radiusMeters, radiusMeters) || other.radiusMeters == radiusMeters)&&(identical(other.validationMode, validationMode) || other.validationMode == validationMode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,latitude,longitude,radiusMeters,validationMode,createdAt,updatedAt);
}

@override
String toString() {
    return 'AttendanceLogLocation(id: $id, name: $name, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, validationMode: $validationMode, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceLogLocationCopyWith<$Res> implements $AttendanceLogLocationCopyWith<$Res> {
  factory _$AttendanceLogLocationCopyWith(_AttendanceLogLocation value, $Res Function(_AttendanceLogLocation) _then) = __$AttendanceLogLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double latitude, double longitude,@JsonKey(name: 'radius_meters') double radiusMeters,@JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson) String validationMode,@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String createdAt,@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String updatedAt
});




}
/// @nodoc
class __$AttendanceLogLocationCopyWithImpl<$Res>
    implements _$AttendanceLogLocationCopyWith<$Res> {
  __$AttendanceLogLocationCopyWithImpl(this._self, this._then);

  final _AttendanceLogLocation _self;
  final $Res Function(_AttendanceLogLocation) _then;

/// Create a copy of AttendanceLogLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? validationMode = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_AttendanceLogLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as double,validationMode: null == validationMode ? _self.validationMode : validationMode // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

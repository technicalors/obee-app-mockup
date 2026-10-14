// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_tree_selection_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserTreeSelectionUser {

 String get id; String get name; String get username;@JsonKey(name: 'organization_id') String get organizationId; OrganizationRef get organization;@JsonKey(required: true) UserTreeProfile? get profile;
/// Create a copy of UserTreeSelectionUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserTreeSelectionUserCopyWith<UserTreeSelectionUser> get copyWith => _$UserTreeSelectionUserCopyWithImpl<UserTreeSelectionUser>(this as UserTreeSelectionUser, _$identity);

  /// Serializes this UserTreeSelectionUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserTreeSelectionUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserTreeSelectionUser&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.organization, _this.organization) || other.organization == _this.organization)&&(identical(other.profile, _this.profile) || other.profile == _this.profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserTreeSelectionUser;
  return Object.hash(runtimeType,_this.id,_this.name,_this.username,_this.organizationId,_this.organization,_this.profile);
}

@override
String toString() {
  final _this = this as UserTreeSelectionUser;
  return 'UserTreeSelectionUser(id: ${_this.id}, name: ${_this.name}, username: ${_this.username}, organizationId: ${_this.organizationId}, organization: ${_this.organization}, profile: ${_this.profile})';
}


}

/// @nodoc
abstract mixin class $UserTreeSelectionUserCopyWith<$Res>  {
  factory $UserTreeSelectionUserCopyWith(UserTreeSelectionUser value, $Res Function(UserTreeSelectionUser) _then) = _$UserTreeSelectionUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String username,@JsonKey(name: 'organization_id') String organizationId, OrganizationRef organization,@JsonKey(required: true) UserTreeProfile? profile
});


$OrganizationRefCopyWith<$Res> get organization;$UserTreeProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$UserTreeSelectionUserCopyWithImpl<$Res>
    implements $UserTreeSelectionUserCopyWith<$Res> {
  _$UserTreeSelectionUserCopyWithImpl(this._self, this._then);

  final UserTreeSelectionUser _self;
  final $Res Function(UserTreeSelectionUser) _then;

/// Create a copy of UserTreeSelectionUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? username = null,Object? organizationId = null,Object? organization = null,Object? profile = freezed,}) {
  return _then(UserTreeSelectionUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,organization: null == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as OrganizationRef,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserTreeProfile?,
  ));
}
/// Create a copy of UserTreeSelectionUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationRefCopyWith<$Res> get organization {
  
  return $OrganizationRefCopyWith<$Res>(_self.organization, (value) {
    return _then(_self.copyWith(organization: value));
  });
}/// Create a copy of UserTreeSelectionUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserTreeProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserTreeProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserTreeSelectionUser].
extension UserTreeSelectionUserPatterns on UserTreeSelectionUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserTreeSelectionUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserTreeSelectionUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserTreeSelectionUser value)  $default,){
final _that = this;
switch (_that) {
case _UserTreeSelectionUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserTreeSelectionUser value)?  $default,){
final _that = this;
switch (_that) {
case _UserTreeSelectionUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String username, @JsonKey(name: 'organization_id')  String organizationId,  OrganizationRef organization, @JsonKey(required: true)  UserTreeProfile? profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserTreeSelectionUser() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.organizationId,_that.organization,_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String username, @JsonKey(name: 'organization_id')  String organizationId,  OrganizationRef organization, @JsonKey(required: true)  UserTreeProfile? profile)  $default,) {final _that = this;
switch (_that) {
case _UserTreeSelectionUser():
return $default(_that.id,_that.name,_that.username,_that.organizationId,_that.organization,_that.profile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String username, @JsonKey(name: 'organization_id')  String organizationId,  OrganizationRef organization, @JsonKey(required: true)  UserTreeProfile? profile)?  $default,) {final _that = this;
switch (_that) {
case _UserTreeSelectionUser() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.organizationId,_that.organization,_that.profile);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _UserTreeSelectionUser implements UserTreeSelectionUser {
  const _UserTreeSelectionUser({required this.id, required this.name, required this.username, @JsonKey(name: 'organization_id') required this.organizationId, required this.organization, @JsonKey(required: true) required this.profile});
  factory _UserTreeSelectionUser.fromJson(Map<String, dynamic> json) => _$UserTreeSelectionUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String username;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override final  OrganizationRef organization;
@override@JsonKey(required: true) final  UserTreeProfile? profile;

/// Create a copy of UserTreeSelectionUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserTreeSelectionUserCopyWith<_UserTreeSelectionUser> get copyWith => __$UserTreeSelectionUserCopyWithImpl<_UserTreeSelectionUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserTreeSelectionUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserTreeSelectionUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,username,organizationId,organization,profile);
}

@override
String toString() {
    return 'UserTreeSelectionUser(id: $id, name: $name, username: $username, organizationId: $organizationId, organization: $organization, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$UserTreeSelectionUserCopyWith<$Res> implements $UserTreeSelectionUserCopyWith<$Res> {
  factory _$UserTreeSelectionUserCopyWith(_UserTreeSelectionUser value, $Res Function(_UserTreeSelectionUser) _then) = __$UserTreeSelectionUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String username,@JsonKey(name: 'organization_id') String organizationId, OrganizationRef organization,@JsonKey(required: true) UserTreeProfile? profile
});


@override $OrganizationRefCopyWith<$Res> get organization;@override $UserTreeProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$UserTreeSelectionUserCopyWithImpl<$Res>
    implements _$UserTreeSelectionUserCopyWith<$Res> {
  __$UserTreeSelectionUserCopyWithImpl(this._self, this._then);

  final _UserTreeSelectionUser _self;
  final $Res Function(_UserTreeSelectionUser) _then;

/// Create a copy of UserTreeSelectionUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? username = null,Object? organizationId = null,Object? organization = null,Object? profile = freezed,}) {
  return _then(_UserTreeSelectionUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,organization: null == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as OrganizationRef,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserTreeProfile?,
  ));
}

/// Create a copy of UserTreeSelectionUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationRefCopyWith<$Res> get organization {
  
  return $OrganizationRefCopyWith<$Res>(_self.organization, (value) {
    return _then(_self.copyWith(organization: value));
  });
}/// Create a copy of UserTreeSelectionUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserTreeProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserTreeProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$UserTreeProfile {

 String get code;
/// Create a copy of UserTreeProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserTreeProfileCopyWith<UserTreeProfile> get copyWith => _$UserTreeProfileCopyWithImpl<UserTreeProfile>(this as UserTreeProfile, _$identity);

  /// Serializes this UserTreeProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserTreeProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserTreeProfile&&(identical(other.code, _this.code) || other.code == _this.code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserTreeProfile;
  return Object.hash(runtimeType,_this.code);
}

@override
String toString() {
  final _this = this as UserTreeProfile;
  return 'UserTreeProfile(code: ${_this.code})';
}


}

/// @nodoc
abstract mixin class $UserTreeProfileCopyWith<$Res>  {
  factory $UserTreeProfileCopyWith(UserTreeProfile value, $Res Function(UserTreeProfile) _then) = _$UserTreeProfileCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$UserTreeProfileCopyWithImpl<$Res>
    implements $UserTreeProfileCopyWith<$Res> {
  _$UserTreeProfileCopyWithImpl(this._self, this._then);

  final UserTreeProfile _self;
  final $Res Function(UserTreeProfile) _then;

/// Create a copy of UserTreeProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,}) {
  return _then(UserTreeProfile(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserTreeProfile].
extension UserTreeProfilePatterns on UserTreeProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserTreeProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserTreeProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserTreeProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserTreeProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserTreeProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserTreeProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserTreeProfile() when $default != null:
return $default(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code)  $default,) {final _that = this;
switch (_that) {
case _UserTreeProfile():
return $default(_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code)?  $default,) {final _that = this;
switch (_that) {
case _UserTreeProfile() when $default != null:
return $default(_that.code);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _UserTreeProfile implements UserTreeProfile {
  const _UserTreeProfile({required this.code});
  factory _UserTreeProfile.fromJson(Map<String, dynamic> json) => _$UserTreeProfileFromJson(json);

@override final  String code;

/// Create a copy of UserTreeProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserTreeProfileCopyWith<_UserTreeProfile> get copyWith => __$UserTreeProfileCopyWithImpl<_UserTreeProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserTreeProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserTreeProfile&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code);
}

@override
String toString() {
    return 'UserTreeProfile(code: $code)';
}


}

/// @nodoc
abstract mixin class _$UserTreeProfileCopyWith<$Res> implements $UserTreeProfileCopyWith<$Res> {
  factory _$UserTreeProfileCopyWith(_UserTreeProfile value, $Res Function(_UserTreeProfile) _then) = __$UserTreeProfileCopyWithImpl;
@override @useResult
$Res call({
 String code
});




}
/// @nodoc
class __$UserTreeProfileCopyWithImpl<$Res>
    implements _$UserTreeProfileCopyWith<$Res> {
  __$UserTreeProfileCopyWithImpl(this._self, this._then);

  final _UserTreeProfile _self;
  final $Res Function(_UserTreeProfile) _then;

/// Create a copy of UserTreeProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(_UserTreeProfile(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

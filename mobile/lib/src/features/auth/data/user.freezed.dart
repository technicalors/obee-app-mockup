// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get name; String get username;@JsonKey(required: true) String? get email;@JsonKey(required: true) String? get avatar;@JsonKey(name: 'organization_id', required: true) String? get organizationId;@JsonKey(required: true) OrganizationRef? get organization;@JsonKey(name: 'root_organization_id') String? get rootOrganizationId; UserProfile? get profile; List<RoleRef> get roles;@JsonKey(name: 'email_verified_at', required: true) String? get emailVerifiedAt;@JsonKey(name: 'supabase_id', required: true) String? get supabaseId;@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String get createdAt;@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String get updatedAt; List<PermissionRef>? get permissions;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as User;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.avatar, _this.avatar) || other.avatar == _this.avatar)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.organization, _this.organization) || other.organization == _this.organization)&&(identical(other.rootOrganizationId, _this.rootOrganizationId) || other.rootOrganizationId == _this.rootOrganizationId)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&const DeepCollectionEquality().equals(other.roles, _this.roles)&&(identical(other.emailVerifiedAt, _this.emailVerifiedAt) || other.emailVerifiedAt == _this.emailVerifiedAt)&&(identical(other.supabaseId, _this.supabaseId) || other.supabaseId == _this.supabaseId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.permissions, _this.permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as User;
  return Object.hash(runtimeType,_this.id,_this.name,_this.username,_this.email,_this.avatar,_this.organizationId,_this.organization,_this.rootOrganizationId,_this.profile,const DeepCollectionEquality().hash(_this.roles),_this.emailVerifiedAt,_this.supabaseId,_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.permissions));
}

@override
String toString() {
  final _this = this as User;
  return 'User(id: ${_this.id}, name: ${_this.name}, username: ${_this.username}, email: ${_this.email}, avatar: ${_this.avatar}, organizationId: ${_this.organizationId}, organization: ${_this.organization}, rootOrganizationId: ${_this.rootOrganizationId}, profile: ${_this.profile}, roles: ${_this.roles}, emailVerifiedAt: ${_this.emailVerifiedAt}, supabaseId: ${_this.supabaseId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, permissions: ${_this.permissions})';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String username,@JsonKey(required: true) String? email,@JsonKey(required: true) String? avatar,@JsonKey(name: 'organization_id', required: true) String? organizationId,@JsonKey(required: true) OrganizationRef? organization,@JsonKey(name: 'root_organization_id') String? rootOrganizationId, UserProfile? profile, List<RoleRef> roles,@JsonKey(name: 'email_verified_at', required: true) String? emailVerifiedAt,@JsonKey(name: 'supabase_id', required: true) String? supabaseId,@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String createdAt,@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String updatedAt, List<PermissionRef>? permissions
});


$OrganizationRefCopyWith<$Res>? get organization;$UserProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? username = null,Object? email = freezed,Object? avatar = freezed,Object? organizationId = freezed,Object? organization = freezed,Object? rootOrganizationId = freezed,Object? profile = freezed,Object? roles = null,Object? emailVerifiedAt = freezed,Object? supabaseId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? permissions = freezed,}) {
  return _then(User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as OrganizationRef?,rootOrganizationId: freezed == rootOrganizationId ? _self.rootOrganizationId : rootOrganizationId // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<RoleRef>,emailVerifiedAt: freezed == emailVerifiedAt ? _self.emailVerifiedAt : emailVerifiedAt // ignore: cast_nullable_to_non_nullable
as String?,supabaseId: freezed == supabaseId ? _self.supabaseId : supabaseId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,permissions: freezed == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<PermissionRef>?,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationRefCopyWith<$Res>? get organization {
    if (_self.organization == null) {
    return null;
  }

  return $OrganizationRefCopyWith<$Res>(_self.organization!, (value) {
    return _then(_self.copyWith(organization: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String username, @JsonKey(required: true)  String? email, @JsonKey(required: true)  String? avatar, @JsonKey(name: 'organization_id', required: true)  String? organizationId, @JsonKey(required: true)  OrganizationRef? organization, @JsonKey(name: 'root_organization_id')  String? rootOrganizationId,  UserProfile? profile,  List<RoleRef> roles, @JsonKey(name: 'email_verified_at', required: true)  String? emailVerifiedAt, @JsonKey(name: 'supabase_id', required: true)  String? supabaseId, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt,  List<PermissionRef>? permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.email,_that.avatar,_that.organizationId,_that.organization,_that.rootOrganizationId,_that.profile,_that.roles,_that.emailVerifiedAt,_that.supabaseId,_that.createdAt,_that.updatedAt,_that.permissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String username, @JsonKey(required: true)  String? email, @JsonKey(required: true)  String? avatar, @JsonKey(name: 'organization_id', required: true)  String? organizationId, @JsonKey(required: true)  OrganizationRef? organization, @JsonKey(name: 'root_organization_id')  String? rootOrganizationId,  UserProfile? profile,  List<RoleRef> roles, @JsonKey(name: 'email_verified_at', required: true)  String? emailVerifiedAt, @JsonKey(name: 'supabase_id', required: true)  String? supabaseId, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt,  List<PermissionRef>? permissions)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.name,_that.username,_that.email,_that.avatar,_that.organizationId,_that.organization,_that.rootOrganizationId,_that.profile,_that.roles,_that.emailVerifiedAt,_that.supabaseId,_that.createdAt,_that.updatedAt,_that.permissions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String username, @JsonKey(required: true)  String? email, @JsonKey(required: true)  String? avatar, @JsonKey(name: 'organization_id', required: true)  String? organizationId, @JsonKey(required: true)  OrganizationRef? organization, @JsonKey(name: 'root_organization_id')  String? rootOrganizationId,  UserProfile? profile,  List<RoleRef> roles, @JsonKey(name: 'email_verified_at', required: true)  String? emailVerifiedAt, @JsonKey(name: 'supabase_id', required: true)  String? supabaseId, @JsonKey(name: 'created_at', required: true, disallowNullValue: true)  String createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)  String updatedAt,  List<PermissionRef>? permissions)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.email,_that.avatar,_that.organizationId,_that.organization,_that.rootOrganizationId,_that.profile,_that.roles,_that.emailVerifiedAt,_that.supabaseId,_that.createdAt,_that.updatedAt,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _User implements User {
  const _User({required this.id, required this.name, required this.username, @JsonKey(required: true) required this.email, @JsonKey(required: true) required this.avatar, @JsonKey(name: 'organization_id', required: true) this.organizationId, @JsonKey(required: true) this.organization, @JsonKey(name: 'root_organization_id') this.rootOrganizationId, this.profile,  List<RoleRef> roles = const <RoleRef>[], @JsonKey(name: 'email_verified_at', required: true) this.emailVerifiedAt, @JsonKey(name: 'supabase_id', required: true) this.supabaseId, @JsonKey(name: 'created_at', required: true, disallowNullValue: true) required this.createdAt, @JsonKey(name: 'updated_at', required: true, disallowNullValue: true) required this.updatedAt,  List<PermissionRef>? permissions}): _roles = roles,_permissions = permissions;
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String username;
@override@JsonKey(required: true) final  String? email;
@override@JsonKey(required: true) final  String? avatar;
@override@JsonKey(name: 'organization_id', required: true) final  String? organizationId;
@override@JsonKey(required: true) final  OrganizationRef? organization;
@override@JsonKey(name: 'root_organization_id') final  String? rootOrganizationId;
@override final  UserProfile? profile;
 final  List<RoleRef> _roles;
@override@JsonKey() List<RoleRef> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override@JsonKey(name: 'email_verified_at', required: true) final  String? emailVerifiedAt;
@override@JsonKey(name: 'supabase_id', required: true) final  String? supabaseId;
@override@JsonKey(name: 'created_at', required: true, disallowNullValue: true) final  String createdAt;
@override@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) final  String updatedAt;
 final  List<PermissionRef>? _permissions;
@override List<PermissionRef>? get permissions {
  final value = _permissions;
  if (value == null) return null;
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.rootOrganizationId, rootOrganizationId) || other.rootOrganizationId == rootOrganizationId)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.roles, _roles)&&(identical(other.emailVerifiedAt, emailVerifiedAt) || other.emailVerifiedAt == emailVerifiedAt)&&(identical(other.supabaseId, supabaseId) || other.supabaseId == supabaseId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.permissions, _permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,username,email,avatar,organizationId,organization,rootOrganizationId,profile,const DeepCollectionEquality().hash(_roles),emailVerifiedAt,supabaseId,createdAt,updatedAt,const DeepCollectionEquality().hash(_permissions));
}

@override
String toString() {
    return 'User(id: $id, name: $name, username: $username, email: $email, avatar: $avatar, organizationId: $organizationId, organization: $organization, rootOrganizationId: $rootOrganizationId, profile: $profile, roles: $roles, emailVerifiedAt: $emailVerifiedAt, supabaseId: $supabaseId, createdAt: $createdAt, updatedAt: $updatedAt, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String username,@JsonKey(required: true) String? email,@JsonKey(required: true) String? avatar,@JsonKey(name: 'organization_id', required: true) String? organizationId,@JsonKey(required: true) OrganizationRef? organization,@JsonKey(name: 'root_organization_id') String? rootOrganizationId, UserProfile? profile, List<RoleRef> roles,@JsonKey(name: 'email_verified_at', required: true) String? emailVerifiedAt,@JsonKey(name: 'supabase_id', required: true) String? supabaseId,@JsonKey(name: 'created_at', required: true, disallowNullValue: true) String createdAt,@JsonKey(name: 'updated_at', required: true, disallowNullValue: true) String updatedAt, List<PermissionRef>? permissions
});


@override $OrganizationRefCopyWith<$Res>? get organization;@override $UserProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? username = null,Object? email = freezed,Object? avatar = freezed,Object? organizationId = freezed,Object? organization = freezed,Object? rootOrganizationId = freezed,Object? profile = freezed,Object? roles = null,Object? emailVerifiedAt = freezed,Object? supabaseId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? permissions = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as OrganizationRef?,rootOrganizationId: freezed == rootOrganizationId ? _self.rootOrganizationId : rootOrganizationId // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<RoleRef>,emailVerifiedAt: freezed == emailVerifiedAt ? _self.emailVerifiedAt : emailVerifiedAt // ignore: cast_nullable_to_non_nullable
as String?,supabaseId: freezed == supabaseId ? _self.supabaseId : supabaseId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,permissions: freezed == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<PermissionRef>?,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationRefCopyWith<$Res>? get organization {
    if (_self.organization == null) {
    return null;
  }

  return $OrganizationRefCopyWith<$Res>(_self.organization!, (value) {
    return _then(_self.copyWith(organization: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$RoleRef {

 String get id; String get name; String? get description;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of RoleRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleRefCopyWith<RoleRef> get copyWith => _$RoleRefCopyWithImpl<RoleRef>(this as RoleRef, _$identity);

  /// Serializes this RoleRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoleRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoleRef;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as RoleRef;
  return 'RoleRef(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $RoleRefCopyWith<$Res>  {
  factory $RoleRefCopyWith(RoleRef value, $Res Function(RoleRef) _then) = _$RoleRefCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$RoleRefCopyWithImpl<$Res>
    implements $RoleRefCopyWith<$Res> {
  _$RoleRefCopyWithImpl(this._self, this._then);

  final RoleRef _self;
  final $Res Function(RoleRef) _then;

/// Create a copy of RoleRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(RoleRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleRef].
extension RoleRefPatterns on RoleRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleRef value)  $default,){
final _that = this;
switch (_that) {
case _RoleRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleRef value)?  $default,){
final _that = this;
switch (_that) {
case _RoleRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleRef() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RoleRef():
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RoleRef() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _RoleRef implements RoleRef {
  const _RoleRef({required this.id, required this.name, required this.description, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _RoleRef.fromJson(Map<String, dynamic> json) => _$RoleRefFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of RoleRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleRefCopyWith<_RoleRef> get copyWith => __$RoleRefCopyWithImpl<_RoleRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,createdAt,updatedAt);
}

@override
String toString() {
    return 'RoleRef(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RoleRefCopyWith<$Res> implements $RoleRefCopyWith<$Res> {
  factory _$RoleRefCopyWith(_RoleRef value, $Res Function(_RoleRef) _then) = __$RoleRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$RoleRefCopyWithImpl<$Res>
    implements _$RoleRefCopyWith<$Res> {
  __$RoleRefCopyWithImpl(this._self, this._then);

  final _RoleRef _self;
  final $Res Function(_RoleRef) _then;

/// Create a copy of RoleRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RoleRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PermissionRef {

 String get id; String get name;@JsonKey(required: true) String? get description;@JsonKey(name: 'created_at', required: true) String? get createdAt;@JsonKey(name: 'updated_at', required: true) String? get updatedAt;
/// Create a copy of PermissionRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionRefCopyWith<PermissionRef> get copyWith => _$PermissionRefCopyWithImpl<PermissionRef>(this as PermissionRef, _$identity);

  /// Serializes this PermissionRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PermissionRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PermissionRef;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as PermissionRef;
  return 'PermissionRef(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $PermissionRefCopyWith<$Res>  {
  factory $PermissionRefCopyWith(PermissionRef value, $Res Function(PermissionRef) _then) = _$PermissionRefCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(required: true) String? description,@JsonKey(name: 'created_at', required: true) String? createdAt,@JsonKey(name: 'updated_at', required: true) String? updatedAt
});




}
/// @nodoc
class _$PermissionRefCopyWithImpl<$Res>
    implements $PermissionRefCopyWith<$Res> {
  _$PermissionRefCopyWithImpl(this._self, this._then);

  final PermissionRef _self;
  final $Res Function(PermissionRef) _then;

/// Create a copy of PermissionRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(PermissionRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PermissionRef].
extension PermissionRefPatterns on PermissionRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PermissionRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PermissionRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PermissionRef value)  $default,){
final _that = this;
switch (_that) {
case _PermissionRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PermissionRef value)?  $default,){
final _that = this;
switch (_that) {
case _PermissionRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(required: true)  String? description, @JsonKey(name: 'created_at', required: true)  String? createdAt, @JsonKey(name: 'updated_at', required: true)  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PermissionRef() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(required: true)  String? description, @JsonKey(name: 'created_at', required: true)  String? createdAt, @JsonKey(name: 'updated_at', required: true)  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PermissionRef():
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(required: true)  String? description, @JsonKey(name: 'created_at', required: true)  String? createdAt, @JsonKey(name: 'updated_at', required: true)  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PermissionRef() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _PermissionRef implements PermissionRef {
  const _PermissionRef({required this.id, required this.name, @JsonKey(required: true) required this.description, @JsonKey(name: 'created_at', required: true) required this.createdAt, @JsonKey(name: 'updated_at', required: true) required this.updatedAt});
  factory _PermissionRef.fromJson(Map<String, dynamic> json) => _$PermissionRefFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(required: true) final  String? description;
@override@JsonKey(name: 'created_at', required: true) final  String? createdAt;
@override@JsonKey(name: 'updated_at', required: true) final  String? updatedAt;

/// Create a copy of PermissionRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PermissionRefCopyWith<_PermissionRef> get copyWith => __$PermissionRefCopyWithImpl<_PermissionRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PermissionRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PermissionRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,createdAt,updatedAt);
}

@override
String toString() {
    return 'PermissionRef(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PermissionRefCopyWith<$Res> implements $PermissionRefCopyWith<$Res> {
  factory _$PermissionRefCopyWith(_PermissionRef value, $Res Function(_PermissionRef) _then) = __$PermissionRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(required: true) String? description,@JsonKey(name: 'created_at', required: true) String? createdAt,@JsonKey(name: 'updated_at', required: true) String? updatedAt
});




}
/// @nodoc
class __$PermissionRefCopyWithImpl<$Res>
    implements _$PermissionRefCopyWith<$Res> {
  __$PermissionRefCopyWithImpl(this._self, this._then);

  final _PermissionRef _self;
  final $Res Function(_PermissionRef) _then;

/// Create a copy of PermissionRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PermissionRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_user_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateUserInput {

 String get name;@JsonKey(includeIfNull: false) EditableUserProfile? get profile;
/// Create a copy of UpdateUserInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserInputCopyWith<UpdateUserInput> get copyWith => _$UpdateUserInputCopyWithImpl<UpdateUserInput>(this as UpdateUserInput, _$identity);

  /// Serializes this UpdateUserInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateUserInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserInput&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.profile, _this.profile) || other.profile == _this.profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateUserInput;
  return Object.hash(runtimeType,_this.name,_this.profile);
}

@override
String toString() {
  final _this = this as UpdateUserInput;
  return 'UpdateUserInput(name: ${_this.name}, profile: ${_this.profile})';
}


}

/// @nodoc
abstract mixin class $UpdateUserInputCopyWith<$Res>  {
  factory $UpdateUserInputCopyWith(UpdateUserInput value, $Res Function(UpdateUserInput) _then) = _$UpdateUserInputCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(includeIfNull: false) EditableUserProfile? profile
});


$EditableUserProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$UpdateUserInputCopyWithImpl<$Res>
    implements $UpdateUserInputCopyWith<$Res> {
  _$UpdateUserInputCopyWithImpl(this._self, this._then);

  final UpdateUserInput _self;
  final $Res Function(UpdateUserInput) _then;

/// Create a copy of UpdateUserInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? profile = freezed,}) {
  return _then(UpdateUserInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as EditableUserProfile?,
  ));
}
/// Create a copy of UpdateUserInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditableUserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $EditableUserProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateUserInput].
extension UpdateUserInputPatterns on UpdateUserInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateUserInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateUserInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdateUserInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateUserInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateUserInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(includeIfNull: false)  EditableUserProfile? profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateUserInput() when $default != null:
return $default(_that.name,_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(includeIfNull: false)  EditableUserProfile? profile)  $default,) {final _that = this;
switch (_that) {
case _UpdateUserInput():
return $default(_that.name,_that.profile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(includeIfNull: false)  EditableUserProfile? profile)?  $default,) {final _that = this;
switch (_that) {
case _UpdateUserInput() when $default != null:
return $default(_that.name,_that.profile);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _UpdateUserInput implements UpdateUserInput {
  const _UpdateUserInput({required this.name, @JsonKey(includeIfNull: false) this.profile});
  factory _UpdateUserInput.fromJson(Map<String, dynamic> json) => _$UpdateUserInputFromJson(json);

@override final  String name;
@override@JsonKey(includeIfNull: false) final  EditableUserProfile? profile;

/// Create a copy of UpdateUserInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserInputCopyWith<_UpdateUserInput> get copyWith => __$UpdateUserInputCopyWithImpl<_UpdateUserInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateUserInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserInput&&(identical(other.name, name) || other.name == name)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,profile);
}

@override
String toString() {
    return 'UpdateUserInput(name: $name, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserInputCopyWith<$Res> implements $UpdateUserInputCopyWith<$Res> {
  factory _$UpdateUserInputCopyWith(_UpdateUserInput value, $Res Function(_UpdateUserInput) _then) = __$UpdateUserInputCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(includeIfNull: false) EditableUserProfile? profile
});


@override $EditableUserProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$UpdateUserInputCopyWithImpl<$Res>
    implements _$UpdateUserInputCopyWith<$Res> {
  __$UpdateUserInputCopyWithImpl(this._self, this._then);

  final _UpdateUserInput _self;
  final $Res Function(_UpdateUserInput) _then;

/// Create a copy of UpdateUserInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? profile = freezed,}) {
  return _then(_UpdateUserInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as EditableUserProfile?,
  ));
}

/// Create a copy of UpdateUserInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditableUserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $EditableUserProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$EditableUserProfile {

@JsonKey(name: 'phone_number') String? get phoneNumber; String? get address; String? get sex; String? get birthday;
/// Create a copy of EditableUserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditableUserProfileCopyWith<EditableUserProfile> get copyWith => _$EditableUserProfileCopyWithImpl<EditableUserProfile>(this as EditableUserProfile, _$identity);

  /// Serializes this EditableUserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EditableUserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditableUserProfile&&(identical(other.phoneNumber, _this.phoneNumber) || other.phoneNumber == _this.phoneNumber)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.sex, _this.sex) || other.sex == _this.sex)&&(identical(other.birthday, _this.birthday) || other.birthday == _this.birthday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EditableUserProfile;
  return Object.hash(runtimeType,_this.phoneNumber,_this.address,_this.sex,_this.birthday);
}

@override
String toString() {
  final _this = this as EditableUserProfile;
  return 'EditableUserProfile(phoneNumber: ${_this.phoneNumber}, address: ${_this.address}, sex: ${_this.sex}, birthday: ${_this.birthday})';
}


}

/// @nodoc
abstract mixin class $EditableUserProfileCopyWith<$Res>  {
  factory $EditableUserProfileCopyWith(EditableUserProfile value, $Res Function(EditableUserProfile) _then) = _$EditableUserProfileCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'phone_number') String? phoneNumber, String? address, String? sex, String? birthday
});




}
/// @nodoc
class _$EditableUserProfileCopyWithImpl<$Res>
    implements $EditableUserProfileCopyWith<$Res> {
  _$EditableUserProfileCopyWithImpl(this._self, this._then);

  final EditableUserProfile _self;
  final $Res Function(EditableUserProfile) _then;

/// Create a copy of EditableUserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneNumber = freezed,Object? address = freezed,Object? sex = freezed,Object? birthday = freezed,}) {
  return _then(EditableUserProfile(
phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EditableUserProfile].
extension EditableUserProfilePatterns on EditableUserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditableUserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditableUserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditableUserProfile value)  $default,){
final _that = this;
switch (_that) {
case _EditableUserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditableUserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _EditableUserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number')  String? phoneNumber,  String? address,  String? sex,  String? birthday)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditableUserProfile() when $default != null:
return $default(_that.phoneNumber,_that.address,_that.sex,_that.birthday);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number')  String? phoneNumber,  String? address,  String? sex,  String? birthday)  $default,) {final _that = this;
switch (_that) {
case _EditableUserProfile():
return $default(_that.phoneNumber,_that.address,_that.sex,_that.birthday);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'phone_number')  String? phoneNumber,  String? address,  String? sex,  String? birthday)?  $default,) {final _that = this;
switch (_that) {
case _EditableUserProfile() when $default != null:
return $default(_that.phoneNumber,_that.address,_that.sex,_that.birthday);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _EditableUserProfile implements EditableUserProfile {
  const _EditableUserProfile({@JsonKey(name: 'phone_number') required this.phoneNumber, required this.address, required this.sex, required this.birthday});
  factory _EditableUserProfile.fromJson(Map<String, dynamic> json) => _$EditableUserProfileFromJson(json);

@override@JsonKey(name: 'phone_number') final  String? phoneNumber;
@override final  String? address;
@override final  String? sex;
@override final  String? birthday;

/// Create a copy of EditableUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditableUserProfileCopyWith<_EditableUserProfile> get copyWith => __$EditableUserProfileCopyWithImpl<_EditableUserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditableUserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditableUserProfile&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.address, address) || other.address == address)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthday, birthday) || other.birthday == birthday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,phoneNumber,address,sex,birthday);
}

@override
String toString() {
    return 'EditableUserProfile(phoneNumber: $phoneNumber, address: $address, sex: $sex, birthday: $birthday)';
}


}

/// @nodoc
abstract mixin class _$EditableUserProfileCopyWith<$Res> implements $EditableUserProfileCopyWith<$Res> {
  factory _$EditableUserProfileCopyWith(_EditableUserProfile value, $Res Function(_EditableUserProfile) _then) = __$EditableUserProfileCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'phone_number') String? phoneNumber, String? address, String? sex, String? birthday
});




}
/// @nodoc
class __$EditableUserProfileCopyWithImpl<$Res>
    implements _$EditableUserProfileCopyWith<$Res> {
  __$EditableUserProfileCopyWithImpl(this._self, this._then);

  final _EditableUserProfile _self;
  final $Res Function(_EditableUserProfile) _then;

/// Create a copy of EditableUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneNumber = freezed,Object? address = freezed,Object? sex = freezed,Object? birthday = freezed,}) {
  return _then(_EditableUserProfile(
phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

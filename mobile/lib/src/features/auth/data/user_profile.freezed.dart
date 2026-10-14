// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

@JsonKey(name: 'phone_number', required: true, fromJson: _nullablePhoneFromJson) String? get phoneNumber;@JsonKey(required: true, fromJson: _nullableProfileDateFromJson) String? get birthday;@JsonKey(required: true) String? get address;@JsonKey(required: true, fromJson: _nullableSexFromJson) String? get sex;@JsonKey(required: true, disallowNullValue: true) String get code;@JsonKey(name: 'position_id', required: true) String? get positionId;@JsonKey(required: true) PositionRef? get position;@JsonKey(name: 'joined_at', required: true, fromJson: _nullableProfileDateFromJson) String? get joinedAt;@JsonKey(name: 'starting_date', required: true, fromJson: _nullableProfileDateFromJson) String? get startingDate;@JsonKey(name: 'education_level', required: true) String? get educationLevel;@JsonKey(name: 'employee_type', required: true) String? get employeeType;@JsonKey(name: 'citizen_identification_card', required: true) String? get citizenIdentificationCard;@JsonKey(name: 'social_insurance_number', required: true) String? get socialInsuranceNumber;@JsonKey(name: 'health_insurance_card_number', required: true) String? get healthInsuranceCardNumber;@JsonKey(name: 'personal_tax_identification_number', required: true) String? get personalTaxIdentificationNumber;@JsonKey(name: 'dependent_tax_identification_number', required: true) String? get dependentTaxIdentificationNumber;@JsonKey(name: 'bank_account_number', required: true) String? get bankAccountNumber;@JsonKey(required: true) double? get age;@JsonKey(required: true) double? get seniority;@JsonKey(name: 'created_at', required: true) String? get createdAt;@JsonKey(name: 'updated_at', required: true) String? get updatedAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.phoneNumber, _this.phoneNumber) || other.phoneNumber == _this.phoneNumber)&&(identical(other.birthday, _this.birthday) || other.birthday == _this.birthday)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.sex, _this.sex) || other.sex == _this.sex)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.positionId, _this.positionId) || other.positionId == _this.positionId)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt)&&(identical(other.startingDate, _this.startingDate) || other.startingDate == _this.startingDate)&&(identical(other.educationLevel, _this.educationLevel) || other.educationLevel == _this.educationLevel)&&(identical(other.employeeType, _this.employeeType) || other.employeeType == _this.employeeType)&&(identical(other.citizenIdentificationCard, _this.citizenIdentificationCard) || other.citizenIdentificationCard == _this.citizenIdentificationCard)&&(identical(other.socialInsuranceNumber, _this.socialInsuranceNumber) || other.socialInsuranceNumber == _this.socialInsuranceNumber)&&(identical(other.healthInsuranceCardNumber, _this.healthInsuranceCardNumber) || other.healthInsuranceCardNumber == _this.healthInsuranceCardNumber)&&(identical(other.personalTaxIdentificationNumber, _this.personalTaxIdentificationNumber) || other.personalTaxIdentificationNumber == _this.personalTaxIdentificationNumber)&&(identical(other.dependentTaxIdentificationNumber, _this.dependentTaxIdentificationNumber) || other.dependentTaxIdentificationNumber == _this.dependentTaxIdentificationNumber)&&(identical(other.bankAccountNumber, _this.bankAccountNumber) || other.bankAccountNumber == _this.bankAccountNumber)&&(identical(other.age, _this.age) || other.age == _this.age)&&(identical(other.seniority, _this.seniority) || other.seniority == _this.seniority)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserProfile;
  return Object.hashAll([runtimeType,_this.phoneNumber,_this.birthday,_this.address,_this.sex,_this.code,_this.positionId,_this.position,_this.joinedAt,_this.startingDate,_this.educationLevel,_this.employeeType,_this.citizenIdentificationCard,_this.socialInsuranceNumber,_this.healthInsuranceCardNumber,_this.personalTaxIdentificationNumber,_this.dependentTaxIdentificationNumber,_this.bankAccountNumber,_this.age,_this.seniority,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as UserProfile;
  return 'UserProfile(phoneNumber: ${_this.phoneNumber}, birthday: ${_this.birthday}, address: ${_this.address}, sex: ${_this.sex}, code: ${_this.code}, positionId: ${_this.positionId}, position: ${_this.position}, joinedAt: ${_this.joinedAt}, startingDate: ${_this.startingDate}, educationLevel: ${_this.educationLevel}, employeeType: ${_this.employeeType}, citizenIdentificationCard: ${_this.citizenIdentificationCard}, socialInsuranceNumber: ${_this.socialInsuranceNumber}, healthInsuranceCardNumber: ${_this.healthInsuranceCardNumber}, personalTaxIdentificationNumber: ${_this.personalTaxIdentificationNumber}, dependentTaxIdentificationNumber: ${_this.dependentTaxIdentificationNumber}, bankAccountNumber: ${_this.bankAccountNumber}, age: ${_this.age}, seniority: ${_this.seniority}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'phone_number', required: true, fromJson: _nullablePhoneFromJson) String? phoneNumber,@JsonKey(required: true, fromJson: _nullableProfileDateFromJson) String? birthday,@JsonKey(required: true) String? address,@JsonKey(required: true, fromJson: _nullableSexFromJson) String? sex,@JsonKey(required: true, disallowNullValue: true) String code,@JsonKey(name: 'position_id', required: true) String? positionId,@JsonKey(required: true) PositionRef? position,@JsonKey(name: 'joined_at', required: true, fromJson: _nullableProfileDateFromJson) String? joinedAt,@JsonKey(name: 'starting_date', required: true, fromJson: _nullableProfileDateFromJson) String? startingDate,@JsonKey(name: 'education_level', required: true) String? educationLevel,@JsonKey(name: 'employee_type', required: true) String? employeeType,@JsonKey(name: 'citizen_identification_card', required: true) String? citizenIdentificationCard,@JsonKey(name: 'social_insurance_number', required: true) String? socialInsuranceNumber,@JsonKey(name: 'health_insurance_card_number', required: true) String? healthInsuranceCardNumber,@JsonKey(name: 'personal_tax_identification_number', required: true) String? personalTaxIdentificationNumber,@JsonKey(name: 'dependent_tax_identification_number', required: true) String? dependentTaxIdentificationNumber,@JsonKey(name: 'bank_account_number', required: true) String? bankAccountNumber,@JsonKey(required: true) double? age,@JsonKey(required: true) double? seniority,@JsonKey(name: 'created_at', required: true) String? createdAt,@JsonKey(name: 'updated_at', required: true) String? updatedAt
});


$PositionRefCopyWith<$Res>? get position;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneNumber = freezed,Object? birthday = freezed,Object? address = freezed,Object? sex = freezed,Object? code = null,Object? positionId = freezed,Object? position = freezed,Object? joinedAt = freezed,Object? startingDate = freezed,Object? educationLevel = freezed,Object? employeeType = freezed,Object? citizenIdentificationCard = freezed,Object? socialInsuranceNumber = freezed,Object? healthInsuranceCardNumber = freezed,Object? personalTaxIdentificationNumber = freezed,Object? dependentTaxIdentificationNumber = freezed,Object? bankAccountNumber = freezed,Object? age = freezed,Object? seniority = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(UserProfile(
phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,positionId: freezed == positionId ? _self.positionId : positionId // ignore: cast_nullable_to_non_nullable
as String?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as PositionRef?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,startingDate: freezed == startingDate ? _self.startingDate : startingDate // ignore: cast_nullable_to_non_nullable
as String?,educationLevel: freezed == educationLevel ? _self.educationLevel : educationLevel // ignore: cast_nullable_to_non_nullable
as String?,employeeType: freezed == employeeType ? _self.employeeType : employeeType // ignore: cast_nullable_to_non_nullable
as String?,citizenIdentificationCard: freezed == citizenIdentificationCard ? _self.citizenIdentificationCard : citizenIdentificationCard // ignore: cast_nullable_to_non_nullable
as String?,socialInsuranceNumber: freezed == socialInsuranceNumber ? _self.socialInsuranceNumber : socialInsuranceNumber // ignore: cast_nullable_to_non_nullable
as String?,healthInsuranceCardNumber: freezed == healthInsuranceCardNumber ? _self.healthInsuranceCardNumber : healthInsuranceCardNumber // ignore: cast_nullable_to_non_nullable
as String?,personalTaxIdentificationNumber: freezed == personalTaxIdentificationNumber ? _self.personalTaxIdentificationNumber : personalTaxIdentificationNumber // ignore: cast_nullable_to_non_nullable
as String?,dependentTaxIdentificationNumber: freezed == dependentTaxIdentificationNumber ? _self.dependentTaxIdentificationNumber : dependentTaxIdentificationNumber // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as double?,seniority: freezed == seniority ? _self.seniority : seniority // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PositionRefCopyWith<$Res>? get position {
    if (_self.position == null) {
    return null;
  }

  return $PositionRefCopyWith<$Res>(_self.position!, (value) {
    return _then(_self.copyWith(position: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number', required: true, fromJson: _nullablePhoneFromJson)  String? phoneNumber, @JsonKey(required: true, fromJson: _nullableProfileDateFromJson)  String? birthday, @JsonKey(required: true)  String? address, @JsonKey(required: true, fromJson: _nullableSexFromJson)  String? sex, @JsonKey(required: true, disallowNullValue: true)  String code, @JsonKey(name: 'position_id', required: true)  String? positionId, @JsonKey(required: true)  PositionRef? position, @JsonKey(name: 'joined_at', required: true, fromJson: _nullableProfileDateFromJson)  String? joinedAt, @JsonKey(name: 'starting_date', required: true, fromJson: _nullableProfileDateFromJson)  String? startingDate, @JsonKey(name: 'education_level', required: true)  String? educationLevel, @JsonKey(name: 'employee_type', required: true)  String? employeeType, @JsonKey(name: 'citizen_identification_card', required: true)  String? citizenIdentificationCard, @JsonKey(name: 'social_insurance_number', required: true)  String? socialInsuranceNumber, @JsonKey(name: 'health_insurance_card_number', required: true)  String? healthInsuranceCardNumber, @JsonKey(name: 'personal_tax_identification_number', required: true)  String? personalTaxIdentificationNumber, @JsonKey(name: 'dependent_tax_identification_number', required: true)  String? dependentTaxIdentificationNumber, @JsonKey(name: 'bank_account_number', required: true)  String? bankAccountNumber, @JsonKey(required: true)  double? age, @JsonKey(required: true)  double? seniority, @JsonKey(name: 'created_at', required: true)  String? createdAt, @JsonKey(name: 'updated_at', required: true)  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.phoneNumber,_that.birthday,_that.address,_that.sex,_that.code,_that.positionId,_that.position,_that.joinedAt,_that.startingDate,_that.educationLevel,_that.employeeType,_that.citizenIdentificationCard,_that.socialInsuranceNumber,_that.healthInsuranceCardNumber,_that.personalTaxIdentificationNumber,_that.dependentTaxIdentificationNumber,_that.bankAccountNumber,_that.age,_that.seniority,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number', required: true, fromJson: _nullablePhoneFromJson)  String? phoneNumber, @JsonKey(required: true, fromJson: _nullableProfileDateFromJson)  String? birthday, @JsonKey(required: true)  String? address, @JsonKey(required: true, fromJson: _nullableSexFromJson)  String? sex, @JsonKey(required: true, disallowNullValue: true)  String code, @JsonKey(name: 'position_id', required: true)  String? positionId, @JsonKey(required: true)  PositionRef? position, @JsonKey(name: 'joined_at', required: true, fromJson: _nullableProfileDateFromJson)  String? joinedAt, @JsonKey(name: 'starting_date', required: true, fromJson: _nullableProfileDateFromJson)  String? startingDate, @JsonKey(name: 'education_level', required: true)  String? educationLevel, @JsonKey(name: 'employee_type', required: true)  String? employeeType, @JsonKey(name: 'citizen_identification_card', required: true)  String? citizenIdentificationCard, @JsonKey(name: 'social_insurance_number', required: true)  String? socialInsuranceNumber, @JsonKey(name: 'health_insurance_card_number', required: true)  String? healthInsuranceCardNumber, @JsonKey(name: 'personal_tax_identification_number', required: true)  String? personalTaxIdentificationNumber, @JsonKey(name: 'dependent_tax_identification_number', required: true)  String? dependentTaxIdentificationNumber, @JsonKey(name: 'bank_account_number', required: true)  String? bankAccountNumber, @JsonKey(required: true)  double? age, @JsonKey(required: true)  double? seniority, @JsonKey(name: 'created_at', required: true)  String? createdAt, @JsonKey(name: 'updated_at', required: true)  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.phoneNumber,_that.birthday,_that.address,_that.sex,_that.code,_that.positionId,_that.position,_that.joinedAt,_that.startingDate,_that.educationLevel,_that.employeeType,_that.citizenIdentificationCard,_that.socialInsuranceNumber,_that.healthInsuranceCardNumber,_that.personalTaxIdentificationNumber,_that.dependentTaxIdentificationNumber,_that.bankAccountNumber,_that.age,_that.seniority,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'phone_number', required: true, fromJson: _nullablePhoneFromJson)  String? phoneNumber, @JsonKey(required: true, fromJson: _nullableProfileDateFromJson)  String? birthday, @JsonKey(required: true)  String? address, @JsonKey(required: true, fromJson: _nullableSexFromJson)  String? sex, @JsonKey(required: true, disallowNullValue: true)  String code, @JsonKey(name: 'position_id', required: true)  String? positionId, @JsonKey(required: true)  PositionRef? position, @JsonKey(name: 'joined_at', required: true, fromJson: _nullableProfileDateFromJson)  String? joinedAt, @JsonKey(name: 'starting_date', required: true, fromJson: _nullableProfileDateFromJson)  String? startingDate, @JsonKey(name: 'education_level', required: true)  String? educationLevel, @JsonKey(name: 'employee_type', required: true)  String? employeeType, @JsonKey(name: 'citizen_identification_card', required: true)  String? citizenIdentificationCard, @JsonKey(name: 'social_insurance_number', required: true)  String? socialInsuranceNumber, @JsonKey(name: 'health_insurance_card_number', required: true)  String? healthInsuranceCardNumber, @JsonKey(name: 'personal_tax_identification_number', required: true)  String? personalTaxIdentificationNumber, @JsonKey(name: 'dependent_tax_identification_number', required: true)  String? dependentTaxIdentificationNumber, @JsonKey(name: 'bank_account_number', required: true)  String? bankAccountNumber, @JsonKey(required: true)  double? age, @JsonKey(required: true)  double? seniority, @JsonKey(name: 'created_at', required: true)  String? createdAt, @JsonKey(name: 'updated_at', required: true)  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.phoneNumber,_that.birthday,_that.address,_that.sex,_that.code,_that.positionId,_that.position,_that.joinedAt,_that.startingDate,_that.educationLevel,_that.employeeType,_that.citizenIdentificationCard,_that.socialInsuranceNumber,_that.healthInsuranceCardNumber,_that.personalTaxIdentificationNumber,_that.dependentTaxIdentificationNumber,_that.bankAccountNumber,_that.age,_that.seniority,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _UserProfile implements UserProfile {
  const _UserProfile({@JsonKey(name: 'phone_number', required: true, fromJson: _nullablePhoneFromJson) this.phoneNumber, @JsonKey(required: true, fromJson: _nullableProfileDateFromJson) this.birthday, @JsonKey(required: true) this.address, @JsonKey(required: true, fromJson: _nullableSexFromJson) this.sex, @JsonKey(required: true, disallowNullValue: true) required this.code, @JsonKey(name: 'position_id', required: true) this.positionId, @JsonKey(required: true) this.position, @JsonKey(name: 'joined_at', required: true, fromJson: _nullableProfileDateFromJson) this.joinedAt, @JsonKey(name: 'starting_date', required: true, fromJson: _nullableProfileDateFromJson) this.startingDate, @JsonKey(name: 'education_level', required: true) this.educationLevel, @JsonKey(name: 'employee_type', required: true) this.employeeType, @JsonKey(name: 'citizen_identification_card', required: true) this.citizenIdentificationCard, @JsonKey(name: 'social_insurance_number', required: true) this.socialInsuranceNumber, @JsonKey(name: 'health_insurance_card_number', required: true) this.healthInsuranceCardNumber, @JsonKey(name: 'personal_tax_identification_number', required: true) this.personalTaxIdentificationNumber, @JsonKey(name: 'dependent_tax_identification_number', required: true) this.dependentTaxIdentificationNumber, @JsonKey(name: 'bank_account_number', required: true) this.bankAccountNumber, @JsonKey(required: true) this.age, @JsonKey(required: true) this.seniority, @JsonKey(name: 'created_at', required: true) this.createdAt, @JsonKey(name: 'updated_at', required: true) this.updatedAt});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override@JsonKey(name: 'phone_number', required: true, fromJson: _nullablePhoneFromJson) final  String? phoneNumber;
@override@JsonKey(required: true, fromJson: _nullableProfileDateFromJson) final  String? birthday;
@override@JsonKey(required: true) final  String? address;
@override@JsonKey(required: true, fromJson: _nullableSexFromJson) final  String? sex;
@override@JsonKey(required: true, disallowNullValue: true) final  String code;
@override@JsonKey(name: 'position_id', required: true) final  String? positionId;
@override@JsonKey(required: true) final  PositionRef? position;
@override@JsonKey(name: 'joined_at', required: true, fromJson: _nullableProfileDateFromJson) final  String? joinedAt;
@override@JsonKey(name: 'starting_date', required: true, fromJson: _nullableProfileDateFromJson) final  String? startingDate;
@override@JsonKey(name: 'education_level', required: true) final  String? educationLevel;
@override@JsonKey(name: 'employee_type', required: true) final  String? employeeType;
@override@JsonKey(name: 'citizen_identification_card', required: true) final  String? citizenIdentificationCard;
@override@JsonKey(name: 'social_insurance_number', required: true) final  String? socialInsuranceNumber;
@override@JsonKey(name: 'health_insurance_card_number', required: true) final  String? healthInsuranceCardNumber;
@override@JsonKey(name: 'personal_tax_identification_number', required: true) final  String? personalTaxIdentificationNumber;
@override@JsonKey(name: 'dependent_tax_identification_number', required: true) final  String? dependentTaxIdentificationNumber;
@override@JsonKey(name: 'bank_account_number', required: true) final  String? bankAccountNumber;
@override@JsonKey(required: true) final  double? age;
@override@JsonKey(required: true) final  double? seniority;
@override@JsonKey(name: 'created_at', required: true) final  String? createdAt;
@override@JsonKey(name: 'updated_at', required: true) final  String? updatedAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.address, address) || other.address == address)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.code, code) || other.code == code)&&(identical(other.positionId, positionId) || other.positionId == positionId)&&(identical(other.position, position) || other.position == position)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.startingDate, startingDate) || other.startingDate == startingDate)&&(identical(other.educationLevel, educationLevel) || other.educationLevel == educationLevel)&&(identical(other.employeeType, employeeType) || other.employeeType == employeeType)&&(identical(other.citizenIdentificationCard, citizenIdentificationCard) || other.citizenIdentificationCard == citizenIdentificationCard)&&(identical(other.socialInsuranceNumber, socialInsuranceNumber) || other.socialInsuranceNumber == socialInsuranceNumber)&&(identical(other.healthInsuranceCardNumber, healthInsuranceCardNumber) || other.healthInsuranceCardNumber == healthInsuranceCardNumber)&&(identical(other.personalTaxIdentificationNumber, personalTaxIdentificationNumber) || other.personalTaxIdentificationNumber == personalTaxIdentificationNumber)&&(identical(other.dependentTaxIdentificationNumber, dependentTaxIdentificationNumber) || other.dependentTaxIdentificationNumber == dependentTaxIdentificationNumber)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.age, age) || other.age == age)&&(identical(other.seniority, seniority) || other.seniority == seniority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,phoneNumber,birthday,address,sex,code,positionId,position,joinedAt,startingDate,educationLevel,employeeType,citizenIdentificationCard,socialInsuranceNumber,healthInsuranceCardNumber,personalTaxIdentificationNumber,dependentTaxIdentificationNumber,bankAccountNumber,age,seniority,createdAt,updatedAt]);
}

@override
String toString() {
    return 'UserProfile(phoneNumber: $phoneNumber, birthday: $birthday, address: $address, sex: $sex, code: $code, positionId: $positionId, position: $position, joinedAt: $joinedAt, startingDate: $startingDate, educationLevel: $educationLevel, employeeType: $employeeType, citizenIdentificationCard: $citizenIdentificationCard, socialInsuranceNumber: $socialInsuranceNumber, healthInsuranceCardNumber: $healthInsuranceCardNumber, personalTaxIdentificationNumber: $personalTaxIdentificationNumber, dependentTaxIdentificationNumber: $dependentTaxIdentificationNumber, bankAccountNumber: $bankAccountNumber, age: $age, seniority: $seniority, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'phone_number', required: true, fromJson: _nullablePhoneFromJson) String? phoneNumber,@JsonKey(required: true, fromJson: _nullableProfileDateFromJson) String? birthday,@JsonKey(required: true) String? address,@JsonKey(required: true, fromJson: _nullableSexFromJson) String? sex,@JsonKey(required: true, disallowNullValue: true) String code,@JsonKey(name: 'position_id', required: true) String? positionId,@JsonKey(required: true) PositionRef? position,@JsonKey(name: 'joined_at', required: true, fromJson: _nullableProfileDateFromJson) String? joinedAt,@JsonKey(name: 'starting_date', required: true, fromJson: _nullableProfileDateFromJson) String? startingDate,@JsonKey(name: 'education_level', required: true) String? educationLevel,@JsonKey(name: 'employee_type', required: true) String? employeeType,@JsonKey(name: 'citizen_identification_card', required: true) String? citizenIdentificationCard,@JsonKey(name: 'social_insurance_number', required: true) String? socialInsuranceNumber,@JsonKey(name: 'health_insurance_card_number', required: true) String? healthInsuranceCardNumber,@JsonKey(name: 'personal_tax_identification_number', required: true) String? personalTaxIdentificationNumber,@JsonKey(name: 'dependent_tax_identification_number', required: true) String? dependentTaxIdentificationNumber,@JsonKey(name: 'bank_account_number', required: true) String? bankAccountNumber,@JsonKey(required: true) double? age,@JsonKey(required: true) double? seniority,@JsonKey(name: 'created_at', required: true) String? createdAt,@JsonKey(name: 'updated_at', required: true) String? updatedAt
});


@override $PositionRefCopyWith<$Res>? get position;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneNumber = freezed,Object? birthday = freezed,Object? address = freezed,Object? sex = freezed,Object? code = null,Object? positionId = freezed,Object? position = freezed,Object? joinedAt = freezed,Object? startingDate = freezed,Object? educationLevel = freezed,Object? employeeType = freezed,Object? citizenIdentificationCard = freezed,Object? socialInsuranceNumber = freezed,Object? healthInsuranceCardNumber = freezed,Object? personalTaxIdentificationNumber = freezed,Object? dependentTaxIdentificationNumber = freezed,Object? bankAccountNumber = freezed,Object? age = freezed,Object? seniority = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserProfile(
phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,positionId: freezed == positionId ? _self.positionId : positionId // ignore: cast_nullable_to_non_nullable
as String?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as PositionRef?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,startingDate: freezed == startingDate ? _self.startingDate : startingDate // ignore: cast_nullable_to_non_nullable
as String?,educationLevel: freezed == educationLevel ? _self.educationLevel : educationLevel // ignore: cast_nullable_to_non_nullable
as String?,employeeType: freezed == employeeType ? _self.employeeType : employeeType // ignore: cast_nullable_to_non_nullable
as String?,citizenIdentificationCard: freezed == citizenIdentificationCard ? _self.citizenIdentificationCard : citizenIdentificationCard // ignore: cast_nullable_to_non_nullable
as String?,socialInsuranceNumber: freezed == socialInsuranceNumber ? _self.socialInsuranceNumber : socialInsuranceNumber // ignore: cast_nullable_to_non_nullable
as String?,healthInsuranceCardNumber: freezed == healthInsuranceCardNumber ? _self.healthInsuranceCardNumber : healthInsuranceCardNumber // ignore: cast_nullable_to_non_nullable
as String?,personalTaxIdentificationNumber: freezed == personalTaxIdentificationNumber ? _self.personalTaxIdentificationNumber : personalTaxIdentificationNumber // ignore: cast_nullable_to_non_nullable
as String?,dependentTaxIdentificationNumber: freezed == dependentTaxIdentificationNumber ? _self.dependentTaxIdentificationNumber : dependentTaxIdentificationNumber // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as double?,seniority: freezed == seniority ? _self.seniority : seniority // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PositionRefCopyWith<$Res>? get position {
    if (_self.position == null) {
    return null;
  }

  return $PositionRefCopyWith<$Res>(_self.position!, (value) {
    return _then(_self.copyWith(position: value));
  });
}
}


/// @nodoc
mixin _$PositionRef {

 String get id; String get name; String? get description;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of PositionRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PositionRefCopyWith<PositionRef> get copyWith => _$PositionRefCopyWithImpl<PositionRef>(this as PositionRef, _$identity);

  /// Serializes this PositionRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PositionRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PositionRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PositionRef;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as PositionRef;
  return 'PositionRef(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $PositionRefCopyWith<$Res>  {
  factory $PositionRefCopyWith(PositionRef value, $Res Function(PositionRef) _then) = _$PositionRefCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$PositionRefCopyWithImpl<$Res>
    implements $PositionRefCopyWith<$Res> {
  _$PositionRefCopyWithImpl(this._self, this._then);

  final PositionRef _self;
  final $Res Function(PositionRef) _then;

/// Create a copy of PositionRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(PositionRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PositionRef].
extension PositionRefPatterns on PositionRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PositionRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PositionRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PositionRef value)  $default,){
final _that = this;
switch (_that) {
case _PositionRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PositionRef value)?  $default,){
final _that = this;
switch (_that) {
case _PositionRef() when $default != null:
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
case _PositionRef() when $default != null:
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
case _PositionRef():
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
case _PositionRef() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _PositionRef implements PositionRef {
  const _PositionRef({required this.id, required this.name, required this.description, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _PositionRef.fromJson(Map<String, dynamic> json) => _$PositionRefFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of PositionRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PositionRefCopyWith<_PositionRef> get copyWith => __$PositionRefCopyWithImpl<_PositionRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PositionRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PositionRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,createdAt,updatedAt);
}

@override
String toString() {
    return 'PositionRef(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PositionRefCopyWith<$Res> implements $PositionRefCopyWith<$Res> {
  factory _$PositionRefCopyWith(_PositionRef value, $Res Function(_PositionRef) _then) = __$PositionRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$PositionRefCopyWithImpl<$Res>
    implements _$PositionRefCopyWith<$Res> {
  __$PositionRefCopyWithImpl(this._self, this._then);

  final _PositionRef _self;
  final $Res Function(_PositionRef) _then;

/// Create a copy of PositionRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PositionRef(
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

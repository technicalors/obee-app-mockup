import 'package:intl/intl.dart';
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory UserProfile({
    @JsonKey(
      name: 'phone_number',
      required: true,
      fromJson: _nullablePhoneFromJson,
    )
    String? phoneNumber,
    @JsonKey(required: true, fromJson: _nullableProfileDateFromJson)
    String? birthday,
    @JsonKey(required: true) String? address,
    @JsonKey(required: true, fromJson: _nullableSexFromJson) String? sex,
    @JsonKey(required: true, disallowNullValue: true) required String code,
    @JsonKey(name: 'position_id', required: true) String? positionId,
    @JsonKey(required: true) PositionRef? position,
    @JsonKey(
      name: 'joined_at',
      required: true,
      fromJson: _nullableProfileDateFromJson,
    )
    String? joinedAt,
    @JsonKey(
      name: 'starting_date',
      required: true,
      fromJson: _nullableProfileDateFromJson,
    )
    String? startingDate,
    @JsonKey(name: 'education_level', required: true) String? educationLevel,
    @JsonKey(name: 'employee_type', required: true) String? employeeType,
    @JsonKey(name: 'citizen_identification_card', required: true)
    String? citizenIdentificationCard,
    @JsonKey(name: 'social_insurance_number', required: true)
    String? socialInsuranceNumber,
    @JsonKey(name: 'health_insurance_card_number', required: true)
    String? healthInsuranceCardNumber,
    @JsonKey(name: 'personal_tax_identification_number', required: true)
    String? personalTaxIdentificationNumber,
    @JsonKey(name: 'dependent_tax_identification_number', required: true)
    String? dependentTaxIdentificationNumber,
    @JsonKey(name: 'bank_account_number', required: true)
    String? bankAccountNumber,
    @JsonKey(required: true) double? age,
    @JsonKey(required: true) double? seniority,
    @JsonKey(name: 'created_at', required: true) String? createdAt,
    @JsonKey(name: 'updated_at', required: true) String? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
abstract class PositionRef with _$PositionRef {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory PositionRef({
    required String id,
    required String name,
    required String? description,
    @JsonKey(name: 'created_at') required String? createdAt,
    @JsonKey(name: 'updated_at') required String? updatedAt,
  }) = _PositionRef;
  factory PositionRef.fromJson(Map<String, dynamic> json) =>
      _$PositionRefFromJson(json);
}

String? _nullableSexFromJson(Object? value) => switch (value) {
  null => null,
  'male' => 'male',
  'female' => 'female',
  _ => throw const FormatException('Invalid profile sex.'),
};

String? _nullablePhoneFromJson(Object? value) {
  if (value == null) return null;
  if (value is! String || !RegExp(r'^\+?\d{8,15}$').hasMatch(value)) {
    throw const FormatException('Invalid profile phone number.');
  }
  return value;
}

String? _nullableProfileDateFromJson(Object? value) {
  if (value == null) return null;
  if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw const FormatException('Profile date must be YYYY-MM-DD.');
  }
  DateFormat('yyyy-MM-dd').parseStrict(value);
  return value;
}

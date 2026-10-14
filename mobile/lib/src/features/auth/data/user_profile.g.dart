// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_UserProfile',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'phone_number',
        'birthday',
        'address',
        'sex',
        'code',
        'position_id',
        'position',
        'joined_at',
        'starting_date',
        'education_level',
        'employee_type',
        'citizen_identification_card',
        'social_insurance_number',
        'health_insurance_card_number',
        'personal_tax_identification_number',
        'dependent_tax_identification_number',
        'bank_account_number',
        'age',
        'seniority',
        'created_at',
        'updated_at',
      ],
      disallowNullValues: const ['code'],
    );
    final val = _UserProfile(
      phoneNumber: $checkedConvert(
        'phone_number',
        (v) => _nullablePhoneFromJson(v),
      ),
      birthday: $checkedConvert(
        'birthday',
        (v) => _nullableProfileDateFromJson(v),
      ),
      address: $checkedConvert('address', (v) => v as String?),
      sex: $checkedConvert('sex', (v) => _nullableSexFromJson(v)),
      code: $checkedConvert('code', (v) => v as String),
      positionId: $checkedConvert('position_id', (v) => v as String?),
      position: $checkedConvert(
        'position',
        (v) =>
            v == null ? null : PositionRef.fromJson(v as Map<String, dynamic>),
      ),
      joinedAt: $checkedConvert(
        'joined_at',
        (v) => _nullableProfileDateFromJson(v),
      ),
      startingDate: $checkedConvert(
        'starting_date',
        (v) => _nullableProfileDateFromJson(v),
      ),
      educationLevel: $checkedConvert('education_level', (v) => v as String?),
      employeeType: $checkedConvert('employee_type', (v) => v as String?),
      citizenIdentificationCard: $checkedConvert(
        'citizen_identification_card',
        (v) => v as String?,
      ),
      socialInsuranceNumber: $checkedConvert(
        'social_insurance_number',
        (v) => v as String?,
      ),
      healthInsuranceCardNumber: $checkedConvert(
        'health_insurance_card_number',
        (v) => v as String?,
      ),
      personalTaxIdentificationNumber: $checkedConvert(
        'personal_tax_identification_number',
        (v) => v as String?,
      ),
      dependentTaxIdentificationNumber: $checkedConvert(
        'dependent_tax_identification_number',
        (v) => v as String?,
      ),
      bankAccountNumber: $checkedConvert(
        'bank_account_number',
        (v) => v as String?,
      ),
      age: $checkedConvert('age', (v) => (v as num?)?.toDouble()),
      seniority: $checkedConvert('seniority', (v) => (v as num?)?.toDouble()),
      createdAt: $checkedConvert('created_at', (v) => v as String?),
      updatedAt: $checkedConvert('updated_at', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'phoneNumber': 'phone_number',
    'positionId': 'position_id',
    'joinedAt': 'joined_at',
    'startingDate': 'starting_date',
    'educationLevel': 'education_level',
    'employeeType': 'employee_type',
    'citizenIdentificationCard': 'citizen_identification_card',
    'socialInsuranceNumber': 'social_insurance_number',
    'healthInsuranceCardNumber': 'health_insurance_card_number',
    'personalTaxIdentificationNumber': 'personal_tax_identification_number',
    'dependentTaxIdentificationNumber': 'dependent_tax_identification_number',
    'bankAccountNumber': 'bank_account_number',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'birthday': instance.birthday,
      'address': instance.address,
      'sex': instance.sex,
      'code': instance.code,
      'position_id': instance.positionId,
      'position': instance.position?.toJson(),
      'joined_at': instance.joinedAt,
      'starting_date': instance.startingDate,
      'education_level': instance.educationLevel,
      'employee_type': instance.employeeType,
      'citizen_identification_card': instance.citizenIdentificationCard,
      'social_insurance_number': instance.socialInsuranceNumber,
      'health_insurance_card_number': instance.healthInsuranceCardNumber,
      'personal_tax_identification_number':
          instance.personalTaxIdentificationNumber,
      'dependent_tax_identification_number':
          instance.dependentTaxIdentificationNumber,
      'bank_account_number': instance.bankAccountNumber,
      'age': instance.age,
      'seniority': instance.seniority,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_PositionRef _$PositionRefFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_PositionRef',
  json,
  ($checkedConvert) {
    final val = _PositionRef(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String?),
      createdAt: $checkedConvert('created_at', (v) => v as String?),
      updatedAt: $checkedConvert('updated_at', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'createdAt': 'created_at', 'updatedAt': 'updated_at'},
);

Map<String, dynamic> _$PositionRefToJson(_PositionRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

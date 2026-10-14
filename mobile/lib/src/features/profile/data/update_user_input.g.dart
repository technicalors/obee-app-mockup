// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateUserInput _$UpdateUserInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_UpdateUserInput', json, ($checkedConvert) {
      final val = _UpdateUserInput(
        name: $checkedConvert('name', (v) => v as String),
        profile: $checkedConvert(
          'profile',
          (v) => v == null
              ? null
              : EditableUserProfile.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UpdateUserInputToJson(_UpdateUserInput instance) =>
    <String, dynamic>{
      'name': instance.name,
      'profile': ?instance.profile?.toJson(),
    };

_EditableUserProfile _$EditableUserProfileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_EditableUserProfile', json, ($checkedConvert) {
      final val = _EditableUserProfile(
        phoneNumber: $checkedConvert('phone_number', (v) => v as String?),
        address: $checkedConvert('address', (v) => v as String?),
        sex: $checkedConvert('sex', (v) => v as String?),
        birthday: $checkedConvert('birthday', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'phoneNumber': 'phone_number'});

Map<String, dynamic> _$EditableUserProfileToJson(
  _EditableUserProfile instance,
) => <String, dynamic>{
  'phone_number': instance.phoneNumber,
  'address': instance.address,
  'sex': instance.sex,
  'birthday': instance.birthday,
};

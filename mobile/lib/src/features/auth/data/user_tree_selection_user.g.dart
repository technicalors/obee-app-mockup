// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_tree_selection_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserTreeSelectionUser _$UserTreeSelectionUserFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_UserTreeSelectionUser', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['profile']);
  final val = _UserTreeSelectionUser(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    username: $checkedConvert('username', (v) => v as String),
    organizationId: $checkedConvert('organization_id', (v) => v as String),
    organization: $checkedConvert(
      'organization',
      (v) => OrganizationRef.fromJson(v as Map<String, dynamic>),
    ),
    profile: $checkedConvert(
      'profile',
      (v) => v == null
          ? null
          : UserTreeProfile.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'organizationId': 'organization_id'});

Map<String, dynamic> _$UserTreeSelectionUserToJson(
  _UserTreeSelectionUser instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'organization_id': instance.organizationId,
  'organization': instance.organization.toJson(),
  'profile': instance.profile?.toJson(),
};

_UserTreeProfile _$UserTreeProfileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_UserTreeProfile', json, ($checkedConvert) {
      final val = _UserTreeProfile(
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$UserTreeProfileToJson(_UserTreeProfile instance) =>
    <String, dynamic>{'code': instance.code};

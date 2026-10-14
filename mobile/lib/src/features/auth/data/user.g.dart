// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_User',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'email',
        'avatar',
        'organization_id',
        'organization',
        'email_verified_at',
        'supabase_id',
        'created_at',
        'updated_at',
      ],
      disallowNullValues: const ['created_at', 'updated_at'],
    );
    final val = _User(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      username: $checkedConvert('username', (v) => v as String),
      email: $checkedConvert('email', (v) => v as String?),
      avatar: $checkedConvert('avatar', (v) => v as String?),
      organizationId: $checkedConvert('organization_id', (v) => v as String?),
      organization: $checkedConvert(
        'organization',
        (v) => v == null
            ? null
            : OrganizationRef.fromJson(v as Map<String, dynamic>),
      ),
      rootOrganizationId: $checkedConvert(
        'root_organization_id',
        (v) => v as String?,
      ),
      profile: $checkedConvert(
        'profile',
        (v) =>
            v == null ? null : UserProfile.fromJson(v as Map<String, dynamic>),
      ),
      roles: $checkedConvert(
        'roles',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => RoleRef.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <RoleRef>[],
      ),
      emailVerifiedAt: $checkedConvert(
        'email_verified_at',
        (v) => v as String?,
      ),
      supabaseId: $checkedConvert('supabase_id', (v) => v as String?),
      createdAt: $checkedConvert('created_at', (v) => v as String),
      updatedAt: $checkedConvert('updated_at', (v) => v as String),
      permissions: $checkedConvert(
        'permissions',
        (v) => (v as List<dynamic>?)
            ?.map((e) => PermissionRef.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'organizationId': 'organization_id',
    'rootOrganizationId': 'root_organization_id',
    'emailVerifiedAt': 'email_verified_at',
    'supabaseId': 'supabase_id',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'email': instance.email,
  'avatar': instance.avatar,
  'organization_id': instance.organizationId,
  'organization': instance.organization?.toJson(),
  'root_organization_id': instance.rootOrganizationId,
  'profile': instance.profile?.toJson(),
  'roles': instance.roles.map((e) => e.toJson()).toList(),
  'email_verified_at': instance.emailVerifiedAt,
  'supabase_id': instance.supabaseId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'permissions': instance.permissions?.map((e) => e.toJson()).toList(),
};

_RoleRef _$RoleRefFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_RoleRef',
  json,
  ($checkedConvert) {
    final val = _RoleRef(
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

Map<String, dynamic> _$RoleRefToJson(_RoleRef instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_PermissionRef _$PermissionRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_PermissionRef',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['description', 'created_at', 'updated_at'],
        );
        final val = _PermissionRef(
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

Map<String, dynamic> _$PermissionRefToJson(_PermissionRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:obee_mobile/src/features/auth/data/organization_ref.dart';
import 'package:obee_mobile/src/features/auth/data/user_profile.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory User({
    required String id,
    required String name,
    required String username,
    @JsonKey(required: true) required String? email,
    @JsonKey(required: true) required String? avatar,
    @JsonKey(name: 'organization_id', required: true) String? organizationId,
    @JsonKey(required: true) OrganizationRef? organization,
    @JsonKey(name: 'root_organization_id') String? rootOrganizationId,
    UserProfile? profile,
    @Default(<RoleRef>[]) List<RoleRef> roles,
    @JsonKey(name: 'email_verified_at', required: true) String? emailVerifiedAt,
    @JsonKey(name: 'supabase_id', required: true) String? supabaseId,
    @JsonKey(name: 'created_at', required: true, disallowNullValue: true)
    required String createdAt,
    @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)
    required String updatedAt,
    List<PermissionRef>? permissions,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class RoleRef with _$RoleRef {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory RoleRef({
    required String id,
    required String name,
    required String? description,
    @JsonKey(name: 'created_at') required String? createdAt,
    @JsonKey(name: 'updated_at') required String? updatedAt,
  }) = _RoleRef;
  factory RoleRef.fromJson(Map<String, dynamic> json) =>
      _$RoleRefFromJson(json);
}

@freezed
abstract class PermissionRef with _$PermissionRef {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory PermissionRef({
    required String id,
    required String name,
    @JsonKey(required: true) required String? description,
    @JsonKey(name: 'created_at', required: true) required String? createdAt,
    @JsonKey(name: 'updated_at', required: true) required String? updatedAt,
  }) = _PermissionRef;

  factory PermissionRef.fromJson(Map<String, dynamic> json) =>
      _$PermissionRefFromJson(json);
}

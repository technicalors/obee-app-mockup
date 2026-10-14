// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_ref.freezed.dart';
part 'organization_ref.g.dart';

@freezed
abstract class OrganizationRef with _$OrganizationRef {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory OrganizationRef({
    required String id,
    required String name,
    required String type,
    @JsonKey(name: 'parent_id', required: true) String? parentId,
    @JsonKey(name: 'tax_identification_number', required: true)
    String? taxIdentificationNumber,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    OrganizationRef? parent,
  }) = _OrganizationRef;

  factory OrganizationRef.fromJson(Map<String, dynamic> json) =>
      _$OrganizationRefFromJson(json);
}

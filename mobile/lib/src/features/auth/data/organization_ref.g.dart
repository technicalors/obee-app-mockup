// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrganizationRef _$OrganizationRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_OrganizationRef',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['parent_id', 'tax_identification_number'],
        );
        final val = _OrganizationRef(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          type: $checkedConvert('type', (v) => v as String),
          parentId: $checkedConvert('parent_id', (v) => v as String?),
          taxIdentificationNumber: $checkedConvert(
            'tax_identification_number',
            (v) => v as String?,
          ),
          createdAt: $checkedConvert('created_at', (v) => v as String),
          updatedAt: $checkedConvert('updated_at', (v) => v as String),
          parent: $checkedConvert(
            'parent',
            (v) => v == null
                ? null
                : OrganizationRef.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'parentId': 'parent_id',
        'taxIdentificationNumber': 'tax_identification_number',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$OrganizationRefToJson(_OrganizationRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'parent_id': instance.parentId,
      'tax_identification_number': instance.taxIdentificationNumber,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'parent': instance.parent?.toJson(),
    };

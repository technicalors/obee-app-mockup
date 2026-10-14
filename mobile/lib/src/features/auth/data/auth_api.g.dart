// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResult _$LoginResultFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_LoginResult',
  json,
  ($checkedConvert) {
    final val = _LoginResult(
      accessToken: $checkedConvert('access_token', (v) => v as String),
      tokenType: $checkedConvert('token_type', (v) => v as String),
      user: $checkedConvert(
        'user',
        (v) => decodeAuthenticatedUser(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'accessToken': 'access_token', 'tokenType': 'token_type'},
);

Map<String, dynamic> _$LoginResultToJson(_LoginResult instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'user': instance.user.toJson(),
    };

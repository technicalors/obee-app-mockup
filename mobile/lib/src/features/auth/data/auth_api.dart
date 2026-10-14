// ignore_for_file: invalid_annotation_target

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';

part 'auth_api.freezed.dart';
part 'auth_api.g.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return MobileAuthApi(ref.watch(apiClientProvider));
});

abstract interface class AuthApi {
  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  });

  Future<User> currentUser();

  Future<void> logout();
}

class MobileAuthApi implements AuthApi {
  const MobileAuthApi(this._api);

  final ApiClient _api;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final body = await _api.post<Map<String, dynamic>>(
      '/mobile/auth/login',
      data: {'email': email, 'password': password, 'device_name': deviceName},
    );

    return LoginResult.fromJson(body);
  }

  @override
  Future<User> currentUser() async {
    final body = await _api.get<Map<String, dynamic>>('/mobile/auth/user');

    return decodeAuthenticatedUser(body);
  }

  @override
  Future<void> logout() => _api.postVoid('/mobile/auth/logout');
}

@freezed
abstract class LoginResult with _$LoginResult {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory LoginResult({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(fromJson: decodeAuthenticatedUser) required User user,
  }) = _LoginResult;

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);
}

User decodeAuthenticatedUser(Map<String, dynamic> json) {
  if (!json.containsKey('root_organization_id') ||
      (json['root_organization_id'] != null &&
          json['root_organization_id'] is! String)) {
    throw const FormatException(
      'Authenticated user root_organization_id is required, nullable.',
    );
  }
  if (json['roles'] is! List) {
    throw const FormatException(
      'Authenticated user roles contract is invalid.',
    );
  }
  final permissions = json['permissions'];
  if (permissions is! List) {
    throw const FormatException(
      'Authenticated user permissions contract is invalid.',
    );
  }
  final user = User.fromJson(json);
  if (user.organizationId != user.organization?.id ||
      (user.organizationId == null) != (user.rootOrganizationId == null)) {
    throw const FormatException(
      'Authenticated user organization is inconsistent.',
    );
  }
  return user;
}

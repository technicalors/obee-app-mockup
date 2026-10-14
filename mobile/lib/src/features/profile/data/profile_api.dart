import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/profile/data/update_user_input.dart';

final profileApiProvider = Provider<ProfileApi>((ref) {
  return MobileProfileApi(ref.watch(apiClientProvider));
});

abstract interface class ProfileApi {
  Future<User> updateProfile({required UpdateUserInput input});
}

class MobileProfileApi implements ProfileApi {
  const MobileProfileApi(this._api);

  final ApiClient _api;

  @override
  Future<User> updateProfile({required UpdateUserInput input}) async {
    final body = await _api.put<Map<String, dynamic>>(
      '/profile',
      data: input.toJson(),
    );

    return decodeAuthenticatedUser(body);
  }
}

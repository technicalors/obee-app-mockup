import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';

void main() {
  for (final email in [null, 'admin@example.com']) {
    test('login response accepts email $email', () {
      final result = LoginResult.fromJson({
        'access_token': 'token-1',
        'token_type': 'Bearer',
        'user': {
          'id': 'user-1',
          'name': 'Admin User',
          'username': 'admin',
          'email': email,
          'avatar': null,
          'deleted_at': null,
          'organization_id': null,
          'root_organization_id': null,
          'organization': null,
          'email_verified_at': null,
          'supabase_id': null,
          'created_at': '2026-10-02T00:00:00Z',
          'updated_at': '2026-10-02T00:00:00Z',
          'permissions': [
            {
              'id': 'permission-1',
              'name': 'users.viewAny',
              'description': 'View users',
              'created_at': null,
              'updated_at': null,
            },
          ],
          'roles': [],
        },
      });

      expect(result.accessToken, 'token-1');
      expect(result.user.email, email);
      expect(result.user.username, 'admin');
      expect(result.user.permissions!.single.id, 'permission-1');
      expect(result.user.permissions!.single.name, 'users.viewAny');
      expect(result.user.permissions!.single.description, 'View users');
      expect(
        () => User.fromJson({
          ...result.user.toJson(),
          'permissions': ['users.viewAny'],
        }),
        throwsA(isA<CheckedFromJsonException>()),
      );
      expect(
        () => User.fromJson({
          ...result.user.toJson(),
          'permissions': [
            {'name': 'users.viewAny'},
          ],
        }),
        throwsA(isA<CheckedFromJsonException>()),
      );
      expect(User.fromJson(result.user.toJson()), result.user);
      expect(result.user.toJson()['email'], email);
    });
  }

  test('user response rejects email with an invalid type', () {
    expect(
      () => User.fromJson({
        'id': 'user-1',
        'name': 'Admin User',
        'username': 'admin',
        'email': 123,
        'avatar': null,
      }),
      throwsA(isA<CheckedFromJsonException>()),
    );
  });

  for (final field in ['roles', 'permissions']) {
    for (final invalid in [null, 'basic', <String, Object?>{}]) {
      test('authenticated user rejects invalid $field: $invalid', () {
        expect(
          () => decodeAuthenticatedUser({
            'roles': [],
            'permissions': [],
            field: invalid,
          }),
          throwsFormatException,
        );
      });
    }
    test('authenticated user rejects missing $field', () {
      final json = <String, dynamic>{'roles': [], 'permissions': []}
        ..remove(field);
      expect(() => decodeAuthenticatedUser(json), throwsFormatException);
    });
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/features/auth/data/user_profile.dart';
import 'package:obee_mobile/src/features/profile/data/profile_api.dart';
import 'package:obee_mobile/src/features/profile/data/update_user_input.dart';
import 'network_failure_test.dart' show ReplyAdapter;

void main() {
  test(
    'self-service uses /profile once under /api with nested personal fields',
    () async {
      final adapter = ReplyAdapter(
        ResponseBody.fromString(
          jsonEncode({
            'id': 'user-1',
            'name': 'Changed',
            'username': 'employee',
            'email': null,
            'avatar': null,
            'deleted_at': null,
            'profile': profileJson(),
            'roles': [],
            'permissions': [],
            'email_verified_at': null,
            'organization': null,
            'organization_id': null,
            'root_organization_id': null,
            'supabase_id': null,
            'created_at': '2026-10-02T00:00:00Z',
            'updated_at': '2026-10-02T00:00:00Z',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://obee.test/api'));
      dio.httpClientAdapter = adapter;
      addTearDown(dio.close);
      final result = await MobileProfileApi(ApiClient(dio)).updateProfile(
        input: const UpdateUserInput(
          name: 'Changed',
          profile: EditableUserProfile(
            phoneNumber: null,
            address: null,
            sex: 'female',
            birthday: '1990-04-05',
          ),
        ),
      );
      expect(adapter.lastRequest.method, 'PUT');
      expect(
        adapter.lastRequest.uri.toString(),
        'https://obee.test/api/profile',
      );
      expect(adapter.lastRequest.data, {
        'name': 'Changed',
        'profile': {
          'phone_number': null,
          'address': null,
          'sex': 'female',
          'birthday': '1990-04-05',
        },
      });
      expect(result.profile!.code, 'EMP-1');
      expect(result.profile!.birthday, '1990-04-05');
    },
  );
  test('profile DTO rejects obsolete sex/date values at ingestion', () {
    expect(
      () => UserProfile.fromJson({...profileJson(), 'sex': 'other'}),
      throwsA(isA<Exception>()),
    );
    expect(
      () => UserProfile.fromJson({
        ...profileJson(),
        'birthday': '1990-04-04T17:00:00Z',
      }),
      throwsA(isA<Exception>()),
    );
  });
}

Map<String, dynamic> profileJson() => {
  'code': 'EMP-1',
  'phone_number': null,
  'address': null,
  'sex': 'female',
  'birthday': '1990-04-05',
  'position_id': null,
  'position': null,
  'joined_at': null,
  'starting_date': null,
  'education_level': null,
  'employee_type': null,
  'citizen_identification_card': null,
  'social_insurance_number': null,
  'health_insurance_card_number': null,
  'personal_tax_identification_number': null,
  'dependent_tax_identification_number': null,
  'bank_account_number': null,
  'age': 36,
  'seniority': null,
  'created_at': null,
  'updated_at': null,
};

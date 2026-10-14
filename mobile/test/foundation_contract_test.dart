import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/core/network/api_problem.dart';
import 'package:obee_mobile/src/core/network/paginated_list.dart';
import 'package:obee_mobile/src/core/time/business_time.dart';
import 'package:obee_mobile/src/features/profile/data/update_user_input.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';

void main() {
  test(
    'production rejects cleartext and credentials; dev permits local HTTP',
    () {
      expect(
        () => AppConfig.parse(
          environment: AppEnvironment.prod,
          apiBaseUrl: 'http://obee.test/api',
          appBaseUrl: 'https://obee.test',
        ),
        throwsFormatException,
      );
      expect(
        () => AppConfig.parse(
          apiBaseUrl: 'https://user:pass@obee.test/api',
          appBaseUrl: 'https://obee.test',
        ),
        throwsFormatException,
      );
      expect(
        () => AppConfig.parse(
          apiBaseUrl: 'https://obee.test/api',
          appBaseUrl: 'https://obee.test/path',
        ),
        throwsFormatException,
      );
      expect(
        AppConfig.parse(
          apiBaseUrl: 'http://10.0.2.2/api',
          appBaseUrl: 'http://10.0.2.2',
        ).environment,
        AppEnvironment.dev,
      );
    },
  );
  test('self-service payload nests profile and preserves explicit nulls', () {
    expect(
      const UpdateUserInput(
        name: 'Employee',
        profile: EditableUserProfile(
          phoneNumber: null,
          address: 'Address',
          sex: 'female',
          birthday: null,
        ),
      ).toJson(),
      {
        'name': 'Employee',
        'profile': {
          'phone_number': null,
          'address': 'Address',
          'sex': 'female',
          'birthday': null,
        },
      },
    );
    expect(const UpdateUserInput(name: 'Employee').toJson(), {
      'name': 'Employee',
    });
  });
  test(
    'pagination consumes the web envelope and rejects Laravel legacy shape',
    () {
      final page = PaginatedList<String>.fromJson({
        'items': [
          {'name': 'A'},
        ],
        'pagination': {
          'page': 1,
          'per_page': 20,
          'total': 21,
          'has_next': true,
        },
      }, (item) => item['name'] as String);
      expect(page.items, ['A']);
      expect(page.pagination.hasNext, true);
      expect(
        () => PaginatedList<String>.fromJson({
          'data': [],
          'meta': {},
        }, (item) => item['name'] as String),
        throwsFormatException,
      );
    },
  );
  test('422 field errors retain nested paths and reject scalar messages', () {
    final payload = <String, dynamic>{
      'type': 'about:blank',
      'title': 'Invalid',
      'status': 422,
      'detail': 'Invalid input',
      'errors': {
        'profile.phone_number': ['Invalid phone'],
      },
    };
    expect(ApiProblem.fromJson(payload).errors?['profile.phone_number'], [
      'Invalid phone',
    ]);
    expect(
      () => ApiProblem.fromJson({
        ...payload,
        'errors': {'name': 'Invalid'},
      }),
      throwsFormatException,
    );
  });
  test('business clock crosses UTC day boundary in Vietnam consistently', () {
    expect(
      businessWallTime(DateTime.parse('2026-10-01T18:30:00Z')),
      DateTime(2026, 10, 2, 1, 30),
    );
    expect(
      businessWallTime(DateTime.parse('2026-10-02T08:00:00+07:00')),
      DateTime(2026, 10, 2, 8),
    );
  });
  test('tree selection rejects missing organization assignments', () {
    expect(
      () => UserTreeSelectionUser.fromJson({
        'id': 'u',
        'name': 'User',
        'username': 'user',
        'deleted_at': null,
        'profile': null,
        'organization_id': null,
        'organization': null,
      }),
      throwsFormatException,
    );
  });
}

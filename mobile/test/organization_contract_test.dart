import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/core/widgets/tree_select.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_api.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_api.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_user_tree.dart';
import 'package:obee_mobile/src/features/profile/data/profile_api.dart';
import 'package:obee_mobile/src/features/profile/data/update_user_input.dart';

import 'network_failure_test.dart' show ReplyAdapter;

void main() {
  test(
    'profile update preserves organization snapshot without editing assignments',
    () async {
      final adapter = _adapter(_authenticatedUserJson());
      final user = await MobileProfileApi(
        _client(adapter),
      ).updateProfile(input: const UpdateUserInput(name: 'Employee'));
      expect(adapter.lastRequest.path, '/profile');
      expect(adapter.lastRequest.data, {'name': 'Employee'});
      expect(user.organizationId, 'team');
      expect(user.rootOrganizationId, 'root');
    },
  );
  test(
    'login and restore consume organization snapshots and root scope',
    () async {
      final snapshot = _authenticatedUserJson();
      for (final login in [true, false]) {
        final adapter = _adapter(
          login
              ? {
                  'access_token': 'token',
                  'token_type': 'Bearer',
                  'user': snapshot,
                }
              : snapshot,
        );
        final api = MobileAuthApi(_client(adapter));
        final user = login
            ? (await api.login(
                email: 'user@example.com',
                password: 'password',
                deviceName: 'test',
              )).user
            : await api.currentUser();
        expect(
          adapter.lastRequest.path,
          login ? '/mobile/auth/login' : '/mobile/auth/user',
        );
        expect(user.organizationId, 'team');
        expect(user.organization!.name, 'Tổ A');
        expect(user.rootOrganizationId, 'root');
        expect(decodeAuthenticatedUser(user.toJson()), user);
        expect(user.toJson().keys, isNot(contains('company_id')));
        expect(user.toJson().keys, isNot(contains('departments')));
      }
    },
  );

  test(
    'authenticated snapshots reject missing or inconsistent assignments',
    () {
      for (final field in [
        'organization',
        'organization_id',
        'root_organization_id',
      ]) {
        final payload = _authenticatedUserJson()..remove(field);
        expect(
          () => decodeAuthenticatedUser(payload),
          throwsA(isA<Exception>()),
          reason: field,
        );
      }
      for (final patch in [
        {'organization_id': 'other'},
        {'organization': null},
        {'root_organization_id': null},
        {'organization_id': null, 'organization': null},
      ]) {
        expect(
          () =>
              decodeAuthenticatedUser({..._authenticatedUserJson(), ...patch}),
          throwsFormatException,
        );
      }
      final unassigned = decodeAuthenticatedUser({
        ..._authenticatedUserJson(),
        'organization_id': null,
        'organization': null,
        'root_organization_id': null,
      });
      expect(hasScheduleOrganization(unassigned), false);
    },
  );

  test(
    'selection fetch scopes to the root and decodes the complete parent chain',
    () async {
      final adapter = _adapter([_selectionJson('employee', _team)]);
      final users = await MobileScheduleApi(
        _client(adapter),
      ).fetchUsers(rootOrganizationId: 'root');
      expect(adapter.lastRequest.path, '/users/tree');
      expect(adapter.lastRequest.queryParameters, {
        'root_organization_id': 'root',
      });
      expect(users.single.organizationId, 'team');
      expect(users.single.organization.parent!.id, 'division');
      expect(users.single.organization.parent!.parent!.id, 'root');
      expect(
        UserTreeSelectionUser.fromJson(users.single.toJson()),
        users.single,
      );
    },
  );

  test('selection rejects incomplete, mismatched and cyclic parent chains', () {
    final missingParent = {..._team}..remove('parent');
    final repeatedAncestor = {..._root, 'id': 'team'};
    final invalidOrganizations = [
      missingParent,
      {..._team, 'parent': null},
      {..._team, 'parent_id': 'other'},
      {
        ..._team,
        'parent': {
          ..._division,
          'parent_id': 'team',
          'parent': repeatedAncestor,
        },
      },
    ];
    for (final organization in invalidOrganizations) {
      expect(
        () => UserTreeSelectionUser.fromJson(_selectionJson('u', organization)),
        throwsFormatException,
      );
    }
    final payload = _selectionJson('u', _team);
    expect(
      () => UserTreeSelectionUser.fromJson({
        ...payload,
        'organization_id': 'other',
      }),
      throwsFormatException,
    );
    expect(
      () => UserTreeSelectionUser.fromJson({...payload}..remove('profile')),
      throwsFormatException,
    );
    expect(
      () => UserTreeSelectionUser.fromJson(
        _selectionJson('u', {..._team, 'type': null}),
      ),
      throwsA(isA<CheckedFromJsonException>()),
    );
  });

  test(
    'tree preserves root users and every level, and excludes another root',
    () {
      final users = [
        UserTreeSelectionUser.fromJson(_selectionJson('root-user', _root)),
        UserTreeSelectionUser.fromJson(
          _selectionJson('division-user', _division),
        ),
        UserTreeSelectionUser.fromJson(_selectionJson('team-user', _team)),
        UserTreeSelectionUser.fromJson(
          _selectionJson('other-user', {..._root, 'id': 'other-root'}),
        ),
      ];
      final currentUser = decodeAuthenticatedUser(_authenticatedUserJson());
      final tree = buildScheduleUserTree(
        users: users,
        currentUser: currentUser,
      );
      expect(tree.single.id, 'root');
      expect(tree.single.label, 'Công ty A');
      expect(tree.single.items.single.id, 'root-user');
      expect(tree.single.childGroups.single.id, 'division');
      expect(tree.single.childGroups.single.items.single.id, 'division-user');
      expect(
        tree.single.childGroups.single.childGroups.single.items.single.id,
        'team-user',
      );
      expect(
        buildVisibleScheduleUserIds(users: users, currentUser: currentUser),
        {'root-user', 'division-user', 'team-user'},
      );
    },
  );

  test('tree fails loudly on conflicting parents from different users', () {
    final users = [
      UserTreeSelectionUser.fromJson(_selectionJson('one', _team)),
      UserTreeSelectionUser.fromJson(
        _selectionJson('two', {..._team, 'parent_id': 'root', 'parent': _root}),
      ),
    ];
    expect(
      () => buildScheduleUserTree(
        users: users,
        currentUser: decodeAuthenticatedUser(_authenticatedUserJson()),
      ),
      throwsFormatException,
    );
  });

  test('shuffled deep hierarchies render every user exactly once', () {
    final random = Random(42);
    final currentUser = decodeAuthenticatedUser(_authenticatedUserJson());
    for (var sample = 0; sample < 50; sample++) {
      Map<String, dynamic> organization = _root;
      final users = <UserTreeSelectionUser>[];
      final expected = <String>[];
      final depth = random.nextInt(12) + 1;
      for (var level = 0; level < depth; level++) {
        final id = 'user-$level';
        users.add(
          UserTreeSelectionUser.fromJson(_selectionJson(id, organization)),
        );
        expected.add(id);
        organization = {
          ..._team,
          'id': 'node-$level',
          'parent_id': organization['id'],
          'parent': organization,
        };
      }
      users.shuffle(random);
      final tree = buildScheduleUserTree(
        users: users,
        currentUser: currentUser,
      );
      expect(
        _itemIds(tree.single),
        unorderedEquals(expected),
        reason: 'sample=$sample depth=$depth',
      );
    }
  });

  test('attendance context consumes organization access assignments', () async {
    final location = <String, dynamic>{
      'id': 'location',
      'name': 'Văn phòng',
      'latitude': 10.0,
      'longitude': 106.0,
      'radius_meters': 100,
      'validation_mode': 'location',
      'deleted_at': null,
      'created_at': '2026-10-01T00:00:00Z',
      'updated_at': '2026-10-01T00:00:00Z',
      'ips': [],
      'users': [],
      'excluded_users': [],
      'organizations': [_team],
    };
    final adapter = _adapter({
      'ip_address': null,
      'has_shift_today': true,
      'user': {'id': 'employee', 'name': 'Employee'},
      'assigned_locations': [location],
    });
    final context = await MobileAttendanceApi(_client(adapter)).fetchContext();
    expect(adapter.lastRequest.path, '/attendance/context');
    expect(context.assignedLocations.single.organizations.single.id, 'team');
    expect(AttendanceContext.fromJson(context.toJson()), context);
    expect(
      () => AttendanceLocation.fromJson({...location}..remove('organizations')),
      throwsA(isA<CheckedFromJsonException>()),
    );
  });
}

Iterable<String> _itemIds(TreeSelectGroup group) sync* {
  yield* group.items.map((item) => item.id);
  for (final child in group.childGroups) {
    yield* _itemIds(child);
  }
}

ReplyAdapter _adapter(Object json) => ReplyAdapter(
  ResponseBody.fromString(
    jsonEncode(json),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  ),
);

ApiClient _client(ReplyAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://obee.test/api'));
  dio.httpClientAdapter = adapter;
  addTearDown(dio.close);
  return ApiClient(dio);
}

Map<String, dynamic> _authenticatedUserJson() => {
  'id': 'employee',
  'name': 'Employee',
  'username': 'employee',
  'email': null,
  'avatar': null,
  'deleted_at': null,
  'email_verified_at': null,
  'supabase_id': null,
  'created_at': '2026-10-01T00:00:00Z',
  'updated_at': '2026-10-01T00:00:00Z',
  'organization_id': 'team',
  'organization': {..._team}..remove('parent'),
  'root_organization_id': 'root',
  'roles': [],
  'permissions': [],
};

Map<String, dynamic> _selectionJson(
  String id,
  Map<String, dynamic> organization,
) => {
  'id': id,
  'name': id,
  'username': id,
  'deleted_at': null,
  'organization_id': organization['id'],
  'organization': organization,
  'profile': {'code': 'EMP-$id'},
};

final _root = <String, dynamic>{
  'id': 'root',
  'name': 'Công ty A',
  'type': 'Công ty',
  'parent_id': null,
  'tax_identification_number': '0123456789',
  'parent': null,
  'created_at': '2026-10-01T00:00:00Z',
  'updated_at': '2026-10-01T00:00:00Z',
};
final _division = <String, dynamic>{
  'id': 'division',
  'name': 'Khối A',
  'type': 'Khối',
  'parent_id': 'root',
  'tax_identification_number': null,
  'parent': _root,
  'created_at': '2026-10-01T00:00:00Z',
  'updated_at': '2026-10-01T00:00:00Z',
};
final _team = <String, dynamic>{
  'id': 'team',
  'name': 'Tổ A',
  'type': 'Tổ',
  'parent_id': 'division',
  'tax_identification_number': null,
  'parent': _division,
  'created_at': '2026-10-01T00:00:00Z',
  'updated_at': '2026-10-01T00:00:00Z',
};

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:obee_mobile/src/app/app.dart';
import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/core/location/device_location_service.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_api.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/data/user_profile.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/profile/data/profile_api.dart';
import 'package:obee_mobile/src/features/profile/data/update_user_input.dart';
import 'package:obee_mobile/src/features/profile/ui/edit_profile_page.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_page.dart';

final _appConfig = AppConfig.parse(
  apiBaseUrl: 'http://obee.local/api',
  appBaseUrl: 'http://obee.local',
);

void main() {
  testWidgets('profile shows missing email for a user without email', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authApiProvider.overrideWithValue(_FakeAuthApi(email: null)),
          tokenStorageProvider.overrideWithValue(
            _MemoryTokenStorage('token-1'),
          ),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, child) => Scaffold(
              body: ref.watch(authControllerProvider).isAuthenticated
                  ? const ProfilePage()
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final emailRow = find
        .ancestor(of: find.text('Email'), matching: find.byType(Row))
        .first;
    expect(
      find.descendant(of: emailRow, matching: find.text('Chưa có')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens edit profile as a page and submits updated profile data', (
    tester,
  ) async {
    final authApi = _FakeAuthApi();
    final profileApi = _FakeProfileApi();

    await tester.pumpWidget(
      _buildProfileApp(profileApi: profileApi, authApi: authApi),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hồ sơ'));
    await tester.pumpAndSettle();

    expect(find.text('Admin User'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Chỉnh sửa hồ sơ'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfilePage), findsOneWidget);
    expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('Đổi ảnh đại diện'), findsOneWidget);
    expect(
      find.text(
        'Tính năng cập nhật ảnh đại diện sẽ được bổ sung trong thời gian tới.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Đã hiểu'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Updated User');
    final saveButton = find.descendant(
      of: find.byType(EditProfilePage),
      matching: find.widgetWithText(FilledButton, 'Lưu thông tin'),
    );
    await tester.scrollUntilVisible(
      saveButton,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    tester.widget<FilledButton>(saveButton).onPressed!.call();
    await tester.pumpAndSettle();

    expect(profileApi.lastInput?.name, 'Updated User');
    expect(find.text('Updated User'), findsAtLeastNWidgets(1));
  });

  testWidgets('submits updated profile data through header action button', (
    tester,
  ) async {
    final profileApi = _FakeProfileApi();
    await tester.pumpWidget(_buildProfileApp(profileApi: profileApi));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hồ sơ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chỉnh sửa hồ sơ'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfilePage), findsOneWidget);
    expect(
      find.byKey(const ValueKey('edit_profile_header_save')),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField).first, 'Header Saved User');
    await tester.tap(find.byKey(const ValueKey('edit_profile_header_save')));
    await tester.pumpAndSettle();

    expect(profileApi.lastInput?.name, 'Header Saved User');
    expect(find.text('Header Saved User'), findsAtLeastNWidgets(1));
  });
}

Widget _buildProfileApp({required ProfileApi profileApi, AuthApi? authApi}) {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(_appConfig),
      attendanceApiProvider.overrideWithValue(_FakeAttendanceApi()),
      deviceLocationServiceProvider.overrideWithValue(
        DeviceLocationService(
          platform: _FakeGeolocatorPlatform(
            permission: LocationPermission.deniedForever,
          ),
        ),
      ),
      tokenStorageProvider.overrideWithValue(_MemoryTokenStorage('token-1')),
      authApiProvider.overrideWithValue(authApi ?? _FakeAuthApi()),
      profileApiProvider.overrideWithValue(profileApi),
    ],
    child: const ObeeMobileApp(),
  );
}

class _FakeAuthApi implements AuthApi {
  _FakeAuthApi({String? email = 'admin@example.com'})
    : user = User(
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        id: 'user-1',
        name: 'Admin User',
        username: 'admin',
        email: email,
        avatar: null,
        profile: const UserProfile(
          code: 'EMP-TEST',
          phoneNumber: '0987654321',
          birthday: '1990-04-05',
          address: 'Ho Chi Minh City',
          sex: 'female',
        ),
      );

  final User user;

  @override
  Future<User> currentUser() async => user;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

class _FakeProfileApi implements ProfileApi {
  UpdateUserInput? lastInput;

  @override
  Future<User> updateProfile({required UpdateUserInput input}) async {
    lastInput = input;

    return User(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'user-1',
      name: input.name,
      username: 'admin',
      email: 'admin@example.com',
      avatar: null,
      profile: UserProfile(
        code: 'EMP-TEST',
        phoneNumber: input.profile?.phoneNumber,
        birthday: input.profile?.birthday,
        address: input.profile?.address,
        sex: input.profile?.sex,
      ),
    );
  }
}

class _MemoryTokenStorage implements TokenStorage {
  _MemoryTokenStorage(this.token);

  String? token;

  @override
  Future<void> clearToken() async {
    token = null;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String token) async {
    this.token = token;
  }
}

class _FakeAttendanceApi implements AttendanceApi {
  @override
  Future<AttendanceContext> fetchContext() async {
    return const AttendanceContext(
      user: AttendanceUserRef(id: 'user-1', name: 'User'),
      ipAddress: null,
      assignedLocations: [],
    );
  }

  @override
  Future<AttendanceDayDetail> fetchDayDetail(String date) async {
    return AttendanceDayDetail(date: date, totalWorkSeconds: 0, logs: const []);
  }

  @override
  Future<List<AttendanceRangeSummary>> fetchRange({
    required String from,
    required String to,
  }) async {
    return const [];
  }

  @override
  Future<AttendanceLog> punch(AttendanceCoordinates? coordinates) async {
    return const AttendanceLog(
      source: 'mobile',
      id: 'log-1',
      checkedAt: '2026-01-02 03:04:05',
    );
  }
}

final class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  _FakeGeolocatorPlatform({this.permission = LocationPermission.whileInUse});

  final LocationPermission permission;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => permission;
}

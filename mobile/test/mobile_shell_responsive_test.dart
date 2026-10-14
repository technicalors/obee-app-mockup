import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:obee_mobile/src/app/app.dart';
import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/app/router.dart';
import 'package:obee_mobile/src/core/location/device_location_service.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_api.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/data/user_profile.dart';

final _appConfig = AppConfig.parse(
  apiBaseUrl: 'http://obee.local/api',
  appBaseUrl: 'http://obee.local',
);

void main() {
  testWidgets('uses bottom navigation on phone widths', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('shell_navigation_bar')), findsOneWidget);
    expect(find.byKey(const ValueKey('shell_navigation_rail')), findsNothing);
    expect(find.text('Yêu cầu'), findsOneWidget);
  });

  testWidgets('notifications are disabled in attendance and their route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Chấm công'), findsAtLeastNWidgets(1));
    expect(find.byTooltip('Thông báo'), findsNothing);
    expect(
      find.byKey(const ValueKey('attendance_notifications_button')),
      findsNothing,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ObeeMobileApp)),
      listen: false,
    );
    final router = container.read(routerProvider);
    router.go('/app/notifications');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/app/attendance');
    expect(find.text('Thông báo'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens Requests through bottom navigation on phone widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yêu cầu'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('shell_navigation_bar')), findsOneWidget);
    expect(find.byKey(const ValueKey('shell_navigation_rail')), findsNothing);
    expect(find.byKey(const ValueKey('request_add_action')), findsOneWidget);
  });

  testWidgets('uses navigation rail on wide layouts', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('shell_navigation_rail')), findsOneWidget);
    expect(find.byKey(const ValueKey('shell_navigation_bar')), findsNothing);
    expect(find.text('Yêu cầu'), findsOneWidget);
  });

  testWidgets('opens Requests through navigation rail on wide layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yêu cầu'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('shell_navigation_rail')), findsOneWidget);
    expect(find.byKey(const ValueKey('shell_navigation_bar')), findsNothing);
    expect(find.byKey(const ValueKey('request_add_action')), findsOneWidget);
  });
}

Widget _buildApp() {
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
      authApiProvider.overrideWithValue(_FakeAuthApi()),
    ],
    child: const ObeeMobileApp(),
  );
}

class _FakeAuthApi implements AuthApi {
  @override
  Future<User> currentUser() async {
    return const User(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'user-1',
      name: 'Admin User',
      username: 'admin',
      email: 'admin@example.com',
      avatar: null,
      profile: UserProfile(code: 'EMP-TEST'),
    );
  }

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

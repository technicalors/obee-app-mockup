import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/core/location/device_location_service.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/app/app.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_api.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';

final _appConfig = AppConfig.parse(
  apiBaseUrl: 'http://obee.local/api',
  appBaseUrl: 'http://obee.local',
);

void main() {
  testWidgets('shows login form', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
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
          tokenStorageProvider.overrideWithValue(_MemoryTokenStorage()),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
        ],
        child: const ObeeMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Obee'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Mã nhân viên'), findsOneWidget);
    expect(find.text('Nhập mã nhân viên'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.text('Nhập mật khẩu'), findsOneWidget);
    expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Tạo tài khoản'), findsNothing);
    expect(find.text('Google'), findsNothing);
    expect(find.text('Quên mật khẩu?'), findsNothing);
    expect(find.text('Microsoft'), findsNothing);
    expect(find.text('Apple'), findsNothing);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('remember me row does not overflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
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
          tokenStorageProvider.overrideWithValue(_MemoryTokenStorage()),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
        ],
        child: const ObeeMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Ghi nhớ đăng nhập'), findsOneWidget);
    expect(find.text('Quên mật khẩu?'), findsNothing);
  });
}

class _FakeAuthApi implements AuthApi {
  @override
  Future<User> currentUser() async {
    throw UnimplementedError();
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
  @override
  Future<void> clearToken() async {}

  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> writeToken(String token) async {}
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

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

final _appConfig = AppConfig.parse(
  apiBaseUrl: 'http://obee.local/api',
  appBaseUrl: 'http://obee.local',
);

void main() {
  testWidgets('attendance layout stays stable on narrow phones', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
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
          tokenStorageProvider.overrideWithValue(
            _MemoryTokenStorage('token-1'),
          ),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
        ],
        child: const ObeeMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Obee Office'), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey('attendance_punch_button')),
      findsOneWidget,
    );
    // Explicitly verify "Giờ Việt Nam (GMT+7)" is removed
    expect(find.textContaining('Giờ Việt Nam'), findsNothing);
    expect(find.textContaining('GMT+7'), findsNothing);

    // Verify Punch tab cards
    expect(find.text('Ca làm việc'), findsOneWidget);
    expect(find.text('Kiểm tra lại'), findsOneWidget);
    expect(find.text('GPS ngoài vùng'), findsNothing);
    expect(find.text('IP hợp lệ'), findsOneWidget);
    expect(find.textContaining('IP hiện tại:'), findsNothing);

    // Switch to Calendar (Lịch sử) tab
    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();

    expect(find.text('Ngày công'), findsOneWidget);
    expect(find.text('Muộn'), findsOneWidget);
    expect(find.text('Vắng mặt'), findsAtLeastNWidgets(1));
    expect(find.text('Tổng giờ'), findsOneWidget);
  });

  testWidgets('switching to calendar automatically on punch completion', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_appConfig),
          attendanceApiProvider.overrideWithValue(_FakeAttendanceApi()),
          deviceLocationServiceProvider.overrideWithValue(
            DeviceLocationService(
              platform: _FakeGeolocatorPlatform(
                permission: LocationPermission.whileInUse,
              ),
            ),
          ),
          tokenStorageProvider.overrideWithValue(
            _MemoryTokenStorage('token-1'),
          ),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
        ],
        child: const ObeeMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('attendance_punch_button')),
      findsOneWidget,
    );

    // Tap punch button
    expect(find.textContaining('IP hiện tại:'), findsNothing);
    expect(find.textContaining('Sai số GPS'), findsNothing);
    await tester.ensureVisible(
      find.byKey(const ValueKey('attendance_punch_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('attendance_punch_button')));
    await tester.pumpAndSettle();

    // Verify it automatically switched to Lịch sử tab
    expect(find.text('Ngày công'), findsOneWidget);
    expect(find.text('Tổng giờ'), findsOneWidget);
  });

  testWidgets('cannot punch when user has no shift today', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_appConfig),
          attendanceApiProvider.overrideWithValue(
            _FakeAttendanceApi(hasShiftToday: false),
          ),
          deviceLocationServiceProvider.overrideWithValue(
            DeviceLocationService(
              platform: _FakeGeolocatorPlatform(
                permission: LocationPermission.whileInUse,
              ),
            ),
          ),
          tokenStorageProvider.overrideWithValue(
            _MemoryTokenStorage('token-1'),
          ),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
        ],
        child: const ObeeMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify warning that user is not assigned a shift
    expect(
      find.textContaining('Chỉ khi được phân ca mới có thể chấm công'),
      findsOneWidget,
    );
    expect(find.text('Chưa phân ca'), findsOneWidget);

    // Tapping punch button shows snackbar
    await tester.ensureVisible(
      find.byKey(const ValueKey('attendance_punch_button')),
    );
    await tester.tap(find.byKey(const ValueKey('attendance_punch_button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Bạn chưa được phân ca làm việc hôm nay.'),
      findsOneWidget,
    );
  });
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
  _FakeAttendanceApi({this.hasShiftToday = true});

  final bool hasShiftToday;

  @override
  Future<AttendanceContext> fetchContext() async {
    return AttendanceContext(
      user: const AttendanceUserRef(id: 'user-1', name: 'User'),
      ipAddress: '203.0.113.1',
      hasShiftToday: hasShiftToday,
      assignedLocations: const [
        AttendanceLocation(
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          id: 'location-1',
          name: 'Obee Office',
          latitude: 10.0,
          longitude: 106.0,
          radiusMeters: 200,
          validationMode: 'either',
          ips: [
            AttendanceLocationIp(
              attendanceLocationId: 'location-1',
              createdAt: '2026-01-01T00:00:00Z',
              updatedAt: '2026-01-01T00:00:00Z',
              id: 'ip-1',
              ipAddress: '203.0.113.1',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<AttendanceDayDetail> fetchDayDetail(String date) async {
    return AttendanceDayDetail(
      date: date,
      totalWorkSeconds: 28800,
      logs: const [
        AttendanceLog(
          source: 'mobile',
          id: 'log-1',
          checkedAt: '2026-01-02 08:00:00',
          location: AttendanceLogLocation(
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
            id: 'location-1',
            name: 'Obee Office',
            latitude: 10.0,
            longitude: 106.0,
            radiusMeters: 200,
            validationMode: 'either',
          ),
        ),
      ],
    );
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

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    return Position(
      longitude: 106.0,
      latitude: 10.0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      altitudeAccuracy: 1,
      heading: 0,
      headingAccuracy: 1,
      speed: 0,
      speedAccuracy: 1,
    );
  }
}

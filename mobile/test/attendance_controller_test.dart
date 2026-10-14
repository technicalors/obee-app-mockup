import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:obee_mobile/src/core/location/device_location_service.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_api.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/attendance/state/attendance_controller.dart';

void main() {
  for (final mode in ['location', 'ip', 'both', 'either']) {
    for (final gpsAvailable in [true, false]) {
      test(
        'punch honors $mode with GPS available=$gpsAvailable and matching IP',
        () async {
          final api = _AttendanceApi(mode: mode);
          final container = ProviderContainer(
            overrides: [
              attendanceApiProvider.overrideWithValue(api),
              deviceLocationServiceProvider.overrideWithValue(
                DeviceLocationService(
                  platform: _PositionPlatform(gpsAvailable: gpsAvailable),
                  clock: Clock.fixed(_measuredAt),
                ),
              ),
            ],
          );
          addTearDown(container.dispose);
          await container.read(attendanceControllerProvider.notifier).punch();
          final shouldPunch = gpsAvailable || mode == 'ip' || mode == 'either';
          expect(api.punchCalls, shouldPunch ? 1 : 0);
          if (shouldPunch) {
            expect(api.submittedPosition, gpsAvailable ? isNotNull : isNull);
          }
          expect(container.read(attendanceControllerProvider).punching, false);
        },
      );
    }
  }

  test(
    'punch uses refreshed server IP instead of an earlier matching IP',
    () async {
      final api = _AttendanceApi(mode: 'ip');
      final container = ProviderContainer(
        overrides: [
          attendanceApiProvider.overrideWithValue(api),
          deviceLocationServiceProvider.overrideWithValue(
            DeviceLocationService(
              platform: _PositionPlatform(gpsAvailable: false),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(attendanceControllerProvider.notifier);
      await controller.loadContext();
      expect(controller.bestEvaluation!.eligibility.ipMatched, true);
      api.ip = '14.224.216.181';
      await controller.punch();
      expect(api.punchCalls, 0);
      expect(controller.bestEvaluation!.eligibility.ipMatched, false);
    },
  );
}

final _measuredAt = DateTime.utc(2026, 10, 6, 8);

final class _PositionPlatform extends GeolocatorPlatform {
  _PositionPlatform({required this.gpsAvailable});
  final bool gpsAvailable;
  @override
  Future<bool> isLocationServiceEnabled() async => gpsAvailable;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;
  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async => Position(
    longitude: 106.6972049,
    latitude: 20.8605173,
    timestamp: _measuredAt,
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

class _AttendanceApi implements AttendanceApi {
  _AttendanceApi({required this.mode});
  final String mode;
  String ip = '14.224.216.180';
  int punchCalls = 0;
  AttendanceCoordinates? submittedPosition;
  @override
  Future<AttendanceContext> fetchContext() async => AttendanceContext(
    user: const AttendanceUserRef(id: 'user-1', name: 'User'),
    ipAddress: ip,
    assignedLocations: [
      AttendanceLocation(
        id: 'loc-1',
        name: 'Office',
        latitude: 20.8605173,
        longitude: 106.6972049,
        radiusMeters: 250,
        validationMode: mode,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        ips: const [
          AttendanceLocationIp(
            id: 'ip-1',
            attendanceLocationId: 'loc-1',
            ipAddress: '14.224.216.180',
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
          ),
        ],
      ),
    ],
  );
  @override
  Future<AttendanceDayDetail> fetchDayDetail(String date) async =>
      AttendanceDayDetail(date: date, logs: [], totalWorkSeconds: 0);
  @override
  Future<List<AttendanceRangeSummary>> fetchRange({
    required String from,
    required String to,
  }) async => [];
  @override
  Future<AttendanceLog> punch(AttendanceCoordinates? coordinates) async {
    punchCalls++;
    submittedPosition = coordinates;
    return const AttendanceLog(
      id: 'log-1',
      checkedAt: '2026-10-06T08:00:00Z',
      source: 'obee',
    );
  }
}

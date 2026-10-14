import 'package:flutter_test/flutter_test.dart';
import 'package:clock/clock.dart';
import 'package:geolocator/geolocator.dart';
import 'package:obee_mobile/src/core/location/device_location_service.dart';

void main() {
  final now = DateTime.utc(2026, 10, 6, 8);
  test('requests best accuracy and preserves measurement metadata', () async {
    final platform = _FakeGeolocatorPlatform(
      position: _position(
        latitude: 20.8605173,
        longitude: 106.6972049,
        timestamp: now,
        accuracy: 125,
      ),
    );
    final service = DeviceLocationService(
      platform: platform,
      clock: Clock.fixed(now),
    );
    final result = await service.getCurrentLocation();
    expect(platform.settings!.accuracy, LocationAccuracy.best);
    expect(result.accuracyMeters, 125);
    expect(result.measuredAt, now);
  });
  for (final age in [
    const Duration(seconds: 31),
    const Duration(seconds: -6),
  ]) {
    test('rejects measurement age $age against the injected clock', () async {
      final service = DeviceLocationService(
        platform: _FakeGeolocatorPlatform(
          position: _position(
            latitude: 10,
            longitude: 106,
            timestamp: now.subtract(age),
          ),
        ),
        clock: Clock.fixed(now),
      );
      await expectLater(service.getCurrentLocation(), throwsFormatException);
    });
  }
  test('rejects invalid GPS accuracy at the device boundary', () async {
    final service = DeviceLocationService(
      platform: _FakeGeolocatorPlatform(
        position: _position(
          latitude: 10,
          longitude: 106,
          timestamp: now,
          accuracy: -1,
        ),
      ),
      clock: Clock.fixed(now),
    );
    await expectLater(service.getCurrentLocation(), throwsFormatException);
  });
  test('returns serviceDisabled when device location is off', () async {
    final service = DeviceLocationService(
      platform: _FakeGeolocatorPlatform(serviceEnabled: false),
    );

    final result = await service.getCurrentLocation();

    expect(result.status, DeviceLocationStatus.serviceDisabled);
  });

  test('requests permission and returns permissionDenied', () async {
    final platform = _FakeGeolocatorPlatform(
      permission: LocationPermission.denied,
      requestedPermission: LocationPermission.deniedForever,
    );
    final service = DeviceLocationService(platform: platform);

    final result = await service.getCurrentLocation();

    expect(platform.didRequestPermission, isTrue);
    expect(result.status, DeviceLocationStatus.permissionDeniedForever);
  });

  test('rejects stale location measurements', () async {
    final stale = _position(
      latitude: 10,
      longitude: 106,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    );
    final service = DeviceLocationService(
      platform: _FakeGeolocatorPlatform(position: stale),
    );
    await expectLater(service.getCurrentLocation(), throwsFormatException);
  });

  test('returns current coordinates when location is available', () async {
    final service = DeviceLocationService(
      platform: _FakeGeolocatorPlatform(
        permission: LocationPermission.whileInUse,
        position: _position(latitude: 10.7769, longitude: 106.7009),
      ),
    );

    final result = await service.getCurrentLocation();

    expect(result.status, DeviceLocationStatus.ready);
    expect(result.latitude, 10.7769);
    expect(result.longitude, 106.7009);
  });
}

final class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  _FakeGeolocatorPlatform({
    this.serviceEnabled = true,
    this.permission = LocationPermission.whileInUse,
    this.requestedPermission = LocationPermission.whileInUse,
    Position? position,
  }) : position = position ?? _position(latitude: 0, longitude: 0);

  final bool serviceEnabled;
  final LocationPermission permission;
  final LocationPermission requestedPermission;
  final Position position;

  bool didRequestPermission = false;
  LocationSettings? settings;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    didRequestPermission = true;

    return requestedPermission;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    settings = locationSettings;
    return position;
  }
}

Position _position({
  required double latitude,
  required double longitude,
  DateTime? timestamp,
  double accuracy = 1,
}) {
  return Position(
    longitude: longitude,
    latitude: latitude,
    timestamp: timestamp ?? DateTime.now(),
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 1,
  );
}

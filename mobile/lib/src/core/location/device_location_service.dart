import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clock/clock.dart';
import 'package:obee_mobile/src/core/network/mock_api_interceptor.dart';
import 'package:obee_mobile/src/core/time/clock_provider.dart';
import 'package:geolocator/geolocator.dart';

enum DeviceLocationStatus {
  ready,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

final class DeviceLocationResult {
  const DeviceLocationResult({
    required this.status,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.measuredAt,
  });

  final DeviceLocationStatus status;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final DateTime? measuredAt;
}

final class DeviceLocationService {
  DeviceLocationService({
    GeolocatorPlatform? platform,
    this.clock = const Clock(),
  }) : _platform = platform ?? GeolocatorPlatform.instance;

  final GeolocatorPlatform _platform;
  final Clock clock;

  Future<bool> openSettings() => _platform.openAppSettings();

  Future<DeviceLocationResult> getCurrentLocation() async {
    if (mockApiEnabled) {
      return DeviceLocationResult(
        status: DeviceLocationStatus.ready,
        latitude: 10.7769,
        longitude: 106.7009,
        accuracyMeters: 5,
        measuredAt: clock.now(),
      );
    }

    final serviceEnabled = await _platform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const DeviceLocationResult(
        status: DeviceLocationStatus.serviceDisabled,
      );
    }

    var permission = await _platform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _platform.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return const DeviceLocationResult(
        status: DeviceLocationStatus.permissionDeniedForever,
      );
    }
    if (permission == LocationPermission.denied) {
      return const DeviceLocationResult(
        status: DeviceLocationStatus.permissionDenied,
      );
    }

    final position = await _platform.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final age = clock.now().difference(position.timestamp);
    if (age > const Duration(seconds: 30) ||
        age < const Duration(seconds: -5)) {
      throw const FormatException('Location measurement is not fresh.');
    }
    if (!position.latitude.isFinite ||
        position.latitude < -90 ||
        position.latitude > 90 ||
        !position.longitude.isFinite ||
        position.longitude < -180 ||
        position.longitude > 180 ||
        !position.accuracy.isFinite ||
        position.accuracy < 0) {
      throw const FormatException('Location measurement is invalid.');
    }

    return DeviceLocationResult(
      status: DeviceLocationStatus.ready,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      measuredAt: position.timestamp,
    );
  }
}

final deviceLocationServiceProvider = Provider<DeviceLocationService>((ref) {
  return DeviceLocationService(clock: ref.watch(clockProvider));
});

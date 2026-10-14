import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';

final attendanceApiProvider = Provider<AttendanceApi>((ref) {
  return MobileAttendanceApi(ref.watch(apiClientProvider));
});

abstract interface class AttendanceApi {
  Future<AttendanceContext> fetchContext();

  Future<AttendanceDayDetail> fetchDayDetail(String date);

  Future<List<AttendanceRangeSummary>> fetchRange({
    required String from,
    required String to,
  });

  Future<AttendanceLog> punch(AttendanceCoordinates? coordinates);
}

final class MobileAttendanceApi implements AttendanceApi {
  const MobileAttendanceApi(this._api);

  final ApiClient _api;

  @override
  Future<AttendanceContext> fetchContext() async {
    final body = await _api.get<Map<String, dynamic>>('/attendance/context');

    return AttendanceContext.fromJson(body);
  }

  @override
  Future<AttendanceDayDetail> fetchDayDetail(String date) async {
    final body = await _api.get<Map<String, dynamic>>(
      '/attendance/logs',
      queryParameters: {'date': date},
    );

    return AttendanceDayDetail.fromJson(body);
  }

  @override
  Future<List<AttendanceRangeSummary>> fetchRange({
    required String from,
    required String to,
  }) async {
    final body = await _api.get<List<dynamic>>(
      '/attendance/logs/range',
      queryParameters: {'from': from, 'to': to},
    );

    return body
        .cast<Map<String, dynamic>>()
        .map(AttendanceRangeSummary.fromJson)
        .toList(growable: false);
  }

  @override
  Future<AttendanceLog> punch(AttendanceCoordinates? coordinates) async {
    final body = await _api.post<Map<String, dynamic>>(
      '/attendance/logs',
      data: {
        if (coordinates != null) ...{
          'latitude': coordinates.latitude,
          'longitude': coordinates.longitude,
        },
      },
    );

    return AttendanceLog.fromJson(body);
  }
}

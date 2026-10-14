// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:obee_mobile/src/features/auth/data/organization_ref.dart';

part 'attendance_models.freezed.dart';
part 'attendance_models.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AttendanceLocationIp with _$AttendanceLocationIp {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AttendanceLocationIp({
    required String id,
    @JsonKey(name: 'ip_address') required String ipAddress,
    @JsonKey(name: 'attendance_location_id', required: true)
    required String attendanceLocationId,
    @JsonKey(name: 'created_at', required: true, disallowNullValue: true)
    required String createdAt,
    @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)
    required String updatedAt,
  }) = _AttendanceLocationIp;

  factory AttendanceLocationIp.fromJson(Map<String, dynamic> json) =>
      _$AttendanceLocationIpFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class AttendanceLocation with _$AttendanceLocation {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AttendanceLocation({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'radius_meters') required double radiusMeters,
    @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson)
    required String validationMode,
    @JsonKey(required: true, disallowNullValue: true)
    @Default(<AttendanceLocationIp>[])
    List<AttendanceLocationIp> ips,
    @JsonKey(name: 'created_at', required: true, disallowNullValue: true)
    required String createdAt,
    @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)
    required String updatedAt,
    @JsonKey(required: true, disallowNullValue: true)
    @Default(<AttendanceUserRef>[])
    List<AttendanceUserRef> users,
    @JsonKey(required: true, disallowNullValue: true)
    @Default(<OrganizationRef>[])
    List<OrganizationRef> organizations,
    @JsonKey(name: 'excluded_users', required: true, disallowNullValue: true)
    @Default(<AttendanceUserRef>[])
    List<AttendanceUserRef> excludedUsers,
  }) = _AttendanceLocation;

  factory AttendanceLocation.fromJson(Map<String, dynamic> json) =>
      _$AttendanceLocationFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class AttendanceContext with _$AttendanceContext {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AttendanceContext({
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'assigned_locations')
    required List<AttendanceLocation> assignedLocations,
    @JsonKey(name: 'has_shift_today', required: true, disallowNullValue: true)
    @Default(true)
    bool hasShiftToday,
    @JsonKey(name: 'shift_start_at') String? shiftStartAt,
    @JsonKey(name: 'shift_end_at') String? shiftEndAt,
    @JsonKey(required: true, disallowNullValue: true)
    required AttendanceUserRef user,
  }) = _AttendanceContext;

  factory AttendanceContext.fromJson(Map<String, dynamic> json) =>
      _$AttendanceContextFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class AttendanceLog with _$AttendanceLog {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AttendanceLog({
    required String id,
    @JsonKey(name: 'checked_at') required String checkedAt,
    @JsonKey(name: 'ip_address') String? ipAddress,
    double? latitude,
    double? longitude,
    AttendanceLogLocation? location,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'attendance_location_id', required: true)
    String? attendanceLocationId,
    @JsonKey(required: true, disallowNullValue: true) required String source,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _AttendanceLog;

  factory AttendanceLog.fromJson(Map<String, dynamic> json) =>
      _$AttendanceLogFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class AttendanceDayDetail with _$AttendanceDayDetail {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AttendanceDayDetail({
    required String date,
    @JsonKey(name: 'total_work_seconds') required int totalWorkSeconds,
    required List<AttendanceLog> logs,
    @JsonKey(name: 'first_check_in_at', required: true) String? firstCheckInAt,
    @JsonKey(name: 'last_check_out_at', required: true) String? lastCheckOutAt,
    @JsonKey(name: 'is_late') @Default(false) bool isLate,
    @JsonKey(name: 'shift_start_at') String? shiftStartAt,
    @JsonKey(name: 'shift_end_at') String? shiftEndAt,
  }) = _AttendanceDayDetail;

  factory AttendanceDayDetail.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDayDetailFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class AttendanceRangeSummary with _$AttendanceRangeSummary {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AttendanceRangeSummary({
    required String date,
    @JsonKey(name: 'logs_count') required int logsCount,
    @JsonKey(name: 'on_leave', required: true, disallowNullValue: true)
    @Default(false)
    bool onLeave,
    @JsonKey(name: 'first_check_in_at', required: true) String? firstCheckInAt,
    @JsonKey(name: 'last_check_out_at', required: true) String? lastCheckOutAt,
    @JsonKey(name: 'total_work_seconds') required int totalWorkSeconds,
    @JsonKey(name: 'is_late') @Default(false) bool isLate,
    @JsonKey(name: 'shift_start_at') String? shiftStartAt,
    @JsonKey(name: 'shift_end_at') String? shiftEndAt,
  }) = _AttendanceRangeSummary;

  factory AttendanceRangeSummary.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRangeSummaryFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class AttendanceCoordinates with _$AttendanceCoordinates {
  const factory AttendanceCoordinates({
    required double latitude,
    required double longitude,
  }) = _AttendanceCoordinates;
}

@Freezed(fromJson: true, toJson: true)
abstract class AttendanceUserRef with _$AttendanceUserRef {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AttendanceUserRef({required Object id, required String name}) =
      _AttendanceUserRef;
  factory AttendanceUserRef.fromJson(Map<String, dynamic> json) {
    if (json['id'] is! String && json['id'] is! num) {
      throw const FormatException(
        'Attendance user id must be a string or number.',
      );
    }
    return _$AttendanceUserRefFromJson(json);
  }
}

@Freezed(fromJson: true, toJson: true)
abstract class AttendanceLogLocation with _$AttendanceLogLocation {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AttendanceLogLocation({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'radius_meters') required double radiusMeters,
    @JsonKey(name: 'validation_mode', fromJson: _validationModeFromJson)
    required String validationMode,
    @JsonKey(name: 'created_at', required: true, disallowNullValue: true)
    required String createdAt,
    @JsonKey(name: 'updated_at', required: true, disallowNullValue: true)
    required String updatedAt,
  }) = _AttendanceLogLocation;
  factory AttendanceLogLocation.fromJson(Map<String, dynamic> json) =>
      _$AttendanceLogLocationFromJson(json);
}

String _validationModeFromJson(Object? value) {
  if (value is! String ||
      !const {'location', 'ip', 'both', 'either'}.contains(value)) {
    throw const FormatException('Invalid attendance validation mode.');
  }
  return value;
}

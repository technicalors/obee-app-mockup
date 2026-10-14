// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';

part 'request_models.freezed.dart';
part 'request_models.g.dart';

@freezed
abstract class AbsenceRequestUserRef with _$AbsenceRequestUserRef {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AbsenceRequestUserRef({
    required String id,
    required String name,
    @JsonKey(name: 'username') String? username,
    String? email,
    String? avatar,
  }) = _AbsenceRequestUserRef;

  factory AbsenceRequestUserRef.fromJson(Map<String, dynamic> json) =>
      _$AbsenceRequestUserRefFromJson(json);
}

@freezed
abstract class AbsenceRequestModel with _$AbsenceRequestModel {
  const AbsenceRequestModel._();

  @JsonSerializable(checked: true, explicitToJson: true)
  const factory AbsenceRequestModel({
    required String id,
    String? code,
    @JsonKey(name: 'root_organization_id') required String rootOrganizationId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'leave_type') required String leaveTypeWire,
    @JsonKey(name: 'start_at') required String startAt,
    @JsonKey(name: 'end_at') required String endAt,
    required String reason,
    String? address,
    required String status,
    @JsonKey(name: 'duration_days') @Default(0.0) double durationDays,
    @JsonKey(name: 'reviewer_id') required String reviewerId,
    AbsenceRequestUserRef? user,
    AbsenceRequestUserRef? requester,
    AbsenceRequestUserRef? reviewer,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'approved_at') String? approvedAt,
    @JsonKey(name: 'rejected_at') String? rejectedAt,
    @JsonKey(name: 'approval_note') String? approvalNote,
  }) = _AbsenceRequestModel;

  factory AbsenceRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AbsenceRequestModelFromJson(json);

  LeaveTypeEnum get leaveType => LeaveTypeEnum.fromWireValue(leaveTypeWire);
  AbsenceRequestStatus get requestStatus =>
      AbsenceRequestStatus.fromWireValue(status);

  String get displayCode {
    if (code != null && code!.isNotEmpty) return code!;
    final normalized = id.replaceAll('-', '');
    final suffix = normalized.length >= 4
        ? normalized.substring(0, 4).toUpperCase()
        : id.toUpperCase();
    return 'YC-2026-$suffix';
  }

  String get displayRequesterName =>
      requester?.name ?? user?.name ?? 'Nhân viên';

  String get displayReviewerName => reviewer?.name ?? 'Người duyệt';
}

@freezed
abstract class LeaveBalanceModel with _$LeaveBalanceModel {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory LeaveBalanceModel({
    @Default(0.0) double entitlement,
    @Default(0.0) double used,
    @Default(0.0) double remaining,
    @JsonKey(name: 'cycle_start') String? cycleStart,
    @JsonKey(name: 'cycle_end') String? cycleEnd,
  }) = _LeaveBalanceModel;

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceModelFromJson(json);
}

class CreateRequestDraft {
  const CreateRequestDraft({
    required this.rootOrganizationId,
    required this.reviewerId,
    required this.leaveType,
    required this.startAt,
    required this.endAt,
    required this.reason,
    this.address,
  });

  final String rootOrganizationId;
  final String reviewerId;
  final LeaveTypeEnum leaveType;
  final String startAt;
  final String endAt;
  final String reason;
  final String? address;

  Map<String, dynamic> toJson() => {
    'root_organization_id': rootOrganizationId,
    'reviewer_id': reviewerId,
    'leave_type': leaveType.wireValue,
    'start_at': startAt,
    'end_at': endAt,
    'reason': reason,
    if (address != null) 'address': address,
    'status': 'pending',
  };

  Map<String, dynamic> toUpdateJson() => {
    'reviewer_id': reviewerId,
    'leave_type': leaveType.wireValue,
    'start_at': startAt,
    'end_at': endAt,
    'reason': reason,
    if (address != null) 'address': address,
    'status': 'pending',
  };
}

@freezed
abstract class WorkShiftPeriodModel with _$WorkShiftPeriodModel {
  @JsonSerializable(checked: true)
  const factory WorkShiftPeriodModel({
    required String id,
    @JsonKey(name: 'work_shift_id') required String workShiftId,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(name: 'start_day_offset') required int startDayOffset,
    @JsonKey(name: 'end_day_offset') required int endDayOffset,
  }) = _WorkShiftPeriodModel;
  factory WorkShiftPeriodModel.fromJson(Map<String, dynamic> json) =>
      _$WorkShiftPeriodModelFromJson(json);
}

@freezed
abstract class WorkShiftModel with _$WorkShiftModel {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory WorkShiftModel({
    required String id,
    @JsonKey(name: 'root_organization_id') required String rootOrganizationId,
    required String name,
    required List<WorkShiftPeriodModel> periods,
  }) = _WorkShiftModel;
  factory WorkShiftModel.fromJson(Map<String, dynamic> json) =>
      _$WorkShiftModelFromJson(json);
}

@freezed
abstract class AssignedWorkPeriodModel with _$AssignedWorkPeriodModel {
  @JsonSerializable(checked: true)
  const factory AssignedWorkPeriodModel({
    @JsonKey(name: 'start_at') required String startAt,
    @JsonKey(name: 'end_at') required String endAt,
  }) = _AssignedWorkPeriodModel;
  factory AssignedWorkPeriodModel.fromJson(Map<String, dynamic> json) =>
      _$AssignedWorkPeriodModelFromJson(json);
}

@freezed
abstract class LeaveCoverageItemModel with _$LeaveCoverageItemModel {
  @JsonSerializable(checked: true)
  const factory LeaveCoverageItemModel({
    required String date,
    required String status,
    @JsonKey(name: 'work_shift_id') String? workShiftId,
    required double hours,
    required double days,
    required String note,
  }) = _LeaveCoverageItemModel;
  factory LeaveCoverageItemModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveCoverageItemModelFromJson(json);
}

@freezed
abstract class LeaveCoveragePreviewModel with _$LeaveCoveragePreviewModel {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory LeaveCoveragePreviewModel({
    @JsonKey(name: 'total_days') required double totalDays,
    @JsonKey(name: 'working_days') required double workingDays,
    @JsonKey(name: 'holiday_days') required int holidayDays,
    @JsonKey(name: 'off_days') required int offDays,
    required List<LeaveCoverageItemModel> items,
  }) = _LeaveCoveragePreviewModel;
  factory LeaveCoveragePreviewModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveCoveragePreviewModelFromJson(json);
}

@freezed
abstract class WorkUserShiftModel with _$WorkUserShiftModel {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory WorkUserShiftModel({
    required String id,
    @JsonKey(name: 'root_organization_id') required String rootOrganizationId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'work_shift_id') required String workShiftId,
    @JsonKey(name: 'work_date') required String workDate,
    @JsonKey(name: 'start_at') required String startAt,
    @JsonKey(name: 'end_at') required String endAt,
    @JsonKey(name: 'work_shift') required WorkShiftModel workShift,
    @JsonKey(name: 'work_periods')
    required List<AssignedWorkPeriodModel> workPeriods,
  }) = _WorkUserShiftModel;
  factory WorkUserShiftModel.fromJson(Map<String, dynamic> json) =>
      _$WorkUserShiftModelFromJson(json);
}

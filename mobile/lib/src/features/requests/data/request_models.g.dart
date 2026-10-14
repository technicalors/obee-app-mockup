// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AbsenceRequestUserRef _$AbsenceRequestUserRefFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AbsenceRequestUserRef', json, ($checkedConvert) {
  final val = _AbsenceRequestUserRef(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    username: $checkedConvert('username', (v) => v as String?),
    email: $checkedConvert('email', (v) => v as String?),
    avatar: $checkedConvert('avatar', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AbsenceRequestUserRefToJson(
  _AbsenceRequestUserRef instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'email': instance.email,
  'avatar': instance.avatar,
};

_AbsenceRequestModel _$AbsenceRequestModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_AbsenceRequestModel',
      json,
      ($checkedConvert) {
        final val = _AbsenceRequestModel(
          id: $checkedConvert('id', (v) => v as String),
          code: $checkedConvert('code', (v) => v as String?),
          rootOrganizationId: $checkedConvert(
            'root_organization_id',
            (v) => v as String,
          ),
          userId: $checkedConvert('user_id', (v) => v as String),
          leaveTypeWire: $checkedConvert('leave_type', (v) => v as String),
          startAt: $checkedConvert('start_at', (v) => v as String),
          endAt: $checkedConvert('end_at', (v) => v as String),
          reason: $checkedConvert('reason', (v) => v as String),
          address: $checkedConvert('address', (v) => v as String?),
          status: $checkedConvert('status', (v) => v as String),
          durationDays: $checkedConvert(
            'duration_days',
            (v) => (v as num?)?.toDouble() ?? 0.0,
          ),
          reviewerId: $checkedConvert('reviewer_id', (v) => v as String),
          user: $checkedConvert(
            'user',
            (v) => v == null
                ? null
                : AbsenceRequestUserRef.fromJson(v as Map<String, dynamic>),
          ),
          requester: $checkedConvert(
            'requester',
            (v) => v == null
                ? null
                : AbsenceRequestUserRef.fromJson(v as Map<String, dynamic>),
          ),
          reviewer: $checkedConvert(
            'reviewer',
            (v) => v == null
                ? null
                : AbsenceRequestUserRef.fromJson(v as Map<String, dynamic>),
          ),
          createdAt: $checkedConvert('created_at', (v) => v as String?),
          approvedAt: $checkedConvert('approved_at', (v) => v as String?),
          rejectedAt: $checkedConvert('rejected_at', (v) => v as String?),
          approvalNote: $checkedConvert('approval_note', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'rootOrganizationId': 'root_organization_id',
        'userId': 'user_id',
        'leaveTypeWire': 'leave_type',
        'startAt': 'start_at',
        'endAt': 'end_at',
        'durationDays': 'duration_days',
        'reviewerId': 'reviewer_id',
        'createdAt': 'created_at',
        'approvedAt': 'approved_at',
        'rejectedAt': 'rejected_at',
        'approvalNote': 'approval_note',
      },
    );

Map<String, dynamic> _$AbsenceRequestModelToJson(
  _AbsenceRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'root_organization_id': instance.rootOrganizationId,
  'user_id': instance.userId,
  'leave_type': instance.leaveTypeWire,
  'start_at': instance.startAt,
  'end_at': instance.endAt,
  'reason': instance.reason,
  'address': instance.address,
  'status': instance.status,
  'duration_days': instance.durationDays,
  'reviewer_id': instance.reviewerId,
  'user': instance.user?.toJson(),
  'requester': instance.requester?.toJson(),
  'reviewer': instance.reviewer?.toJson(),
  'created_at': instance.createdAt,
  'approved_at': instance.approvedAt,
  'rejected_at': instance.rejectedAt,
  'approval_note': instance.approvalNote,
};

_LeaveBalanceModel _$LeaveBalanceModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_LeaveBalanceModel',
      json,
      ($checkedConvert) {
        final val = _LeaveBalanceModel(
          entitlement: $checkedConvert(
            'entitlement',
            (v) => (v as num?)?.toDouble() ?? 0.0,
          ),
          used: $checkedConvert('used', (v) => (v as num?)?.toDouble() ?? 0.0),
          remaining: $checkedConvert(
            'remaining',
            (v) => (v as num?)?.toDouble() ?? 0.0,
          ),
          cycleStart: $checkedConvert('cycle_start', (v) => v as String?),
          cycleEnd: $checkedConvert('cycle_end', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'cycleStart': 'cycle_start', 'cycleEnd': 'cycle_end'},
    );

Map<String, dynamic> _$LeaveBalanceModelToJson(_LeaveBalanceModel instance) =>
    <String, dynamic>{
      'entitlement': instance.entitlement,
      'used': instance.used,
      'remaining': instance.remaining,
      'cycle_start': instance.cycleStart,
      'cycle_end': instance.cycleEnd,
    };

_WorkShiftPeriodModel _$WorkShiftPeriodModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_WorkShiftPeriodModel',
  json,
  ($checkedConvert) {
    final val = _WorkShiftPeriodModel(
      id: $checkedConvert('id', (v) => v as String),
      workShiftId: $checkedConvert('work_shift_id', (v) => v as String),
      startTime: $checkedConvert('start_time', (v) => v as String),
      endTime: $checkedConvert('end_time', (v) => v as String),
      startDayOffset: $checkedConvert(
        'start_day_offset',
        (v) => (v as num).toInt(),
      ),
      endDayOffset: $checkedConvert(
        'end_day_offset',
        (v) => (v as num).toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'workShiftId': 'work_shift_id',
    'startTime': 'start_time',
    'endTime': 'end_time',
    'startDayOffset': 'start_day_offset',
    'endDayOffset': 'end_day_offset',
  },
);

Map<String, dynamic> _$WorkShiftPeriodModelToJson(
  _WorkShiftPeriodModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'work_shift_id': instance.workShiftId,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'start_day_offset': instance.startDayOffset,
  'end_day_offset': instance.endDayOffset,
};

_WorkShiftModel _$WorkShiftModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_WorkShiftModel', json, ($checkedConvert) {
      final val = _WorkShiftModel(
        id: $checkedConvert('id', (v) => v as String),
        rootOrganizationId: $checkedConvert(
          'root_organization_id',
          (v) => v as String,
        ),
        name: $checkedConvert('name', (v) => v as String),
        periods: $checkedConvert(
          'periods',
          (v) => (v as List<dynamic>)
              .map(
                (e) => WorkShiftPeriodModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'rootOrganizationId': 'root_organization_id'});

Map<String, dynamic> _$WorkShiftModelToJson(_WorkShiftModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'root_organization_id': instance.rootOrganizationId,
      'name': instance.name,
      'periods': instance.periods.map((e) => e.toJson()).toList(),
    };

_AssignedWorkPeriodModel _$AssignedWorkPeriodModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AssignedWorkPeriodModel', json, ($checkedConvert) {
  final val = _AssignedWorkPeriodModel(
    startAt: $checkedConvert('start_at', (v) => v as String),
    endAt: $checkedConvert('end_at', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'startAt': 'start_at', 'endAt': 'end_at'});

Map<String, dynamic> _$AssignedWorkPeriodModelToJson(
  _AssignedWorkPeriodModel instance,
) => <String, dynamic>{'start_at': instance.startAt, 'end_at': instance.endAt};

_LeaveCoverageItemModel _$LeaveCoverageItemModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_LeaveCoverageItemModel', json, ($checkedConvert) {
  final val = _LeaveCoverageItemModel(
    date: $checkedConvert('date', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    workShiftId: $checkedConvert('work_shift_id', (v) => v as String?),
    hours: $checkedConvert('hours', (v) => (v as num).toDouble()),
    days: $checkedConvert('days', (v) => (v as num).toDouble()),
    note: $checkedConvert('note', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'workShiftId': 'work_shift_id'});

Map<String, dynamic> _$LeaveCoverageItemModelToJson(
  _LeaveCoverageItemModel instance,
) => <String, dynamic>{
  'date': instance.date,
  'status': instance.status,
  'work_shift_id': instance.workShiftId,
  'hours': instance.hours,
  'days': instance.days,
  'note': instance.note,
};

_LeaveCoveragePreviewModel _$LeaveCoveragePreviewModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_LeaveCoveragePreviewModel',
  json,
  ($checkedConvert) {
    final val = _LeaveCoveragePreviewModel(
      totalDays: $checkedConvert('total_days', (v) => (v as num).toDouble()),
      workingDays: $checkedConvert(
        'working_days',
        (v) => (v as num).toDouble(),
      ),
      holidayDays: $checkedConvert('holiday_days', (v) => (v as num).toInt()),
      offDays: $checkedConvert('off_days', (v) => (v as num).toInt()),
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map(
              (e) => LeaveCoverageItemModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'totalDays': 'total_days',
    'workingDays': 'working_days',
    'holidayDays': 'holiday_days',
    'offDays': 'off_days',
  },
);

Map<String, dynamic> _$LeaveCoveragePreviewModelToJson(
  _LeaveCoveragePreviewModel instance,
) => <String, dynamic>{
  'total_days': instance.totalDays,
  'working_days': instance.workingDays,
  'holiday_days': instance.holidayDays,
  'off_days': instance.offDays,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

_WorkUserShiftModel _$WorkUserShiftModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_WorkUserShiftModel',
      json,
      ($checkedConvert) {
        final val = _WorkUserShiftModel(
          id: $checkedConvert('id', (v) => v as String),
          rootOrganizationId: $checkedConvert(
            'root_organization_id',
            (v) => v as String,
          ),
          userId: $checkedConvert('user_id', (v) => v as String),
          workShiftId: $checkedConvert('work_shift_id', (v) => v as String),
          workDate: $checkedConvert('work_date', (v) => v as String),
          startAt: $checkedConvert('start_at', (v) => v as String),
          endAt: $checkedConvert('end_at', (v) => v as String),
          workShift: $checkedConvert(
            'work_shift',
            (v) => WorkShiftModel.fromJson(v as Map<String, dynamic>),
          ),
          workPeriods: $checkedConvert(
            'work_periods',
            (v) => (v as List<dynamic>)
                .map(
                  (e) => AssignedWorkPeriodModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'rootOrganizationId': 'root_organization_id',
        'userId': 'user_id',
        'workShiftId': 'work_shift_id',
        'workDate': 'work_date',
        'startAt': 'start_at',
        'endAt': 'end_at',
        'workShift': 'work_shift',
        'workPeriods': 'work_periods',
      },
    );

Map<String, dynamic> _$WorkUserShiftModelToJson(_WorkUserShiftModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'root_organization_id': instance.rootOrganizationId,
      'user_id': instance.userId,
      'work_shift_id': instance.workShiftId,
      'work_date': instance.workDate,
      'start_at': instance.startAt,
      'end_at': instance.endAt,
      'work_shift': instance.workShift.toJson(),
      'work_periods': instance.workPeriods.map((e) => e.toJson()).toList(),
    };

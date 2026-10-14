// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceLocationIp _$AttendanceLocationIpFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_AttendanceLocationIp',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'attendance_location_id',
        'created_at',
        'updated_at',
      ],
      disallowNullValues: const ['created_at', 'updated_at'],
    );
    final val = _AttendanceLocationIp(
      id: $checkedConvert('id', (v) => v as String),
      ipAddress: $checkedConvert('ip_address', (v) => v as String),
      attendanceLocationId: $checkedConvert(
        'attendance_location_id',
        (v) => v as String,
      ),
      createdAt: $checkedConvert('created_at', (v) => v as String),
      updatedAt: $checkedConvert('updated_at', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'ipAddress': 'ip_address',
    'attendanceLocationId': 'attendance_location_id',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$AttendanceLocationIpToJson(
  _AttendanceLocationIp instance,
) => <String, dynamic>{
  'id': instance.id,
  'ip_address': instance.ipAddress,
  'attendance_location_id': instance.attendanceLocationId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_AttendanceLocation _$AttendanceLocationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_AttendanceLocation',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'ips',
            'created_at',
            'updated_at',
            'users',
            'organizations',
            'excluded_users',
          ],
          disallowNullValues: const [
            'ips',
            'created_at',
            'updated_at',
            'users',
            'organizations',
            'excluded_users',
          ],
        );
        final val = _AttendanceLocation(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          latitude: $checkedConvert('latitude', (v) => (v as num).toDouble()),
          longitude: $checkedConvert('longitude', (v) => (v as num).toDouble()),
          radiusMeters: $checkedConvert(
            'radius_meters',
            (v) => (v as num).toDouble(),
          ),
          validationMode: $checkedConvert(
            'validation_mode',
            (v) => _validationModeFromJson(v),
          ),
          ips: $checkedConvert(
            'ips',
            (v) =>
                (v as List<dynamic>?)
                    ?.map(
                      (e) => AttendanceLocationIp.fromJson(
                        e as Map<String, dynamic>,
                      ),
                    )
                    .toList() ??
                const <AttendanceLocationIp>[],
          ),
          createdAt: $checkedConvert('created_at', (v) => v as String),
          updatedAt: $checkedConvert('updated_at', (v) => v as String),
          users: $checkedConvert(
            'users',
            (v) =>
                (v as List<dynamic>?)
                    ?.map(
                      (e) =>
                          AttendanceUserRef.fromJson(e as Map<String, dynamic>),
                    )
                    .toList() ??
                const <AttendanceUserRef>[],
          ),
          organizations: $checkedConvert(
            'organizations',
            (v) =>
                (v as List<dynamic>?)
                    ?.map(
                      (e) =>
                          OrganizationRef.fromJson(e as Map<String, dynamic>),
                    )
                    .toList() ??
                const <OrganizationRef>[],
          ),
          excludedUsers: $checkedConvert(
            'excluded_users',
            (v) =>
                (v as List<dynamic>?)
                    ?.map(
                      (e) =>
                          AttendanceUserRef.fromJson(e as Map<String, dynamic>),
                    )
                    .toList() ??
                const <AttendanceUserRef>[],
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'radiusMeters': 'radius_meters',
        'validationMode': 'validation_mode',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
        'excludedUsers': 'excluded_users',
      },
    );

Map<String, dynamic> _$AttendanceLocationToJson(_AttendanceLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius_meters': instance.radiusMeters,
      'validation_mode': instance.validationMode,
      'ips': instance.ips.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'users': instance.users.map((e) => e.toJson()).toList(),
      'organizations': instance.organizations.map((e) => e.toJson()).toList(),
      'excluded_users': instance.excludedUsers.map((e) => e.toJson()).toList(),
    };

_AttendanceContext _$AttendanceContextFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_AttendanceContext',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['has_shift_today', 'user'],
          disallowNullValues: const ['has_shift_today', 'user'],
        );
        final val = _AttendanceContext(
          ipAddress: $checkedConvert('ip_address', (v) => v as String?),
          assignedLocations: $checkedConvert(
            'assigned_locations',
            (v) => (v as List<dynamic>)
                .map(
                  (e) => AttendanceLocation.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
          hasShiftToday: $checkedConvert(
            'has_shift_today',
            (v) => v as bool? ?? true,
          ),
          shiftStartAt: $checkedConvert('shift_start_at', (v) => v as String?),
          shiftEndAt: $checkedConvert('shift_end_at', (v) => v as String?),
          user: $checkedConvert(
            'user',
            (v) => AttendanceUserRef.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'ipAddress': 'ip_address',
        'assignedLocations': 'assigned_locations',
        'hasShiftToday': 'has_shift_today',
        'shiftStartAt': 'shift_start_at',
        'shiftEndAt': 'shift_end_at',
      },
    );

Map<String, dynamic> _$AttendanceContextToJson(_AttendanceContext instance) =>
    <String, dynamic>{
      'ip_address': instance.ipAddress,
      'assigned_locations': instance.assignedLocations
          .map((e) => e.toJson())
          .toList(),
      'has_shift_today': instance.hasShiftToday,
      'shift_start_at': instance.shiftStartAt,
      'shift_end_at': instance.shiftEndAt,
      'user': instance.user.toJson(),
    };

_AttendanceLog _$AttendanceLogFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_AttendanceLog',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['attendance_location_id', 'source'],
          disallowNullValues: const ['source'],
        );
        final val = _AttendanceLog(
          id: $checkedConvert('id', (v) => v as String),
          checkedAt: $checkedConvert('checked_at', (v) => v as String),
          ipAddress: $checkedConvert('ip_address', (v) => v as String?),
          latitude: $checkedConvert('latitude', (v) => (v as num?)?.toDouble()),
          longitude: $checkedConvert(
            'longitude',
            (v) => (v as num?)?.toDouble(),
          ),
          location: $checkedConvert(
            'location',
            (v) => v == null
                ? null
                : AttendanceLogLocation.fromJson(v as Map<String, dynamic>),
          ),
          userId: $checkedConvert('user_id', (v) => v as String?),
          attendanceLocationId: $checkedConvert(
            'attendance_location_id',
            (v) => v as String?,
          ),
          source: $checkedConvert('source', (v) => v as String),
          createdAt: $checkedConvert('created_at', (v) => v as String?),
          updatedAt: $checkedConvert('updated_at', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'checkedAt': 'checked_at',
        'ipAddress': 'ip_address',
        'userId': 'user_id',
        'attendanceLocationId': 'attendance_location_id',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$AttendanceLogToJson(_AttendanceLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'checked_at': instance.checkedAt,
      'ip_address': instance.ipAddress,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'location': instance.location?.toJson(),
      'user_id': instance.userId,
      'attendance_location_id': instance.attendanceLocationId,
      'source': instance.source,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_AttendanceDayDetail _$AttendanceDayDetailFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_AttendanceDayDetail',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['first_check_in_at', 'last_check_out_at'],
    );
    final val = _AttendanceDayDetail(
      date: $checkedConvert('date', (v) => v as String),
      totalWorkSeconds: $checkedConvert(
        'total_work_seconds',
        (v) => (v as num).toInt(),
      ),
      logs: $checkedConvert(
        'logs',
        (v) => (v as List<dynamic>)
            .map((e) => AttendanceLog.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      firstCheckInAt: $checkedConvert('first_check_in_at', (v) => v as String?),
      lastCheckOutAt: $checkedConvert('last_check_out_at', (v) => v as String?),
      isLate: $checkedConvert('is_late', (v) => v as bool? ?? false),
      shiftStartAt: $checkedConvert('shift_start_at', (v) => v as String?),
      shiftEndAt: $checkedConvert('shift_end_at', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'totalWorkSeconds': 'total_work_seconds',
    'firstCheckInAt': 'first_check_in_at',
    'lastCheckOutAt': 'last_check_out_at',
    'isLate': 'is_late',
    'shiftStartAt': 'shift_start_at',
    'shiftEndAt': 'shift_end_at',
  },
);

Map<String, dynamic> _$AttendanceDayDetailToJson(
  _AttendanceDayDetail instance,
) => <String, dynamic>{
  'date': instance.date,
  'total_work_seconds': instance.totalWorkSeconds,
  'logs': instance.logs.map((e) => e.toJson()).toList(),
  'first_check_in_at': instance.firstCheckInAt,
  'last_check_out_at': instance.lastCheckOutAt,
  'is_late': instance.isLate,
  'shift_start_at': instance.shiftStartAt,
  'shift_end_at': instance.shiftEndAt,
};

_AttendanceRangeSummary _$AttendanceRangeSummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_AttendanceRangeSummary',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'on_leave',
        'first_check_in_at',
        'last_check_out_at',
      ],
      disallowNullValues: const ['on_leave'],
    );
    final val = _AttendanceRangeSummary(
      date: $checkedConvert('date', (v) => v as String),
      logsCount: $checkedConvert('logs_count', (v) => (v as num).toInt()),
      onLeave: $checkedConvert('on_leave', (v) => v as bool? ?? false),
      firstCheckInAt: $checkedConvert('first_check_in_at', (v) => v as String?),
      lastCheckOutAt: $checkedConvert('last_check_out_at', (v) => v as String?),
      totalWorkSeconds: $checkedConvert(
        'total_work_seconds',
        (v) => (v as num).toInt(),
      ),
      isLate: $checkedConvert('is_late', (v) => v as bool? ?? false),
      shiftStartAt: $checkedConvert('shift_start_at', (v) => v as String?),
      shiftEndAt: $checkedConvert('shift_end_at', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'logsCount': 'logs_count',
    'onLeave': 'on_leave',
    'firstCheckInAt': 'first_check_in_at',
    'lastCheckOutAt': 'last_check_out_at',
    'totalWorkSeconds': 'total_work_seconds',
    'isLate': 'is_late',
    'shiftStartAt': 'shift_start_at',
    'shiftEndAt': 'shift_end_at',
  },
);

Map<String, dynamic> _$AttendanceRangeSummaryToJson(
  _AttendanceRangeSummary instance,
) => <String, dynamic>{
  'date': instance.date,
  'logs_count': instance.logsCount,
  'on_leave': instance.onLeave,
  'first_check_in_at': instance.firstCheckInAt,
  'last_check_out_at': instance.lastCheckOutAt,
  'total_work_seconds': instance.totalWorkSeconds,
  'is_late': instance.isLate,
  'shift_start_at': instance.shiftStartAt,
  'shift_end_at': instance.shiftEndAt,
};

_AttendanceCoordinates _$AttendanceCoordinatesFromJson(
  Map<String, dynamic> json,
) => _AttendanceCoordinates(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$AttendanceCoordinatesToJson(
  _AttendanceCoordinates instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_AttendanceUserRef _$AttendanceUserRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AttendanceUserRef', json, ($checkedConvert) {
      final val = _AttendanceUserRef(
        id: $checkedConvert('id', (v) => v as Object),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AttendanceUserRefToJson(_AttendanceUserRef instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_AttendanceLogLocation _$AttendanceLogLocationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_AttendanceLogLocation',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['created_at', 'updated_at'],
      disallowNullValues: const ['created_at', 'updated_at'],
    );
    final val = _AttendanceLogLocation(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      latitude: $checkedConvert('latitude', (v) => (v as num).toDouble()),
      longitude: $checkedConvert('longitude', (v) => (v as num).toDouble()),
      radiusMeters: $checkedConvert(
        'radius_meters',
        (v) => (v as num).toDouble(),
      ),
      validationMode: $checkedConvert(
        'validation_mode',
        (v) => _validationModeFromJson(v),
      ),
      createdAt: $checkedConvert('created_at', (v) => v as String),
      updatedAt: $checkedConvert('updated_at', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'radiusMeters': 'radius_meters',
    'validationMode': 'validation_mode',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$AttendanceLogLocationToJson(
  _AttendanceLogLocation instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'radius_meters': instance.radiusMeters,
  'validation_mode': instance.validationMode,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

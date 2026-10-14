import 'package:dio/dio.dart';

const mockApiEnabled = bool.fromEnvironment('OBEE_MOCK_API');

final class MockApiInterceptor extends Interceptor {
  final List<Map<String, dynamic>> _attendanceLogs = [];
  late final List<Map<String, dynamic>> _schedules = [
    _schedule('schedule-1'),
    ..._demoSchedules(),
  ];
  late final List<Map<String, dynamic>> _requests = [
    _absenceRequest('request-1'),
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final response = _responseFor(options);
    if (identical(response, _notFound)) {
      handler.reject(
        DioException.badResponse(
          statusCode: 404,
          requestOptions: options,
          response: Response<Object?>(
            requestOptions: options,
            statusCode: 404,
            data: {'message': 'Mock route not found: ${options.path}'},
          ),
        ),
      );
      return;
    }

    handler.resolve(
      Response<Object?>(
        requestOptions: options,
        statusCode: 200,
        data: response,
        headers: Headers.fromMap({
          Headers.contentTypeHeader: [Headers.jsonContentType],
        }),
      ),
    );
  }

  Object? _responseFor(RequestOptions options) {
    final method = options.method.toUpperCase();
    final path = options.path;

    if (method == 'POST' && path == '/mobile/auth/login') {
      return {
        'access_token': 'obee-mobile-demo-token',
        'token_type': 'Bearer',
        'user': Map<String, dynamic>.from(_demoUser),
      };
    }
    if (method == 'GET' && path == '/mobile/auth/user') {
      return Map<String, dynamic>.from(_demoUser);
    }
    if (method == 'POST' && path == '/mobile/auth/logout') return null;

    if (method == 'GET' && path == '/attendance/context') {
      final now = DateTime.now();
      return {
        'ip_address': '203.0.113.10',
        'assigned_locations': [_location],
        'has_shift_today': true,
        'shift_start_at': DateTime(
          now.year,
          now.month,
          now.day,
          8,
        ).toIso8601String(),
        'shift_end_at': DateTime(
          now.year,
          now.month,
          now.day,
          17,
          30,
        ).toIso8601String(),
        'user': _attendanceUser,
      };
    }
    if (method == 'GET' && path == '/attendance/logs') {
      final date =
          options.queryParameters['date']?.toString() ?? _date(DateTime.now());
      final logs = date == _date(DateTime.now())
          ? _todayLogs()
          : <Map<String, dynamic>>[];
      return {
        'date': date,
        'total_work_seconds': logs.length > 1 ? 28_800 : 0,
        'logs': logs,
        'first_check_in_at': logs.isEmpty ? null : logs.first['checked_at'],
        'last_check_out_at': logs.length < 2 ? null : logs.last['checked_at'],
        'is_late': false,
        'shift_start_at': '${date}T08:00:00',
        'shift_end_at': '${date}T17:30:00',
      };
    }
    if (method == 'GET' && path == '/attendance/logs/range') {
      final now = DateTime.now();
      return List.generate(7, (index) {
        final day = now.subtract(Duration(days: index));
        final date = _date(day);
        return {
          'date': date,
          'logs_count': index == 0 ? _todayLogs().length : 2,
          'on_leave': false,
          'first_check_in_at': '${date}T08:03:00',
          'last_check_out_at': index == 0 ? null : '${date}T17:28:00',
          'total_work_seconds': index == 0 ? 0 : 28_800 - index * 240,
          'is_late': false,
          'shift_start_at': '${date}T08:00:00',
          'shift_end_at': '${date}T17:30:00',
        };
      });
    }
    if (method == 'POST' && path == '/attendance/logs') {
      final now = DateTime.now();
      final log = _attendanceLog(
        id: 'attendance-${_attendanceLogs.length + 1}',
        checkedAt: now,
      );
      _attendanceLogs.add(log);
      return log;
    }

    if (method == 'GET' && path == '/users/tree') return _treeUsers;
    if (method == 'PUT' && path == '/profile') {
      final data = options.data;
      if (data is Map) {
        for (final entry in data.entries) {
          if (entry.key == 'name' || entry.key == 'email') {
            _demoUser[entry.key.toString()] = entry.value;
          } else {
            final profile = Map<String, dynamic>.from(
              _demoUser['profile']! as Map,
            );
            profile[entry.key.toString()] = entry.value;
            _demoUser['profile'] = profile;
          }
        }
      }
      return Map<String, dynamic>.from(_demoUser);
    }

    if (method == 'GET' && path == '/schedules') {
      return _schedules.map(Map<String, dynamic>.from).toList(growable: false);
    }
    if (method == 'GET' && path.startsWith('/schedules/')) {
      final id = path.split('/').last;
      return Map<String, dynamic>.from(
        _schedules.firstWhere(
          (schedule) => schedule['id'] == id,
          orElse: () => _schedules.first,
        ),
      );
    }
    if (method == 'POST' && path == '/schedule-events') {
      _schedules.add(
        _schedule('schedule-${_schedules.length + 1}', options.data),
      );
      return null;
    }
    if (method == 'PUT' && path.startsWith('/schedule-events/')) return null;
    if (method == 'DELETE' && path.startsWith('/schedule-events/')) return null;
    if (method == 'POST' && path.endsWith('/join')) return null;
    if (method == 'POST' && path.endsWith('/leave')) return null;

    if (method == 'GET' && path == '/work-user-shifts/mine') {
      return _workShifts;
    }
    if (method == 'GET' && path == '/absence-requests/leave-balance') {
      return {
        'entitlement': 12.0,
        'used': 2.0,
        'remaining': 10.0,
        'cycle_start': '${DateTime.now().year}-01-01',
        'cycle_end': '${DateTime.now().year}-12-31',
      };
    }
    if (method == 'GET' && path == '/absence-requests/preview-coverage') {
      return {
        'total_days': 1.0,
        'working_days': 1.0,
        'holiday_days': 0,
        'off_days': 0,
        'items': [
          {
            'date': _date(DateTime.now().add(const Duration(days: 1))),
            'status': 'working_day',
            'work_shift_id': 'shift-1',
            'hours': 8.0,
            'days': 1.0,
            'note': 'Ngày làm việc',
          },
        ],
      };
    }
    if (method == 'GET' && path == '/absence-requests') {
      return _requests.map(Map<String, dynamic>.from).toList(growable: false);
    }
    if (method == 'POST' && path == '/absence-requests') {
      final request = _absenceRequest(
        'request-${_requests.length + 1}',
        options.data,
      );
      _requests.add(request);
      return request;
    }
    if (method == 'GET' && path.startsWith('/absence-requests/')) {
      final id = path.split('/').last;
      return Map<String, dynamic>.from(
        _requests.firstWhere(
          (request) => request['id'] == id,
          orElse: () => _requests.first,
        ),
      );
    }
    if (method == 'PUT' && path.startsWith('/absence-requests/')) {
      return Map<String, dynamic>.from(_requests.first);
    }
    if (method == 'POST' && path.startsWith('/absence-requests/')) return null;
    if (method == 'DELETE' && path.startsWith('/absence-requests/')) {
      return null;
    }

    return _notFound;
  }

  List<Map<String, dynamic>> _todayLogs() {
    if (_attendanceLogs.isNotEmpty) return _attendanceLogs;
    final now = DateTime.now();
    return [
      _attendanceLog(
        id: 'attendance-in',
        checkedAt: DateTime(now.year, now.month, now.day, 8, 3),
      ),
    ];
  }
}

const _notFound = Object();
const _timestamp = '2026-01-01T00:00:00.000Z';

final _organization = <String, dynamic>{
  'id': 'organization-1',
  'name': 'Công ty Obee',
  'type': 'company',
  'parent_id': null,
  'tax_identification_number': '0312345678',
  'created_at': _timestamp,
  'updated_at': _timestamp,
  'parent': null,
};

final _demoUser = <String, dynamic>{
  'id': 'user-1',
  'name': 'Nguyễn Minh Anh',
  'username': 'minhanh',
  'email': 'demo@obee.vn',
  'avatar': null,
  'organization_id': 'organization-1',
  'organization': _organization,
  'root_organization_id': 'organization-1',
  'profile': {
    'phone_number': '0901234567',
    'birthday': '1995-08-18',
    'address': 'Thành phố Hồ Chí Minh',
    'sex': 'male',
    'code': 'OB001',
    'position_id': 'position-1',
    'position': {
      'id': 'position-1',
      'name': 'Product Designer',
      'description': 'Thiết kế sản phẩm',
      'created_at': _timestamp,
      'updated_at': _timestamp,
    },
    'joined_at': '2024-01-15',
    'starting_date': '2024-01-15',
    'education_level': 'university',
    'employee_type': 'full_time',
    'citizen_identification_card': null,
    'social_insurance_number': null,
    'health_insurance_card_number': null,
    'personal_tax_identification_number': null,
    'dependent_tax_identification_number': null,
    'bank_account_number': null,
    'age': 31.0,
    'seniority': 2.0,
    'created_at': _timestamp,
    'updated_at': _timestamp,
  },
  'roles': [
    {
      'id': 'role-1',
      'name': 'employee',
      'description': 'Nhân viên',
      'created_at': _timestamp,
      'updated_at': _timestamp,
    },
  ],
  'email_verified_at': _timestamp,
  'supabase_id': null,
  'created_at': _timestamp,
  'updated_at': _timestamp,
  'permissions': [
    _permission('permission-1', 'absence-requests.review'),
    _permission('permission-2', 'schedule-events.create'),
    _permission('permission-3', 'schedule-events.update'),
  ],
};

Map<String, dynamic> _permission(String id, String name) => {
  'id': id,
  'name': name,
  'description': null,
  'created_at': _timestamp,
  'updated_at': _timestamp,
};

const _attendanceUser = {'id': 'user-1', 'name': 'Nguyễn Minh Anh'};

final _location = <String, dynamic>{
  'id': 'location-1',
  'name': 'Văn phòng Obee',
  'latitude': 10.7769,
  'longitude': 106.7009,
  'radius_meters': 250.0,
  'validation_mode': 'either',
  'ips': [
    {
      'id': 'ip-1',
      'ip_address': '203.0.113.10',
      'attendance_location_id': 'location-1',
      'created_at': _timestamp,
      'updated_at': _timestamp,
    },
  ],
  'created_at': _timestamp,
  'updated_at': _timestamp,
  'users': [_attendanceUser],
  'organizations': [_organization],
  'excluded_users': <Map<String, dynamic>>[],
};

Map<String, dynamic> _attendanceLog({
  required String id,
  required DateTime checkedAt,
}) => {
  'id': id,
  'checked_at': checkedAt.toIso8601String(),
  'ip_address': '203.0.113.10',
  'latitude': 10.7769,
  'longitude': 106.7009,
  'location': {
    'id': _location['id'],
    'name': _location['name'],
    'latitude': _location['latitude'],
    'longitude': _location['longitude'],
    'radius_meters': _location['radius_meters'],
    'validation_mode': _location['validation_mode'],
    'created_at': _timestamp,
    'updated_at': _timestamp,
  },
  'user_id': 'user-1',
  'attendance_location_id': 'location-1',
  'source': 'mobile',
  'created_at': checkedAt.toIso8601String(),
  'updated_at': checkedAt.toIso8601String(),
};

final _treeUsers = <Map<String, dynamic>>[
  _treeUser('user-1', 'Nguyễn Minh Anh', 'minhanh', 'OB001'),
  _treeUser('user-2', 'Trần Thu Hà', 'thuha', 'OB002'),
  _treeUser('user-3', 'Lê Quốc Huy', 'quochuy', 'OB003'),
];

Map<String, dynamic> _treeUser(
  String id,
  String name,
  String username,
  String code,
) => {
  'id': id,
  'name': name,
  'username': username,
  'organization_id': 'organization-1',
  'organization': Map<String, dynamic>.from(_organization),
  'profile': {'code': code},
};

Map<String, dynamic> _schedule(
  String id, [
  Object? draft,
  DateTime? seedStart,
  Duration seedDuration = const Duration(hours: 1, minutes: 30),
]) {
  final now = DateTime.now();
  final data = draft is Map
      ? Map<String, dynamic>.from(draft)
      : <String, dynamic>{};
  // Created drafts keep their chosen date and time so they land in the grid.
  final draftStart = _draftDateTime(data['start_date'], data['start_time']);
  final draftEnd = _draftDateTime(data['end_date'], data['end_time']);
  final start =
      draftStart ?? seedStart ?? DateTime(now.year, now.month, now.day, 9);
  final end = draftEnd != null && draftEnd.isAfter(start)
      ? draftEnd
      : start.add(seedDuration);
  final eventId = 'event-${id.split('-').last}';
  final isMultipleDays = data['schedule_type'] == 'multiple_days';
  final startDate = data['start_date']?.toString() ?? _date(start);
  final endDate = data['end_date']?.toString() ?? _date(end);
  return {
    'id': id,
    'event_id': eventId,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'one_day': _date(start) == _date(end),
    'remind_at': start.subtract(const Duration(minutes: 15)).toIso8601String(),
    'event': {
      'id': eventId,
      'title': data['title'] ?? 'Họp kế hoạch sản phẩm Obee',
      'type': data['type'] ?? 'meeting',
      'schedule_type': data['schedule_type'] ?? 'ordinary',
      'start_date': startDate,
      'end_date': endDate,
      'repeat_type': data['repeat_type'],
      'repeat_pattern': data['repeat_pattern'],
      // The schedule contract requires null clock times for multi-day events.
      'start_time': isMultipleDays ? null : data['start_time'] ?? _time(start),
      'end_time': isMultipleDays ? null : data['end_time'] ?? _time(end),
      'note': data['note'] ?? 'Trao đổi tiến độ và kế hoạch tuần mới.',
      'physical_address': data['physical_address'] ?? 'Phòng họp Obee',
      'privacy': data['privacy'] ?? 'public',
      'is_general': data['is_general'] ?? false,
      'remind_range': data['remind_range'] ?? 'minute',
      'remind_value': data['remind_value'] ?? 15,
      'created_by': 'user-1',
      'updated_by': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'participants': [
        _scheduleUser(_treeUsers[0]),
        _scheduleUser(_treeUsers[1]),
      ],
      'observers': [_scheduleUser(_treeUsers[2])],
    },
  };
}

Map<String, dynamic> _scheduleUser(Map<String, dynamic> user) => {
  'id': user['id'],
  'name': user['name'],
  'avatar': null,
  'email': '${user['username']}@obee.vn',
};

Map<String, dynamic> _absenceRequest(String id, [Object? draft]) {
  final data = draft is Map
      ? Map<String, dynamic>.from(draft)
      : <String, dynamic>{};
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  return {
    'id': id,
    'code': 'YC-2026-001',
    'root_organization_id': 'organization-1',
    'user_id': 'user-1',
    'leave_type': data['leave_type'] ?? 'annual_leave',
    'start_at': data['start_at'] ?? '${_date(tomorrow)}T08:00:00',
    'end_at': data['end_at'] ?? '${_date(tomorrow)}T17:30:00',
    'reason': data['reason'] ?? 'Nghỉ phép cá nhân',
    'address': data['address'],
    'status': data['status'] ?? 'pending',
    'duration_days': 1.0,
    'reviewer_id': data['reviewer_id'] ?? 'user-2',
    'user': _requestUser(_treeUsers[0]),
    'requester': _requestUser(_treeUsers[0]),
    'reviewer': _requestUser(_treeUsers[1]),
    'created_at': DateTime.now().toIso8601String(),
    'approved_at': null,
    'rejected_at': null,
    'approval_note': null,
  };
}

Map<String, dynamic> _requestUser(Map<String, dynamic> user) => {
  'id': user['id'],
  'name': user['name'],
  'username': user['username'],
  'email': '${user['username']}@obee.vn',
  'avatar': null,
};

final _workShifts = <Map<String, dynamic>>[
  {
    'id': 'assignment-1',
    'root_organization_id': 'organization-1',
    'user_id': 'user-1',
    'work_shift_id': 'shift-1',
    'work_date': _date(DateTime.now().add(const Duration(days: 1))),
    'start_at':
        '${_date(DateTime.now().add(const Duration(days: 1)))}T08:00:00',
    'end_at': '${_date(DateTime.now().add(const Duration(days: 1)))}T17:30:00',
    'work_shift': {
      'id': 'shift-1',
      'root_organization_id': 'organization-1',
      'name': 'Ca hành chính',
      'periods': [
        {
          'id': 'period-1',
          'work_shift_id': 'shift-1',
          'start_time': '08:00',
          'end_time': '17:30',
          'start_day_offset': 0,
          'end_day_offset': 0,
        },
      ],
    },
    'work_periods': [
      {
        'start_at':
            '${_date(DateTime.now().add(const Duration(days: 1)))}T08:00:00',
        'end_at':
            '${_date(DateTime.now().add(const Duration(days: 1)))}T17:30:00',
      },
    ],
  },
];

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

DateTime? _draftDateTime(Object? date, Object? time) {
  if (date is! String || date.length < 10) {
    return null;
  }
  final clock = time is String && time.length >= 5 ? time : '00:00';
  return DateTime.tryParse('${date.substring(0, 10)}T${clock.substring(0, 5)}');
}

String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

/// Extra demo occurrences around today so every calendar view has content:
/// overlapping meetings, a multi-day seminar and events in other months.
List<Map<String, dynamic>> _demoSchedules() {
  final now = DateTime.now();
  DateTime at(int dayOffset, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + dayOffset, hour, minute);

  Map<String, dynamic> seed(
    String id,
    DateTime start,
    Duration duration, {
    required String title,
    required String type,
    String scheduleType = 'ordinary',
    String? address,
  }) {
    final end = start.add(duration);
    return _schedule(
      id,
      {
        'title': title,
        'type': type,
        'schedule_type': scheduleType,
        'start_date': _date(start),
        'end_date': _date(end),
        if (scheduleType != 'multiple_days') 'start_time': _time(start),
        if (scheduleType != 'multiple_days') 'end_time': _time(end),
        'physical_address': ?address,
      },
      start,
      duration,
    );
  }

  return [
    seed(
      'schedule-2',
      at(0, 10),
      const Duration(hours: 1),
      title: 'Phỏng vấn ứng viên Flutter',
      type: 'interview',
      address: 'Online - Google Meet',
    ),
    seed(
      'schedule-3',
      at(0, 14),
      const Duration(hours: 2),
      title: 'Đào tạo quy trình chấm công',
      type: 'training',
      address: 'Phòng đào tạo',
    ),
    seed(
      'schedule-4',
      at(1, 8, 30),
      const Duration(hours: 1),
      title: 'Daily standup',
      type: 'meeting',
    ),
    seed(
      'schedule-5',
      at(2, 0),
      const Duration(hours: 47),
      title: 'Hội thảo chuyển đổi số',
      type: 'seminar',
      scheduleType: 'multiple_days',
      address: 'Trung tâm hội nghị',
    ),
    seed(
      'schedule-6',
      at(-2, 15),
      const Duration(hours: 1, minutes: 30),
      title: 'Gặp gỡ đối tác',
      type: 'meetup',
      address: 'Café The Coffee House',
    ),
    seed(
      'schedule-7',
      at(-1, 9),
      const Duration(hours: 8),
      title: 'Công tác Đà Nẵng',
      type: 'business_trip',
    ),
    seed(
      'schedule-8',
      at(16, 0),
      const Duration(hours: 23),
      title: 'Nghỉ lễ',
      type: 'holiday',
      scheduleType: 'multiple_days',
    ),
    seed(
      'schedule-9',
      at(35, 9),
      const Duration(hours: 1),
      title: 'Review quý',
      type: 'meeting',
    ),
  ];
}

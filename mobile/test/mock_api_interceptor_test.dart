import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/network/mock_api_interceptor.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://mock.obee.local/api'));
    dio.interceptors.add(MockApiInterceptor());
  });

  test('returns the exact mobile auth contract', () async {
    final response = await dio.post<Map<String, dynamic>>(
      '/mobile/auth/login',
      data: {'email': 'demo@obee.vn', 'password': 'demo123'},
    );

    final result = LoginResult.fromJson(response.data!);
    expect(result.accessToken, 'obee-mobile-demo-token');
    expect(result.user.name, 'Nguyễn Minh Anh');
  });

  test('returns attendance and schedule contracts', () async {
    final attendance = await dio.get<Map<String, dynamic>>(
      '/attendance/context',
    );
    final context = AttendanceContext.fromJson(attendance.data!);
    expect(context.assignedLocations.single.name, 'Văn phòng Obee');

    final schedules = await dio.get<List<dynamic>>('/schedules');
    final schedule = ScheduleModel.fromJson(
      schedules.data!.first as Map<String, dynamic>,
    );
    expect(schedule.event.title, 'Họp kế hoạch sản phẩm Obee');

    // Demo occurrences give the week, month and year views content.
    final all = schedules.data!
        .cast<Map<String, dynamic>>()
        .map(ScheduleModel.fromJson)
        .toList();
    expect(all.length, greaterThan(5));
    expect(
      all.map((item) => item.event.scheduleType),
      contains(ScheduleEventScheduleType.multipleDays),
    );
    expect(all.every((item) => !item.end.isBefore(item.start)), isTrue);
  });
}

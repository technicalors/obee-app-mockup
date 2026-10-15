import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/network/mock_api_interceptor.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/tasks/data/task_models.dart';

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

  test('serves Google Tasks style lists and tasks', () async {
    final lists = await dio.get<List<dynamic>>('/task-lists');
    final parsedLists = lists.data!
        .cast<Map<String, dynamic>>()
        .map(TaskListModel.fromJson)
        .toList();
    expect(parsedLists.where((list) => list.isDefault), hasLength(1));

    final tasks = await dio.get<List<dynamic>>('/tasks');
    final parsed = tasks.data!
        .cast<Map<String, dynamic>>()
        .map(TaskModel.fromJson)
        .toList();
    expect(parsed.any((task) => task.isSubtask), isTrue);
    expect(parsed.any((task) => task.completed), isTrue);
    expect(parsed.any((task) => task.starred), isTrue);

    final created = TaskModel.fromJson(
      (await dio.post<Map<String, dynamic>>(
        '/tasks',
        data: const TaskDraft(
          listId: 'list-default',
          title: 'New task',
          starred: true,
        ).toRequestJson(),
      )).data!,
    );
    expect(created.starredAt, isNotNull);
    // New top-level tasks go first in their list.
    final minPosition = parsed
        .where((task) => task.listId == 'list-default' && !task.isSubtask)
        .map((task) => task.position)
        .reduce((a, b) => a < b ? a : b);
    expect(created.position, lessThan(minPosition));

    final completed = TaskModel.fromJson(
      (await dio.patch<Map<String, dynamic>>(
        '/tasks/${created.id}',
        data: {'completed': true},
      )).data!,
    );
    expect(completed.completed, isTrue);
    expect(completed.completedAt, isNotNull);

    await dio.delete<void>('/tasks/task-2');
    final remaining = (await dio.get<List<dynamic>>(
      '/tasks',
    )).data!.cast<Map<String, dynamic>>().map(TaskModel.fromJson);
    // Deleting a parent removes its subtasks too.
    expect(
      remaining.where(
        (task) => task.id == 'task-2' || task.parentId == 'task-2',
      ),
      isEmpty,
    );
  });
}

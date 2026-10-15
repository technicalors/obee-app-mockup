import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/shell/ui/app_shell.dart';
import 'package:obee_mobile/src/features/tasks/data/task_api.dart';
import 'package:obee_mobile/src/features/tasks/ui/task_detail_page.dart';
import 'package:obee_mobile/src/features/tasks/ui/tasks_page.dart';

import 'support/fake_task_api.dart';

void main() {
  FakeTaskApi seededApi() => FakeTaskApi(
    tasks: [
      fakeTask(
        'report',
        'Gửi báo cáo tuần',
        dueDate: '2026-06-10',
        notes: 'Tổng hợp số liệu',
        position: 0,
      ),
      fakeTask('plan', 'Chuẩn bị họp', dueDate: '2026-06-08', position: 1),
      fakeTask('slides', 'Làm slide', parentId: 'plan', position: 0),
      fakeTask('room', 'Đặt phòng họp', position: 2),
      fakeTask('done', 'Đăng ký đào tạo', completed: true),
      fakeTask(
        'design',
        'Review thiết kế',
        listId: 'list-project',
        starred: true,
      ),
    ],
  );

  testWidgets('shows lists, nested subtasks, due chips and completed count', (
    tester,
  ) async {
    await _pumpTasks(tester, api: seededApi());

    expect(find.text('Công việc'), findsWidgets);
    expect(
      find.byKey(const ValueKey('task-list-tab-list-default')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('task-list-tab-new')), findsOneWidget);
    expect(find.text('Gửi báo cáo tuần'), findsOneWidget);
    expect(find.text('Tổng hợp số liệu'), findsOneWidget);
    expect(find.text('Hôm nay'), findsOneWidget);
    // Subtask is indented under its parent.
    final parent = tester.getTopLeft(find.text('Chuẩn bị họp'));
    final child = tester.getTopLeft(find.text('Làm slide'));
    expect(child.dx, greaterThan(parent.dx));
    expect(find.text('Đã hoàn thành (1)'), findsOneWidget);
    expect(find.text('Đăng ký đào tạo'), findsNothing);
    // Other lists' tasks stay hidden.
    expect(find.text('Review thiết kế'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('tasks-completed-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Đăng ký đào tạo'), findsOneWidget);
  });

  testWidgets('adds a task with details and star from the sheet', (
    tester,
  ) async {
    final api = seededApi();
    await _pumpTasks(tester, api: api);

    await tester.tap(find.byKey(const ValueKey('tasks-add-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('tasks-new-title')),
      'Gọi khách hàng',
    );
    await tester.tap(find.byKey(const ValueKey('tasks-new-notes-toggle')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('tasks-new-notes')),
      'Xác nhận lịch demo',
    );
    await tester.tap(find.byKey(const ValueKey('tasks-new-star')));
    await tester.tap(find.byKey(const ValueKey('tasks-new-save')));
    await tester.pumpAndSettle();

    expect(find.text('Gọi khách hàng'), findsOneWidget);
    expect(api.tasks.last.notes, 'Xác nhận lịch demo');
    expect(api.tasks.last.starred, isTrue);
    expect(api.tasks.last.listId, 'list-default');
  });

  testWidgets('checking a task moves it to the completed section', (
    tester,
  ) async {
    await _pumpTasks(tester, api: seededApi());

    await tester.tap(find.byKey(const ValueKey('task-check-room')));
    await tester.pumpAndSettle();

    expect(find.text('Đặt phòng họp'), findsNothing);
    expect(find.text('Đã hoàn thành (2)'), findsOneWidget);
  });

  testWidgets('starred tab lists starred tasks from every list', (
    tester,
  ) async {
    await _pumpTasks(tester, api: seededApi());

    await tester.tap(find.byKey(const ValueKey('task-star-room')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-list-tab-starred')));
    await tester.pumpAndSettle();

    expect(find.text('Có gắn dấu sao'), findsOneWidget);
    expect(find.text('Đặt phòng họp'), findsOneWidget);
    expect(find.text('Review thiết kế'), findsOneWidget);
    expect(find.text('Gửi báo cáo tuần'), findsNothing);
  });

  testWidgets('date sort groups tasks under due headers', (tester) async {
    await _pumpTasks(tester, api: seededApi());

    await tester.tap(find.byKey(const ValueKey('tasks-sort-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-sort-date')));
    await tester.pumpAndSettle();

    expect(find.text('Quá hạn'), findsOneWidget);
    expect(find.text('Không có ngày'), findsOneWidget);
    // "Hôm nay" is both a section header and the task's due chip.
    expect(find.text('Hôm nay'), findsNWidgets(2));
  });

  testWidgets('creates a new list and switches to it', (tester) async {
    final api = seededApi();
    await _pumpTasks(tester, api: api);

    // "Danh sách mới" is pinned, so it is tappable without scrolling.
    await tester.tap(find.byKey(const ValueKey('task-list-tab-new')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-list-name-field')),
      'Cá nhân',
    );
    await tester.tap(find.byKey(const ValueKey('task-list-name-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('tasks-list-title')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('tasks-list-title'))).data,
      'Cá nhân',
    );
    expect(find.text('Chưa có việc nào'), findsOneWidget);
  });

  testWidgets('detail page edits, adds a subtask and completes the task', (
    tester,
  ) async {
    final api = seededApi();
    await _pumpTasks(tester, api: api);

    await tester.tap(find.text('Đặt phòng họp'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailPage), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('task-detail-title')),
      'Đặt phòng họp tầng 5',
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      api.tasks.firstWhere((t) => t.id == 'room').title,
      'Đặt phòng họp tầng 5',
    );

    await tester.tap(find.byKey(const ValueKey('task-detail-add-subtask')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-detail-subtask-input')),
      'Gửi email xác nhận',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Gửi email xác nhận'), findsOneWidget);
    expect(api.tasks.last.parentId, 'room');

    await tester.tap(find.byKey(const ValueKey('task-detail-complete')));
    await tester.pumpAndSettle();

    // Completing returns to the list; parent and subtask are both done.
    expect(find.byType(TaskDetailPage), findsNothing);
    expect(find.text('Đã hoàn thành (3)'), findsOneWidget);
  });

  testWidgets('detail delete removes the task and returns', (tester) async {
    final api = seededApi();
    await _pumpTasks(tester, api: api);

    await tester.tap(find.text('Chuẩn bị họp'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-detail-delete')));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailPage), findsNothing);
    expect(find.text('Chuẩn bị họp'), findsNothing);
    expect(find.text('Làm slide'), findsNothing);
    expect(api.deletedTaskIds, ['plan']);
  });

  testWidgets('fits a narrow phone with the new-list button visible', (
    tester,
  ) async {
    await _pumpTasks(tester, api: seededApi(), size: const Size(320, 640));
    expect(tester.takeException(), isNull);

    final button = tester.getRect(
      find.byKey(const ValueKey('task-list-tab-new')),
    );
    expect(button.right, lessThanOrEqualTo(320));
    expect(button.left, greaterThanOrEqualTo(0));
  });

  testWidgets('shell shows the Công việc tab before Hồ sơ when enabled', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(
      initialLocation: '/app/tasks',
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              AppShell(showTasks: true, child: child),
          routes: [
            for (final path in [
              '/app/attendance',
              '/app/requests',
              '/app/schedule',
              '/app/tasks',
              '/app/profile',
            ])
              GoRoute(
                path: path,
                builder: (context, state) => Text('page $path'),
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    final labels = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .map((destination) => destination.label)
        .toList();
    expect(labels, [
      'Chấm công',
      'Yêu cầu',
      'Lịch trình',
      'Công việc',
      'Hồ sơ',
    ]);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 3);
  });
}

Future<void> _pumpTasks(
  WidgetTester tester, {
  required FakeTaskApi api,
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    initialLocation: TasksPage.routePath,
    routes: [
      GoRoute(
        path: TasksPage.routePath,
        builder: (context, state) => TasksPage(now: DateTime(2026, 6, 10)),
      ),
      GoRoute(
        path: '/app/tasks/:id',
        builder: (context, state) =>
            TaskDetailPage(taskId: state.pathParameters['id']!),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [taskApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

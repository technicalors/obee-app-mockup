import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/auth/ui/auth_session_listener.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_api.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_page.dart';
import 'schedule_page_test.dart' show FakeScheduleApi;
import 'auth_controller_test.dart'
    show FakeAuthApi, MemoryTokenStorage, createSchedulePermission;

void main() {
  testWidgets(
    'foreground and calendar refresh update capabilities on the same token',
    (tester) async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage('saved-token');
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authApiProvider.overrideWithValue(api),
            tokenStorageProvider.overrideWithValue(storage),
            scheduleApiProvider.overrideWithValue(FakeScheduleApi()),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: AuthSessionListener(
              child: SchedulePage(now: DateTime(2026, 10, 3)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('schedule-create-fab')), findsNothing);

      api.user = api.user.copyWith(permissions: [createSchedulePermission]);
      resumeFromBackground(tester);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('schedule-create-fab')), findsOneWidget);
      expect(storage.token, 'saved-token');

      api.user = api.user.copyWith(permissions: []);
      resumeFromBackground(tester);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('schedule-create-fab')), findsNothing);
      expect(storage.token, 'saved-token');

      api.user = api.user.copyWith(permissions: [createSchedulePermission]);
      await tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('schedule-create-fab')), findsOneWidget);
      expect(storage.token, 'saved-token');

      await tester.pumpWidget(const SizedBox.shrink());
      final previousCalls = api.currentUserCalls;
      resumeFromBackground(tester);
      await tester.pump();
      expect(api.currentUserCalls, previousCalls);
    },
  );

  testWidgets('failed foreground refresh reports error and keeps the session', (
    tester,
  ) async {
    final api = FakeAuthApi();
    final storage = MemoryTokenStorage('saved-token');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authApiProvider.overrideWithValue(api),
          tokenStorageProvider.overrideWithValue(storage),
        ],
        child: const MaterialApp(
          home: AuthSessionListener(child: Scaffold(body: Text('Obee'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    api.restoreError = DioException(
      requestOptions: RequestOptions(path: '/mobile/auth/user'),
    );
    resumeFromBackground(tester);
    await tester.pumpAndSettle();
    expect(
      find.text('Không thể kết nối máy chủ. Kiểm tra mạng và thử lại.'),
      findsOneWidget,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AuthSessionListener)),
      listen: false,
    );
    expect(container.read(authControllerProvider).isAuthenticated, true);
    expect(storage.token, 'saved-token');
  });
}

void resumeFromBackground(WidgetTester tester) {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

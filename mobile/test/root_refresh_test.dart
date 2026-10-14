import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/core/location/device_location_service.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_api.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_formatters.dart';
import 'package:obee_mobile/src/features/attendance/state/attendance_controller.dart';
import 'package:obee_mobile/src/features/attendance/ui/attendance_page.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/auth/ui/auth_session_listener.dart';
import 'package:obee_mobile/src/features/chat/data/chat_conversation.dart';
import 'package:obee_mobile/src/features/chat/data/chat_coworker.dart';
import 'package:obee_mobile/src/features/chat/data/chat_group_info.dart';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';
import 'package:obee_mobile/src/features/chat/data/chat_thread.dart';
import 'package:obee_mobile/src/features/chat/state/chat_hub_provider.dart';
import 'package:obee_mobile/src/features/chat/state/direct_chat_search_provider.dart';
import 'package:obee_mobile/src/features/chat/ui/chat_hub_page.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_page.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_api.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_controller.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_page.dart';
import 'package:obee_mobile/src/features/shell/ui/app_shell.dart';

import 'auth_controller_test.dart' show FakeAuthApi, MemoryTokenStorage;
import 'schedule_page_test.dart' show FakeScheduleApi;

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
  });

  for (final page in <String, Widget>{
    'profile': const ProfilePage(),
    'leave': const PlaceholderFeaturePage(
      icon: AppShellIcon.leave,
      title: 'Nghỉ phép',
    ),
    'notifications': const PlaceholderFeaturePage(
      icon: AppShellIcon.notifications,
      title: 'Thông báo',
    ),
  }.entries) {
    testWidgets('${page.key} pull refresh fetches the authenticated user', (
      tester,
    ) async {
      final auth = FakeAuthApi();
      await _pumpRoot(tester, page.value, auth: auth);
      final calls = auth.currentUserCalls;
      auth.user = auth.user.copyWith(name: 'Tên vừa cập nhật');
      await _pull(
        tester,
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
      );
      expect(auth.currentUserCalls, calls + 1);
      if (page.key == 'profile') {
        expect(find.text('Tên vừa cập nhật'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final selectedDay in [false, true]) {
    testWidgets(
      'schedule ${selectedDay ? 'empty day' : 'month'} pull refresh reloads API data and preserves selection',
      (tester) async {
        final auth = FakeAuthApi();
        final api = FakeScheduleApi();
        final date = DateTime(2026, 10, 3);
        final container = await _pumpRoot(
          tester,
          SchedulePage(
            now: date,
            initialSelectedDate: selectedDay ? date : null,
          ),
          auth: auth,
          schedules: api,
        );
        final authCalls = auth.currentUserCalls;
        final scheduleCalls = api.fetchSchedulesCallCount;
        final oldState = container.read(scheduleControllerProvider);
        await _pull(
          tester,
          find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    widget.axisDirection == AxisDirection.down,
              )
              .first,
        );
        expect(api.fetchSchedulesCallCount, scheduleCalls + 1);
        expect(auth.currentUserCalls, authCalls + 1);
        final state = container.read(scheduleControllerProvider);
        expect(state.month, oldState.month);
        expect(state.visibility, oldState.visibility);
        expect(state.selectedUserId, oldState.selectedUserId);
        if (selectedDay) {
          expect(
            find.text('Không có lịch trình cho ngày đã chọn.'),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'attendance refresh reloads context, location, month and selected history day',
    (tester) async {
      final auth = FakeAuthApi();
      final api = _AttendanceApi();
      final location = _LocationPlatform();
      final container = await _pumpRoot(
        tester,
        const AttendancePage(),
        auth: auth,
        attendance: api,
        location: location,
      );
      final authCalls = auth.currentUserCalls;
      final contextCalls = api.contextCalls;
      final rangeCalls = api.rangeCalls;
      final locationCalls = location.calls;
      await _pull(
        tester,
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
      );
      expect(auth.currentUserCalls, authCalls + 1);
      expect(api.contextCalls, contextCalls + 1);
      expect(api.rangeCalls, rangeCalls + 1);
      expect(location.calls, locationCalls + 1);
      final controller = container.read(attendanceControllerProvider.notifier);
      await controller.shiftCalendarMonth(-1);
      final selectedDate = container
          .read(attendanceControllerProvider)
          .selectedDate;
      final month = container
          .read(attendanceControllerProvider)
          .calendarMonthStart;
      final detailCalls = api.dates.length;
      api.workSeconds = 7200;
      await tester.tap(find.text('Lịch sử'));
      await tester.pumpAndSettle();
      await _pull(
        tester,
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
      );
      expect(api.dates.skip(detailCalls), [
        container.read(attendanceControllerProvider).today,
        selectedDate,
      ]);
      final state = container.read(attendanceControllerProvider);
      expect(state.calendarMonthStart, month);
      expect(state.selectedDate, selectedDate);
      expect(state.selectedDayDetail!.totalWorkSeconds, 7200);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'attendance data loads alongside user refresh and refresh finishes without waiting for GPS',
    () async {
      final auth = FakeAuthApi();
      final api = _AttendanceApi();
      final location = _LocationPlatform();
      final container = ProviderContainer(
        overrides: [
          authApiProvider.overrideWithValue(auth),
          tokenStorageProvider.overrideWithValue(
            MemoryTokenStorage('saved-token'),
          ),
          attendanceApiProvider.overrideWithValue(api),
          deviceLocationServiceProvider.overrideWithValue(
            DeviceLocationService(platform: location),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.notifier).retryRestore();
      final controller = container.read(attendanceControllerProvider.notifier);
      await controller.bootstrap();
      final pendingLocation = Completer<bool>();
      final pendingUser = Completer<User>();
      location.pending = pendingLocation;
      auth.pendingUser = pendingUser;
      final contextCalls = api.contextCalls;
      final rangeCalls = api.rangeCalls;
      final refreshed = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(api.contextCalls, contextCalls + 1);
      expect(api.rangeCalls, rangeCalls + 1);
      expect(
        container.read(attendanceControllerProvider).loadingContext,
        false,
      );
      expect(
        container.read(attendanceControllerProvider).positionState,
        PositionState.loading,
      );
      pendingUser.complete(auth.user);
      await refreshed;
      expect(pendingLocation.isCompleted, false);
      expect(
        container.read(attendanceControllerProvider).positionState,
        PositionState.loading,
      );
      pendingLocation.complete(false);
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(attendanceControllerProvider).positionState,
        PositionState.failed,
      );
    },
  );

  for (final tab in ChatHubTab.values) {
    testWidgets(
      'chat ${tab.name} refresh works from empty lists and reloads both tabs',
      (tester) async {
        final repository = _ChatRepository();
        final container = await _pumpRoot(
          tester,
          const ChatHubPage(),
          auth: FakeAuthApi(),
          chat: repository,
        );
        container.read(chatHubProvider.notifier).selectTab(tab);
        await tester.pumpAndSettle();
        final generalCalls = repository.generalCalls;
        final directCalls = repository.directCalls;
        repository.hasData = true;
        await _pull(
          tester,
          find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    widget.axisDirection == AxisDirection.down,
              )
              .first,
        );
        expect(repository.generalCalls, generalCalls + 1);
        expect(repository.directCalls, directCalls + 1);
        expect(container.read(chatHubProvider).selectedTab, tab);
        expect(
          find.text(tab == ChatHubTab.general ? 'Kênh mới' : 'Nhóm mới'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'chat refresh waits for responses, surfaces failure and allows retry',
    (tester) async {
      final repository = _ChatRepository()..hasData = true;
      final container = await _pumpRoot(
        tester,
        const ChatHubPage(),
        auth: FakeAuthApi(),
        chat: repository,
      );
      container.read(directChatSearchProvider.notifier).updateQuery('Nhóm');
      final pending = Completer<List<ChatConversation>>();
      repository.pendingGeneral = pending;
      await tester.drag(
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
        const Offset(0, 500),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 200));
      expect(repository.generalCalls, 2);
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);
      pending.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(
        find.text('Không thể tải lại danh sách trò chuyện.'),
        findsOneWidget,
      );
      expect(find.byType(RefreshProgressIndicator), findsNothing);
      expect(container.read(directChatSearchProvider), 'Nhóm');
      repository.pendingGeneral = null;
      await _pull(
        tester,
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
      );
      expect(find.text('Kênh mới'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<ProviderContainer> _pumpRoot(
  WidgetTester tester,
  Widget page, {
  required FakeAuthApi auth,
  ScheduleApi? schedules,
  AttendanceApi? attendance,
  _LocationPlatform? location,
  ChatRepository? chat,
}) async {
  final container = ProviderContainer(
    retry: (retryCount, error) => null,
    overrides: [
      authApiProvider.overrideWithValue(auth),
      tokenStorageProvider.overrideWithValue(MemoryTokenStorage('saved-token')),
      if (schedules != null) scheduleApiProvider.overrideWithValue(schedules),
      if (attendance != null)
        attendanceApiProvider.overrideWithValue(attendance),
      if (location != null)
        deviceLocationServiceProvider.overrideWithValue(
          DeviceLocationService(platform: location),
        ),
      if (chat != null) chatRepositoryProvider.overrideWithValue(chat),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(),
        locale: const Locale('vi'),
        home: AuthSessionListener(child: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _pull(WidgetTester tester, Finder scrollable) async {
  await tester.drag(scrollable, const Offset(0, 500));
  await tester.pumpAndSettle();
}

final class _AttendanceApi implements AttendanceApi {
  int contextCalls = 0;
  int rangeCalls = 0;
  int workSeconds = 3600;
  final dates = <String>[];

  @override
  Future<AttendanceContext> fetchContext() async {
    contextCalls++;
    return const AttendanceContext(
      user: AttendanceUserRef(id: 'user-1', name: 'User'),
      assignedLocations: [],
      hasShiftToday: false,
    );
  }

  @override
  Future<AttendanceDayDetail> fetchDayDetail(String date) async {
    dates.add(date);
    return AttendanceDayDetail(
      date: date,
      totalWorkSeconds: workSeconds,
      logs: const [],
    );
  }

  @override
  Future<List<AttendanceRangeSummary>> fetchRange({
    required String from,
    required String to,
  }) async {
    rangeCalls++;
    return [];
  }

  @override
  Future<AttendanceLog> punch(AttendanceCoordinates? coordinates) =>
      throw UnimplementedError();
}

final class _LocationPlatform extends GeolocatorPlatform {
  int calls = 0;
  Completer<bool>? pending;

  @override
  Future<bool> isLocationServiceEnabled() async {
    calls++;
    if (pending != null) return pending!.future;
    return false;
  }
}

final class _ChatRepository implements ChatRepository {
  int generalCalls = 0;
  int directCalls = 0;
  bool hasData = false;
  Completer<List<ChatConversation>>? pendingGeneral;

  @override
  Future<List<ChatConversation>> loadGeneralChannels() async {
    generalCalls++;
    if (pendingGeneral != null) return pendingGeneral!.future;
    return hasData
        ? const [
            ChatConversation(
              kind: ChatConversationKind.general,
              id: 'general',
              title: 'Kênh mới',
              previewText: 'Nội dung mới',
              timestampLabel: '10:00',
              avatarKind: ChatConversationAvatarKind.organization,
            ),
          ]
        : [];
  }

  @override
  Future<List<ChatConversation>> loadDirectConversations() async {
    directCalls++;
    return hasData
        ? const [
            ChatConversation(
              kind: ChatConversationKind.group,
              id: 'direct',
              title: 'Nhóm mới',
              previewText: 'Nội dung mới',
              timestampLabel: '10:00',
              avatarKind: ChatConversationAvatarKind.group,
            ),
          ]
        : [];
  }

  @override
  Future<List<ChatCoworker>> loadCoworkers() => throw UnimplementedError();
  @override
  Future<String> openDirectConversationForCoworker(String coworkerId) =>
      throw UnimplementedError();
  @override
  Future<ChatThread> loadThread(String conversationId) =>
      throw UnimplementedError();
  @override
  Future<ChatGroupInfo> loadGroupInfo(String conversationId) =>
      throw UnimplementedError();
  @override
  Future<ChatThread> sendThreadMessage({
    required String conversationId,
    required String text,
  }) => throw UnimplementedError();
}

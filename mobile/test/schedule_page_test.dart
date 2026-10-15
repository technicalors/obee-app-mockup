import 'dart:async';

import 'package:dio/dio.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/auth/data/organization_ref.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_api.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_detail_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_detail_content.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_form_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/v2/schedule_page_v2.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_month_calendar.dart';

void main() {
  // Smoke test for replacing the placeholder route with the real schedule UI.
  testWidgets('schedule page renders the real schedule UI', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime(2026, 6, 8);
    final currentDay = DateTime(today.year, today.month, today.day, 9);
    final api = FakeScheduleApi(
      schedules: [
        _schedule(
          id: 'schedule-1',
          title: 'Planning',
          start: currentDay,
          end: currentDay.add(const Duration(hours: 1)),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: today),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('schedule-filter-toggle')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('schedule-visibility-dropdown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('schedule-user-dropdown')),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('schedule-user-dropdown')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Row &&
              widget.children.length == 3 &&
              widget.children[0] is Expanded &&
              widget.children[2] is Expanded,
        ),
      ),
      findsOneWidget,
    );

    final userSelectedText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-dropdown')),
        matching: find.text(_currentUser.name),
      ),
    );
    expect(userSelectedText.maxLines, 1);
    expect(userSelectedText.overflow, TextOverflow.ellipsis);

    final visibilitySelectedText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-visibility-dropdown')),
        matching: find.text(ScheduleVisibilityFilter.participated.label),
      ),
    );
    expect(visibilitySelectedText.maxLines, 1);
    expect(visibilitySelectedText.overflow, TextOverflow.ellipsis);

    expect(find.byKey(const ValueKey('schedule-month-picker')), findsOneWidget);
    expect(find.text('Tháng 6, 2026'), findsOneWidget);
    expect(find.text('Không có lịch trình'), findsNothing);
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Planning'), findsNWidgets(2));
    // Type label shows on the day tile and in the filter legend.
    expect(find.text('Cuộc họp'), findsNWidgets(2));
  });

  testWidgets('schedule page shows timeline dates for multi-day schedules', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime(2026, 12, 31);
    final api = FakeScheduleApi(
      schedules: [
        _schedule(
          id: 'schedule-overnight',
          title: 'Overnight workshop',
          type: ScheduleEventType.training,
          start: DateTime(2026, 12, 31, 22, 30),
          end: DateTime(2027, 1, 1, 7),
          scheduleType: ScheduleEventScheduleType.multipleDays,
          physicalAddress: 'Phòng đào tạo',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: today),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('22:30'), findsNothing);
    expect(find.text('07:00'), findsNothing);
    expect(find.text('31/12'), findsOneWidget);
    expect(find.text('01/01'), findsOneWidget);
    expect(find.text('31/12/2026'), findsNothing);
    expect(find.text('01/01/2027'), findsNothing);
    expect(find.text('Phòng đào tạo'), findsOneWidget);
    expect(find.text('Đào tạo'), findsOneWidget);
  });

  testWidgets('calendar displays titles for single-day and multi-day events', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime(2025, 4, 15);
    final api = FakeScheduleApi(
      schedules: [
        _schedule(
          id: 'schedule-single-day',
          title: 'Họp bí mật riêng tư',
          type: ScheduleEventType.meeting,
          start: DateTime(2025, 4, 15, 9),
          end: DateTime(2025, 4, 15, 10, 30),
          scheduleType: ScheduleEventScheduleType.ordinary,
          physicalAddress: 'Phòng họp A',
        ),
        _schedule(
          id: 'schedule-multi-day',
          title: 'Chuẩn bị demo Nhật Bản',
          type: ScheduleEventType.seminar,
          start: DateTime(2025, 4, 24),
          end: DateTime(2025, 4, 27),
          scheduleType: ScheduleEventScheduleType.multipleDays,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: today),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // In week view for Day 15, close to return to full month view
    await tester.tap(find.byKey(const ValueKey('schedule-day-panel-close')));
    await tester.pumpAndSettle();

    // Calendar month title
    expect(find.text('Tháng 4, 2025'), findsOneWidget);

    // Multi-day event: displays title in calendar (month view)
    expect(find.text('Chuẩn bị demo Nhật Bản'), findsOneWidget);

    // Re-select day 15 to open day panel
    await tester.tap(
      find.byKey(const ValueKey('schedule-day-2025-04-15')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    // Single-day event: title shows in the month cell and the day panel
    expect(find.text('Họp bí mật riêng tư'), findsNWidgets(2));
    // The type label only appears on the timeline card badge
    expect(find.text('Cuộc họp'), findsOneWidget);

    // Bottom panel header
    expect(find.text('Lịch ngày 15/04'), findsOneWidget);
    expect(find.text('Phòng họp A'), findsOneWidget);
  });

  testWidgets(
    'default calendar has no day selected, tapping day switches to week view, close button restores month view',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2025, 4, 15);
      final api = FakeScheduleApi(
        schedules: [
          _schedule(
            id: 'schedule-single-day',
            title: 'Họp bí mật riêng tư',
            type: ScheduleEventType.meeting,
            start: DateTime(2025, 4, 15, 9),
            end: DateTime(2025, 4, 15, 10, 30),
            scheduleType: ScheduleEventScheduleType.ordinary,
            physicalAddress: 'Phòng họp A',
          ),
        ],
      );

      // Open with initialSelectedDate = null (default behavior)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: GoRouter(
              initialLocation: '/app/schedule',
              routes: [
                GoRoute(
                  path: '/app/schedule',
                  builder: (context, state) => SchedulePage(now: today),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. By default, no day is selected and day panel is NOT shown
      expect(
        find.byKey(const ValueKey('schedule-day-panel-close')),
        findsNothing,
      );
      expect(find.text('Lịch ngày 15/04'), findsNothing);

      // 2. Tap on day 15 cell -> switches to week view of day 15 + shows day panel
      await tester.tap(
        find.byKey(const ValueKey('schedule-day-2025-04-15')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('schedule-day-panel-close')),
        findsOneWidget,
      );
      expect(find.text('Lịch ngày 15/04'), findsOneWidget);
      expect(find.text('Họp bí mật riêng tư'), findsNWidgets(2));

      // 3. Tap close button -> restores original month view
      await tester.tap(find.byKey(const ValueKey('schedule-day-panel-close')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('schedule-day-panel-close')),
        findsNothing,
      );
      expect(find.text('Lịch ngày 15/04'), findsNothing);
    },
  );

  testWidgets(
    'multi-day schedule wraps to next week and displays continuation from the cut-off part',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2025, 4, 1);
      final api = FakeScheduleApi(
        schedules: [
          _schedule(
            id: 'schedule-multi-cross-week',
            title:
                'Chuẩn bị demo kế hoạch phát triển thị trường Nhật Bản tại Tokyo',
            type: ScheduleEventType.training,
            start: DateTime(
              2025,
              4,
              18,
            ), // Friday of week 3 (Cols 4..6 = 3 cols)
            end: DateTime(
              2025,
              4,
              22,
            ), // Tuesday of week 4 (Cols 0..1 = 2 cols)
            scheduleType: ScheduleEventScheduleType.multipleDays,
          ),
          _schedule(
            id: 'schedule-short-multi',
            title: 'Họp ngắn',
            type: ScheduleEventType.seminar,
            start: DateTime(
              2025,
              4,
              25,
            ), // Friday of week 4 (Cols 4..6 = 3 cols)
            end: DateTime(
              2025,
              4,
              29,
            ), // Tuesday of week 5 (Cols 0..1 = 2 cols)
            scheduleType: ScheduleEventScheduleType.multipleDays,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: GoRouter(
              initialLocation: '/app/schedule',
              routes: [
                GoRoute(
                  path: '/app/schedule',
                  builder: (context, state) => SchedulePage(now: today),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Long title that was cut off: Week 3 shows first segment, Week 4 displays continuation
      expect(find.text('Chuẩn bị demo'), findsOneWidget);
      expect(find.text('kế hoạch'), findsOneWidget);

      // 2. Short title 'Họp ngắn' that completely fit in week 4:
      // In week 5 it is an empty card, so 'Họp ngắn' is rendered only once in the entire calendar!
      expect(find.text('Họp ngắn'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping different dates of a multi-day schedule badge selects the exact tapped date',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2026, 6, 8);
      final api = FakeScheduleApi(
        schedules: [
          _schedule(
            id: 'multi-day-event',
            title: 'Hội nghị khách hàng 3 ngày',
            type: ScheduleEventType.seminar,
            start: DateTime(2026, 6, 8),
            end: DateTime(2026, 6, 10),
            scheduleType: ScheduleEventScheduleType.multipleDays,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: _router(now: today),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('schedule-day-panel-close')));
      await tester.pumpAndSettle();

      final badgeFinder = find.text('Hội nghị khách hàng 3 ngày');
      expect(badgeFinder, findsOneWidget);

      final badgeRect = tester.getRect(badgeFinder);
      final middlePoint = Offset(
        badgeRect.left + badgeRect.width * 0.5,
        badgeRect.center.dy,
      );
      await tester.tapAt(middlePoint);
      await tester.pumpAndSettle();

      expect(find.text('Lịch ngày 09/06'), findsOneWidget);
    },
  );

  testWidgets(
    'schedule page collapses equal start and end time into one rail item',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2026, 6, 8);
      final api = FakeScheduleApi(
        schedules: [
          _schedule(
            id: 'schedule-same-time',
            title: 'Single timestamp event',
            start: DateTime(2026, 6, 8, 9),
            end: DateTime(2026, 6, 8, 9),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: _router(now: today),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('09:00'), findsOneWidget);
    },
  );

  testWidgets('schedule month picker changes the loaded calendar month', (
    tester,
  ) async {
    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: DateTime(2026, 6, 8)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(api.fetchSchedulesRequests, [
      (
        endFrom: DateTime(2026, 6, 1),
        endTo: null,
        eventId: null,
        startFrom: null,
        startTo: DateTime(2026, 7, 5),
        userIds: null,
        visibility: ScheduleVisibilityFilter.participated,
      ),
    ]);

    await tester.tap(find.text('Tháng 6, 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('month-year-picker-month-8')));
    await tester.pumpAndSettle();

    expect(find.text('Chọn tháng'), findsOneWidget);
    expect(api.fetchSchedulesRequests, [
      (
        endFrom: DateTime(2026, 6, 1),
        endTo: null,
        eventId: null,
        startFrom: null,
        startTo: DateTime(2026, 7, 5),
        userIds: null,
        visibility: ScheduleVisibilityFilter.participated,
      ),
    ]);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Tháng 8, 2026'), findsOneWidget);
    expect(api.fetchSchedulesRequests.last, (
      endFrom: DateTime(2026, 7, 27),
      endTo: null,
      eventId: null,
      startFrom: null,
      startTo: DateTime(2026, 9, 6),
      userIds: null,
      visibility: ScheduleVisibilityFilter.participated,
    ));
  });

  testWidgets(
    'selecting another company user forces visibility to all and disables visibility changes',
    (tester) async {
      final api = FakeScheduleApi();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: _router(now: DateTime(2026, 6, 8)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('schedule-filter-toggle')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('schedule-user-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_observerUser.name).last);
      await tester.pumpAndSettle();

      expect(api.fetchSchedulesRequests.last, (
        endFrom: DateTime(2026, 6, 1),
        endTo: null,
        eventId: null,
        startFrom: null,
        startTo: DateTime(2026, 7, 5),
        userIds: _observerUser.id,
        visibility: ScheduleVisibilityFilter.all,
      ));

      final disabledVisibilityField = tester
          .widget<DropdownButtonFormField<ScheduleVisibilityFilter>>(
            find.byKey(const ValueKey('schedule-visibility-dropdown')),
          );
      expect(disabledVisibilityField.onChanged, isNull);

      await tester.tap(find.byKey(const ValueKey('schedule-user-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_currentUser.name).last);
      await tester.pumpAndSettle();

      expect(api.fetchSchedulesRequests.last, (
        endFrom: DateTime(2026, 6, 1),
        endTo: null,
        eventId: null,
        startFrom: null,
        startTo: DateTime(2026, 7, 5),
        userIds: null,
        visibility: ScheduleVisibilityFilter.all,
      ));

      final enabledVisibilityField = tester
          .widget<DropdownButtonFormField<ScheduleVisibilityFilter>>(
            find.byKey(const ValueKey('schedule-visibility-dropdown')),
          );
      expect(enabledVisibilityField.onChanged, isNotNull);
    },
  );

  // Verifies the primary user action is wired all the way to the modal form.
  testWidgets('create button opens the schedule form page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: DateTime(2026, 6, 8)),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thêm lịch trình mới'));
    await tester.pumpAndSettle();

    expect(find.text('Tiêu đề'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('schedule_form_header_save')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('schedule-participants-field')),
      findsOneWidget,
    );
  });

  testWidgets(
    'schedule form renders date and time picker text fields',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = FakeScheduleApi();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: _router(
              now: DateTime(2026, 6, 8),
              initialLocation: ScheduleFormPage.routePath,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ngày bắt đầu'), findsOneWidget);
      expect(find.text('Ngày kết thúc'), findsOneWidget);
      expect(find.text('Thời điểm bắt đầu'), findsOneWidget);
      expect(find.text('Thời điểm kết thúc'), findsOneWidget);

      final pickerFields = tester
          .widgetList<TextField>(find.byType(TextField))
          .where((field) => field.readOnly)
          .toList(growable: false);

      expect(pickerFields, hasLength(4));
      expect(
        pickerFields
            .map((field) => field.controller?.text)
            .toList(growable: false),
        [
          matches(RegExp(r'^\d{2}/\d{2}/\d{4}$')),
          matches(RegExp(r'^\d{2}/\d{2}/\d{4}$')),
          matches(RegExp(r'^\d{2}:\d{2}$')),
          matches(RegExp(r'^\d{2}:\d{2}$')),
        ],
      );
    },
  );

  testWidgets('repeat schedule shows weekly repeat-pattern tree select', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleFormPage.routePath,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<ScheduleEventScheduleType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lặp lại').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<ScheduleEventRepeatType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hàng tuần').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('schedule-repeat-pattern-field')),
      findsOneWidget,
    );
  });

  testWidgets('canceling the form returns without reloading schedules', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: DateTime(2026, 6, 8)),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(api.fetchSchedulesCallCount, 1);

    await tester.tap(find.byTooltip('Thêm lịch trình mới'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('schedule-month-picker')), findsOneWidget);
    expect(api.fetchSchedulesCallCount, 1);
  });

  testWidgets(
    'exiting edited form shows discard confirmation dialog and cancels or confirms exit',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = FakeScheduleApi();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: _router(now: DateTime(2026, 6, 8)),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Thêm lịch trình mới'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Edited title');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();

      expect(find.text('Bỏ thay đổi?'), findsOneWidget);
      expect(find.text('Ở lại'), findsOneWidget);
      expect(find.text('Bỏ thay đổi'), findsOneWidget);

      await tester.tap(find.text('Ở lại'));
      await tester.pumpAndSettle();
      expect(find.text('Tạo lịch trình'), findsOneWidget);

      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Bỏ thay đổi'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('schedule-month-picker')),
        findsOneWidget,
      );
      expect(api.createScheduleCallCount, 0);
    },
  );

  testWidgets('saving the form reloads schedules after pop result', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: DateTime(2026, 6, 8)),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(api.fetchSchedulesCallCount, 1);

    await tester.tap(find.byTooltip('Thêm lịch trình mới'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'New planning');
    await tester.tap(find.byKey(const ValueKey('schedule_form_header_save')));
    await tester.pumpAndSettle();

    expect(api.createScheduleCallCount, 1);
    expect(api.fetchSchedulesCallCount, 2);
    expect(find.byKey(const ValueKey('schedule-month-picker')), findsOneWidget);
  });

  testWidgets('participant tree select supports grouped selection and search', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleFormPage.routePath,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('schedule-participants-field')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('schedule-participants-sheet')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-company-1')),
        matching: find.text('Công ty A'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-dept-1')),
        matching: find.text('Kinh doanh'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('schedule-user-dept-1-user-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();

    expect(find.text('Minh'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('schedule-clear-participants')));
    await tester.pumpAndSettle();
    expect(find.text('Minh'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('schedule-observers-field')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('schedule-observers-search')),
      'Minh',
    );
    await tester.pumpAndSettle();
    expect(find.text('Công ty A'), findsOneWidget);
    // Tree automatically expands to the matching items on search
    expect(find.text('Kinh doanh'), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, 'Minh'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('schedule-user-dept-1-user-1')),
      findsNothing,
    );
    expect(find.text('Công ty B'), findsNothing);
  });

  testWidgets('repeat type switch clears stale repeat pattern selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleFormPage.routePath,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<ScheduleEventScheduleType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lặp lại').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<ScheduleEventRepeatType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hàng tuần').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('schedule-repeat-pattern-field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-repeat-group-weekly')),
        matching: find.text('Thứ trong tuần'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('schedule-repeat-item-weekly-1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(find.text('Thứ 2'), findsOneWidget);

    await tester.tap(
      find.byType(DropdownButtonFormField<ScheduleEventRepeatType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hàng ngày').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('schedule-repeat-pattern-field')),
      findsNothing,
    );
    expect(find.text('Thứ 2'), findsNothing);
  });

  testWidgets(
    'switching weekly and monthly repeat types clears stale repeat pattern ids',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = FakeScheduleApi();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: _router(
              now: DateTime(2026, 6, 8),
              initialLocation: ScheduleFormPage.routePath,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(
        find.byType(DropdownButtonFormField<ScheduleEventScheduleType>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lặp lại').last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byType(DropdownButtonFormField<ScheduleEventRepeatType>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hàng tuần').last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('schedule-repeat-pattern-field')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('schedule-repeat-group-weekly')),
          matching: find.text('Thứ trong tuần'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('schedule-repeat-item-weekly-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
      await tester.pumpAndSettle();
      expect(find.text('Thứ 2'), findsOneWidget);

      await tester.tap(
        find.byType(DropdownButtonFormField<ScheduleEventRepeatType>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hàng tháng').last);
      await tester.pumpAndSettle();
      expect(find.text('Thứ 2'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('schedule-repeat-pattern-field')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('schedule-repeat-group-monthly')),
          matching: find.text('Ngày trong tháng'),
        ),
      );
      await tester.pumpAndSettle();

      final monthlyTile = tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('schedule-repeat-item-monthly-1')),
      );
      expect(monthlyTile.value, isFalse);

      await tester.tap(
        find.byKey(const ValueKey('schedule-repeat-item-monthly-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      await tester.tap(
        find.byType(DropdownButtonFormField<ScheduleEventRepeatType>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hàng tuần').last);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsNothing);
    },
  );

  testWidgets('repeat schedule shows monthly repeat-pattern tree select', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleFormPage.routePath,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<ScheduleEventScheduleType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lặp lại').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<ScheduleEventRepeatType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hàng tháng').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('schedule-repeat-pattern-field')),
      findsOneWidget,
    );
  });

  testWidgets('selection users render once under their assigned organization', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi(users: const [_sameOrganizationUser]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleFormPage.routePath,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('schedule-participants-field')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-company-1')),
        matching: find.text('Công ty A'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-dept-1')),
        matching: find.text('Kinh doanh'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('schedule-user-dept-1-user-3')),
      findsOneWidget,
    );
  });

  testWidgets('edit route pre-fills the existing event values', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime(2026, 6, 8);
    final currentDay = DateTime(today.year, today.month, today.day, 9);
    final api = FakeScheduleApi(
      schedules: [
        _schedule(
          id: 'schedule-1',
          title: 'Planning',
          start: currentDay,
          end: currentDay.add(const Duration(hours: 1)),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: today,
            initialLocation:
                '${ScheduleFormPage.routePath}?scheduleId=schedule-1&eventId=event-schedule-1&mode=edit',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(api.fetchScheduleDetailCallCount, 1);
    expect(find.text('Chỉnh sửa lịch trình'), findsOneWidget);
    final titleField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(titleField.initialValue, 'Planning');
    expect(
      find.byKey(const ValueKey('schedule_form_header_save')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('schedule-participants-field')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-company-1')),
        matching: find.text('Công ty A'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-dept-1')),
        matching: find.text('Kinh doanh'),
      ),
    );
    await tester.pumpAndSettle();

    final participantTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('schedule-user-dept-1-user-1')),
    );
    expect(participantTile.value, isTrue);
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('schedule-observers-field')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-company-1')),
        matching: find.text('Công ty A'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-dept-1')),
        matching: find.text('Kinh doanh'),
      ),
    );
    await tester.pumpAndSettle();

    final observerTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('schedule-user-dept-1-user-2')),
    );
    expect(observerTile.value, isTrue);
  });

  testWidgets('reuse route pre-fills selected participants in the picker', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime(2026, 6, 8);
    final currentDay = DateTime(today.year, today.month, today.day, 9);
    final api = FakeScheduleApi(
      schedules: [
        _schedule(
          id: 'schedule-1',
          title: 'Planning',
          start: currentDay,
          end: currentDay.add(const Duration(hours: 1)),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: today,
            initialLocation:
                '${ScheduleFormPage.routePath}?scheduleId=schedule-1&eventId=event-schedule-1',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('schedule-participants-field')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-company-1')),
        matching: find.text('Công ty A'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-dept-1')),
        matching: find.text('Kinh doanh'),
      ),
    );
    await tester.pumpAndSettle();

    final participantTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('schedule-user-dept-1-user-1')),
    );
    expect(participantTile.value, isTrue);
  });

  testWidgets(
    'edit route drops hidden cross-company participant and observer ids',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2026, 6, 10);
      final api = FakeScheduleApi(
        schedules: [_crossCompanySchedule(id: 'schedule-cross-company-1')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: _router(now: today),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('schedule-tile-schedule-cross-company-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('schedule_detail_header_edit')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Huy'), findsNothing);
      expect(find.text('Lan'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('schedule_form_header_save')));
      await tester.pump();

      expect(api.lastUpdateDraft?.participants, ['user-1']);
      expect(api.lastUpdateDraft?.observers, isEmpty);
      expect(find.text('Cập nhật lịch trình thành công.'), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('Chi tiết lịch trình'), findsOneWidget);

      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('schedule-month-picker')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'edit route keeps existing participant and observer ids for unassigned users',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2026, 6, 10);
      final router = _router(now: today);
      final api = FakeScheduleApi(
        schedules: [_crossCompanySchedule(id: 'schedule-cross-company-2')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(
              _FakeUnassignedAuthController.new,
            ),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      router.push(
        '${ScheduleFormPage.routePath}?scheduleId=schedule-cross-company-2&eventId=event-schedule-cross-company-2&mode=edit',
      );
      await tester.pumpAndSettle();

      expect(find.text('Chỉnh sửa lịch trình'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('schedule_form_header_save')));
      await tester.pumpAndSettle();

      expect(api.lastUpdateDraft?.participants, ['user-1', 'user-4']);
      expect(api.lastUpdateDraft?.observers, ['user-4']);
    },
  );

  testWidgets(
    'edit route keeps participants assigned directly to the root organization',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2026, 6, 10);
      final api = FakeScheduleApi(
        schedules: [_rootOrganizationSchedule(id: 'schedule-company-1')],
        users: const [_currentUser, _observerUser, _rootOrganizationUser],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: _router(now: today),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('schedule-tile-schedule-company-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('schedule_detail_header_edit')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phuong'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('schedule_form_header_save')));
      await tester.pumpAndSettle();

      expect(api.lastUpdateDraft?.participants, ['user-1', 'user-6']);
      expect(api.lastUpdateDraft?.observers, isEmpty);
    },
  );

  testWidgets('selecting a parent group confirms all child user ids', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleFormPage.routePath,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('schedule-participants-field')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-company-1')),
        matching: find.byType(Checkbox),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();

    expect(find.text('Minh'), findsOneWidget);
    expect(find.text('Lan'), findsOneWidget);
  });

  testWidgets('repeat edit route pre-fills repeat pattern selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi(
      schedules: [_repeatSchedule(id: 'repeat-schedule-1')],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation:
                '${ScheduleFormPage.routePath}?scheduleId=repeat-schedule-1&eventId=event-repeat-schedule-1&mode=edit',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('schedule-repeat-pattern-field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-repeat-group-weekly')),
        matching: find.text('Thứ trong tuần'),
      ),
    );
    await tester.pumpAndSettle();

    final mondayTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('schedule-repeat-item-weekly-1')),
    );
    final wednesdayTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('schedule-repeat-item-weekly-3')),
    );
    expect(mondayTile.value, isTrue);
    expect(wednesdayTile.value, isTrue);
  });

  testWidgets('repeat reuse route pre-fills repeat pattern selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi(
      schedules: [_repeatSchedule(id: 'repeat-schedule-1')],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation:
                '${ScheduleFormPage.routePath}?scheduleId=repeat-schedule-1&eventId=event-repeat-schedule-1',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('schedule-repeat-pattern-field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-repeat-group-weekly')),
        matching: find.text('Thứ trong tuần'),
      ),
    );
    await tester.pumpAndSettle();

    final mondayTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('schedule-repeat-item-weekly-1')),
    );
    expect(mondayTile.value, isTrue);
  });

  testWidgets('submitting with no participants still blocks the form', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleFormPage.routePath,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Planning');
    await tester.tap(find.byKey(const ValueKey('schedule-participants-field')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-company-1')),
        matching: find.text('Công ty A'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-user-group-dept-1')),
        matching: find.text('Kinh doanh'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('schedule-user-dept-1-user-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('schedule_form_header_save')));
    await tester.pumpAndSettle();

    expect(find.text('Cần chọn ít nhất một người tham gia.'), findsOneWidget);
    expect(api.createScheduleCallCount, 0);
  });

  testWidgets('repeat submit sends selected repeat pattern integers', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: DateTime(2026, 6, 8)),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thêm lịch trình mới'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Weekly planning');
    await tester.tap(
      find.byType(DropdownButtonFormField<ScheduleEventScheduleType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lặp lại').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<ScheduleEventRepeatType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hàng tuần').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('schedule-repeat-pattern-field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-repeat-group-weekly')),
        matching: find.text('Thứ trong tuần'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('schedule-repeat-item-weekly-1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('schedule-repeat-item-weekly-3')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('schedule_form_header_save')));
    await tester.pumpAndSettle();

    expect(api.createScheduleCallCount, 1);
    expect(api.lastCreateDraft?.repeatPattern, [1, 3]);
  });

  testWidgets('users without organization cannot create schedule', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(
            _FakeUnassignedAuthController.new,
          ),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleFormPage.routePath,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Bạn cần được gán tổ chức trước khi tạo lịch trình.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('schedule-participants-field')),
      findsNothing,
    );
    expect(api.createScheduleCallCount, 0);
  });

  testWidgets('malformed edit route is rejected up front', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation:
                '${ScheduleFormPage.routePath}?eventId=event-schedule-1&mode=edit',
          ),
        ),
      ),
    );

    await tester.pump();

    final error = tester.takeException();
    expect(error, isA<StateError>());
    expect(api.fetchScheduleDetailCallCount, 0);
    expect(api.createScheduleCallCount, 0);
  });

  testWidgets('empty edit route parameters are rejected up front', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation:
                '${ScheduleFormPage.routePath}?scheduleId=&eventId=&mode=edit',
          ),
        ),
      ),
    );

    await tester.pump();

    final error = tester.takeException();
    expect(error, isA<StateError>());
    expect(api.fetchScheduleDetailCallCount, 0);
    expect(api.createScheduleCallCount, 0);
  });

  testWidgets('tapping a schedule opens the detail page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime(2026, 6, 8);
    final currentDay = DateTime(today.year, today.month, today.day, 9);
    final api = FakeScheduleApi(
      schedules: [
        _schedule(
          id: 'schedule-1',
          title: 'Planning',
          start: currentDay,
          end: currentDay.add(const Duration(hours: 1)),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: today),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('schedule-tile-schedule-1')));
    await tester.pumpAndSettle();

    expect(api.fetchScheduleDetailCallCount, 1);
    expect(find.text('Chi tiết lịch trình'), findsOneWidget);
    expect(find.textContaining('Planning'), findsOneWidget);
    expect(find.byTooltip('Quay lại'), findsOneWidget);
  });

  testWidgets('repeat detail shows repeat summary badge', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi(
      schedules: [_repeatSchedule(id: 'repeat-schedule-1')],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleDetailPage.location(
              scheduleId: 'repeat-schedule-1',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hàng tuần · 10/06/2026 - 30/06/2026'), findsOneWidget);
  });

  testWidgets('canceling detail returns without reloading schedules', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime(2026, 6, 8);
    final currentDay = DateTime(today.year, today.month, today.day, 9);
    final api = FakeScheduleApi(
      schedules: [
        _schedule(
          id: 'schedule-1',
          title: 'Planning',
          start: currentDay,
          end: currentDay.add(const Duration(hours: 1)),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(now: today),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(api.fetchSchedulesCallCount, 1);

    await tester.tap(find.byKey(const ValueKey('schedule-tile-schedule-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('schedule-month-picker')), findsOneWidget);
    expect(api.fetchSchedulesCallCount, 1);
  });

  testWidgets('malformed detail route is rejected up front', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: ScheduleDetailPage.routePath,
          ),
        ),
      ),
    );

    await tester.pump();

    final error = tester.takeException();
    expect(error, isA<StateError>());
    expect(api.fetchScheduleDetailCallCount, 0);
  });

  testWidgets('empty detail route parameter is rejected up front', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = FakeScheduleApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: _router(
            now: DateTime(2026, 6, 8),
            initialLocation: '${ScheduleDetailPage.routePath}?scheduleId=',
          ),
        ),
      ),
    );

    await tester.pump();

    final error = tester.takeException();
    expect(error, isA<StateError>());
    expect(api.fetchScheduleDetailCallCount, 0);
  });

  for (final reloadFails in [false, true]) {
    testWidgets(
      'system back refreshes calendar after saving (reload failed: $reloadFails)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final today = DateTime(2026, 6, 8);
        final original = _schedule(
          id: 'schedule-1',
          title: 'Planning',
          start: DateTime(2026, 6, 8, 9),
          end: DateTime(2026, 6, 8, 10),
        );
        final updated = original.copyWith(
          event: original.event.copyWith(title: 'Updated planning'),
        );
        final reload = Completer<List<ScheduleModel>>();
        final api = FakeScheduleApi(schedules: [original])
          ..updatedSchedules = [updated]
          ..eventSchedulesResult = reload;
        final router = _router(now: today);
        addTearDown(router.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              scheduleApiProvider.overrideWithValue(api),
              authControllerProvider.overrideWith(_FakeAuthController.new),
            ],
            child: MaterialApp.router(
              theme: buildAppTheme(),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('schedule-tile-schedule-1')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('schedule_detail_header_edit')),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).first,
          'Updated planning',
        );
        await tester.tap(
          find.byKey(const ValueKey('schedule_form_header_save')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(ScheduleFormPage), findsNothing);
        expect(api.fetchSchedulesCallCount, 2);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        if (reloadFails) {
          reload.completeError(StateError('detail reload failed'));
          await tester.pumpAndSettle();
          expect(find.text('Không thể tải chi tiết lịch trình.'), findsWidgets);
        }

        // Exercise Android/system Back rather than the header's explicit callback.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleDetailPage), findsNothing);
        expect(api.fetchSchedulesCallCount, 3);
        expect(api.fetchSchedulesRequests.last.eventId, isNull);
        expect(find.text('Updated planning'), findsNWidgets(2));
        if (!reloadFails) {
          reload.complete([updated]);
          await tester.pumpAndSettle();
          expect(find.byType(ScheduleDetailPage), findsNothing);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  for (final movedToNextMonth in [false, true]) {
    testWidgets(
      'saving edits refreshes regenerated detail and allows another edit (moved: $movedToNextMonth)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final today = DateTime(2026, 6, 8);
        var original = _schedule(
          id: 'schedule-1',
          title: 'Planning',
          start: DateTime(2026, 6, 8, 9),
          end: DateTime(2026, 6, 8, 10),
        );
        if (!movedToNextMonth) {
          original = original.copyWith(
            event: original.event.copyWith(
              scheduleType: ScheduleEventScheduleType.repeat,
              repeatType: ScheduleEventRepeatType.daily,
              startDate: DateTime(2026, 6, 1),
              endDate: DateTime(2026, 6, 30),
            ),
          );
        }
        final api = FakeScheduleApi(schedules: [original]);
        final router = _router(now: today);
        addTearDown(router.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              scheduleApiProvider.overrideWithValue(api),
              authControllerProvider.overrideWith(_FakeAuthController.new),
            ],
            child: MaterialApp.router(
              theme: buildAppTheme(),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('schedule-tile-schedule-1')),
        );
        await tester.pumpAndSettle();

        for (var revision = 1; revision <= 2; revision++) {
          await tester.tap(
            find.byKey(const ValueKey('schedule_detail_header_edit')),
          );
          await tester.pumpAndSettle();
          final title = 'Updated planning $revision';
          await tester.enterText(find.byType(TextFormField).first, title);
          final month = movedToNextMonth ? 7 : 6;
          final updated = original.copyWith(
            id: 'regenerated-$revision',
            start: DateTime(2026, month, 8, 11),
            end: DateTime(2026, month, 8, 12),
            event: original.event.copyWith(
              title: title,
              startDate: movedToNextMonth
                  ? DateTime(2026, month, 8)
                  : original.event.startDate,
              endDate: movedToNextMonth
                  ? DateTime(2026, month, 8)
                  : original.event.endDate,
              startTime: '11:00',
              endTime: '12:00',
              physicalAddress: 'New location $revision',
              note: 'New note $revision',
            ),
          );
          api.updatedSchedules = [
            if (!movedToNextMonth)
              updated.copyWith(
                id: 'earlier-$revision',
                start: DateTime(2026, 6, 1, 11),
                end: DateTime(2026, 6, 1, 12),
              ),
            updated,
          ];

          await tester.tap(
            find.byKey(const ValueKey('schedule_form_header_save')),
          );
          await tester.pumpAndSettle();

          expect(find.byType(ScheduleFormPage), findsNothing);
          final detail = tester.widget<ScheduleDetailContent>(
            find.byType(ScheduleDetailContent),
          );
          expect(detail.schedule, updated);
          expect(
            find.textContaining(title, findRichText: true),
            findsOneWidget,
          );
          expect(find.text('New location $revision'), findsOneWidget);
          expect(find.text('New note $revision'), findsOneWidget);
          expect(api.fetchSchedulesRequests.last, (
            endFrom: null,
            endTo: null,
            eventId: original.event.id,
            startFrom: null,
            startTo: null,
            userIds: null,
            visibility: ScheduleVisibilityFilter.all,
          ));
          // Opening the next edit must fetch the regenerated ID, not the old one.
          expect(api.fetchScheduleDetailCallCount, revision + 1);
        }

        await tester.tap(find.byTooltip('Quay lại'));
        await tester.pumpAndSettle();
        expect(find.byType(ScheduleDetailPage), findsNothing);
        expect(api.fetchSchedulesCallCount, 4);
      },
    );
  }

  testWidgets(
    'header action buttons on detail and form trigger edit and save',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime(2026, 6, 8);
      final currentDay = DateTime(today.year, today.month, today.day, 9);
      final api = FakeScheduleApi(
        schedules: [
          _schedule(
            id: 'schedule-1',
            title: 'Planning',
            start: currentDay,
            end: currentDay.add(const Duration(hours: 1)),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleApiProvider.overrideWithValue(api),
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: _router(now: today),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('schedule-tile-schedule-1')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('schedule_detail_header_edit')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('schedule_detail_header_edit')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('schedule_form_header_save')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('schedule_form_header_save')));
      await tester.pump();

      expect(api.lastUpdateDraft, isNotNull);
      expect(find.text('Cập nhật lịch trình thành công.'), findsWidgets);
    },
  );

  testWidgets('view menu switches between week, month and year views', (
    tester,
  ) async {
    final api = FakeScheduleApi(
      schedules: [
        _schedule(
          id: 'schedule-1',
          title: 'Planning',
          start: DateTime(2026, 6, 10, 9),
          end: DateTime(2026, 6, 10, 10, 30),
        ),
        _schedule(
          id: 'schedule-2',
          title: 'Sync',
          start: DateTime(2026, 6, 10, 10),
          end: DateTime(2026, 6, 10, 11),
        ),
      ],
    );
    await _pumpSchedulePage(tester, api: api, now: DateTime(2026, 6, 10));

    await _selectViewMode(tester, ScheduleViewMode.week);

    expect(find.text('8 – 14/06'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('schedule-week-block-schedule-1-2026-06-10')),
      findsOneWidget,
    );
    // Overlapping blocks are laid out side by side.
    final first = tester.getRect(
      find.byKey(const ValueKey('schedule-week-block-schedule-1-2026-06-10')),
    );
    final second = tester.getRect(
      find.byKey(const ValueKey('schedule-week-block-schedule-2-2026-06-10')),
    );
    expect(second.left, greaterThan(first.left));
    expect(api.fetchSchedulesRequests.last.endFrom, DateTime(2026, 6, 8));
    expect(api.fetchSchedulesRequests.last.startTo, DateTime(2026, 6, 14));

    await _selectViewMode(tester, ScheduleViewMode.year);

    expect(find.byKey(const ValueKey('schedule-year-grid')), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(api.fetchSchedulesRequests.last.endFrom, DateTime(2026));
    expect(api.fetchSchedulesRequests.last.startTo, DateTime(2026, 12, 31));

    await tester.tap(find.byKey(const ValueKey('schedule-year-month-8')));
    await tester.pumpAndSettle();

    expect(find.text('Tháng 8, 2026'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('schedule-day-2026-08-15')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('schedule-today-button')));
    await tester.pumpAndSettle();

    expect(find.text('Tháng 6, 2026'), findsOneWidget);
  });

  testWidgets('tapping an empty week slot creates a schedule at that hour', (
    tester,
  ) async {
    final api = FakeScheduleApi();
    await _pumpSchedulePage(tester, api: api, now: DateTime(2026, 6, 10));
    await _selectViewMode(tester, ScheduleViewMode.week);

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const ValueKey('schedule-week-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    scrollable.position.jumpTo(13 * 56);
    await tester.pumpAndSettle();

    final column = find.byKey(
      const ValueKey('schedule-week-column-2026-06-11'),
    );
    await tester.tapAt(tester.getTopLeft(column) + const Offset(10, 14.5 * 56));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Slot planning');
    await tester.tap(find.byKey(const ValueKey('schedule_form_header_save')));
    await tester.pumpAndSettle();

    expect(api.lastCreateDraft?.startDate, DateTime(2026, 6, 11, 14));
    expect(api.lastCreateDraft?.endDate, DateTime(2026, 6, 11, 15));
    expect(api.lastCreateDraft?.startTime, '14:00');
  });

  testWidgets('create button is hidden without the create permission', (
    tester,
  ) async {
    await _pumpSchedulePage(
      tester,
      api: FakeScheduleApi(),
      now: DateTime(2026, 6, 10),
      auth: _FakeObserverAuthController.new,
    );

    expect(find.byKey(const ValueKey('schedule-create-fab')), findsNothing);
  });

  testWidgets('month cells cap visible events and show a +N counter', (
    tester,
  ) async {
    final api = FakeScheduleApi(
      schedules: [
        for (var hour = 8; hour < 13; hour++)
          _schedule(
            id: 'schedule-$hour',
            title: 'Event $hour',
            start: DateTime(2026, 6, 10, hour),
            end: DateTime(2026, 6, 10, hour, 30),
          ),
      ],
    );
    await _pumpSchedulePage(tester, api: api, now: DateTime(2026, 6, 10));

    expect(
      find.byKey(const ValueKey('schedule-day-more-2026-06-10')),
      findsOneWidget,
    );
    expect(find.text('+2'), findsOneWidget);
  });

  for (final mode in ScheduleViewMode.values) {
    testWidgets('${mode.name} view fits a narrow phone', (tester) async {
      final api = FakeScheduleApi(
        schedules: [
          _schedule(
            id: 'schedule-1',
            title: 'Họp kế hoạch sản phẩm rất dài',
            start: DateTime(2026, 6, 10, 9),
            end: DateTime(2026, 6, 10, 10),
          ),
          _schedule(
            id: 'schedule-2',
            title: 'Hội thảo khách hàng',
            type: ScheduleEventType.seminar,
            scheduleType: ScheduleEventScheduleType.multipleDays,
            start: DateTime(2026, 6, 9),
            end: DateTime(2026, 6, 12),
          ),
        ],
      );
      await _pumpSchedulePage(
        tester,
        api: api,
        now: DateTime(2026, 6, 10),
        size: const Size(320, 640),
      );
      await _selectViewMode(tester, mode);

      expect(tester.takeException(), isNull);
    });
  }

  group('schedule layout v2', () {
    Widget v2(DateTime now) => SchedulePageV2(now: now);

    List<ScheduleModel> v2Schedules() => [
      _schedule(
        id: 'schedule-today',
        title: 'Planning',
        start: DateTime(2026, 6, 10, 9),
        end: DateTime(2026, 6, 10, 10),
      ),
      _schedule(
        id: 'schedule-later',
        title: 'Client review',
        type: ScheduleEventType.seminar,
        start: DateTime(2026, 6, 12, 14),
        end: DateTime(2026, 6, 12, 15),
      ),
    ];

    testWidgets('tapping a day opens the day drawer like layout v1', (
      tester,
    ) async {
      await _pumpSchedulePage(
        tester,
        api: FakeScheduleApi(schedules: v2Schedules()),
        now: DateTime(2026, 6, 10),
        page: v2,
      );

      expect(find.text('Tháng 6, 2026'), findsOneWidget);
      // Full grid only: titles in the cells, no drawer yet.
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Client review'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('schedule-day-panel-close')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('schedule-day-2026-06-12')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('Lịch ngày 12/06'), findsOneWidget);
      expect(find.text('Client review'), findsNWidgets(2));
      // The grid collapses to the tapped week.
      expect(
        find.byKey(const ValueKey('schedule-day-2026-06-01')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('schedule-day-panel-close')));
      await tester.pumpAndSettle();

      expect(find.text('Lịch ngày 12/06'), findsNothing);
      expect(
        find.byKey(const ValueKey('schedule-day-2026-06-01')),
        findsOneWidget,
      );
    });

    testWidgets('view menu switches between year, month and week', (
      tester,
    ) async {
      final api = FakeScheduleApi(schedules: v2Schedules());
      await _pumpSchedulePage(
        tester,
        api: api,
        now: DateTime(2026, 6, 10),
        page: v2,
      );

      await _selectViewMode(tester, ScheduleViewMode.week);

      expect(find.text('8 – 14/06'), findsOneWidget);
      // Only the selected week's row is shown.
      expect(
        find.byKey(const ValueKey('schedule-day-2026-06-08')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('schedule-day-2026-06-15')),
        findsNothing,
      );
      expect(find.text('Planning'), findsNWidgets(2));
      expect(api.fetchSchedulesRequests.last.endFrom, DateTime(2026, 6, 8));

      await _selectViewMode(tester, ScheduleViewMode.year);

      expect(find.byKey(const ValueKey('schedule-year-grid')), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('schedule-year-month-9')));
      await tester.pumpAndSettle();

      expect(find.text('Tháng 9, 2026'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('schedule-day-2026-09-15')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('schedule-today-button')));
      await tester.pumpAndSettle();

      expect(find.text('Tháng 6, 2026'), findsOneWidget);
    });

    testWidgets('multi-day events render as a bar across their days', (
      tester,
    ) async {
      await _pumpSchedulePage(
        tester,
        api: FakeScheduleApi(
          schedules: [
            _schedule(
              id: 'schedule-conference',
              title: 'Hội nghị',
              type: ScheduleEventType.seminar,
              scheduleType: ScheduleEventScheduleType.multipleDays,
              start: DateTime(2026, 6, 9),
              end: DateTime(2026, 6, 11),
            ),
          ],
        ),
        now: DateTime(2026, 6, 10),
        page: v2,
      );

      // One bar in the grid spanning 9–11/06, plus the agenda card for today.
      final barText = find.descendant(
        of: find.byType(ScheduleMonthCalendar),
        matching: find.text('Hội nghị'),
      );
      expect(barText, findsOneWidget);
      final bar = tester.getRect(
        find.ancestor(of: barText, matching: find.byType(Container)).first,
      );
      final firstDay = tester.getRect(
        find.byKey(const ValueKey('schedule-day-2026-06-09')),
      );
      final lastDay = tester.getRect(
        find.byKey(const ValueKey('schedule-day-2026-06-11')),
      );
      expect(bar.left, closeTo(firstDay.left, 4));
      expect(bar.right, closeTo(lastDay.right, 4));
    });

    testWidgets('filter toggle shows the shared filter fields', (tester) async {
      await _pumpSchedulePage(
        tester,
        api: FakeScheduleApi(),
        now: DateTime(2026, 6, 10),
        page: v2,
      );

      await tester.tap(find.byKey(const ValueKey('schedule-filter-toggle')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('schedule-user-dropdown')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('schedule-visibility-dropdown')),
        findsOneWidget,
      );
    });

    testWidgets('create actions are hidden without the create permission', (
      tester,
    ) async {
      await _pumpSchedulePage(
        tester,
        api: FakeScheduleApi(),
        now: DateTime(2026, 6, 10),
        auth: _FakeObserverAuthController.new,
        page: v2,
      );

      expect(find.byKey(const ValueKey('schedule-create-fab')), findsNothing);
      expect(
        find.byKey(const ValueKey('schedule-v2-empty-create')),
        findsNothing,
      );
    });

    testWidgets('add button opens the create form', (tester) async {
      await _pumpSchedulePage(
        tester,
        api: FakeScheduleApi(),
        now: DateTime(2026, 6, 10),
        page: v2,
      );

      await tester.tap(find.byTooltip('Thêm lịch trình mới'));
      await tester.pumpAndSettle();

      expect(find.text('Tiêu đề'), findsOneWidget);
    });

    for (final mode in ScheduleViewMode.values) {
      testWidgets('${mode.name} view fits a narrow phone', (tester) async {
        await _pumpSchedulePage(
          tester,
          api: FakeScheduleApi(schedules: v2Schedules()),
          now: DateTime(2026, 6, 10),
          size: const Size(320, 640),
          page: v2,
        );
        await _selectViewMode(tester, mode);

        expect(tester.takeException(), isNull);
      });
    }
  });
}

Future<void> _pumpSchedulePage(
  WidgetTester tester, {
  required FakeScheduleApi api,
  required DateTime now,
  AuthController Function() auth = _FakeAuthController.new,
  Size size = const Size(800, 1400),
  Widget Function(DateTime now)? page,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    initialLocation: '/app/schedule',
    routes: [
      GoRoute(
        path: ScheduleFormPage.routePath,
        builder: (context, state) => const ScheduleFormPage(isEditing: false),
      ),
      GoRoute(
        path: '/app/schedule',
        builder: (context, state) => page?.call(now) ?? SchedulePage(now: now),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        scheduleApiProvider.overrideWithValue(api),
        authControllerProvider.overrideWith(auth),
      ],
      child: MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectViewMode(WidgetTester tester, ScheduleViewMode mode) async {
  await tester.tap(find.byKey(const ValueKey('schedule-view-mode-button')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('schedule-view-mode-${mode.name}')));
  await tester.pumpAndSettle();
}

GoRouter _router({required DateTime now, String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation ?? '/app/schedule',
    routes: [
      GoRoute(
        path: ScheduleDetailPage.routePath,
        builder: (context, state) {
          final config = ScheduleDetailPage.parseRoute(state.uri);

          return ScheduleDetailPage(scheduleId: config.scheduleId);
        },
      ),
      GoRoute(
        path: ScheduleFormPage.routePath,
        builder: (context, state) {
          final config = ScheduleFormPage.parseRoute(state.uri);

          return ScheduleFormPage(
            scheduleId: config.scheduleId,
            scheduleEventId: config.scheduleEventId,
            isEditing: config.isEditing,
          );
        },
      ),
      GoRoute(
        path: '/app/schedule',
        builder: (context, state) =>
            SchedulePage(now: now, initialSelectedDate: now),
      ),
    ],
  );
}

const _rootA = OrganizationRef(
  id: 'company-1',
  name: 'Công ty A',
  type: 'Công ty',
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
);
const _rootB = OrganizationRef(
  id: 'company-2',
  name: 'Công ty B',
  type: 'Công ty',
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
);
const _salesOrganization = OrganizationRef(
  id: 'dept-1',
  name: 'Kinh doanh',
  type: 'Phòng ban',
  parentId: 'company-1',
  parent: _rootA,
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
);
const _accountingOrganization = OrganizationRef(
  id: 'dept-9',
  name: 'Kế toán',
  type: 'Phòng ban',
  parentId: 'company-2',
  parent: _rootB,
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
);

const _currentUser = User(
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
  id: 'user-1',
  permissions: [
    PermissionRef(
      id: 'permission-create',
      name: 'schedule-events.create',
      description: null,
      createdAt: null,
      updatedAt: null,
    ),
    PermissionRef(
      id: 'permission-update',
      name: 'schedule-events.update',
      description: null,
      createdAt: null,
      updatedAt: null,
    ),
    PermissionRef(
      id: 'permission-delete',
      name: 'schedule-events.delete',
      description: null,
      createdAt: null,
      updatedAt: null,
    ),
  ],
  name: 'Lan',
  username: 'lan',
  email: 'lan@example.com',
  avatar: null,
  rootOrganizationId: 'company-1',
  organizationId: 'dept-1',
  organization: _salesOrganization,
);

/// Feature-local fake used by widget tests so the page can exercise loading and
/// navigation behavior without pulling in transport concerns.
class FakeScheduleApi implements ScheduleApi {
  FakeScheduleApi({
    this.schedules = const [],
    this.users = const [_currentUser, _observerUser, _otherCompanyUser],
    this.failDeleteSchedule = false,
  });

  List<ScheduleModel> schedules;
  List<ScheduleModel>? updatedSchedules;
  Completer<List<ScheduleModel>>? eventSchedulesResult;
  final List<User> users;
  final bool failDeleteSchedule;
  ScheduleDraft? lastCreateDraft;
  ScheduleDraft? lastUpdateDraft;
  final List<
    ({
      DateTime? endTo,
      DateTime? endFrom,
      String? eventId,
      DateTime? startFrom,
      DateTime? startTo,
      String? userIds,
      ScheduleVisibilityFilter visibility,
    })
  >
  fetchSchedulesRequests = [];
  var createScheduleCallCount = 0;
  var deleteScheduleCallCount = 0;
  var fetchScheduleDetailCallCount = 0;
  var fetchSchedulesCallCount = 0;
  var joinScheduleCallCount = 0;
  var leaveScheduleCallCount = 0;

  @override
  Future<void> createSchedule(ScheduleDraft draft) async {
    createScheduleCallCount += 1;
    lastCreateDraft = draft;
  }

  @override
  Future<void> deleteSchedule(String scheduleEventId) async {
    deleteScheduleCallCount += 1;
    if (failDeleteSchedule) {
      throw Exception('delete failed');
    }
  }

  @override
  Future<ScheduleModel> fetchScheduleDetail(String scheduleId) async {
    fetchScheduleDetailCallCount += 1;
    return schedules.firstWhere((item) => item.id == scheduleId);
  }

  @override
  Future<List<ScheduleModel>> fetchSchedules({
    CancelToken? cancelToken,
    DateTime? endTo,
    DateTime? endFrom,
    String? eventId,
    DateTime? startFrom,
    DateTime? startTo,
    String? userIds,
    required ScheduleVisibilityFilter visibility,
  }) async {
    fetchSchedulesCallCount += 1;
    fetchSchedulesRequests.add((
      endFrom: endFrom,
      eventId: eventId,
      endTo: endTo,
      startFrom: startFrom,
      startTo: startTo,
      userIds: userIds,
      visibility: visibility,
    ));
    final result = eventSchedulesResult;
    if (eventId != null && result != null) {
      return result.future;
    }
    return eventId == null
        ? schedules
        : schedules.where((item) => item.eventId == eventId).toList();
  }

  @override
  Future<List<UserTreeSelectionUser>> fetchUsers({
    required String rootOrganizationId,
  }) async => users
      .where(
        (u) =>
            u.rootOrganizationId == rootOrganizationId &&
            u.organization != null,
      )
      .map(
        (u) => UserTreeSelectionUser(
          id: u.id,
          name: u.name,
          username: u.username,
          organizationId: u.organizationId!,
          organization: u.organization!,
          profile: null,
        ),
      )
      .toList();

  @override
  Future<void> joinSchedule(String scheduleEventId) async {
    joinScheduleCallCount += 1;
  }

  @override
  Future<void> leaveSchedule(String scheduleEventId) async {
    leaveScheduleCallCount += 1;
  }

  @override
  Future<void> updateSchedule({
    required String scheduleEventId,
    required ScheduleDraft draft,
  }) async {
    lastUpdateDraft = draft;
    final updated = updatedSchedules;
    if (updated != null) {
      schedules = updated;
    }
  }
}

/// Auth override that keeps the page inside the authenticated shell state.
class _FakeAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState.authenticated(_currentUser);
  }
}

class _FakeObserverAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState.authenticated(_observerUser);
  }
}

class _FakeUnassignedAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState.authenticated(_unassignedUser);
  }
}

const _observerUser = User(
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
  id: 'user-2',
  name: 'Minh',
  username: 'minh',
  email: 'minh@example.com',
  avatar: null,
  rootOrganizationId: 'company-1',
  organizationId: 'dept-1',
  organization: _salesOrganization,
);

const _sameOrganizationUser = User(
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
  id: 'user-3',
  name: 'Hoa',
  username: 'hoa',
  email: 'hoa@example.com',
  avatar: null,
  rootOrganizationId: 'company-1',
  organizationId: 'dept-1',
  organization: _salesOrganization,
);

const _otherCompanyUser = User(
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
  id: 'user-4',
  name: 'Huy',
  username: 'huy',
  email: 'huy@example.com',
  avatar: null,
  rootOrganizationId: 'company-2',
  organizationId: 'dept-9',
  organization: _accountingOrganization,
);

const _rootOrganizationUser = User(
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
  id: 'user-6',
  name: 'Phuong',
  username: 'phuong',
  email: 'phuong@example.com',
  avatar: null,
  rootOrganizationId: 'company-1',
  organizationId: 'company-1',
  organization: _rootA,
);

const _unassignedUser = User(
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
  id: 'user-5',
  name: 'Khach',
  username: 'khach',
  email: 'khach@example.com',
  avatar: null,
);

/// Compact schedule fixture for rendering tests.
ScheduleModel _schedule({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  ScheduleEventType type = ScheduleEventType.meeting,
  ScheduleEventScheduleType scheduleType = ScheduleEventScheduleType.ordinary,
  String physicalAddress = 'HQ',
  String createdBy = 'user-1',
  List<ScheduleUserRef> participants = const [
    ScheduleUserRef(id: 'user-1', name: 'Lan', avatar: null, email: null),
  ],
  List<ScheduleUserRef> observers = const [
    ScheduleUserRef(id: 'user-2', name: 'Minh', avatar: null, email: null),
  ],
}) {
  return ScheduleModel(
    eventId: 'event-$id',
    id: id,
    start: start,
    end: end,
    oneDay:
        start.year == end.year &&
        start.month == end.month &&
        start.day == end.day,
    remindAt: null,
    event: ScheduleEventModel(
      id: 'event-$id',
      title: title,
      type: type,
      scheduleType: scheduleType,
      startDate: start,
      endDate: end,
      repeatType: null,
      repeatPattern: null,
      startTime:
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
      endTime:
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
      note: null,
      physicalAddress: physicalAddress,
      privacy: ScheduleEventPrivacy.public,
      isGeneral: false,
      remindRange: null,
      remindValue: null,
      createdBy: createdBy,
      updatedBy: null,
      createdAt: start,
      updatedAt: start,
      participants: participants,
      observers: observers,
    ),
  );
}

ScheduleModel _repeatSchedule({required String id}) {
  final start = DateTime(2026, 6, 10, 8);
  final end = DateTime(2026, 6, 30, 17);

  return ScheduleModel(
    eventId: 'event-$id',
    id: id,
    start: start,
    end: end,
    oneDay: false,
    remindAt: null,
    event: ScheduleEventModel(
      id: 'event-$id',
      title: 'Weekly planning',
      type: ScheduleEventType.meeting,
      scheduleType: ScheduleEventScheduleType.repeat,
      startDate: start,
      endDate: end,
      repeatType: ScheduleEventRepeatType.weekly,
      repeatPattern: const [1, 3],
      startTime: '08:00',
      endTime: '17:00',
      note: null,
      physicalAddress: 'HQ',
      privacy: ScheduleEventPrivacy.public,
      isGeneral: false,
      remindRange: null,
      remindValue: null,
      createdBy: 'user-1',
      updatedBy: null,
      createdAt: start,
      updatedAt: start,
      participants: const [
        ScheduleUserRef(id: 'user-1', name: 'Lan', avatar: null, email: null),
      ],
      observers: const [
        ScheduleUserRef(id: 'user-2', name: 'Minh', avatar: null, email: null),
      ],
    ),
  );
}

ScheduleModel _crossCompanySchedule({required String id}) {
  final start = DateTime(2026, 6, 10, 8);
  final end = DateTime(2026, 6, 10, 9);

  return ScheduleModel(
    eventId: 'event-$id',
    id: id,
    start: start,
    end: end,
    oneDay: true,
    remindAt: null,
    event: ScheduleEventModel(
      id: 'event-$id',
      title: 'Cross company planning',
      type: ScheduleEventType.meeting,
      scheduleType: ScheduleEventScheduleType.ordinary,
      startDate: start,
      endDate: end,
      repeatType: null,
      repeatPattern: null,
      startTime: null,
      endTime: null,
      note: null,
      physicalAddress: 'HQ',
      privacy: ScheduleEventPrivacy.public,
      isGeneral: false,
      remindRange: null,
      remindValue: null,
      createdBy: 'user-1',
      updatedBy: null,
      createdAt: start,
      updatedAt: start,
      participants: const [
        ScheduleUserRef(id: 'user-1', name: 'Lan', avatar: null, email: null),
        ScheduleUserRef(id: 'user-4', name: 'Huy', avatar: null, email: null),
      ],
      observers: const [
        ScheduleUserRef(id: 'user-4', name: 'Huy', avatar: null, email: null),
      ],
    ),
  );
}

ScheduleModel _rootOrganizationSchedule({required String id}) {
  final start = DateTime(2026, 6, 10, 8);
  final end = DateTime(2026, 6, 10, 9);

  return ScheduleModel(
    eventId: 'event-$id',
    id: id,
    start: start,
    end: end,
    oneDay: true,
    remindAt: null,
    event: ScheduleEventModel(
      id: 'event-$id',
      title: 'Root organization participant planning',
      type: ScheduleEventType.meeting,
      scheduleType: ScheduleEventScheduleType.ordinary,
      startDate: start,
      endDate: end,
      repeatType: null,
      repeatPattern: null,
      startTime: null,
      endTime: null,
      note: null,
      physicalAddress: 'HQ',
      privacy: ScheduleEventPrivacy.public,
      isGeneral: false,
      remindRange: null,
      remindValue: null,
      createdBy: 'user-1',
      updatedBy: null,
      createdAt: start,
      updatedAt: start,
      participants: const [
        ScheduleUserRef(id: 'user-1', name: 'Lan', avatar: null, email: null),
        ScheduleUserRef(
          id: 'user-6',
          name: 'Phuong',
          avatar: null,
          email: null,
        ),
      ],
      observers: const [],
    ),
  );
}

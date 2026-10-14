import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/core/time/clock_provider.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/data/user_profile.dart';
import 'package:obee_mobile/src/features/requests/data/request_api.dart';
import 'package:obee_mobile/src/features/requests/state/request_list_controller.dart';
import 'package:obee_mobile/src/features/requests/ui/create_business_trip_request_page.dart';
import 'package:obee_mobile/src/features/requests/ui/create_leave_request_page.dart';
import 'package:obee_mobile/src/features/requests/ui/request_detail_page.dart';
import 'package:obee_mobile/src/features/requests/ui/request_list_page.dart';

import 'support/fake_request_api.dart';

void main() {
  testWidgets(
    'created date label displays defaults and clearing keeps picker defaults',
    (tester) async {
      await tester.pumpWidget(_buildTestWidget(const RequestListPage()));
      await tester.pumpAndSettle();
      final filter = find.byKey(const ValueKey('request_created_date_filter'));
      expect(find.text('Ngày tạo: 06/09/2026 - 06/10/2026'), findsOneWidget);
      expect(find.text('Khoảng ngày'), findsNothing);
      await tester.ensureVisible(filter);
      await tester.tap(
        find.descendant(of: filter, matching: find.byIcon(Icons.close)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ngày tạo'), findsOneWidget);
      await tester.tap(filter);
      await tester.pumpAndSettle();
      expect(find.text('Chọn ngày tạo'), findsOneWidget);
      final picker = tester.widget<DateRangePickerDialog>(
        find.byType(DateRangePickerDialog),
      );
      expect(picker.initialDateRange!.start, DateTime(2026, 9, 6));
      expect(picker.initialDateRange!.end, DateTime(2026, 10, 6));
      Navigator.of(tester.element(find.byType(DateRangePickerDialog))).pop();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'request list renders exactly 3 tabs: Yêu cầu, Chấp thuận, Từ chối',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestWidget(const RequestListPage()));
      await tester.pumpAndSettle();

      // Verify title and add button
      expect(find.text('Yêu cầu'), findsWidgets);
      expect(find.byKey(const ValueKey('request_add_action')), findsOneWidget);

      // Tab 'Tất cả' is removed
      expect(find.text('Tất cả'), findsNothing);

      // Exactly 3 tabs: Yêu cầu, Chấp thuận, Từ chối
      expect(find.text('Chấp thuận'), findsOneWidget);
      expect(find.text('Từ chối'), findsWidgets);

      // Filter chips: Người yêu cầu & Người duyệt
      expect(find.text('Người yêu cầu'), findsWidgets);
      expect(find.text('Người duyệt'), findsWidgets);

      // Formatted single-day date range with single date visible
      expect(find.textContaining('06/10/2026 08:00 - 12:00'), findsOneWidget);
    },
  );

  testWidgets('plus button shows bottom sheet with leave and trip options', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestWidget(const RequestListPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('request_add_action')));
    await tester.pumpAndSettle();

    expect(find.text('Tạo yêu cầu mới'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('create_leave_request_option')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('create_trip_request_option')),
      findsOneWidget,
    );
  });

  testWidgets(
    'create leave request page renders inputs, balance and submit action',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestWidget(const CreateLeaveRequestPage()));
      await tester.pumpAndSettle();

      expect(find.text('Tạo yêu cầu nghỉ phép'), findsOneWidget);
      expect(find.text('Số dư phép năm'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('leave_form_reviewer_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('leave_form_type_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('leave_form_date_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('leave_form_shift_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('leave_form_submit_button')),
        findsOneWidget,
      );
    },
  );

  testWidgets('create business trip page renders inputs and submit action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _buildTestWidget(const CreateBusinessTripRequestPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tạo yêu cầu công tác'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('trip_form_reviewer_field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('trip_form_start_time_field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('trip_form_end_time_field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('trip_form_address_input')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('trip_form_submit_button')),
      findsOneWidget,
    );
  });

  testWidgets(
    'request detail page renders details and pending action buttons',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final reviewerAuth = _FakeAuthApi(
        user: const User(
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          id: 'user-huu',
          name: 'Trần Văn Hữu',
          username: 'huu.tv',
          email: 'huu@example.com',
          avatar: null,
          profile: UserProfile(code: 'EMP-002'),
          rootOrganizationId: 'org-root',
          permissions: [
            PermissionRef(
              id: 'review',
              name: 'absence-requests.review',
              description: null,
              createdAt: null,
              updatedAt: null,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          const RequestDetailPage(requestId: 'req-1'),
          authApi: reviewerAuth,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chi tiết yêu cầu'), findsOneWidget);
      expect(find.text('Nghỉ phép không lương'), findsWidgets);
      expect(find.text('YC-2026-104'), findsOneWidget);
      expect(find.text('Thông tin yêu cầu'), findsOneWidget);
      expect(find.text('Hoàng Văn Lượng'), findsOneWidget);
      expect(find.text('Trần Văn Hữu'), findsOneWidget);

      // 3 action buttons for pending request
      expect(
        find.byKey(const ValueKey('detail_approve_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('detail_reject_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('detail_return_button')),
        findsOneWidget,
      );

      // Tap approve opens action modal with OK button
      await tester.tap(find.byKey(const ValueKey('detail_approve_button')));
      await tester.pumpAndSettle();
      expect(find.text('Chấp nhận yêu cầu'), findsOneWidget);
      expect(find.text('Xác nhận phê duyệt yêu cầu này'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      // For leave request (not business trip), Địa điểm should not be shown
      expect(find.text('Địa điểm'), findsNothing);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Đã chấp thuận yêu cầu.'), findsOneWidget);
    },
  );

  testWidgets(
    'reject action opens modal with reason input and confirms with OK',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final reviewerAuth = _FakeAuthApi(
        user: const User(
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          id: 'user-huu',
          name: 'Trần Văn Hữu',
          username: 'huu.tv',
          email: 'huu@example.com',
          avatar: null,
          profile: UserProfile(code: 'EMP-002'),
          rootOrganizationId: 'org-root',
          permissions: [
            PermissionRef(
              id: 'review',
              name: 'absence-requests.review',
              description: null,
              createdAt: null,
              updatedAt: null,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          const RequestDetailPage(requestId: 'req-1'),
          authApi: reviewerAuth,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('detail_reject_button')));
      await tester.pumpAndSettle();

      expect(find.text('Từ chối yêu cầu'), findsOneWidget);
      expect(find.text('Vui lòng nhập lý do từ chối'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('modal_reject_reason_input')),
        findsOneWidget,
      );
      expect(find.text('OK'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('modal_reject_reason_input')),
        'Lý do bận công việc đột xuất',
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('modal_reject_confirm_button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Đã từ chối yêu cầu.'), findsOneWidget);
    },
  );

  testWidgets(
    'return action opens modal with revision note input and confirms with OK',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final reviewerAuth = _FakeAuthApi(
        user: const User(
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          id: 'user-huu',
          name: 'Trần Văn Hữu',
          username: 'huu.tv',
          email: 'huu@example.com',
          avatar: null,
          profile: UserProfile(code: 'EMP-002'),
          rootOrganizationId: 'org-root',
          permissions: [
            PermissionRef(
              id: 'review',
              name: 'absence-requests.review',
              description: null,
              createdAt: null,
              updatedAt: null,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          const RequestDetailPage(requestId: 'req-1'),
          authApi: reviewerAuth,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('detail_return_button')));
      await tester.pumpAndSettle();

      expect(find.text('Cần điều chỉnh'), findsOneWidget);
      expect(find.text('Nêu rõ nội dung cần điều chỉnh'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('modal_return_note_input')),
        findsOneWidget,
      );
      expect(find.text('OK'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('modal_return_note_input')),
        'Vui lòng đính kèm biên bản kiểm tra máy',
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('modal_return_confirm_button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Đã chuyển sang cần điều chỉnh.'), findsOneWidget);
    },
  );

  testWidgets('own pending request displays cancel schedule send action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Authenticated user owns req-1 by user_id.
    final authApi = _FakeAuthApi(
      user: const User(
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        id: 'user-luong',
        name: 'Hoàng Văn Lượng',
        username: 'luong.hv',
        email: 'luong@example.com',
        avatar: null,
        profile: UserProfile(code: 'EMP-001'),
      ),
    );

    await tester.pumpWidget(
      _buildTestWidget(const RequestListPage(), authApi: authApi),
    );
    await tester.pumpAndSettle();

    // Card of own request displays cancel schedule send icon
    expect(find.byIcon(Icons.cancel_schedule_send), findsOneWidget);
  });

  testWidgets(
    'own pending request in detail page shows back and cancel on appbar and no review bottom bar',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ownAuth = _FakeAuthApi(
        user: const User(
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          id: 'user-luong',
          name: 'Hoàng Văn Lượng',
          username: 'luong.hv',
          email: 'luong@example.com',
          avatar: null,
          profile: UserProfile(code: 'EMP-001'),
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          const RequestDetailPage(requestId: 'req-1'),
          authApi: ownAuth,
        ),
      );
      await tester.pumpAndSettle();

      // Back button exists
      expect(
        find.byKey(const ValueKey('request_detail_back_button')),
        findsOneWidget,
      );
      // Cancel schedule send icon on AppBar
      expect(
        find.byKey(const ValueKey('detail_cancel_button')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cancel_schedule_send), findsOneWidget);
      // No review buttons for own request
      expect(find.byKey(const ValueKey('detail_approve_button')), findsNothing);
      expect(find.byKey(const ValueKey('detail_reject_button')), findsNothing);
      expect(find.byKey(const ValueKey('detail_return_button')), findsNothing);
    },
  );

  testWidgets(
    'third-party user in detail page only shows back button on appbar and no action buttons',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Third party user (neither requester nor reviewer)
      final thirdPartyAuth = _FakeAuthApi(
        user: const User(
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          id: 'user-other',
          name: 'Người Thứ Ba',
          username: 'other',
          email: 'other@example.com',
          avatar: null,
          profile: UserProfile(code: 'EMP-999'),
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          const RequestDetailPage(requestId: 'req-1'),
          authApi: thirdPartyAuth,
        ),
      );
      await tester.pumpAndSettle();

      // Back button exists
      expect(
        find.byKey(const ValueKey('request_detail_back_button')),
        findsOneWidget,
      );
      // No cancel action and no review actions
      expect(find.byKey(const ValueKey('detail_cancel_button')), findsNothing);
      expect(find.byKey(const ValueKey('detail_approve_button')), findsNothing);
      expect(find.byKey(const ValueKey('detail_reject_button')), findsNothing);
      expect(find.byKey(const ValueKey('detail_return_button')), findsNothing);
    },
  );

  testWidgets(
    'returned request displays revision note and edit button on appbar for requester',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final requesterAuth = _FakeAuthApi(
        user: const User(
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          id: 'user-luong',
          name: 'Hoàng Văn Lượng',
          username: 'luong.hv',
          email: 'luong@example.com',
          avatar: null,
          profile: UserProfile(code: 'EMP-001'),
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          const RequestDetailPage(requestId: 'req-5'),
          authApi: requesterAuth,
        ),
      );
      await tester.pumpAndSettle();

      // Revision note card is shown
      expect(find.text('Nội dung cần chỉnh sửa'), findsOneWidget);
      expect(
        find.textContaining('Vui lòng bổ sung kế hoạch làm việc'),
        findsOneWidget,
      );

      // Edit action button on AppBar for requester
      expect(find.byKey(const ValueKey('detail_edit_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('detail_cancel_button')), findsNothing);
    },
  );

  testWidgets(
    'rejected request displays rejection reason and edit button on appbar for requester',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final requesterAuth = _FakeAuthApi(
        user: const User(
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          id: 'user-luong',
          name: 'Hoàng Văn Lượng',
          username: 'luong.hv',
          email: 'luong@example.com',
          avatar: null,
          profile: UserProfile(code: 'EMP-001'),
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          const RequestDetailPage(requestId: 'req-6'),
          authApi: requesterAuth,
        ),
      );
      await tester.pumpAndSettle();

      // Rejection reason card is shown
      expect(find.text('Lý do từ chối'), findsOneWidget);
      expect(
        find.textContaining('Trùng đợt triển khai dự án trọng điểm'),
        findsOneWidget,
      );

      // Edit action button on AppBar for requester
      expect(find.byKey(const ValueKey('detail_edit_button')), findsOneWidget);
    },
  );

  testWidgets(
    'editing a returned business trip request pre-fills inputs and re-submits',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestWidget(
          const CreateBusinessTripRequestPage(requestId: 'req-5'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chỉnh sửa yêu cầu công tác'), findsOneWidget);
      // Pre-filled address
      expect(find.text('Đà Nẵng'), findsOneWidget);

      // Submit re-sends the request
      await tester.tap(find.byKey(const ValueKey('trip_form_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Đã gửi lại yêu cầu thành công!'), findsOneWidget);
    },
  );

  testWidgets('editing a leave request pre-fills inputs and re-submits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _buildTestWidget(const CreateLeaveRequestPage(requestId: 'req-6')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chỉnh sửa yêu cầu nghỉ phép'), findsOneWidget);
    expect(find.text('Nghỉ du lịch cùng gia đình.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('leave_form_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Đã gửi lại yêu cầu thành công!'), findsOneWidget);
  });

  testWidgets(
    'created date filter updates matching items and tab badges dynamically',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(
            Clock.fixed(DateTime.utc(2026, 10, 6, 3)),
          ),
          tokenStorageProvider.overrideWithValue(
            _MemoryTokenStorage('saved-token'),
          ),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
          requestApiProvider.overrideWithValue(FakeRequestApi()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(),
            locale: const Locale('vi'),
            home: const RequestListPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final controller = container.read(requestListControllerProvider.notifier);

      // Filter to October 2026: only October items match (req-1, req-2, req-3)
      controller.selectDateRange(
        DateTimeRange(
          start: DateTime(2026, 10, 1),
          end: DateTime(2026, 10, 10),
        ),
      );
      await tester.pumpAndSettle();

      final state = container.read(requestListControllerProvider);
      expect(state.pendingCount, 1);
      expect(state.approvedCount, 2);
      expect(state.rejectedCount, 0);

      // Clear filter: all items match
      controller.selectDateRange(null);
      await tester.pumpAndSettle();

      final resetState = container.read(requestListControllerProvider);
      expect(resetState.pendingCount, 1);
      expect(resetState.approvedCount, 2);
      expect(resetState.rejectedCount, 3);
    },
  );
}

Widget _buildTestWidget(
  Widget child, {
  _FakeAuthApi? authApi,
  FakeRequestApi? requestApi,
}) {
  return ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(
        Clock.fixed(DateTime.utc(2026, 10, 6, 3)),
      ),
      tokenStorageProvider.overrideWithValue(
        _MemoryTokenStorage('saved-token'),
      ),
      authApiProvider.overrideWithValue(authApi ?? _FakeAuthApi()),
      requestApiProvider.overrideWithValue(requestApi ?? FakeRequestApi()),
    ],
    child: MaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('vi'),
      home: child,
    ),
  );
}

class _MemoryTokenStorage implements TokenStorage {
  _MemoryTokenStorage([this.token]);

  String? token;

  @override
  Future<void> clearToken() async => token = null;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String token) async => this.token = token;
}

class _FakeAuthApi implements AuthApi {
  _FakeAuthApi({User? user})
    : _user =
          user ??
          const User(
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
            id: 'user-1',
            name: 'Admin User',
            username: 'admin',
            email: 'admin@example.com',
            avatar: null,
            profile: UserProfile(code: 'EMP-TEST'),
            rootOrganizationId: 'org-root',
          );

  final User _user;

  @override
  Future<User> currentUser() async => _user;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

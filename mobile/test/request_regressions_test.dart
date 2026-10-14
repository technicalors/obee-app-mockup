import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/time/clock_provider.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/requests/data/request_api.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/state/create_leave_request_controller.dart';
import 'package:obee_mobile/src/features/requests/state/create_trip_request_controller.dart';
import 'package:obee_mobile/src/features/requests/ui/create_business_trip_request_page.dart';
import 'package:obee_mobile/src/features/requests/ui/create_leave_request_page.dart';
import 'package:obee_mobile/src/features/requests/ui/request_detail_page.dart';
import 'package:obee_mobile/src/features/requests/ui/request_list_page.dart';
import 'package:obee_mobile/src/features/requests/ui/widgets/request_action_dialogs.dart';

import 'support/fake_request_api.dart';
import 'support/request_fixtures.dart';

void main() {
  for (final status in ['rejected', 'returned']) {
    for (final viewerId in ['user-luong', 'user-huu', 'unrelated-user']) {
      testWidgets('$status feedback is visible to every viewer ($viewerId)', (
        tester,
      ) async {
        final api = FakeRequestApi();
        api.items = [
          initialDemoRequests.first.copyWith(
            status: status,
            approvalNote: 'Nội dung phản hồi riêng tư',
          ),
        ];
        final user = _reviewer.copyWith(id: viewerId, permissions: []);
        await tester.pumpWidget(
          _app(const RequestListPage(), api: api, user: user),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Từ chối'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Nội dung phản hồi riêng tư'),
          findsOneWidget,
        );
        await tester.pumpWidget(
          _app(
            const RequestDetailPage(requestId: 'req-1'),
            api: api,
            user: user,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Nội dung phản hồi riêng tư'), findsOneWidget);
        expect(
          find.text(
            status == 'rejected' ? 'Lý do từ chối' : 'Nội dung cần chỉnh sửa',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('revision requires a nonblank note and returns validated text', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showReturnRequestModal(
                  context: context,
                  item: initialDemoRequests.first,
                );
              },
              child: const Text('Mở'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Mở'));
    await tester.pumpAndSettle();
    final confirm = find.byKey(const ValueKey('modal_return_confirm_button'));
    final input = find.byKey(const ValueKey('modal_return_note_input'));
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập nội dung cần điều chỉnh.'), findsOneWidget);
    expect(result, isNull);
    await tester.enterText(input, '  \n  ');
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('modal_return_note_input')),
      findsOneWidget,
    );
    await tester.enterText(input, '  Bổ sung kế hoạch  ');
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(result, 'Bổ sung kế hoạch');
    expect(tester.takeException(), isNull);
  });

  for (final approve in [true, false]) {
    for (final size in [const Size(320, 480), const Size(840, 600)]) {
      testWidgets(
        '${approve ? 'approval' : 'cancellation'} scrolls long reason at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          bool? result;
          final item = initialDemoRequests.first.copyWith(
            reason: List.filled(40, 'Nội dung yêu cầu nhiều dòng.').join('\n'),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () async {
                      result = approve
                          ? await showApproveRequestModal(
                              context: context,
                              item: item,
                            )
                          : await showCancelRequestModal(
                              context: context,
                              item: item,
                            );
                    },
                    child: const Text('Mở'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Mở'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final confirm = find.byKey(
            ValueKey(
              approve
                  ? 'modal_approve_confirm_button'
                  : 'modal_cancel_confirm_button',
            ),
          );
          await tester.ensureVisible(confirm);
          await tester.pumpAndSettle();
          await tester.tap(confirm);
          await tester.pumpAndSettle();
          expect(result, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final name in ['Hoàng Văn Lượng', 'Trần Văn Hữu']) {
    testWidgets(
      'same display name $name grants no ownership controls in list or detail',
      (tester) async {
        final user = _reviewer.copyWith(
          id: 'unrelated-user',
          name: name,
          username: name == 'Hoàng Văn Lượng' ? 'luong.hv' : 'huu.tv',
        );
        await tester.pumpWidget(_app(const RequestListPage(), user: user));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.cancel_schedule_send), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('request_card_req-1')),
            matching: find.byIcon(Icons.check),
          ),
          findsNothing,
        );
        await tester.pumpWidget(
          _app(const RequestDetailPage(requestId: 'req-1'), user: user),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('detail_approve_button')),
          findsNothing,
        );
        expect(find.byIcon(Icons.cancel_schedule_send), findsNothing);
        await tester.pumpWidget(
          _app(const RequestDetailPage(requestId: 'req-5'), user: user),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('detail_edit_button')), findsNothing);
      },
    );
  }

  testWidgets(
    'persisted custom interval is rendered without invented full-day shift',
    (tester) async {
      final api = FakeRequestApi();
      api.items = [
        initialDemoRequests.first.copyWith(
          startAt: '2026-10-06T03:00:00Z',
          endAt: '2026-10-06T05:00:00Z',
        ),
      ];
      await tester.pumpWidget(
        _app(const RequestDetailPage(requestId: 'req-1'), api: api),
      );
      await tester.pumpAndSettle();
      expect(find.text('06/10/2026 10:00 – 12:00'), findsNWidgets(2));
      expect(find.text('Cả ngày (08:00 – 17:30)'), findsNothing);
    },
  );

  for (final trip in [false, true]) {
    for (final failure in [false, true]) {
      testWidgets(
        '${trip ? 'trip' : 'leave'} edit continuation is safe after page disposal (${failure ? 'failure' : 'success'})',
        (tester) async {
          final api = FakeRequestApi()
            ..detailCompleter = Completer<AbsenceRequestModel>();
          await tester.pumpWidget(
            _app(
              trip
                  ? const CreateBusinessTripRequestPage(requestId: 'req-5')
                  : const CreateLeaveRequestPage(requestId: 'req-1'),
              api: api,
            ),
          );
          await tester.pump();
          await tester.pumpWidget(const SizedBox());
          if (failure) {
            api.detailCompleter!.completeError(StateError('offline'));
          } else {
            api.detailCompleter!.complete(initialDemoRequests.first);
          }
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('${trip ? 'trip' : 'leave'} reviewer picker applies Bỏ chọn', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          trip
              ? const CreateBusinessTripRequestPage()
              : const CreateLeaveRequestPage(),
          user: _reviewer.copyWith(id: 'user-luong'),
        ),
      );
      await tester.pumpAndSettle();
      final field = find.byKey(
        ValueKey(
          trip ? 'trip_form_reviewer_field' : 'leave_form_reviewer_field',
        ),
      );
      final container = ProviderScope.containerOf(tester.element(field));
      if (trip) {
        container
            .read(createTripRequestControllerProvider.notifier)
            .setReviewer('user-huu');
      } else {
        container
            .read(createLeaveRequestControllerProvider.notifier)
            .setReviewer('user-huu');
      }
      await tester.pumpAndSettle();
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bỏ chọn'));
      await tester.pumpAndSettle();
      expect(
        trip
            ? container.read(createTripRequestControllerProvider).reviewerId
            : container.read(createLeaveRequestControllerProvider).reviewerId,
        isNull,
      );
    });
  }

  testWidgets('failed list approval displays failure and no success message', (
    tester,
  ) async {
    final api = FakeRequestApi()..mutationError = StateError('forbidden');
    await tester.pumpWidget(_app(const RequestListPage(), api: api));
    await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('request_card_req-1'));
    await tester.tap(
      find.descendant(of: card, matching: find.byIcon(Icons.check)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('modal_approve_confirm_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Không thể chấp thuận yêu cầu.'), findsWidgets);
    expect(find.text('Đã chấp thuận yêu cầu.'), findsNothing);
    expect(api.items.first.status, 'pending');
  });
}

Widget _app(Widget page, {FakeRequestApi? api, User user = _reviewer}) =>
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(
          Clock.fixed(DateTime.utc(2026, 10, 6, 3)),
        ),
        requestApiProvider.overrideWithValue(api ?? FakeRequestApi()),
        authControllerProvider.overrideWith(() => _Auth(user)),
      ],
      child: MaterialApp(home: page),
    );

const _reviewer = User(
  id: 'user-huu',
  name: 'Trần Văn Hữu',
  username: 'huu.tv',
  email: null,
  avatar: null,
  rootOrganizationId: 'org-root',
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
  permissions: [
    PermissionRef(
      id: 'review',
      name: 'absence-requests.review',
      description: null,
      createdAt: null,
      updatedAt: null,
    ),
  ],
);

class _Auth extends AuthController {
  _Auth(this.user);
  final User user;
  @override
  AuthState build() => AuthState.authenticated(user);
}

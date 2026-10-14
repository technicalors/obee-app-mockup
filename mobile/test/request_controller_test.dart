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
import 'package:obee_mobile/src/features/requests/state/request_detail_controller.dart';
import 'package:obee_mobile/src/features/requests/state/request_list_controller.dart';

import 'support/fake_request_api.dart';
import 'support/request_fixtures.dart';

void main() {
  for (final (instant, start, end) in [
    (
      DateTime.utc(2026, 10, 5, 18),
      DateTime(2026, 9, 6),
      DateTime(2026, 10, 6),
    ),
    (DateTime.utc(2026, 1, 1), DateTime(2025, 12, 2), DateTime(2026, 1, 1)),
    (DateTime.utc(2024, 3, 1), DateTime(2024, 1, 31), DateTime(2024, 3, 1)),
  ]) {
    test(
      'default created-date range uses Vietnamese today and 30 prior days at $instant',
      () {
        final container = _container(
          FakeRequestApi(),
          clock: Clock.fixed(instant),
        );
        final range = container
            .read(requestListControllerProvider)
            .selectedDateRange!;
        expect(range.start, start);
        expect(range.end, end);
      },
    );
  }

  test(
    'created-date filter includes whole boundary days and ignores absence dates',
    () async {
      final api = FakeRequestApi();
      api.items = [
        initialDemoRequests.first.copyWith(
          id: 'before',
          createdAt: '2026-09-05T23:59:59.999999+07:00',
        ),
        initialDemoRequests.first.copyWith(
          id: 'first',
          createdAt: '2026-09-05T17:00:00Z',
          startAt: '2026-12-01T01:00:00Z',
          endAt: '2026-12-01T05:00:00Z',
        ),
        initialDemoRequests.first.copyWith(
          id: 'last',
          createdAt: '2026-10-06T16:59:59.999999Z',
          startAt: '2026-12-01T01:00:00Z',
          endAt: '2026-12-01T05:00:00Z',
        ),
        initialDemoRequests.first.copyWith(
          id: 'after',
          createdAt: '2026-10-06T17:00:00Z',
        ),
        initialDemoRequests.first.copyWith(id: 'undated', createdAt: null),
      ];
      final container = _container(api);
      final controller = container.read(requestListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      final state = container.read(requestListControllerProvider);
      expect(state.filteredItems.map((item) => item.id), ['first', 'last']);
      expect(state.pendingCount, 2);
      expect(state.createdDateRangeLabel, 'Ngày tạo: 06/09/2026 - 06/10/2026');
      controller.selectDateRange(
        DateTimeRange(start: DateTime(2026, 10, 6), end: DateTime(2026, 10, 6)),
      );
      await controller.refresh();
      expect(
        container
            .read(requestListControllerProvider)
            .filteredItems
            .map((item) => item.id),
        ['last'],
      );
      controller.selectDateRange(null);
      expect(
        container.read(requestListControllerProvider).filteredItems,
        hasLength(5),
      );
      expect(
        container.read(requestListControllerProvider).createdDateRangeLabel,
        'Ngày tạo',
      );
    },
  );

  test('reason-only edit preserves arbitrary persisted timestamps', () async {
    final api = FakeRequestApi();
    api.items = [
      initialDemoRequests.first.copyWith(
        status: 'returned',
        startAt: '2026-10-06T03:00:15.000000Z',
        endAt: '2026-10-06T05:00:25.000000Z',
      ),
    ];
    final container = _container(api);
    container.listen(createLeaveRequestControllerProvider, (_, _) {});
    final controller = container.read(
      createLeaveRequestControllerProvider.notifier,
    );
    await controller.initForRequest('req-1');
    expect(
      container.read(createLeaveRequestControllerProvider).selectedPeriodKey,
      isNull,
    );
    controller.setReason('Lý do mới');
    expect(await controller.submit(), isTrue);
    expect(api.lastDraft!.startAt, '2026-10-06T03:00:15.000000Z');
    expect(api.lastDraft!.endAt, '2026-10-06T05:00:25.000000Z');
    expect(api.balanceDates, contains('2026-10-06'));
  });

  test(
    'changing date clears persisted interval until the new assignment is loaded',
    () async {
      final api = FakeRequestApi();
      api.items = [
        initialDemoRequests.first.copyWith(
          status: 'returned',
          startAt: '2026-10-06T03:00:00Z',
          endAt: '2026-10-06T05:00:00Z',
        ),
      ];
      final container = _container(api);
      container.listen(createLeaveRequestControllerProvider, (_, _) {});
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      await controller.initForRequest('req-1');
      controller.setLeaveDate(DateTime(2026, 10, 7));
      expect(await controller.submit(), isFalse);
      await Future<void>.delayed(Duration.zero);
      controller.setCustomInterval(
        '2026-10-07 10:00:00',
        '2026-10-07 12:00:00',
      );
      expect(await controller.submit(), isTrue);
      expect(api.lastDraft!.startAt, '2026-10-07 10:00:00');
      expect(api.lastDraft!.endAt, '2026-10-07 12:00:00');
      controller.setCustomInterval(
        '2026-10-07 13:30:00',
        '2026-10-07 17:30:00',
      );
      expect(await controller.submit(), isTrue);
      expect(api.lastDraft!.startAt, '2026-10-07 13:30:00');
      expect(api.lastDraft!.endAt, '2026-10-07 17:30:00');
    },
  );

  test(
    'clearing reviewer invalidates both forms and prevents submission',
    () async {
      final api = FakeRequestApi();
      final container = _container(api);
      container.listen(createLeaveRequestControllerProvider, (_, _) {});
      container.listen(createTripRequestControllerProvider, (_, _) {});
      final leave = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      leave.setReviewer('user-huu');
      leave.setLeaveDate(DateTime(2026, 10, 6));
      leave.setReason('Lý do');
      await Future<void>.delayed(Duration.zero);
      leave.setCustomInterval('2026-10-06 08:00:00', '2026-10-06 12:00:00');
      expect(
        container.read(createLeaveRequestControllerProvider).isValid,
        isTrue,
      );
      leave.setReviewer(null);
      expect(
        container.read(createLeaveRequestControllerProvider).reviewerId,
        isNull,
      );
      expect(await leave.submit(), isFalse);
      final trip = container.read(createTripRequestControllerProvider.notifier);
      trip.setReviewer('user-huu');
      trip.setStartDateTime(DateTime(2026, 10, 6, 8));
      trip.setEndDateTime(DateTime(2026, 10, 6, 12));
      trip.setReason('Lý do');
      trip.setAddress('Hà Nội');
      expect(
        container.read(createTripRequestControllerProvider).isValid,
        isTrue,
      );
      trip.setReviewer(null);
      expect(
        container.read(createTripRequestControllerProvider).reviewerId,
        isNull,
      );
      expect(await trip.submit(), isFalse);
      expect(api.mutationCalls, 0);
    },
  );

  for (final fail in [false, true]) {
    test(
      'edit fetch ${fail ? 'failure' : 'success'} after disposal is safe in both controllers',
      () async {
        final api = FakeRequestApi()..detailCompleter = Completer();
        final container = _container(api);
        container.listen(createLeaveRequestControllerProvider, (_, _) {});
        container.listen(createTripRequestControllerProvider, (_, _) {});
        final leave = container
            .read(createLeaveRequestControllerProvider.notifier)
            .initForRequest('req-1');
        final trip = container
            .read(createTripRequestControllerProvider.notifier)
            .initForRequest('req-1');
        container.dispose();
        if (fail) {
          api.detailCompleter!.completeError(StateError('fetch failed'));
        } else {
          api.detailCompleter!.complete(initialDemoRequests.first);
        }
        await Future.wait([leave, trip]);
      },
    );
  }

  test('leave balance follows chosen date and ignores stale replies', () async {
    final api = FakeRequestApi();
    final old = Completer<LeaveBalanceModel>();
    final latest = Completer<LeaveBalanceModel>();
    api.balanceResponses['2026-12-31'] = old;
    api.balanceResponses['2027-01-01'] = latest;
    final container = _container(api);
    container.listen(createLeaveRequestControllerProvider, (_, _) {});
    final controller = container.read(
      createLeaveRequestControllerProvider.notifier,
    );
    await Future<void>.delayed(Duration.zero);
    controller.setLeaveDate(DateTime(2026, 12, 31));
    controller.setLeaveDate(DateTime(2027, 1, 1));
    expect(
      container
          .read(createLeaveRequestControllerProvider)
          .leaveBalance
          .isLoading,
      isTrue,
    );
    latest.complete(const LeaveBalanceModel(entitlement: 12, remaining: 12));
    await Future<void>.delayed(Duration.zero);
    old.complete(const LeaveBalanceModel(entitlement: 10, remaining: 1));
    await Future<void>.delayed(Duration.zero);
    expect(api.balanceDates, containsAllInOrder(['2026-12-31', '2027-01-01']));
    expect(
      container
          .read(createLeaveRequestControllerProvider)
          .leaveBalance
          .requireValue
          .remaining,
      12,
    );
  });

  test(
    'balance failures are exposed as errors, never fabricated zeroes',
    () async {
      final container = _container(
        FakeRequestApi()..fetchError = StateError('offline'),
      );
      container.listen(createLeaveRequestControllerProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      expect(
        container
            .read(createLeaveRequestControllerProvider)
            .leaveBalance
            .hasError,
        isTrue,
      );
    },
  );

  test(
    'list starts empty and rejected mutations return failure without changing items',
    () async {
      final api = FakeRequestApi()..mutationError = StateError('forbidden');
      final container = _container(api);
      expect(container.read(requestListControllerProvider).items, isEmpty);
      await Future<void>.delayed(Duration.zero);
      final original = container.read(requestListControllerProvider).items;
      final controller = container.read(requestListControllerProvider.notifier);
      expect(await controller.approveRequest('req-1'), isFalse);
      expect(await controller.rejectRequest('req-1'), isFalse);
      expect(
        await controller.returnRequest('req-1', note: 'Điều chỉnh'),
        isFalse,
      );
      expect(await controller.cancelRequest('req-1'), isFalse);
      expect(container.read(requestListControllerProvider).items, original);
      expect(
        container.read(requestListControllerProvider).errorMessage,
        isNotNull,
      );
    },
  );

  test('review refresh uses server status and approval timestamp', () async {
    final api = FakeRequestApi();
    final container = _container(api);
    final provider = requestDetailControllerProvider('req-1');
    container.listen(provider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    expect(await container.read(provider.notifier).approve(), isTrue);
    expect(
      container.read(provider).request!.approvedAt,
      '2026-10-06T02:00:00Z',
    );
    expect(container.read(provider).request!.status, 'approved');
  });
}

ProviderContainer _container(FakeRequestApi api, {Clock? clock}) {
  final container = ProviderContainer(
    overrides: [
      clockProvider.overrideWithValue(
        clock ?? Clock.fixed(DateTime.utc(2026, 10, 6, 3)),
      ),
      requestApiProvider.overrideWithValue(api),
      authControllerProvider.overrideWith(_Authenticated.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

class _Authenticated extends AuthController {
  @override
  AuthState build() => const AuthState.authenticated(
    User(
      id: 'user-luong',
      name: 'Hoàng Văn Lượng',
      username: 'luong.hv',
      email: null,
      avatar: null,
      rootOrganizationId: 'org-root',
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
    ),
  );
}

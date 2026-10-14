import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/requests/data/request_api.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/logic/request_formatters.dart';
import 'package:obee_mobile/src/features/requests/state/create_leave_request_controller.dart';

import 'support/fake_request_api.dart';

const nightAssignment = WorkUserShiftModel(
  id: 'assignment',
  rootOrganizationId: 'org-root',
  userId: 'employee',
  workShiftId: 'night',
  workDate: '2026-10-10',
  startAt: '2026-10-10T22:00:00+07:00',
  endAt: '2026-10-11T06:00:00+07:00',
  workShift: WorkShiftModel(
    id: 'night',
    rootOrganizationId: 'org-root',
    name: 'Ca đêm linh động',
    periods: [
      WorkShiftPeriodModel(
        id: 'p1',
        workShiftId: 'night',
        startTime: '22:00:00',
        endTime: '02:00:00',
        startDayOffset: 0,
        endDayOffset: 1,
      ),
      WorkShiftPeriodModel(
        id: 'p2',
        workShiftId: 'night',
        startTime: '03:00:00',
        endTime: '06:00:00',
        startDayOffset: 1,
        endDayOffset: 1,
      ),
    ],
  ),
  workPeriods: [
    AssignedWorkPeriodModel(
      startAt: '2026-10-10T22:00:00+07:00',
      endAt: '2026-10-11T02:00:00+07:00',
    ),
    AssignedWorkPeriodModel(
      startAt: '2026-10-11T03:00:00+07:00',
      endAt: '2026-10-11T06:00:00+07:00',
    ),
  ],
);

void main() {
  test(
    'balance follows the actual start date of a next-day shift period',
    () async {
      final api = FakeRequestApi()..assignedShifts = [nightAssignment];
      final container = _container(api);
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      controller.setLeaveDate(DateTime(2026, 10, 10));
      await Future<void>.delayed(Duration.zero);
      controller.setWorkShift('1');
      await Future<void>.delayed(Duration.zero);
      expect(api.balanceDates.last, '2026-10-11');
      controller.setWorkShift('all');
      await Future<void>.delayed(Duration.zero);
      expect(api.balanceDates.last, '2026-10-10');
    },
  );

  test(
    'custom leave balance uses business time and ignores stale balance responses',
    () async {
      final api = FakeRequestApi();
      final previous = Completer<LeaveBalanceModel>();
      final current = Completer<LeaveBalanceModel>();
      api.balanceResponses['2026-12-31'] = previous;
      api.balanceResponses['2027-01-01'] = current;
      final container = _container(api);
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      await Future<void>.delayed(Duration.zero);
      controller.setCustomInterval(
        '2026-12-31T01:00:00Z',
        '2026-12-31T05:00:00Z',
      );
      controller.setCustomInterval(
        '2026-12-31T23:00:00Z',
        '2027-01-01T05:00:00Z',
      );
      expect(api.balanceDates.last, '2027-01-01');
      current.complete(const LeaveBalanceModel(entitlement: 12, remaining: 12));
      await Future<void>.delayed(Duration.zero);
      previous.complete(const LeaveBalanceModel(entitlement: 12, remaining: 1));
      await Future<void>.delayed(Duration.zero);
      expect(
        container
            .read(createLeaveRequestControllerProvider)
            .leaveBalance
            .requireValue
            .remaining,
        12,
      );
    },
  );

  test('removed draft status fails instead of becoming pending', () {
    expect(() => AbsenceRequestStatus.fromWireValue('draft'), throwsStateError);
  });
  test(
    'UTC morning assignment displays 08:00–12:00 and submits the same instants',
    () async {
      final assignment = nightAssignment.copyWith(
        startAt: '2026-10-10T01:00:00.000000Z',
        endAt: '2026-10-10T05:00:00.000000Z',
        workPeriods: const [
          AssignedWorkPeriodModel(
            startAt: '2026-10-10T01:00:00.000000Z',
            endAt: '2026-10-10T05:00:00.000000Z',
          ),
        ],
      );
      final api = FakeRequestApi()..shiftsHandler = (_) async => [assignment];
      final container = _container(api);
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      controller.setLeaveDate(DateTime(2026, 10, 10));
      await Future<void>.delayed(Duration.zero);
      expect(
        controller.workShiftOptions.first.label,
        contains('08:00 → 12:00'),
      );
      expect(controller.workShiftOptions.last.label, contains('08:00 → 12:00'));
      controller.setWorkShift('0');
      controller.setReviewer('reviewer');
      controller.setReason('Nghỉ buổi sáng');
      final state = container.read(createLeaveRequestControllerProvider);
      expect(
        formatRequestRange(state.startAt, state.endAt),
        '10/10/2026 08:00 - 12:00',
      );
      expect(await controller.submit(), isTrue);
      expect(api.lastDraft!.startAt, assignment.startAt);
      expect(api.lastDraft!.endAt, assignment.endAt);
      expect(api.lastDraft!.toJson()['status'], 'pending');
    },
  );

  test(
    'editing a saved interval remains submittable after assignment failure',
    () async {
      final api = FakeRequestApi()
        ..shiftsHandler = (_) => Future.error(StateError('offline'));
      final request = api.items.first.copyWith(
        status: 'returned',
        startAt: '2026-10-10T23:00:00+07:00',
        endAt: '2026-10-11T01:00:00+07:00',
      );
      api.items = [request];
      final container = _container(api);
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      await controller.initForRequest(request.id);
      controller.setReason('Đổi lý do');
      expect(
        container
            .read(createLeaveRequestControllerProvider)
            .assignedShifts
            .hasError,
        isTrue,
      );
      expect(
        container.read(createLeaveRequestControllerProvider).isValid,
        isTrue,
      );
      expect(await controller.submit(), isTrue);
      expect(api.lastDraft!.startAt, request.startAt);
      expect(api.lastDraft!.endAt, request.endAt);
    },
  );

  test('custom interval survives pending assignment completion', () async {
    final pending = Completer<List<WorkUserShiftModel>>();
    final api = FakeRequestApi()..shiftsHandler = (_) => pending.future;
    final container = _container(api);
    final controller = container.read(
      createLeaveRequestControllerProvider.notifier,
    );
    controller.setLeaveDate(DateTime(2026, 10, 10));
    controller.setCustomInterval(
      '2026-10-10T23:00:00+07:00',
      '2026-10-11T01:00:00+07:00',
    );
    pending.complete([nightAssignment]);
    await Future<void>.delayed(Duration.zero);
    final state = container.read(createLeaveRequestControllerProvider);
    expect(state.isCustomRange, isTrue);
    expect(state.selectedPeriodKey, 'custom');
    expect(state.startAt, '2026-10-10T23:00:00+07:00');
    expect(state.endAt, '2026-10-11T01:00:00+07:00');
  });

  test(
    'valid custom interval submits without selecting an assignment date',
    () async {
      final api = FakeRequestApi();
      final container = _container(api);
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      controller.setReviewer('reviewer');
      controller.setReason('Nghỉ tùy chỉnh');
      controller.setCustomInterval(
        '2026-10-10T23:00:00+07:00',
        '2026-10-11T01:00:00+07:00',
      );
      expect(
        container.read(createLeaveRequestControllerProvider).isValid,
        isTrue,
      );
      expect(await controller.submit(), isTrue);
      expect(api.lastDraft!.startAt, '2026-10-10T23:00:00+07:00');
    },
  );

  for (final failure in [false, true]) {
    test(
      'custom submission ignores assignment ${failure ? "failure" : "loading"}',
      () async {
        final pending = Completer<List<WorkUserShiftModel>>();
        final api = FakeRequestApi()..shiftsHandler = (_) => pending.future;
        final container = _container(api);
        final controller = container.read(
          createLeaveRequestControllerProvider.notifier,
        );
        controller.setReviewer('reviewer');
        controller.setReason('Nghỉ');
        controller.setLeaveDate(DateTime(2026, 10, 10));
        controller.setCustomInterval(
          '2026-10-10T23:00:00+07:00',
          '2026-10-11T01:00:00+07:00',
        );
        if (failure) {
          pending.completeError(StateError('offline'));
          await Future<void>.delayed(Duration.zero);
        }
        expect(
          container.read(createLeaveRequestControllerProvider).isValid,
          isTrue,
        );
        expect(await controller.submit(), isTrue);
        if (!failure) pending.complete([]);
      },
    );
  }
  test(
    'night leave uses assigned whole-shift or period timestamps without fixed-hour defaults',
    () async {
      final api = FakeRequestApi()..assignedShifts = [nightAssignment];
      final container = _container(api);
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      controller.setReviewer('reviewer');
      controller.setReason('Nghỉ ca đêm');
      controller.setLeaveDate(DateTime(2026, 10, 10));
      expect(
        container.read(createLeaveRequestControllerProvider).isValid,
        isFalse,
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.workShiftOptions.map((option) => option.key), [
        'all',
        '0',
        '1',
      ]);
      expect(
        container.read(createLeaveRequestControllerProvider).startAt,
        nightAssignment.startAt,
      );
      expect(
        container.read(createLeaveRequestControllerProvider).endAt,
        nightAssignment.endAt,
      );
      controller.setWorkShift('1');
      expect(await controller.submit(), isTrue);
      expect(api.lastDraft!.startAt, '2026-10-11T03:00:00+07:00');
      expect(api.lastDraft!.endAt, '2026-10-11T06:00:00+07:00');
      final decoded = WorkUserShiftModel.fromJson(nightAssignment.toJson());
      expect(decoded, nightAssignment);
    },
  );

  test(
    'a day without assignment clears selected hours and cannot submit',
    () async {
      final api = FakeRequestApi()..assignedShifts = [nightAssignment];
      final container = _container(api);
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      controller.setReviewer('reviewer');
      controller.setReason('Nghỉ');
      controller.setLeaveDate(DateTime(2026, 10, 10));
      await Future<void>.delayed(Duration.zero);
      controller.setLeaveDate(DateTime(2026, 10, 12));
      await Future<void>.delayed(Duration.zero);
      expect(controller.workShiftOptions, isEmpty);
      expect(
        container.read(createLeaveRequestControllerProvider).startAt,
        isNull,
      );
      expect(await controller.submit(), isFalse);
      expect(api.mutationCalls, 0);
    },
  );

  test(
    'late assignment responses do not restore hours for a previous day',
    () async {
      final old = Completer<List<WorkUserShiftModel>>();
      final current = Completer<List<WorkUserShiftModel>>();
      final api = FakeRequestApi()
        ..shiftsHandler = (date) =>
            date == '2026-10-10' ? old.future : current.future;
      final container = _container(api);
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      controller.setLeaveDate(DateTime(2026, 10, 10));
      controller.setLeaveDate(DateTime(2026, 10, 12));
      current.complete([]);
      await Future<void>.delayed(Duration.zero);
      old.complete([nightAssignment]);
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(createLeaveRequestControllerProvider).leaveDate,
        DateTime(2026, 10, 12),
      );
      expect(controller.workShiftOptions, isEmpty);
      expect(
        container.read(createLeaveRequestControllerProvider).startAt,
        isNull,
      );
    },
  );

  test(
    'assignment failures are surfaced and never create a default shift',
    () async {
      final api = FakeRequestApi()
        ..shiftsHandler = (_) => Future.error(StateError('offline'));
      final container = _container(api);
      final controller = container.read(
        createLeaveRequestControllerProvider.notifier,
      );
      controller.setLeaveDate(DateTime(2026, 10, 10));
      await Future<void>.delayed(Duration.zero);
      expect(
        container
            .read(createLeaveRequestControllerProvider)
            .assignedShifts
            .hasError,
        isTrue,
      );
      expect(controller.workShiftOptions, isEmpty);
      expect(await controller.submit(), isFalse);
    },
  );
}

ProviderContainer _container(FakeRequestApi api) {
  final container = ProviderContainer(
    overrides: [
      requestApiProvider.overrideWithValue(api),
      authControllerProvider.overrideWith(_Auth.new),
    ],
  );
  addTearDown(container.dispose);
  container.listen(createLeaveRequestControllerProvider, (_, _) {});
  return container;
}

class _Auth extends AuthController {
  @override
  AuthState build() => const AuthState.authenticated(
    User(
      id: 'employee',
      name: 'Employee',
      username: 'employee',
      email: null,
      avatar: null,
      rootOrganizationId: 'org-root',
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
    ),
  );
}

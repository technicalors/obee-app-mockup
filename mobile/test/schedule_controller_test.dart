import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/data/organization_ref.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_api.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_controller.dart';
import 'schedule_page_test.dart' show FakeScheduleApi;

void main() {
  test('refreshing edited detail reports missing event occurrences', () async {
    final api = FakeScheduleApi();
    final container = ProviderContainer.test(
      overrides: [
        scheduleApiProvider.overrideWithValue(api),
        authControllerProvider.overrideWith(TestAuth.new),
      ],
    );
    final result = await container
        .read(scheduleControllerProvider.notifier)
        .fetchScheduleDetailAfterUpdate(
          scheduleEventId: 'missing-event',
          occurrenceDate: DateTime(2026, 6, 8),
        );

    expect(result, isNull);
    expect(
      container.read(scheduleControllerProvider).errorMessage,
      'Không thể tải chi tiết lịch trình.',
    );
  });

  test('refreshing edited detail surfaces request failures', () async {
    final api = DelayedScheduleApi();
    final container = ProviderContainer.test(
      overrides: [
        scheduleApiProvider.overrideWithValue(api),
        authControllerProvider.overrideWith(TestAuth.new),
      ],
    );
    final result = container
        .read(scheduleControllerProvider.notifier)
        .fetchScheduleDetailAfterUpdate(
          scheduleEventId: 'event-1',
          occurrenceDate: DateTime(2026, 6, 8),
        );
    api.requests.single.completeError(StateError('network failed'));

    expect(await result, isNull);
    expect(
      container.read(scheduleControllerProvider).errorMessage,
      'Không thể tải chi tiết lịch trình.',
    );
  });

  test(
    'organization changes discard users from an older root request',
    () async {
      final api = DelayedUserScheduleApi();
      final container = ProviderContainer(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(OrganizationAuth.new),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(scheduleControllerProvider.notifier);
      final initial = controller.initialize(now: DateTime(2026, 10, 2));
      expect(api.requests.single.rootId, 'root-a');
      await controller.setSelectedUser('old-colleague');
      container
          .read(authControllerProvider.notifier)
          .replaceAuthenticatedUser(_organizationUser('root-b'));
      expect(api.requests.last.rootId, 'root-b');
      expect(container.read(scheduleControllerProvider).selectedUserId, 'u');
      expect(container.read(scheduleControllerProvider).users, isEmpty);
      final colleague = UserTreeSelectionUser(
        id: 'new-colleague',
        name: 'Colleague',
        username: 'colleague',
        organizationId: 'root-b',
        organization: _organizationUser('root-b').organization!,
        profile: null,
      );
      api.requests.last.result.complete([colleague]);
      await Future<void>.delayed(Duration.zero);
      api.requests.first.result.completeError(StateError('old root failed'));
      await initial;
      final state = container.read(scheduleControllerProvider);
      expect(state.users, [colleague]);
      expect(state.errorMessage, null);
      expect(state.isUsersLoading, false);

      final refreshed = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(api.requests.last.rootId, 'root-b');
      expect(api.requests, hasLength(3));
      api.requests.last.result.complete([]);
      await refreshed;
      expect(container.read(scheduleControllerProvider).users, isEmpty);
    },
  );

  test(
    'removing an organization clears selection users and skips tree requests',
    () async {
      final api = DelayedUserScheduleApi();
      final container = ProviderContainer(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(OrganizationAuth.new),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(scheduleControllerProvider.notifier);
      final initial = controller.initialize(now: DateTime(2026, 10, 2));
      api.requests.single.result.complete([
        UserTreeSelectionUser(
          id: 'colleague',
          name: 'Colleague',
          username: 'colleague',
          organizationId: 'root-a',
          organization: _organizationUser('root-a').organization!,
          profile: null,
        ),
      ]);
      await initial;
      expect(container.read(scheduleControllerProvider).users, hasLength(1));
      container
          .read(authControllerProvider.notifier)
          .replaceAuthenticatedUser(
            _organizationUser('root-a').copyWith(
              organization: null,
              organizationId: null,
              rootOrganizationId: null,
            ),
          );
      await Future<void>.delayed(Duration.zero);
      expect(container.read(scheduleControllerProvider).users, isEmpty);
      expect(container.read(scheduleControllerProvider).isUsersLoading, false);
      expect(api.requests, hasLength(1));
    },
  );

  test(
    'new calendar request cancels prior request and ignores its late failure',
    () async {
      final api = DelayedScheduleApi();
      final container = ProviderContainer(
        overrides: [
          scheduleApiProvider.overrideWithValue(api),
          authControllerProvider.overrideWith(TestAuth.new),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(scheduleControllerProvider.notifier);
      final initial = controller.initialize(now: DateTime(2026, 10, 2));
      final changed = controller.changeMonth(DateTime(2026, 11));
      expect(api.cancellations.first!.isCancelled, true);
      api.requests.last.complete([]);
      await changed;
      api.requests.first.completeError(StateError('old request failed'));
      await initial;
      final state = container.read(scheduleControllerProvider);
      expect(state.month, DateTime(2026, 11));
      expect(state.errorMessage, null);
      expect(state.isLoading, false);
    },
  );
}

User _organizationUser(String rootId) => User(
  id: 'u',
  name: 'User',
  username: 'user',
  email: null,
  avatar: null,
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
  organizationId: rootId,
  rootOrganizationId: rootId,
  organization: OrganizationRef(
    id: rootId,
    name: rootId,
    type: 'Công ty',
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
  ),
);

class OrganizationAuth extends AuthController {
  @override
  AuthState build() => AuthState.authenticated(_organizationUser('root-a'));

  @override
  Future<void> refreshCurrentUser() async {}
}

class DelayedUserScheduleApi extends FakeScheduleApi {
  final requests =
      <({String rootId, Completer<List<UserTreeSelectionUser>> result})>[];

  @override
  Future<List<UserTreeSelectionUser>> fetchUsers({
    required String rootOrganizationId,
  }) {
    final result = Completer<List<UserTreeSelectionUser>>();
    requests.add((rootId: rootOrganizationId, result: result));
    return result.future;
  }
}

class TestAuth extends AuthController {
  @override
  AuthState build() => const AuthState.authenticated(
    User(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'u',
      name: 'User',
      username: 'user',
      email: null,
      avatar: null,
    ),
  );
}

class DelayedScheduleApi extends FakeScheduleApi {
  final requests = <Completer<List<ScheduleModel>>>[];
  final cancellations = <CancelToken?>[];
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
  }) {
    final result = Completer<List<ScheduleModel>>();
    requests.add(result);
    cancellations.add(cancelToken);
    return result.future;
  }
}

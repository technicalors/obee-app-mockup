import 'dart:async';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';
import 'package:obee_mobile/src/features/chat/state/direct_chat_search_provider.dart';
import 'package:obee_mobile/src/core/session/session_events.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_api.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_controller.dart';

import 'schedule_page_test.dart' show FakeScheduleApi;

void main() {
  for (final action in ['logout', 'login', 'expiration']) {
    test(
      '$action completes while schedule watches the authenticated session',
      () async {
        final storage = MemoryTokenStorage('saved-token');
        final container = ProviderContainer(
          overrides: [
            authApiProvider.overrideWithValue(FakeAuthApi()),
            tokenStorageProvider.overrideWithValue(storage),
            scheduleApiProvider.overrideWithValue(FakeScheduleApi()),
          ],
        );
        addTearDown(container.dispose);
        final controller = container.read(authControllerProvider.notifier);
        await controller.retryRestore();
        container.listen(scheduleControllerProvider, (_, _) {});

        switch (action) {
          case 'logout':
            await controller.logout();
          case 'login':
            await controller.login(email: 'admin', password: 'password');
          case 'expiration':
            container
                .read(sessionEventsProvider)
                .add(const SessionEvent.expired('saved-token'));
            await pumpEventQueue();
        }

        expect(storage.token, action == 'login' ? 'token-1' : null);
        expect(controller.accessToken, storage.token);
        expect(
          container.read(authControllerProvider).isAuthenticated,
          action == 'login',
        );
        expect(
          container.read(authControllerProvider).errorMessage,
          action == 'expiration' ? 'Phiên đăng nhập đã hết hiệu lực.' : null,
        );
      },
    );
  }

  test(
    'logout reports a real token deletion failure and retains the session',
    () async {
      final storage = MemoryTokenStorage('saved-token');
      final container = createContainer(api: FakeAuthApi(), storage: storage);
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.retryRestore();
      storage.clearError = StateError('Keystore unavailable');

      await controller.logout();

      expect(storage.token, 'saved-token');
      expect(controller.accessToken, 'saved-token');
      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, true);
      expect(state.isLoading, false);
      expect(
        state.errorMessage,
        'Không thể xóa phiên đăng nhập trên thiết bị.',
      );
    },
  );

  test(
    'network failure during restore retains token and allows retry',
    () async {
      final api = FakeAuthApi(
        restoreError: DioException(
          requestOptions: RequestOptions(path: '/mobile/auth/user'),
        ),
      );
      final storage = MemoryTokenStorage('saved-token');
      final container = createContainer(api: api, storage: storage);
      addTearDown(container.dispose);
      container.read(authControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(authControllerProvider).restoreFailed, true);
      expect(storage.token, 'saved-token');
      api.restoreError = null;
      await container.read(authControllerProvider.notifier).retryRestore();
      expect(container.read(authControllerProvider).isAuthenticated, true);
    },
  );

  test('401 from expired token cannot terminate a newer session', () async {
    final storage = MemoryTokenStorage('previous-token');
    final container = createContainer(api: FakeAuthApi(), storage: storage);
    addTearDown(container.dispose);
    container.read(authControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await container
        .read(authControllerProvider.notifier)
        .login(email: 'admin', password: 'password');
    container
        .read(sessionEventsProvider)
        .add(const SessionEvent.expired('previous-token'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(container.read(authControllerProvider).isAuthenticated, true);
    expect(storage.token, 'token-1');
    container
        .read(sessionEventsProvider)
        .add(const SessionEvent.expired('token-1'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(container.read(authControllerProvider).isAuthenticated, false);
    expect(storage.token, null);
  });

  test(
    'storage failure terminates login loading and reports failure',
    () async {
      final container = createContainer(
        api: FakeAuthApi(),
        storage: FailingTokenStorage(),
      );
      addTearDown(container.dispose);
      await container
          .read(authControllerProvider.notifier)
          .login(email: 'admin', password: 'password');
      final state = container.read(authControllerProvider);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.errorMessage, isNotNull);
    },
  );

  test(
    'new session resets feature search and replaces cached repository',
    () async {
      final container = createContainer(
        api: FakeAuthApi(),
        storage: MemoryTokenStorage(),
      );
      addTearDown(container.dispose);
      final repository = container.read(chatRepositoryProvider);
      container
          .read(directChatSearchProvider.notifier)
          .updateQuery('previous employee');
      await container
          .read(authControllerProvider.notifier)
          .login(email: 'admin', password: 'password');
      expect(container.read(directChatSearchProvider), '');
      expect(
        identical(container.read(chatRepositoryProvider), repository),
        false,
      );
      container
          .read(directChatSearchProvider.notifier)
          .updateQuery('private query');
      await container.read(authControllerProvider.notifier).logout();
      expect(container.read(directChatSearchProvider), '');
    },
  );

  test('login stores token and authenticates user', () async {
    final api = FakeAuthApi();
    final storage = MemoryTokenStorage();
    final container = createContainer(api: api, storage: storage);

    addTearDown(container.dispose);

    await container
        .read(authControllerProvider.notifier)
        .login(email: 'admin', password: 'password');

    final state = container.read(authControllerProvider);

    expect(state.isAuthenticated, true);
    expect(state.user?.email, 'admin@example.com');
    expect(await storage.readToken(), 'token-1');
  });

  test('restore clears an invalid stored token', () async {
    final api = FakeAuthApi(restoreError: unauthorizedError());
    final storage = MemoryTokenStorage('stale-token');
    final container = createContainer(api: api, storage: storage);

    addTearDown(container.dispose);

    container.read(authControllerProvider);
    await waitFor(() async => storage.readToken(), null);

    final state = container.read(authControllerProvider);

    expect(state.isAuthenticated, false);
    expect(await storage.readToken(), null);
  });

  test(
    'refresh applies grants and revocations without changing session',
    () async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage('saved-token');
      final container = createContainer(api: api, storage: storage);
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.retryRestore();
      final repository = container.read(chatRepositoryProvider);

      api.user = api.user.copyWith(
        roles: [basicRole],
        permissions: [createSchedulePermission],
      );
      await controller.refreshCurrentUser();
      expect(container.read(authControllerProvider).user!.roles, [basicRole]);
      expect(container.read(authControllerProvider).user!.permissions, [
        createSchedulePermission,
      ]);

      api.user = api.user.copyWith(roles: [], permissions: []);
      await controller.refreshCurrentUser();
      expect(container.read(authControllerProvider).user!.roles, isEmpty);
      expect(container.read(authControllerProvider).user!.permissions, isEmpty);
      expect(storage.token, 'saved-token');
      expect(container.read(chatRepositoryProvider), same(repository));
    },
  );

  test(
    'concurrent refreshes share a request and preserve visible user',
    () async {
      final api = FakeAuthApi();
      final container = createContainer(
        api: api,
        storage: MemoryTokenStorage('saved-token'),
      );
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.retryRestore();
      final previousCalls = api.currentUserCalls;
      final pending = Completer<User>();
      api.pendingUser = pending;

      final first = controller.refreshCurrentUser();
      final second = controller.refreshCurrentUser();
      expect(api.currentUserCalls, previousCalls + 1);
      expect(container.read(authControllerProvider).user, api.user);
      expect(container.read(authControllerProvider).isRestoring, false);
      pending.complete(
        api.user.copyWith(permissions: [createSchedulePermission]),
      );
      await Future.wait([first, second]);
      expect(container.read(authControllerProvider).user!.permissions, [
        createSchedulePermission,
      ]);
    },
  );

  test(
    'late refresh cannot overwrite a new login or block its refresh',
    () async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage('saved-token');
      final container = createContainer(api: api, storage: storage);
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.retryRestore();
      final oldUser = api.user;
      final pending = Completer<User>();
      api.pendingUser = pending;
      final oldRefresh = controller.refreshCurrentUser();

      await controller.logout();
      api.user = api.user.copyWith(id: 'user-2', username: 'new-user');
      await controller.login(email: 'new-user', password: 'password');
      api.user = api.user.copyWith(permissions: [createSchedulePermission]);
      await controller.refreshCurrentUser();
      pending.complete(oldUser);
      await oldRefresh;
      expect(container.read(authControllerProvider).user, api.user);
      expect(storage.token, 'token-1');
    },
  );

  test('late refresh cannot overwrite a saved profile snapshot', () async {
    final api = FakeAuthApi();
    final container = createContainer(
      api: api,
      storage: MemoryTokenStorage('saved-token'),
    );
    addTearDown(container.dispose);
    final controller = container.read(authControllerProvider.notifier);
    await controller.retryRestore();
    final pending = Completer<User>();
    api.pendingUser = pending;
    final refresh = controller.refreshCurrentUser();
    final updatedUser = api.user.copyWith(name: 'Updated profile');
    controller.replaceAuthenticatedUser(updatedUser);
    pending.complete(api.user);
    await refresh;
    expect(container.read(authControllerProvider).user, updatedUser);
  });

  test(
    'refresh failure retains session and reports error until retry',
    () async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage('saved-token');
      final container = createContainer(api: api, storage: storage);
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.retryRestore();
      api.restoreError = DioException(
        requestOptions: RequestOptions(path: '/mobile/auth/user'),
      );
      await controller.refreshCurrentUser();
      expect(container.read(authControllerProvider).user, api.user);
      expect(container.read(authControllerProvider).errorMessage, isNotNull);
      expect(storage.token, 'saved-token');

      api.restoreError = null;
      await controller.refreshCurrentUser();
      expect(container.read(authControllerProvider).errorMessage, isNull);
    },
  );

  test('401 during refresh expires the session', () async {
    final api = FakeAuthApi();
    final storage = MemoryTokenStorage('saved-token');
    final container = createContainer(api: api, storage: storage);
    addTearDown(container.dispose);
    final controller = container.read(authControllerProvider.notifier);
    await controller.retryRestore();
    api.restoreError = unauthorizedError();
    await controller.refreshCurrentUser();
    expect(container.read(authControllerProvider).isAuthenticated, false);
    expect(storage.token, null);
  });

  test('expiration clears storage before rebuilding feature state', () async {
    final api = FakeAuthApi();
    final storage = DelayedClearTokenStorage('saved-token');
    final container = createContainer(api: api, storage: storage);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.notifier).retryRestore();
    container
        .read(directChatSearchProvider.notifier)
        .updateQuery('private query');
    final tokensAtReset = <String?>[];
    container.listen(directChatSearchProvider, (_, next) {
      if (next.isEmpty) tokensAtReset.add(storage.token);
    });

    container
        .read(sessionEventsProvider)
        .add(const SessionEvent.expired('saved-token'));
    await storage.clearStarted.future;
    container
        .read(sessionEventsProvider)
        .add(const SessionEvent.expired('saved-token'));
    await pumpEventQueue();
    expect(storage.clearCalls, 1);
    expect(tokensAtReset, isEmpty);

    storage.allowClear.complete();
    await pumpEventQueue();
    expect(storage.token, isNull);
    expect(container.read(directChatSearchProvider), isEmpty);
    expect(tokensAtReset, [null]);
    expect(container.read(authControllerProvider).user, isNull);
  });

  test('403 from an old token cannot refresh a newer session', () async {
    final api = FakeAuthApi();
    final container = createContainer(
      api: api,
      storage: MemoryTokenStorage('saved-token'),
    );
    addTearDown(container.dispose);
    final controller = container.read(authControllerProvider.notifier);
    await controller.retryRestore();
    await controller.login(email: 'admin', password: 'password');
    final previousCalls = api.currentUserCalls;
    container
        .read(sessionEventsProvider)
        .add(const SessionEvent.authorizationDenied('saved-token'));
    await pumpEventQueue();
    expect(api.currentUserCalls, previousCalls);
  });
}

const basicRole = RoleRef(
  id: 'role-basic',
  name: 'basic',
  description: null,
  createdAt: null,
  updatedAt: null,
);

const createSchedulePermission = PermissionRef(
  id: 'permission-create-schedule',
  name: 'schedule-events.create',
  description: null,
  createdAt: null,
  updatedAt: null,
);

Future<void> waitFor<T>(Future<T> Function() read, T expected) async {
  for (var attempt = 0; attempt < 20; attempt += 1) {
    if (await read() == expected) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

ProviderContainer createContainer({
  required AuthApi api,
  required TokenStorage storage,
}) {
  return ProviderContainer(
    overrides: [
      authApiProvider.overrideWithValue(api),
      tokenStorageProvider.overrideWithValue(storage),
    ],
  );
}

class FakeAuthApi implements AuthApi {
  FakeAuthApi({this.restoreError});

  DioException? restoreError;
  Completer<User>? pendingUser;
  int currentUserCalls = 0;
  User user = const User(
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
    id: 'user-1',
    name: 'Admin User',
    username: 'admin',
    email: 'admin@example.com',
    avatar: null,
    permissions: [],
  );

  @override
  Future<User> currentUser() async {
    currentUserCalls += 1;
    final pending = pendingUser;
    pendingUser = null;
    if (pending != null) return pending.future;
    if (restoreError != null) {
      throw restoreError!;
    }

    return user;
  }

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    return LoginResult(accessToken: 'token-1', tokenType: 'Bearer', user: user);
  }

  @override
  Future<void> logout() async {}
}

class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage([this.token]);

  String? token;
  Object? clearError;

  @override
  Future<void> clearToken() async {
    if (clearError != null) throw clearError!;
    token = null;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String token) async {
    this.token = token;
  }
}

DioException unauthorizedError() {
  return DioException(
    requestOptions: RequestOptions(path: '/mobile/auth/user'),
    response: Response<Object?>(
      requestOptions: RequestOptions(path: '/mobile/auth/user'),
      statusCode: 401,
    ),
  );
}

class FailingTokenStorage extends MemoryTokenStorage {
  @override
  Future<void> writeToken(String token) async =>
      throw StateError('Keystore unavailable');
}

class DelayedClearTokenStorage implements TokenStorage {
  DelayedClearTokenStorage(this.token);

  String? token;
  int clearCalls = 0;
  final clearStarted = Completer<void>();
  final allowClear = Completer<void>();

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String token) async {
    this.token = token;
  }

  @override
  Future<void> clearToken() async {
    clearCalls += 1;
    clearStarted.complete();
    await allowClear.future;
    token = null;
  }
}

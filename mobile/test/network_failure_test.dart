import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/core/session/session_events.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';
import 'package:obee_mobile/src/features/chat/state/direct_chat_search_provider.dart';
import 'auth_controller_test.dart'
    show MemoryTokenStorage, FakeAuthApi, createSchedulePermission;

void main() {
  test(
    'real auth provider graph restores and dispatches bearer requests',
    () async {
      final container = setup(MemoryTokenStorage('saved-token'));
      addTearDown(container.dispose);
      final adapter = ReplyAdapter(
        ResponseBody.fromString(
          jsonEncode(FakeAuthApi().user.toJson()),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        ),
      );
      container.read(dioProvider).httpClientAdapter = adapter;
      container.read(authControllerProvider);
      await pumpEventQueue();
      expect(container.read(authControllerProvider).isAuthenticated, true);
      expect(adapter.lastRequest.path, '/mobile/auth/user');
      expect(
        adapter.lastRequest.headers['Authorization'],
        'Bearer saved-token',
      );
      expect(adapter.fetchCount, 1);
      for (final path in ['/schedules', '/attendance/context']) {
        final featureAdapter = ReplyAdapter(ResponseBody.fromString('{}', 200));
        container.read(dioProvider).httpClientAdapter = featureAdapter;
        await container.read(apiClientProvider).get<Object>(path);
        expect(featureAdapter.lastRequest.path, path);
        expect(
          featureAdapter.lastRequest.headers['Authorization'],
          'Bearer saved-token',
        );
        expect(featureAdapter.fetchCount, 1);
      }
    },
  );

  test('real login graph uses the new token for feature requests', () async {
    final storage = MemoryTokenStorage();
    final container = setup(storage);
    addTearDown(container.dispose);
    final loginAdapter = ReplyAdapter(
      ResponseBody.fromString(
        jsonEncode({
          'access_token': 'login-token',
          'token_type': 'Bearer',
          'user': FakeAuthApi().user.toJson(),
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
    container.read(dioProvider).httpClientAdapter = loginAdapter;
    final controller = container.read(authControllerProvider.notifier);
    await pumpEventQueue();
    await controller.login(email: 'admin', password: 'password');
    expect(container.read(authControllerProvider).isAuthenticated, true);
    expect(
      loginAdapter.lastRequest.headers.containsKey('Authorization'),
      false,
    );
    expect(storage.token, 'login-token');
    for (final path in ['/schedules', '/attendance/context']) {
      final featureAdapter = ReplyAdapter(ResponseBody.fromString('{}', 200));
      container.read(dioProvider).httpClientAdapter = featureAdapter;
      await container.read(apiClientProvider).get<Object>(path);
      expect(featureAdapter.lastRequest.path, path);
      expect(
        featureAdapter.lastRequest.headers['Authorization'],
        'Bearer login-token',
      );
      expect(featureAdapter.fetchCount, 1);
    }
  });

  for (final contentType in ['application/json', 'application/problem+json']) {
    test('401 $contentType clears the current session and cached data', () async {
      final storage = MemoryTokenStorage('expired-token');
      final container = setup(storage, authApi: FakeAuthApi());
      addTearDown(container.dispose);
      await container.read(authControllerProvider.notifier).retryRestore();
      final repository = container.read(chatRepositoryProvider);
      container
          .read(directChatSearchProvider.notifier)
          .updateQuery('private query');
      final adapter = ReplyAdapter(
        ResponseBody.fromString(
          contentType == 'application/json'
              ? '{"message":"Unauthenticated."}'
              : '{"type":"about:blank","title":"Unauthenticated","status":401,"detail":"Unauthenticated."}',
          401,
          headers: {
            Headers.contentTypeHeader: [contentType],
          },
        ),
      );
      container.read(dioProvider).httpClientAdapter = adapter;

      await expectLater(
        container.read(apiClientProvider).get<Object>('/attendance/logs'),
        throwsA(isA<DioException>()),
      );
      await pumpEventQueue();

      final auth = container.read(authControllerProvider);
      expect(auth.user, isNull);
      expect(auth.isAuthenticated, false);
      expect(auth.restoreFailed, false);
      expect(auth.errorMessage, 'Phiên đăng nhập đã hết hiệu lực.');
      expect(storage.token, isNull);
      expect(container.read(directChatSearchProvider), isEmpty);
      expect(container.read(chatRepositoryProvider), isNot(same(repository)));
      expect(adapter.fetchCount, 1);
      expect(
        adapter.lastRequest.headers['Authorization'],
        'Bearer expired-token',
      );
    });
  }

  test(
    '401 logs out even when secure storage cannot delete the token',
    () async {
      final storage = UndeletableStorage('expired-token');
      final container = setup(storage, authApi: FakeAuthApi());
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.retryRestore();
      container
          .read(directChatSearchProvider.notifier)
          .updateQuery('private query');
      final adapter = ReplyAdapter(
        ResponseBody.fromString('{"message":"Unauthenticated."}', 401),
      );
      container.read(dioProvider).httpClientAdapter = adapter;

      await expectLater(
        container.read(apiClientProvider).get<Object>('/attendance/logs'),
        throwsA(isA<DioException>()),
      );
      await pumpEventQueue();
      final auth = container.read(authControllerProvider);
      expect(auth.isAuthenticated, false);
      expect(auth.restoreFailed, false);
      expect(auth.errorMessage, 'Phiên đăng nhập đã hết hiệu lực.');
      expect(controller.accessToken, isNull);
      expect(storage.token, 'expired-token');
      expect(container.read(directChatSearchProvider), isEmpty);

      // The failed native deletion must not put the rejected token on a request.
      await expectLater(
        container.read(apiClientProvider).get<Object>('/attendance/logs'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.lastRequest.headers.containsKey('Authorization'), false);

      await controller.login(email: 'admin', password: 'password');
      expect(container.read(authControllerProvider).isAuthenticated, true);
      expect(storage.token, 'token-1');
      await expectLater(
        container.read(apiClientProvider).get<Object>('/attendance/logs'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.lastRequest.headers['Authorization'], 'Bearer token-1');
    },
  );

  test('401 from login does not expire an existing session token', () async {
    final storage = MemoryTokenStorage('current-token');
    final container = setup(storage, authApi: FakeAuthApi());
    addTearDown(container.dispose);
    await container.read(authControllerProvider.notifier).retryRestore();
    final adapter = ReplyAdapter(
      ResponseBody.fromString('{"message":"Unauthenticated."}', 401),
    );
    container.read(dioProvider).httpClientAdapter = adapter;

    await expectLater(
      container.read(apiClientProvider).post<Object>('/mobile/auth/login'),
      throwsA(isA<DioException>()),
    );
    await pumpEventQueue();
    expect(adapter.lastRequest.headers.containsKey('Authorization'), false);
    expect(storage.token, 'current-token');
    expect(container.read(authControllerProvider).isAuthenticated, true);
  });

  test(
    'malformed problem response rejects instead of leaving request pending',
    () async {
      final container = setup(
        MemoryTokenStorage('token'),
        authApi: FakeAuthApi(),
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.notifier).retryRestore();
      final dio = container.read(dioProvider);
      dio.httpClientAdapter = ReplyAdapter(
        ResponseBody.fromString(
          '{"type":"about:blank","title":"Invalid","status":422,"detail":"Invalid","errors":{"name":"bad"}}',
          422,
          headers: {
            Headers.contentTypeHeader: ['application/problem+json'],
          },
        ),
      );
      await expectLater(
        container
            .read(apiClientProvider)
            .get<Object>('/profile')
            .timeout(const Duration(seconds: 2)),
        throwsA(isA<DioException>()),
      );
    },
  );
  test('secure storage read error rejects before network dispatch', () async {
    final container = setup(UnreadableStorage());
    addTearDown(container.dispose);
    await container.read(authControllerProvider.notifier).retryRestore();
    final adapter = ReplyAdapter(ResponseBody.fromString('{}', 200));
    container.read(dioProvider).httpClientAdapter = adapter;
    await expectLater(
      container
          .read(apiClientProvider)
          .get<Object>('/profile')
          .timeout(const Duration(seconds: 2)),
      throwsA(isA<DioException>()),
    );
    expect(adapter.fetchCount, 0);
  });
  test('required-body requests reject empty 204 responses', () async {
    final dio = Dio();
    dio.httpClientAdapter = ReplyAdapter(ResponseBody.fromString('', 204));
    addTearDown(dio.close);
    await expectLater(
      ApiClient(dio).get<Object>('/profile'),
      throwsFormatException,
    );
  });

  test(
    '403 refreshes permissions and preserves the rejected operation',
    () async {
      final api = FakeAuthApi();
      final storage = MemoryTokenStorage('token');
      final container = setup(storage, authApi: api);
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      await controller.retryRestore();
      api.user = api.user.copyWith(permissions: [createSchedulePermission]);
      final previousCalls = api.currentUserCalls;
      final adapter = ReplyAdapter(ResponseBody.fromString('{}', 403));
      container.read(dioProvider).httpClientAdapter = adapter;

      await expectLater(
        container.read(apiClientProvider).post<Object>('/schedule-events'),
        throwsA(isA<DioException>()),
      );
      await pumpEventQueue();
      expect(api.currentUserCalls, previousCalls + 1);
      expect(container.read(authControllerProvider).user!.permissions, [
        createSchedulePermission,
      ]);
      expect(storage.token, 'token');
      expect(adapter.fetchCount, 1);
      expect(adapter.lastRequest.headers['Authorization'], 'Bearer token');
    },
  );

  test('403 from snapshot endpoint does not trigger a refresh loop', () async {
    final container = setup(
      MemoryTokenStorage('token'),
      authApi: FakeAuthApi(),
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.notifier).retryRestore();
    final events = <SessionEvent>[];
    final subscription = container
        .read(sessionEventsProvider)
        .stream
        .listen(events.add);
    addTearDown(subscription.cancel);
    container.read(dioProvider).httpClientAdapter = ReplyAdapter(
      ResponseBody.fromString('{}', 403),
    );
    await expectLater(
      container.read(apiClientProvider).get<Object>('/mobile/auth/user'),
      throwsA(isA<DioException>()),
    );
    await pumpEventQueue();
    expect(events, isEmpty);
  });
}

ProviderContainer setup(TokenStorage storage, {AuthApi? authApi}) =>
    ProviderContainer(
      overrides: [
        if (authApi != null) authApiProvider.overrideWithValue(authApi),
        tokenStorageProvider.overrideWithValue(storage),
        appConfigProvider.overrideWithValue(
          AppConfig.parse(
            apiBaseUrl: 'https://obee.test/api',
            appBaseUrl: 'https://obee.test',
          ),
        ),
      ],
    );

class UnreadableStorage extends MemoryTokenStorage {
  @override
  Future<String?> readToken() async => throw StateError('Keystore error');
}

class UndeletableStorage extends MemoryTokenStorage {
  UndeletableStorage(super.token);

  @override
  Future<void> clearToken() async => throw StateError('Keystore error');
}

class ReplyAdapter implements HttpClientAdapter {
  ReplyAdapter(this.response);
  final ResponseBody response;
  int fetchCount = 0;
  late RequestOptions lastRequest;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCount += 1;
    lastRequest = options;
    return response;
  }

  @override
  void close({bool force = false}) {}
}

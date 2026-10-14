import 'dart:async';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/network/api_problem.dart';
import 'package:obee_mobile/src/core/session/session_events.dart';
import 'package:obee_mobile/src/core/session/session_credentials.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/attendance/state/attendance_controller.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_controller.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_form_controller.dart';
import 'package:obee_mobile/src/features/profile/state/profile_controller.dart';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';
import 'package:obee_mobile/src/features/chat/state/chat_hub_provider.dart';
import 'package:obee_mobile/src/features/chat/state/direct_chat_search_provider.dart';
import 'package:obee_mobile/src/features/chat/state/new_direct_chat_provider.dart';
import 'package:obee_mobile/src/features/chat/state/group_creation_preview_provider.dart';
import 'package:obee_mobile/src/features/requests/state/request_list_controller.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late AuthApi _authApi;
  late TokenStorage _tokenStorage;
  late SessionCredentials _credentials;
  int _operation = 0;
  int _userRevision = 0;
  ({int operation, Future<void> future})? _userRefresh;

  // Requests use the live session, never a persisted token already rejected
  // by the server. Secure storage is only read when restoring a session.
  String? get accessToken => _credentials.token;

  @override
  AuthState build() {
    _credentials = ref.watch(sessionCredentialsProvider);
    _authApi = ref.watch(authApiProvider);
    _tokenStorage = ref.watch(tokenStorageProvider);
    final subscription = ref.read(sessionEventsProvider).stream.listen((event) {
      switch (event.type) {
        case SessionEventType.expired:
          unawaited(_expireSession(event.token));
        case SessionEventType.authorizationDenied:
          if (event.token == _credentials.token) {
            unawaited(refreshCurrentUser());
          }
      }
    });
    ref.onDispose(subscription.cancel);
    unawaited(_restore());
    return const AuthState.loading();
  }

  void replaceAuthenticatedUser(User user) {
    _userRevision += 1;
    state = AuthState.authenticated(user);
  }

  Future<void> retryRestore() => _restore();

  Future<void> refreshCurrentUser() async {
    if (!state.isAuthenticated ||
        state.isLoading ||
        _credentials.token == null) {
      return;
    }
    final operation = _operation;
    final pending = _userRefresh;
    if (pending != null && pending.operation == operation) {
      await pending.future;
      return;
    }

    final refresh = _refreshCurrentUser(
      operation: operation,
      revision: _userRevision,
      token: _credentials.token!,
    );
    _userRefresh = (operation: operation, future: refresh);
    try {
      await refresh;
    } finally {
      if (identical(_userRefresh?.future, refresh)) {
        _userRefresh = null;
      }
    }
  }

  Future<void> _refreshCurrentUser({
    required int operation,
    required int revision,
    required String token,
  }) async {
    try {
      final user = await _authApi.currentUser();
      if (!ref.mounted ||
          operation != _operation ||
          token != _credentials.token) {
        return;
      }
      if (revision != _userRevision) return;
      if (user.id != state.user!.id) {
        throw const FormatException(
          'Authenticated user identity changed during refresh.',
        );
      }
      state = AuthState.authenticated(user);
    } catch (error) {
      if (!ref.mounted ||
          operation != _operation ||
          token != _credentials.token) {
        return;
      }
      if (error is DioException && error.response?.statusCode == 401) {
        await _expireSession(token);
      } else if (revision == _userRevision) {
        state = state.copyWith(errorMessage: _messageForError(error));
      }
    }
  }

  Future<void> login({required String email, required String password}) async {
    final operation = ++_operation;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _authApi.login(
        email: email,
        password: password,
        deviceName: 'Obee ${defaultTargetPlatform.name}',
      );
      if (!ref.mounted || operation != _operation) return;
      if (result.tokenType != 'Bearer') {
        throw const FormatException('Token type contract is invalid.');
      }
      await _tokenStorage.writeToken(result.accessToken);
      if (!ref.mounted || operation != _operation) return;
      _credentials.restore(result.accessToken);
      _resetFeatureState();
      state = AuthState.authenticated(result.user);
    } catch (error) {
      if (!ref.mounted || operation != _operation) return;
      state = AuthState.unauthenticated(_messageForError(error));
    }
  }

  Future<void> logout() async {
    final operation = ++_operation;
    state = state.copyWith(isLoading: true, errorMessage: null);
    Object? failure;
    try {
      await _authApi.logout();
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) failure = error;
    } catch (error) {
      failure = error;
    }
    if (!ref.mounted || operation != _operation) return;
    try {
      await _tokenStorage.clearToken();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to delete the session from secure storage during logout.',
        name: 'obee.auth',
        error: error,
        stackTrace: stackTrace,
      );
      if (ref.mounted && operation == _operation) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể xóa phiên đăng nhập trên thiết bị.',
        );
      }
      return;
    }
    if (!ref.mounted || operation != _operation) return;
    _credentials.restore(null);
    _resetFeatureState();
    state = AuthState.unauthenticated(
      failure == null
          ? null
          : 'Đã đăng xuất trên thiết bị. Không thể thu hồi phiên trên máy chủ; phiên sẽ hết hạn theo thời gian quy định.',
    );
  }

  Future<void> _restore() async {
    final operation = ++_operation;
    _credentials.beginRestore();
    // The first await ensures build() has installed the initial state.
    try {
      final token = await _tokenStorage.readToken();
      if (!ref.mounted || operation != _operation) return;
      _credentials.restore(token);
      if (token == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      state = const AuthState.loading();
      final user = await _authApi.currentUser();
      if (!ref.mounted || operation != _operation) return;
      state = AuthState.authenticated(user);
    } catch (error) {
      if (!ref.mounted || operation != _operation) return;
      if (error is DioException && error.response?.statusCode == 401) {
        final token = _credentials.token;
        if (token != null) await _expireSession(token);
      } else {
        state = AuthState.restoreFailure(_messageForError(error));
      }
    }
  }

  Future<void> _expireSession(String rejectedToken) async {
    if (!ref.mounted || rejectedToken != _credentials.token) return;
    final operation = ++_operation;
    _credentials.restore(null);
    try {
      await _tokenStorage.clearToken();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to delete the expired session from secure storage.',
        name: 'obee.auth',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (!ref.mounted || operation != _operation) return;
    _resetFeatureState();
    state = const AuthState.unauthenticated('Phiên đăng nhập đã hết hiệu lực.');
  }

  void _resetFeatureState() {
    // Session dependents can watch auth. Reset their caches at the container
    // level rather than treating them as dependencies of this controller.
    final container = ref.container;
    container.invalidate(attendanceControllerProvider);
    container.invalidate(scheduleControllerProvider);
    container.invalidate(scheduleFormControllerProvider);
    container.invalidate(profileControllerProvider);
    container.invalidate(requestListControllerProvider);
    container.invalidate(chatRepositoryProvider);
    container.invalidate(chatHubProvider);
    container.invalidate(directChatSearchProvider);
    container.invalidate(newDirectChatSearchProvider);
    container.invalidate(groupCreationPreviewProvider);
  }
}

class AuthState {
  const AuthState({
    required this.user,
    required this.isLoading,
    required this.errorMessage,
    this.isRestoring = false,
    this.restoreFailed = false,
  });
  const AuthState.loading()
    : user = null,
      isLoading = true,
      errorMessage = null,
      isRestoring = true,
      restoreFailed = false;
  const AuthState.restoreFailure(this.errorMessage)
    : user = null,
      isLoading = false,
      isRestoring = false,
      restoreFailed = true;
  const AuthState.unauthenticated([this.errorMessage])
    : user = null,
      isLoading = false,
      isRestoring = false,
      restoreFailed = false;
  const AuthState.authenticated(User this.user)
    : isLoading = false,
      errorMessage = null,
      isRestoring = false,
      restoreFailed = false;
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isRestoring;
  final bool restoreFailed;
  bool get isAuthenticated => user != null;
  AuthState copyWith({User? user, bool? isLoading, String? errorMessage}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        isRestoring: isRestoring,
        restoreFailed: restoreFailed,
      );
}

String _messageForError(Object error) {
  if (error is DioException) {
    final apiError = error.error;
    if (apiError is ApiProblemException) {
      return problemMessage(apiError.problem);
    }
    return 'Không thể kết nối máy chủ. Kiểm tra mạng và thử lại.';
  }
  return 'Không thể xác minh dữ liệu hoặc lưu phiên đăng nhập. Vui lòng thử lại.';
}

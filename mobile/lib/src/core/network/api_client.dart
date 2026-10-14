import 'package:obee_mobile/src/core/session/session_events.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/core/network/api_problem.dart';
import 'package:obee_mobile/src/core/network/mock_api_interceptor.dart';
import 'package:obee_mobile/src/core/session/session_credentials.dart';

final dioProvider = Provider<Dio>((ref) {
  final appConfig = ref.watch(appConfigProvider);
  final credentials = ref.watch(sessionCredentialsProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: appConfig.apiBaseUrl,
      headers: const {'Accept': 'application/json', 'Accept-Language': 'vi'},
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  if (mockApiEnabled) {
    dio.interceptors.add(MockApiInterceptor());
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          if (options.path != '/mobile/auth/login') {
            final token = credentials.token;
            if (token == null && !credentials.isAvailable) {
              throw StateError('Authentication session is unavailable.');
            }
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        } catch (error, stackTrace) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: error,
              stackTrace: stackTrace,
            ),
          );
        }
      },
      onError: (error, handler) {
        final authorization = error.requestOptions.headers['Authorization'];
        if (ref.mounted &&
            authorization is String &&
            authorization.startsWith('Bearer ')) {
          final token = authorization.substring('Bearer '.length);
          if (error.response?.statusCode == 401) {
            ref.read(sessionEventsProvider).add(SessionEvent.expired(token));
          } else if (error.response?.statusCode == 403 &&
              error.requestOptions.path != '/mobile/auth/user') {
            ref
                .read(sessionEventsProvider)
                .add(SessionEvent.authorizationDenied(token));
          }
        }
        try {
          handler.reject(parseApiError(error));
        } catch (cause, stackTrace) {
          handler.reject(error.copyWith(error: cause, stackTrace: stackTrace));
        }
      },
    ),
  );

  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

final class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    if (response.data == null) {
      throw const FormatException('API response body is required.');
    }
    return response.data as T;
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    if (response.data == null) {
      throw const FormatException('API response body is required.');
    }
    return response.data as T;
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    if (response.data == null) {
      throw const FormatException('API response body is required.');
    }
    return response.data as T;
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    if (response.data == null) {
      throw const FormatException('API response body is required.');
    }
    return response.data as T;
  }

  Future<void> putVoid(
    String path, {
    Object? data,
    CancelToken? cancelToken,
  }) async {
    await _dio.put<void>(path, data: data, cancelToken: cancelToken);
  }

  Future<void> postVoid(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    await _dio.post<void>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  Future<void> delete(
    String path, {
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    await _dio.delete<void>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }
}

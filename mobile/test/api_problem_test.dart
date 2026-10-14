import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/network/api_problem.dart';

void main() {
  test('parses problem without optional errors', () {
    final problem = ApiProblem.fromJson(const {
      'type': 'http://obee.local/problems/unauthenticated',
      'title': 'Unauthenticated',
      'status': 401,
      'detail': 'Authentication is required.',
      'instance': '/api/mobile/auth/user',
    });

    expect(problem.errors, null);
    expect(problemMessage(problem), 'Authentication is required.');
  });

  test('prefers field error messages over generic detail', () {
    final problem = ApiProblem.fromJson(const {
      'type': 'http://obee.local/problems/validation-error',
      'title': 'Validation failed',
      'status': 422,
      'detail': '[CODE] The given data was invalid.',
      'instance': '/api/attendance/logs',
      'errors': {
        'location': [
          'Không có địa điểm chấm công nào phù hợp với vị trí hoặc điều kiện IP hiện tại.',
        ],
      },
    });

    expect(
      problemMessage(problem),
      'Không có địa điểm chấm công nào phù hợp với vị trí hoặc điều kiện IP hiện tại.',
    );
  });

  test('rejects malformed optional errors', () {
    expect(
      () => ApiProblem.fromJson(const {
        'type': 'http://obee.local/problems/validation-error',
        'title': 'Validation failed',
        'status': 422,
        'detail': 'The given data was invalid.',
        'errors': ['email'],
      }),
      throwsFormatException,
    );
  });

  test('parses Dio problem errors by content type', () {
    final error = parseApiError(
      DioException.badResponse(
        statusCode: 401,
        requestOptions: RequestOptions(path: '/api/mobile/auth/user'),
        response: Response<Map<String, Object?>>(
          requestOptions: RequestOptions(path: '/api/mobile/auth/user'),
          statusCode: 401,
          headers: Headers.fromMap({
            Headers.contentTypeHeader: ['application/problem+json'],
          }),
          data: const {
            'type': 'http://obee.local/problems/unauthenticated',
            'title': 'Unauthenticated',
            'status': 401,
            'detail': 'Authentication is required.',
          },
        ),
      ),
    );

    expect(error.error, isA<ApiProblemException>());
  });

  test('does not parse non-problem JSON errors as problem responses', () {
    final error = parseApiError(
      DioException.badResponse(
        statusCode: 500,
        requestOptions: RequestOptions(path: '/api/mobile/auth/user'),
        response: Response<Map<String, Object?>>(
          requestOptions: RequestOptions(path: '/api/mobile/auth/user'),
          statusCode: 500,
          headers: Headers.fromMap({
            Headers.contentTypeHeader: ['application/json'],
          }),
          data: const {'message': 'Server error'},
        ),
      ),
    );

    expect(error.error, isA<ApiStatusException>());
  });
}

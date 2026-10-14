import 'package:dio/dio.dart';

class ApiProblem {
  const ApiProblem({
    required this.type,
    required this.title,
    required this.status,
    required this.detail,
    required this.instance,
    required this.errors,
  });

  factory ApiProblem.fromJson(Map<String, Object?> json) {
    final type = json['type'];
    final title = json['title'];
    final status = json['status'];
    final detail = json['detail'];
    final instance = json['instance'];
    final errors = json['errors'];

    if (type is! String ||
        title is! String ||
        status is! int ||
        detail is! String) {
      throw const FormatException('Problem response contract is invalid.');
    }

    if (errors != null && errors is! Map<String, Object?>) {
      throw const FormatException('Problem errors contract is invalid.');
    }
    final problemErrors = <String, List<String>>{};
    if (errors is Map<String, Object?>) {
      for (final entry in errors.entries) {
        final messages = entry.value;
        if (messages is! List ||
            messages.any((message) => message is! String)) {
          throw const FormatException(
            'Problem field errors contract is invalid.',
          );
        }
        problemErrors[entry.key] = messages.cast<String>();
      }
    }
    if (status == 422 && errors == null) {
      throw const FormatException('Validation problem requires field errors.');
    }
    if (instance != null && instance is! String) {
      throw const FormatException('Problem instance contract is invalid.');
    }

    return ApiProblem(
      type: type,
      title: title,
      status: status,
      detail: detail,
      instance: instance is String ? instance : null,
      errors: errors == null ? null : problemErrors,
    );
  }

  final String type;
  final String title;
  final int status;
  final String detail;
  final String? instance;
  final Map<String, List<String>>? errors;
}

class ApiProblemException implements Exception {
  const ApiProblemException(this.problem);

  final ApiProblem problem;

  @override
  String toString() => problemMessage(problem);
}

String problemMessage(ApiProblem problem) {
  final errors = problem.errors;
  if (errors != null) {
    for (final messages in errors.values) {
      if (messages.isNotEmpty && messages.first.isNotEmpty) {
        return messages.first;
      }
    }
  }

  return problem.detail;
}

class ApiStatusException implements Exception {
  const ApiStatusException(this.statusCode);

  final int statusCode;
}

DioException parseApiError(DioException error) {
  final response = error.response;
  final payload = response?.data;
  final contentType = response?.headers.value(Headers.contentTypeHeader);

  if (payload is Map<String, Object?> &&
      contentType != null &&
      contentType.contains('application/problem+json')) {
    return error.copyWith(
      error: ApiProblemException(ApiProblem.fromJson(payload)),
    );
  }

  if (response?.statusCode != null) {
    return error.copyWith(error: ApiStatusException(response!.statusCode!));
  }

  return error;
}

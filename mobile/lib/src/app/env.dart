import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment { dev, staging, prod }

final class AppConfig {
  AppConfig._({
    required this.environment,
    required this.apiBaseUri,
    required this.appBaseUri,
  });

  static const _apiBaseUrlKey = 'OBEE_API_BASE_URL';
  static const _appBaseUrlKey = 'OBEE_APP_BASE_URL';

  static const _apiBaseUrlValue = String.fromEnvironment(_apiBaseUrlKey);
  static const _appBaseUrlValue = String.fromEnvironment(_appBaseUrlKey);

  static const _hasApiBaseUrl = bool.hasEnvironment(_apiBaseUrlKey);
  static const _hasAppBaseUrl = bool.hasEnvironment(_appBaseUrlKey);

  static final current = AppConfig.fromEnvironment();

  final AppEnvironment environment;
  final Uri apiBaseUri;
  final Uri appBaseUri;

  String get apiBaseUrl => apiBaseUri.toString();

  String get appBaseUrl => appBaseUri.toString();

  static AppConfig fromEnvironment() {
    const envName = String.fromEnvironment('OBEE_ENV');
    if (!const bool.hasEnvironment('OBEE_ENV')) {
      throw StateError('Missing required dart define: OBEE_ENV.');
    }
    final environment = AppEnvironment.values.byName(envName);
    if (appFlavor != null && appFlavor != envName) {
      throw StateError('Build flavor must match OBEE_ENV.');
    }
    if (!_hasApiBaseUrl) {
      throw StateError(
        'Missing required dart define: $_apiBaseUrlKey. '
        'Pass --dart-define=$_apiBaseUrlKey=<url> or '
        '--dart-define-from-file=<file>.',
      );
    }

    if (!_hasAppBaseUrl) {
      throw StateError(
        'Missing required dart define: $_appBaseUrlKey. '
        'Pass --dart-define=$_appBaseUrlKey=<url> or '
        '--dart-define-from-file=<file>.',
      );
    }

    return AppConfig.parse(
      environment: environment,
      apiBaseUrl: _apiBaseUrlValue,
      appBaseUrl: _appBaseUrlValue,
    );
  }

  static AppConfig parse({
    AppEnvironment environment = AppEnvironment.dev,
    required String apiBaseUrl,
    required String appBaseUrl,
  }) {
    final parsedApiBaseUri = _parseHttpUri(
      key: _apiBaseUrlKey,
      value: apiBaseUrl,
    );
    final parsedAppBaseUri = _parseHttpUri(
      key: _appBaseUrlKey,
      value: appBaseUrl,
    );

    if (!_isApiPath(parsedApiBaseUri)) {
      throw FormatException(
        '$_apiBaseUrlKey must end with /api. Received: $apiBaseUrl',
      );
    }

    if (parsedAppBaseUri.path != '' && parsedAppBaseUri.path != '/') {
      throw const FormatException('OBEE_APP_BASE_URL must be an origin.');
    }
    if (environment != AppEnvironment.dev &&
        (parsedApiBaseUri.scheme != 'https' ||
            parsedAppBaseUri.scheme != 'https')) {
      throw const FormatException('Staging and production require HTTPS.');
    }
    return AppConfig._(
      environment: environment,
      apiBaseUri: parsedApiBaseUri,
      appBaseUri: parsedAppBaseUri,
    );
  }

  static Uri _parseHttpUri({required String key, required String value}) {
    final uri = Uri.parse(value);

    if (!uri.hasScheme || uri.host.isEmpty) {
      throw FormatException('$key must be an absolute URL. Received: $value');
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw FormatException('$key must use http or https. Received: $value');
    }

    if (uri.userInfo.isNotEmpty) {
      throw FormatException('$key must not include credentials.');
    }
    if (uri.hasQuery || uri.hasFragment) {
      throw FormatException(
        '$key must not include a query string or fragment. Received: $value',
      );
    }

    return uri;
  }

  static bool _isApiPath(Uri uri) {
    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty);

    return segments.isNotEmpty && segments.last == 'api';
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.current;
});

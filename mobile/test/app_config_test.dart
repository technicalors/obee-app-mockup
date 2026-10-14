import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/env.dart';

void main() {
  test('parses valid app config urls', () {
    final config = AppConfig.parse(
      apiBaseUrl: 'https://api.obee.test/api',
      appBaseUrl: 'https://app.obee.test',
    );

    expect(config.apiBaseUrl, 'https://api.obee.test/api');
    expect(config.appBaseUrl, 'https://app.obee.test');
  });

  test('rejects api url without /api suffix', () {
    expect(
      () => AppConfig.parse(
        apiBaseUrl: 'https://api.obee.test/v1',
        appBaseUrl: 'https://app.obee.test',
      ),
      throwsFormatException,
    );
  });

  test('rejects relative urls', () {
    expect(
      () => AppConfig.parse(
        apiBaseUrl: '/api',
        appBaseUrl: 'https://app.obee.test',
      ),
      throwsFormatException,
    );
  });
}

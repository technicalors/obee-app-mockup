import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/requests/logic/request_formatters.dart';

void main() {
  group('request_formatters', () {
    test('formats ISO UTC datetime into Asia/Ho_Chi_Minh local time', () {
      const utcStart = '2026-10-06T01:00:00.000000Z';
      const utcEnd = '2026-10-06T05:00:00.000000Z';

      expect(formatRequestDateTime(utcStart), '06/10/2026 08:00');
      expect(formatRequestDateTime(utcEnd), '06/10/2026 12:00');
    });

    test(
      'single-day request shows date once followed by time range without repeating date',
      () {
        const utcStart = '2026-10-06T01:00:00.000000Z'; // 08:00 UTC+7
        const utcEnd = '2026-10-06T05:00:00.000000Z'; // 12:00 UTC+7

        final range = formatRequestRange(utcStart, utcEnd);
        expect(range, '06/10/2026 08:00 - 12:00');
      },
    );

    test('multi-day request shows both full start and end dates', () {
      const utcStart = '2026-10-06T01:00:00.000000Z'; // 06/10/2026 08:00
      const utcEnd = '2026-10-08T05:00:00.000000Z'; // 08/10/2026 12:00

      final range = formatRequestRange(utcStart, utcEnd);
      expect(range, '06/10/2026 08:00 - 08/10/2026 12:00');
    });

    test('supports custom separator like en-dash', () {
      const utcStart = '2026-10-06T01:00:00.000000Z';
      const utcEnd = '2026-10-06T05:00:00.000000Z';

      final range = formatRequestRange(utcStart, utcEnd, separator: ' – ');
      expect(range, '06/10/2026 08:00 – 12:00');
    });

    test('preserves already formatted dates', () {
      const formatted = '06/10/2026 08:00';
      expect(formatRequestDateTime(formatted), '06/10/2026 08:00');
    });

    test('handles null and empty values gracefully', () {
      expect(formatRequestDateTime(null), '');
      expect(formatRequestDateTime(''), '');
      expect(formatRequestRange(null, null), '');
    });
  });
}

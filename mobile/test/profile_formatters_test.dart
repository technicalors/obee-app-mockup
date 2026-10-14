import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/profile/logic/profile_formatters.dart';

void main() {
  test('displays nullable profile values without empty probing', () {
    expect(displayNullableProfileValue(null), null);
    expect(displayNullableProfileValue(''), '');
    expect(displayNullableProfileValue('  value  '), '  value  ');
  });

  test('formats birthday and rejects invalid non-null values', () {
    expect(formatProfileBirthday(null, 'vi'), null);
    expect(formatProfileBirthday('1990-04-05', 'vi'), '05/04/1990');
    expect(
      () => formatProfileBirthday('1990-04-04T17:00:00.000Z', 'vi'),
      throwsFormatException,
    );
    expect(() => formatProfileBirthday('invalid', 'vi'), throwsFormatException);
  });

  test('keeps API birthdays as date-only values and rejects timestamps', () {
    expect(
      () => parseProfileDateValue('1990-04-04T17:00:00.000Z'),
      throwsFormatException,
    );
    expect(parseProfileDateValue('1990-04-05'), DateTime(1990, 4, 5));
    expect(() => parseProfileDateValue('1990-02-30'), throwsFormatException);
  });

  test('converts display birthday values back to API date format', () {
    expect(formatDisplayDateValue(DateTime(1990, 4, 5), 'vi'), '05/04/1990');
    expect(parseDisplayDateValue('05/04/1990'), DateTime(1990, 4, 5));
    expect(formatDateOnly(parseDisplayDateValue('05/04/1990')), '1990-04-05');
  });
}

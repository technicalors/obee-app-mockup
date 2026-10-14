import 'package:intl/intl.dart';

String? displayNullableProfileValue(String? value) {
  if (value == null) {
    return null;
  }

  return value;
}

String? formatProfileBirthday(String? value, String locale) {
  if (value == null) {
    return null;
  }

  return formatDisplayDateValue(parseProfileDateValue(value), locale);
}

String? formatProfileGender(
  String? value, {
  required String male,
  required String female,
  required String other,
}) {
  switch (value) {
    case 'male':
      return male;
    case 'female':
      return female;
    case 'other':
      return other;
    default:
      return null;
  }
}

String formatDateOnly(DateTime value) {
  return DateFormat('yyyy-MM-dd').format(value);
}

String formatDisplayDateValue(DateTime value, String locale) {
  return DateFormat('dd/MM/yyyy').format(value);
}

DateTime parseProfileDateValue(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw const FormatException('Profile birthday must be YYYY-MM-DD.');
  }
  return DateFormat('yyyy-MM-dd').parseStrict(value);
}

DateTime parseDisplayDateValue(String value) {
  return DateFormat('dd/MM/yyyy').parseStrict(value);
}

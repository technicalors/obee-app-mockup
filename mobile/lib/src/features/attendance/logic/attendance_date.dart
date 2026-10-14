import 'package:obee_mobile/src/core/time/business_time.dart';
import 'package:intl/intl.dart';

const _canonicalDatePattern = r'^\d{4}-\d{2}-\d{2}$';

DateTime attendanceNow() {
  return businessNow();
}

String attendanceToday() {
  return formatCanonicalAttendanceDate(attendanceNow());
}

String formatCanonicalAttendanceDate(DateTime value) {
  return DateFormat('yyyy-MM-dd').format(value);
}

DateTime parseAttendanceDateValue(String value) {
  if (!RegExp(_canonicalDatePattern).hasMatch(value)) {
    throw FormatException('Invalid attendance date value: $value');
  }

  return DateFormat('yyyy-MM-dd').parseStrict(value);
}

String getAttendanceMonthStartValue(DateTime reference) {
  return formatCanonicalAttendanceDate(
    DateTime(reference.year, reference.month),
  );
}

String shiftAttendanceMonthValue(String monthStartValue, int deltaMonths) {
  final parsed = parseAttendanceDateValue(monthStartValue);
  final shifted = DateTime(parsed.year, parsed.month + deltaMonths);

  return formatCanonicalAttendanceDate(DateTime(shifted.year, shifted.month));
}

String getAttendanceMonthEndValue(String monthStartValue) {
  final parsed = parseAttendanceDateValue(monthStartValue);
  final end = DateTime(parsed.year, parsed.month + 1, 0);

  return formatCanonicalAttendanceDate(end);
}

String formatAttendanceMonthLabel(String monthStartValue, String locale) {
  final parsed = parseAttendanceDateValue(monthStartValue);

  return DateFormat.yMMMM(locale).format(parsed);
}

String formatAttendanceDateLabel(String value, String locale) {
  final parsed = parseAttendanceDateValue(value);

  return DateFormat.yMMMMEEEEd(locale).format(parsed);
}

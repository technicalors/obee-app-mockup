import 'package:obee_mobile/src/core/time/business_time.dart';

DateTime? parseRequestDateTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final trimmed = raw.trim();

  // Try standard DateTime.tryParse (handles ISO 8601 like 2026-10-06T01:00:00.000000Z, 2026-10-06 01:00:00)
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) {
    if (parsed.isUtc || trimmed.endsWith('Z')) {
      return businessWallTime(parsed);
    }
    return parsed;
  }

  // Try dd/MM/yyyy HH:mm format
  final parts = trimmed.split(' ');
  if (parts.isNotEmpty && parts[0].contains('/')) {
    final dateParts = parts[0].split('/');
    if (dateParts.length == 3) {
      final day = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final year = int.tryParse(dateParts[2]);
      if (day != null && month != null && year != null) {
        int hour = 0;
        int minute = 0;
        if (parts.length > 1 && parts[1].contains(':')) {
          final timeParts = parts[1].split(':');
          hour = int.tryParse(timeParts[0]) ?? 0;
          minute = int.tryParse(timeParts[1]) ?? 0;
        }
        return DateTime(year, month, day, hour, minute);
      }
    }
  }

  return null;
}

String formatRequestDateTime(String? raw, {String fallback = ''}) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  final dt = parseRequestDateTime(raw);
  if (dt != null) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString().padLeft(4, '0');
    final hr = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $hr:$min';
  }
  return raw;
}

String formatRequestDateOnly(String? raw, {String fallback = ''}) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  final dt = parseRequestDateTime(raw);
  if (dt != null) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }
  return raw;
}

/// Formats request date range.
/// For single-day requests: shows the date once, then the time range:
/// e.g. "06/10/2026 08:00 - 12:00"
/// For multi-day requests: shows full start and end date times:
/// e.g. "06/10/2026 08:00 - 08/10/2026 12:00"
String formatRequestRange(
  String? startAt,
  String? endAt, {
  String separator = ' - ',
}) {
  final startDt = parseRequestDateTime(startAt);
  final endDt = parseRequestDateTime(endAt);

  if (startDt == null && endDt == null) {
    if (startAt != null && startAt.isNotEmpty) return startAt;
    return '';
  }

  if (startDt != null && endDt == null) {
    return formatRequestDateTime(startAt);
  }

  if (startDt == null && endDt != null) {
    return formatRequestDateTime(endAt);
  }

  final startDay = startDt!.day.toString().padLeft(2, '0');
  final startMonth = startDt.month.toString().padLeft(2, '0');
  final startYear = startDt.year.toString().padLeft(4, '0');
  final startHour = startDt.hour.toString().padLeft(2, '0');
  final startMinute = startDt.minute.toString().padLeft(2, '0');

  final endHour = endDt!.hour.toString().padLeft(2, '0');
  final endMinute = endDt.minute.toString().padLeft(2, '0');

  final isSameDay =
      startDt.year == endDt.year &&
      startDt.month == endDt.month &&
      startDt.day == endDt.day;

  if (isSameDay) {
    // Single-day request: show date once, then time range
    return '$startDay/$startMonth/$startYear $startHour:$startMinute$separator$endHour:$endMinute';
  } else {
    // Multi-day request: show date for both start and end
    final endDay = endDt.day.toString().padLeft(2, '0');
    final endMonth = endDt.month.toString().padLeft(2, '0');
    final endYear = endDt.year.toString().padLeft(4, '0');
    return '$startDay/$startMonth/$startYear $startHour:$startMinute$separator$endDay/$endMonth/$endYear $endHour:$endMinute';
  }
}

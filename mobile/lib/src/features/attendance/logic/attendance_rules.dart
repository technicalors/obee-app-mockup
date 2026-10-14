import 'dart:math' as math;

import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_date.dart';

class AttendanceEligibility {
  const AttendanceEligibility({
    required this.distanceMeters,
    required this.locationMatched,
    required this.ipMatched,
    required this.eligible,
  });

  final double? distanceMeters;
  final bool locationMatched;
  final bool ipMatched;
  final bool eligible;
}

class AttendanceCalendarCell {
  const AttendanceCalendarCell({
    required this.date,
    required this.dayOfMonth,
    required this.inRange,
  });

  final String date;
  final int dayOfMonth;
  final bool inRange;
}

class AttendanceEvaluation {
  const AttendanceEvaluation({
    required this.location,
    required this.eligibility,
  });

  final AttendanceLocation location;
  final AttendanceEligibility eligibility;
}

double haversineMeters(AttendanceCoordinates from, AttendanceCoordinates to) {
  const earthRadius = 6371000.0;
  final latitudeDelta = _degreesToRadians(to.latitude - from.latitude);
  final longitudeDelta = _degreesToRadians(to.longitude - from.longitude);
  final haversine =
      math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
      math.cos(_degreesToRadians(from.latitude)) *
          math.cos(_degreesToRadians(to.latitude)) *
          math.sin(longitudeDelta / 2) *
          math.sin(longitudeDelta / 2);

  return 2 * earthRadius * math.asin(math.sqrt(haversine.clamp(0.0, 1.0)));
}

AttendanceEligibility evaluateAttendanceEligibility(
  AttendanceLocation location,
  AttendanceCoordinates? currentPosition,
  String? currentIpAddress,
) {
  final distance = currentPosition == null
      ? null
      : haversineMeters(
          currentPosition,
          AttendanceCoordinates(
            latitude: location.latitude,
            longitude: location.longitude,
          ),
        );

  final locationMatched = distance != null && distance <= location.radiusMeters;
  final ipMatched =
      currentIpAddress != null &&
      location.ips.any((ip) => ip.ipAddress == currentIpAddress);

  final eligible = switch (location.validationMode) {
    'location' => locationMatched,
    'ip' => ipMatched,
    'both' => locationMatched && ipMatched,
    'either' => locationMatched || ipMatched,
    _ => throw FormatException(
      'Invalid attendance validation mode: ${location.validationMode}',
    ),
  };

  return AttendanceEligibility(
    distanceMeters: distance,
    locationMatched: locationMatched,
    ipMatched: ipMatched,
    eligible: eligible,
  );
}

AttendanceEvaluation? selectBestEvaluation(
  List<AttendanceLocation> locations,
  AttendanceCoordinates? position,
  String? ipAddress,
) {
  if (locations.isEmpty) {
    return null;
  }

  final evaluations = locations
      .map(
        (location) => AttendanceEvaluation(
          location: location,
          eligibility: evaluateAttendanceEligibility(
            location,
            position,
            ipAddress,
          ),
        ),
      )
      .toList(growable: false);

  final eligible = evaluations
      .where((item) => item.eligibility.eligible)
      .toList();
  final candidates = eligible.isNotEmpty ? eligible : evaluations;

  candidates.sort(_compareEvaluations);

  return candidates.first;
}

int _compareEvaluations(AttendanceEvaluation left, AttendanceEvaluation right) {
  final leftDistance = left.eligibility.distanceMeters;
  final rightDistance = right.eligibility.distanceMeters;

  if (leftDistance == null && rightDistance == null) {
    return 0;
  }

  if (leftDistance == null) {
    return 1;
  }

  if (rightDistance == null) {
    return -1;
  }

  return leftDistance.compareTo(rightDistance);
}

String formatWorkSeconds(int totalSeconds) {
  final totalMinutes = totalSeconds ~/ 60;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  return '$hours:${minutes.toString().padLeft(2, '0')}';
}

String formatDecimalHours(int totalSeconds) {
  return (totalSeconds / 3600).toStringAsFixed(1);
}

List<AttendanceCalendarCell> buildAttendanceCalendarCells(
  String from,
  String to,
) {
  final fromDate = parseAttendanceDateValue(from);
  final toDate = parseAttendanceDateValue(to);

  if (fromDate.isAfter(toDate)) {
    return const [];
  }

  final fromWeekday = _mondayWeekdayIndex(fromDate);
  final toWeekday = _mondayWeekdayIndex(toDate);
  final firstCellDate = fromDate.subtract(Duration(days: fromWeekday));
  final lastCellDate = toDate.add(Duration(days: 6 - toWeekday));
  final cells = <AttendanceCalendarCell>[];

  for (
    var date = firstCellDate;
    !date.isAfter(lastCellDate);
    date = date.add(const Duration(days: 1))
  ) {
    final inRange = !date.isBefore(fromDate) && !date.isAfter(toDate);
    cells.add(
      AttendanceCalendarCell(
        date: formatCanonicalAttendanceDate(date),
        dayOfMonth: date.day,
        inRange: inRange,
      ),
    );
  }

  return cells;
}

int calculateTotalWorkSeconds({required List<AttendanceLog> logs}) {
  if (logs.length < 2) {
    return 0;
  }

  final firstTime = DateTime.parse(logs.first.checkedAt);
  final lastTime = DateTime.parse(logs.last.checkedAt);
  final diffSeconds = lastTime.difference(firstTime).inSeconds;

  return diffSeconds > 0 ? diffSeconds : 0;
}

bool isAttendanceLate({
  required DateTime checkInAt,
  required DateTime shiftStartAt,
}) {
  return checkInAt.isAfter(shiftStartAt);
}

bool canPunchAttendance({
  required bool hasShiftToday,
  required bool locationOrIpEligible,
}) {
  return hasShiftToday && locationOrIpEligible;
}

enum CalendarDayAttendanceState { absent, checked, late, incomplete, leave }

CalendarDayAttendanceState calendarDayAttendanceState(
  AttendanceRangeSummary? summary,
) {
  if (summary == null) return CalendarDayAttendanceState.absent;
  if (summary.logsCount == 0) {
    return summary.onLeave
        ? CalendarDayAttendanceState.leave
        : CalendarDayAttendanceState.absent;
  }

  // Nếu chấm công sau khi bắt đầu ca thì là muộn
  final isLate =
      summary.isLate ||
      (summary.firstCheckInAt != null &&
          summary.shiftStartAt != null &&
          isAttendanceLate(
            checkInAt: DateTime.parse(summary.firstCheckInAt!),
            shiftStartAt: DateTime.parse(summary.shiftStartAt!),
          ));

  if (isLate) {
    return CalendarDayAttendanceState.late;
  }

  if (summary.logsCount >= 2) {
    return CalendarDayAttendanceState.checked;
  }

  return CalendarDayAttendanceState.incomplete;
}

String validationModeLabel(String mode) {
  return switch (mode) {
    'location' => 'Theo vị trí',
    'ip' => 'Theo IP',
    'both' => 'Vị trí và IP',
    'either' => 'Vị trí hoặc IP',
    _ => mode,
  };
}

double _degreesToRadians(double value) {
  return value * math.pi / 180;
}

int _mondayWeekdayIndex(DateTime date) {
  return (date.weekday + 6) % 7;
}

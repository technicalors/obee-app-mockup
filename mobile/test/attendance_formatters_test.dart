import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_formatters.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_rules.dart';

void main() {
  test('formats current clock', () {
    expect(formatAttendanceClock(DateTime(2026, 1, 2, 3, 4, 5)), '03:04:05');
  });

  test('formats current ip from nullable context', () {
    expect(formatCurrentIp(null), 'Chưa có IP');

    const context = AttendanceContext(
      user: AttendanceUserRef(id: 'user-1', name: 'User'),
      ipAddress: '127.0.0.1',
      assignedLocations: [],
    );

    expect(formatCurrentIp(context), 'IP hiện tại: 127.0.0.1');
  });

  test('formats checked at time and rejects invalid timestamps', () {
    expect(formatAttendanceLogTime('2026-01-02T03:04:05+07:00'), '03:04');
    expect(formatAttendanceLogTime('2026-01-02T03:04:05Z'), '10:04');
    expect(formatAttendanceLogTime('2026-01-01T20:04:05Z'), '03:04');
    expect(() => formatAttendanceLogTime('not-a-date'), throwsFormatException);
  });

  test('formats attendance position and calendar labels', () {
    expect(positionStateLabel(PositionState.ready), 'Đã có vị trí');
    expect(calendarStatusLabel(CalendarDayAttendanceState.checked), 'Đã chấm');
  });

  test('formats vietnamese dates correctly matching mockup', () {
    final dt = DateTime(2026, 10, 5); // Monday
    expect(formatVietnameseDayOfWeek(dt), 'Thứ Hai');
    expect(formatVietnameseFullDate(dt), 'Thứ Hai, 5 tháng 10, 2026');
    expect(formatVietnameseMonthYear(dt), 'Tháng 10 năm 2026');
    expect(formatVietnameseMonthYearShort(dt), 'Tháng 10/2026');
    expect(formatVietnameseDayDetail(dt), 'Chi tiết ngày 5 tháng 10, 2026');
  });
}

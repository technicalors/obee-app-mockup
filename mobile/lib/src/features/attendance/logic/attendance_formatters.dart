import 'package:obee_mobile/src/core/time/business_time.dart';
import 'package:intl/intl.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_rules.dart';

enum PositionState { idle, loading, ready, denied, deniedForever, failed }

String formatAttendanceClock(DateTime value) {
  return DateFormat('HH:mm:ss').format(value);
}

String formatCurrentIp(AttendanceContext? context) {
  final address = context?.ipAddress;
  if (address == null) {
    return 'Chưa có IP';
  }

  return 'IP hiện tại: $address';
}

String positionStateLabel(PositionState state) {
  return switch (state) {
    PositionState.loading => 'Đang lấy vị trí',
    PositionState.ready => 'Đã có vị trí',
    PositionState.deniedForever =>
      'Quyền vị trí bị chặn. Mở cài đặt để cấp quyền.',
    PositionState.denied => 'Bạn chưa cấp quyền vị trí',
    PositionState.failed => 'Không lấy được vị trí',
    PositionState.idle => 'Chưa kiểm tra vị trí',
  };
}

String formatAttendanceLogTime(String value) {
  final parsed = businessWallTime(DateTime.parse(value));

  return DateFormat('HH:mm').format(parsed);
}

String calendarStatusLabel(CalendarDayAttendanceState state) {
  return switch (state) {
    CalendarDayAttendanceState.leave => 'Nghỉ phép',
    CalendarDayAttendanceState.absent => 'Vắng',
    CalendarDayAttendanceState.checked => 'Đã chấm',
    CalendarDayAttendanceState.late => 'Muộn',
    CalendarDayAttendanceState.incomplete => 'Thiếu',
  };
}

String formatVietnameseDayOfWeek(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => 'Thứ Hai',
    DateTime.tuesday => 'Thứ Ba',
    DateTime.wednesday => 'Thứ Tư',
    DateTime.thursday => 'Thứ Năm',
    DateTime.friday => 'Thứ Sáu',
    DateTime.saturday => 'Thứ Bảy',
    DateTime.sunday => 'Chủ Nhật',
    _ => '',
  };
}

String formatVietnameseFullDate(DateTime date) {
  final dow = formatVietnameseDayOfWeek(date);
  return '$dow, ${date.day} tháng ${date.month}, ${date.year}';
}

String formatVietnameseMonthYear(DateTime date) {
  return 'Tháng ${date.month} năm ${date.year}';
}

String formatVietnameseMonthYearShort(DateTime date) {
  return 'Tháng ${date.month}/${date.year}';
}

String formatVietnameseDayDetail(DateTime date) {
  return 'Chi tiết ngày ${date.day} tháng ${date.month}, ${date.year}';
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';

void main() {
  test('formats API dates without changing the schedule wire shape', () {
    expect(formatApiDate(DateTime(2026, 6, 10, 8, 5)), '2026-06-10');
  });

  test('formats API datetimes without changing the schedule wire shape', () {
    expect(
      formatApiDateTime(DateTime(2026, 6, 10, 8, 5)),
      '2026-06-10 08:05:00',
    );
  });

  test('formats API times with zero-padded hours and minutes', () {
    expect(formatApiTime(const TimeOfDay(hour: 8, minute: 5)), '08:05');
  });

  test('formats display dates as dd/mm/yyyy', () {
    expect(formatDisplayDate(DateTime(2026, 6, 10, 8, 5)), '10/06/2026');
  });

  test('formats schedule weekdays in Vietnamese', () {
    expect(formatScheduleWeekday(DateTime(2026, 6, 8)), 'Thứ Hai');
    expect(formatScheduleWeekday(DateTime(2026, 6, 9)), 'Thứ Ba');
    expect(formatScheduleWeekday(DateTime(2026, 6, 10)), 'Thứ Tư');
    expect(formatScheduleWeekday(DateTime(2026, 6, 11)), 'Thứ Năm');
    expect(formatScheduleWeekday(DateTime(2026, 6, 12)), 'Thứ Sáu');
    expect(formatScheduleWeekday(DateTime(2026, 6, 13)), 'Thứ Bảy');
    expect(formatScheduleWeekday(DateTime(2026, 6, 14)), 'Chủ Nhật');
  });

  test('formats schedule date with weekday', () {
    expect(
      formatScheduleDateWithWeekday(DateTime(2026, 6, 8)),
      'Thứ Hai, 08/06/2026',
    );
  });

  test('formats schedule month year as MM/yyyy', () {
    expect(formatScheduleMonthYear(DateTime(2026, 6)), '06/2026');
    expect(formatScheduleMonthYear(DateTime(2026, 10)), '10/2026');
  });

  test('formats the selected day label for the schedule page header', () {
    expect(
      formatScheduleSelectedDayLabel(DateTime(2026, 6, 10, 8, 5)),
      'Lịch ngày 10/06',
    );
  });

  test('formats the event count label for the selected day badge', () {
    expect(formatScheduleEventCountLabel(3), '3 lịch trình');
  });

  test('formats the repeat summary used by the detail page', () {
    expect(
      formatScheduleRepeatSummary(
        _schedule(
          start: DateTime(2026, 6, 10, 8, 5),
          end: DateTime(2026, 6, 30, 9, 45),
          scheduleType: ScheduleEventScheduleType.repeat,
          repeatType: ScheduleEventRepeatType.weekly,
        ),
      ),
      'Hàng tuần · 10/06/2026 - 30/06/2026',
    );
  });

  test('formats schedule user lists for the detail page rows', () {
    expect(
      formatScheduleUserListLabel(
        prefix: 'Người tham gia',
        users: const [
          ScheduleUserRef(id: 'user-1', name: 'Lan', avatar: null, email: null),
          ScheduleUserRef(
            id: 'user-2',
            name: 'Minh',
            avatar: null,
            email: null,
          ),
        ],
      ),
      'Người tham gia: Lan, Minh',
    );
  });

  test('formats a schedule range as one datetime when start and end match', () {
    expect(
      formatScheduleDateTimeRange(
        _schedule(
          start: DateTime(2026, 6, 10, 8, 5),
          end: DateTime(2026, 6, 10, 8, 5),
        ),
      ),
      '10/06/2026 08:05',
    );
  });

  test(
    'formats a schedule range as one date with two times on the same day',
    () {
      expect(
        formatScheduleDateTimeRange(
          _schedule(
            start: DateTime(2026, 6, 10, 8, 5),
            end: DateTime(2026, 6, 10, 9, 45),
          ),
        ),
        '10/06/2026 08:05 - 09:45',
      );
    },
  );

  test('formats a schedule range as two datetimes across different days', () {
    expect(
      formatScheduleDateTimeRange(
        _schedule(
          start: DateTime(2026, 6, 10, 8, 5),
          end: DateTime(2026, 6, 11, 9, 45),
        ),
      ),
      '10/06/2026 08:05 - 11/06/2026 09:45',
    );
  });
}

ScheduleModel _schedule({
  required DateTime start,
  required DateTime end,
  ScheduleEventScheduleType scheduleType = ScheduleEventScheduleType.ordinary,
  ScheduleEventRepeatType? repeatType,
}) {
  return ScheduleModel(
    eventId: 'event-1',
    id: 'schedule-1',
    start: start,
    end: end,
    oneDay:
        start.year == end.year &&
        start.month == end.month &&
        start.day == end.day,
    remindAt: null,
    event: ScheduleEventModel(
      id: 'event-1',
      title: 'Planning',
      type: ScheduleEventType.meeting,
      scheduleType: scheduleType,
      startDate: start,
      endDate: end,
      repeatType: repeatType,
      repeatPattern: null,
      startTime: null,
      endTime: null,
      note: null,
      physicalAddress: null,
      privacy: ScheduleEventPrivacy.public,
      isGeneral: false,
      remindRange: null,
      remindValue: null,
      createdBy: 'user-1',
      updatedBy: null,
      createdAt: start,
      updatedAt: start,
      participants: const [],
      observers: const [],
    ),
  );
}

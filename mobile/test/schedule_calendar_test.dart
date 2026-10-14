import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_calendar.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_month_calendar.dart';

void main() {
  test('buildWeekDays returns the Monday-first week around a date', () {
    final days = buildWeekDays(DateTime(2026, 10, 1));

    expect(days.map(scheduleDateKey), [
      '2026-09-28',
      '2026-09-29',
      '2026-09-30',
      '2026-10-01',
      '2026-10-02',
      '2026-10-03',
      '2026-10-04',
    ]);
    expect(scheduleWeekStart(DateTime(2026, 10, 4)), DateTime(2026, 9, 28));
  });

  test('buildYearMonths returns the first day of each month', () {
    final months = buildYearMonths(2026);

    expect(months, hasLength(12));
    expect(months.first, DateTime(2026));
    expect(months.last, DateTime(2026, 12));
  });

  test('scheduleRangeForView covers the active view', () {
    final month = DateTime(2026, 10);
    final focused = DateTime(2026, 10, 14);

    final monthRange = scheduleRangeForView(
      mode: ScheduleViewMode.month,
      month: month,
      focusedDate: focused,
    );
    final weekRange = scheduleRangeForView(
      mode: ScheduleViewMode.week,
      month: month,
      focusedDate: focused,
    );
    final yearRange = scheduleRangeForView(
      mode: ScheduleViewMode.year,
      month: month,
      focusedDate: focused,
    );

    expect(monthRange, scheduleVisibleRange(month));
    expect(weekRange.start, DateTime(2026, 10, 12));
    expect(weekRange.end, DateTime(2026, 10, 18));
    expect(yearRange.start, DateTime(2026));
    expect(yearRange.end, DateTime(2026, 12, 31));
  });

  // The grid should always render full weeks so the month view stays aligned.
  test('buildScheduleCalendar returns full weeks around the month', () {
    final cells = buildScheduleCalendar(DateTime(2026, 6));

    expect(cells.length, 35);
    expect(scheduleDateKey(cells.first.date), '2026-06-01');
    expect(scheduleDateKey(cells.last.date), '2026-07-05');
  });

  test(
    'scheduleVisibleRange matches the first and last visible grid cells',
    () {
      final range = scheduleVisibleRange(DateTime(2026, 8));

      expect(scheduleDateKey(range.start), '2026-07-27');
      expect(scheduleDateKey(range.end), '2026-09-06');
    },
  );

  test(
    'buildScheduleCalendar expands to six weeks when five weeks is not enough',
    () {
      final cells = buildScheduleCalendar(DateTime(2026, 8));

      expect(cells.length, 42);
      expect(scheduleDateKey(cells.first.date), '2026-07-27');
      expect(scheduleDateKey(cells.last.date), '2026-09-06');
    },
  );

  // Day grouping powers both the calendar dots and the detail list beneath the
  // grid, so this verifies inclusive expansion across a multi-day span.
  test('groupSchedulesByDate includes each covered day exactly once', () {
    final grouped = groupSchedulesByDate([
      _schedule(
        id: 'schedule-1',
        start: DateTime(2026, 6, 10, 9),
        end: DateTime(2026, 6, 12, 17),
        scheduleType: ScheduleEventScheduleType.multipleDays,
      ),
    ]);

    expect(grouped.keys, ['2026-06-10', '2026-06-11', '2026-06-12']);
    expect(grouped['2026-06-10']!.single.id, 'schedule-1');
    expect(grouped['2026-06-12']!.single.id, 'schedule-1');
  });

  test(
    'groupSchedulesByDate uses date-only event bounds for multi-day schedules',
    () {
      final grouped = groupSchedulesByDate([
        _schedule(
          id: 'schedule-utc',
          start: DateTime.utc(2026, 6, 30, 17),
          end: DateTime.utc(2026, 7, 3, 17),
          scheduleType: ScheduleEventScheduleType.multipleDays,
          eventStartDate: DateTime(2026, 7, 1),
          eventEndDate: DateTime(2026, 7, 4),
        ),
      ]);

      expect(grouped.keys, [
        '2026-07-01',
        '2026-07-02',
        '2026-07-03',
        '2026-07-04',
      ]);
      expect(grouped['2026-07-01']!.single.id, 'schedule-utc');
      expect(grouped['2026-07-04']!.single.id, 'schedule-utc');
    },
  );

  test(
    'groupSchedulesByDate keeps midnight end exclusive for ordinary schedules',
    () {
      final grouped = groupSchedulesByDate([
        _schedule(
          id: 'schedule-2',
          start: DateTime(2026, 6, 10, 9),
          end: DateTime(2026, 6, 12),
        ),
      ]);

      expect(grouped.keys, ['2026-06-10', '2026-06-11']);
    },
  );

  test(
    'fitText splits words accurately based on measured unconstrained width',
    () {
      const style = TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700);

      // 1. "Đào tạo kỹ năng quản lý"
      // Measure unconstrained width of "Đào tạo kỹ năng quản"
      final pQuang = TextPainter(
        text: const TextSpan(text: 'Đào tạo kỹ năng quản', style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      final r1 = fitText(
        text: 'Đào tạo kỹ năng quản lý',
        style: style,
        maxWidth: pQuang.width + 1.0,
        textDirection: TextDirection.ltr,
      );
      expect(r1.fitted, 'Đào tạo kỹ năng quản');
      expect(r1.remaining, 'lý');

      // 2. Next segment with remaining "lý"
      final r1Next = fitText(
        text: r1.remaining,
        style: style,
        maxWidth: 50.0,
        textDirection: TextDirection.ltr,
      );
      expect(r1Next.fitted, 'lý');
      expect(r1Next.remaining, '');

      // 3. "Hội thảo định hướng sản phẩm"
      final pHoiThao = TextPainter(
        text: const TextSpan(text: 'Hội thảo', style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      final r2 = fitText(
        text: 'Hội thảo định hướng sản phẩm',
        style: style,
        maxWidth: pHoiThao.width + 1.0,
        textDirection: TextDirection.ltr,
      );
      expect(r2.fitted, 'Hội thảo');
      expect(r2.remaining, 'định hướng sản phẩm');

      // 4. "Công tác và làm việc với khách hàng"
      final pCongTac = TextPainter(
        text: const TextSpan(text: 'Công tác và làm việc', style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      final r3 = fitText(
        text: 'Công tác và làm việc với khách hàng',
        style: style,
        maxWidth: pCongTac.width + 1.0,
        textDirection: TextDirection.ltr,
      );
      expect(r3.fitted, 'Công tác và làm việc');
      expect(r3.remaining, 'với khách hàng');
    },
  );
  test('join and leave permissions follow participant and observer rules', () {
    final schedule = _schedule(
      id: 'schedule-1',
      start: DateTime(2026, 6, 10, 9),
      end: DateTime(2026, 6, 10, 10),
      participants: const [],
      observers: const [
        ScheduleUserRef(id: 'user-1', name: 'Lan', avatar: null, email: null),
      ],
    );

    expect(canJoinSchedule(schedule, 'user-1'), true);
    expect(canLeaveSchedule(schedule, 'user-1'), false);
    expect(
      canLeaveSchedule(
        _schedule(
          id: 'schedule-2',
          start: DateTime(2026, 6, 10, 9),
          end: DateTime(2026, 6, 10, 10),
          participants: const [
            ScheduleUserRef(
              id: 'user-1',
              name: 'Lan',
              avatar: null,
              email: null,
            ),
          ],
        ),
        'user-1',
      ),
      true,
    );
  });
}

/// Small fixture builder that keeps the tests focused on the date logic under
/// review instead of verbose object construction.
ScheduleModel _schedule({
  required String id,
  required DateTime start,
  required DateTime end,
  ScheduleEventScheduleType scheduleType = ScheduleEventScheduleType.ordinary,
  DateTime? eventStartDate,
  DateTime? eventEndDate,
  List<ScheduleUserRef> participants = const [],
  List<ScheduleUserRef> observers = const [],
}) {
  return ScheduleModel(
    eventId: 'event-1',
    id: id,
    start: start,
    end: end,
    oneDay: false,
    remindAt: null,
    event: ScheduleEventModel(
      id: 'event-$id',
      title: 'Event $id',
      type: ScheduleEventType.meeting,
      scheduleType: scheduleType,
      startDate: eventStartDate ?? start,
      endDate: eventEndDate ?? end,
      repeatType: null,
      repeatPattern: null,
      startTime: null,
      endTime: null,
      note: null,
      physicalAddress: null,
      privacy: ScheduleEventPrivacy.public,
      isGeneral: false,
      remindRange: null,
      remindValue: null,
      createdBy: 'creator-1',
      updatedBy: null,
      createdAt: start,
      updatedAt: start,
      participants: participants,
      observers: observers,
    ),
  );
}

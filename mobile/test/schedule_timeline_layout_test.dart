import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_timeline_layout.dart';

void main() {
  final day = DateTime(2026, 6, 10);

  test('places non-overlapping events in a single column', () {
    final blocks = layoutDaySchedules(day, [
      _schedule('a', DateTime(2026, 6, 10, 9), DateTime(2026, 6, 10, 10)),
      _schedule('b', DateTime(2026, 6, 10, 10), DateTime(2026, 6, 10, 11)),
    ]);

    expect(blocks.map((block) => block.column), [0, 0]);
    expect(blocks.map((block) => block.columnCount), [1, 1]);
    expect(blocks.first.startMinute, 9 * 60);
    expect(blocks.first.endMinute, 10 * 60);
  });

  test('splits overlapping events into side-by-side columns', () {
    final blocks = layoutDaySchedules(day, [
      _schedule('a', DateTime(2026, 6, 10, 9), DateTime(2026, 6, 10, 11)),
      _schedule('b', DateTime(2026, 6, 10, 10), DateTime(2026, 6, 10, 12)),
      _schedule('c', DateTime(2026, 6, 10, 11), DateTime(2026, 6, 10, 13)),
      _schedule('d', DateTime(2026, 6, 10, 15), DateTime(2026, 6, 10, 16)),
    ]);
    final byId = {for (final block in blocks) block.schedule.id: block};

    expect(byId['a']!.column, 0);
    expect(byId['b']!.column, 1);
    // c starts when a ends, so it reuses the first column.
    expect(byId['c']!.column, 0);
    expect(byId['a']!.columnCount, 2);
    expect(byId['c']!.columnCount, 2);
    expect(byId['d']!.column, 0);
    expect(byId['d']!.columnCount, 1);
  });

  test('clips overnight events to the visible day', () {
    final overnight = _schedule(
      'night',
      DateTime(2026, 6, 9, 22),
      DateTime(2026, 6, 10, 7),
    );

    final previousDay = layoutDaySchedules(DateTime(2026, 6, 9), [overnight]);
    final nextDay = layoutDaySchedules(day, [overnight]);

    expect(previousDay.single.startMinute, 22 * 60);
    expect(previousDay.single.endMinute, 24 * 60);
    expect(nextDay.single.startMinute, 0);
    expect(nextDay.single.endMinute, 7 * 60);
  });

  test('keeps short events at the end of the day visible', () {
    final blocks = layoutDaySchedules(day, [
      _schedule(
        'late',
        DateTime(2026, 6, 10, 23, 55),
        DateTime(2026, 6, 10, 23, 55),
      ),
    ]);

    expect(blocks.single.endMinute, 24 * 60);
    expect(blocks.single.endMinute - blocks.single.startMinute, 15);
  });

  test('routes multi-day and day-long events to the all-day strip', () {
    final multiDay = _schedule(
      'multi',
      DateTime(2026, 6, 9),
      DateTime(2026, 6, 12),
      scheduleType: ScheduleEventScheduleType.multipleDays,
    );
    final fullDay = _schedule(
      'full',
      DateTime(2026, 6, 10),
      DateTime(2026, 6, 11),
    );

    expect(isAllDaySchedule(multiDay), isTrue);
    expect(isAllDaySchedule(fullDay), isTrue);
    expect(layoutDaySchedules(day, [multiDay, fullDay]), isEmpty);
  });
}

ScheduleModel _schedule(
  String id,
  DateTime start,
  DateTime end, {
  ScheduleEventScheduleType scheduleType = ScheduleEventScheduleType.ordinary,
}) {
  return ScheduleModel(
    eventId: 'event-$id',
    id: id,
    start: start,
    end: end,
    oneDay: true,
    remindAt: null,
    event: ScheduleEventModel(
      id: 'event-$id',
      title: id,
      type: ScheduleEventType.meeting,
      scheduleType: scheduleType,
      startDate: start,
      endDate: end,
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
      createdBy: 'user-1',
      updatedBy: null,
      createdAt: start,
      updatedAt: start,
      participants: const [],
      observers: const [],
    ),
  );
}

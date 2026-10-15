import type { Schedule } from '#/api/schedules';

import { describe, expect, it } from 'vitest';

import {
  buildAuthoringPayload,
  buildMonthGrid,
  buildWeekSegments,
  createDraftFromEvent,
  formatAuthoringDate,
  formatAuthoringTime,
  formatScheduleTileMeta,
  getScheduleCardClass,
  getScheduleTypeClass,
  parseMonthValue,
} from './schedule-page';

function makeSchedule(overrides: Partial<Schedule> = {}): Schedule {
  return {
    end: '2026-06-15T17:00:00.000Z',
    event: {
      company_name: null,
      company_phone_number: null,
      created_at: '2026-06-16T08:00:00.000000Z',
      created_by: 'user-1',
      end_date: '2026-06-16',
      end_time: '00:00',
      has_reminder: false,
      id: 'event-1',
      is_general: false,
      note: null,
      observers: [],
      participants: [],
      physical_address: null,
      privacy: 'public',
      remind_range: null,
      remind_value: null,
      repeat_end_time: null,
      repeat_pattern: null,
      repeat_start_time: null,
      repeat_type: null,
      schedule_type: 'ordinary',
      start_date: '2026-06-16',
      start_time: '00:00',
      title: 'Midnight Shift',
      type: 'meeting',
      updated_at: '2026-06-16T08:00:00.000000Z',
      updated_by: null,
    },
    event_id: 'event-1',
    id: 'schedule-1',
    one_day: true,
    remind_at: null,
    start: '2026-06-15T17:00:00.000Z',
    ...overrides,
  };
}

describe('buildMonthGrid', () => {
  it('places a UTC timestamp on its schedule date in the application timezone', () => {
    const schedule = makeSchedule({
      end: '2026-09-24T17:30:00.000Z',
      event: {
        ...makeSchedule().event,
        end_date: '2026-09-25',
        end_time: '00:30',
        start_date: '2026-09-25',
        start_time: '00:26',
      },
      start: '2026-09-24T17:26:00.000Z',
    });
    const grid = buildMonthGrid(
      parseMonthValue('2026-09'),
      [schedule],
      '2026-09-01',
    );

    expect(grid.find(({ date }) => date === '2026-09-25')?.schedules).toContain(
      schedule,
    );
    expect(
      grid.find(({ date }) => date === '2026-09-24')?.schedules,
    ).toHaveLength(0);
  });

  it('keeps multi-day and repeat occurrences on their application dates', () => {
    const multiDaySchedule = makeSchedule({
      end: '2026-09-26T16:59:00.000Z',
      event: {
        ...makeSchedule().event,
        end_date: '2026-09-26',
        end_time: null,
        schedule_type: 'multiple_days',
        start_date: '2026-09-25',
        start_time: null,
      },
      one_day: false,
      start: '2026-09-24T17:00:00.000Z',
    });
    const repeatSchedule = makeSchedule({
      end: '2026-09-24T17:30:00.000Z',
      event: {
        ...makeSchedule().event,
        end_date: '2026-10-11',
        end_time: '00:30',
        repeat_pattern: [5],
        repeat_type: 'weekly',
        schedule_type: 'repeat',
        start_date: '2026-09-25',
        start_time: '00:26',
      },
      id: 'repeat-1',
      start: '2026-09-24T17:26:00.000Z',
    });
    const grid = buildMonthGrid(
      parseMonthValue('2026-09'),
      [multiDaySchedule, repeatSchedule],
      '2026-09-01',
    );

    expect(grid.find(({ date }) => date === '2026-09-25')?.schedules).toEqual(
      expect.arrayContaining([multiDaySchedule, repeatSchedule]),
    );
    expect(grid.find(({ date }) => date === '2026-09-26')?.schedules).toContain(
      multiDaySchedule,
    );
    expect(
      grid.find(({ date }) => date === '2026-09-27')?.schedules,
    ).toHaveLength(0);
    expect(buildWeekSegments(grid.slice(21, 28))).toContainEqual(
      expect.objectContaining({
        columnSpan: 2,
        endDate: '2026-09-26',
        startColumn: 5,
        startDate: '2026-09-25',
      }),
    );
  });

  it('places midnight schedules on the local calendar day', () => {
    const grid = buildMonthGrid(
      parseMonthValue('2026-06'),
      [makeSchedule()],
      '2026-06-01',
      'Asia/Ho_Chi_Minh',
    );
    const day16 = grid.find(({ date }) => date === '2026-06-16');
    const day15 = grid.find(({ date }) => date === '2026-06-15');

    expect(day16?.schedules).toHaveLength(1);
    expect(day15?.schedules).toHaveLength(0);
  });

  it('keeps schedules visible on leading and trailing grid cells across month boundaries', () => {
    const grid = buildMonthGrid(
      parseMonthValue('2026-06'),
      [
        makeSchedule({
          end: '2026-08-10T17:00:00.000Z',
          event: {
            ...makeSchedule().event,
            end_date: '2026-08-10',
            end_time: null,
            schedule_type: 'multiple_days',
            start_date: '2026-05-20',
            start_time: null,
            title: 'Quarter Roadshow',
            type: 'business_trip',
          },
          id: 'schedule-long',
          one_day: false,
          start: '2026-05-20T09:00:00.000Z',
        }),
        makeSchedule({
          end: '2026-07-02T10:00:00.000Z',
          event: {
            ...makeSchedule().event,
            end_date: '2026-07-02',
            end_time: '10:00',
            start_date: '2026-07-02',
            start_time: '09:00',
            title: 'Wrap-up',
          },
          id: 'schedule-next-month',
          start: '2026-07-02T09:00:00.000Z',
        }),
      ],
      '2026-06-01',
      'UTC',
    );

    expect(
      grid
        .find(({ date }) => date === '2026-06-01')
        ?.schedules.map(({ id }) => id),
    ).toContain('schedule-long');
    expect(
      grid
        .find(({ date }) => date === '2026-07-02')
        ?.schedules.map(({ id }) => id),
    ).toContain('schedule-next-month');
    expect(grid.find(({ date }) => date === '2026-07-05')).toBeDefined();
    expect(grid.find(({ date }) => date === '2026-07-06')).toBeUndefined();
  });
});

describe('buildWeekSegments', () => {
  it('builds a single spanning segment for a multi-day schedule inside one week', () => {
    const grid = buildMonthGrid(
      parseMonthValue('2026-06'),
      [
        makeSchedule({
          end: '2026-06-21T17:00:00.000Z',
          event: {
            ...makeSchedule().event,
            end_date: '2026-06-21',
            end_time: null,
            schedule_type: 'multiple_days',
            start_date: '2026-06-20',
            start_time: null,
            title: 'Roadshow',
            type: 'business_trip',
          },
          id: 'schedule-3',
          one_day: false,
          start: '2026-06-20T09:00:00.000Z',
        }),
      ],
      '2026-06-01',
      'Asia/Ho_Chi_Minh',
    );
    const segments = buildWeekSegments(grid.slice(14, 21), 'Asia/Ho_Chi_Minh');

    expect(segments).toEqual([
      expect.objectContaining({
        columnSpan: 2,
        endDate: '2026-06-21',
        startColumn: 6,
        startDate: '2026-06-20',
      }),
    ]);
  });

  it('continues a multi-day schedule with a new segment at the next week boundary', () => {
    const grid = buildMonthGrid(
      parseMonthValue('2026-06'),
      [
        makeSchedule({
          end: '2026-07-02T17:00:00.000Z',
          event: {
            ...makeSchedule().event,
            end_date: '2026-07-02',
            end_time: null,
            schedule_type: 'multiple_days',
            start_date: '2026-06-28',
            start_time: null,
            title: 'Week boundary event',
          },
          one_day: false,
          start: '2026-06-28T09:00:00.000Z',
        }),
      ],
      '2026-06-01',
      'UTC',
    );

    expect(buildWeekSegments(grid.slice(21, 28), 'UTC')).toEqual([
      expect.objectContaining({
        columnSpan: 1,
        endDate: '2026-06-28',
        startColumn: 7,
        startDate: '2026-06-28',
      }),
    ]);
    expect(buildWeekSegments(grid.slice(28, 35), 'UTC')).toEqual([
      expect.objectContaining({
        columnSpan: 4,
        endDate: '2026-07-02',
        startColumn: 1,
        startDate: '2026-06-29',
      }),
    ]);
  });
});

describe('formatScheduleTileMeta', () => {
  it('formats schedule times in the application timezone by default', () => {
    expect(
      formatScheduleTileMeta(
        makeSchedule({
          end: '2026-09-24T17:30:00.000Z',
          start: '2026-09-24T17:26:00.000Z',
        }),
      ),
    ).toBe('00:26 - 00:30');
  });

  it('shows a single time when start and end times are equal', () => {
    expect(
      formatScheduleTileMeta(
        makeSchedule({
          end: '2026-06-16T09:00:00.000Z',
          start: '2026-06-16T09:00:00.000Z',
        }),
        'UTC',
      ),
    ).toBe('09:00');
  });
});

describe('schedule color classes', () => {
  it('returns static tailwind classes for schedule type pills', () => {
    expect(
      getScheduleTypeClass(
        makeSchedule({
          event: {
            ...makeSchedule().event,
            type: 'training',
          },
        }),
      ),
    ).toContain('bg-[#3182dc]');
  });

  it('returns solid type colors for multi-day schedule bars', () => {
    const multiDaySchedule = makeSchedule({
      event: {
        ...makeSchedule().event,
        schedule_type: 'multiple_days',
        type: 'interview',
      },
      one_day: false,
    });
    const classes = getScheduleCardClass(multiDaySchedule);

    expect(classes).toContain('bg-[#ef9201]');
    expect(classes).toContain('text-white');
  });

  it('uses a clean borderless style for repeat schedule tiles', () => {
    const schedule = makeSchedule();
    const repeatSchedule = makeSchedule({
      event: {
        ...schedule.event,
        schedule_type: 'repeat',
      },
    });
    const repeatClasses = getScheduleCardClass(repeatSchedule);

    expect(repeatClasses).not.toContain('border-dashed');
    expect(repeatClasses).not.toContain('border-');
    expect(repeatClasses).toBe(getScheduleCardClass(schedule));
  });
});

describe('authoring helpers', () => {
  it('formats backend UTC datetimes and YYYY-MM-DD strings to authoring dates', () => {
    expect(formatAuthoringDate('2026-06-15T17:00:00.000Z')).toBe('2026-06-16');
    expect(formatAuthoringDate('2026-06-16')).toBe('2026-06-16');
  });

  it('formats authoring times directly without timezone conversion', () => {
    expect(formatAuthoringTime(null)).toBe('');
    expect(formatAuthoringTime('09:30')).toBe('09:30');
  });

  it('hydrates draft and builds normalized write payloads across cadence types', () => {
    const draft = createDraftFromEvent(
      makeSchedule({
        event: {
          ...makeSchedule().event,
          end_date: '2026-06-16',
          end_time: '10:30',
          remind_range: 'minute',
          remind_value: 15,
          start_date: '2026-06-16',
          start_time: '09:00',
        },
      }),
      'edit',
    );

    expect(draft.has_reminder).toBe(true);
    expect(draft.start_time).toBe('09:00');
    expect(draft.end_time).toBe('10:30');
    expect(buildAuthoringPayload(draft)).toMatchObject({
      end_date: '2026-06-16',
      end_time: '10:30',
      remind_range: 'minute',
      remind_value: 15,
      repeat_pattern: null,
      repeat_type: null,
      schedule_type: 'ordinary',
      start_date: '2026-06-16',
      start_time: '09:00',
    });
  });
});

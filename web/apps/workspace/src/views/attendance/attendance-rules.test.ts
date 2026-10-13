import type {
  AttendanceLocation,
  AttendanceRangeSummary,
} from '#/api/contracts';

import { describe, expect, it } from 'vitest';

import {
  buildAttendanceCalendarCells,
  evaluateAttendanceEligibility,
  formatWorkSeconds,
  getAttendanceCellSurfaceClasses,
  getAttendanceSummaryStatus,
  haversineMeters,
} from './attendance-rules';

function makeLocation(
  validationMode: AttendanceLocation['validation_mode'],
): AttendanceLocation {
  return {
    created_at: '2026-06-23T08:00:00+07:00',
    departments: [],
    excluded_users: [],
    id: 'location-1',
    ips: [
      {
        attendance_location_id: 'location-1',
        created_at: '2026-06-23T08:00:00+07:00',
        id: 'ip-1',
        ip_address: '127.0.0.1',
        updated_at: '2026-06-23T08:00:00+07:00',
      },
    ],
    is_active: true,
    latitude: 10,
    longitude: 106,
    name: 'HQ',
    radius_meters: 150,
    updated_at: '2026-06-23T08:00:00+07:00',
    users: [],
    validation_mode: validationMode,
  };
}

function makeSummary(
  date: string,
  logsCount: number,
  totalWorkSeconds: number,
  onLeave = false,
): AttendanceRangeSummary {
  return {
    date,
    first_check_in_at: logsCount === 0 ? null : `${date}T08:00:00+07:00`,
    last_check_out_at: logsCount < 2 ? null : `${date}T17:30:00+07:00`,
    logs_count: logsCount,
    on_leave: onLeave,
    total_work_seconds: totalWorkSeconds,
  };
}

describe('attendance rules', () => {
  it('calculates haversine distance in meters', () => {
    expect(
      haversineMeters(
        { latitude: 10, longitude: 106 },
        { latitude: 10.001, longitude: 106 },
      ),
    ).toBeCloseTo(111.2, 0);
  });

  it.each([
    ['location', true, false, true],
    ['ip', false, true, true],
    ['both', true, true, true],
    ['both', true, false, false],
    ['either', false, true, true],
    ['either', false, false, false],
  ] as const)(
    'evaluates %s validation mode',
    (mode, locationShouldMatch, ipShouldMatch, expected) => {
      const position = locationShouldMatch
        ? { latitude: 10, longitude: 106 }
        : { latitude: 11, longitude: 106 };
      const ipAddress = ipShouldMatch ? '127.0.0.1' : '10.0.0.2';

      expect(
        evaluateAttendanceEligibility(makeLocation(mode), position, ipAddress)
          .eligible,
      ).toBe(expected);
    },
  );

  it('builds month cells with Monday-first padding', () => {
    const cells = buildAttendanceCalendarCells('2026-06', [
      makeSummary('2026-06-01', 2, 34_200),
      makeSummary('2026-06-02', 1, 0),
    ]);

    expect(cells).toHaveLength(35);
    expect(cells[0]).toMatchObject({
      date: '2026-06-01',
      dayNumber: 1,
      inMonth: true,
      status: 'punched',
      workHours: '9:30',
    });
    expect(cells[1]).toMatchObject({
      date: '2026-06-02',
      status: 'deficient',
    });
    expect(cells[34]).toMatchObject({
      date: '2026-07-05',
      inMonth: false,
    });
  });

  it('formats work seconds and summary status from logs_count', () => {
    expect(formatWorkSeconds(34_200)).toBe('9:30');
    expect(getAttendanceSummaryStatus(undefined)).toBe('empty');
    expect(getAttendanceSummaryStatus(makeSummary('2026-06-01', 0, 0))).toBe(
      'empty',
    );
    expect(
      getAttendanceSummaryStatus(makeSummary('2026-06-01', 0, 0, true)),
    ).toBe('leave');
    expect(getAttendanceSummaryStatus(makeSummary('2026-06-01', 1, 0))).toBe(
      'deficient',
    );
    expect(
      getAttendanceSummaryStatus(makeSummary('2026-06-01', 2, 34_200)),
    ).toBe('punched');
  });

  it('maps calendar cell status to theme-aware surface classes', () => {
    expect(
      getAttendanceCellSurfaceClasses({
        inMonth: true,
        isFuture: false,
        status: 'leave',
      }),
    ).toEqual(
      expect.arrayContaining([
        'cursor-pointer',
        'bg-blue-500/10',
        'dark:bg-blue-500/18',
        'dark:ring-blue-500/35',
      ]),
    );
    expect(
      getAttendanceCellSurfaceClasses({
        inMonth: false,
        isFuture: false,
        status: 'empty',
      }),
    ).toEqual([
      'bg-muted/10',
      'dark:bg-muted/20',
      'text-muted-foreground/35',
      'dark:text-muted-foreground/50',
      'pointer-events-none',
    ]);
  });
});

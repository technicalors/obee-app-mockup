import type { User } from '#/api/contracts';
import type { Schedule } from '#/api/schedules';

import { describe, expect, it } from 'vitest';

import {
  buildDepartmentUserTreeOptions,
  buildMonthGrid,
  buildWeekSegments,
  formatAuthoringDate,
  formatScheduleTileMeta,
  getDraftTimeValue,
  getScheduleCardClass,
  getScheduleTypeClass,
  parseMonthValue,
} from './schedule-page';

function makeUser(overrides: Partial<User> = {}): User {
  return {
    avatar: null,
    company: {
      created_at: '2026-06-16T08:00:00.000000Z',
      id: 'company-1',
      name: 'Obee Company',
      tax_identification_number: '123456789',
      updated_at: '2026-06-16T08:00:00.000000Z',
    },
    company_id: 'company-1',
    created_at: '2026-06-16T08:00:00.000000Z',
    departments: [],
    email: 'owner@example.com',
    email_verified_at: null,
    id: 'user-1',
    is_active: true,
    name: 'Owner User',
    profile: null,
    roles: [],
    supabase_id: null,
    updated_at: '2026-06-16T08:00:00.000000Z',
    username: 'owner',
    ...overrides,
  };
}

function makeSchedule(overrides: Partial<Schedule> = {}): Schedule {
  return {
    end: '2026-06-15T17:00:00.000Z',
    event: {
      company_name: null,
      company_phone_number: null,
      created_at: '2026-06-16T08:00:00.000000Z',
      created_by: 'user-1',
      end_date: '2026-06-15T17:00:00.000Z',
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
      start_date: '2026-06-15T17:00:00.000Z',
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
            end_date: '2026-08-10T17:00:00.000Z',
            schedule_type: 'multiple_days',
            start_date: '2026-05-20T09:00:00.000Z',
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
            end_date: '2026-07-02T10:00:00.000Z',
            start_date: '2026-07-02T09:00:00.000Z',
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
            end_date: '2026-06-21T17:00:00.000Z',
            schedule_type: 'multiple_days',
            start_date: '2026-06-20T09:00:00.000Z',
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
});

describe('buildDepartmentUserTreeOptions', () => {
  it('groups users under nested departments and keeps users without departments selectable', () => {
    const parentDepartment = {
      children: [],
      company: null,
      company_id: 'company-1',
      created_at: null,
      id: 'department-parent',
      name: 'Operations',
      parent: null,
      parent_id: null,
      updated_at: null,
    };

    expect(
      buildDepartmentUserTreeOptions([
        makeUser({
          departments: [
            {
              children: [],
              company: null,
              company_id: 'company-1',
              created_at: null,
              id: 'department-child',
              name: 'Field Team',
              parent: parentDepartment,
              parent_id: 'department-parent',
              updated_at: null,
            },
          ],
        }),
        makeUser({
          departments: [
            {
              children: [],
              company: null,
              company_id: 'company-1',
              created_at: null,
              id: 'department-child',
              name: 'Field Team',
              parent: parentDepartment,
              parent_id: 'department-parent',
              updated_at: null,
            },
          ],
          email: 'participant@example.com',
          id: 'user-2',
          name: 'Participant User',
          username: 'participant',
        }),
        makeUser({
          email: 'solo@example.com',
          id: 'user-3',
          name: 'Solo User',
          username: 'solo',
        }),
      ]),
    ).toEqual([
      {
        children: [
          {
            children: [
              {
                children: [
                  {
                    key: 'user-1',
                    label: 'Owner User',
                    value: 'user-1',
                  },
                  {
                    key: 'user-2',
                    label: 'Participant User',
                    value: 'user-2',
                  },
                ],
                key: 'department-department-child',
                label: 'Field Team',
                selectable: false,
                value: 'department-department-child',
              },
            ],
            key: 'department-department-parent',
            label: 'Operations',
            selectable: false,
            value: 'department-department-parent',
          },
          { key: 'user-3', label: 'Solo User', value: 'user-3' },
        ],
        key: 'company-company-1',
        label: 'Obee Company',
        selectable: false,
        value: 'company-company-1',
      },
    ]);
  });

  it('falls back to department and user roots when company data is unavailable', () => {
    expect(
      buildDepartmentUserTreeOptions([
        makeUser({
          company: null,
          departments: [
            {
              children: [],
              company: null,
              company_id: 'company-1',
              created_at: null,
              id: 'department-parent',
              name: 'Operations',
              parent: null,
              parent_id: null,
              updated_at: null,
            },
          ],
        }),
      ]),
    ).toEqual([
      {
        children: [{ key: 'user-1', label: 'Owner User', value: 'user-1' }],
        key: 'department-department-parent',
        label: 'Operations',
        selectable: false,
        value: 'department-department-parent',
      },
    ]);
  });
});

describe('formatScheduleTileMeta', () => {
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

  it('returns static tailwind classes for multi-day schedule tiles', () => {
    expect(
      getScheduleCardClass(
        makeSchedule({
          event: {
            ...makeSchedule().event,
            schedule_type: 'multiple_days',
            type: 'interview',
          },
          one_day: false,
        }),
      ),
    ).toContain('border-[#ef9201]');
  });
});

describe('authoring timezone helpers', () => {
  it('formats backend UTC datetimes to GMT+7 authoring dates', () => {
    expect(formatAuthoringDate('2026-06-15T17:00:00.000Z')).toBe('2026-06-16');
  });

  it('formats backend UTC datetimes to GMT+7 authoring times when repeat time is absent', () => {
    expect(getDraftTimeValue(null, '2026-06-15T17:00:00.000Z')).toBe('00:00');
  });

  it('keeps explicit repeat time values unchanged', () => {
    expect(getDraftTimeValue('09:30:00', '2026-06-15T17:00:00.000Z')).toBe(
      '09:30',
    );
  });
});

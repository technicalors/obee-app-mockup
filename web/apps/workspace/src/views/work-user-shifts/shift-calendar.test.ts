import type {
  OrganizationHierarchy,
  UserTreeSelectionUser,
} from '#/api/contracts';
import type { WorkUserShift } from '#/api/work-user-shifts';

import { describe, expect, it } from 'vitest';

import {
  buildMonthCalendarGrid,
  buildShiftLookup,
  buildWorkShiftRangePayload,
  filterWorkShiftAssignableUsers,
  formatShiftTime,
  getIncludedWorkDates,
  getMonthDateRange,
  resolveWorkShiftRootOrganizationId,
  summarizeWorkShiftRange,
} from './shift-calendar';

const mockRootOrganization: OrganizationHierarchy = {
  created_at: '2026-06-01T00:00:00Z',
  id: 'root-1',
  name: 'Root 1',
  parent: null,
  parent_id: null,
  tax_identification_number: null,
  type: 'Công ty',
  updated_at: '2026-06-01T00:00:00Z',
};

const mockUser1 = {
  avatar: null,
  organization_id: 'root-1',
  created_at: '2026-06-01T00:00:00Z',
  email: 'user1@example.com',
  email_verified_at: null,
  id: 'user-1',
  deleted_at: null,
  name: 'User 1',
  supabase_id: null,
  updated_at: '2026-06-01T00:00:00Z',
  username: 'user1',
};

function createShift(overrides: Partial<WorkUserShift> = {}): WorkUserShift {
  return {
    root_organization: mockRootOrganization,
    root_organization_id: 'root-1',
    created_at: null,
    created_by: 'admin-1',
    creator: mockUser1,
    end_at: '2026-06-06T12:00:00Z',
    id: 'shift-1',
    work_shift_id: 'SHIFT_MORNING',
    start_at: '2026-06-06T08:00:00Z',
    updated_at: null,
    user: mockUser1,
    user_id: 'user-1',
    work_date: '2026-06-06',
    work_shift: {
      id: 'definition',
      root_organization_id: 'root-org',
      name: 'Ca tùy chỉnh',
      created_by: 'creator',
      created_at: null,
      updated_at: null,
      periods: [
        {
          id: 'p1',
          work_shift_id: 'definition',
          start_time: '08:00:00',
          end_time: '12:00:00',
          start_day_offset: 0,
          end_day_offset: 0,
          created_at: null,
          updated_at: null,
        },
      ],
    },
    work_periods: [
      { start_at: '2026-10-05T01:00:00Z', end_at: '2026-10-05T05:00:00Z' },
    ],
    ...overrides,
  };
}

function selectionUser(
  id: string,
  rootOrganizationId: string,
): UserTreeSelectionUser {
  const rootOrganization = {
    ...mockRootOrganization,
    id: rootOrganizationId,
  };
  const organization: OrganizationHierarchy = {
    ...rootOrganization,
    id: `organization-${id}`,
    name: 'Organization',
    parent_id: rootOrganization.id,
    parent: rootOrganization,
    type: 'Nhóm',
  };
  return {
    ...mockUser1,
    id,
    profile: null,
    organization_id: organization.id,
    organization,
  };
}

describe('work shift helpers', () => {
  it('builds an explicit range payload with overwrite enabled', () => {
    expect(
      buildWorkShiftRangePayload({
        rootOrganizationId: 'root-1',
        dateFrom: '2026-05-29',
        dateTo: '2026-06-03',
        selectedWeekdays: [2, 3, 4, 5, 6],
        workShiftId: 'SHIFT_FULL_DAY',
        repeatEveryWeeks: 1,
        userIds: ['user-1', 'user-2'],
      }),
    ).toEqual({
      root_organization_id: 'root-1',
      date_from: '2026-05-29',
      date_to: '2026-06-03',
      repeat_every_weeks: 1,
      selected_weekdays: [2, 3, 4, 5, 6],
      work_shift_id: 'SHIFT_FULL_DAY',
      user_ids: ['user-1', 'user-2'],
    });
  });

  it('uses selected Vietnamese weekday numbers across month boundaries', () => {
    expect(
      getIncludedWorkDates('2026-05-29', '2026-06-03', [2, 3, 4, 5, 6]),
    ).toEqual(['2026-05-29', '2026-06-01', '2026-06-02', '2026-06-03']);
  });

  it('summarizes selected users and included work dates', () => {
    expect(
      summarizeWorkShiftRange({
        dateFrom: '2026-06-01',
        dateTo: '2026-06-07',
        selectedWeekdays: [2, 3, 4, 5, 6, 7],
        workShiftId: 'SHIFT_MORNING',
        repeatEveryWeeks: 1,
        userIds: ['user-1', 'user-2'],
      }),
    ).toEqual({
      includedDays: 6,
      selectedUsers: 2,
      totalAssignments: 12,
    });
  });

  it('keys shifts by user and work date', () => {
    const shifts: WorkUserShift[] = [createShift()];

    expect(buildShiftLookup(shifts).get('user-1:2026-06-06')).toEqual(
      shifts[0],
    );
  });

  it('gets the full date range for a selected month', () => {
    expect(getMonthDateRange('2026-02')).toEqual({
      dateFrom: '2026-02-01',
      dateTo: '2026-02-28',
    });
  });

  it('uses each selection user root Organization and excludes inactive users', () => {
    const one = selectionUser('user-1', 'root-1');
    const two = selectionUser('user-2', 'root-1');
    const inactive = {
      ...selectionUser('user-3', 'root-1'),
      deleted_at: '2026-01-01T00:00:00.000000Z',
    };
    const other = selectionUser('user-4', 'root-2');
    const users = [one, two, inactive, other];
    expect(filterWorkShiftAssignableUsers(users)).toEqual([one, two, other]);
    expect(
      resolveWorkShiftRootOrganizationId(users, ['user-1', 'user-2']),
    ).toBe('root-1');
    expect(
      resolveWorkShiftRootOrganizationId(users, ['user-1', 'user-4']),
    ).toBeNull();
    expect(resolveWorkShiftRootOrganizationId(users, ['missing'])).toBeNull();
    expect(resolveWorkShiftRootOrganizationId(users, [])).toBeNull();
  });

  it('builds month calendar grid with correct leading and trailing days', () => {
    const grid = buildMonthCalendarGrid('2026-06');
    expect(grid.length).toBe(35);
    expect(grid[0]?.date).toBe('2026-06-01');
    expect(grid[0]?.isCurrentMonth).toBe(true);
    expect(grid[0]?.uiWeekday).toBe(2); // Monday

    const lastDay = grid[grid.length - 1];
    expect(lastDay?.date).toBe('2026-07-05');
    expect(lastDay?.isCurrentMonth).toBe(false);
    expect(lastDay?.isSunday).toBe(true);
    expect(lastDay?.uiWeekday).toBe(8); // Sunday
  });

  it('formats shift time to HH:mm in target timezone', () => {
    expect(formatShiftTime('2026-06-01T08:00:00Z', 'UTC')).toBe('08:00');
    expect(formatShiftTime('2026-06-01T01:00:00Z', 'Asia/Ho_Chi_Minh')).toBe(
      '08:00',
    );
  });
});

describe('calendar week recurrence', () => {
  it('anchors to Monday and skips intervening weeks across year boundaries', () => {
    expect(getIncludedWorkDates('2026-12-31', '2027-01-21', [2, 5], 2)).toEqual(
      ['2026-12-31', '2027-01-11', '2027-01-14'],
    );
  });
});

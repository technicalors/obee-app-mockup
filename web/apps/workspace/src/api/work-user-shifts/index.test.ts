import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  createWorkUserShiftRange,
  deleteWorkUserShift,
  getWorkUserShifts,
  updateWorkUserShift,
} from './index';

const requestClient = vi.hoisted(() => ({
  delete: vi.fn(),
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
}));

vi.mock('#/api/request', () => ({ requestClient }));

const user = {
  avatar: null,
  organization_id: 'root-1',
  created_at: '2026-09-01T00:00:00Z',
  email: 'employee@example.com',
  email_verified_at: null,
  id: 'user-1',
  deleted_at: null,
  name: 'Nguyen An',
  supabase_id: null,
  updated_at: '2026-09-01T00:00:00Z',
  username: 'nguyen.an',
};

const shift = {
  root_organization: {
    created_at: '2026-09-01T00:00:00Z',
    id: 'root-1',
    name: 'Acme',
    parent_id: null,
    tax_identification_number: null,
    type: 'Công ty',
    updated_at: '2026-09-01T00:00:00Z',
  },
  root_organization_id: 'root-1',
  created_at: '2026-09-28T10:00:00Z',
  created_by: 'manager-1',
  creator: { ...user, id: 'manager-1', name: 'Manager' },
  end_at: '2026-10-05T17:00:00Z',
  id: 'shift-1',
  work_shift_id: 'SHIFT_FULL_DAY',
  start_at: '2026-10-05T08:00:00Z',
  updated_at: '2026-09-28T10:00:00Z',
  user,
  user_id: 'user-1',
  work_date: '2026-10-05',
  work_shift: {
    id: 'definition',
    root_organization_id: 'root-org',
    code: 'CUSTOM',
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
};

describe('work user shift API', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('loads one employee month and writes a selected weekday range', async () => {
    requestClient.get.mockResolvedValue([shift]);
    requestClient.post.mockResolvedValue([shift]);

    await expect(
      getWorkUserShifts({
        root_organization_id: 'root-1',
        from: '2026-10-01',
        to: '2026-10-31',
        user_id: 'user-1',
      }),
    ).resolves.toHaveLength(1);
    expect(requestClient.get).toHaveBeenCalledWith('/work-user-shifts', {
      params: {
        root_organization_id: 'root-1',
        from: '2026-10-01',
        to: '2026-10-31',
        user_id: 'user-1',
      },
    });

    const payload = {
      root_organization_id: 'root-1',
      date_from: '2026-10-05',
      date_to: '2026-10-09',
      repeat_every_weeks: 1,
      selected_weekdays: [2, 3, 4, 5, 6],
      work_shift_id: 'SHIFT_FULL_DAY' as const,
      user_ids: ['user-1', 'user-2'],
    };
    await expect(createWorkUserShiftRange(payload)).resolves.toHaveLength(1);
    expect(requestClient.post).toHaveBeenCalledWith(
      '/work-user-shifts/range',
      payload,
    );
  });

  it('updates and deletes one assignment', async () => {
    requestClient.put.mockResolvedValue({
      ...shift,
      work_shift_id: 'SHIFT_MORNING',
    });
    requestClient.delete.mockResolvedValue(undefined);

    await expect(
      updateWorkUserShift('shift-1', 'SHIFT_MORNING'),
    ).resolves.toMatchObject({ work_shift_id: 'SHIFT_MORNING' });
    expect(requestClient.put).toHaveBeenCalledWith(
      '/work-user-shifts/shift-1',
      { work_shift_id: 'SHIFT_MORNING' },
    );

    await deleteWorkUserShift('shift-1');
    expect(requestClient.delete).toHaveBeenCalledWith(
      '/work-user-shifts/shift-1',
    );
  });

  it('rejects a reversed date range before sending it', async () => {
    await expect(
      createWorkUserShiftRange({
        root_organization_id: 'root-1',
        date_from: '2026-10-09',
        date_to: '2026-10-05',
        repeat_every_weeks: 1,
        selected_weekdays: [2],
        work_shift_id: 'SHIFT_FULL_DAY',
        user_ids: ['user-1'],
      }),
    ).rejects.toThrow(/date_to/);
    expect(requestClient.post).not.toHaveBeenCalled();
  });
});

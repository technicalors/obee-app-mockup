import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  createWorkShift,
  createWorkShiftSchema,
  deleteWorkShift,
  getWorkShifts,
  updateWorkShift,
  updateWorkShiftSchema,
} from './index';

const requestClient = vi.hoisted(() => ({
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
  delete: vi.fn(),
}));
vi.mock('#/api/request', () => ({ requestClient }));

const periods = [
  {
    start_time: '22:00:00',
    end_time: '02:00:00',
    start_day_offset: 0,
    end_day_offset: 1,
  },
  {
    start_time: '03:00:00',
    end_time: '06:00:00',
    start_day_offset: 1,
    end_day_offset: 1,
  },
];
const configuration = { name: 'Ca đêm', periods };
const definition = {
  ...configuration,
  id: 'definition',
  root_organization_id: 'root',
  created_by: 'creator',
  created_at: null,
  updated_at: null,
  periods: periods.map((period, index) => ({
    ...period,
    id: `period-${index}`,
    work_shift_id: 'definition',
    created_at: null,
    updated_at: null,
  })),
};

describe('dynamic work shift API', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('reads catalogs and persists exact overnight offsets without status fields', async () => {
    requestClient.get.mockResolvedValue([definition]);
    requestClient.post.mockResolvedValue(definition);
    requestClient.put.mockResolvedValue({ ...definition, name: 'Ca đêm mới' });
    expect(await getWorkShifts('root')).toEqual([definition]);
    const payload = { ...configuration, root_organization_id: 'root' };
    expect(await createWorkShift(payload)).toEqual(definition);
    expect(requestClient.post).toHaveBeenCalledWith('/work-shifts', payload);
    expect(
      await updateWorkShift('definition', {
        ...configuration,
        name: 'Ca đêm mới',
      }),
    ).toEqual({ ...definition, name: 'Ca đêm mới' });
    await deleteWorkShift('definition');
    expect(requestClient.delete).toHaveBeenCalledWith(
      '/work-shifts/definition',
    );
  });

  it('rejects overlapping or reversed periods and status at the boundary', () => {
    expect(
      updateWorkShiftSchema.safeParse({
        ...configuration,
        periods: [{ ...periods[0], end_day_offset: 0 }],
      }).success,
    ).toBe(false);
    expect(
      updateWorkShiftSchema.safeParse({
        ...configuration,
        periods: [{ ...periods[0], end_time: '04:00:00' }, periods[1]],
      }).success,
    ).toBe(false);
    expect(
      updateWorkShiftSchema.safeParse({
        ...configuration,
        periods: [{ ...periods[1] }],
      }).success,
    ).toBe(false);
    expect(
      createWorkShiftSchema.safeParse({
        ...configuration,
        root_organization_id: 'root',
        status: 'active',
      }).success,
    ).toBe(false);
    expect(
      updateWorkShiftSchema.safeParse({ ...configuration, periods: [] })
        .success,
    ).toBe(false);
  });

  it('requires a name and rejects removed shift codes', () => {
    expect(
      updateWorkShiftSchema.safeParse({ ...configuration, name: '' }).success,
    ).toBe(false);
    expect(
      updateWorkShiftSchema.safeParse({ ...configuration, name: '   ' })
        .success,
    ).toBe(false);
    expect(
      updateWorkShiftSchema.safeParse({ ...configuration, code: 'NIGHT' })
        .success,
    ).toBe(false);
    expect(
      updateWorkShiftSchema.parse({ ...configuration, name: ' Ca đêm ' }).name,
    ).toBe('Ca đêm');
  });

  it('propagates transport failures and rejects incomplete catalog data', async () => {
    requestClient.get.mockResolvedValue([{ ...definition, periods: [] }]);
    await expect(getWorkShifts('root')).rejects.toThrow(/periods/);
    requestClient.put.mockRejectedValue(new Error('conflicting assignment'));
    await expect(updateWorkShift('definition', configuration)).rejects.toThrow(
      'conflicting assignment',
    );
  });
});

import { z } from '@vben/common-ui';

import { requestClient } from '#/api/request';

export const workShiftPeriodInputSchema = z
  .object({
    start_time: z.string().regex(/^([01]\d|2[0-3]):[0-5]\d:[0-5]\d$/),
    end_time: z.string().regex(/^([01]\d|2[0-3]):[0-5]\d:[0-5]\d$/),
    start_day_offset: z.number().int().min(0).max(1),
    end_day_offset: z.number().int().min(0).max(1),
  })
  .strict();

export const workShiftPeriodSchema = workShiftPeriodInputSchema.extend({
  id: z.string(),
  work_shift_id: z.string(),
  created_at: z.string().nullable(),
  updated_at: z.string().nullable(),
});

export const workShiftSchema = z.object({
  id: z.string(),
  root_organization_id: z.string(),
  name: z.string(),
  created_by: z.string(),
  created_at: z.string().nullable(),
  updated_at: z.string().nullable(),
  periods: workShiftPeriodSchema.array().min(1),
});

const seconds = (time: string): number =>
  Number(time.slice(0, 2)) * 3600 +
  Number(time.slice(3, 5)) * 60 +
  Number(time.slice(6, 8));

const workShiftConfigurationSchema = z
  .object({
    name: z.string().trim().min(1).max(255),
    periods: workShiftPeriodInputSchema.array().min(1).max(24),
  })
  .strict();

export const updateWorkShiftSchema = workShiftConfigurationSchema.refine(
  (value) => {
    const ranges = value.periods
      .map((period) => ({
        start: period.start_day_offset * 86_400 + seconds(period.start_time),
        end: period.end_day_offset * 86_400 + seconds(period.end_time),
      }))
      .toSorted((a, b) => a.start - b.start);
    const first = ranges[0];
    if (first === undefined || first.start >= 86_400) return false;
    let previousEnd = -1;
    for (const range of ranges) {
      if (range.end <= range.start || range.start < previousEnd) return false;
      previousEnd = range.end;
    }
    return true;
  },
  { path: ['periods'] },
);

export const createWorkShiftSchema = z
  .object({
    ...workShiftConfigurationSchema.shape,
    root_organization_id: z.string().min(1),
  })
  .strict()
  .refine(
    ({ root_organization_id: _root, ...configuration }) =>
      updateWorkShiftSchema.safeParse(configuration).success,
    { path: ['periods'] },
  );

export type WorkShift = z.infer<typeof workShiftSchema>;
export type WorkShiftPeriod = z.infer<typeof workShiftPeriodSchema>;
export type CreateWorkShift = z.infer<typeof createWorkShiftSchema>;
export type UpdateWorkShift = z.infer<typeof updateWorkShiftSchema>;

export async function getWorkShifts(
  rootOrganizationId: string,
): Promise<WorkShift[]> {
  return workShiftSchema.array().parse(
    await requestClient.get<unknown>('/work-shifts', {
      params: { root_organization_id: rootOrganizationId },
    }),
  );
}

export async function createWorkShift(
  payload: CreateWorkShift,
): Promise<WorkShift> {
  return workShiftSchema.parse(
    await requestClient.post<unknown>(
      '/work-shifts',
      createWorkShiftSchema.parse(payload),
    ),
  );
}

export async function updateWorkShift(
  id: string,
  payload: UpdateWorkShift,
): Promise<WorkShift> {
  return workShiftSchema.parse(
    await requestClient.put<unknown>(
      `/work-shifts/${id}`,
      updateWorkShiftSchema.parse(payload),
    ),
  );
}

export async function deleteWorkShift(id: string): Promise<void> {
  await requestClient.delete(`/work-shifts/${id}`);
}

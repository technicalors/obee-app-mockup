import { z } from '@vben/common-ui';

import { organizationSchema, userSchema } from '#/api/contracts';
import { requestClient } from '#/api/request';
import { workShiftSchema } from '#/api/work-shifts';

const shiftUserSchema = userSchema.omit({
  organization: true,
  profile: true,
  roles: true,
});

export const workUserShiftSchema = z.object({
  root_organization: organizationSchema,
  root_organization_id: z.string(),
  created_at: z.string().nullable(),
  created_by: z.string(),
  creator: shiftUserSchema,
  end_at: z.string(),
  id: z.string(),
  work_shift_id: z.string().min(1),
  work_shift: workShiftSchema,
  work_periods: z
    .object({ start_at: z.string(), end_at: z.string() })
    .array()
    .min(1),
  start_at: z.string(),
  updated_at: z.string().nullable(),
  user: shiftUserSchema,
  user_id: z.string(),
  work_date: z.string().date(),
});

export const createWorkUserShiftRangeSchema = z
  .object({
    root_organization_id: z.string().min(1),
    date_from: z.string().date(),
    date_to: z.string().date(),
    repeat_every_weeks: z.number().int().min(1).max(52),
    selected_weekdays: z.array(z.number().int().min(2).max(8)).min(1),
    work_shift_id: z.string().min(1),
    user_ids: z.array(z.string().min(1)).min(1),
  })
  .strict()
  .refine((value) => value.date_to >= value.date_from, {
    path: ['date_to'],
  });

export type WorkUserShift = z.infer<typeof workUserShiftSchema>;
export type CreateWorkUserShiftRange = z.input<
  typeof createWorkUserShiftRangeSchema
>;

export async function getWorkUserShifts(params: {
  from: string;
  root_organization_id: string;
  to: string;
  user_id: string;
}): Promise<WorkUserShift[]> {
  return workUserShiftSchema
    .array()
    .parse(await requestClient.get<unknown>('/work-user-shifts', { params }));
}

export async function createWorkUserShiftRange(
  payload: CreateWorkUserShiftRange,
): Promise<WorkUserShift[]> {
  return workUserShiftSchema
    .array()
    .parse(
      await requestClient.post<unknown>(
        '/work-user-shifts/range',
        createWorkUserShiftRangeSchema.parse(payload),
      ),
    );
}

export async function updateWorkUserShift(
  id: string,
  workShiftId: string,
): Promise<WorkUserShift> {
  return workUserShiftSchema.parse(
    await requestClient.put<unknown>(`/work-user-shifts/${id}`, {
      work_shift_id: z.string().min(1).parse(workShiftId),
    }),
  );
}

export async function deleteWorkUserShift(id: string): Promise<void> {
  await requestClient.delete(`/work-user-shifts/${id}`);
}

export async function getMyWorkUserShifts(params: {
  from: string;
  to: string;
}): Promise<WorkUserShift[]> {
  return workUserShiftSchema
    .array()
    .parse(
      await requestClient.get<unknown>('/work-user-shifts/mine', { params }),
    );
}

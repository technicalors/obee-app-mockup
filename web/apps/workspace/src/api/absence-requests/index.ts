import { z } from '@vben/common-ui';

import {
  organizationSchema,
  paginatedListSchema,
  paginationQuerySchema,
  userSchema,
} from '#/api/contracts';
import { requestClient } from '#/api/request';

export const leaveTypeSchema = z.enum(['UNPAID', 'ANNUAL', 'BUSINESS_TRIP']);
export const absenceStatusSchema = z.enum([
  'pending',
  'returned',
  'approved',
  'rejected',
]);

const relatedUserSchema = userSchema.omit({
  organization: true,
  profile: true,
  roles: true,
});

export const absenceRequestSchema = z.object({
  address: z.string().nullable(),
  approval_note: z.string().nullable(),
  approved_at: z.string().nullable(),
  root_organization: organizationSchema,
  root_organization_id: z.string(),
  created_at: z.string(),
  duration_days: z.number().nonnegative(),
  end_at: z.string(),
  id: z.string(),
  leave_type: leaveTypeSchema,
  reason: z.string(),
  rejected_at: z.string().nullable(),
  requested_by: z.string(),
  requester: relatedUserSchema,
  reviewer: relatedUserSchema,
  reviewer_id: z.string(),
  submitted_at: z.string().nullable(),
  start_at: z.string(),
  status: absenceStatusSchema,
  updated_at: z.string(),
  user: relatedUserSchema,
  user_id: z.string(),
});

export const leaveBalanceSchema = z.object({
  cycle_end: z.string().nullable(),
  cycle_start: z.string().nullable(),
  entitlement: z.number(),
  remaining: z.number(),
  used: z.number(),
});

export const absenceListQuerySchema = paginationQuerySchema.extend({
  root_organization_id: z.string().optional(),
  from: z.string().date().optional(),
  leave_type: leaveTypeSchema.optional(),
  reviewer_id: z.string().optional(),
  reviewer_ids: z.array(z.string()).optional(),
  status: absenceStatusSchema.optional(),
  statuses: z.array(absenceStatusSchema).optional(),
  to: z.string().date().optional(),
  user_id: z.string().optional(),
  user_ids: z.array(z.string()).optional(),
});

export const createAbsenceRequestSchema = z
  .object({
    address: z.string().min(1).max(255).nullable(),
    root_organization_id: z.string().min(1),
    end_at: z.string().min(1),
    leave_type: leaveTypeSchema,
    reason: z.string().min(1).max(5000),
    reviewer_id: z.string().min(1),
    start_at: z.string().min(1),
    status: z.literal('pending').optional(),
  })
  .strict()
  .refine(
    (value) =>
      new Date(value.end_at).getTime() > new Date(value.start_at).getTime(),
    {
      message: 'End time must be after start time',
      path: ['end_at'],
    },
  )
  .refine(
    (value) => value.leave_type !== 'BUSINESS_TRIP' || value.address !== null,
    {
      message: 'Address is required for business trip',
      path: ['address'],
    },
  );

export const reviewAbsenceRequestSchema = z
  .object({ approval_note: z.string().min(1).max(5000).nullable() })
  .strict();

export type AbsenceRequest = z.infer<typeof absenceRequestSchema>;
export type LeaveBalance = z.infer<typeof leaveBalanceSchema>;
export type LeaveType = z.infer<typeof leaveTypeSchema>;
export type AbsenceStatus = z.infer<typeof absenceStatusSchema>;
export type AbsenceListQuery = z.input<typeof absenceListQuerySchema>;
export type CreateAbsenceRequest = z.input<typeof createAbsenceRequestSchema>;
export type UpdateAbsenceRequest = Omit<
  CreateAbsenceRequest,
  'root_organization_id' | 'status'
> & {
  status?: 'pending';
};
export type ReviewAbsenceRequest = z.input<typeof reviewAbsenceRequestSchema>;

export async function getAbsenceRequests(params: AbsenceListQuery) {
  return paginatedListSchema(absenceRequestSchema).parse(
    await requestClient.get<unknown>('/absence-requests', {
      params: absenceListQuerySchema.parse(params),
    }),
  );
}

export async function getAbsenceRequest(id: string): Promise<AbsenceRequest> {
  return absenceRequestSchema.parse(
    await requestClient.get<unknown>(`/absence-requests/${id}`),
  );
}

export async function getReviewerCapability(): Promise<boolean> {
  return z
    .boolean()
    .parse(
      await requestClient.get<unknown>('/absence-requests/reviewer-capability'),
    );
}

export const leaveCoveragePreviewSchema = z.object({
  holiday_days: z.number(),
  items: z.array(
    z.object({
      date: z.string(),
      days: z.number(),
      hours: z.number(),
      note: z.string(),
      work_shift_id: z.string().nullable(),
      status: z.enum(['covered', 'holiday', 'no_shift']),
    }),
  ),
  off_days: z.number(),
  total_days: z.number(),
  working_days: z.number(),
});

export const leaveCoveragePreviewQuerySchema = z.object({
  root_organization_id: z.string(),
  end_at: z.string(),
  leave_type: leaveTypeSchema,
  start_at: z.string(),
  user_id: z.string().optional(),
});

export type LeaveCoveragePreview = z.infer<typeof leaveCoveragePreviewSchema>;
export type LeaveCoveragePreviewQuery = z.input<
  typeof leaveCoveragePreviewQuerySchema
>;

export async function previewLeaveCoverage(
  params: LeaveCoveragePreviewQuery,
): Promise<LeaveCoveragePreview> {
  return leaveCoveragePreviewSchema.parse(
    await requestClient.get<unknown>('/absence-requests/preview-coverage', {
      params: leaveCoveragePreviewQuerySchema.parse(params),
    }),
  );
}

export async function getLeaveBalance(asOf?: string): Promise<LeaveBalance> {
  return leaveBalanceSchema.parse(
    await requestClient.get<unknown>('/absence-requests/leave-balance', {
      params:
        asOf === undefined ? {} : { as_of: z.string().date().parse(asOf) },
    }),
  );
}

export async function createAbsenceRequest(
  payload: CreateAbsenceRequest,
): Promise<AbsenceRequest> {
  return absenceRequestSchema.parse(
    await requestClient.post<unknown>(
      '/absence-requests',
      createAbsenceRequestSchema.parse(payload),
    ),
  );
}

export async function updateAbsenceRequest(
  id: string,
  payload: UpdateAbsenceRequest,
): Promise<AbsenceRequest> {
  return absenceRequestSchema.parse(
    await requestClient.put<unknown>(`/absence-requests/${id}`, payload),
  );
}

export async function submitAbsenceRequest(
  id: string,
): Promise<AbsenceRequest> {
  return absenceRequestSchema.parse(
    await requestClient.post<unknown>(`/absence-requests/${id}/submit`),
  );
}

export async function returnAbsenceRequest(
  id: string,
  payload: ReviewAbsenceRequest,
): Promise<AbsenceRequest> {
  return absenceRequestSchema.parse(
    await requestClient.post<unknown>(
      `/absence-requests/${id}/return`,
      reviewAbsenceRequestSchema.parse(payload),
    ),
  );
}

export async function approveAbsenceRequest(
  id: string,
  payload: ReviewAbsenceRequest,
): Promise<AbsenceRequest> {
  return absenceRequestSchema.parse(
    await requestClient.post<unknown>(
      `/absence-requests/${id}/approve`,
      reviewAbsenceRequestSchema.parse(payload),
    ),
  );
}

export async function rejectAbsenceRequest(
  id: string,
  payload: ReviewAbsenceRequest,
): Promise<AbsenceRequest> {
  return absenceRequestSchema.parse(
    await requestClient.post<unknown>(
      `/absence-requests/${id}/reject`,
      reviewAbsenceRequestSchema.parse(payload),
    ),
  );
}

export async function deleteAbsenceRequest(id: string): Promise<void> {
  await requestClient.delete(`/absence-requests/${id}`);
}

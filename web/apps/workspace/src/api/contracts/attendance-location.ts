import { z } from '@vben/common-ui';

import { attendanceValidationModeSchema } from './attendance';
import { paginationQuerySchema } from './pagination';

export const createAttendanceLocationPayloadSchema = z
  .object({
    name: z.string().min(1).max(255),
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
    radius_meters: z.number().int().min(1).max(10_000),
    validation_mode: attendanceValidationModeSchema,
    is_active: z.boolean().optional(),
    user_ids: z.array(z.string()).optional(),
    department_ids: z.array(z.string()).optional(),
    excluded_user_ids: z.array(z.string()).optional(),
    ip_addresses: z.array(z.string()).optional(),
  })
  .strict();

export const updateAttendanceLocationPayloadSchema = z
  .object({
    name: z.string().min(1).max(255).optional(),
    latitude: z.number().min(-90).max(90).optional(),
    longitude: z.number().min(-180).max(180).optional(),
    radius_meters: z.number().int().min(1).max(10_000).optional(),
    validation_mode: attendanceValidationModeSchema.optional(),
    is_active: z.boolean().optional(),
    user_ids: z.array(z.string()).optional(),
    department_ids: z.array(z.string()).optional(),
    excluded_user_ids: z.array(z.string()).optional(),
    ip_addresses: z.array(z.string()).optional(),
  })
  .strict();

export const attendanceLocationIndexQuerySchema = paginationQuerySchema.extend({
  is_active: z.boolean().optional(),
  search: z.string().optional(),
  validation_mode: attendanceValidationModeSchema.optional(),
});

export type CreateAttendanceLocationPayload = z.input<
  typeof createAttendanceLocationPayloadSchema
>;
export type UpdateAttendanceLocationPayload = z.input<
  typeof updateAttendanceLocationPayloadSchema
>;
export type AttendanceLocationIndexQuery = z.input<
  typeof attendanceLocationIndexQuerySchema
>;

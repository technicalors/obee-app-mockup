import { z } from '@vben/common-ui';

import { organizationSchema } from './organization';

export const attendanceValidationModeSchema = z.enum([
  'location',
  'ip',
  'both',
  'either',
]);

const attendanceUserSchema = z.object({
  id: z.union([z.string(), z.number()]),
  name: z.string(),
});

export const attendanceLocationIpSchema = z.object({
  id: z.string(),
  attendance_location_id: z.string(),
  ip_address: z.string(),
  created_at: z.string(),
  updated_at: z.string(),
});

const attendanceLocationBaseSchema = z.object({
  id: z.string(),
  name: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  radius_meters: z.number(),
  validation_mode: attendanceValidationModeSchema,
  created_at: z.string(),
  updated_at: z.string(),
  deleted_at: z.string().nullable(),
});

export const attendanceLocationSchema = attendanceLocationBaseSchema.extend({
  ips: z.array(attendanceLocationIpSchema),
  users: z.array(attendanceUserSchema),
  organizations: z.array(organizationSchema),
  excluded_users: z.array(attendanceUserSchema),
});

export const attendanceContextSchema = z.object({
  has_shift_today: z.boolean(),
  shift_start_at: z.string().nullable().optional(),
  shift_end_at: z.string().nullable().optional(),
  ip_address: z.string().nullable(),
  user: attendanceUserSchema,
  assigned_locations: z.array(attendanceLocationSchema),
});

export const attendanceLogSchema = z.object({
  id: z.string(),
  user_id: z.string().optional(),
  attendance_location_id: z.string().nullable(),
  checked_at: z.string(),
  ip_address: z.string().nullable(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  source: z.string(),
  created_at: z.string().optional(),
  updated_at: z.string().optional(),
  location: attendanceLocationBaseSchema.nullable().optional(),
});

export const attendanceDayDetailSchema = z.object({
  date: z.string().date(),
  first_check_in_at: z.string().nullable(),
  last_check_out_at: z.string().nullable(),
  total_work_seconds: z.number().int().nonnegative(),
  is_late: z.boolean().optional(),
  shift_start_at: z.string().nullable().optional(),
  shift_end_at: z.string().nullable().optional(),
  logs: z.array(attendanceLogSchema),
});

export const attendanceRangeSummarySchema = z.object({
  date: z.string().date(),
  first_check_in_at: z.string().nullable(),
  last_check_out_at: z.string().nullable(),
  logs_count: z.number().int().nonnegative(),
  on_leave: z.boolean(),
  total_work_seconds: z.number().int().nonnegative(),
  is_late: z.boolean().optional(),
  shift_start_at: z.string().nullable().optional(),
  shift_end_at: z.string().nullable().optional(),
});

export const attendancePunchPayloadSchema = z
  .object({
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
  })
  .strict();

export type AttendanceValidationMode = z.infer<
  typeof attendanceValidationModeSchema
>;
export type AttendanceLocationIp = z.infer<typeof attendanceLocationIpSchema>;
export type AttendanceLocation = z.infer<typeof attendanceLocationSchema>;
export type AttendanceContext = z.infer<typeof attendanceContextSchema>;
export type AttendanceLog = z.infer<typeof attendanceLogSchema>;
export type AttendanceDayDetail = z.infer<typeof attendanceDayDetailSchema>;
export type AttendanceRangeSummary = z.infer<
  typeof attendanceRangeSummarySchema
>;
export type AttendancePunchPayload = z.input<
  typeof attendancePunchPayloadSchema
>;

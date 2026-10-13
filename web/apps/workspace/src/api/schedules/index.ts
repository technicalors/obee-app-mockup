import { z } from '@vben/common-ui';

import { requestClient } from '#/api/request';

export const scheduleVisibilitySchema = z.enum([
  'all',
  'participated',
  'observed',
  'created',
]);

const scheduleUserSchema = z.object({
  avatar: z.nullable(z.string()),
  email: z.string(),
  id: z.string(),
  name: z.string(),
});

const scheduleEventSchema = z.object({
  company_name: z.nullable(z.string()),
  company_phone_number: z.nullable(z.string()),
  created_at: z.string(),
  created_by: z.string(),
  end_date: z.string(),
  has_reminder: z.boolean(),
  id: z.string(),
  is_general: z.boolean(),
  note: z.nullable(z.string()),
  observers: z.array(scheduleUserSchema),
  participants: z.array(scheduleUserSchema),
  physical_address: z.nullable(z.string()),
  privacy: z.enum(['private', 'public']),
  remind_range: z.nullable(z.enum(['minute', 'hour', 'day'])),
  remind_value: z.nullable(z.number()),
  repeat_end_time: z.nullable(z.string()),
  repeat_pattern: z.nullable(z.array(z.number().int())),
  repeat_start_time: z.nullable(z.string()),
  repeat_type: z.nullable(z.enum(['daily', 'weekly', 'monthly'])),
  schedule_type: z.enum(['ordinary', 'multiple_days', 'repeat']),
  start_date: z.string(),
  title: z.string(),
  type: z.enum([
    'training',
    'seminar',
    'interview',
    'meetup',
    'meeting',
    'holiday',
    'business_trip',
  ]),
  updated_at: z.string(),
  updated_by: z.nullable(z.string()),
});
const scheduleEventWritePayloadSchema = z.object({
  company_name: z.nullable(z.string()),
  company_phone_number: z.nullable(z.string()),
  end_date: z.string(),
  has_reminder: z.boolean(),
  is_general: z.boolean(),
  note: z.nullable(z.string()),
  observers: z.array(z.string()),
  participants: z.array(z.string()),
  physical_address: z.nullable(z.string()),
  privacy: z.enum(['private', 'public']),
  remind_range: z.nullable(z.enum(['minute', 'hour', 'day'])),
  remind_value: z.nullable(z.number()),
  repeat_end_time: z.nullable(z.string()),
  repeat_pattern: z.nullable(z.array(z.number().int())),
  repeat_start_time: z.nullable(z.string()),
  repeat_type: z.nullable(z.enum(['daily', 'weekly', 'monthly'])),
  schedule_type: z.enum(['ordinary', 'multiple_days', 'repeat']),
  start_date: z.string(),
  title: z.string(),
  type: z.enum([
    'training',
    'seminar',
    'interview',
    'meetup',
    'meeting',
    'holiday',
    'business_trip',
  ]),
});

const scheduleSchema = z.object({
  end: z.string(),
  event: scheduleEventSchema,
  event_id: z.string(),
  id: z.string(),
  one_day: z.boolean(),
  remind_at: z.nullable(z.string()),
  start: z.string(),
});

const schedulesSchema = z.array(scheduleSchema);
const scheduleMutationMessageSchema = z.object({
  message: z.string(),
});

export type ScheduleVisibility = z.infer<typeof scheduleVisibilitySchema>;
export type ScheduleEvent = z.infer<typeof scheduleEventSchema>;
export type ScheduleEventWritePayload = z.infer<
  typeof scheduleEventWritePayloadSchema
>;
export type Schedule = z.infer<typeof scheduleSchema>;
export { scheduleSchema };

export interface GetSchedulesParams {
  end_from?: string;
  end_to?: string;
  event_id?: string;
  start_from?: string;
  start_to?: string;
  user_ids?: string;
  visibility: ScheduleVisibility;
}

export async function getSchedules(
  params: GetSchedulesParams,
): Promise<Schedule[]> {
  const payload = await requestClient.get<unknown>('/schedules', { params });

  return schedulesSchema.parse(payload);
}

export async function getSchedule(scheduleId: string): Promise<Schedule> {
  const payload = await requestClient.get<unknown>(`/schedules/${scheduleId}`);

  return scheduleSchema.parse(payload);
}

export async function joinScheduleEvent(
  eventId: string,
): Promise<{ message: string }> {
  const payload = await requestClient.post<unknown>(
    `/schedule-events/${eventId}/join`,
  );

  return scheduleMutationMessageSchema.parse(payload);
}

export async function leaveScheduleEvent(
  eventId: string,
): Promise<{ message: string }> {
  const payload = await requestClient.post<unknown>(
    `/schedule-events/${eventId}/leave`,
  );

  return scheduleMutationMessageSchema.parse(payload);
}

export async function deleteScheduleEvent(
  eventId: string,
): Promise<{ message: string }> {
  const payload = await requestClient.delete<unknown>(
    `/schedule-events/${eventId}`,
  );

  return scheduleMutationMessageSchema.parse(payload);
}

export async function createScheduleEvent(
  payload: ScheduleEventWritePayload,
): Promise<void> {
  await requestClient.post<unknown>('/schedule-events', payload);
}

export async function updateScheduleEvent(
  eventId: string,
  payload: ScheduleEventWritePayload,
): Promise<void> {
  await requestClient.put<unknown>(`/schedule-events/${eventId}`, payload);
}

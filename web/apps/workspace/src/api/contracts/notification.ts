import { z } from '@vben/common-ui';

import { paginationQuerySchema } from './pagination';

export const SCHEDULE_EVENT_NOTIFICATION_TYPE = String.raw`App\Notifications\ScheduleEventNotification`;

export const notificationPayloadSchema = z
  .object({
    action: z.object({
      id: z.string().min(1),
      type: z.string().min(1),
    }),
    actor: z.object({
      id: z.string().uuid(),
      name: z.string().min(1),
      username: z.string().min(1),
    }),
    kind: z.string().min(1),
    message: z.string().min(1).max(10_000),
    meta: z.union([
      z.record(z.string(), z.unknown()),
      z.array(z.never()).length(0),
    ]),
    subject: z.object({
      id: z.string().min(1),
      type: z.string().min(1),
    }),
    version: z.number().int(),
  })
  .strict();

export const notificationSchema = z
  .object({
    created_at: z.string().datetime({ offset: true }),
    data: notificationPayloadSchema,
    id: z.string().uuid(),
    kind: z.string().min(1),
    read_at: z.string().datetime({ offset: true }).nullable(),
    type: z.string().min(1),
  })
  .strict()
  .refine((notification) => notification.kind === notification.data.kind, {
    message: 'Notification kind must match notification data.kind.',
    path: ['kind'],
  });

export const notificationIndexQuerySchema = paginationQuerySchema
  .extend({
    is_read: z.union([z.literal(0), z.literal(1)]).optional(),
    kind: z.string().min(1).max(255).optional(),
  })
  .strict();

export const manualNotificationPayloadSchema = z
  .object({
    message: z.string().min(1).max(10_000),
    recipient_ids: z.array(z.string().uuid()).min(1).max(100),
  })
  .strict();

export const markAllNotificationsReadResponseSchema = z
  .object({
    updated: z.number().int().nonnegative(),
  })
  .strict();

export type InboxNotification = z.infer<typeof notificationSchema>;
export type ManualNotificationPayload = z.input<
  typeof manualNotificationPayloadSchema
>;
export type NotificationIndexQuery = z.input<
  typeof notificationIndexQuerySchema
>;

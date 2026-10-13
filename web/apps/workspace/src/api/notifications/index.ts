import type {
  InboxNotification,
  ManualNotificationPayload,
  NotificationIndexQuery,
  PaginatedList,
  User,
} from '#/api/contracts';

import {
  manualNotificationPayloadSchema,
  markAllNotificationsReadResponseSchema,
  notificationIndexQuerySchema,
  notificationSchema,
  paginatedListSchema,
  userSchema,
} from '#/api/contracts';
import { requestClient } from '#/api/request';

export async function getNotificationRecipientsApi(): Promise<User[]> {
  return userSchema
    .array()
    .parse(await requestClient.get<unknown>('/notifications/recipients'));
}

export async function getNotificationsApi(
  params: NotificationIndexQuery,
): Promise<PaginatedList<InboxNotification>> {
  return paginatedListSchema(notificationSchema).parse(
    await requestClient.get<unknown>('/notifications', {
      params: notificationIndexQuerySchema.parse(params),
    }),
  );
}

export async function markAllNotificationsReadApi(): Promise<number> {
  return markAllNotificationsReadResponseSchema.parse(
    await requestClient.post<unknown>('/notifications/read-all'),
  ).updated;
}

export async function markNotificationReadApi(
  id: string,
): Promise<InboxNotification> {
  return notificationSchema.parse(
    await requestClient.post<unknown>(`/notifications/${id}/read`),
  );
}

export async function sendManualNotificationApi(
  payload: ManualNotificationPayload,
): Promise<InboxNotification[]> {
  return notificationSchema
    .array()
    .parse(
      await requestClient.post<unknown>(
        '/notifications',
        manualNotificationPayloadSchema.parse(payload),
      ),
    );
}

export const notificationsResource = {
  getAll: getNotificationsApi,
};

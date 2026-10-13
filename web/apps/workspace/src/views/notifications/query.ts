import type { NotificationIndexQuery, ResourcePaginationQuery } from '#/api';

export type NotificationReadState = 'all' | 'read' | 'unread';

export function createNotificationIndexQuery(
  pagination: ResourcePaginationQuery,
  readState: NotificationReadState,
): NotificationIndexQuery {
  const query: NotificationIndexQuery = { ...pagination };

  if (readState === 'read') {
    query.is_read = 1;
  }

  if (readState === 'unread') {
    query.is_read = 0;
  }

  return query;
}

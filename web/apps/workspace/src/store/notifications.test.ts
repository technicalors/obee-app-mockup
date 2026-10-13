import type { InboxNotification } from '#/api';

import { createPinia, setActivePinia } from 'pinia';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const api = vi.hoisted(() => ({
  getNotificationsApi: vi.fn(),
  markAllNotificationsReadApi: vi.fn(),
  markNotificationReadApi: vi.fn(),
  sendManualNotificationApi: vi.fn(),
}));
const realtime = vi.hoisted(() => ({
  disconnect: vi.fn(),
  onNotification: undefined as
    | ((notification: InboxNotification) => void)
    | undefined,
  onSyncRequired: undefined as (() => void) | undefined,
}));

vi.mock('#/api', () => ({
  getNotificationsApi: api.getNotificationsApi,
  markAllNotificationsReadApi: api.markAllNotificationsReadApi,
  markNotificationReadApi: api.markNotificationReadApi,
  sendManualNotificationApi: api.sendManualNotificationApi,
}));

vi.mock('#/realtime/notifications', () => ({
  connectNotificationRealtime: vi.fn(
    (
      _userId: string,
      onNotification: (notification: InboxNotification) => void,
      onSyncRequired: () => void,
    ) => {
      realtime.onNotification = onNotification;
      realtime.onSyncRequired = onSyncRequired;

      return realtime.disconnect;
    },
  ),
}));

function makeNotification(
  id: string,
  readAt: null | string = null,
): InboxNotification {
  return {
    created_at: '2026-08-01T10:00:00.000000Z',
    data: {
      action: {
        id: 'notifications',
        type: 'inbox',
      },
      actor: {
        id: '550e8400-e29b-41d4-a716-446655440000',
        name: 'Admin',
        username: 'admin',
      },
      kind: 'system.manual',
      message: `Message ${id}`,
      meta: {},
      subject: {
        id: 'manual-notification-id',
        type: 'notification',
      },
      version: 1,
    },
    id,
    kind: 'system.manual',
    read_at: readAt,
    type: 'App\\Notifications\\ManualNotification',
  };
}

describe('notification store', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
    vi.clearAllMocks();
    realtime.onNotification = undefined;
    realtime.onSyncRequired = undefined;
  });

  it('loads inbox data and applies Reverb updates to the shared inbox state', async () => {
    api.getNotificationsApi.mockResolvedValue({
      items: [makeNotification('550e8400-e29b-41d4-a716-446655440001')],
      pagination: {
        has_next: false,
        page: 1,
        per_page: 100,
        total: 1,
      },
    });

    const { useNotificationStore } = await import('./notifications');
    const store = useNotificationStore();

    await store.initialize('550e8400-e29b-41d4-a716-446655440000');
    realtime.onNotification?.(
      makeNotification('550e8400-e29b-41d4-a716-446655440002'),
    );

    expect(api.getNotificationsApi).toHaveBeenCalledWith({
      page: 1,
      per_page: 100,
    });
    expect(store.notifications).toHaveLength(2);
    expect(store.unreadCount).toBe(2);
  });

  it('reloads authoritative inbox data after marking all notifications as read', async () => {
    const notification = makeNotification(
      '550e8400-e29b-41d4-a716-446655440001',
    );
    api.getNotificationsApi
      .mockResolvedValueOnce({
        items: [notification],
        pagination: {
          has_next: false,
          page: 1,
          per_page: 100,
          total: 1,
        },
      })
      .mockResolvedValueOnce({
        items: [
          makeNotification(
            '550e8400-e29b-41d4-a716-446655440001',
            '2026-08-01T10:01:00.000000Z',
          ),
        ],
        pagination: {
          has_next: false,
          page: 1,
          per_page: 100,
          total: 1,
        },
      });
    api.markAllNotificationsReadApi.mockResolvedValue(1);

    const { useNotificationStore } = await import('./notifications');
    const store = useNotificationStore();

    await store.initialize('550e8400-e29b-41d4-a716-446655440000');
    await store.markAllRead();

    expect(api.markAllNotificationsReadApi).toHaveBeenCalledOnce();
    expect(api.getNotificationsApi).toHaveBeenCalledTimes(2);
    expect(store.unreadCount).toBe(0);
  });

  it('returns and applies the confirmed notification when marking it as read', async () => {
    const updatedNotification = makeNotification(
      '550e8400-e29b-41d4-a716-446655440001',
      '2026-08-01T10:01:00.000000Z',
    );
    api.markNotificationReadApi.mockResolvedValue(updatedNotification);

    const { useNotificationStore } = await import('./notifications');
    const store = useNotificationStore();

    await expect(store.markRead(updatedNotification.id)).resolves.toEqual(
      updatedNotification,
    );

    expect(store.notifications).toEqual([updatedNotification]);
    expect(store.unreadCount).toBe(0);
  });

  it('disconnects the recipient channel when the store resets', async () => {
    api.getNotificationsApi.mockResolvedValue({
      items: [],
      pagination: {
        has_next: false,
        page: 1,
        per_page: 100,
        total: 0,
      },
    });

    const { useNotificationStore } = await import('./notifications');
    const store = useNotificationStore();

    await store.initialize('550e8400-e29b-41d4-a716-446655440000');
    store.$reset();

    expect(realtime.disconnect).toHaveBeenCalledOnce();
  });
});

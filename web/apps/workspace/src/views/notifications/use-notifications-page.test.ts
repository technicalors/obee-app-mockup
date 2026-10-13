import type { InboxNotification } from '#/api';

import { createApp, nextTick, reactive } from 'vue';

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { useNotificationsPage } from './use-notifications-page';

const tableState = vi.hoisted(() => ({
  reload: vi.fn(),
}));
const notificationPageState = vi.hoisted(() => ({
  onCellClick: undefined as
    | ((context: { row: InboxNotification }) => void)
    | undefined,
}));
const routerState = vi.hoisted(() => ({
  push: vi.fn(),
}));

const notificationState = reactive({
  markRead: vi.fn(),
  notifications: [] as InboxNotification[],
});

vi.mock('@vben/common-ui', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@vben/common-ui')>();

  return {
    ...actual,
    useVbenModal: () => [
      {},
      {
        open: vi.fn(),
        setData: vi.fn(),
      },
    ],
  };
});

vi.mock('ant-design-vue', () => ({
  notification: {
    success: vi.fn(),
  },
}));

vi.mock('vue-router', () => ({
  useRouter: () => routerState,
}));

vi.mock('#/api', () => ({
  notificationsResource: {},
}));

vi.mock('#/locales', () => ({
  $t: (key: string) => key,
}));

vi.mock('#/shared/request-feedback', () => ({
  showRequestError: vi.fn(),
}));

vi.mock('#/shared/resource-table', () => ({
  useResourceTable: (options: {
    gridEvents: {
      cellClick: (context: { row: InboxNotification }) => void;
    };
  }) => {
    notificationPageState.onCellClick = options.gridEvents.cellClick;

    return [{}, tableState];
  },
}));

vi.mock('#/store', () => ({
  useAuthStore: () => ({
    hasSession: true,
  }),
  useNotificationStore: () => notificationState,
}));

vi.mock('./schema', () => ({
  createNotificationTableColumns: () => [],
}));

function makeNotification(): InboxNotification {
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
      message: 'Realtime message.',
      meta: {},
      subject: {
        id: 'manual-notification-id',
        type: 'notification',
      },
      version: 1,
    },
    id: '550e8400-e29b-41d4-a716-446655440001',
    kind: 'system.manual',
    read_at: null,
    type: 'App\\Notifications\\ManualNotification',
  };
}

function makeScheduleEventNotification(): InboxNotification {
  const notification = makeNotification();

  return {
    ...notification,
    data: {
      ...notification.data,
      kind: 'schedule.event.created',
      subject: {
        id: 'schedule-event-id',
        type: 'App\\Models\\ScheduleEvent',
      },
    },
    kind: 'schedule.event.created',
    type: 'App\\Notifications\\ScheduleEventNotification',
  };
}

function mountComposable(): ReturnType<typeof createApp> {
  const app = createApp({
    setup() {
      useNotificationsPage();

      return {};
    },
    template: '<div />',
  });

  app.mount(document.createElement('div'));

  return app;
}

describe('useNotificationsPage', () => {
  beforeEach(() => {
    notificationState.notifications = [];
    notificationState.markRead.mockReset();
    tableState.reload.mockReset();
    routerState.push.mockReset();
  });

  it('reloads the visible list when the shared realtime inbox changes', async () => {
    const app = mountComposable();

    notificationState.notifications = [makeNotification()];
    await nextTick();

    expect(tableState.reload).toHaveBeenCalledOnce();

    app.unmount();
  });

  it('routes schedule event notifications to the schedule drawer target', async () => {
    const inboxNotification = makeScheduleEventNotification();
    notificationState.markRead.mockResolvedValue({
      ...inboxNotification,
      read_at: '2026-08-01T10:01:00.000000Z',
    });
    const app = mountComposable();

    if (notificationPageState.onCellClick === undefined) {
      throw new Error('Notification row click handler was not configured.');
    }

    notificationPageState.onCellClick({ row: inboxNotification });
    await Promise.resolve();
    await Promise.resolve();

    expect(notificationState.markRead).toHaveBeenCalledWith(
      inboxNotification.id,
    );
    expect(routerState.push).toHaveBeenCalledWith({
      name: 'Schedules',
      query: { event_id: 'schedule-event-id' },
    });

    app.unmount();
  });
});

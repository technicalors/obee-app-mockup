import type { NotificationReadState } from './query';

import type { InboxNotification, NotificationIndexQuery } from '#/api';

import { defineAsyncComponent, ref, watch } from 'vue';
import { useRouter } from 'vue-router';

import { useVbenModal } from '@vben/common-ui';

import { notification } from 'ant-design-vue';

import { notificationsResource } from '#/api';
import { SCHEDULE_EVENT_NOTIFICATION_TYPE } from '#/api/contracts';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore, useNotificationStore } from '#/store';

import { createNotificationIndexQuery } from './query';
import { createNotificationTableColumns } from './schema';

const CreateNotificationModalComponent = defineAsyncComponent(
  () => import('./create-notification-modal.vue'),
);

export function useNotificationsPage() {
  const router = useRouter();
  const authStore = useAuthStore();
  const notificationStore = useNotificationStore();
  const detailDrawerOpen = ref(false);
  const readState = ref<NotificationReadState>('all');
  const selectedNotification = ref<InboxNotification | null>(null);

  const [CreateNotificationModal, createNotificationModalApi] = useVbenModal({
    connectedComponent: CreateNotificationModalComponent,
  });

  const [Grid, table] = useResourceTable<
    InboxNotification,
    NotificationIndexQuery
  >({
    buildQuery: (pagination) =>
      createNotificationIndexQuery(pagination, readState.value),
    enabled: () => authStore.hasSession,
    errorMessage: $t('page.notifications.messages.unexpectedError'),
    gridEvents: {
      cellClick: ({ row }: { row: InboxNotification }) => {
        void openDetail(row);
      },
    },
    gridOptions: {
      border: false,
      columns: createNotificationTableColumns(),
      rowConfig: {
        keyField: 'id',
      },
      rowStyle: {
        cursor: 'pointer',
      },
      showHeader: false,
      toolbarConfig: {
        custom: false,
        refresh: false,
        search: false,
        zoom: false,
      },
    },
    resource: notificationsResource,
    tableTitle: $t('page.notifications.listTitle'),
  });

  watch(
    () => notificationStore.notifications,
    () => {
      void table.reload();
    },
  );

  function closeDetail(): void {
    detailDrawerOpen.value = false;
    selectedNotification.value = null;
  }

  function openCreate(): void {
    createNotificationModalApi.setData({
      onSaved: table.reload,
    });
    createNotificationModalApi.open();
  }

  function setReadState(value: number | string): void {
    switch (value) {
      case 'all':
      case 'read':
      case 'unread': {
        readState.value = value;
        void table.reload();
        return;
      }
      default: {
        throw new Error(`Unsupported notification read state: ${value}`);
      }
    }
  }

  async function markAllRead(): Promise<void> {
    try {
      await notificationStore.markAllRead();
      await table.reload();
      notification.success({
        message: $t('page.notifications.messages.markedAllRead'),
      });
    } catch (error) {
      showRequestError(
        error,
        $t('page.notifications.messages.unexpectedError'),
        'Unexpected notification read-all error:',
      );
    }
  }

  async function openDetail(
    inboxNotification: InboxNotification,
  ): Promise<void> {
    const opensScheduleDetail =
      inboxNotification.type === SCHEDULE_EVENT_NOTIFICATION_TYPE;

    if (!opensScheduleDetail) {
      selectedNotification.value = inboxNotification;
      detailDrawerOpen.value = true;
    }

    if (inboxNotification.read_at === null) {
      try {
        const readNotification = await notificationStore.markRead(
          inboxNotification.id,
        );

        if (opensScheduleDetail === false) {
          selectedNotification.value = readNotification;
        }
        await table.reload();
      } catch (error) {
        showRequestError(
          error,
          $t('page.notifications.messages.unexpectedError'),
          'Unexpected notification read error:',
        );
      }
    }

    if (opensScheduleDetail) {
      await router.push({
        name: 'Schedules',
        query: { event_id: inboxNotification.data.subject.id },
      });
    }
  }

  return {
    CreateNotificationModal,
    Grid,
    closeDetail,
    detailDrawerOpen,
    markAllRead,
    openCreate,
    readState,
    selectedNotification,
    setReadState,
  };
}

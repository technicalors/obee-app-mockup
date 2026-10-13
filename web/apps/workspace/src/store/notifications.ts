import type {
  InboxNotification,
  ManualNotificationPayload,
} from '#/api/contracts';

import { computed, ref } from 'vue';

import { acceptHMRUpdate, defineStore } from 'pinia';

import {
  getNotificationsApi,
  markAllNotificationsReadApi,
  markNotificationReadApi,
  sendManualNotificationApi,
} from '#/api';
import { connectNotificationRealtime } from '#/realtime/notifications';

const INBOX_PAGE_SIZE = 100;

export const useNotificationStore = defineStore('notifications', () => {
  const notifications = ref<InboxNotification[]>([]);
  const isLoading = ref(false);
  let disconnectRealtime: (() => void) | undefined;

  const unreadCount = computed(
    () =>
      notifications.value.filter(
        (notification) => notification.read_at === null,
      ).length,
  );
  const unreadNotifications = computed(() =>
    notifications.value.filter((notification) => notification.read_at === null),
  );

  async function refreshInbox(): Promise<void> {
    isLoading.value = true;

    try {
      const inbox = await getNotificationsApi({
        page: 1,
        per_page: INBOX_PAGE_SIZE,
      });

      notifications.value = inbox.items;
    } finally {
      isLoading.value = false;
    }
  }

  async function initialize(userId: string): Promise<void> {
    stopRealtime();
    disconnectRealtime = connectNotificationRealtime(userId, upsert, () => {
      void refreshInbox();
    });

    try {
      await refreshInbox();
    } catch (error: unknown) {
      stopRealtime();
      throw error;
    }
  }

  async function markRead(id: string): Promise<InboxNotification> {
    const notification = await markNotificationReadApi(id);
    upsert(notification);

    return notification;
  }

  async function markAllRead(): Promise<void> {
    await markAllNotificationsReadApi();
    await refreshInbox();
  }

  async function sendManualNotification(
    payload: ManualNotificationPayload,
  ): Promise<void> {
    await sendManualNotificationApi(payload);
    await refreshInbox();
  }

  function upsert(notification: InboxNotification): void {
    const notificationIndex = notifications.value.findIndex(
      (item) => item.id === notification.id,
    );

    if (notificationIndex === -1) {
      notifications.value = [notification, ...notifications.value];

      return;
    }

    notifications.value = notifications.value.with(
      notificationIndex,
      notification,
    );
  }

  function stopRealtime(): void {
    disconnectRealtime?.();
    disconnectRealtime = undefined;
  }

  function $reset(): void {
    notifications.value = [];
    isLoading.value = false;
    stopRealtime();
  }

  return {
    $reset,
    initialize,
    isLoading,
    markAllRead,
    markRead,
    notifications,
    refreshInbox,
    sendManualNotification,
    stopRealtime,
    unreadCount,
    unreadNotifications,
    upsert,
  };
});

const hot = import.meta.hot;
if (hot) {
  hot.accept(acceptHMRUpdate(useNotificationStore, hot));
}

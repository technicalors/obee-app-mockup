<script lang="ts" setup>
import type { NotificationItem } from '@vben/layouts';

import { computed, onUnmounted, watch } from 'vue';
import { useRouter } from 'vue-router';

import { AuthenticationLoginExpiredModal } from '@vben/common-ui';
import { useWatermark } from '@vben/hooks';
import {
  BasicLayout,
  LockScreen,
  Notification,
  UserDropdown,
} from '@vben/layouts';
import { preferences, usePreferences } from '@vben/preferences';
import { useAccessStore, useUserStore } from '@vben/stores';

import { storeToRefs } from 'pinia';

import { SCHEDULE_EVENT_NOTIFICATION_TYPE } from '#/api/contracts';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useAuthStore, useNotificationStore } from '#/store';
import LoginForm from '#/views/_core/authentication/login.vue';
import { formatNotificationDateTime } from '#/views/notifications/format';

const router = useRouter();
const userStore = useUserStore();
const authStore = useAuthStore();
const notificationStore = useNotificationStore();
const accessStore = useAccessStore();
const { destroyWatermark, updateWatermark } = useWatermark();
const { isDark } = usePreferences();
const { unreadCount, unreadNotifications } = storeToRefs(notificationStore);
const notifications = computed<NotificationItem[]>(() =>
  unreadNotifications.value.map((notification) => ({
    avatar: preferences.app.defaultAvatar,
    date: formatNotificationDateTime(notification.created_at),
    id: notification.id,
    isRead: notification.read_at !== null,
    message: notification.data.message,
    title: notification.data.actor.name,
  })),
);
const showDot = computed(() => unreadCount.value > 0);

const menus = computed(() => [
  {
    handler: () => {
      router.push({ name: 'Profile' });
    },
    icon: 'lucide:user',
    text: $t('page.auth.profile'),
  },
]);

const avatar = computed(() => {
  return userStore.userInfo?.avatar ?? preferences.app.defaultAvatar;
});

async function handleLogout() {
  await authStore.logout(false);
}

async function handleNoticeClear(): Promise<void> {
  try {
    await notificationStore.markAllRead();
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('page.notifications.messages.unexpectedError'),
      'Unable to mark notifications as read:',
    );
  }
}

async function markRead(id: number | string): Promise<void> {
  if (typeof id !== 'string') {
    throw new TypeError('Notification ids must be strings.');
  }

  try {
    await notificationStore.markRead(id);
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('page.notifications.messages.unexpectedError'),
      'Unable to mark notification as read:',
    );
  }
}

async function viewAll(): Promise<void> {
  await router.push('/notifications');
}

async function handleNotificationClick(item: NotificationItem): Promise<void> {
  if (typeof item.id !== 'string') {
    throw new TypeError('Notification ids must be strings.');
  }

  const inboxNotification = notificationStore.notifications.find(
    (notification) => notification.id === item.id,
  );

  if (inboxNotification === undefined) {
    throw new Error(`Notification ${item.id} is not in the inbox.`);
  }

  if (inboxNotification.type === SCHEDULE_EVENT_NOTIFICATION_TYPE) {
    await router.push({
      name: 'Schedules',
      query: { event_id: inboxNotification.data.subject.id },
    });
    return;
  }

  await viewAll();
}

watch(
  () => authStore.user,
  (user) => {
    notificationStore.stopRealtime();

    if (user === null) {
      return;
    }

    void notificationStore.initialize(user.id).catch((error: unknown) => {
      showRequestError(
        error,
        $t('page.notifications.messages.unexpectedError'),
        'Unable to initialize notification inbox:',
      );
    });
  },
  { immediate: true },
);

onUnmounted(() => {
  notificationStore.stopRealtime();
});

watch(
  () => ({
    enable: preferences.app.watermark,
    content: preferences.app.watermarkContent,
    isDark: isDark.value,
  }),
  async ({ enable, content, isDark: isDarkValue }) => {
    if (enable) {
      const watermarkColor = isDarkValue
        ? 'rgba(255, 255, 255, 0.12)'
        : 'rgba(0, 0, 0, 0.12)';

      await updateWatermark({
        advancedStyle: {
          colorStops: [
            {
              color: watermarkColor,
              offset: 0,
            },
            {
              color: watermarkColor,
              offset: 1,
            },
          ],
          type: 'linear',
        },
        content:
          content ||
          `${userStore.userInfo?.username} - ${userStore.userInfo?.realName}`,
      });
    } else {
      destroyWatermark();
    }
  },
  {
    immediate: true,
  },
);
</script>

<template>
  <BasicLayout @clear-preferences-and-logout="handleLogout">
    <template #user-dropdown>
      <UserDropdown
        :avatar
        :menus
        :text="userStore.userInfo?.realName"
        description="ann.vben@gmail.com"
        tag-text="Pro"
        @logout="handleLogout"
        @clear-preferences-and-logout="handleLogout"
      />
    </template>
    <template #notification>
      <Notification
        :dot="showDot"
        :notifications="notifications"
        @clear="handleNoticeClear"
        @on-click="handleNotificationClick"
        @read="(item) => item.id && markRead(item.id)"
        @make-all="handleNoticeClear"
        @view-all="viewAll"
      />
    </template>
    <template #extra>
      <AuthenticationLoginExpiredModal
        v-model:open="accessStore.loginExpired"
        :avatar
      >
        <LoginForm />
      </AuthenticationLoginExpiredModal>
    </template>
    <template #lock-screen>
      <LockScreen :avatar @to-login="handleLogout" />
    </template>
  </BasicLayout>
</template>

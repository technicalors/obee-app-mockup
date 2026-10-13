<script setup lang="ts">
import type { InboxNotification } from '#/api';

import { createIconifyIcon } from '@vben/icons';

import { Drawer, Input } from 'ant-design-vue';

import { $t } from '#/locales';

import { formatNotificationDateTime } from './format';

defineProps<{
  notification: InboxNotification | null;
  open: boolean;
}>();

const emit = defineEmits<{
  close: [];
}>();

const SenderIcon = createIconifyIcon('lucide:user');
const TimeIcon = createIconifyIcon('lucide:clock-3');
const NoteIcon = createIconifyIcon('lucide:file-text');
</script>

<template>
  <Drawer
    :footer="null"
    :open="open"
    :width="620"
    class="notification-detail-drawer"
    placement="right"
    @close="emit('close')"
  >
    <template #title>
      <div class="drawer-header">
        <h2 class="drawer-title">
          {{ $t('page.notifications.detail.title') }}
        </h2>
      </div>
    </template>

    <div v-if="notification" class="notification-detail">
      <section class="information-card">
        <div class="field">
          <div class="field-heading">
            <SenderIcon class="field-icon" />
            <p class="field-label">
              {{ $t('page.notifications.fields.sender') }}
            </p>
          </div>

          <p class="field-value">
            {{ notification.data.actor.username }}
          </p>
        </div>

        <div class="field">
          <div class="field-heading">
            <TimeIcon class="field-icon" />
            <p class="field-label">
              {{ $t('page.notifications.fields.occurredAt') }}
            </p>
          </div>

          <p class="field-value">
            {{ formatNotificationDateTime(notification.created_at) }}
          </p>
        </div>

        <div class="field content-field">
          <div class="field-heading">
            <NoteIcon class="field-icon" />
            <p class="field-label">
              {{ $t('page.notifications.fields.content') }}
            </p>
          </div>

          <Input.TextArea
            :auto-size="{ minRows: 4 }"
            :value="notification.data.message"
            readonly
          />
        </div>
      </section>
    </div>
  </Drawer>
</template>

<style scoped>
.notification-detail-drawer :deep(.ant-drawer-content) {
  background: hsl(var(--background));
}

.notification-detail-drawer :deep(.ant-drawer-header) {
  min-height: auto;
  padding: 16px 22px;
  background: hsl(var(--background));
  border-bottom: 1px solid hsl(var(--border));
}

.notification-detail-drawer :deep(.ant-drawer-title) {
  flex: 1;
  min-width: 0;
}

.notification-detail-drawer :deep(.ant-drawer-body) {
  padding: 0;
  background: hsl(var(--background));
}

.drawer-header {
  min-width: 0;
}

.drawer-title {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
  line-height: 32px;
  color: hsl(var(--foreground));
}

.notification-detail {
  padding: 28px;
}

.information-card {
  display: grid;
  gap: 30px;
}

.field {
  min-width: 0;
}

.field-heading {
  display: flex;
  gap: 10px;
  align-items: center;
  min-height: 24px;
  margin-bottom: 8px;
}

.field-icon {
  display: block;
  flex: 0 0 20px;
  width: 20px;
  height: 20px;
  color: hsl(var(--muted-foreground));
}

.field-label {
  margin: 0;
  font-size: 16px;
  font-weight: 500;
  line-height: 20px;
  color: hsl(var(--muted-foreground));
}

.field-value {
  margin: 0;
  font-size: 18px;
  font-weight: 500;
  line-height: 28px;
  color: hsl(var(--foreground));
  overflow-wrap: anywhere;
  white-space: pre-wrap;
}

.content-field :deep(.ant-input) {
  padding: 12px 14px;
  font-size: 17px;
  line-height: 26px;
  color: hsl(var(--foreground));
  resize: none;
  background: hsl(var(--muted));
  border-color: hsl(var(--border));
}

@media (max-width: 640px) {
  .notification-detail-drawer :deep(.ant-drawer-content-wrapper) {
    width: 100% !important;
  }

  .notification-detail-drawer :deep(.ant-drawer-header) {
    padding: 18px;
  }

  .drawer-title {
    font-size: 21px;
    line-height: 29px;
  }

  .notification-detail {
    padding: 20px 18px;
  }

  .information-card {
    gap: 24px;
  }

  .field-label {
    font-size: 15px;
  }

  .field-value {
    font-size: 17px;
  }

  .content-field :deep(.ant-input) {
    font-size: 16px;
  }
}
</style>

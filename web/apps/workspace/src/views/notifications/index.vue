<script setup lang="ts">
import { VbenButton } from '@vben/common-ui';
import { Eye, EyeOff } from '@vben/icons';

import { Segmented } from 'ant-design-vue';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { formatNotificationDateTime } from './format';
import NotificationDetailDrawer from './notification-detail-drawer.vue';
import { useNotificationsPage } from './use-notifications-page';

const {
  CreateNotificationModal,
  Grid,
  closeDetail,
  detailDrawerOpen,
  markAllRead,
  openCreate,
  readState,
  selectedNotification,
  setReadState,
} = useNotificationsPage();

const readStateTabs = [
  {
    label: $t('page.notifications.filters.all'),
    value: 'all',
  },
  {
    label: $t('page.notifications.filters.read'),
    value: 'read',
  },
  {
    label: $t('page.notifications.filters.unread'),
    value: 'unread',
  },
];
</script>

<template>
  <ResourceListPage>
    <Grid
      class="notifications-grid"
      :row-config="{
        height: 88,
        isHover: false,
      }"
      :scroll-y="{
        enabled: false,
      }"
    >
      <template #table-title>
        <div class="notifications-heading">
          <div class="notifications-heading__top">
            <div class="notifications-heading__text">
              <h2 class="notifications-title">
                {{ $t('page.notifications.listTitle') }}
              </h2>

              <p class="notifications-description">
                {{ $t('page.notifications.listDescription') }}
              </p>
            </div>

            <div class="notifications-actions">
              <VbenButton class="mark-read-button" @click="markAllRead">
                <span class="button-content">
                  <Eye class="size-4" />

                  {{ $t('page.notifications.actions.markAllRead') }}
                </span>
              </VbenButton>

              <VbenButton
                class="create-notification-button"
                @click="openCreate"
              >
                <span class="button-content">
                  <span
                    aria-hidden="true"
                    class="create-notification-button__plus"
                  >
                    +
                  </span>

                  {{ $t('page.notifications.actions.create') }}
                </span>
              </VbenButton>
            </div>
          </div>

          <div class="notifications-filter">
            <span class="notifications-filter__label">
              {{ $t('page.notifications.filters.readState') }}
            </span>

            <Segmented
              :options="readStateTabs"
              :value="readState"
              class="read-state-segmented"
              @change="setReadState"
            />
          </div>
        </div>
      </template>

      <template #notification="{ row }">
        <article
          class="notification-row"
          :class="{
            'notification-row--unread': row.read_at === null,
          }"
        >
          <div class="notification-row__main">
            <div class="notification-row__meta">
              <Eye
                v-if="row.read_at !== null"
                :aria-label="$t('page.notifications.status.read')"
                class="notification-row__icon"
              />

              <EyeOff
                v-else
                :aria-label="$t('page.notifications.status.unread')"
                class="notification-row__icon notification-row__icon--unread"
              />

              <time :datetime="row.created_at" class="notification-row__time">
                {{ formatNotificationDateTime(row.created_at) }}
              </time>
            </div>

            <p
              class="notification-row__message"
              :class="{
                'notification-row__message--unread': row.read_at === null,
              }"
              :title="row.data.message"
            >
              {{ row.data.message }}
            </p>
          </div>

          <p class="notification-row__actor">
            <span>{{ $t('page.notifications.fields.by') }}</span>
            <strong>{{ row.data.actor.username }}</strong>
          </p>
        </article>
      </template>
    </Grid>

    <CreateNotificationModal />

    <NotificationDetailDrawer
      :notification="selectedNotification"
      :open="detailDrawerOpen"
      @close="closeDetail"
    />
  </ResourceListPage>
</template>

<style scoped>
.notifications-grid :deep(.vxe-grid--toolbar-wrapper) {
  width: 100%;
}

.notifications-grid :deep(.vxe-toolbar) {
  width: 100%;
}

.notifications-grid :deep(.vxe-buttons--wrapper) {
  flex: 1;
  width: 100%;
  min-width: 0;
}

.notifications-heading {
  width: 100%;
  min-width: 0;
}

.notifications-heading__top {
  display: flex;
  gap: 24px;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}

.notifications-heading__text {
  flex: 1;
  min-width: 0;
}

.notifications-title {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  line-height: 28px;
  color: hsl(var(--foreground));
}

.notifications-description {
  margin: 3px 0 0;
  font-size: 13px;
  line-height: 20px;
  color: hsl(var(--muted-foreground));
}

.notifications-filter {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: stretch;
  width: 100%;
  margin-top: 20px;
}

.notifications-filter__label {
  font-size: 13px;
  font-weight: 600;
  color: hsl(var(--muted-foreground));
  white-space: nowrap;
}

.read-state-segmented {
  display: block;
  width: 100% !important;
  padding: 4px !important;
  background: hsl(var(--muted)) !important;
  border: 1px solid hsl(var(--border)) !important;
  border-radius: 12px !important;
  box-shadow: inset 0 1px 2px hsl(var(--foreground) / 4%);
}

:deep(.read-state-segmented .ant-segmented-group) {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  width: 100%;
}

:deep(.read-state-segmented .ant-segmented-item) {
  width: 100%;
  min-width: 0;
  min-height: 34px;
  font-size: 13px;
  font-weight: 600;
  color: hsl(var(--muted-foreground));
  text-align: center;
  border-radius: 9px;
  transition:
    color 180ms ease,
    background-color 180ms ease,
    box-shadow 180ms ease;
}

:deep(.read-state-segmented .ant-segmented-item-label) {
  display: block;
  width: 100%;
  min-height: 34px;
  padding: 0 16px;
  line-height: 34px;
}

:deep(.read-state-segmented .ant-segmented-item:hover) {
  color: hsl(var(--primary));
}

:deep(.read-state-segmented .ant-segmented-item-selected) {
  color: hsl(var(--primary)) !important;
  background: hsl(var(--background)) !important;
  border: 1px solid hsl(var(--primary) / 10%);
  box-shadow:
    0 1px 3px hsl(var(--foreground) / 12%),
    0 4px 12px hsl(var(--foreground) / 8%) !important;
}

:deep(.read-state-segmented .ant-segmented-thumb) {
  display: none !important;
}

.notifications-actions {
  display: flex;
  flex-shrink: 0;
  gap: 10px;
  align-items: center;
}

.button-content {
  display: inline-flex;
  gap: 7px;
  align-items: center;
  justify-content: center;
}

.mark-read-button {
  min-height: 40px;
  padding: 0 16px !important;
  color: hsl(var(--foreground)) !important;
  background: hsl(var(--background)) !important;
  border: 1px solid hsl(var(--border)) !important;
  border-radius: 9px !important;
  box-shadow: 0 1px 2px hsl(var(--foreground) / 5%);
  opacity: 1 !important;
}

.mark-read-button:hover {
  color: hsl(var(--primary)) !important;
  background: hsl(var(--primary) / 8%) !important;
  border-color: hsl(var(--primary)) !important;
}

.mark-read-button:disabled,
.mark-read-button[disabled] {
  color: hsl(var(--muted-foreground) / 65%) !important;
  background: hsl(var(--muted)) !important;
  border-color: hsl(var(--border) / 60%) !important;
  opacity: 1 !important;
}

.create-notification-button {
  min-height: 40px;
  padding: 0 16px !important;
  border-radius: 9px !important;
  box-shadow: 0 4px 12px hsl(var(--primary) / 20%);
}

.create-notification-button__plus {
  font-size: 20px;
  font-weight: 400;
  line-height: 1;
}

.notification-row {
  position: relative;
  box-sizing: border-box;
  display: flex;
  gap: 32px;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  height: 88px;
  padding: 14px 28px;
  color: hsl(var(--foreground));
  text-align: left;
  cursor: pointer;
  background: hsl(var(--background));
  transition:
    background-color 160ms ease,
    box-shadow 160ms ease;
}

.notification-row:hover {
  background: hsl(var(--accent));
  box-shadow: inset 3px 0 0 hsl(var(--primary));
}

.notification-row--unread {
  background: hsl(var(--primary) / 5%);
}

.notification-row--unread::before {
  position: absolute;
  top: 14px;
  bottom: 14px;
  left: 0;
  width: 3px;
  content: '';
  background: hsl(var(--primary));
  border-radius: 0 3px 3px 0;
}

.notification-row__main {
  flex: 1;
  min-width: 0;
  text-align: left;
}

.notification-row__meta {
  display: flex;
  gap: 8px;
  align-items: center;
  text-align: left;
}

.notification-row__icon {
  flex-shrink: 0;
  width: 16px;
  height: 16px;
  color: hsl(var(--muted-foreground));
}

.notification-row__icon--unread {
  color: hsl(var(--primary));
}

.notification-row__time {
  font-size: 13px;
  line-height: 20px;
  color: hsl(var(--muted-foreground));
}

.notification-row__message {
  width: 100%;
  margin: 5px 0 0;
  overflow: hidden;
  text-overflow: ellipsis;
  font-size: 15px;
  font-weight: 600;
  line-height: 22px;
  color: hsl(var(--foreground));
  text-align: left;
  white-space: nowrap;
}

.notification-row__message--unread {
  font-weight: 700;
}

.notification-row__actor {
  display: flex;
  flex-shrink: 0;
  gap: 4px;
  align-items: center;
  margin: 0;
  font-size: 13px;
  line-height: 20px;
  color: hsl(var(--muted-foreground));
  text-align: right;
  white-space: nowrap;
}

.notification-row__actor strong {
  font-weight: 500;
  color: hsl(var(--foreground) / 80%);
}

.notifications-grid :deep(.vxe-table--body .vxe-body--row) {
  height: 88px !important;
}

.notifications-grid :deep(.vxe-table--body .vxe-body--column) {
  height: 88px !important;
  padding: 0 !important;
  vertical-align: middle !important;
}

.notifications-grid :deep(.vxe-table--body .vxe-cell) {
  width: 100% !important;
  height: 88px !important;
  max-height: 88px !important;
  padding: 0 !important;
  overflow: hidden !important;
  text-overflow: initial !important;
  line-height: normal !important;
  text-align: left !important;
  white-space: normal !important;
}

.notifications-grid :deep(.vxe-table--body .col--ellipsis .vxe-cell) {
  height: 88px !important;
  max-height: 88px !important;
  overflow: hidden !important;
  text-overflow: initial !important;
  white-space: normal !important;
}

.notifications-grid :deep(.vxe-table--body .vxe-body--row:hover) {
  background: transparent !important;
}

@media (max-width: 900px) {
  .notifications-heading__top {
    align-items: flex-start;
  }
}

@media (max-width: 640px) {
  .notifications-heading__top {
    flex-direction: column;
  }

  .notifications-actions {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
  }

  .notifications-actions > * {
    flex: 1;
  }

  .notifications-filter {
    width: 100%;
  }

  .read-state-segmented {
    width: 100% !important;
  }

  .notification-row {
    gap: 16px;
    padding: 14px 16px;
  }

  .notification-row__actor {
    max-width: 120px;
    overflow: hidden;
    text-overflow: ellipsis;
  }
}
</style>

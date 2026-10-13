<script setup lang="ts">
import type { Schedule } from '#/api/schedules';

import { computed, ref, watch } from 'vue';

import { VbenButton } from '@vben/common-ui';
import { createIconifyIcon } from '@vben/icons';

import { Drawer, Modal } from 'ant-design-vue';

import { $t } from '#/locales';

import { getScheduleShape, getScheduleTypeClass } from '../schedule-page';

const props = defineProps<{
  actionLoading: boolean;
  canDeleteSchedule: boolean;
  canEditSchedule: boolean;
  canJoinSchedule: boolean;
  canLeaveSchedule: boolean;
  canReuseSchedule: boolean;
  deleteDialogOpen: boolean;
  detailLoading: boolean;
  onClose: () => void;
  onCloseDeleteDialog: () => void;
  onConfirmDeleteSchedule: () => void;
  onJoinSelectedSchedule: () => void;
  onLeaveSelectedSchedule: () => void;
  onOpenDeleteDialog: () => void;
  onOpenEditDrawer: () => void;
  onOpenReuseDrawer: () => void;
  open: boolean;
  schedule: null | Schedule;
  title: string;
}>();

const VISIBLE_SCHEDULE_USERS = 8;

const TimeIcon = createIconifyIcon('lucide:clock-3');
const ParticipantsIcon = createIconifyIcon('lucide:users');
const ObserversIcon = createIconifyIcon('lucide:share-2');
const ReminderIcon = createIconifyIcon('lucide:bell');
const LocationIcon = createIconifyIcon('lucide:map-pin');
const NoteIcon = createIconifyIcon('lucide:file-text');

const participantsExpanded = ref(false);
const observersExpanded = ref(false);

const visibleParticipants = computed(() => {
  if (props.schedule === null) {
    return [];
  }

  return participantsExpanded.value
    ? props.schedule.event.participants
    : props.schedule.event.participants.slice(0, VISIBLE_SCHEDULE_USERS);
});

const visibleObservers = computed(() => {
  if (props.schedule === null) {
    return [];
  }

  return observersExpanded.value
    ? props.schedule.event.observers
    : props.schedule.event.observers.slice(0, VISIBLE_SCHEDULE_USERS);
});

const hiddenParticipantsCount = computed(() => {
  if (props.schedule === null || participantsExpanded.value) {
    return 0;
  }

  return (
    props.schedule.event.participants.length - visibleParticipants.value.length
  );
});

const hiddenObserversCount = computed(() => {
  if (props.schedule === null || observersExpanded.value) {
    return 0;
  }

  return props.schedule.event.observers.length - visibleObservers.value.length;
});

watch(
  () => props.schedule?.event.id,
  () => {
    participantsExpanded.value = false;
    observersExpanded.value = false;
  },
);

function formatScheduleDate(value: string, includeTime: boolean): string {
  const formatter = new Intl.DateTimeFormat('en-GB', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    ...(includeTime
      ? {
          hour: '2-digit' as const,
          hour12: false,
          minute: '2-digit' as const,
        }
      : {}),
    timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
  });

  return formatter.format(new Date(value)).replace(',', '');
}

function getScheduleTypeLabel(schedule: Schedule): string {
  return $t(`page.schedules.detail.typeLabels.${schedule.event.type}`);
}

function getScheduleDetailTime(schedule: Schedule): string {
  if (getScheduleShape(schedule) === 'multi-day') {
    return `${formatScheduleDate(schedule.start, false)} - ${formatScheduleDate(schedule.end, false)}`;
  }

  return `${formatScheduleDate(schedule.start, true)} - ${formatScheduleDate(schedule.end, true)}`;
}

function getScheduleRecurrenceLabel(schedule: Schedule): null | string {
  if (schedule.event.schedule_type === 'multiple_days') {
    return $t('page.schedules.detail.multiDay');
  }

  if (schedule.event.schedule_type !== 'repeat') {
    return null;
  }

  if (
    schedule.event.repeat_type === null ||
    schedule.event.repeat_start_time === null ||
    schedule.event.repeat_end_time === null
  ) {
    throw new TypeError('Invalid repeat schedule.');
  }

  return `${$t(`page.schedules.detail.repeat.${schedule.event.repeat_type}`)} · ${formatScheduleDate(schedule.event.start_date, false)} - ${formatScheduleDate(schedule.event.end_date, false)} · ${schedule.event.repeat_start_time} - ${schedule.event.repeat_end_time}`;
}

function getReminderLabel(schedule: Schedule): string {
  if (!schedule.event.has_reminder) {
    return $t('page.schedules.detail.reminderOff');
  }

  if (
    schedule.event.remind_range === null ||
    schedule.event.remind_value === null
  ) {
    throw new TypeError('Invalid reminder state.');
  }

  return $t('page.schedules.detail.reminderOn', {
    range: $t(
      `page.schedules.detail.reminderRange.${schedule.event.remind_range}`,
    ),
    value: schedule.event.remind_value,
  });
}
</script>

<template>
  <Drawer
    :open="open"
    :title="title"
    placement="right"
    width="560"
    @close="onClose"
  >
    <template #default>
      <p
        v-if="detailLoading"
        class="text-sm text-muted-foreground"
        role="status"
      >
        {{ $t('page.schedules.loading') }}
      </p>
      <div
        v-else-if="schedule"
        class="flex h-full min-h-0 flex-col text-sm"
        data-testid="schedule-detail-content"
      >
        <div class="min-h-0 flex-1 space-y-5 overflow-y-auto pr-1">
          <div class="space-y-2">
            <span
              class="inline-flex rounded-md px-2 py-1 text-xs font-medium"
              :class="getScheduleTypeClass(schedule)"
              data-testid="schedule-detail-type-badge"
            >
              {{ getScheduleTypeLabel(schedule) }}
            </span>
            <p class="text-xl font-semibold text-foreground">
              {{ schedule.event.title }}
            </p>
          </div>

          <dl class="space-y-4">
            <div class="flex items-start gap-3">
              <dt class="pt-0.5 text-muted-foreground">
                <TimeIcon
                  class="size-4"
                  data-testid="schedule-detail-time-icon"
                />
              </dt>
              <dd class="min-w-0 space-y-1 text-foreground">
                <p class="leading-5">{{ getScheduleDetailTime(schedule) }}</p>
                <p
                  v-if="getScheduleRecurrenceLabel(schedule) !== null"
                  class="leading-5 text-muted-foreground"
                >
                  {{ getScheduleRecurrenceLabel(schedule) }}
                </p>
              </dd>
            </div>
            <div
              v-if="schedule.event.participants.length > 0"
              class="flex items-start gap-3"
            >
              <dt class="pt-0.5 text-muted-foreground">
                <ParticipantsIcon
                  class="size-4"
                  data-testid="schedule-detail-participants-icon"
                />
              </dt>
              <dd class="flex flex-wrap items-center gap-2 text-foreground">
                <span
                  v-for="user in visibleParticipants"
                  :key="`participant-${user.id}`"
                  class="inline-flex rounded-sm bg-primary px-2.5 py-1 text-xs font-medium text-primary-foreground"
                  data-testid="schedule-detail-participant-badge"
                >
                  {{ user.name }}
                </span>
                <button
                  v-if="hiddenParticipantsCount > 0"
                  type="button"
                  class="inline-flex rounded-sm px-2.5 py-1 text-xs font-medium text-primary transition hover:bg-primary/10"
                  data-testid="schedule-detail-show-more-participants"
                  @click="participantsExpanded = true"
                >
                  {{
                    $t('page.schedules.detail.showMoreUsers', {
                      count: hiddenParticipantsCount,
                    })
                  }}
                </button>
                <button
                  v-else-if="participantsExpanded"
                  type="button"
                  class="inline-flex rounded-sm px-2.5 py-1 text-xs font-medium text-primary transition hover:bg-primary/10"
                  data-testid="schedule-detail-collapse-participants"
                  @click="participantsExpanded = false"
                >
                  {{ $t('page.schedules.detail.collapseUsers') }}
                </button>
              </dd>
            </div>
            <div
              v-if="schedule.event.observers.length > 0"
              class="flex items-start gap-3"
            >
              <dt class="pt-0.5 text-muted-foreground">
                <ObserversIcon
                  class="size-4"
                  data-testid="schedule-detail-observers-icon"
                />
              </dt>
              <dd class="flex flex-wrap items-center gap-2 text-foreground">
                <span
                  v-for="user in visibleObservers"
                  :key="`observer-${user.id}`"
                  class="inline-flex rounded-sm bg-muted px-2.5 py-1 text-xs font-medium"
                  data-testid="schedule-detail-observer-badge"
                >
                  {{ user.name }}
                </span>
                <button
                  v-if="hiddenObserversCount > 0"
                  type="button"
                  class="inline-flex rounded-sm px-2.5 py-1 text-xs font-medium text-primary transition hover:bg-primary/10"
                  data-testid="schedule-detail-show-more-observers"
                  @click="observersExpanded = true"
                >
                  {{
                    $t('page.schedules.detail.showMoreUsers', {
                      count: hiddenObserversCount,
                    })
                  }}
                </button>
                <button
                  v-else-if="observersExpanded"
                  type="button"
                  class="inline-flex rounded-sm px-2.5 py-1 text-xs font-medium text-primary transition hover:bg-primary/10"
                  data-testid="schedule-detail-collapse-observers"
                  @click="observersExpanded = false"
                >
                  {{ $t('page.schedules.detail.collapseUsers') }}
                </button>
              </dd>
            </div>
            <div
              v-if="schedule.event.has_reminder"
              class="flex items-start gap-3"
            >
              <dt class="pt-0.5 text-muted-foreground">
                <ReminderIcon
                  class="size-4"
                  data-testid="schedule-detail-reminder-icon"
                />
              </dt>
              <dd class="leading-5 text-foreground">
                {{ getReminderLabel(schedule) }}
              </dd>
            </div>
            <div
              v-if="schedule.event.physical_address !== null"
              class="flex items-start gap-3"
            >
              <dt class="pt-0.5 text-muted-foreground">
                <LocationIcon
                  class="size-4"
                  data-testid="schedule-detail-location-icon"
                />
              </dt>
              <dd class="leading-5 text-foreground">
                {{ schedule.event.physical_address }}
              </dd>
            </div>
            <div
              v-if="schedule.event.note !== null"
              class="flex items-start gap-3"
            >
              <dt class="pt-0.5 text-muted-foreground">
                <NoteIcon
                  class="size-4"
                  data-testid="schedule-detail-note-icon"
                />
              </dt>
              <dd class="space-y-1">
                <p class="whitespace-pre-wrap leading-6 text-foreground">
                  {{ schedule.event.note }}
                </p>
              </dd>
            </div>
          </dl>
        </div>
      </div>
    </template>

    <template #footer>
      <div
        v-if="
          schedule &&
          (canEditSchedule ||
            canDeleteSchedule ||
            canReuseSchedule ||
            canJoinSchedule ||
            canLeaveSchedule)
        "
        class="flex w-full flex-wrap justify-end gap-2"
        data-testid="schedule-detail-footer"
      >
        <VbenButton
          v-if="canReuseSchedule"
          data-testid="schedule-action-reuse"
          variant="ghost"
          @click="onOpenReuseDrawer"
        >
          {{ $t('page.schedules.detail.actions.reuse') }}
        </VbenButton>
        <VbenButton
          v-if="canJoinSchedule"
          :disabled="actionLoading"
          data-testid="schedule-action-join"
          variant="default"
          @click="onJoinSelectedSchedule"
        >
          {{ $t('page.schedules.detail.actions.join') }}
        </VbenButton>
        <VbenButton
          v-if="canLeaveSchedule"
          :disabled="actionLoading"
          data-testid="schedule-action-leave"
          variant="secondary"
          @click="onLeaveSelectedSchedule"
        >
          {{ $t('page.schedules.detail.actions.leave') }}
        </VbenButton>
        <VbenButton
          v-if="canDeleteSchedule"
          :disabled="actionLoading"
          data-testid="schedule-action-delete"
          variant="destructive"
          @click="onOpenDeleteDialog"
        >
          {{ $t('page.schedules.detail.actions.delete') }}
        </VbenButton>
        <VbenButton
          v-if="canEditSchedule"
          data-testid="schedule-action-edit"
          variant="default"
          @click="onOpenEditDrawer"
        >
          {{ $t('page.schedules.detail.actions.edit') }}
        </VbenButton>
      </div>
    </template>
  </Drawer>

  <Modal
    :cancel-text="$t('page.schedules.delete.cancel')"
    :ok-text="$t('page.schedules.delete.confirm')"
    :open="deleteDialogOpen"
    :title="$t('page.schedules.delete.title')"
    @cancel="onCloseDeleteDialog"
    @ok="onConfirmDeleteSchedule"
  >
    <p>{{ $t('page.schedules.delete.description') }}</p>
  </Modal>
</template>

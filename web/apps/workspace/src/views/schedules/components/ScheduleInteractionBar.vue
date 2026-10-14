<script setup lang="ts">
import type { Dayjs } from 'dayjs';

import type { ScheduleUserTreeOption } from '../schedule-page';

import type { ScheduleVisibility } from '#/api/schedules';

import { VbenButton } from '@vben/common-ui';
import { ChevronLeft, ChevronRight } from '@vben/icons';

import { DatePicker, Select, TreeSelect } from 'ant-design-vue';

import { $t } from '#/locales';

export type ScheduleViewMode = 'day' | 'month' | 'week' | 'year';

const props = defineProps<{
  calendarUsersLoading: boolean;
  calendarUserTreeOptions: ScheduleUserTreeOption[];
  currentMonthLabel: string;
  isCurrentMonthSelected: boolean;
  navigationLabel: string;
  onSelectCurrentMonth: () => void;
  onShiftPeriod: (offset: number) => void;
  onUpdateSelectedCalendarUsers: (value: string[] | undefined) => void;
  onUpdateSelectedMonth: (value: Dayjs | string) => void;
  onUpdateViewMode: (mode: ScheduleViewMode) => void;
  onUpdateVisibility: (value: ScheduleVisibility | undefined) => void;
  selectedCalendarUserIds: string[];
  selectedMonthValue: string;
  showCalendarUsersFilter: boolean;
  showMonthPicker: boolean;
  viewMode: ScheduleViewMode;
  visibility: ScheduleVisibility;
  visibilityDisabled: boolean;
  visibilityOptions: Array<{ label: string; value: ScheduleVisibility }>;
}>();

const viewModeOptions: Array<{ label: string; value: ScheduleViewMode }> = [
  { label: 'day', value: 'day' },
  { label: 'week', value: 'week' },
  { label: 'month', value: 'month' },
  { label: 'year', value: 'year' },
];

function handleSelectedMonthUpdate(value: Dayjs | string): void {
  props.onUpdateSelectedMonth(value);
}

function handleVisibilityUpdate(value: unknown): void {
  props.onUpdateVisibility(value as ScheduleVisibility | undefined);
}

function handleSelectedCalendarUsersUpdate(value: unknown): void {
  props.onUpdateSelectedCalendarUsers(value as string[] | undefined);
}

function handleViewModeChange(value: unknown): void {
  props.onUpdateViewMode(value as ScheduleViewMode);
}
</script>

<template>
  <div class="rounded border border-border bg-background p-4">
    <div class="flex flex-wrap justify-between items-center gap-4">
      <span class="flex items-center gap-2">
        <VbenButton
          :aria-label="$t('page.schedules.actions.today')"
          :aria-pressed="isCurrentMonthSelected"
          size="sm"
          @click="onSelectCurrentMonth"
        >
          {{ $t('page.schedules.actions.today') }}
        </VbenButton>
        <VbenButton
          :aria-label="$t('page.schedules.actions.previousMonth')"
          size="sm"
          class="shadow-none"
          variant="outline"
          @click="onShiftPeriod(-1)"
        >
          <ChevronLeft class="size-4" />
        </VbenButton>

        <DatePicker
          v-if="showMonthPicker"
          :aria-label="$t('page.schedules.actions.selectMonth')"
          :value="selectedMonthValue"
          picker="month"
          format="MMMM, YYYY"
          value-format="YYYY-MM"
          @update:value="handleSelectedMonthUpdate"
          class="[&_*]:capitalize font-bold min-w-40"
        />
        <span
          v-else
          class="min-w-40 text-center text-sm font-bold capitalize text-foreground"
          data-testid="schedule-navigation-label"
        >
          {{ navigationLabel }}
        </span>

        <VbenButton
          :aria-label="$t('page.schedules.actions.nextMonth')"
          class="shadow-none"
          size="sm"
          variant="outline"
          @click="onShiftPeriod(1)"
        >
          <ChevronRight class="size-4" />
        </VbenButton>

        <div
          class="ml-2 flex rounded-md border border-border"
          data-testid="schedule-view-mode-switcher"
        >
          <button
            v-for="option in viewModeOptions"
            :key="option.value"
            type="button"
            class="px-3 py-1.5 text-xs font-medium transition-colors first:rounded-l-md last:rounded-r-md"
            :class="
              viewMode === option.value
                ? 'bg-primary text-primary-foreground'
                : 'text-muted-foreground hover:bg-accent hover:text-foreground'
            "
            :data-testid="`schedule-view-mode-${option.value}`"
            @click="handleViewModeChange(option.value)"
          >
            {{ $t(`page.schedules.viewMode.${option.label}`) }}
          </button>
        </div>
      </span>
      <div
        v-if="showCalendarUsersFilter"
        class="flex items-center gap-2 text-sm text-muted-foreground"
      >
        <TreeSelect
          :aria-label="$t('page.schedules.actions.selectCalendars')"
          :loading="calendarUsersLoading"
          :tree-data="calendarUserTreeOptions"
          :value="selectedCalendarUserIds"
          data-testid="calendar-user-tree-select"
          @update:value="handleSelectedCalendarUsersUpdate"
          class="w-128"
          tree-checkable
          allow-clear
          :show-checked-strategy="TreeSelect.SHOW_CHILD"
          tree-node-filter-prop="label"
          max-tag-count="responsive"
        />
        <Select
          :aria-label="$t('page.schedules.actions.selectVisibility')"
          :disabled="visibilityDisabled"
          :options="visibilityOptions"
          :value="visibility"
          class="min-w-52"
          @update:value="handleVisibilityUpdate"
        />
      </div>
    </div>
  </div>
</template>

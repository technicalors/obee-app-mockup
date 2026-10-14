<script setup lang="ts">
import type { Schedule } from '#/api/schedules';

import { computed } from 'vue';

import { Tooltip } from 'ant-design-vue';

import { $t } from '#/locales';

import {
  buildYearGrid,
  formatDayKey,
  formatDayKeyInTimeZone,
  getScheduleTypeClass,
  parseDayKey,
} from '../schedule-page';

const props = defineProps<{
  allowCreate: boolean;
  hasCompany: boolean;
  loading: boolean;
  locale: string;
  onOpenCreateDrawer: (date: string) => void;
  onOpenScheduleDetail: (scheduleId: string) => void;
  onSelectDay: (date: string) => void;
  onSelectMonth: (monthValue: string) => void;
  schedules: Schedule[];
  today: string;
  year: number;
}>();

const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;

const weekdayHeaders = computed(() => {
  if (props.locale.startsWith('vi')) {
    return ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  }
  const formatter = new Intl.DateTimeFormat(props.locale, { weekday: 'narrow' });
  return Array.from({ length: 7 }, (_, i) =>
    formatter.format(new Date(Date.UTC(2026, 5, 15 + i))),
  );
});

const yearMonths = computed(() => buildYearGrid(props.year, props.locale));

// Map schedules by date 'YYYY-MM-DD'
const schedulesByDate = computed(() => {
  const map = new Map<string, Schedule[]>();

  for (const schedule of props.schedules) {
    const startKey = formatDayKeyInTimeZone(schedule.start, timeZone);
    const endKey = formatDayKeyInTimeZone(schedule.end, timeZone);

    if (startKey === endKey) {
      const list = map.get(startKey) ?? [];
      list.push(schedule);
      map.set(startKey, list);
    } else {
      let current = parseDayKey(startKey);
      const end = parseDayKey(endKey);

      while (current <= end) {
        const key = formatDayKey(current);
        const list = map.get(key) ?? [];
        list.push(schedule);
        map.set(key, list);
        current = new Date(current.getTime() + 86_400_000);
      }
    }
  }

  return map;
});

// Event count per month 'YYYY-MM'
const eventCountByMonth = computed(() => {
  const map = new Map<string, number>();

  for (const month of yearMonths.value) {
    let count = 0;
    const seenEventIds = new Set<string>();

    for (const day of month.days) {
      const daySchedules = schedulesByDate.value.get(day.date) ?? [];
      for (const s of daySchedules) {
        if (!seenEventIds.has(s.id)) {
          seenEventIds.add(s.id);
          count++;
        }
      }
    }

    map.set(month.monthValue, count);
  }

  return map;
});

function formatEventTime(isoString: string): string {
  const formatter = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit',
    hour12: false,
    minute: '2-digit',
    timeZone,
  });
  return formatter.format(new Date(isoString));
}

function handleMonthClick(monthValue: string): void {
  props.onSelectMonth(monthValue);
}

function handleDayClick(date: string): void {
  props.onSelectDay(date);
}

function getDotColor(schedule: Schedule): string {
  const typeClass = getScheduleTypeClass(schedule);
  if (typeClass.includes('emerald')) return 'bg-emerald-500';
  if (typeClass.includes('sky')) return 'bg-sky-500';
  if (typeClass.includes('amber')) return 'bg-amber-500';
  if (typeClass.includes('purple')) return 'bg-purple-500';
  if (typeClass.includes('rose')) return 'bg-rose-500';
  if (typeClass.includes('indigo')) return 'bg-indigo-500';
  return 'bg-primary';
}
</script>

<template>
  <div
    data-testid="schedule-year-view"
    :aria-busy="loading"
    class="flex flex-col bg-background p-6"
  >
    <p v-if="loading" class="p-4 text-sm text-muted-foreground" role="status">
      {{ $t('page.schedules.loading') }}
    </p>

    <div
      v-else
      class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
    >
      <div
        v-for="month in yearMonths"
        :key="month.monthValue"
        class="flex flex-col rounded-xl border border-border/70 bg-card p-4 shadow-sm transition-all hover:border-primary/40 hover:shadow-md"
      >
        <!-- Month Header -->
        <div class="mb-3 flex items-center justify-between">
          <button
            type="button"
            class="group flex items-center gap-1.5 text-left text-sm font-bold capitalize text-foreground transition-colors hover:text-primary"
            :title="$t('page.schedules.yearView.clickMonthToView')"
            @click="handleMonthClick(month.monthValue)"
          >
            <span>{{ month.monthLabel }}</span>
            <span
              class="text-xs text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100"
            >
              &rarr;
            </span>
          </button>

          <span
            v-if="(eventCountByMonth.get(month.monthValue) ?? 0) > 0"
            class="rounded-full bg-primary/10 px-2 py-0.5 text-[11px] font-medium text-primary"
          >
            {{ $t('page.schedules.yearView.eventsCount', { count: eventCountByMonth.get(month.monthValue) }) }}
          </span>
        </div>

        <!-- Weekday Headers -->
        <div class="mb-1.5 grid grid-cols-7 text-center">
          <span
            v-for="(label, idx) in weekdayHeaders"
            :key="label"
            class="py-1 text-[11px] font-semibold"
            :class="
              idx === 5
                ? 'text-sky-500'
                : idx === 6
                  ? 'text-pink-500'
                  : 'text-muted-foreground'
            "
          >
            {{ label }}
          </span>
        </div>

        <!-- Days Grid -->
        <div class="grid grid-cols-7 gap-y-1 text-center">
          <!-- Leading empty slots -->
          <div
            v-for="emptyIdx in month.leadingEmptyDays"
            :key="`empty-${emptyIdx}`"
            class="h-8"
          />

          <!-- Day Cells -->
          <div
            v-for="day in month.days"
            :key="day.date"
            class="flex flex-col items-center justify-center"
          >
            <!-- Day with events: wrap in Tooltip -->
            <Tooltip
              v-if="(schedulesByDate.get(day.date) ?? []).length > 0"
              placement="top"
            >
              <template #title>
                <div class="max-w-xs space-y-1 p-0.5 text-xs">
                  <div class="font-bold border-b border-white/20 pb-1">
                    {{ day.date }}
                  </div>
                  <div
                    v-for="s in schedulesByDate.get(day.date)"
                    :key="s.id"
                    class="flex items-center gap-1.5 py-0.5"
                  >
                    <span
                      class="size-1.5 shrink-0 rounded-full"
                      :class="getDotColor(s)"
                    />
                    <span class="truncate font-medium">{{ s.event.title }}</span>
                    <span class="shrink-0 text-[10px] opacity-75">
                      {{ formatEventTime(s.start) }}
                    </span>
                  </div>
                  <div class="pt-1 text-[10px] opacity-70 italic">
                    {{ $t('page.schedules.yearView.clickToView') }}
                  </div>
                </div>
              </template>

              <button
                type="button"
                class="group relative flex size-7 flex-col items-center justify-center rounded-full transition-all hover:bg-accent focus:outline-none"
                :class="[
                  day.date === today
                    ? 'bg-primary text-primary-foreground font-bold shadow-sm hover:bg-primary/90'
                    : 'text-foreground',
                ]"
                :data-testid="`year-day-${day.date}`"
                @click="handleDayClick(day.date)"
              >
                <span class="text-xs leading-none">{{ day.dayNumber }}</span>

                <!-- Event dots -->
                <div class="mt-0.5 flex items-center gap-0.5">
                  <span
                    v-for="s in (schedulesByDate.get(day.date) ?? []).slice(0, 3)"
                    :key="s.id"
                    class="size-1 rounded-full"
                    :class="day.date === today ? 'bg-primary-foreground' : getDotColor(s)"
                  />
                </div>
              </button>
            </Tooltip>

            <!-- Day without events -->
            <button
              v-else
              type="button"
              class="flex size-7 items-center justify-center rounded-full text-xs transition-all hover:bg-accent/60 focus:outline-none"
              :class="[
                day.date === today
                  ? 'bg-primary text-primary-foreground font-bold shadow-sm hover:bg-primary/90'
                  : day.isWeekend
                    ? 'text-muted-foreground/80'
                    : 'text-foreground',
              ]"
              :data-testid="`year-day-${day.date}`"
              @click="handleDayClick(day.date)"
            >
              {{ day.dayNumber }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

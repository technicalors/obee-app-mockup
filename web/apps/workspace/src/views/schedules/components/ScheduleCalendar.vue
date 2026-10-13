<script setup lang="ts">
import type { ScheduleMonthGridCell } from '../schedule-page';

import type { Schedule } from '#/api/schedules';

import { computed } from 'vue';

import { VbenIconButton } from '@vben/common-ui';
import { createIconifyIcon } from '@vben/icons';

import { Avatar } from 'ant-design-vue';

import { $t } from '#/locales';

import {
  buildWeekSegments,
  formatScheduleTileMeta,
  getScheduleCardClass,
  getScheduleShape,
  getScheduleTypeClass,
} from '../schedule-page';

const props = defineProps<{
  allowCreate: boolean;
  hasCompany: boolean;
  loading: boolean;
  monthGridCells: ScheduleMonthGridCell[];
  onOpenCreateDrawer: (date: string) => void;
  onOpenScheduleDetail: (scheduleId: string) => void;
  sectionUsers: Array<{
    avatar: null | string;
    key: string;
    title: string;
  }>;
}>();

const PlusIcon = createIconifyIcon('lucide:plus');
const RepeatIcon = createIconifyIcon('lucide:repeat');

const weekRows = computed(() =>
  Array.from(
    { length: Math.ceil(props.monthGridCells.length / 7) },
    (_, index) => {
      const cells = props.monthGridCells.slice(index * 7, index * 7 + 7);

      return {
        cells,
        segments: buildWeekSegments(cells),
      };
    },
  ),
);

function getCellSegments(
  date: string,
  weekSegments: ReturnType<typeof buildWeekSegments>,
) {
  return weekSegments.filter((segment) => segment.startDate === date);
}

function getCellSchedules(cell: ScheduleMonthGridCell): Schedule[] {
  return cell.schedules.filter(
    (schedule) => getScheduleShape(schedule) !== 'multi-day',
  );
}

function getCellSegmentLaneHeight(
  date: string,
  weekSegments: ReturnType<typeof buildWeekSegments>,
): number {
  if (weekSegments.length === 0) {
    return 0;
  }

  const coveringSegments = weekSegments.filter(
    (segment) => segment.startDate <= date && segment.endDate >= date,
  );

  const maxLevel = Math.max(...coveringSegments.map(({ level }) => level));
  return (maxLevel + 1) * 2.75;
}

function getSegmentWidth(columnSpan: number): string {
  return `calc(${columnSpan * 100}% + ${(columnSpan - 1) * 1.1}rem)`;
}

function getScheduleTypeLabel(schedule: Schedule): string {
  return $t(`page.schedules.form.typeOptions.${schedule.event.type}`);
}

function getScheduleVisibleUsers(
  schedule: Schedule,
): typeof props.sectionUsers {
  if (props.sectionUsers.length <= 1) {
    return [];
  }

  return props.sectionUsers.filter(
    ({ key }) =>
      schedule.event.created_by === key ||
      schedule.event.participants.some(({ id }) => id === key) ||
      schedule.event.observers.some(({ id }) => id === key),
  );
}

function getCellClass(cell: ScheduleMonthGridCell): string[] {
  const dayOfWeek = new Date(`${cell.date}T00:00:00Z`).getUTCDay();
  const borderShape =
    dayOfWeek === 0 || dayOfWeek % 2 !== 0 ? 'border-x border-b' : 'border-b';
  let borderStyle = 'border-border';
  let bgStyle = 'bg-background';
  let textStyle = '';

  if (cell.isToday) {
    bgStyle = 'bg-yellow-400/10';
  } else if (!cell.inCurrentMonth) {
    borderStyle = 'border-border/70';
    bgStyle = 'bg-muted/30';
    textStyle = 'text-muted-foreground/70';
  }

  if (dayOfWeek === 6) {
    bgStyle = cell.inCurrentMonth ? 'bg-sky-400/10' : 'bg-sky-300/10';
  } else if (dayOfWeek === 0) {
    bgStyle = cell.inCurrentMonth ? 'bg-pink-400/10' : 'bg-pink-300/10';
  }

  return [`${borderShape} ${borderStyle} ${bgStyle} ${textStyle}`];
}
</script>

<template>
  <div
    data-testid="schedule-content"
    :aria-busy="loading"
    class="bg-background"
  >
    <p v-if="loading" class="text-sm text-muted-foreground" role="status">
      {{ $t('page.schedules.loading') }}
    </p>
    <div v-else role="grid">
      <div v-for="week in weekRows" :key="week.cells[0]?.date">
        <div class="grid grid-cols-7">
          <article
            v-for="cell in week.cells"
            :key="cell.date"
            :aria-current="cell.isToday ? 'date' : undefined"
            :data-day-key="cell.date"
            data-testid="schedule-day-cell"
            class="flex min-h-70 flex-col gap-2 p-2"
            :class="getCellClass(cell)"
            role="gridcell"
          >
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <VbenIconButton
                  v-if="allowCreate && hasCompany"
                  :aria-label="`${$t('page.schedules.actions.create')} ${cell.date}`"
                  :data-create-day-key="cell.date"
                  data-testid="schedule-create-day"
                  variant="outline"
                  class="w-6 h-6"
                  @click="onOpenCreateDrawer(cell.date)"
                >
                  <PlusIcon class="size-3" />
                </VbenIconButton>
              </div>
              <div class="flex items-center gap-2">
                <span
                  :class="
                    cell.isToday ? 'font-bold underline underline-offset-2' : ''
                  "
                  class="font-semibold"
                >
                  {{ cell.dayNumber }}
                </span>
              </div>
            </div>

            <div
              class="relative"
              :data-segment-lane-date="cell.date"
              data-testid="schedule-segment-lane"
              :style="{
                height: `${getCellSegmentLaneHeight(cell.date, week.segments)}rem`,
                display: `${getCellSegmentLaneHeight(cell.date, week.segments) > 0 ? 'block' : 'hidden'}`,
                marginBottom: '-0.563rem',
              }"
            >
              <button
                v-for="segment in getCellSegments(cell.date, week.segments)"
                :key="`${segment.startDate}-${segment.schedule.id}`"
                :aria-label="segment.schedule.event.title"
                :data-schedule-id="segment.schedule.id"
                :data-schedule-shape="getScheduleShape(segment.schedule)"
                :data-schedule-span="segment.columnSpan"
                :data-schedule-type="segment.schedule.event.type"
                class="absolute left-0 z-10 flex min-w-0 items-center justify-start gap-1 px-2 py-1.5 text-left text-xs shadow-sm"
                :class="getScheduleCardClass(segment.schedule)"
                :style="{
                  top: `${segment.level * 2.75}rem`,
                  width: getSegmentWidth(segment.columnSpan),
                }"
                type="button"
                @click="onOpenScheduleDetail(segment.schedule.id)"
              >
                <span
                  v-if="getScheduleVisibleUsers(segment.schedule).length > 0"
                  data-testid="schedule-shared-user-avatars"
                  class="flex shrink-0 items-center pl-3"
                >
                  <Avatar
                    v-for="user in getScheduleVisibleUsers(segment.schedule)"
                    :key="`segment-${segment.schedule.id}-${user.key}`"
                    :size="18"
                    :src="user.avatar ?? undefined"
                    data-testid="schedule-shared-user-avatar"
                    class="border border-background bg-muted text-[9px] font-semibold text-muted-foreground"
                    style="margin-left: -9px"
                  >
                    {{ user.title.charAt(0).toUpperCase() }}
                  </Avatar>
                </span>
                <span class="min-w-0 flex-1 truncate font-medium">
                  {{ segment.schedule.event.title }}
                </span>
              </button>
            </div>

            <div class="space-y-3">
              <button
                v-for="schedule in getCellSchedules(cell)"
                :key="`${cell.date}-${schedule.id}`"
                :aria-label="schedule.event.title"
                :data-schedule-id="schedule.id"
                :data-schedule-shape="getScheduleShape(schedule)"
                :data-schedule-type="schedule.event.type"
                class="flex w-full flex-col items-start gap-1 overflow-hidden p-1.5 text-left text-xs shadow-sm"
                :class="getScheduleCardClass(schedule)"
                type="button"
                @click="onOpenScheduleDetail(schedule.id)"
              >
                <span
                  v-if="getScheduleVisibleUsers(schedule).length > 0"
                  data-testid="schedule-shared-user-avatars"
                  class="flex items-center pl-2"
                >
                  <Avatar
                    v-for="user in getScheduleVisibleUsers(schedule)"
                    :key="`cell-${schedule.id}-${user.key}`"
                    :size="18"
                    :src="user.avatar ?? undefined"
                    data-testid="schedule-shared-user-avatar"
                    class="border border-background bg-muted text-[9px] font-semibold text-muted-foreground first:ml-0"
                    style="margin-left: -10px"
                  >
                    {{ user.title.charAt(0).toUpperCase() }}
                  </Avatar>
                </span>
                <span
                  class="flex w-full flex-wrap items-center justify-between gap-2"
                >
                  <span
                    class="rounded-md px-1 py-0.5 text-[9px] font-semibold"
                    :class="getScheduleTypeClass(schedule)"
                  >
                    {{ getScheduleTypeLabel(schedule) }}
                  </span>
                  <span class="flex shrink-0 items-center gap-1 text-[10px]">
                    <RepeatIcon
                      v-if="schedule.event.schedule_type === 'repeat'"
                      size="1"
                    />
                    {{ formatScheduleTileMeta(schedule) }}
                  </span>
                </span>
                <span class="min-w-0 w-full font-medium text-xs">
                  {{ schedule.event.title }}
                </span>
              </button>
            </div>
          </article>
        </div>
      </div>
    </div>
  </div>
</template>

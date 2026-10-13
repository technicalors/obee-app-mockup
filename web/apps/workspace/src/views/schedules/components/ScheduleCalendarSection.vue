<script setup lang="ts">
import type { Schedule } from '#/api/schedules';

import { computed, ref } from 'vue';

import { useContentMaximize } from '@vben/hooks';
import { createIconifyIcon } from '@vben/icons';

import { Avatar } from 'ant-design-vue';

import { buildMonthGrid, parseMonthValue } from '../schedule-page';
import ScheduleCalendar from './ScheduleCalendar.vue';

interface ScheduleCalendarTab {
  avatar: null | string;
  canTransfer: boolean;
  key: string;
  title: string;
}

const props = defineProps<{
  allowCreate: boolean;
  hasCompany: boolean;
  loading: boolean;
  monthValue: string;
  onOpenCreateDrawer: (date: string) => void;
  onOpenScheduleDetail: (scheduleId: string) => void;
  onTransferTab: (tabKey: string) => void;
  schedules: Schedule[];
  sectionTestId: string;
  sectionUsers: ScheduleCalendarTab[];
  tabs: ScheduleCalendarTab[];
  today: string;
  weekdayLabels: string[];
}>();

const EllipsisIcon = createIconifyIcon('lucide:ellipsis');
const SwapIcon = createIconifyIcon('lucide:arrow-left-right');
const { contentIsMaximize } = useContentMaximize();

const overflowMenuOpen = ref(false);
const sectionClassHeight = computed(() =>
  contentIsMaximize.value ? 'h-[calc(100vh-10rem)]' : 'h-[calc(100vh-13rem)]',
);

const visibleTabs = computed(() => props.tabs.slice(0, 4));
const hiddenTabs = computed(() => props.tabs.slice(4));

function toggleOverflowMenu(): void {
  overflowMenuOpen.value = !overflowMenuOpen.value;
}
</script>

<template>
  <section
    :data-testid="sectionTestId"
    class="flex flex-col overflow-hidden rounded bg-background"
    :class="sectionClassHeight"
  >
    <div class="flex items-center gap-2 border-b border-border/70">
      <div
        class="relative flex flex-1 items-end gap-1 overflow-x-auto"
        data-testid="schedule-calendar-tabs"
      >
        <div
          v-for="tab in visibleTabs"
          :key="tab.key"
          class="flex shrink-0 items-center gap-1 px-4 py-2 text-sm font-medium text-foreground"
        >
          <button
            v-if="tab.canTransfer"
            type="button"
            data-testid="schedule-calendar-tab-transfer"
            class="flex size-7 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            @click="onTransferTab(tab.key)"
          >
            <SwapIcon class="size-3.5" />
          </button>
          <div
            data-testid="schedule-calendar-tab"
            class="flex min-w-0 items-center gap-2"
          >
            <Avatar
              :size="30"
              :src="tab.avatar ?? undefined"
              class="shrink-0 bg-muted text-[12px] font-semibold text-muted-foreground"
            >
              {{ tab.title.charAt(0).toUpperCase() }}
            </Avatar>
            <span
              data-testid="schedule-calendar-tab-label"
              class="max-w-40 truncate"
            >
              {{ tab.title }}
            </span>
          </div>
        </div>
      </div>

      <div v-if="hiddenTabs.length > 0" class="relative shrink-0">
        <button
          type="button"
          data-testid="schedule-calendar-tab-overflow-toggle"
          :aria-expanded="overflowMenuOpen"
          class="border-b-2 border-transparent px-3 py-2 text-sm font-semibold text-foreground transition-colors hover:text-primary"
          @click="toggleOverflowMenu"
        >
          <EllipsisIcon size="5" />
        </button>

        <div
          v-if="overflowMenuOpen"
          data-testid="schedule-calendar-tab-overflow-menu"
          class="absolute right-0 top-6 z-100 mt-2 h-56 min-w-56 overflow-y-scroll rounded-lg border border-border bg-background p-1 shadow-lg"
        >
          <div
            v-for="tab in hiddenTabs"
            :key="tab.key"
            class="flex items-center gap-1 rounded-md px-1 py-1 text-sm text-foreground transition-colors hover:bg-accent"
          >
            <button
              v-if="tab.canTransfer"
              type="button"
              data-testid="schedule-calendar-tab-overflow-transfer"
              class="flex size-7 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
              @click="onTransferTab(tab.key)"
            >
              <SwapIcon class="size-3.5" />
            </button>
            <div
              data-testid="schedule-calendar-tab-overflow-item"
              class="flex min-w-0 flex-1 items-center gap-2 rounded-md px-2 py-1 text-left text-sm text-foreground transition-colors hover:bg-accent"
            >
              <Avatar
                :size="28"
                :src="tab.avatar ?? undefined"
                class="shrink-0 bg-muted text-[12px] font-semibold text-muted-foreground"
              >
                {{ tab.title.charAt(0).toUpperCase() }}
              </Avatar>
              <span
                data-testid="schedule-calendar-tab-overflow-label"
                class="truncate"
              >
                {{ tab.title }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      class="grid grid-cols-7 text-xs font-bold uppercase tracking-wide me-[15px] bg-background"
      data-testid="schedule-calendar-weekday-header"
    >
      <div
        v-for="(weekday, index) in weekdayLabels"
        :key="weekday"
        class="bg-muted px-2 py-2 text-center border-border"
        :class="index % 2 === 0 ? 'border' : 'border-y'"
      >
        {{ weekday }}
      </div>
    </div>

    <div
      data-testid="schedule-calendar-scroll-container"
      class="min-h-0 flex-1 overflow-auto"
    >
      <ScheduleCalendar
        :allow-create="allowCreate"
        :has-company="hasCompany"
        :loading="loading"
        :month-grid-cells="
          buildMonthGrid(parseMonthValue(monthValue), schedules, today)
        "
        :on-open-create-drawer="onOpenCreateDrawer"
        :on-open-schedule-detail="onOpenScheduleDetail"
        :section-users="sectionUsers"
      />
    </div>
  </section>
</template>

<script setup lang="ts">
import type { Schedule } from '#/api/schedules';

import { computed, onMounted, onUnmounted, ref } from 'vue';

import { createIconifyIcon } from '@vben/icons';

import { $t } from '#/locales';

import {
  formatDayKeyInTimeZone,
  getScheduleShape,
  getScheduleTypeClass,
  getScheduleWeekBlockClass,
} from '../schedule-page';

const props = defineProps<{
  allowCreate: boolean;
  dates: string[];
  hasCompany: boolean;
  loading: boolean;
  onOpenCreateDrawer: (date: string) => void;
  onOpenScheduleDetail: (scheduleId: string) => void;
  onUpdateTime?: (
    scheduleId: string,
    newStartIso: string,
    newEndIso: string,
  ) => void;
  schedules: Schedule[];
  today: string;
  weekdayLabels: string[];
}>();

const PlusIcon = createIconifyIcon('lucide:plus');

const HOUR_HEIGHT = 60;
const START_HOUR = 6;
const END_HOUR = 23;
const TOTAL_HOURS = END_HOUR - START_HOUR;
const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;

const hours = Array.from({ length: TOTAL_HOURS }, (_, i) => START_HOUR + i);

const currentTimeOffset = ref(getCurrentTimeOffset());
let currentTimeTimer: ReturnType<typeof setInterval> | null = null;

function getCurrentTimeOffset(): number {
  const now = new Date();
  const formatter = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
    timeZone,
  });
  const timeString = formatter.format(now);
  const [h, m] = timeString.split(':').map(Number) as [number, number];
  return ((h - START_HOUR) * 60 + m) / (TOTAL_HOURS * 60);
}

onMounted(() => {
  currentTimeTimer = setInterval(() => {
    currentTimeOffset.value = getCurrentTimeOffset();
  }, 60_000);
});

onUnmounted(() => {
  if (currentTimeTimer !== null) {
    clearInterval(currentTimeTimer);
  }
});

function handleSlotClick(date: string, _hour: number) {
  if (props.allowCreate) {
    props.onOpenCreateDrawer(date);
  }
}

const isCurrentTimeVisible = computed(() => {
  const offset = currentTimeOffset.value;
  return (
    offset >= 0 &&
    offset <= 1 &&
    props.dates.some((d) => d === props.today)
  );
});

interface PositionedEvent {
  endMinute: number;
  left: number;
  schedule: Schedule;
  startMinute: number;
  width: number;
}

const columnEvents = computed(() => {
  const result: Record<string, PositionedEvent[]> = {};

  for (const date of props.dates) {
    const daySchedules = props.schedules
      .filter((s) => {
        if (getScheduleShape(s) === 'multi-day') return false;
        const startKey = formatDayKeyInTimeZone(s.start, timeZone);
        const endKey = formatDayKeyInTimeZone(s.end, timeZone);
        return startKey <= date && endKey >= date;
      })
      .map((s) => {
        const startMin = getMinuteOfDay(s.start);
        const endMin = getMinuteOfDay(s.end);
        return {
          schedule: s,
          startMinute: Math.max(startMin, START_HOUR * 60),
          endMinute: Math.min(endMin, END_HOUR * 60),
        };
      })
      .filter((e) => e.endMinute > e.startMinute);

    daySchedules.sort((a, b) => a.startMinute - b.startMinute || a.endMinute - b.endMinute);

    const columns: (typeof daySchedules[number])[][] = [];
    const positioned: PositionedEvent[] = [];

    for (const event of daySchedules) {
      let placed = false;
      for (const col of columns) {
        const last = col[col.length - 1];
        if (last && last.endMinute <= event.startMinute) {
          col.push(event);
          placed = true;
          break;
        }
      }
      if (!placed) {
        columns.push([event]);
      }
    }

    for (let colIndex = 0; colIndex < columns.length; colIndex++) {
      for (const event of columns[colIndex]!) {
        positioned.push({
          ...event,
          left: colIndex / columns.length,
          width: 1 / columns.length,
        });
      }
    }

    result[date] = positioned;
  }

  return result;
});

const allDayEvents = computed(() => {
  const result: Record<string, Schedule[]> = {};
  for (const date of props.dates) {
    result[date] = props.schedules.filter((s) => {
      if (getScheduleShape(s) !== 'multi-day') return false;
      const startKey = formatDayKeyInTimeZone(s.start, timeZone);
      const endKey = formatDayKeyInTimeZone(s.end, timeZone);
      return startKey <= date && endKey >= date;
    });
  }
  return result;
});

function getMinuteOfDay(iso: string): number {
  const formatter = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
    timeZone,
  });
  const timeString = formatter.format(new Date(iso));
  const [h, m] = timeString.split(':').map(Number) as [number, number];
  return h * 60 + m;
}

function getEventTop(startMinute: number): number {
  return ((startMinute - START_HOUR * 60) / 60) * HOUR_HEIGHT;
}

function getEventHeight(startMinute: number, endMinute: number): number {
  return Math.max(((endMinute - startMinute) / 60) * HOUR_HEIGHT, 20);
}

function formatHour(hour: number): string {
  return `${String(hour).padStart(2, '0')}:00`;
}

function formatEventTime(schedule: Schedule): string {
  const startMin = getMinuteOfDay(schedule.start);
  const endMin = getMinuteOfDay(schedule.end);
  const sh = Math.floor(startMin / 60);
  const sm = startMin % 60;
  const eh = Math.floor(endMin / 60);
  const em = endMin % 60;
  return `${String(sh).padStart(2, '0')}:${String(sm).padStart(2, '0')} - ${String(eh).padStart(2, '0')}:${String(em).padStart(2, '0')}`;
}

function getDateDayOfWeek(date: string): string {
  const d = new Date(`${date}T00:00:00Z`);
  const dayIndex = d.getUTCDay();
  const mondayIndex = dayIndex === 0 ? 6 : dayIndex - 1;
  return props.weekdayLabels[mondayIndex] ?? '';
}

function getDateDayNumber(date: string): string {
  return String(Number(date.slice(8, 10)));
}

function getScheduleTypeLabel(schedule: Schedule): string {
  return $t(`page.schedules.form.typeOptions.${schedule.event.type}`);
}

const gridColumnsRef = ref<HTMLElement | null>(null);

// Drag State (Moving event)
interface DragState {
  currentDate: string;
  currentStartMinute: number;
  duration: number;
  hasMoved: boolean;
  initialMouseX: number;
  initialMouseY: number;
  originalDate: string;
  originalStartMinute: number;
  schedule: Schedule;
}
const activeDrag = ref<DragState | null>(null);

// Resize State (Changing duration)
interface ResizeState {
  currentEndMinute: number;
  date: string;
  hasResized: boolean;
  initialMouseY: number;
  originalEndMinute: number;
  schedule: Schedule;
  startMinute: number;
}
const activeResize = ref<ResizeState | null>(null);

function formatIsoTime(dateStr: string, totalMinutes: number): string {
  const h = Math.floor(totalMinutes / 60);
  const m = totalMinutes % 60;
  return `${dateStr}T${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}:00+07:00`;
}

function formatMinutesRange(startMin: number, endMin: number): string {
  const sh = Math.floor(startMin / 60);
  const sm = startMin % 60;
  const eh = Math.floor(endMin / 60);
  const em = endMin % 60;
  return `${String(sh).padStart(2, '0')}:${String(sm).padStart(2, '0')} - ${String(eh).padStart(2, '0')}:${String(em).padStart(2, '0')}`;
}

// Start dragging event card
function handleEventMouseDown(
  e: MouseEvent,
  schedule: Schedule,
  date: string,
  startMinute: number,
  endMinute: number,
): void {
  // Only primary mouse button
  if (e.button !== 0) return;
  e.preventDefault();

  const duration = endMinute - startMinute;
  activeDrag.value = {
    currentDate: date,
    currentStartMinute: startMinute,
    duration,
    hasMoved: false,
    initialMouseX: e.clientX,
    initialMouseY: e.clientY,
    originalDate: date,
    originalStartMinute: startMinute,
    schedule,
  };

  document.body.style.userSelect = 'none';

  const handleMouseMove = (moveEvent: MouseEvent): void => {
    if (!activeDrag.value) return;

    const deltaY = moveEvent.clientY - activeDrag.value.initialMouseY;
    const deltaX = moveEvent.clientX - activeDrag.value.initialMouseX;

    if (!activeDrag.value.hasMoved && (Math.abs(deltaY) > 4 || Math.abs(deltaX) > 4)) {
      activeDrag.value.hasMoved = true;
      document.body.style.cursor = 'grabbing';
    }

    if (activeDrag.value.hasMoved) {
      // 15-minute snapping
      const deltaMinutes = Math.round(((deltaY / HOUR_HEIGHT) * 60) / 15) * 15;
      const newStart = Math.max(
        START_HOUR * 60,
        Math.min(
          END_HOUR * 60 - activeDrag.value.duration,
          activeDrag.value.originalStartMinute + deltaMinutes,
        ),
      );
      activeDrag.value.currentStartMinute = newStart;

      // Detect date column by mouse X
      if (gridColumnsRef.value && props.dates.length > 1) {
        const rect = gridColumnsRef.value.getBoundingClientRect();
        const colWidth = rect.width / props.dates.length;
        const colIdx = Math.floor((moveEvent.clientX - rect.left) / colWidth);
        const clampedCol = Math.max(0, Math.min(props.dates.length - 1, colIdx));
        activeDrag.value.currentDate = props.dates[clampedCol]!;
      }
    }
  };

  const handleMouseUp = (): void => {
    window.removeEventListener('mousemove', handleMouseMove);
    window.removeEventListener('mouseup', handleMouseUp);
    document.body.style.userSelect = '';
    document.body.style.cursor = '';

    if (activeDrag.value) {
      if (activeDrag.value.hasMoved && props.onUpdateTime) {
        const newStartIso = formatIsoTime(
          activeDrag.value.currentDate,
          activeDrag.value.currentStartMinute,
        );
        const newEndIso = formatIsoTime(
          activeDrag.value.currentDate,
          activeDrag.value.currentStartMinute + activeDrag.value.duration,
        );
        props.onUpdateTime(activeDrag.value.schedule.id, newStartIso, newEndIso);
      } else if (!activeDrag.value.hasMoved) {
        props.onOpenScheduleDetail(schedule.id);
      }
      activeDrag.value = null;
    }
  };

  window.addEventListener('mousemove', handleMouseMove);
  window.addEventListener('mouseup', handleMouseUp);
}

// Start resizing event card from bottom
function handleResizeMouseDown(
  e: MouseEvent,
  schedule: Schedule,
  date: string,
  startMinute: number,
  endMinute: number,
): void {
  e.stopPropagation();
  e.preventDefault();

  activeResize.value = {
    currentEndMinute: endMinute,
    date,
    hasResized: false,
    initialMouseY: e.clientY,
    originalEndMinute: endMinute,
    schedule,
    startMinute,
  };

  document.body.style.userSelect = 'none';
  document.body.style.cursor = 'ns-resize';

  const handleMouseMove = (moveEvent: MouseEvent): void => {
    if (!activeResize.value) return;

    const deltaY = moveEvent.clientY - activeResize.value.initialMouseY;
    if (!activeResize.value.hasResized && Math.abs(deltaY) > 3) {
      activeResize.value.hasResized = true;
    }

    if (activeResize.value.hasResized) {
      const deltaMinutes = Math.round(((deltaY / HOUR_HEIGHT) * 60) / 15) * 15;
      const newEnd = Math.max(
        activeResize.value.startMinute + 15,
        Math.min(END_HOUR * 60, activeResize.value.originalEndMinute + deltaMinutes),
      );
      activeResize.value.currentEndMinute = newEnd;
    }
  };

  const handleMouseUp = (): void => {
    window.removeEventListener('mousemove', handleMouseMove);
    window.removeEventListener('mouseup', handleMouseUp);
    document.body.style.userSelect = '';
    document.body.style.cursor = '';

    if (activeResize.value) {
      if (
        activeResize.value.hasResized &&
        activeResize.value.currentEndMinute !== activeResize.value.originalEndMinute &&
        props.onUpdateTime
      ) {
        const newEndIso = formatIsoTime(
          activeResize.value.date,
          activeResize.value.currentEndMinute,
        );
        props.onUpdateTime(
          activeResize.value.schedule.id,
          activeResize.value.schedule.start,
          newEndIso,
        );
      }
      activeResize.value = null;
    }
  };

  window.addEventListener('mousemove', handleMouseMove);
  window.addEventListener('mouseup', handleMouseUp);
}
</script>

<template>
  <div
    data-testid="schedule-week-view"
    :aria-busy="loading"
    class="flex flex-col bg-background"
  >
    <p v-if="loading" class="p-4 text-sm text-muted-foreground" role="status">
      {{ $t('page.schedules.loading') }}
    </p>

    <template v-else>
      <!-- All-day events row -->
      <div class="flex border-b border-border">
        <div class="w-16 shrink-0 border-r border-border bg-muted/30 px-1 py-1 text-center text-[10px] font-medium text-muted-foreground">
          {{ $t('page.schedules.weekView.allDay') }}
        </div>
        <div class="grid flex-1" :style="{ gridTemplateColumns: `repeat(${dates.length}, 1fr)` }">
          <div
            v-for="date in dates"
            :key="`allday-${date}`"
            class="min-h-8 border-r border-border/50 px-1 py-1"
          >
            <button
              v-for="schedule in (allDayEvents[date] ?? [])"
              :key="`allday-${date}-${schedule.id}`"
              type="button"
              class="mb-0.5 block w-full truncate rounded px-1.5 py-0.5 text-left text-[10px] font-medium"
              :class="getScheduleTypeClass(schedule)"
              @click="onOpenScheduleDetail(schedule.id)"
            >
              {{ schedule.event.title }}
            </button>
          </div>
        </div>
      </div>

      <!-- Column headers -->
      <div class="flex border-b border-border">
        <div class="w-16 shrink-0" />
        <div class="grid flex-1" :style="{ gridTemplateColumns: `repeat(${dates.length}, 1fr)` }">
          <div
            v-for="date in dates"
            :key="`header-${date}`"
            class="flex flex-col items-center border-r border-border/50 py-2"
            :class="date === today ? 'bg-primary/5' : ''"
          >
            <span class="text-[10px] font-medium uppercase text-muted-foreground">
              {{ getDateDayOfWeek(date) }}
            </span>
            <span
              class="mt-0.5 flex size-8 items-center justify-center rounded-full text-sm font-bold"
              :class="date === today ? 'bg-primary text-primary-foreground' : 'text-foreground'"
            >
              {{ getDateDayNumber(date) }}
            </span>
            <button
              v-if="allowCreate && hasCompany"
              type="button"
              class="mt-1 flex size-5 items-center justify-center rounded text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
              data-testid="schedule-week-create-day"
              @click="onOpenCreateDrawer(date)"
            >
              <PlusIcon class="size-3" />
            </button>
          </div>
        </div>
      </div>

      <!-- Time grid -->
      <div class="relative flex flex-1 overflow-y-auto">
        <!-- Time labels -->
        <div class="w-16 shrink-0">
          <div
            v-for="hour in hours"
            :key="hour"
            class="relative border-r border-border"
            :style="{ height: `${HOUR_HEIGHT}px` }"
          >
            <span
              class="absolute -top-2.5 right-2 text-[10px] font-medium text-muted-foreground"
            >
              {{ formatHour(hour) }}
            </span>
          </div>
        </div>

        <!-- Day columns -->
        <div
          ref="gridColumnsRef"
          class="relative grid flex-1 select-none"
          :style="{ gridTemplateColumns: `repeat(${dates.length}, 1fr)` }"
        >
          <!-- Grid lines -->
          <template v-for="date in dates" :key="`grid-${date}`">
            <div
              class="relative border-r border-border/50"
              :class="date === today ? 'bg-primary/[0.02]' : ''"
            >
              <div
                v-for="hour in hours"
                :key="`line-${date}-${hour}`"
                class="border-b border-border/40 transition-colors hover:bg-accent/30"
                :style="{ height: `${HOUR_HEIGHT}px` }"
                @click="handleSlotClick(date, hour)"
              />

              <!-- Events -->
              <div
                v-for="event in (columnEvents[date] ?? [])"
                :key="`event-${date}-${event.schedule.id}`"
                class="group absolute z-10 flex flex-col overflow-hidden rounded-md border-l-[3.5px] px-2 py-1 text-left shadow-xs transition hover:shadow-md cursor-grab active:cursor-grabbing select-none"
                :class="[
                  getScheduleWeekBlockClass(event.schedule),
                  activeDrag?.schedule.id === event.schedule.id ? 'opacity-30 pointer-events-none' : '',
                ]"
                :style="{
                  top: `${getEventTop(event.startMinute)}px`,
                  height: `${getEventHeight(
                    event.startMinute,
                    activeResize?.schedule.id === event.schedule.id
                      ? activeResize.currentEndMinute
                      : event.endMinute,
                  )}px`,
                  left: `calc(${event.left * 100}% + 2px)`,
                  width: `calc(${event.width * 100}% - 4px)`,
                }"
                @mousedown="handleEventMouseDown($event, event.schedule, date, event.startMinute, event.endMinute)"
              >
                <div class="flex items-center justify-between gap-1">
                  <span class="truncate text-[11px] font-bold leading-tight">
                    {{ event.schedule.event.title }}
                  </span>
                  <span
                    v-if="event.schedule.event.meeting_url"
                    class="size-2 rounded-full bg-primary shrink-0"
                    title="Có link họp trực tuyến"
                  />
                </div>
                <span
                  v-if="getEventHeight(event.startMinute, event.endMinute) > 34"
                  class="truncate text-[10px] opacity-80 font-medium"
                >
                  {{
                    activeResize?.schedule.id === event.schedule.id
                      ? formatMinutesRange(event.startMinute, activeResize.currentEndMinute)
                      : formatEventTime(event.schedule)
                  }}
                </span>
                <span
                  v-if="getEventHeight(event.startMinute, event.endMinute) > 50"
                  class="truncate text-[9px] opacity-70"
                >
                  {{ getScheduleTypeLabel(event.schedule) }}
                </span>

                <!-- Bottom Resize Handle -->
                <div
                  class="absolute bottom-0 left-0 right-0 h-3 cursor-ns-resize flex items-end justify-center pb-0.5 opacity-60 hover:opacity-100 group-hover:opacity-100 transition-opacity z-20"
                  title="Kéo viền để thay đổi thời lượng"
                  @mousedown.stop="handleResizeMouseDown($event, event.schedule, date, event.startMinute, event.endMinute)"
                >
                  <div class="h-1 w-8 rounded-full bg-foreground/40 hover:bg-primary transition-colors" />
                </div>
              </div>
            </div>
          </template>

          <!-- Dragging Ghost Preview -->
          <div
            v-if="activeDrag && activeDrag.hasMoved"
            class="pointer-events-none absolute z-40 flex flex-col overflow-hidden rounded-md border-2 border-dashed border-primary bg-primary/25 px-2 py-1 shadow-2xl backdrop-blur-xs ring-2 ring-primary"
            :style="{
              top: `${getEventTop(activeDrag.currentStartMinute)}px`,
              height: `${getEventHeight(activeDrag.currentStartMinute, activeDrag.currentStartMinute + activeDrag.duration)}px`,
              left: `calc(${(dates.indexOf(activeDrag.currentDate) / dates.length) * 100}% + 4px)`,
              width: `calc(${100 / dates.length}% - 8px)`,
            }"
          >
            <span class="truncate text-[11px] font-bold text-foreground">
              {{ activeDrag.schedule.event.title }}
            </span>
            <span class="text-[10px] font-bold text-primary">
              {{ formatMinutesRange(activeDrag.currentStartMinute, activeDrag.currentStartMinute + activeDrag.duration) }}
            </span>
            <span class="text-[9px] text-muted-foreground">
              {{ activeDrag.currentDate }}
            </span>
          </div>

          <!-- Current time indicator -->
          <div
            v-if="isCurrentTimeVisible"
            class="pointer-events-none absolute left-0 right-0 z-20"
            data-testid="current-time-indicator"
            :style="{ top: `${currentTimeOffset * TOTAL_HOURS * HOUR_HEIGHT}px` }"
          >
            <div class="flex items-center">
              <div class="size-2.5 rounded-full bg-red-500" />
              <div class="h-[2px] flex-1 bg-red-500" />
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

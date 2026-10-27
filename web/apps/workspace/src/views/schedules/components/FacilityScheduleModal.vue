<script setup lang="ts">
import type { Schedule } from '#/api/schedules';

import { computed, onMounted, onUnmounted, ref, watch } from 'vue';

import { VbenButton } from '@vben/common-ui';
import { ChevronLeft, ChevronRight, createIconifyIcon } from '@vben/icons';

import { DatePicker, message, Modal, Radio, Tag, Tooltip } from 'ant-design-vue';

import { mockEquipments } from '#/mocks/data';

export interface SelectedFacilityItem {
  durationHours: number;
  end: string;
  endMinute: number;
  equipmentCode: string;
  equipmentId: string;
  equipmentName: string;
  start: string;
  startMinute: number;
}

const props = defineProps<{
  currentTimeRange?: null | { end: string; start: string };
  date: string;
  open: boolean;
  schedules: Schedule[];
  selectedEquipmentIds: string[];
}>();

const emit = defineEmits<{
  close: [];
  selectEquipments: [
    equipmentIds: string[],
    selections: SelectedFacilityItem[],
    date?: string,
  ];
  selectTimeAndEquipment: [
    equipmentId: string,
    start: string,
    end: string,
    date?: string,
  ];
}>();

const CalendarIcon = createIconifyIcon('lucide:calendar');
const CheckCircleIcon = createIconifyIcon('lucide:check-circle-2');
const AlertTriangleIcon = createIconifyIcon('lucide:alert-triangle');
const XIcon = createIconifyIcon('lucide:x');

const selectedDate = ref(props.date || new Date().toISOString().slice(0, 10));

watch(
  () => props.date,
  (newDate) => {
    if (newDate) {
      selectedDate.value = newDate;
    }
  },
);

// Time window filter
type TimeWindow = '24h' | 'afternoon' | 'all' | 'morning';
const timeWindow = ref<TimeWindow>('all');

// Automatically switch to 24h view if current range is outside 07:00 - 20:00
watch(
  () => props.currentTimeRange,
  (range) => {
    if (range?.start && range?.end) {
      const [sh] = range.start.split(':').map(Number) as [number];
      const [eh] = range.end.split(':').map(Number) as [number];
      if (sh < 7 || eh > 20) {
        timeWindow.value = '24h';
      }
    }
  },
  { immediate: true },
);

const timeWindowConfig = computed(() => {
  switch (timeWindow.value) {
    case 'morning': {
      return { endHour: 13, startHour: 7 };
    }
    case 'afternoon': {
      return { endHour: 19, startHour: 12 };
    }
    case '24h': {
      return { endHour: 24, startHour: 0 };
    }
    default: {
      return { endHour: 20, startHour: 7 };
    }
  }
});

const startHour = computed(() => timeWindowConfig.value.startHour);
const endHour = computed(() => timeWindowConfig.value.endHour);
const totalHours = computed(() => endHour.value - startHour.value);
const hours = computed(() =>
  Array.from({ length: totalHours.value }, (_, i) => startHour.value + i),
);

// 30-minute granularity slots
interface TimelineSlot {
  endMinute: number;
  hour: number;
  index: number;
  isFirstHalf: boolean;
  label: string;
  startMinute: number;
}

const slots = computed<TimelineSlot[]>(() => {
  const result: TimelineSlot[] = [];
  let idx = 0;
  for (let h = startHour.value; h < endHour.value; h++) {
    // 00 - 30
    result.push({
      endMinute: h * 60 + 30,
      hour: h,
      index: idx++,
      isFirstHalf: true,
      label: `${String(h).padStart(2, '0')}:00 - ${String(h).padStart(2, '0')}:30`,
      startMinute: h * 60,
    });
    // 30 - 60
    result.push({
      endMinute: (h + 1) * 60,
      hour: h,
      index: idx++,
      isFirstHalf: false,
      label: `${String(h).padStart(2, '0')}:30 - ${String(h + 1).padStart(2, '0')}:00`,
      startMinute: h * 60 + 30,
    });
  }
  return result;
});

// Planned event boundaries down to exact minutes
const boundaryMinutes = computed(() => {
  if (!props.currentTimeRange?.start || !props.currentTimeRange?.end) {
    return null;
  }
  const [sh, sm] = props.currentTimeRange.start
    .split(':')
    .map(Number) as [number, number];
  const [eh, em] = props.currentTimeRange.end
    .split(':')
    .map(Number) as [number, number];

  return {
    end: eh * 60 + em,
    endText: props.currentTimeRange.end,
    start: sh * 60 + sm,
    startText: props.currentTimeRange.start,
  };
});

function isSlotOutsideBoundary(slotStartMin: number, slotEndMin: number): boolean {
  if (!boundaryMinutes.value) return false;
  return (
    slotEndMin <= boundaryMinutes.value.start ||
    slotStartMin >= boundaryMinutes.value.end
  );
}

function formatMinuteToTime(totalMin: number): string {
  const h = Math.floor(totalMin / 60);
  const m = totalMin % 60;
  return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
}

function shiftDate(offset: number): void {
  const d = new Date(`${selectedDate.value}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + offset);
  selectedDate.value = d.toISOString().slice(0, 10);
}

function selectToday(): void {
  selectedDate.value = new Date().toISOString().slice(0, 10);
}

function handleDateChange(val: unknown): void {
  if (typeof val === 'string') {
    selectedDate.value = val;
  }
}

// Multi-equipment selections store: equipmentId -> SelectedFacilityItem
const selectedItems = ref<Record<string, SelectedFacilityItem>>({});

// Initialize / Sync selected items when modal opens
watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      activeDrag.value = null;
      const initialMap: Record<string, SelectedFacilityItem> = {};
      if (props.selectedEquipmentIds && props.selectedEquipmentIds.length > 0) {
        const start = props.currentTimeRange?.start ?? '08:00';
        const end = props.currentTimeRange?.end ?? '17:00';
        const startMin = boundaryMinutes.value?.start ?? parseMinute(start);
        const endMin = boundaryMinutes.value?.end ?? parseMinute(end);
        const durationHours = Number(
          Math.max(0.5, (endMin - startMin) / 60).toFixed(1),
        );

        for (const id of props.selectedEquipmentIds) {
          const eq = mockEquipments.find((e) => e.id === id);
          if (eq) {
            initialMap[id] = {
              durationHours,
              end,
              endMinute: endMin,
              equipmentCode: eq.code,
              equipmentId: id,
              equipmentName: eq.name,
              start,
              startMinute: startMin,
            };
          }
        }
      }
      selectedItems.value = initialMap;
    }
  },
  { immediate: true },
);

function parseMinute(timeStr: string): number {
  const [h, m] = timeStr.split(':').map(Number) as [number, number];
  return h * 60 + m;
}

// Sort equipment: selected equipment first, then meeting rooms, then others
const sortedEquipments = computed(() => {
  return [...mockEquipments].sort((a, b) => {
    const aSelected = Boolean(selectedItems.value[a.id]);
    const bSelected = Boolean(selectedItems.value[b.id]);
    if (aSelected && !bSelected) return -1;
    if (!aSelected && bSelected) return 1;
    const aIsRoom = a.code.startsWith('ROOM');
    const bIsRoom = b.code.startsWith('ROOM');
    if (aIsRoom && !bIsRoom) return -1;
    if (!aIsRoom && bIsRoom) return 1;
    return a.name.localeCompare(b.name);
  });
});

interface FacilityBooking {
  durationText: string;
  endMinute: number;
  organizer: string;
  schedule: Schedule;
  startMinute: number;
  timeRangeText: string;
  title: string;
}

const equipmentBookings = computed(() => {
  const map = new Map<string, FacilityBooking[]>();

  for (const eq of mockEquipments) {
    map.set(eq.id, []);
  }

  for (const schedule of props.schedules) {
    const startDate = schedule.start.slice(0, 10);
    const endDate = schedule.end.slice(0, 10);

    if (startDate <= selectedDate.value && endDate >= selectedDate.value) {
      const eqIds = schedule.event.equipment_ids ?? [];
      const startMin = getMinuteOfDay(schedule.start);
      const endMin = getMinuteOfDay(schedule.end);

      const durationHours = ((endMin - startMin) / 60)
        .toFixed(1)
        .replace('.0', '');
      const sh = Math.floor(startMin / 60);
      const sm = startMin % 60;
      const eh = Math.floor(endMin / 60);
      const em = endMin % 60;
      const timeRangeText = `${String(sh).padStart(2, '0')}:${String(sm).padStart(2, '0')} - ${String(eh).padStart(2, '0')}:${String(em).padStart(2, '0')}`;

      for (const eqId of eqIds) {
        const list = map.get(eqId);
        if (list) {
          list.push({
            durationText: `${durationHours}h`,
            endMinute: endMin,
            organizer: schedule.event.participants[0]?.name ?? 'Đồng nghiệp',
            schedule,
            startMinute: startMin,
            timeRangeText,
            title: schedule.event.title,
          });
        }
      }
    }
  }

  return map;
});

function getMinuteOfDay(iso: string): number {
  const d = new Date(iso);
  const formatter = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit',
    hour12: false,
    minute: '2-digit',
    timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
  });
  const [h, m] = formatter.format(d).split(':').map(Number) as [number, number];
  return h * 60 + m;
}

function getBookingLeft(startMin: number): string {
  const windowStartMin = startHour.value * 60;
  const windowTotalMin = totalHours.value * 60;
  const rel = (startMin - windowStartMin) / windowTotalMin;
  return `${Math.max(0, Math.min(100, rel * 100))}%`;
}

function getBookingWidth(startMin: number, endMin: number): string {
  const windowStartMin = startHour.value * 60;
  const windowEndMin = endHour.value * 60;
  const windowTotalMin = totalHours.value * 60;

  const visibleStart = Math.max(startMin, windowStartMin);
  const visibleEnd = Math.min(endMin, windowEndMin);

  if (visibleEnd <= visibleStart) return '0%';

  const dur = (visibleEnd - visibleStart) / windowTotalMin;
  return `${Math.max(1, dur * 100)}%`;
}

function isBookingVisibleInWindow(startMin: number, endMin: number): boolean {
  const windowStartMin = startHour.value * 60;
  const windowEndMin = endHour.value * 60;
  return Math.max(startMin, windowStartMin) < Math.min(endMin, windowEndMin);
}

// Current selection time range positioning (Draft range)
const currentRangePosition = computed(() => {
  if (!props.currentTimeRange?.start || !props.currentTimeRange?.end) {
    return null;
  }
  const [sh, sm] = props.currentTimeRange.start
    .split(':')
    .map(Number) as [number, number];
  const [eh, em] = props.currentTimeRange.end
    .split(':')
    .map(Number) as [number, number];
  const startMin = sh * 60 + sm;
  const endMin = eh * 60 + em;

  const windowStartMin = startHour.value * 60;
  const windowEndMin = endHour.value * 60;
  const windowTotalMin = totalHours.value * 60;

  if (Math.max(startMin, windowStartMin) >= Math.min(endMin, windowEndMin)) {
    return null;
  }

  const left = Math.max(
    0,
    ((startMin - windowStartMin) / windowTotalMin) * 100,
  );
  const width = Math.max(1, ((endMin - startMin) / windowTotalMin) * 100);

  return {
    endMin,
    left: `${left}%`,
    startMin,
    width: `${width}%`,
  };
});

function hasConflict(
  equipmentId: string,
  customRange?: { endMin: number; startMin: number },
): boolean {
  const range =
    customRange ??
    (boundaryMinutes.value
      ? {
          endMin: boundaryMinutes.value.end,
          startMin: boundaryMinutes.value.start,
        }
      : null);
  if (!range) return false;
  const bookings = equipmentBookings.value.get(equipmentId) ?? [];

  return bookings.some(
    (b) =>
      Math.max(b.startMinute, range.startMin) <
      Math.min(b.endMinute, range.endMin),
  );
}

function isSlotBooked(
  equipmentId: string,
  startMin: number,
  endMin: number,
): boolean {
  const bookings = equipmentBookings.value.get(equipmentId) ?? [];
  return bookings.some(
    (b) => Math.max(b.startMinute, startMin) < Math.min(b.endMinute, endMin),
  );
}

function formatHour(h: number): string {
  return `${String(h).padStart(2, '0')}:00`;
}

// Drag to select range functionality using 30-min slots
interface DragSelection {
  currentSlotIndex: number;
  equipmentId: string;
  startSlotIndex: number;
}

const activeDrag = ref<DragSelection | null>(null);

const activeDragNormalized = computed(() => {
  if (!activeDrag.value) return null;
  const { currentSlotIndex, equipmentId, startSlotIndex } = activeDrag.value;
  const minIdx = Math.min(startSlotIndex, currentSlotIndex);
  const maxIdx = Math.max(startSlotIndex, currentSlotIndex);

  const startSlot = slots.value[minIdx];
  const endSlot = slots.value[maxIdx];
  if (!startSlot || !endSlot) return null;

  let rawStart = startSlot.startMinute;
  let rawEnd = endSlot.endMinute;

  // Strict boundary clamping down to the exact minute
  if (boundaryMinutes.value) {
    rawStart = Math.max(rawStart, boundaryMinutes.value.start);
    rawEnd = Math.min(rawEnd, boundaryMinutes.value.end);
  }

  const conflicted = hasConflict(equipmentId, {
    endMin: rawEnd,
    startMin: rawStart,
  });

  const durationMin = Math.max(0, rawEnd - rawStart);
  const durationHours = Number((durationMin / 60).toFixed(1));

  return {
    conflicted,
    durationHours,
    endMinute: rawEnd,
    endTimeText: formatMinuteToTime(rawEnd),
    equipmentId,
    startMinute: rawStart,
    startTimeText: formatMinuteToTime(rawStart),
  };
});

function handleSlotMouseDown(
  eqId: string,
  slot: TimelineSlot,
  event: MouseEvent,
): void {
  if (event.button !== 0) return;

  if (isSlotOutsideBoundary(slot.startMinute, slot.endMinute)) {
    if (boundaryMinutes.value) {
      message.warning(
        `Chỉ được chọn trong khung giờ dự kiến (${boundaryMinutes.value.startText} - ${boundaryMinutes.value.endText})`,
      );
    }
    return;
  }

  if (isSlotBooked(eqId, slot.startMinute, slot.endMinute)) {
    message.warning('Khung giờ này đã có lịch đặt, vui lòng chọn ô khác');
    return;
  }

  activeDrag.value = {
    currentSlotIndex: slot.index,
    equipmentId: eqId,
    startSlotIndex: slot.index,
  };
}

function handleSlotMouseEnter(eqId: string, slot: TimelineSlot): void {
  if (!activeDrag.value || activeDrag.value.equipmentId !== eqId) return;

  // If outside boundary, clamp to the nearest valid slot index
  if (boundaryMinutes.value) {
    if (slot.endMinute <= boundaryMinutes.value.start) {
      // Find first slot inside boundary
      const firstValid = slots.value.find(
        (s) => s.endMinute > boundaryMinutes.value!.start,
      );
      if (firstValid) activeDrag.value.currentSlotIndex = firstValid.index;
      return;
    }
    if (slot.startMinute >= boundaryMinutes.value.end) {
      // Find last slot inside boundary
      const validSlots = slots.value.filter(
        (s) => s.startMinute < boundaryMinutes.value!.end,
      );
      const lastValid = validSlots[validSlots.length - 1];
      if (lastValid) activeDrag.value.currentSlotIndex = lastValid.index;
      return;
    }
  }

  activeDrag.value.currentSlotIndex = slot.index;
}

function handleGlobalMouseUp(): void {
  if (!activeDrag.value || !activeDragNormalized.value) {
    activeDrag.value = null;
    return;
  }

  const drag = activeDragNormalized.value;
  activeDrag.value = null;

  if (drag.conflicted) {
    message.error(
      'Khung giờ bạn kéo bị trùng với lịch đặt khác, vui lòng chọn lại!',
    );
    return;
  }

  const eq = mockEquipments.find((e) => e.id === drag.equipmentId);
  selectedItems.value[drag.equipmentId] = {
    durationHours: drag.durationHours,
    end: drag.endTimeText,
    endMinute: drag.endMinute,
    equipmentCode: eq?.code ?? '',
    equipmentId: drag.equipmentId,
    equipmentName: eq?.name ?? 'Thiết bị',
    start: drag.startTimeText,
    startMinute: drag.startMinute,
  };

  message.success(
    `Đã chọn ${eq?.name}: ${drag.startTimeText} - ${drag.endTimeText}`,
  );
}

onMounted(() => {
  window.addEventListener('mouseup', handleGlobalMouseUp);
});

onUnmounted(() => {
  window.removeEventListener('mouseup', handleGlobalMouseUp);
});

function handleQuickSelectEntireRange(equipmentId: string): void {
  if (!props.currentTimeRange?.start || !props.currentTimeRange?.end || !boundaryMinutes.value) {
    return;
  }
  if (hasConflict(equipmentId)) {
    message.error('Thiết bị này có lịch trùng trong khung giờ dự kiến!');
    return;
  }

  const eq = mockEquipments.find((e) => e.id === equipmentId);
  const startMin = boundaryMinutes.value.start;
  const endMin = boundaryMinutes.value.end;
  const durationHours = Number(Math.max(0.5, (endMin - startMin) / 60).toFixed(1));

  selectedItems.value[equipmentId] = {
    durationHours,
    end: boundaryMinutes.value.endText,
    endMinute: endMin,
    equipmentCode: eq?.code ?? '',
    equipmentId,
    equipmentName: eq?.name ?? 'Thiết bị',
    start: boundaryMinutes.value.startText,
    startMinute: startMin,
  };

  message.success(
    `Đã chọn ${eq?.name}: ${boundaryMinutes.value.startText} - ${boundaryMinutes.value.endText}`,
  );
}

function handleRemoveSelectedItem(equipmentId: string): void {
  delete selectedItems.value[equipmentId];
}

function handleConfirmSelection(): void {
  const items = Object.values(selectedItems.value);
  if (items.length === 0) {
    message.warning('Vui lòng chọn ít nhất một thiết bị hoặc khung giờ');
    return;
  }

  const equipmentIds = Object.keys(selectedItems.value);
  emit('selectEquipments', equipmentIds, items, selectedDate.value);

  const first = items[0];
  if (first) {
    emit(
      'selectTimeAndEquipment',
      first.equipmentId,
      first.start,
      first.end,
      selectedDate.value,
    );
  }
  emit('close');
}

function handleCancel(): void {
  activeDrag.value = null;
  emit('close');
}
</script>

<template>
  <Modal
    :open="open"
    width="1080px"
    @cancel="handleCancel"
    class="facility-schedule-modal"
  >
    <template #title>
      <div class="flex items-center gap-2">
        <CalendarIcon class="size-5 text-primary" />
        <span class="font-bold text-base">Lịch sử dụng cơ sở vật chất & phòng họp</span>
      </div>
    </template>

    <div class="space-y-4 pt-2 select-none">
      <!-- Toolbar: Date & Time Window Selector -->
      <div class="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-border bg-muted/20 p-3">
        <!-- Date Selector -->
        <div class="flex items-center gap-2">
          <button
            type="button"
            class="inline-flex items-center justify-center rounded-md border border-input bg-background px-3 py-1.5 text-xs font-semibold text-foreground transition hover:bg-accent hover:text-accent-foreground shrink-0 shadow-xs cursor-pointer"
            @click="selectToday"
          >
            Hôm nay
          </button>
          <button
            type="button"
            class="inline-flex size-7 items-center justify-center rounded-md border border-input bg-background text-foreground transition hover:bg-accent shrink-0 shadow-xs cursor-pointer"
            @click="shiftDate(-1)"
          >
            <ChevronLeft class="size-4" />
          </button>
          <DatePicker
            :value="selectedDate"
            value-format="YYYY-MM-DD"
            format="DD/MM/YYYY"
            class="min-w-36 font-semibold"
            @update:value="handleDateChange"
          />
          <button
            type="button"
            class="inline-flex size-7 items-center justify-center rounded-md border border-input bg-background text-foreground transition hover:bg-accent shrink-0 shadow-xs cursor-pointer"
            @click="shiftDate(1)"
          >
            <ChevronRight class="size-4" />
          </button>
        </div>

        <!-- Time Window Filter -->
        <div class="flex items-center gap-2">
          <span class="text-xs text-muted-foreground hidden sm:inline">Khung giờ:</span>
          <Radio.Group
            v-model:value="timeWindow"
            size="small"
            option-type="button"
            button-style="solid"
          >
            <Radio.Button value="all">Giờ hành chính (07:00 - 20:00)</Radio.Button>
            <Radio.Button value="24h">24 Giờ (00:00 - 24:00)</Radio.Button>
            <Radio.Button value="morning">Sáng (07:00 - 13:00)</Radio.Button>
            <Radio.Button value="afternoon">Chiều (12:00 - 19:00)</Radio.Button>
          </Radio.Group>
        </div>

        <!-- Planned Slot Badge -->
        <div v-if="currentTimeRange" class="flex items-center gap-2 text-xs">
          <span class="text-muted-foreground">Khung giờ dự kiến của lịch:</span>
          <Tag color="blue" class="font-bold font-mono text-xs py-0.5 px-2">
            {{ currentTimeRange.start }} - {{ currentTimeRange.end }}
          </Tag>
        </div>
      </div>

      <!-- Timeline Table Container -->
      <div class="overflow-x-auto rounded-lg border border-border bg-background shadow-xs">
        <div class="min-w-[950px]">
          <!-- Timeline Header -->
          <div class="flex border-b border-border bg-muted/50 text-[11px] font-semibold text-muted-foreground">
            <div class="w-64 shrink-0 border-r border-border p-2.5">
              Cơ sở vật chất / Phòng họp
            </div>
            <div class="relative flex flex-1">
              <div
                v-for="hour in hours"
                :key="hour"
                class="flex-1 border-r border-border/50 py-2 text-center font-mono text-[11px]"
              >
                {{ formatHour(hour) }}
              </div>
            </div>
          </div>

          <!-- Facility Rows -->
          <div class="divide-y divide-border/60">
            <div
              v-for="eq in sortedEquipments"
              :key="eq.id"
              class="flex items-stretch transition-colors hover:bg-muted/15"
              :class="selectedItems[eq.id] ? 'bg-primary/[0.06]' : ''"
            >
              <!-- Equipment Label -->
              <div class="w-64 shrink-0 border-r border-border p-2.5 flex flex-col justify-center gap-1.5">
                <div class="flex items-center justify-between gap-1.5">
                  <div class="min-w-0">
                    <div class="text-xs font-semibold text-foreground truncate" :title="eq.name">
                      {{ eq.name }}
                    </div>
                    <div class="text-[10px] text-muted-foreground font-mono">
                      {{ eq.code }}
                    </div>
                  </div>

                  <!-- Status / Selection Tag -->
                  <div class="shrink-0 flex items-center gap-1">
                    <Tag v-if="selectedItems[eq.id]" color="blue" class="text-[10px] m-0 font-semibold font-mono">
                      {{ selectedItems[eq.id]?.start }} - {{ selectedItems[eq.id]?.end }}
                    </Tag>
                    <Tag v-else-if="boundaryMinutes && hasConflict(eq.id)" color="error" class="text-[10px] m-0 font-semibold">
                      <span class="flex items-center gap-1">
                        <AlertTriangleIcon class="size-3" />
                        Trùng
                      </span>
                    </Tag>
                    <Tag v-else-if="boundaryMinutes" color="success" class="text-[10px] m-0 font-semibold">
                      <span class="flex items-center gap-1">
                        <CheckCircleIcon class="size-3" />
                        Rảnh
                      </span>
                    </Tag>
                  </div>
                </div>

                <!-- Action Button -->
                <div class="flex items-center gap-1 w-full">
                  <button
                    v-if="selectedItems[eq.id]"
                    type="button"
                    class="inline-flex items-center justify-center gap-1 rounded border border-rose-300 bg-rose-50 hover:bg-rose-100 text-rose-700 dark:bg-rose-950/40 dark:border-rose-800 dark:text-rose-300 px-2 py-0.5 text-[10px] font-semibold transition cursor-pointer w-full"
                    @click.stop="handleRemoveSelectedItem(eq.id)"
                  >
                    <XIcon class="size-3" />
                    <span>Bỏ chọn</span>
                  </button>
                  <button
                    v-else-if="boundaryMinutes && !hasConflict(eq.id)"
                    type="button"
                    class="inline-flex items-center justify-center gap-1 rounded bg-primary/10 hover:bg-primary hover:text-primary-foreground text-primary px-2 py-0.5 text-[10px] font-semibold transition cursor-pointer w-full"
                    :title="`Chọn trọn vẹn khung giờ ${boundaryMinutes.startText} - ${boundaryMinutes.endText}`"
                    @click.stop="handleQuickSelectEntireRange(eq.id)"
                  >
                    <CheckCircleIcon class="size-3" />
                    <span>Dùng trọn vẹn ({{ boundaryMinutes.startText }} - {{ boundaryMinutes.endText }})</span>
                  </button>
                </div>
              </div>

              <!-- Timeline Slot Area (30-min precision) -->
              <div class="relative flex flex-1 items-center h-12">
                <!-- 30-min Sub-slots -->
                <div
                  v-for="slot in slots"
                  :key="slot.index"
                  class="h-full flex-1 transition-colors relative"
                  :class="[
                    slot.isFirstHalf ? 'border-r border-border/20 border-dashed' : 'border-r border-border/50',
                    isSlotOutsideBoundary(slot.startMinute, slot.endMinute)
                      ? 'bg-muted/40 cursor-not-allowed opacity-45'
                      : isSlotBooked(eq.id, slot.startMinute, slot.endMinute)
                        ? 'cursor-not-allowed bg-rose-50/40 dark:bg-rose-950/20'
                        : 'hover:bg-primary/10 cursor-crosshair',
                  ]"
                  :title="
                    isSlotOutsideBoundary(slot.startMinute, slot.endMinute)
                      ? `Nằm ngoài khung giờ dự kiến (${boundaryMinutes?.startText} - ${boundaryMinutes?.endText})`
                      : isSlotBooked(eq.id, slot.startMinute, slot.endMinute)
                        ? `Đã có lịch đặt: ${slot.label}`
                        : `Kéo hoặc nhấp để chọn: ${slot.label}`
                  "
                  @mousedown="handleSlotMouseDown(eq.id, slot, $event)"
                  @mouseenter="handleSlotMouseEnter(eq.id, slot)"
                />

                <!-- Highlight Band for Currently Selected Time Range from Draft -->
                <div
                  v-if="currentRangePosition && selectedDate === date"
                  class="pointer-events-none absolute top-0 bottom-0 z-10 border-x-2 shadow-xs opacity-40"
                  :class="hasConflict(eq.id) ? 'bg-red-500/10 border-red-500' : 'bg-primary/10 border-primary'"
                  :style="{
                    left: currentRangePosition.left,
                    width: currentRangePosition.width,
                  }"
                />

                <!-- Selected Range Band for this Equipment -->
                <div
                  v-if="selectedItems[eq.id] && (!activeDrag || activeDrag.equipmentId !== eq.id)"
                  class="absolute top-1 bottom-1 z-25 flex items-center justify-between rounded border-2 border-primary bg-primary/25 px-2 shadow-xs transition-all font-mono text-xs font-bold"
                  :style="{
                    left: getBookingLeft(selectedItems[eq.id]?.startMinute ?? 0),
                    width: getBookingWidth(
                      selectedItems[eq.id]?.startMinute ?? 0,
                      selectedItems[eq.id]?.endMinute ?? 0,
                    ),
                  }"
                >
                  <span class="truncate text-[10px] text-foreground font-sans font-semibold flex items-center gap-1">
                    <CheckCircleIcon class="size-3 text-primary shrink-0" />
                    <span>{{ selectedItems[eq.id]?.start }} - {{ selectedItems[eq.id]?.end }}</span>
                  </span>
                  <button
                    type="button"
                    class="ml-1 flex size-4 items-center justify-center rounded-full hover:bg-black/10 dark:hover:bg-white/20 text-muted-foreground hover:text-foreground cursor-pointer shrink-0"
                    title="Bỏ chọn thiết bị này"
                    @click.stop="handleRemoveSelectedItem(eq.id)"
                  >
                    <XIcon class="size-3" />
                  </button>
                </div>

                <!-- Active Dragging Range Selection Band -->
                <div
                  v-if="activeDragNormalized && activeDragNormalized.equipmentId === eq.id"
                  class="pointer-events-none absolute top-0.5 bottom-0.5 z-30 flex items-center justify-center rounded border-2 shadow-md transition-all font-mono text-xs font-bold"
                  :class="
                    activeDragNormalized.conflicted
                      ? 'bg-red-500/30 border-red-500 text-red-700 dark:text-red-300'
                      : 'bg-primary/30 border-primary text-primary-foreground drop-shadow'
                  "
                  :style="{
                    left: getBookingLeft(activeDragNormalized.startMinute),
                    width: getBookingWidth(activeDragNormalized.startMinute, activeDragNormalized.endMinute),
                  }"
                >
                  <span class="rounded bg-background/95 px-1.5 py-0.5 text-[10px] shadow-sm text-foreground">
                    {{ activeDragNormalized.startTimeText }} - {{ activeDragNormalized.endTimeText }} ({{ activeDragNormalized.durationHours }}h)
                    <span v-if="activeDragNormalized.conflicted" class="text-red-500 ml-1 font-bold">Trùng!</span>
                  </span>
                </div>

                <!-- Booked Multi-hour Event Blocks -->
                <template v-for="(booking, bIdx) in (equipmentBookings.get(eq.id) ?? [])" :key="bIdx">
                  <Tooltip
                    v-if="isBookingVisibleInWindow(booking.startMinute, booking.endMinute)"
                    placement="top"
                  >
                    <template #title>
                      <div class="p-1 space-y-1 text-xs">
                        <div class="font-bold text-sm">{{ booking.title }}</div>
                        <div class="text-primary font-mono font-semibold">{{ booking.timeRangeText }} ({{ booking.durationText }})</div>
                        <div class="opacity-80">Người đặt: {{ booking.organizer }}</div>
                      </div>
                    </template>

                    <div
                      class="absolute z-20 flex h-8 items-center overflow-hidden rounded-md border border-rose-300/80 bg-rose-50/95 px-2 text-xs font-semibold text-rose-900 shadow-sm transition hover:shadow-md hover:brightness-95 dark:border-rose-700 dark:bg-rose-950/90 dark:text-rose-200 cursor-default"
                      :style="{
                        left: getBookingLeft(booking.startMinute),
                        width: getBookingWidth(booking.startMinute, booking.endMinute),
                      }"
                    >
                      <div class="flex items-center gap-1.5 min-w-0">
                        <span class="rounded bg-rose-200/80 px-1 py-0.2 text-[10px] font-mono text-rose-800 dark:bg-rose-900 dark:text-rose-200 shrink-0">
                          {{ booking.timeRangeText }}
                        </span>
                        <span class="truncate">{{ booking.title }}</span>
                      </div>
                    </div>
                  </Tooltip>
                </template>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Legend & Tip -->
      <div class="flex flex-wrap items-center justify-between gap-3 text-xs text-muted-foreground pt-1">
        <div class="flex items-center gap-4">
          <div class="flex items-center gap-1.5">
            <span class="size-3 rounded bg-rose-100 border border-rose-300" />
            <span class="font-medium">Đã có lịch đặt</span>
          </div>
          <div class="flex items-center gap-1.5">
            <span class="size-3 rounded bg-primary/20 border border-primary/50" />
            <span class="font-medium">Khung giờ dự kiến</span>
          </div>
          <div class="flex items-center gap-1.5">
            <span class="size-3 rounded border border-border bg-background" />
            <span class="font-medium">Còn trống</span>
          </div>
          <div class="flex items-center gap-1.5">
            <span class="size-3 rounded bg-muted/60 border border-border" />
            <span class="font-medium">Ngoài vùng dự kiến</span>
          </div>
        </div>
        <div class="text-[11px] text-primary italic font-medium">
          💡 Rê chuột kéo thả để chọn nhiều tài sản. Giới hạn tự động bám sát từng phút của lịch trình.
        </div>
      </div>
    </div>

    <!-- Modal Footer Actions: Multi-equipment Summary & Confirm -->
    <template #footer>
      <div class="flex flex-wrap items-center justify-between gap-3 px-1 py-1">
        <div class="flex flex-1 items-center gap-2 text-xs min-w-0">
          <template v-if="Object.keys(selectedItems).length > 0">
            <span class="text-muted-foreground font-medium shrink-0">
              Đã chọn ({{ Object.keys(selectedItems).length }}):
            </span>
            <div class="flex flex-wrap items-center gap-1.5 max-h-16 overflow-y-auto min-w-0">
              <Tag
                v-for="item in Object.values(selectedItems)"
                :key="item.equipmentId"
                closable
                color="blue"
                class="flex items-center gap-1 font-semibold text-xs py-0.5 px-2 m-0 shrink-0"
                @close="handleRemoveSelectedItem(item.equipmentId)"
              >
                <span class="font-bold">{{ item.equipmentName }}:</span>
                <span class="font-mono">{{ item.start }} - {{ item.end }}</span>
              </Tag>
            </div>
          </template>
          <span v-else class="text-muted-foreground italic text-xs">
            Chưa chọn tài sản nào. Kéo thả trên bảng hoặc bấm &quot;Dùng trọn vẹn&quot; để chọn nhiều tài sản.
          </span>
        </div>

        <div class="flex items-center gap-2 shrink-0">
          <VbenButton
            variant="outline"
            size="sm"
            @click="handleCancel"
          >
            Hủy
          </VbenButton>
          <VbenButton
            variant="default"
            size="sm"
            :disabled="Object.keys(selectedItems).length === 0"
            @click="handleConfirmSelection"
          >
            <CheckCircleIcon class="size-3.5 mr-1" />
            Xác nhận áp dụng
            <span v-if="Object.keys(selectedItems).length > 0" class="ml-1">
              ({{ Object.keys(selectedItems).length }})
            </span>
          </VbenButton>
        </div>
      </div>
    </template>
  </Modal>
</template>

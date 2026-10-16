<script setup lang="ts">
import type { Dayjs } from 'dayjs';

import type {
  ScheduleAuthoringDraft,
  ScheduleAuthoringOption,
  ScheduleUserTreeOption,
} from '../schedule-page';

import type { Schedule, ScheduleEventWritePayload } from '#/api/schedules';

import { computed, ref } from 'vue';

import { VbenButton } from '@vben/common-ui';
import { createIconifyIcon } from '@vben/icons';

import {
  Alert,
  DatePicker,
  Drawer,
  Input,
  Radio,
  Select,
  Switch,
  TimePicker,
  TreeSelect,
} from 'ant-design-vue';

import { mockEquipments } from '#/mocks/data';
import FacilityScheduleModal from './FacilityScheduleModal.vue';

import { $t } from '#/locales';

import {
  formatAuthoringDate,
  formatAuthoringTime,
  getAuthoringPayloadValue,
  getAuthoringRepeatPatternValues,
} from '../schedule-page';

const props = defineProps<{
  authoringMonthPatternOptions: ScheduleAuthoringOption[];
  authoringPayload: null | ScheduleEventWritePayload;
  authoringPrivacyOptions: ScheduleAuthoringOption[];
  authoringReminderRangeOptions: ScheduleAuthoringOption[];
  authoringRepeatTypeOptions: ScheduleAuthoringOption[];
  authoringSaving: boolean;
  authoringScheduleTypeOptions: ScheduleAuthoringOption[];
  authoringTypeOptions: ScheduleAuthoringOption[];
  authoringUsersLoading: boolean;
  authoringUserTreeOptions: ScheduleUserTreeOption[];
  authoringWeekdayPatternOptions: ScheduleAuthoringOption[];
  canSubmitAuthoringDraft: boolean;
  draft: null | ScheduleAuthoringDraft;
  hasCompany: boolean;
  onClose: () => void;
  onSelectAllAuthoringRepeatPatterns: () => void;
  onSubmit: () => void;
  onToggleAuthoringRepeatPattern: (value: number) => void;
  onUpdateAuthoringDate: (
    field: 'end_date' | 'start_date',
    value: Dayjs | string,
  ) => void;
  onUpdateAuthoringField: (
    field: 'observers' | 'participants' | 'privacy' | 'title' | 'type',
    value:
      | Schedule['event']['privacy']
      | Schedule['event']['type']
      | string
      | string[],
  ) => void;
  onUpdateAuthoringGeneral: (value: boolean | number | string) => void;
  onUpdateAuthoringLocationType?: (
    value: 'hybrid' | 'online' | 'physical',
  ) => void;
  onUpdateAuthoringMeetingUrl?: (value: string) => void;
  onUpdateAuthoringEquipmentIds?: (value: string[]) => void;
  onUpdateAuthoringNullableField: (
    field: 'meeting_url' | 'note' | 'physical_address',
    value: string,
  ) => void;
  onUpdateAuthoringReminderEnabled: (value: boolean | number | string) => void;
  onUpdateAuthoringReminderRange: (value: unknown) => void;
  onUpdateAuthoringReminderValue: (value: string) => void;
  onUpdateAuthoringRepeatType: (value: unknown) => void;
  onUpdateAuthoringScheduleType: (value: unknown) => void;
  onUpdateAuthoringTime: (
    field: 'end_time' | 'start_time',
    value: Dayjs | null | string,
  ) => void;
  open: boolean;
  schedules?: Schedule[];
  title: string;
}>();

function isAuthoringRepeatPatternSelected(
  draft: ScheduleAuthoringDraft,
  value: number,
): boolean {
  return getAuthoringRepeatPatternValues(draft).includes(value);
}

function getPatternOptions(
  draft: ScheduleAuthoringDraft,
  weekdayOptions: ScheduleAuthoringOption[],
  monthOptions: ScheduleAuthoringOption[],
): ScheduleAuthoringOption[] {
  return draft.repeat_type === 'weekly' ? weekdayOptions : monthOptions;
}

function getRepeatPatternGridClass(draft: ScheduleAuthoringDraft): string {
  return draft.repeat_type === 'monthly'
    ? 'grid grid-cols-8 gap-2'
    : 'grid grid-cols-4 gap-2';
}

function getRepeatPatternButtonClass(
  draft: ScheduleAuthoringDraft,
  value: number,
): string {
  return isAuthoringRepeatPatternSelected(draft, value)
    ? 'border-primary bg-primary text-primary-foreground hover:border-primary hover:bg-primary hover:text-primary-foreground'
    : 'border-primary/30 bg-background text-primary hover:border-primary hover:bg-primary/10 hover:text-primary';
}

const titleValue = computed({
  get: () => props.draft?.title ?? '',
  set: (value: string) => {
    props.onUpdateAuthoringField('title', value);
  },
});

const typeValue = computed({
  get: () => props.draft?.type ?? 'meeting',
  set: (value: string) => {
    props.onUpdateAuthoringField('type', value);
  },
});

const participantsValue = computed({
  get: () => props.draft?.participants ?? [],
  set: (value: string[]) => {
    props.onUpdateAuthoringField('participants', value);
  },
});

const observersValue = computed({
  get: () => props.draft?.observers ?? [],
  set: (value: string[]) => {
    props.onUpdateAuthoringField('observers', value);
  },
});

const privacyValue = computed({
  get: () => props.draft?.privacy ?? 'public',
  set: (value: string) => {
    props.onUpdateAuthoringField('privacy', value);
  },
});

const VideoIcon = createIconifyIcon('lucide:video');
const MapPinIcon = createIconifyIcon('lucide:map-pin');
const LayersIcon = createIconifyIcon('lucide:layers');
const CalendarDaysIcon = createIconifyIcon('lucide:calendar-days');
const AlertTriangleIcon = createIconifyIcon('lucide:alert-triangle');

const facilityModalOpen = ref(false);

const equipmentOptions = computed(() =>
  mockEquipments.map((eq) => ({
    label: `${eq.name} (${eq.code})`,
    value: eq.id,
  })),
);

const locationTypeValue = computed({
  get: () => props.draft?.location_type ?? 'physical',
  set: (val: 'hybrid' | 'online' | 'physical') => {
    if (props.onUpdateAuthoringLocationType) {
      props.onUpdateAuthoringLocationType(val);
    } else if (props.draft) {
      props.draft.location_type = val;
    }
  },
});

const equipmentIdsValue = computed({
  get: () => props.draft?.equipment_ids ?? [],
  set: (val: string[]) => {
    if (props.onUpdateAuthoringEquipmentIds) {
      props.onUpdateAuthoringEquipmentIds(val);
    } else if (props.draft) {
      props.draft.equipment_ids = val;
    }
  },
});

const currentTimeRange = computed(() => {
  if (!props.draft?.start_time || !props.draft?.end_time) return null;
  return {
    end: props.draft.end_time,
    start: props.draft.start_time,
  };
});

// Check if any selected equipment is conflicted with another schedule
const conflictedEquipments = computed(() => {
  if (
    !props.draft ||
    !props.schedules ||
    !props.draft.equipment_ids?.length ||
    !props.draft.start_time ||
    !props.draft.end_time
  ) {
    return [];
  }

  const date = props.draft.start_date;
  const [sh, sm] = props.draft.start_time.split(':').map(Number) as [number, number];
  const [eh, em] = props.draft.end_time.split(':').map(Number) as [number, number];
  const curStart = sh * 60 + sm;
  const curEnd = eh * 60 + em;

  const conflicts: Array<{ equipmentName: string; eventTitle: string }> = [];

  for (const eqId of props.draft.equipment_ids) {
    const eq = mockEquipments.find((e) => e.id === eqId);
    if (!eq) continue;

    for (const s of props.schedules) {
      // Exclude self if editing
      if (props.draft.mode === 'edit' && s.event.id === props.draft.source_event_id) {
        continue;
      }
      const sStart = s.start.slice(0, 10);
      const sEnd = s.end.slice(0, 10);
      if (sStart <= date && sEnd >= date && s.event.equipment_ids?.includes(eqId)) {
        const sDate = new Date(s.start);
        const eDate = new Date(s.end);
        const sMin = sDate.getHours() * 60 + sDate.getMinutes();
        const eMin = eDate.getHours() * 60 + eDate.getMinutes();

        if (Math.max(curStart, sMin) < Math.min(curEnd, eMin)) {
          conflicts.push({
            equipmentName: eq.name,
            eventTitle: s.event.title,
          });
        }
      }
    }
  }

  return conflicts;
});

function handleSelectFacilitySlot(
  eqId: string,
  start: string,
  end: string,
  date?: string,
): void {
  props.onUpdateAuthoringTime('start_time', start);
  props.onUpdateAuthoringTime('end_time', end);
  if (date && props.draft && props.draft.start_date !== date) {
    props.onUpdateAuthoringDate('start_date', date);
    props.onUpdateAuthoringDate('end_date', date);
  }
  if (props.draft && !props.draft.equipment_ids.includes(eqId)) {
    equipmentIdsValue.value = [...props.draft.equipment_ids, eqId];
  }
  facilityModalOpen.value = false;
}

function setQuickMeetingUrl(type: 'google' | 'teams' | 'zoom'): void {
  const code = Math.random().toString(36).slice(2, 6);
  let url = '';
  switch (type) {
    case 'google': {
      url = `https://meet.google.com/obee-${code}`;
      break;
    }
    case 'zoom': {
      url = `https://zoom.us/j/8899${code}`;
      break;
    }
    case 'teams': {
      url = `https://teams.microsoft.com/l/meetup-join/obee-${code}`;
      break;
    }
  }
  if (props.onUpdateAuthoringMeetingUrl) {
    props.onUpdateAuthoringMeetingUrl(url);
  } else {
    props.onUpdateAuthoringNullableField('meeting_url', url);
  }
}

function setQuickLocation(name: string): void {
  props.onUpdateAuthoringNullableField('physical_address', name);
}

const isCreateBlocked = computed(
  () =>
    props.draft !== null && props.draft.mode !== 'edit' && !props.hasCompany,
);
</script>

<template>
  <Drawer
    :open="open"
    :title="title"
    placement="right"
    :width="560"
    @close="onClose"
  >
    <template #default>
      <div
        v-if="draft && authoringPayload"
        :data-payload-company-name="
          authoringPayload.company_name === null
            ? 'null'
            : authoringPayload.company_name
        "
        :data-payload-company-phone-number="
          authoringPayload.company_phone_number === null
            ? 'null'
            : authoringPayload.company_phone_number
        "
        :data-payload-repeat-end-time="
          getAuthoringPayloadValue(authoringPayload.repeat_end_time)
        "
        :data-payload-repeat-pattern="
          getAuthoringPayloadValue(authoringPayload.repeat_pattern)
        "
        :data-payload-repeat-start-time="
          getAuthoringPayloadValue(authoringPayload.repeat_start_time)
        "
        :data-payload-repeat-type="
          getAuthoringPayloadValue(authoringPayload.repeat_type)
        "
        :data-payload-schedule-type="authoringPayload.schedule_type"
        data-testid="schedule-authoring-drawer"
        class="flex h-full min-h-0 flex-col text-sm"
      >
        <div
          v-if="!hasCompany"
          class="flex min-h-0 flex-1 items-start overflow-y-auto pr-1"
        >
          <Alert
            :message="$t('page.schedules.form.companyRequiredTitle')"
            :description="$t('page.schedules.form.companyRequiredDescription')"
            show-icon
            type="warning"
            data-testid="schedule-form-company-required"
            class="w-full"
          />
        </div>

        <div
          v-else
          class="min-h-0 flex-1 overflow-y-auto"
          style="padding: 24px; margin: -24px"
        >
          <p
            v-if="authoringUsersLoading"
            class="text-muted-foreground"
            role="status"
          >
            {{ $t('page.schedules.form.userOptionsLoading') }}
          </p>

          <div v-else class="grid gap-4">
            <label class="grid gap-1">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.title') }}
              </span>
              <Input
                v-model:value="titleValue"
                data-testid="schedule-form-title"
              />
            </label>

            <label class="grid gap-1">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.eventType') }}
              </span>
              <Select
                v-model:value="typeValue"
                :options="authoringTypeOptions"
                data-testid="schedule-form-type"
              />
            </label>

            <label class="grid gap-1">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.scheduleType') }}
              </span>
              <Select
                :value="draft.schedule_type"
                :options="authoringScheduleTypeOptions"
                data-testid="schedule-form-schedule-type"
                @update:value="onUpdateAuthoringScheduleType"
              />
            </label>

            <div
              v-if="draft.schedule_type === 'repeat'"
              data-testid="schedule-form-repeat-section"
              class="grid gap-4 rounded-lg border border-border/80 bg-muted/30 p-4"
            >
              <label class="grid gap-1">
                <span class="text-xs font-medium text-muted-foreground">
                  {{ $t('page.schedules.form.repeat.type') }}
                </span>
                <Select
                  :value="draft.repeat_type ?? undefined"
                  :aria-required="true"
                  :options="authoringRepeatTypeOptions"
                  data-testid="schedule-form-repeat-type"
                  @update:value="onUpdateAuthoringRepeatType"
                />
              </label>

              <div
                v-if="
                  draft.repeat_type === 'weekly' ||
                  draft.repeat_type === 'monthly'
                "
                data-testid="schedule-form-repeat-pattern-group"
                class="grid gap-2"
              >
                <div class="flex items-center justify-between gap-3">
                  <span class="text-xs font-medium text-muted-foreground">
                    {{
                      $t(
                        draft.repeat_type === 'weekly'
                          ? 'page.schedules.form.repeat.dayPattern'
                          : 'page.schedules.form.repeat.monthPattern',
                      )
                    }}
                  </span>
                  <button
                    type="button"
                    class="text-xs font-medium text-primary transition hover:text-primary/80"
                    data-testid="schedule-form-repeat-pattern-select-all"
                    @click="onSelectAllAuthoringRepeatPatterns"
                  >
                    {{ $t('page.schedules.form.repeat.selectAll') }}
                  </button>
                </div>
                <div
                  :class="getRepeatPatternGridClass(draft)"
                  data-testid="schedule-form-repeat-pattern-grid"
                >
                  <VbenButton
                    v-for="option in getPatternOptions(
                      draft,
                      authoringWeekdayPatternOptions,
                      authoringMonthPatternOptions,
                    )"
                    :key="option.value"
                    :class="
                      getRepeatPatternButtonClass(draft, Number(option.value))
                    "
                    :data-testid="`schedule-form-repeat-pattern-${option.value}`"
                    class="w-full justify-center px-0"
                    size="sm"
                    @click="
                      onToggleAuthoringRepeatPattern(Number(option.value))
                    "
                  >
                    {{ option.label }}
                  </VbenButton>
                </div>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <label class="grid gap-1">
                <span class="text-xs font-medium text-muted-foreground">
                  {{ $t('page.schedules.form.startDate') }}
                </span>
                <DatePicker
                  :value="formatAuthoringDate(draft.start_date)"
                  data-testid="schedule-form-start-date"
                  picker="date"
                  value-format="YYYY-MM-DD"
                  @update:value="onUpdateAuthoringDate('start_date', $event)"
                />
              </label>
              <label class="grid gap-1">
                <span class="text-xs font-medium text-muted-foreground">
                  {{ $t('page.schedules.form.endDate') }}
                </span>
                <DatePicker
                  :value="formatAuthoringDate(draft.end_date)"
                  data-testid="schedule-form-end-date"
                  picker="date"
                  value-format="YYYY-MM-DD"
                  @update:value="onUpdateAuthoringDate('end_date', $event)"
                />
              </label>
            </div>

            <div
              v-if="draft.schedule_type !== 'multiple_days'"
              class="grid grid-cols-2 gap-4"
            >
              <label class="grid gap-1">
                <span class="text-xs font-medium text-muted-foreground">
                  {{ $t('page.schedules.form.startTime') }}
                </span>
                <TimePicker
                  :value="formatAuthoringTime(draft.start_time)"
                  data-testid="schedule-form-start-time"
                  format="HH:mm"
                  value-format="HH:mm"
                  @update:value="onUpdateAuthoringTime('start_time', $event)"
                />
              </label>
              <label class="grid gap-1">
                <span class="text-xs font-medium text-muted-foreground">
                  {{ $t('page.schedules.form.endTime') }}
                </span>
                <TimePicker
                  :value="formatAuthoringTime(draft.end_time)"
                  data-testid="schedule-form-end-time"
                  format="HH:mm"
                  value-format="HH:mm"
                  @update:value="onUpdateAuthoringTime('end_time', $event)"
                />
              </label>
            </div>

            <label class="grid gap-1">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.participants') }}
              </span>
              <TreeSelect
                v-model:value="participantsValue"
                :tree-data="authoringUserTreeOptions"
                data-testid="schedule-form-participants"
                tree-checkable
                allow-clear
                :show-checked-strategy="TreeSelect.SHOW_CHILD"
                tree-node-filter-prop="label"
                max-tag-count="responsive"
              />
            </label>

            <label class="grid gap-1">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.observers') }}
              </span>
              <TreeSelect
                v-model:value="observersValue"
                :tree-data="authoringUserTreeOptions"
                data-testid="schedule-form-observers"
                tree-checkable
                allow-clear
                :show-checked-strategy="TreeSelect.SHOW_CHILD"
                tree-node-filter-prop="label"
                max-tag-count="responsive"
              />
            </label>

            <label class="grid gap-1">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.privacy') }}
              </span>
              <Select
                v-model:value="privacyValue"
                :options="authoringPrivacyOptions"
                data-testid="schedule-form-privacy"
              />
            </label>

            <!-- Location & Meeting Type Section -->
            <div class="space-y-3 rounded-lg border border-border bg-muted/15 p-3">
              <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-foreground">
                  Hình thức & Địa điểm cuộc họp
                </span>
                <Radio.Group
                  v-model:value="locationTypeValue"
                  size="small"
                  option-type="button"
                  button-style="solid"
                >
                  <Radio.Button value="physical">
                    <span class="flex items-center gap-1">
                      <MapPinIcon class="size-3" />
                      Trực tiếp
                    </span>
                  </Radio.Button>
                  <Radio.Button value="online">
                    <span class="flex items-center gap-1">
                      <VideoIcon class="size-3" />
                      Trực tuyến
                    </span>
                  </Radio.Button>
                  <Radio.Button value="hybrid">
                    <span class="flex items-center gap-1">
                      Kết hợp
                    </span>
                  </Radio.Button>
                </Radio.Group>
              </div>

              <!-- Physical Room / Address -->
              <div
                v-if="locationTypeValue === 'physical' || locationTypeValue === 'hybrid'"
                class="grid gap-1.5"
              >
                <div class="flex items-center justify-between">
                  <span class="text-xs font-medium text-muted-foreground flex items-center gap-1">
                    <MapPinIcon class="size-3.5 text-primary" />
                    Phòng họp / Địa điểm
                  </span>
                  <div class="flex items-center gap-1 text-[11px]">
                    <span class="text-muted-foreground">Gợi ý:</span>
                    <button
                      type="button"
                      class="text-primary hover:underline"
                      @click="setQuickLocation('Phòng họp Lotus (Tầng 3)')"
                    >
                      P. Lotus
                    </button>
                    <span>&bull;</span>
                    <button
                      type="button"
                      class="text-primary hover:underline"
                      @click="setQuickLocation('Phòng họp Orchid (Tầng 2)')"
                    >
                      P. Orchid
                    </button>
                  </div>
                </div>
                <Input
                  :value="draft.physical_address ?? ''"
                  placeholder="Ví dụ: Phòng họp Lotus (Tầng 3 - 20 người)"
                  data-testid="schedule-form-physical-address"
                  @update:value="
                    onUpdateAuthoringNullableField('physical_address', $event)
                  "
                />
              </div>

              <!-- Online Meeting URL -->
              <div
                v-if="locationTypeValue === 'online' || locationTypeValue === 'hybrid'"
                class="grid gap-1.5"
              >
                <div class="flex items-center justify-between">
                  <span class="text-xs font-medium text-muted-foreground flex items-center gap-1">
                    <VideoIcon class="size-3.5 text-primary" />
                    Đường dẫn họp trực tuyến
                  </span>
                  <div class="flex items-center gap-1.5">
                    <button
                      type="button"
                      class="rounded bg-primary/10 px-1.5 py-0.5 text-[10px] font-medium text-primary hover:bg-primary/20"
                      @click="setQuickMeetingUrl('google')"
                    >
                      + Google Meet
                    </button>
                    <button
                      type="button"
                      class="rounded bg-sky-500/10 px-1.5 py-0.5 text-[10px] font-medium text-sky-600 hover:bg-sky-500/20"
                      @click="setQuickMeetingUrl('zoom')"
                    >
                      + Zoom
                    </button>
                  </div>
                </div>
                <Input
                  :value="draft.meeting_url ?? ''"
                  placeholder="https://meet.google.com/... hoặc https://zoom.us/..."
                  data-testid="schedule-form-meeting-url"
                  @update:value="
                    onUpdateAuthoringMeetingUrl
                      ? onUpdateAuthoringMeetingUrl($event)
                      : onUpdateAuthoringNullableField('meeting_url', $event)
                  "
                />
              </div>
            </div>

            <!-- Facilities & Equipment Booking Section -->
            <div class="space-y-2 rounded-lg border border-border bg-muted/15 p-3">
              <div class="flex items-center justify-between gap-2">
                <span class="text-xs font-semibold text-foreground flex items-center gap-1.5">
                  <LayersIcon class="size-3.5 text-primary" />
                  Cơ sở vật chất & Thiết bị mượn
                </span>
                <button
                  type="button"
                  class="inline-flex items-center gap-1.5 rounded-md border border-primary/40 bg-primary/10 px-2.5 py-1 text-xs font-semibold text-primary transition hover:bg-primary/20 hover:border-primary shrink-0 whitespace-nowrap cursor-pointer"
                  @click="facilityModalOpen = true"
                >
                  <CalendarDaysIcon class="size-3.5 shrink-0 text-primary" />
                  <span>Xem lịch sử dụng</span>
                </button>
              </div>

              <Select
                v-model:value="equipmentIdsValue"
                mode="multiple"
                :options="equipmentOptions"
                placeholder="Chọn phòng họp, máy chiếu, micro, thiết bị..."
                class="w-full"
                data-testid="schedule-form-equipments"
              />

              <!-- Conflict Warning -->
              <div
                v-if="conflictedEquipments.length > 0"
                class="rounded-md border border-amber-300 bg-amber-50 p-2 text-xs text-amber-800 dark:border-amber-800 dark:bg-amber-950/60 dark:text-amber-200"
              >
                <div class="flex items-center gap-1 font-semibold">
                  <AlertTriangleIcon class="size-3.5 shrink-0 text-amber-600" />
                  Cảnh báo trùng lịch cơ sở vật chất:
                </div>
                <ul class="mt-1 list-disc pl-4 space-y-0.5 text-[11px]">
                  <li v-for="(c, cIdx) in conflictedEquipments" :key="cIdx">
                    <span class="font-bold">{{ c.equipmentName }}</span> đã có lịch đặt bởi
                    <em>"{{ c.eventTitle }}"</em> trong khung giờ này.
                  </li>
                </ul>
              </div>
            </div>

            <label class="grid gap-1">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.note') }}
              </span>
              <textarea
                :value="draft.note ?? ''"
                class="min-h-24 rounded-lg border border-input bg-background px-3 py-2 text-sm outline-none ring-offset-background transition placeholder:text-muted-foreground focus-visible:border-sky-600 hover:border-sky-600"
                data-testid="schedule-form-note"
                @input="
                  onUpdateAuthoringNullableField(
                    'note',
                    ($event.target as HTMLTextAreaElement).value,
                  )
                "
              ></textarea>
            </label>

            <label class="flex items-center justify-between gap-4">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.isGeneral') }}
              </span>
              <Switch
                :checked="draft.is_general"
                data-testid="schedule-form-is-general"
                @update:checked="onUpdateAuthoringGeneral"
              />
            </label>

            <div class="flex items-center justify-between gap-4">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.hasReminder') }}
              </span>
              <Switch
                :checked="draft.has_reminder"
                data-testid="schedule-form-has-reminder"
                @update:checked="onUpdateAuthoringReminderEnabled"
              />
            </div>

            <div
              v-if="draft.has_reminder"
              class="grid grid-cols-2 gap-4"
              data-testid="schedule-form-reminder-section"
            >
              <label class="grid gap-1">
                <span class="text-xs font-medium text-muted-foreground">
                  {{ $t('page.schedules.form.reminderValue') }}
                </span>
                <Input
                  :value="
                    draft.remind_value === null
                      ? ''
                      : String(draft.remind_value)
                  "
                  data-testid="schedule-form-remind-value"
                  type="number"
                  @update:value="onUpdateAuthoringReminderValue"
                />
              </label>
              <label class="grid gap-1">
                <span class="text-xs font-medium text-muted-foreground">
                  {{ $t('page.schedules.form.reminderRange') }}
                </span>
                <Select
                  :value="draft.remind_range ?? undefined"
                  :options="authoringReminderRangeOptions"
                  data-testid="schedule-form-remind-range"
                  @update:value="onUpdateAuthoringReminderRange"
                />
              </label>
            </div>
          </div>
        </div>
      </div>
    </template>

    <template #footer>
      <div
        v-if="draft && authoringPayload && hasCompany"
        class="flex w-full justify-end gap-2"
        data-testid="schedule-form-footer"
      >
        <VbenButton
          data-testid="schedule-form-cancel"
          variant="outline"
          @click="onClose"
        >
          {{ $t('page.schedules.form.cancel') }}
        </VbenButton>
        <VbenButton
          v-if="canSubmitAuthoringDraft && !isCreateBlocked"
          :disabled="authoringSaving"
          data-testid="schedule-form-submit"
          variant="default"
          @click="onSubmit"
        >
          {{ $t('page.schedules.form.create') }}
        </VbenButton>
      </div>
    </template>
  </Drawer>

  <!-- Facility Availability Timeline Modal -->
  <FacilityScheduleModal
    :open="facilityModalOpen"
    :date="draft?.start_date ?? ''"
    :schedules="schedules ?? []"
    :selected-equipment-ids="draft?.equipment_ids ?? []"
    :current-time-range="currentTimeRange"
    @close="facilityModalOpen = false"
    @select-time-and-equipment="handleSelectFacilitySlot"
  />
</template>

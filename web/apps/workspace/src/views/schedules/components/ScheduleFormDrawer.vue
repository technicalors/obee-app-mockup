<script setup lang="ts">
import type { Dayjs } from 'dayjs';

import type {
  ScheduleAuthoringDraft,
  ScheduleAuthoringOption,
  ScheduleUserTreeOption,
} from '../schedule-page';

import type { Schedule, ScheduleEventWritePayload } from '#/api/schedules';

import { computed } from 'vue';

import { VbenButton } from '@vben/common-ui';

import {
  Alert,
  DatePicker,
  Drawer,
  Input,
  Select,
  Switch,
  TimePicker,
  TreeSelect,
} from 'ant-design-vue';

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
  onUpdateAuthoringNullableField: (
    field: 'note' | 'physical_address',
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

            <label class="grid gap-1">
              <span class="text-xs font-medium text-muted-foreground">
                {{ $t('page.schedules.form.location') }}
              </span>
              <Input
                :value="draft.physical_address ?? ''"
                data-testid="schedule-form-physical-address"
                @update:value="
                  onUpdateAuthoringNullableField('physical_address', $event)
                "
              />
            </label>

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
</template>

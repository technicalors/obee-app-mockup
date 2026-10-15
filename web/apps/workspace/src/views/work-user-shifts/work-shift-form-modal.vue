<script setup lang="ts">
import type {
  CreateWorkShift,
  UpdateWorkShift,
  WorkShift,
} from '#/api/work-shifts';

import { computed, reactive, ref, watch } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';
import { preferences } from '@vben/preferences';

import {
  Alert,
  Button,
  Checkbox,
  Form,
  FormItem,
  Input,
  notification,
  Select,
  TimePicker,
} from 'ant-design-vue';

import { createWorkShift, updateWorkShift } from '#/api/work-shifts';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import ShiftTimeline from './shift-timeline.vue';

const props = defineProps<{
  canCreate: boolean;
  canUpdate: boolean;
  open: boolean;
  rootOrganizationId: null | string;
  shift: null | WorkShift;
}>();
const emit = defineEmits<{
  saved: [];
  'update:open': [value: boolean];
}>();
const hasOvernight = ref(false);
const submitting = ref(false);
const formData = reactive<{
  name: string;
  periods: UpdateWorkShift['periods'];
}>({
  name: '',
  periods: [],
});
const { validate, validateInfos, clearValidate } = Form.useForm(
  formData,
  computed(() => ({
    name: [
      {
        required: true,
        whitespace: true,
        message: $t('workShifts.validation.nameRequired'),
      },
    ],
  })),
  { validateOnRuleChange: true },
);
const canSubmit = computed(() =>
  props.shift === null ? props.canCreate : props.canUpdate,
);
const dayOffsetOptions = computed(() => [
  { label: $t('workShifts.labels.assignmentDay'), value: 0 },
  { label: $t('workShifts.labels.nextDay'), value: 1 },
]);
const modalTitle = computed(() =>
  $t(
    props.shift === null
      ? 'workShifts.titles.create'
      : 'workShifts.titles.edit',
  ),
);
const [Modal, modalApi] = useVbenModal({
  class: 'w-[720px] max-w-[calc(100vw-1rem)]',
  draggable: true,
  footer: true,
  fullscreenButton: true,
  showCancelButton: false,
  showConfirmButton: false,
  onOpenChange: (open) => emit('update:open', open),
});
watch(modalTitle, (title) => modalApi.setState({ title }));
watch(
  hasOvernight,
  (enabled) => {
    if (!enabled) {
      for (const period of formData.periods) {
        period.start_day_offset = 0;
        period.end_day_offset = 0;
      }
    }
  },
  { flush: 'sync' },
);
watch(
  () => props.open,
  (open) => {
    if (!open) {
      modalApi.close();
      return;
    }
    clearValidate();
    const shift = props.shift;
    formData.name = shift === null ? '' : shift.name;
    hasOvernight.value =
      shift !== null &&
      shift.periods.some(
        (period) =>
          period.start_day_offset === 1 || period.end_day_offset === 1,
      );
    formData.periods =
      shift === null
        ? [
            {
              start_time: '08:00:00',
              end_time: '17:30:00',
              start_day_offset: 0,
              end_day_offset: 0,
            },
          ]
        : shift.periods.map((period) => ({
            start_time: period.start_time,
            end_time: period.end_time,
            start_day_offset: period.start_day_offset,
            end_day_offset: period.end_day_offset,
          }));
    modalApi.setState({
      title: modalTitle.value,
    });
    modalApi.open();
  },
  { immediate: true },
);

function parseSeconds(time: string): number {
  return (
    Number(time.slice(0, 2)) * 3600 +
    Number(time.slice(3, 5)) * 60 +
    Number(time.slice(6, 8))
  );
}
function getShiftTotalHours(shift: {
  periods: UpdateWorkShift['periods'];
}): number {
  return shift.periods.reduce(
    (total, period) =>
      total +
      Math.max(
        0,
        period.end_day_offset * 86_400 +
          parseSeconds(period.end_time) -
          period.start_day_offset * 86_400 -
          parseSeconds(period.start_time),
      ) /
        3600,
    0,
  );
}
function formatHours(hours: number): string {
  return $t('workShifts.labels.hours', {
    count: new Intl.NumberFormat(preferences.app.locale, {
      maximumFractionDigits: 1,
    }).format(hours),
  });
}
const validationErrors = computed(() => {
  const errors: string[] = [];
  const first = formData.periods[0];
  if (first === undefined) return [$t('workShifts.validation.periodRequired')];
  if (first.start_day_offset !== 0)
    errors.push($t('workShifts.validation.startDay'));
  const ranges = formData.periods
    .map((period, index) => {
      const start =
        period.start_day_offset * 86_400 + parseSeconds(period.start_time);
      const end =
        period.end_day_offset * 86_400 + parseSeconds(period.end_time);
      if (end <= start)
        errors.push(
          $t('workShifts.validation.endAfterStart', { index: index + 1 }),
        );
      return { start, end };
    })
    .toSorted((left, right) => left.start - right.start);
  for (let index = 1; index < ranges.length; index++) {
    const previous = ranges[index - 1];
    const current = ranges[index];
    if (
      previous !== undefined &&
      current !== undefined &&
      current.start < previous.end
    ) {
      errors.push($t('workShifts.validation.overlap'));
      break;
    }
  }
  return errors;
});
function closeForm(): void {
  emit('update:open', false);
}
function addPeriod(): void {
  if (formData.periods.length >= 24) return;
  const last = formData.periods.at(-1);
  formData.periods.push({
    start_time: last === undefined ? '08:00:00' : last.end_time,
    end_time: '21:00:00',
    start_day_offset: last === undefined ? 0 : last.end_day_offset,
    end_day_offset: last === undefined ? 0 : last.end_day_offset,
  });
}
function removePeriod(index: number): void {
  if (formData.periods.length > 1) formData.periods.splice(index, 1);
}
async function handleSubmit(): Promise<void> {
  if (!canSubmit.value) return;
  try {
    await validate();
  } catch {
    return;
  }
  if (validationErrors.value.length > 0) return;
  submitting.value = true;
  try {
    const payload: UpdateWorkShift = {
      name: formData.name,
      periods: formData.periods,
    };
    if (props.shift === null) {
      if (props.rootOrganizationId === null)
        throw new Error($t('workShifts.validation.organizationRequired'));
      const createPayload: CreateWorkShift = {
        ...payload,
        root_organization_id: props.rootOrganizationId,
      };
      await createWorkShift(createPayload);
      notification.success({ message: $t('workShifts.messages.created') });
    } else {
      await updateWorkShift(props.shift.id, payload);
      notification.success({ message: $t('workShifts.messages.updated') });
    }
    emit('saved');
    closeForm();
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('workShifts.messages.saveFailed'),
      'Failed to save work shift:',
    );
  } finally {
    submitting.value = false;
  }
}
</script>

<template>
  <!-- eslint-disable vue/html-closing-bracket-newline -->
  <Modal
    :close-on-click-modal="false"
    :draggable="true"
    :fullscreen-button="true"
  >
    <div class="space-y-5 px-1 py-2">
      <Alert
        v-if="props.shift"
        type="warning"
        show-icon
        :message="$t('workShifts.editWarning.description')"
      />

      <FormItem
        class="!mb-0"
        :label="$t('workShifts.fields.name')"
        :label-col="{ span: 24 }"
        :wrapper-col="{ span: 24 }"
        v-bind="validateInfos.name"
        required
      >
        <Input
          v-model:value="formData.name"
          :placeholder="$t('workShifts.placeholders.name')"
          :maxlength="255"
        />
      </FormItem>

      <section class="space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <h4 class="text-sm font-semibold text-foreground">
            {{
              $t('workShifts.labels.periodsCount', {
                count: formData.periods.length,
              })
            }}
          </h4>
          <label class="flex cursor-pointer items-center gap-2 text-xs">
            <Checkbox v-model:checked="hasOvernight">
              {{ $t('workShifts.fields.overnight') }}
            </Checkbox>
          </label>
        </div>

        <ul class="space-y-2">
          <li
            v-for="(period, idx) in formData.periods"
            :key="idx"
            class="flex flex-wrap items-center gap-x-3 gap-y-2 rounded-lg border border-border bg-muted/30 px-3 py-2"
          >
            <span
              class="w-16 shrink-0 text-xs font-medium text-muted-foreground"
            >
              {{ $t('workShifts.labels.period', { index: idx + 1 }) }}
            </span>
            <div class="flex min-w-0 flex-1 flex-wrap items-center gap-2">
              <div class="flex items-center gap-1.5">
                <TimePicker
                  :allow-clear="false"
                  :minute-step="30"
                  v-model:value="period.start_time"
                  :aria-label="$t('workShifts.fields.start')"
                  format="HH:mm"
                  value-format="HH:mm:ss"
                  class="w-28"
                />
                <Select
                  v-if="hasOvernight"
                  v-model:value="period.start_day_offset"
                  :options="dayOffsetOptions"
                  class="w-32 shrink-0"
                />
              </div>
              <IconifyIcon
                class="size-4 shrink-0 text-muted-foreground"
                icon="lucide:arrow-right"
              />
              <div class="flex items-center gap-1.5">
                <TimePicker
                  :allow-clear="false"
                  :minute-step="30"
                  v-model:value="period.end_time"
                  :aria-label="$t('workShifts.fields.end')"
                  format="HH:mm"
                  value-format="HH:mm:ss"
                  class="w-28"
                />
                <Select
                  v-if="hasOvernight"
                  v-model:value="period.end_day_offset"
                  :options="dayOffsetOptions"
                  class="w-32 shrink-0"
                />
              </div>
            </div>
            <Button
              v-if="formData.periods.length > 1"
              danger
              size="small"
              type="text"
              :aria-label="
                $t('workShifts.actions.deletePeriodLabel', { index: idx + 1 })
              "
              :title="$t('workShifts.actions.deletePeriod')"
              @click="removePeriod(idx)"
            >
              <template #icon>
                <IconifyIcon class="size-4" icon="lucide:trash-2" />
              </template>
            </Button>
          </li>
        </ul>

        <Button
          v-if="formData.periods.length < 24"
          block
          type="dashed"
          :aria-label="$t('workShifts.actions.addPeriod')"
          @click="addPeriod"
        >
          <IconifyIcon class="mr-1 inline size-4" icon="lucide:plus" />
          {{ $t('workShifts.actions.addPeriod') }}
        </Button>

        <div
          v-if="validationErrors.length > 0"
          class="rounded-lg bg-destructive/10 p-2.5 text-xs text-destructive"
          role="alert"
        >
          <ul class="list-disc space-y-0.5 pl-4">
            <li v-for="(err, eIdx) in validationErrors" :key="eIdx">
              {{ err }}
            </li>
          </ul>
        </div>
      </section>

      <!-- Live preview of the shift on a 24h bar -->
      <section class="rounded-lg border border-border bg-card p-3">
        <div class="mb-2 flex items-center justify-between text-xs">
          <span class="text-muted-foreground">
            {{ $t('workShifts.labels.estimatedHours') }}
          </span>
          <span class="text-sm font-semibold text-primary">
            {{ formatHours(getShiftTotalHours({ periods: formData.periods })) }}
          </span>
        </div>
        <ShiftTimeline :periods="formData.periods" />
      </section>
    </div>

    <template #footer>
      <div class="flex w-full items-center justify-end gap-2">
        <Button @click="closeForm">
          {{ $t('workShifts.actions.cancel') }}
        </Button>
        <Button
          type="primary"
          :loading="submitting"
          :disabled="!canSubmit"
          @click="handleSubmit"
        >
          {{
            $t(
              props.shift
                ? 'workShifts.actions.save'
                : 'workShifts.actions.submitCreate',
            )
          }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

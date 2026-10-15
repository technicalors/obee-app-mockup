<script setup lang="ts">
import type { Dayjs } from 'dayjs';

import type {
  AbsenceRequestTimeoffSubtype,
  AbsenceRequestType,
} from '../absence-page';

import type {
  AbsenceRequest,
  CreateAbsenceRequest,
  LeaveBalance,
  LeaveCoveragePreview,
} from '#/api/absence-requests';
import type { UserTreeSelectionUser } from '#/api/contracts';
import type { WorkUserShift } from '#/api/work-user-shifts';

import { computed, onBeforeUnmount, ref, watch } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { preferences } from '@vben/preferences';

import {
  Alert,
  Button,
  DatePicker,
  Form,
  FormItem,
  Input,
  Select,
  Spin,
} from 'ant-design-vue';
import dayjs from 'dayjs';
import timezone from 'dayjs/plugin/timezone';
import utc from 'dayjs/plugin/utc';

import { previewLeaveCoverage } from '#/api/absence-requests';
import { getMyWorkUserShifts } from '#/api/work-user-shifts';
import { $t } from '#/locales';

import {
  ABSENCE_REQUEST_TIMEOFF_SUBTYPE,
  ABSENCE_REQUEST_TYPE,
  deriveAbsenceRequestLeaveType,
} from '../absence-page';
import AbsenceRequestBalanceNotice from './AbsenceRequestBalanceNotice.vue';
import AbsenceRequestCoverageTable from './AbsenceRequestCoverageTable.vue';

const props = defineProps<{
  balance: LeaveBalance | null;
  balanceError: boolean;
  balanceLoading: boolean;
  currentUserId: null | string;
  editingRequest: AbsenceRequest | null;
  open: boolean;
  requestType: AbsenceRequestType;
  reviewerUsers: UserTreeSelectionUser[];
  reviewerUsersLoadError: boolean;
  reviewerUsersLoading: boolean;
  rootOrganizationId: null | string;
  submitting: boolean;
}>();
const emit = defineEmits<{
  balanceDateChange: [date: null | string];
  submit: [values: CreateAbsenceRequest];
  'update:open': [value: boolean];
}>();
dayjs.extend(utc);
dayjs.extend(timezone);

const requestType = ref<AbsenceRequestType>(props.requestType);
const timeoffSubtype = ref<'' | AbsenceRequestTimeoffSubtype>('');
const timeoffDate = ref<string | undefined>();
const timeoffShiftType = ref('all');
const assignedShift = ref<null | WorkUserShift>(null);
const assignmentLoading = ref(false);
const assignmentError = ref(false);
const reviewerId = ref<string | undefined>();
const startAt = ref<string | undefined>();
const endAt = ref<string | undefined>();
const startPickerValue = computed<Dayjs | undefined>({
  get: () =>
    startAt.value
      ? dayjs(startAt.value).tz(preferences.app.timezone)
      : undefined,
  set: (value: Dayjs | null | undefined) => {
    startAt.value =
      value === null || value === undefined
        ? undefined
        : dayjs
            .tz(value.format('YYYY-MM-DDTHH:mm:ss'), preferences.app.timezone)
            .toISOString();
  },
});
const endPickerValue = computed<Dayjs | undefined>({
  get: () =>
    endAt.value ? dayjs(endAt.value).tz(preferences.app.timezone) : undefined,
  set: (value: Dayjs | null | undefined) => {
    endAt.value =
      value === null || value === undefined
        ? undefined
        : dayjs
            .tz(value.format('YYYY-MM-DDTHH:mm:ss'), preferences.app.timezone)
            .toISOString();
  },
});
const reason = ref('');
const address = ref('');
const coveragePreview = ref<LeaveCoveragePreview | null>(null);
const coverageLoading = ref(false);
const coverageError = ref(false);
let coverageVersion = 0;
let assignmentVersion = 0;
onBeforeUnmount(() => {
  ++assignmentVersion;
  ++coverageVersion;
});

const modalTitle = computed(() => {
  if (props.editingRequest) {
    return $t('absenceRequests.create.editTitle');
  }
  if (requestType.value === ABSENCE_REQUEST_TYPE.BUSINESS_TRIP) {
    return $t('absenceRequests.create.actions.openBusinessTrip');
  }
  if (requestType.value === ABSENCE_REQUEST_TYPE.TIMEOFF) {
    return $t('absenceRequests.create.actions.openTimeoff');
  }
  return $t('absenceRequests.create.actions.openBusinessTrip');
});

const [Modal, modalApi] = useVbenModal({
  class: 'w-[680px] max-w-[calc(100vw-1rem)]',
  contentClass: 'p-2 sm:p-4',
  footerClass: 'p-2 sm:p-3',
  headerClass: 'px-3 py-2.5 sm:px-5 sm:py-4',
  draggable: true,
  footer: true,
  fullscreenButton: true,
  showCancelButton: false,
  showConfirmButton: false,
  onOpenChange: (open) => {
    emit('update:open', open);
  },
  title: modalTitle.value,
});

watch(modalTitle, (newTitle) => {
  modalApi.setState({ title: newTitle });
});

watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      modalApi.open();
    } else {
      modalApi.close();
    }
  },
);

const defaultTimePickerValue = dayjs('08:00', 'HH:mm');

const isTimeoff = computed(
  () => requestType.value === ABSENCE_REQUEST_TYPE.TIMEOFF,
);
const isBusinessTrip = computed(
  () => requestType.value === ABSENCE_REQUEST_TYPE.BUSINESS_TRIP,
);
const shiftTypeOptions = computed(() => {
  const options: { label: string; value: string }[] = [];
  if (assignedShift.value !== null) {
    const shift = assignedShift.value;
    const isOvernight = dayjs(shift.end_at)
      .tz(preferences.app.timezone)
      .isAfter(dayjs(shift.start_at).tz(preferences.app.timezone), 'day');
    const allLabel = $t(
      isOvernight
        ? 'absenceRequests.create.shiftSelection.wholeShiftOvernight'
        : 'absenceRequests.create.shiftSelection.wholeShift',
      {
        name: shift.work_shift.name,
        start: dayjs(shift.start_at)
          .tz(preferences.app.timezone)
          .format('HH:mm'),
        end: dayjs(shift.end_at).tz(preferences.app.timezone).format('HH:mm'),
      },
    );

    options.push({ label: allLabel, value: 'all' });

    shift.work_periods.forEach((period, index) => {
      const periodOvernight = dayjs(period.end_at)
        .tz(preferences.app.timezone)
        .isAfter(dayjs(period.start_at).tz(preferences.app.timezone), 'day');
      options.push({
        label: $t(
          periodOvernight
            ? 'absenceRequests.create.shiftSelection.periodOvernight'
            : 'absenceRequests.create.shiftSelection.period',
          {
            index: index + 1,
            start: dayjs(period.start_at)
              .tz(preferences.app.timezone)
              .format('HH:mm'),
            end: dayjs(period.end_at)
              .tz(preferences.app.timezone)
              .format('HH:mm'),
          },
        ),
        value: String(index),
      });
    });
  }
  options.push({
    label: $t('absenceRequests.create.shiftSelection.custom'),
    value: 'custom',
  });
  return options;
});

function applyShiftToTimes(): void {
  if (timeoffShiftType.value === 'custom') {
    if (!startAt.value || !endAt.value) {
      const date =
        timeoffDate.value ??
        dayjs().tz(preferences.app.timezone).format('YYYY-MM-DD');
      startAt.value = dayjs
        .tz(`${date}T08:00:00`, preferences.app.timezone)
        .toISOString();
      endAt.value = dayjs
        .tz(`${date}T17:30:00`, preferences.app.timezone)
        .toISOString();
    }
    return;
  }
  const assignment = assignedShift.value;
  if (assignment === null) {
    startAt.value = undefined;
    endAt.value = undefined;
    return;
  }
  if (timeoffShiftType.value === 'all') {
    startAt.value = assignment.start_at;
    endAt.value = assignment.end_at;
  } else {
    const period = assignment.work_periods[Number(timeoffShiftType.value)];
    if (period === undefined) throw new Error('Invalid selected work period.');
    startAt.value = period.start_at;
    endAt.value = period.end_at;
  }
}

async function loadAssignedShift(): Promise<void> {
  const version = ++assignmentVersion;
  const date = timeoffDate.value;
  const rootId = props.rootOrganizationId;
  assignedShift.value = null;
  assignmentError.value = false;
  assignmentLoading.value = false;
  if (!props.open || !date) return;
  assignmentLoading.value = true;
  try {
    const rows = await getMyWorkUserShifts({ from: date, to: date });
    if (version !== assignmentVersion) return;
    assignedShift.value =
      rows.find((row) => row.root_organization_id === rootId) ?? null;
    if (
      props.editingRequest === null ||
      date !==
        dayjs(props.editingRequest.start_at)
          .tz(preferences.app.timezone)
          .format('YYYY-MM-DD')
    )
      applyShiftToTimes();
  } catch {
    if (version === assignmentVersion) assignmentError.value = true;
  } finally {
    if (version === assignmentVersion) assignmentLoading.value = false;
  }
}

function handleShiftChange(value: unknown): void {
  timeoffShiftType.value = String(value);
  applyShiftToTimes();
}

function retryLoadShift(): void {
  void loadAssignedShift();
}

watch(
  [timeoffDate, () => props.open, () => props.rootOrganizationId],
  ([date, open]) => {
    if (
      open &&
      date &&
      (props.editingRequest === null ||
        date !==
          dayjs(props.editingRequest.start_at)
            .tz(preferences.app.timezone)
            .format('YYYY-MM-DD'))
    ) {
      timeoffShiftType.value = 'all';
      startAt.value = undefined;
      endAt.value = undefined;
    } else if (open && !date) {
      timeoffShiftType.value = 'all';
      startAt.value = undefined;
      endAt.value = undefined;
    }
    void loadAssignedShift();
  },
  { flush: 'sync' },
);

const timeRangeError = computed(() => {
  if (!startAt.value || !endAt.value) return null;
  const start = dayjs(startAt.value);
  const end = dayjs(endAt.value);
  if (!end.isAfter(start)) {
    return 'absenceRequests.create.validation.dateRangeInvalid';
  }
  return null;
});

const isSaveBlocked = computed(() => {
  if (props.reviewerUsersLoading || props.reviewerUsersLoadError) return true;
  if (props.rootOrganizationId === null) return true;
  if (
    !reviewerId.value ||
    !startAt.value ||
    !endAt.value ||
    reason.value === ''
  ) {
    return true;
  }
  if (isBusinessTrip.value && address.value === '') return true;
  if (isTimeoff.value && !timeoffSubtype.value) return true;
  if (isTimeoff.value && timeoffShiftType.value !== 'custom') {
    if (assignmentLoading.value || assignmentError.value) return true;
    const isEditingCurrentDay =
      props.editingRequest !== null &&
      timeoffDate.value ===
        dayjs(props.editingRequest.start_at)
          .tz(preferences.app.timezone)
          .format('YYYY-MM-DD');
    if (!isEditingCurrentDay && assignedShift.value === null) return true;
  }
  if (timeRangeError.value) return true;
  return false;
});

const filteredReviewers = computed(() => {
  return props.reviewerUsers
    .filter((user) => user.id !== props.currentUserId)
    .map((user) => ({ label: user.name, value: user.id }));
});

async function loadCoveragePreview(): Promise<void> {
  const version = ++coverageVersion;
  coverageError.value = false;
  coveragePreview.value = null;
  coverageLoading.value = false;
  const derivedType = deriveAbsenceRequestLeaveType({
    requestType: requestType.value,
    timeoffSubtype: timeoffSubtype.value,
  });

  if (
    !derivedType ||
    props.rootOrganizationId === null ||
    !startAt.value ||
    !endAt.value ||
    timeRangeError.value
  ) {
    coveragePreview.value = null;
    return;
  }

  coverageLoading.value = true;
  try {
    const preview = await previewLeaveCoverage({
      root_organization_id: props.rootOrganizationId,
      end_at: endAt.value,
      leave_type: derivedType,
      start_at: startAt.value,
      user_id: props.currentUserId ?? undefined,
    });
    if (version === coverageVersion) coveragePreview.value = preview;
  } catch {
    if (version === coverageVersion) coverageError.value = true;
  } finally {
    if (version === coverageVersion) coverageLoading.value = false;
  }
}

watch([startAt, endAt, requestType, timeoffSubtype], () => {
  void loadCoveragePreview();
});

watch(startAt, (value) => {
  emit(
    'balanceDateChange',
    value
      ? dayjs(value).tz(preferences.app.timezone).format('YYYY-MM-DD')
      : null,
  );
});

watch(
  () => props.open,
  (isOpen) => {
    if (isOpen && props.editingRequest) {
      const request = props.editingRequest;
      requestType.value =
        request.leave_type === 'BUSINESS_TRIP'
          ? ABSENCE_REQUEST_TYPE.BUSINESS_TRIP
          : ABSENCE_REQUEST_TYPE.TIMEOFF;
      timeoffSubtype.value =
        request.leave_type === 'BUSINESS_TRIP' ? '' : request.leave_type;
      reviewerId.value = request.reviewer_id;
      startAt.value = request.start_at;
      endAt.value = request.end_at;
      if (request.leave_type !== 'BUSINESS_TRIP') {
        timeoffDate.value = dayjs(request.start_at)
          .tz(preferences.app.timezone)
          .format('YYYY-MM-DD');
        timeoffShiftType.value = 'all';
      }
      reason.value = request.reason;
      address.value = request.address ?? '';
    } else if (isOpen) {
      requestType.value = props.requestType;
      timeoffSubtype.value =
        props.requestType === ABSENCE_REQUEST_TYPE.TIMEOFF ? 'ANNUAL' : '';
    } else if (!isOpen) {
      requestType.value = props.requestType;
      timeoffSubtype.value = '';
      reviewerId.value = undefined;
      startAt.value = undefined;
      endAt.value = undefined;
      timeoffDate.value = undefined;
      timeoffShiftType.value = 'all';
      reason.value = '';
      address.value = '';
    }
  },
);

function handleSubmit(): void {
  const derivedType = deriveAbsenceRequestLeaveType({
    requestType: requestType.value,
    timeoffSubtype: timeoffSubtype.value,
  });

  if (
    !derivedType ||
    props.rootOrganizationId === null ||
    !reviewerId.value ||
    !startAt.value ||
    !endAt.value ||
    timeRangeError.value
  ) {
    return;
  }

  emit('submit', {
    address: isBusinessTrip.value ? address.value : null,
    root_organization_id: props.rootOrganizationId,
    end_at: endAt.value,
    leave_type: derivedType,
    reason: reason.value,
    reviewer_id: reviewerId.value,
    start_at: startAt.value,
  });
}
</script>

<template>
  <Modal
    :close-on-click-modal="false"
    :draggable="true"
    :fullscreen-button="true"
  >
    <div>
      <Form layout="vertical" class="[&_.ant-form-item]:mb-4!">
        <p v-if="isBusinessTrip" class="text-xs text-muted-foreground">
          {{ $t('absenceRequests.create.hints.businessTrip') }}
        </p>

        <!-- Balance Notice -->
        <AbsenceRequestBalanceNotice
          :balance="balance"
          :is-loading="balanceLoading"
          :is-error="balanceError"
          class="mb-4"
        />

        <!-- Reviewer -->
        <FormItem
          :label="$t('absenceRequests.create.fields.reviewer')"
          :validate-status="reviewerUsersLoadError ? 'error' : undefined"
          :help="
            reviewerUsersLoadError ? $t('userTreeSelect.loadError') : undefined
          "
          required
        >
          <Select
            v-model:value="reviewerId"
            :options="filteredReviewers"
            :loading="reviewerUsersLoading"
            :disabled="reviewerUsersLoading || reviewerUsersLoadError"
            allow-clear
            show-search
            option-filter-prop="label"
            class="w-full"
            :placeholder="$t('absenceRequests.create.placeholders.reviewer')"
            data-testid="absence-form-reviewer-select"
          />
        </FormItem>

        <!-- Timeoff subtype -->
        <FormItem
          v-if="isTimeoff"
          :label="$t('absenceRequests.create.fields.timeoffType')"
          required
        >
          <Select
            v-model:value="timeoffSubtype"
            class="w-full"
            :placeholder="$t('absenceRequests.create.placeholders.timeoffType')"
            :options="[
              {
                label: $t('absenceRequests.create.options.timeoffType.ANNUAL'),
                value: ABSENCE_REQUEST_TIMEOFF_SUBTYPE.ANNUAL,
              },
              {
                label: $t('absenceRequests.create.options.timeoffType.UNPAID'),
                value: ABSENCE_REQUEST_TIMEOFF_SUBTYPE.UNPAID,
              },
            ]"
          />
        </FormItem>

        <!-- Leave options: date, shift/interval selection -->
        <div v-if="isTimeoff">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <FormItem
              :label="$t('absenceRequests.create.fields.timeoffDate')"
              required
            >
              <DatePicker
                v-model:value="timeoffDate"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
                class="w-full"
                :placeholder="
                  $t('absenceRequests.create.placeholders.timeoffDate')
                "
              />
            </FormItem>

            <FormItem
              :label="$t('absenceRequests.create.fields.timeoffShift')"
              required
            >
              <div
                v-if="assignmentLoading"
                class="flex items-center gap-2 py-1 text-xs text-muted-foreground"
              >
                <Spin size="small" />
                <span>{{
                  $t('absenceRequests.create.shiftSelection.loading')
                }}</span>
              </div>
              <Select
                v-else
                :value="timeoffDate ? timeoffShiftType : undefined"
                class="w-full"
                :disabled="!timeoffDate"
                :options="shiftTypeOptions"
                :placeholder="
                  $t(
                    timeoffDate
                      ? 'absenceRequests.create.shiftSelection.placeholder'
                      : 'absenceRequests.create.shiftSelection.selectDateFirst',
                  )
                "
                data-testid="absence-form-shift-select"
                @change="handleShiftChange"
              />
            </FormItem>
          </div>

          <Alert
            v-if="assignmentError"
            type="error"
            show-icon
            class="mb-4"
            :message="$t('absenceRequests.create.shiftSelection.loadFailed')"
          >
            <template #action>
              <Button size="small" type="link" @click="retryLoadShift">
                {{ $t('absenceRequests.create.shiftSelection.retry') }}
              </Button>
            </template>
          </Alert>

          <Alert
            v-else-if="
              !assignmentLoading &&
              timeoffDate &&
              assignedShift === null &&
              timeoffShiftType !== 'custom'
            "
            type="warning"
            show-icon
            class="mb-4"
            :message="$t('absenceRequests.create.shiftSelection.empty')"
          />

          <!-- Custom time range picker when user selects 'custom' -->
          <div
            v-if="timeoffShiftType === 'custom'"
            class="grid grid-cols-1 sm:grid-cols-2 gap-x-3"
          >
            <FormItem
              :label="$t('absenceRequests.create.fields.startDate')"
              required
            >
              <DatePicker
                v-model:value="startPickerValue"
                format="YYYY-MM-DD HH:mm"
                :show-time="{
                  format: 'HH:mm',
                  defaultValue: defaultTimePickerValue,
                }"
                class="w-full"
                :placeholder="
                  $t('absenceRequests.create.placeholders.startDate')
                "
              />
            </FormItem>
            <FormItem
              :label="$t('absenceRequests.create.fields.endDate')"
              required
            >
              <DatePicker
                v-model:value="endPickerValue"
                format="YYYY-MM-DD HH:mm"
                :show-time="{
                  format: 'HH:mm',
                  defaultValue: defaultTimePickerValue,
                }"
                class="w-full"
                :placeholder="$t('absenceRequests.create.placeholders.endDate')"
              />
            </FormItem>
          </div>
        </div>

        <!-- Business Trip: Custom Start Date/Time & End Date/Time -->
        <div
          v-else-if="isBusinessTrip"
          class="grid grid-cols-1 sm:grid-cols-2 gap-3"
        >
          <FormItem
            :label="$t('absenceRequests.create.fields.startDate')"
            required
          >
            <DatePicker
              v-model:value="startPickerValue"
              format="YYYY-MM-DD HH:mm"
              :show-time="{
                format: 'HH:mm',
                defaultValue: defaultTimePickerValue,
              }"
              class="w-full"
              :placeholder="$t('absenceRequests.create.placeholders.startDate')"
            />
          </FormItem>
          <FormItem
            :label="$t('absenceRequests.create.fields.endDate')"
            required
          >
            <DatePicker
              v-model:value="endPickerValue"
              format="YYYY-MM-DD HH:mm"
              :show-time="{
                format: 'HH:mm',
                defaultValue: defaultTimePickerValue,
              }"
              class="w-full"
              :placeholder="$t('absenceRequests.create.placeholders.endDate')"
            />
          </FormItem>
        </div>

        <!-- Coverage Preview Table -->
        <AbsenceRequestCoverageTable
          v-if="startAt && endAt && !timeRangeError"
          :preview="coveragePreview"
          :loading="coverageLoading"
          :error="coverageError"
          :business-trip="isBusinessTrip"
          @retry="loadCoveragePreview"
          class="mb-4"
        />
        <p v-if="timeRangeError" class="text-xs text-destructive">
          {{ $t(timeRangeError) }}
        </p>

        <!-- Reason -->
        <FormItem :label="$t('absenceRequests.create.fields.reason')" required>
          <Input.TextArea
            v-model:value="reason"
            :rows="3"
            :placeholder="$t('absenceRequests.create.placeholders.reason')"
            :maxlength="5000"
          />
        </FormItem>

        <!-- Business Trip Address -->
        <FormItem
          v-if="isBusinessTrip"
          :label="$t('absenceRequests.create.fields.address')"
          required
        >
          <Input
            v-model:value="address"
            :placeholder="$t('absenceRequests.create.placeholders.address')"
            :maxlength="255"
          />
        </FormItem>
      </Form>
    </div>

    <!-- Modal Footer with actions -->
    <template #footer>
      <div class="flex w-full items-center justify-end gap-2">
        <Button @click="emit('update:open', false)">
          {{ $t('absenceRequests.create.actions.cancel') }}
        </Button>
        <Button
          type="primary"
          :loading="submitting"
          :disabled="isSaveBlocked || submitting"
          @click="handleSubmit"
        >
          {{ $t('absenceRequests.create.actions.submit') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

<script setup lang="ts">
import type { SelectValue } from 'ant-design-vue/es/select';

import type { CalendarDay, UiWeekday } from './shift-calendar';

import type { UserTreeSelectionUser } from '#/api/contracts';
import type { WorkShift } from '#/api/work-shifts';
import type { WorkUserShift } from '#/api/work-user-shifts';

import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';

import { useAccess } from '@vben/access';
import { Page } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';
import { preferences } from '@vben/preferences';

import {
  Button,
  DatePicker,
  Empty,
  InputNumber,
  Modal,
  notification,
  Select,
  Spin,
} from 'ant-design-vue';
import dayjs from 'dayjs';
import timezone from 'dayjs/plugin/timezone';
import utc from 'dayjs/plugin/utc';

import { getOrganizationRootId } from '#/api';
import { userTreeResource } from '#/api/users';
import { getWorkShifts } from '#/api/work-shifts';
import {
  createWorkUserShiftRange,
  deleteWorkUserShift,
  getWorkUserShifts,
  updateWorkUserShift,
} from '#/api/work-user-shifts';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import UserTreeSelect from '#/shared/user-tree-select/user-tree-select.vue';
import { useAuthStore } from '#/store';

import {
  buildMonthCalendarGrid,
  buildShiftLookup,
  buildWorkShiftRangePayload,
  filterWorkShiftAssignableUsers,
  formatShiftTime,
  getMonthDateRange,
  getUiWeekday,
  resolveWorkShiftRootOrganizationId,
  summarizeWorkShiftRange,
  UI_WEEKDAYS,
} from './shift-calendar';
import ShiftConfigModal from './shift-config-modal.vue';
import ShiftTimeline from './shift-timeline.vue';

dayjs.extend(utc);
dayjs.extend(timezone);

const { hasAccessByCodes } = useAccess();
const authStore = useAuthStore();

const canCreate = computed(() => hasAccessByCodes(['work-user-shifts.create']));
const canUpdate = computed(() => hasAccessByCodes(['work-user-shifts.update']));
const canDelete = computed(() => hasAccessByCodes(['work-user-shifts.delete']));

const treeUsers = ref<UserTreeSelectionUser[]>([]);
const shifts = ref<WorkUserShift[]>([]);
const selectedMonth = ref(dayjs().format('YYYY-MM'));
const selectedUserId = ref<null | string>(null);
const selectedShiftId = ref<null | string>(null);

const usersLoading = ref(false);
const usersLoadError = ref(false);
const shiftsLoading = ref(false);
const saving = ref(false);
const deleting = ref(false);

const configOpen = ref(false);
const createOpen = ref(false);
const detailOpen = ref(false);

const formUserIds = ref<string[]>([]);
const formDateFrom = ref('');
const formDateTo = ref('');
const formWorkShiftId = ref('');
const catalog = ref<WorkShift[]>([]);
const catalogLoading = ref(false);
const catalogError = ref(false);
const repeatEveryWeeks = ref(1);
const formSelectedWeekdays = ref<UiWeekday[]>([2, 3, 4, 5, 6]);

let shiftLoadVersion = 0;

const assignableUsers = computed(() =>
  filterWorkShiftAssignableUsers(treeUsers.value),
);

const hasAssignableUsers = computed(() => assignableUsers.value.length > 0);

const selectedUser = computed(() =>
  assignableUsers.value.find((u) => u.id === selectedUserId.value),
);

const shiftTypeOptions = computed(() =>
  catalog.value.map((shift) => ({
    label: shift.name,
    value: shift.id,
  })),
);

const calendarDays = computed<CalendarDay[]>(() =>
  buildMonthCalendarGrid(selectedMonth.value),
);

const shiftByDate = computed(() => {
  const targetUserId = selectedUserId.value;
  if (!targetUserId) {
    return new Map<string, WorkUserShift>();
  }

  const userShifts = shifts.value.filter((s) => s.user_id === targetUserId);
  const lookup = buildShiftLookup(userShifts);
  const map = new Map<string, WorkUserShift>();
  for (const [key, shift] of lookup.entries()) {
    const [, date] = key.split(':');
    if (date) {
      map.set(date, shift);
    }
  }
  return map;
});

const selectedShift = computed(
  () =>
    shifts.value.find((shift) => shift.id === selectedShiftId.value) ?? null,
);

const selectedRootOrganizationId = computed(() => {
  if (createOpen.value && formUserIds.value.length > 0) {
    return resolveWorkShiftRootOrganizationId(
      assignableUsers.value,
      formUserIds.value,
    );
  }
  if (selectedUser.value?.organization) {
    const orgId = getOrganizationRootId(selectedUser.value.organization);
    if (orgId) return orgId;
  }
  const firstOrg = assignableUsers.value[0]?.organization;
  if (firstOrg) {
    const orgId = getOrganizationRootId(firstOrg);
    if (orgId) return orgId;
  }
  return authStore.user?.root_organization_id ?? null;
});

let catalogVersion = 0;
onBeforeUnmount(() => {
  ++catalogVersion;
});

async function loadCatalog(): Promise<void> {
  const version = ++catalogVersion;
  const rootId = selectedRootOrganizationId.value;
  catalog.value = [];
  formWorkShiftId.value = '';
  catalogError.value = false;
  catalogLoading.value = false;
  if (rootId === null) return;
  catalogLoading.value = true;
  try {
    const rows = await getWorkShifts(rootId);
    if (version !== catalogVersion) return;
    catalog.value = rows;
  } catch (error: unknown) {
    if (version !== catalogVersion) return;
    catalogError.value = true;
    showRequestError(
      error,
      $t('workUserShifts.messages.loadFailed'),
      'Failed to load work shifts:',
    );
  } finally {
    if (version === catalogVersion) catalogLoading.value = false;
  }
}

watch(
  selectedRootOrganizationId,
  () => {
    void loadCatalog();
  },
  { immediate: true, flush: 'sync' },
);

const formSummary = computed(() =>
  summarizeWorkShiftRange({
    dateFrom: formDateFrom.value,
    dateTo: formDateTo.value,
    selectedWeekdays: formSelectedWeekdays.value,
    workShiftId: formWorkShiftId.value,
    repeatEveryWeeks: repeatEveryWeeks.value,
    userIds: formUserIds.value,
  }),
);

const canSubmitForm = computed(() => {
  return (
    !catalogLoading.value &&
    !catalogError.value &&
    catalog.value.some((shift) => shift.id === formWorkShiftId.value) &&
    !usersLoading.value &&
    !usersLoadError.value &&
    selectedRootOrganizationId.value !== null &&
    formUserIds.value.length > 0 &&
    formDateFrom.value.length > 0 &&
    formDateTo.value.length > 0 &&
    formDateFrom.value <= formDateTo.value &&
    formSelectedWeekdays.value.length > 0 &&
    formSummary.value.totalAssignments > 0
  );
});

async function loadUsers(): Promise<void> {
  usersLoading.value = true;
  usersLoadError.value = false;
  try {
    treeUsers.value = await userTreeResource.getAll({ trashed: 'with' });
    const currentUserId = authStore.user?.id ? String(authStore.user.id) : '';
    const preferredUser =
      assignableUsers.value.find((u) => u.id === currentUserId) ??
      assignableUsers.value[0];
    selectedUserId.value = preferredUser?.id ?? null;
  } catch (error: unknown) {
    usersLoadError.value = true;
    showRequestError(
      error,
      $t('workUserShifts.messages.loadFailed'),
      'Failed to load user tree:',
    );
  } finally {
    usersLoading.value = false;
  }
}

async function loadShifts(): Promise<void> {
  const version = ++shiftLoadVersion;
  if (!selectedUserId.value || !selectedUser.value) {
    shifts.value = [];
    return;
  }

  const rootOrganizationId = getOrganizationRootId(
    selectedUser.value.organization,
  );

  const { dateFrom, dateTo } = getMonthDateRange(selectedMonth.value);

  shiftsLoading.value = true;
  try {
    const data = await getWorkUserShifts({
      root_organization_id: rootOrganizationId,
      from: dateFrom,
      to: dateTo,
      user_id: selectedUserId.value,
    });
    if (version === shiftLoadVersion) {
      shifts.value = data;
    }
  } catch (error: unknown) {
    if (version === shiftLoadVersion) {
      showRequestError(
        error,
        $t('workUserShifts.messages.loadFailed'),
        'Failed to load work user shifts:',
      );
    }
  } finally {
    if (version === shiftLoadVersion) {
      shiftsLoading.value = false;
    }
  }
}

async function refreshCatalogAndAssignments(): Promise<void> {
  await Promise.all([loadCatalog(), loadShifts()]);
}

function handleMonthChange(value: unknown): void {
  if (value && typeof value === 'object' && 'format' in value) {
    selectedMonth.value = (value as { format: (fmt: string) => string }).format(
      'YYYY-MM',
    );
  } else if (typeof value === 'string') {
    selectedMonth.value = value.slice(0, 7);
  }
}

function openCreate(date?: string): void {
  if (!selectedUserId.value) {
    notification.warning({
      message: $t('workUserShifts.messages.userRequired'),
    });
    return;
  }

  const range = getMonthDateRange(selectedMonth.value);
  formUserIds.value = [selectedUserId.value];
  formDateFrom.value = date ?? range.dateFrom;
  formDateTo.value = date ?? range.dateTo;
  formWorkShiftId.value = '';
  repeatEveryWeeks.value = 1;
  formSelectedWeekdays.value = date
    ? [getUiWeekday(dayjs(date))]
    : [2, 3, 4, 5, 6];

  createOpen.value = true;
}

function toggleWeekday(day: UiWeekday): void {
  const index = formSelectedWeekdays.value.indexOf(day);
  formSelectedWeekdays.value =
    index === -1
      ? [...formSelectedWeekdays.value, day].toSorted()
      : formSelectedWeekdays.value.filter((d) => d !== day);
}

function selectWeekdays(days: UiWeekday[]): void {
  formSelectedWeekdays.value = [...days];
}

const detailPeriods = computed(() => {
  const shift = selectedShift.value;
  if (shift === null) return [];
  const timeZone = preferences.app.timezone;
  const anchor = dayjs.tz(shift.work_date, timeZone);
  return shift.work_periods.map((period) => {
    const start = dayjs(period.start_at).tz(timeZone);
    const end = dayjs(period.end_at).tz(timeZone);
    const startOffset = start.isAfter(anchor, 'day') ? 1 : 0;
    const endOffset = end.isAfter(anchor, 'day') ? 1 : 0;
    return {
      end_day_offset: endOffset,
      end_time: `${formatShiftTime(period.end_at, timeZone)}:00`,
      hours: end.diff(start, 'minute') / 60,
      start_day_offset: startOffset,
      start_time: `${formatShiftTime(period.start_at, timeZone)}:00`,
    };
  });
});

function formatDetailTime(time: string, dayOffset: number): string {
  return dayOffset > 0
    ? `${time.slice(0, 5)} (+${dayOffset})`
    : time.slice(0, 5);
}

function formatDetailHours(hours: number): string {
  return $t('workShifts.labels.hours', {
    count: new Intl.NumberFormat(preferences.app.locale, {
      maximumFractionDigits: 1,
    }).format(hours),
  });
}

function openDetail(shift: WorkUserShift): void {
  selectedShiftId.value = shift.id;
  detailOpen.value = true;
}

async function submitCreateRange(): Promise<void> {
  if (!canSubmitForm.value || !selectedRootOrganizationId.value) {
    return;
  }

  saving.value = true;
  try {
    const payload = buildWorkShiftRangePayload({
      rootOrganizationId: selectedRootOrganizationId.value,
      dateFrom: formDateFrom.value,
      dateTo: formDateTo.value,
      selectedWeekdays: formSelectedWeekdays.value,
      workShiftId: formWorkShiftId.value,
      repeatEveryWeeks: repeatEveryWeeks.value,
      userIds: formUserIds.value,
    });

    await createWorkUserShiftRange(payload);
    createOpen.value = false;
    notification.success({
      message: $t('workUserShifts.messages.created'),
    });
    await loadShifts();
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('workUserShifts.messages.saveFailed'),
      'Failed to create work shift range:',
    );
  } finally {
    saving.value = false;
  }
}

async function onDetailShiftTypeChange(
  newShiftType: SelectValue,
): Promise<void> {
  if (!selectedShift.value || typeof newShiftType !== 'string') {
    return;
  }

  saving.value = true;
  try {
    await updateWorkUserShift(selectedShift.value.id, newShiftType);
    notification.success({
      message: $t('workUserShifts.messages.updated'),
    });
    await loadShifts();
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('workUserShifts.messages.saveFailed'),
      'Failed to update work shift:',
    );
  } finally {
    saving.value = false;
  }
}

async function removeSelectedShift(): Promise<void> {
  if (!selectedShift.value) {
    return;
  }

  deleting.value = true;
  try {
    await deleteWorkUserShift(selectedShift.value.id);
    detailOpen.value = false;
    selectedShiftId.value = null;
    notification.success({
      message: $t('workUserShifts.messages.deleted'),
    });
    await loadShifts();
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('workUserShifts.messages.saveFailed'),
      'Failed to delete work shift:',
    );
  } finally {
    deleting.value = false;
  }
}

watch([selectedMonth, selectedUserId], () => {
  void loadShifts();
});

onMounted(() => {
  void loadUsers();
});
</script>

<template>
  <Page auto-content-height>
    <div class="flex h-full flex-col gap-3 p-3">
      <!-- Top Toolbar -->
      <section
        class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"
      >
        <div class="w-full sm:w-64">
          <DatePicker
            :allow-clear="false"
            class="w-full"
            picker="month"
            :placeholder="$t('workUserShifts.calendar.selectMonth')"
            :value="selectedMonth"
            value-format="YYYY-MM"
            @change="handleMonthChange"
          />
        </div>

        <div class="flex flex-wrap items-center gap-2">
          <div class="w-full sm:w-64">
            <UserTreeSelect
              class="w-full"
              :disabled="!hasAssignableUsers"
              :loading="usersLoading"
              :load-error="usersLoadError"
              :users="assignableUsers"
              :multiple="false"
              :placeholder="
                $t(
                  hasAssignableUsers
                    ? 'workUserShifts.calendar.selectUser'
                    : 'workUserShifts.calendar.noAssignableUsers',
                )
              "
              :model-value="selectedUserId === null ? [] : [selectedUserId]"
              test-id="shift-calendar-user-tree-select"
              @update:model-value="selectedUserId = $event[0] ?? null"
            />
          </div>

          <Button
            :disabled="usersLoading"
            :loading="shiftsLoading"
            @click="loadShifts"
          >
            <template #icon>
              <IconifyIcon class="size-4" icon="lucide:refresh-cw" />
            </template>
            {{ $t('workUserShifts.actions.refresh') }}
          </Button>

          <Button
            v-if="canCreate || canUpdate || canDelete"
            @click="configOpen = true"
          >
            <template #icon>
              <IconifyIcon class="size-4" icon="lucide:settings-2" />
            </template>
            {{ $t('workShifts.actions.configure') }}
          </Button>

          <Button
            v-if="canCreate"
            :disabled="!hasAssignableUsers || !selectedUserId"
            type="primary"
            @click="openCreate()"
          >
            <template #icon>
              <IconifyIcon class="size-4" icon="lucide:calendar-range" />
            </template>
            {{ $t('workUserShifts.actions.apply') }}
          </Button>
        </div>
      </section>

      <!-- Calendar Container -->
      <section
        class="relative flex flex-1 min-h-[560px] flex-col rounded-lg border border-neutral-200 bg-white shadow-xs dark:border-neutral-800 dark:bg-neutral-900"
      >
        <!-- Loading Overlay -->
        <div
          v-if="usersLoading || shiftsLoading"
          class="absolute inset-0 z-20 flex items-center justify-center bg-white/70 backdrop-blur-xs dark:bg-neutral-900/70"
        >
          <div
            class="size-8 animate-spin rounded-full border-2 border-neutral-300 border-t-primary"
          ></div>
        </div>

        <!-- Empty State -->
        <div
          v-if="!hasAssignableUsers && !usersLoading"
          class="flex flex-1 items-center justify-center p-8"
        >
          <Empty
            :description="$t('workUserShifts.calendar.noAssignableUsers')"
          />
        </div>

        <!-- Month Grid View -->
        <div v-else class="flex flex-1 flex-col overflow-hidden">
          <!-- Weekday Headers -->
          <div
            class="grid grid-cols-7 border-b border-neutral-200 text-center text-xs font-semibold select-none dark:border-neutral-800"
          >
            <div
              v-for="day in UI_WEEKDAYS"
              :key="day"
              class="py-2.5"
              :class="{
                'bg-[#f0f9ff] text-sky-800 dark:bg-sky-950/30 dark:text-sky-300':
                  day === 7,
                'bg-[#fef2f2] text-rose-800 dark:bg-rose-950/30 dark:text-rose-300':
                  day === 8,
                'bg-white text-neutral-600 dark:bg-neutral-900 dark:text-neutral-400':
                  day >= 2 && day <= 6,
              }"
            >
              {{ $t(`workUserShifts.weekdays.${day}`) }}
            </div>
          </div>

          <!-- Day Cells -->
          <div
            class="grid flex-1 grid-cols-7 auto-rows-fr divide-x divide-y divide-neutral-200 overflow-y-auto dark:divide-neutral-800"
          >
            <div
              v-for="cell in calendarDays"
              :key="cell.date"
              class="group relative flex min-h-[110px] flex-col p-1.5 transition-colors"
              :class="[
                cell.isSaturday
                  ? 'bg-[#f0f9ff] dark:bg-sky-950/20'
                  : cell.isSunday
                    ? 'bg-[#fef2f2] dark:bg-rose-950/20'
                    : 'bg-white dark:bg-neutral-900',
                cell.isCurrentMonth
                  ? 'text-neutral-800 dark:text-neutral-200'
                  : 'opacity-40',
                canCreate && selectedUserId
                  ? 'cursor-pointer hover:bg-neutral-100/60 dark:hover:bg-neutral-800/60'
                  : '',
              ]"
              @click="
                canCreate && selectedUserId ? openCreate(cell.date) : undefined
              "
            >
              <!-- Cell Day Header -->
              <div class="flex items-center justify-between pb-1">
                <span
                  class="inline-flex size-6 items-center justify-center rounded-full text-xs font-medium"
                  :class="
                    cell.isToday
                      ? 'bg-primary font-bold text-white shadow-xs'
                      : 'text-neutral-700 dark:text-neutral-300'
                  "
                >
                  {{ cell.dayNumber }}
                </span>

                <button
                  v-if="
                    !shiftByDate.has(cell.date) && canCreate && selectedUserId
                  "
                  class="hidden size-5 items-center justify-center rounded text-neutral-400 hover:bg-neutral-200 hover:text-neutral-700 group-hover:inline-flex dark:hover:bg-neutral-700 dark:hover:text-neutral-200"
                  type="button"
                  @click.stop="openCreate(cell.date)"
                >
                  <IconifyIcon class="size-3.5" icon="lucide:plus" />
                </button>
              </div>

              <!-- Shift Event Pill -->
              <div v-if="shiftByDate.get(cell.date)" class="mt-auto">
                <div
                  class="flex flex-col gap-0.5 rounded-md bg-primary px-2 py-1 text-left text-white shadow-xs transition hover:brightness-95"
                  @click.stop="openDetail(shiftByDate.get(cell.date)!)"
                >
                  <span
                    class="block truncate text-[11px] leading-tight opacity-90"
                  >
                    {{
                      formatShiftTime(
                        shiftByDate.get(cell.date)!.start_at,
                        preferences.app.timezone,
                      )
                    }}
                    –
                    {{
                      formatShiftTime(
                        shiftByDate.get(cell.date)!.end_at,
                        preferences.app.timezone,
                      )
                    }}{{
                      dayjs(shiftByDate.get(cell.date)!.end_at)
                        .tz(preferences.app.timezone)
                        .isAfter(
                          dayjs(shiftByDate.get(cell.date)!.start_at).tz(
                            preferences.app.timezone,
                          ),
                          'day',
                        )
                        ? ` (${$t('workUserShifts.form.nextDay')})`
                        : ''
                    }}
                  </span>
                  <span
                    class="block truncate text-xs font-semibold leading-tight"
                  >
                    {{ shiftByDate.get(cell.date)!.work_shift.name }}
                  </span>
                  <span
                    v-if="shiftByDate.get(cell.date)!.work_periods.length > 1"
                    class="block truncate text-[10px] opacity-80"
                  >
                    {{
                      $t('workShifts.labels.periodCount', {
                        count: shiftByDate.get(cell.date)!.work_periods.length,
                      })
                    }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- Shift Config Modal -->
    <ShiftConfigModal
      v-model:open="configOpen"
      :shifts="catalog"
      :root-organization-id="selectedRootOrganizationId"
      :can-create="canCreate"
      :can-update="canUpdate"
      :can-delete="canDelete"
      @refresh="refreshCatalogAndAssignments"
    />

    <!-- Create Shift Modal -->
    <Modal
      v-model:open="createOpen"
      :title="$t('workUserShifts.dialog.createTitle')"
      :width="640"
    >
      <div class="grid gap-5 pt-1">
        <p class="-mt-2 text-xs text-muted-foreground">
          {{ $t('workUserShifts.dialog.createDescription') }}
        </p>

        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-foreground">
            {{ $t('workUserShifts.form.users') }}
          </label>
          <UserTreeSelect
            v-model="formUserIds"
            class="w-full"
            :loading="usersLoading"
            :load-error="usersLoadError"
            :users="assignableUsers"
            :placeholder="$t('workUserShifts.form.usersPlaceholder')"
            test-id="shift-form-user-tree-select"
          />
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-foreground">
            {{ $t('workShifts.fields.shift') }}
          </label>
          <div
            v-if="catalogLoading"
            class="flex items-center gap-2 py-1.5 text-xs text-muted-foreground"
          >
            <Spin size="small" />
            <span>{{ $t('workShifts.states.loading') }}</span>
          </div>
          <div
            v-else-if="catalogError"
            class="flex items-center justify-between rounded border border-destructive/20 bg-destructive/10 p-2 text-xs text-destructive"
          >
            <span>{{ $t('workShifts.states.loadFailed') }}</span>
            <Button size="small" type="link" @click="loadCatalog">
              {{ $t('workShifts.actions.retry') }}
            </Button>
          </div>
          <div
            v-else-if="catalog.length === 0"
            class="flex items-center justify-between rounded border border-amber-200 bg-amber-50 p-2 text-xs text-amber-800 dark:border-amber-900 dark:bg-amber-950 dark:text-amber-200"
          >
            <span>{{ $t('workShifts.states.emptyOrganization') }}</span>
            <Button
              v-if="canCreate || canUpdate"
              size="small"
              type="link"
              @click="
                createOpen = false;
                configOpen = true;
              "
            >
              {{ $t('workShifts.actions.addShift') }}
            </Button>
          </div>
          <Select
            v-else
            v-model:value="formWorkShiftId"
            class="w-full"
            :options="shiftTypeOptions"
            :placeholder="$t('workShifts.placeholders.shift')"
          />
        </div>

        <div class="grid gap-3 sm:grid-cols-2">
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-foreground">
              {{ $t('workUserShifts.form.dateFrom') }}
            </label>
            <DatePicker
              v-model:value="formDateFrom"
              class="w-full"
              value-format="YYYY-MM-DD"
            />
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-foreground">
              {{ $t('workUserShifts.form.dateTo') }}
            </label>
            <DatePicker
              v-model:value="formDateTo"
              class="w-full"
              value-format="YYYY-MM-DD"
            />
          </div>
        </div>

        <div class="flex flex-col gap-2">
          <div class="flex items-center justify-between gap-2">
            <label class="text-xs font-semibold text-foreground">
              {{ $t('workUserShifts.form.selectWeekdays') }}
            </label>
            <div class="flex items-center gap-1 text-xs">
              <Button
                size="small"
                type="link"
                @click="selectWeekdays([2, 3, 4, 5, 6])"
              >
                {{ $t('workUserShifts.form.presetWeekdays') }}
              </Button>
              <Button
                size="small"
                type="link"
                @click="selectWeekdays([2, 3, 4, 5, 6, 7, 8])"
              >
                {{ $t('workUserShifts.form.presetAllDays') }}
              </Button>
            </div>
          </div>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="day in UI_WEEKDAYS"
              :key="day"
              class="inline-flex cursor-pointer items-center gap-1.5 rounded-md border px-3 py-1.5 text-xs font-medium transition"
              :class="
                formSelectedWeekdays.includes(day)
                  ? 'border-primary bg-primary/10 text-primary'
                  : 'border-neutral-200 bg-background text-neutral-600 hover:border-neutral-300 dark:border-neutral-800 dark:text-neutral-400'
              "
              type="button"
              :aria-pressed="formSelectedWeekdays.includes(day)"
              @click="toggleWeekday(day)"
            >
              <span
                class="flex size-3.5 items-center justify-center rounded border text-[10px]"
                :class="
                  formSelectedWeekdays.includes(day)
                    ? 'border-primary bg-primary text-white'
                    : 'border-neutral-300 dark:border-neutral-600'
                "
              >
                <IconifyIcon
                  v-if="formSelectedWeekdays.includes(day)"
                  class="size-3"
                  icon="lucide:check"
                />
              </span>
              {{ $t(`workUserShifts.weekdays.${day}`) }}
            </button>
          </div>
          <div class="flex items-center gap-2 text-xs text-muted-foreground">
            <span>{{ $t('workUserShifts.form.repeatEvery') }}</span>
            <InputNumber
              v-model:value="repeatEveryWeeks"
              size="small"
              class="w-16"
              :min="1"
              :max="52"
            />
            <span>{{ $t('workUserShifts.form.weeks') }}</span>
          </div>
        </div>

        <p
          class="flex items-start gap-1.5 rounded-md bg-muted/60 px-2.5 py-2 text-xs text-muted-foreground"
        >
          <IconifyIcon class="mt-0.5 size-3.5 shrink-0" icon="lucide:info" />
          {{ $t('workUserShifts.form.overwrite') }}
        </p>
      </div>

      <template #footer>
        <div class="flex flex-wrap items-center justify-between gap-2">
          <span class="text-xs font-medium text-muted-foreground">
            {{
              $t('workUserShifts.summary.users', {
                count: formSummary.selectedUsers,
              })
            }}
            ·
            {{
              $t('workUserShifts.summary.days', {
                count: formSummary.includedDays,
              })
            }}
            ·
            {{
              $t('workUserShifts.summary.assignments', {
                count: formSummary.totalAssignments,
              })
            }}
          </span>
          <div class="flex items-center gap-2">
            <Button @click="createOpen = false">
              {{ $t('workUserShifts.actions.cancel') }}
            </Button>
            <Button
              :disabled="!canSubmitForm"
              :loading="saving"
              type="primary"
              @click="submitCreateRange"
            >
              <template #icon>
                <IconifyIcon class="size-4" icon="lucide:calendar-range" />
              </template>
              {{ $t('workUserShifts.actions.apply') }}
            </Button>
          </div>
        </div>
      </template>
    </Modal>

    <!-- Detail Shift Modal -->
    <Modal
      v-model:open="detailOpen"
      :title="$t('workUserShifts.dialog.detailTitle')"
      :width="460"
      @cancel="selectedShiftId = null"
    >
      <div v-if="selectedShift" class="grid gap-4 pt-1">
        <div class="-mt-2 flex items-center justify-between gap-2">
          <p class="m-0 text-sm font-semibold text-foreground">
            {{ selectedShift.user.name }}
          </p>
          <span
            class="rounded-md bg-muted px-2 py-0.5 text-xs tabular-nums text-muted-foreground"
          >
            {{ dayjs(selectedShift.work_date).format('DD/MM/YYYY') }}
          </span>
        </div>

        <section class="rounded-lg border border-border bg-card p-3">
          <p class="m-0 text-sm font-semibold text-foreground">
            {{ selectedShift.work_shift.name }}
          </p>
          <ShiftTimeline class="mt-3" :periods="detailPeriods" />
          <ul class="m-0 mt-3 flex list-none flex-wrap gap-2 p-0">
            <li
              v-for="(period, index) in detailPeriods"
              :key="index"
              class="flex items-center gap-2 rounded-md bg-muted/60 px-2.5 py-1.5 text-xs"
            >
              <span class="font-medium tabular-nums text-foreground">
                {{
                  formatDetailTime(period.start_time, period.start_day_offset)
                }}
                –
                {{ formatDetailTime(period.end_time, period.end_day_offset) }}
              </span>
              <span class="text-muted-foreground">
                {{ formatDetailHours(period.hours) }}
              </span>
            </li>
          </ul>
        </section>

        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-foreground">
            {{ $t('workUserShifts.form.changeShift') }}
          </label>
          <Select
            :disabled="!canUpdate"
            :loading="saving"
            :options="shiftTypeOptions"
            :value="selectedShift.work_shift_id"
            @update:value="onDetailShiftTypeChange"
          />
        </div>
      </div>

      <template #footer>
        <div class="flex items-center justify-between gap-2">
          <Button
            v-if="canDelete"
            danger
            :loading="deleting"
            @click="removeSelectedShift"
          >
            <template #icon>
              <IconifyIcon class="size-4" icon="lucide:trash-2" />
            </template>
            {{ $t('workUserShifts.actions.deleteOne') }}
          </Button>
          <span v-else></span>
          <Button @click="detailOpen = false">
            {{ $t('workUserShifts.actions.close') }}
          </Button>
        </div>
      </template>
    </Modal>
  </Page>
</template>

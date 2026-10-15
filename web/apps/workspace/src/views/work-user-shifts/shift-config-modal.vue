<script setup lang="ts">
import type { WorkShift, WorkShiftPeriod } from '#/api/work-shifts';

import { computed, ref, watch } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';
import { preferences } from '@vben/preferences';

import { Button, Empty, notification, Popconfirm } from 'ant-design-vue';

import { deleteWorkShift } from '#/api/work-shifts';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import ShiftTimeline from './shift-timeline.vue';
import WorkShiftFormModal from './work-shift-form-modal.vue';

const props = defineProps<{
  canCreate: boolean;
  canDelete: boolean;
  canUpdate: boolean;
  open: boolean;
  rootOrganizationId: null | string;
  shifts: WorkShift[];
}>();

const emit = defineEmits<{
  refresh: [];
  'update:open': [value: boolean];
}>();

const modalTitle = computed(() => $t('workShifts.titles.catalog'));

const [Modal, modalApi] = useVbenModal({
  class: 'w-[720px] max-w-[calc(100vw-1rem)]',
  draggable: true,
  footer: true,
  fullscreenButton: true,
  showCancelButton: false,
  showConfirmButton: false,
  title: modalTitle.value,
  onOpenChange: (open) => {
    emit('update:open', open);
  },
});

watch(modalTitle, (title) => modalApi.setState({ title }));

const isFormOpen = ref(false);
const editingShift = ref<null | WorkShift>(null);
const deletingId = ref<null | string>(null);

watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      modalApi.open();
    } else {
      modalApi.close();
      isFormOpen.value = false;
      editingShift.value = null;
    }
  },
  { immediate: true },
);

function parseSeconds(time: string): number {
  const parts = time.split(':');
  const h = Number(parts[0] || 0);
  const m = Number(parts[1] || 0);
  const s = Number(parts[2] || 0);
  return h * 3600 + m * 60 + s;
}

function getShiftTotalHours(shift: { periods: WorkShift['periods'] }): number {
  let total = 0;
  for (const p of shift.periods) {
    const start = p.start_day_offset * 86_400 + parseSeconds(p.start_time);
    const end = p.end_day_offset * 86_400 + parseSeconds(p.end_time);
    if (end > start) {
      total += (end - start) / 3600;
    }
  }
  return total;
}

function formatHours(hours: number): string {
  return $t('workShifts.labels.hours', {
    count: new Intl.NumberFormat(preferences.app.locale, {
      maximumFractionDigits: 1,
    }).format(hours),
  });
}

function periodMinutes(period: WorkShiftPeriod): [number, number] {
  return [
    period.start_day_offset * 1440 + parseSeconds(period.start_time) / 60,
    period.end_day_offset * 1440 + parseSeconds(period.end_time) / 60,
  ];
}

function periodHours(period: WorkShiftPeriod): number {
  const [start, end] = periodMinutes(period);
  return Math.max(0, (end - start) / 60);
}

const hasNextDayPeriod = computed(() =>
  props.shifts.some((shift) =>
    shift.periods.some(
      (period) => period.start_day_offset > 0 || period.end_day_offset > 0,
    ),
  ),
);

function openCreateForm(): void {
  editingShift.value = null;
  isFormOpen.value = true;
}
function openEditForm(shift: WorkShift): void {
  editingShift.value = shift;
  isFormOpen.value = true;
}
watch(
  () => props.rootOrganizationId,
  () => {
    isFormOpen.value = false;
    editingShift.value = null;
  },
);

async function handleDelete(shiftId: string): Promise<void> {
  deletingId.value = shiftId;
  try {
    await deleteWorkShift(shiftId);
    notification.success({ message: $t('workShifts.messages.deleted') });
    emit('refresh');
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('workShifts.messages.deleteFailed'),
      'Failed to delete work shift:',
    );
  } finally {
    deletingId.value = null;
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
    <div class="space-y-3 px-1 py-2">
      <Empty
        v-if="props.shifts.length === 0"
        :description="$t('workShifts.states.empty')"
      />

      <article
        v-for="shift in props.shifts"
        :key="shift.id"
        class="rounded-xl border border-border bg-card p-4 transition-colors hover:border-primary/50"
      >
        <header
          class="flex flex-wrap items-start justify-between gap-x-3 gap-y-1"
        >
          <div class="min-w-0">
            <h3 class="truncate text-sm font-semibold text-foreground">
              {{ shift.name }}
            </h3>
            <p class="mt-0.5 text-xs text-muted-foreground">
              {{
                $t('workShifts.labels.totalHours', {
                  hours: formatHours(getShiftTotalHours(shift)),
                })
              }}
              ·
              {{
                $t('workShifts.labels.periodCount', {
                  count: shift.periods.length,
                })
              }}
            </p>
          </div>
          <div
            v-if="props.canUpdate || props.canDelete"
            class="-mr-2 flex items-center"
          >
            <Button
              v-if="props.canUpdate"
              size="small"
              type="text"
              @click="openEditForm(shift)"
            >
              <IconifyIcon class="mr-1 inline size-3.5" icon="lucide:pencil" />
              {{ $t('workShifts.actions.edit') }}
            </Button>
            <Popconfirm
              v-if="props.canDelete"
              :title="$t('workShifts.deleteConfirm.title')"
              :description="$t('workShifts.deleteConfirm.description')"
              :ok-text="$t('workShifts.actions.delete')"
              :cancel-text="$t('workShifts.actions.cancel')"
              ok-type="danger"
              @confirm="handleDelete(shift.id)"
            >
              <Button
                size="small"
                type="text"
                danger
                :loading="deletingId === shift.id"
              >
                <IconifyIcon
                  class="mr-1 inline size-3.5"
                  icon="lucide:trash-2"
                />
                {{ $t('workShifts.actions.delete') }}
              </Button>
            </Popconfirm>
          </div>
        </header>

        <ShiftTimeline class="mt-3" :periods="shift.periods" />

        <ul class="mt-3 flex flex-wrap gap-2">
          <li
            v-for="(period, index) in shift.periods"
            :key="period.id ?? index"
            class="flex items-center gap-2 rounded-md bg-muted/60 px-2.5 py-1.5 text-xs"
          >
            <span class="tabular-nums font-medium text-foreground">
              {{ period.start_time.slice(0, 5)
              }}<sup
                v-if="period.start_day_offset > 0"
                class="ml-0.5 font-semibold text-warning"
                :title="$t('workShifts.labels.nextDay')"
                >+{{ period.start_day_offset }}</sup
              >
              –
              {{ period.end_time.slice(0, 5)
              }}<sup
                v-if="period.end_day_offset > 0"
                class="ml-0.5 font-semibold text-warning"
                :title="$t('workShifts.labels.nextDay')"
                >+{{ period.end_day_offset }}</sup
              >
            </span>
            <span class="text-muted-foreground">
              {{ formatHours(periodHours(period)) }}
            </span>
          </li>
        </ul>
      </article>

      <p v-if="hasNextDayPeriod" class="text-[11px] text-muted-foreground">
        <span class="font-semibold text-warning">+1</span>
        = {{ $t('workShifts.labels.nextDayHint') }}
      </p>
    </div>

    <template #footer>
      <div class="flex w-full items-center justify-between gap-2">
        <span class="text-sm text-muted-foreground">
          {{
            $t('workShifts.labels.catalogCount', {
              count: props.shifts.length,
            })
          }}
        </span>
        <div class="flex items-center gap-2">
          <Button @click="emit('update:open', false)">
            {{ $t('workShifts.actions.close') }}
          </Button>
          <Button
            v-if="props.canCreate"
            type="primary"
            data-testid="add-shift-btn"
            @click="openCreateForm"
          >
            <IconifyIcon class="mr-1 inline size-4" icon="lucide:plus" />
            {{ $t('workShifts.actions.create') }}
          </Button>
        </div>
      </div>
    </template>
  </Modal>
  <WorkShiftFormModal
    v-if="isFormOpen"
    v-model:open="isFormOpen"
    :can-create="props.canCreate"
    :can-update="props.canUpdate"
    :root-organization-id="props.rootOrganizationId"
    :shift="editingShift"
    @saved="emit('refresh')"
  />
</template>

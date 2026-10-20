<script setup lang="ts">
import type { FundAdjustment } from '../types';

import { computed, ref } from 'vue';

import { Page } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import {
  Badge,
  Button,
  Table,
  Tooltip,
} from 'ant-design-vue';

import { $t } from '#/locales';
import {
  MAX_SIDEBAR_WIDTH,
  MIN_SIDEBAR_WIDTH,
  useResizableFilterSidebar,
} from '#/shared/filter-sidebar/use-resizable-filter-sidebar';

import { useCashFund } from '../store';
import AdjustmentApprovalModal from './components/AdjustmentApprovalModal.vue';
import AdjustmentDetailModal from './components/AdjustmentDetailModal.vue';
import AdjustmentFormModal from './components/AdjustmentFormModal.vue';
import AdjustmentsFilterPanel from './components/AdjustmentsFilterPanel.vue';

const { adjustments } = useCashFund();

const filters = ref({
  keyword: '',
  status: 'all',
});

const appliedFilters = ref({ ...filters.value });
const filtersOpen = ref(false);

const content = ref<HTMLElement | null>(null);
const filterTrigger = ref<null | { $el: HTMLElement }>(null);

const {
  compact,
  resize,
  resizeWithKeyboard,
  startResize,
  stopResize,
  width: filterWidth,
} = useResizableFilterSidebar({
  content,
  open: filtersOpen,
  trigger: filterTrigger,
});

const isCreateModalOpen = ref(false);
const isDetailModalOpen = ref(false);
const isApprovalModalOpen = ref(false);
const selectedAdjustment = ref<FundAdjustment | null>(null);

const activeFilterCount = computed(() => {
  let count = 0;
  if (appliedFilters.value.keyword.trim()) count++;
  if (appliedFilters.value.status !== 'all') count++;
  return count;
});

function applyFilters() {
  appliedFilters.value = { ...filters.value };
  filtersOpen.value = false;
}

function resetFilters() {
  filters.value = {
    keyword: '',
    status: 'all',
  };
  appliedFilters.value = { ...filters.value };
}

function closeFilters() {
  filters.value = { ...appliedFilters.value };
  filtersOpen.value = false;
}

const filteredAdjustments = computed(() => {
  return adjustments.value.filter((adj) => {
    if (appliedFilters.value.status !== 'all' && adj.status !== appliedFilters.value.status) {
      return false;
    }

    if (appliedFilters.value.keyword.trim()) {
      const q = appliedFilters.value.keyword.toLowerCase().trim();
      const matchCode = adj.code.toLowerCase().includes(q);
      const matchFrom = adj.fromSourceName.toLowerCase().includes(q);
      const matchTo = adj.toSourceName.toLowerCase().includes(q);
      const matchReason = adj.reason.toLowerCase().includes(q);
      if (!matchCode && !matchFrom && !matchTo && !matchReason) return false;
    }

    return true;
  });
});

const totalCount = computed(() => adjustments.value.length);
const pendingCount = computed(
  () => adjustments.value.filter((a) => a.status.startsWith('pending_')).length,
);
const completedCount = computed(
  () => adjustments.value.filter((a) => a.status === 'completed').length,
);
const totalAmount = computed(() =>
  adjustments.value.reduce((sum, a) => sum + a.amount, 0),
);

function openDetail(record: FundAdjustment) {
  selectedAdjustment.value = record;
  isDetailModalOpen.value = true;
}

function openApproval(record: FundAdjustment) {
  selectedAdjustment.value = record;
  isApprovalModalOpen.value = true;
}

function getStatusBadge(status: string) {
  switch (status) {
    case 'completed': {
      return { status: 'success', text: 'Hoàn thành' };
    }
    case 'rejected': {
      return { status: 'error', text: 'Từ chối' };
    }
    case 'return_edit': {
      return { status: 'warning', text: 'Yêu cầu sửa' };
    }
    default: {
      return { status: 'processing', text: 'Chờ phê duyệt' };
    }
  }
}

const columns = [
  {
    title: $t('cashFund.adjustments.code'),
    dataIndex: 'code',
    key: 'code',
    width: 145,
    fixed: 'left' as const,
  },
  {
    title: $t('cashFund.adjustments.fromSource'),
    dataIndex: 'fromSourceName',
    key: 'fromSourceName',
    width: 200,
  },
  {
    title: $t('cashFund.adjustments.toSource'),
    dataIndex: 'toSourceName',
    key: 'toSourceName',
    width: 200,
  },
  {
    title: $t('cashFund.adjustments.amount'),
    dataIndex: 'amount',
    key: 'amount',
    width: 155,
    align: 'right' as const,
  },
  {
    title: $t('cashFund.adjustments.effectiveDate'),
    dataIndex: 'effectiveDate',
    key: 'effectiveDate',
    width: 140,
  },
  {
    title: 'Lý do điều chuyển',
    dataIndex: 'reason',
    key: 'reason',
    ellipsis: true,
  },
  {
    title: $t('cashFund.adjustments.status'),
    dataIndex: 'status',
    key: 'status',
    width: 150,
  },
  {
    title: $t('cashFund.adjustments.actions'),
    key: 'actions',
    width: 110,
    fixed: 'right' as const,
  },
];
</script>

<template>
  <Page auto-content-height content-class="overflow-hidden p-4 md:p-6">
    <div
      ref="content"
      class="flex h-full min-h-0 min-w-0 flex-1 items-stretch"
      :class="compact ? 'flex-col gap-4 overflow-y-auto' : 'flex-row'"
    >
      <!-- Left Resizable Filter Sidebar -->
      <aside
        v-if="!compact || filtersOpen"
        id="adjustments-filter-panel"
        class="flex h-full min-h-0 shrink-0 flex-col overflow-hidden rounded-lg border border-border bg-background shadow-xs"
        :class="compact ? 'max-h-[55%] w-full' : ''"
        :style="compact ? undefined : { width: `${filterWidth}px` }"
      >
        <AdjustmentsFilterPanel
          v-model:filters="filters"
          :active-filter-count="activeFilterCount"
          :closable="compact"
          @apply="applyFilters"
          @close="closeFilters"
          @reset="resetFilters"
        />
      </aside>

      <!-- Resizer separator -->
      <div
        v-if="!compact"
        aria-orientation="vertical"
        aria-label="Kéo để điều chỉnh kích thước bộ lọc"
        :aria-valuemax="MAX_SIDEBAR_WIDTH"
        :aria-valuemin="MIN_SIDEBAR_WIDTH"
        :aria-valuenow="filterWidth"
        class="group flex w-2 shrink-0 cursor-col-resize touch-none items-center justify-center outline-none focus-visible:ring-2 focus-visible:ring-primary"
        role="separator"
        tabindex="0"
        @keydown="resizeWithKeyboard"
        @pointercancel="stopResize"
        @pointerdown="startResize"
        @pointermove="resize"
        @pointerup="stopResize"
      >
        <span
          class="h-10 w-1 rounded-full bg-border transition-colors group-hover:bg-primary group-focus-visible:bg-primary"
        />
      </div>

      <!-- Right Main Content Area -->
      <div
        class="flex h-full min-h-0 min-w-0 flex-1 flex-col gap-4 overflow-y-auto rounded-lg border border-border bg-background p-4 shadow-xs"
      >
        <!-- Header -->
        <div class="flex flex-wrap items-center justify-between gap-4">
          <div>
            <h1 class="text-xl font-bold tracking-tight text-foreground md:text-2xl m-0">
              {{ $t('cashFund.adjustments.title') }}
            </h1>
            <p class="text-xs text-muted-foreground mt-1 mb-0">
              {{ $t('cashFund.adjustments.description') }}
            </p>
          </div>

          <div class="flex items-center gap-2">
            <Badge v-if="compact" :count="activeFilterCount">
              <Button
                ref="filterTrigger"
                :aria-expanded="filtersOpen"
                aria-controls="adjustments-filter-panel"
                @click="filtersOpen = true"
              >
                <template #icon>
                  <IconifyIcon icon="lucide:list-filter" class="size-4" />
                </template>
                Bộ lọc
              </Button>
            </Badge>

            <Button type="primary" size="middle" @click="isCreateModalOpen = true">
              <template #icon>
                <IconifyIcon icon="lucide:plus" class="size-4" />
              </template>
              {{ $t('cashFund.adjustments.create') }}
            </Button>
          </div>
        </div>

        <!-- KPI Summary Cards -->
        <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Tổng yêu cầu</span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ totalCount }}</div>
            <span class="text-[10px] text-muted-foreground">Hồ sơ điều chỉnh nội bộ</span>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Chờ phê duyệt</span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ pendingCount }}</div>
            <span class="text-[10px] text-muted-foreground">Đang trong luồng duyệt</span>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Đã hoàn thành</span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ completedCount }}</div>
            <span class="text-[10px] text-muted-foreground">Đã chuyển số dư thành công</span>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Tổng giá trị điều chuyển</span>
            <div class="mt-1 text-xl font-semibold text-foreground">
              {{ totalAmount.toLocaleString() }} <span class="text-[11px] font-normal text-muted-foreground">VND</span>
            </div>
            <span class="text-[10px] text-muted-foreground">Tổng quỹ không đổi</span>
          </div>
        </div>

        <!-- Table -->
        <div class="rounded-lg border border-border bg-card shadow-xs overflow-hidden">
          <Table
            :data-source="filteredAdjustments"
            :columns="columns"
            :scroll="{ x: 1200 }"
            :pagination="{ pageSize: 10, showSizeChanger: true }"
            row-key="id"
            size="middle"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'code'">
                <span
                  class="font-mono font-bold text-primary cursor-pointer hover:underline"
                  @click="openDetail(record as FundAdjustment)"
                >
                  {{ record.code }}
                </span>
              </template>

              <template v-else-if="column.key === 'fromSourceName'">
                <div class="flex flex-col">
                  <span class="font-medium text-foreground text-xs">{{ record.fromSourceName }}</span>
                  <span class="text-[11px] text-muted-foreground">{{ record.fromCompany }}</span>
                </div>
              </template>

              <template v-else-if="column.key === 'toSourceName'">
                <div class="flex flex-col">
                  <span class="font-medium text-foreground text-xs">{{ record.toSourceName }}</span>
                  <span class="text-[11px] text-muted-foreground">{{ record.toCompany }}</span>
                </div>
              </template>

              <template v-else-if="column.key === 'amount'">
                <span class="font-bold text-sm text-foreground">
                  {{ record.amount.toLocaleString() }}
                  <span class="text-xs font-normal text-muted-foreground">{{ record.currency }}</span>
                </span>
              </template>

              <template v-else-if="column.key === 'status'">
                <div class="flex flex-col gap-0.5">
                  <Badge
                    :status="getStatusBadge(record.status).status as any"
                    :text="getStatusBadge(record.status).text"
                  />
                  <span class="text-[11px] text-muted-foreground">
                    {{ record.currentApprover }}
                  </span>
                </div>
              </template>

              <template v-else-if="column.key === 'actions'">
                <div class="flex items-center justify-center gap-1">
                  <!-- Action 1: View Details -->
                  <Tooltip title="Xem chi tiết điều chỉnh">
                    <Button
                      type="text"
                      size="small"
                      class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground hover:text-primary"
                      @click="openDetail(record as FundAdjustment)"
                    >
                      <template #icon>
                        <IconifyIcon icon="lucide:eye" class="size-4" />
                      </template>
                    </Button>
                  </Tooltip>

                  <!-- Action 2: Approve Adjustment (disabled if already completed/rejected) -->
                  <Tooltip
                    :title="
                      record.status.startsWith('pending_')
                        ? 'Phê duyệt điều chỉnh'
                        : record.status === 'completed'
                          ? 'Điều chuyển đã thực hiện hoàn tất'
                          : 'Yêu cầu đã kết thúc'
                    "
                  >
                    <Button
                      type="text"
                      size="small"
                      :disabled="!record.status.startsWith('pending_')"
                      class="inline-flex size-7 items-center justify-center p-0"
                      :class="
                        record.status.startsWith('pending_')
                          ? 'text-primary hover:text-primary'
                          : 'text-muted-foreground/30'
                      "
                      @click="openApproval(record as FundAdjustment)"
                    >
                      <template #icon>
                        <IconifyIcon icon="lucide:check-circle-2" class="size-4" />
                      </template>
                    </Button>
                  </Tooltip>
                </div>
              </template>
            </template>
          </Table>
        </div>
      </div>
    </div>

    <!-- Modals -->
    <AdjustmentFormModal
      v-model:open="isCreateModalOpen"
    />

    <AdjustmentDetailModal
      v-model:open="isDetailModalOpen"
      :adjustment="selectedAdjustment"
    />

    <AdjustmentApprovalModal
      v-model:open="isApprovalModalOpen"
      :adjustment="selectedAdjustment"
    />
  </Page>
</template>

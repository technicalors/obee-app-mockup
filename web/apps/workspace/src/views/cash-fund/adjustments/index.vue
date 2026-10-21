<script setup lang="ts">
import type { FundAdjustment } from '../types';

import { computed, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Badge,
  Button,
  Table,
  Tag,
  Tooltip,
} from 'ant-design-vue';

import { $t } from '#/locales';
import {
  MAX_SIDEBAR_WIDTH,
  MIN_SIDEBAR_WIDTH,
  useResizableFilterSidebar,
} from '#/shared/filter-sidebar/use-resizable-filter-sidebar';
import { ResourceListPage } from '#/shared/resource-table';

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

function openDetail(record: FundAdjustment) {
  selectedAdjustment.value = record;
  isDetailModalOpen.value = true;
}

function openApproval(record: FundAdjustment) {
  selectedAdjustment.value = record;
  isApprovalModalOpen.value = true;
}

function getStatusTag(status: string) {
  switch (status) {
    case 'completed': {
      return { color: 'success', text: 'Hoàn thành' };
    }
    case 'rejected': {
      return { color: 'error', text: 'Từ chối' };
    }
    case 'return_edit': {
      return { color: 'warning', text: 'Yêu cầu sửa' };
    }
    default: {
      return { color: 'processing', text: 'Chờ phê duyệt' };
    }
  }
}

const columns = [
  {
    title: 'STT',
    key: 'sequence',
    width: 55,
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
  },
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
    width: 180,
  },
  {
    title: $t('cashFund.adjustments.toSource'),
    dataIndex: 'toSourceName',
    key: 'toSourceName',
    width: 180,
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
    width: 130,
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
    width: 140,
  },
  {
    title: $t('cashFund.adjustments.actions'),
    key: 'actions',
    width: 100,
    align: 'center' as const,
    fixed: 'right' as const,
  },
];
</script>

<template>
  <ResourceListPage>
    <div
      ref="content"
      class="flex h-full min-h-0 min-w-0 flex-1 items-stretch"
      :class="compact ? 'flex-col gap-4 overflow-y-auto' : 'flex-row'"
    >
      <!-- Left Resizable Filter Sidebar -->
      <aside
        v-if="!compact || filtersOpen"
        id="adjustments-filter-panel"
        class="flex h-full min-h-0 shrink-0 flex-col overflow-hidden rounded border border-border bg-background"
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

      <!-- Main Table Container (matching Masterdata Users Grid) -->
      <div
        class="flex h-full min-h-0 min-w-0 flex-1 flex-col overflow-hidden rounded border border-border bg-background"
      >
        <!-- Table Toolbar matching Masterdata Users -->
        <div class="flex shrink-0 items-center justify-between border-b border-border px-4 py-3">
          <div class="flex min-w-0 flex-col gap-0.5">
            <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
              {{ $t('cashFund.adjustments.title') }}
            </h2>
            <p class="m-0 text-xs text-muted-foreground">
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
                  <IconifyIcon aria-hidden="true" icon="lucide:list-filter" />
                </template>
                Bộ lọc
              </Button>
            </Badge>

            <Button type="primary" @click="isCreateModalOpen = true">
              <template #icon>
                <IconifyIcon aria-hidden="true" icon="lucide:plus" class="size-4" />
              </template>
              {{ $t('cashFund.adjustments.create') }}
            </Button>
          </div>
        </div>

        <!-- Table matching Masterdata Users Grid -->
        <div class="min-h-0 flex-1 overflow-auto">
          <Table
            :data-source="filteredAdjustments"
            :columns="columns"
            :scroll="{ x: 1200, y: 'calc(100vh - 275px)' }"
            :pagination="{
              pageSize: 10,
              showSizeChanger: true,
              pageSizeOptions: ['10', '20', '30', '50'],
              showTotal: (total: number) => `Tổng ${total} bản ghi`,
              class: '!px-4 !py-2.5 !m-0 border-t border-border',
            }"
            row-key="id"
            size="small"
            bordered
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
                <span class="font-semibold text-foreground text-xs">
                  {{ record.amount.toLocaleString() }}
                  <span class="text-[11px] font-normal text-muted-foreground">{{ record.currency }}</span>
                </span>
              </template>

              <template v-else-if="column.key === 'status'">
                <Tag :color="getStatusTag(record.status).color" class="m-0 font-normal">
                  {{ getStatusTag(record.status).text }}
                </Tag>
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
  </ResourceListPage>
</template>

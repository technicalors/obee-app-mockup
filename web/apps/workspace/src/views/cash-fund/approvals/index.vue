<script setup lang="ts">
import type { Proposal, ProposalType } from '../types';

import { computed, ref } from 'vue';

import { Page } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import {
  Badge,
  Button,
  Progress,
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

import { useCashFund } from '../store';
import ProposalDetailModal from '../proposals/components/ProposalDetailModal.vue';
import ApprovalDetailModal from './components/ApprovalDetailModal.vue';
import ApprovalsFilterPanel from './components/ApprovalsFilterPanel.vue';

const { proposals } = useCashFund();

const filters = ref({
  department: 'all',
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

const isViewModalOpen = ref(false);
const isApprovalModalOpen = ref(false);
const selectedProposal = ref<null | Proposal>(null);

const activeFilterCount = computed(() => {
  let count = 0;
  if (appliedFilters.value.keyword.trim()) count++;
  if (appliedFilters.value.department !== 'all') count++;
  if (appliedFilters.value.status !== 'all') count++;
  return count;
});

function applyFilters() {
  appliedFilters.value = { ...filters.value };
  filtersOpen.value = false;
}

function resetFilters() {
  filters.value = {
    department: 'all',
    keyword: '',
    status: 'all',
  };
  appliedFilters.value = { ...filters.value };
}

function closeFilters() {
  filters.value = { ...appliedFilters.value };
  filtersOpen.value = false;
}

// Proposals that are pending approval
const pendingProposals = computed(() => {
  return proposals.value.filter((p) => {
    const isPending =
      p.status.startsWith('pending_') ||
      p.status === 'voucher_issued' ||
      p.status === 'return_edit';

    if (!isPending) return false;

    if (appliedFilters.value.department !== 'all' && p.department !== appliedFilters.value.department) {
      return false;
    }

    if (appliedFilters.value.status !== 'all' && p.status !== appliedFilters.value.status) {
      return false;
    }

    if (appliedFilters.value.keyword.trim()) {
      const q = appliedFilters.value.keyword.toLowerCase().trim();
      const matchCode = p.code.toLowerCase().includes(q);
      const matchTitle = p.title.toLowerCase().includes(q);
      const matchApplicant = p.applicantName.toLowerCase().includes(q);
      if (!matchCode && !matchTitle && !matchApplicant) return false;
    }

    return true;
  });
});

// STATS-PC metrics
const totalPendingCount = computed(() => pendingProposals.value.length);
const totalPendingValue = computed(() =>
  pendingProposals.value.reduce((sum, p) => sum + p.totalAmount, 0),
);
const departmentsCount = computed(() => {
  const depts = new Set(pendingProposals.value.map((p) => p.department));
  return depts.size;
});
const averageValue = computed(() => {
  if (totalPendingCount.value === 0) return 0;
  return Math.round(totalPendingValue.value / totalPendingCount.value);
});

// Category breakdown for pending
const advanceCount = computed(
  () => pendingProposals.value.filter((p) => p.type === 'advance').length,
);
const paymentCount = computed(
  () => pendingProposals.value.filter((p) => p.type === 'payment').length,
);
const receiptCount = computed(
  () => pendingProposals.value.filter((p) => p.type === 'receipt').length,
);
const settlementCount = computed(
  () => pendingProposals.value.filter((p) => p.type === 'settlement').length,
);

const allDepartments = computed(() => {
  return Array.from(new Set(proposals.value.map((p) => p.department)));
});

function openViewModal(record: Proposal) {
  selectedProposal.value = record;
  isViewModalOpen.value = true;
}

function openProcessModal(record: Proposal) {
  selectedProposal.value = record;
  isApprovalModalOpen.value = true;
}

function getTypeTag(type: ProposalType) {
  switch (type) {
    case 'advance': {
      return { color: '', text: $t('cashFund.proposals.types.advance') };
    }
    case 'payment': {
      return { color: '', text: $t('cashFund.proposals.types.payment') };
    }
    case 'receipt': {
      return { color: '', text: $t('cashFund.proposals.types.receipt') };
    }
    case 'settlement': {
      return { color: '', text: $t('cashFund.proposals.types.settlement') };
    }
    default: {
      return { color: '', text: type };
    }
  }
}

const columns = [
  {
    title: $t('cashFund.proposals.code'),
    dataIndex: 'code',
    key: 'code',
    width: 145,
    fixed: 'left' as const,
  },
  {
    title: $t('cashFund.proposals.type'),
    dataIndex: 'type',
    key: 'type',
    width: 135,
  },
  {
    title: $t('cashFund.proposals.titleCol'),
    dataIndex: 'title',
    key: 'title',
    ellipsis: true,
  },
  {
    title: $t('cashFund.proposals.applicant'),
    dataIndex: 'applicantName',
    key: 'applicantName',
    width: 160,
  },
  {
    title: $t('cashFund.proposals.department'),
    dataIndex: 'department',
    key: 'department',
    width: 190,
  },
  {
    title: $t('cashFund.proposals.totalAmount'),
    dataIndex: 'totalAmount',
    key: 'totalAmount',
    width: 155,
    align: 'right' as const,
  },
  {
    title: 'Bước duyệt hiện tại',
    dataIndex: 'currentApprover',
    key: 'currentApprover',
    width: 190,
  },
  {
    title: $t('cashFund.proposals.actions'),
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
        id="approvals-filter-panel"
        class="flex h-full min-h-0 shrink-0 flex-col overflow-hidden rounded-lg border border-border bg-background shadow-xs"
        :class="compact ? 'max-h-[55%] w-full' : ''"
        :style="compact ? undefined : { width: `${filterWidth}px` }"
      >
        <ApprovalsFilterPanel
          v-model:filters="filters"
          :active-filter-count="activeFilterCount"
          :closable="compact"
          :departments="allDepartments"
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
        <!-- Page Header -->
        <div class="flex flex-wrap items-center justify-between gap-4">
          <div>
            <h1 class="text-xl font-bold tracking-tight text-foreground md:text-2xl m-0">
              {{ $t('cashFund.approvals.title') }}
            </h1>
            <p class="text-xs text-muted-foreground mt-1 mb-0">
              {{ $t('cashFund.approvals.description') }}
            </p>
          </div>

          <div v-if="compact">
            <Badge :count="activeFilterCount">
              <Button
                ref="filterTrigger"
                :aria-expanded="filtersOpen"
                aria-controls="approvals-filter-panel"
                @click="filtersOpen = true"
              >
                <template #icon>
                  <IconifyIcon icon="lucide:list-filter" class="size-4" />
                </template>
                Bộ lọc
              </Button>
            </Badge>
          </div>
        </div>

        <!-- STATS-PC: 4 KPI Cards -->
        <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">
              {{ $t('cashFund.approvals.kpi.pendingTotal') }}
            </span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ totalPendingCount }}</div>
            <span class="text-[10px] text-muted-foreground">Yêu cầu cần duyệt</span>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">
              {{ $t('cashFund.approvals.kpi.pendingValue') }}
            </span>
            <div class="mt-1 text-xl font-semibold text-foreground">
              {{ totalPendingValue.toLocaleString() }} <span class="text-[11px] font-normal">VND</span>
            </div>
            <span class="text-[10px] text-muted-foreground">Tổng dòng tiền</span>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">
              {{ $t('cashFund.approvals.kpi.departmentsCount') }}
            </span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ departmentsCount }}</div>
            <span class="text-[10px] text-muted-foreground">Bộ phận đề xuất</span>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">
              {{ $t('cashFund.approvals.kpi.averageValue') }}
            </span>
            <div class="mt-1 text-xl font-semibold text-foreground">
              {{ averageValue.toLocaleString() }} <span class="text-[11px] font-normal">VND</span>
            </div>
            <span class="text-[10px] text-muted-foreground">Trung bình / yêu cầu</span>
          </div>
        </div>

        <!-- Breakdown Bars -->
        <div class="rounded-lg border border-border bg-card p-3.5 shadow-2xs">
          <div class="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-2">
            Phân bố yêu cầu chờ duyệt theo loại nghiệp vụ
          </div>
          <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
            <div class="rounded border border-border bg-muted/20 p-2">
              <div class="flex items-center justify-between text-xs">
                <span class="font-medium text-foreground">Tạm ứng</span>
                <span class="font-semibold">{{ advanceCount }}</span>
              </div>
              <Progress :percent="totalPendingCount ? Math.round((advanceCount / totalPendingCount) * 100) : 0" size="small" />
            </div>

            <div class="rounded border border-border bg-muted/20 p-2">
              <div class="flex items-center justify-between text-xs">
                <span class="font-medium text-foreground">Thanh toán</span>
                <span class="font-semibold">{{ paymentCount }}</span>
              </div>
              <Progress :percent="totalPendingCount ? Math.round((paymentCount / totalPendingCount) * 100) : 0" size="small" />
            </div>

            <div class="rounded border border-border bg-muted/20 p-2">
              <div class="flex items-center justify-between text-xs">
                <span class="font-medium text-foreground">Thu tiền</span>
                <span class="font-semibold">{{ receiptCount }}</span>
              </div>
              <Progress :percent="totalPendingCount ? Math.round((receiptCount / totalPendingCount) * 100) : 0" size="small" />
            </div>

            <div class="rounded border border-border bg-muted/20 p-2">
              <div class="flex items-center justify-between text-xs">
                <span class="font-medium text-foreground">Hoàn ứng</span>
                <span class="font-semibold">{{ settlementCount }}</span>
              </div>
              <Progress :percent="totalPendingCount ? Math.round((settlementCount / totalPendingCount) * 100) : 0" size="small" />
            </div>
          </div>
        </div>

        <!-- Approvals Table -->
        <div class="rounded-lg border border-border bg-card shadow-xs overflow-hidden">
          <Table
            :data-source="pendingProposals"
            :columns="columns"
            :scroll="{ x: 1200 }"
            :pagination="{ pageSize: 10, showSizeChanger: true }"
            row-key="id"
            size="middle"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'code'">
                <span
                  class="font-mono font-semibold text-primary cursor-pointer hover:underline"
                  @click="openViewModal(record as Proposal)"
                >
                  {{ record.code }}
                </span>
              </template>

              <template v-else-if="column.key === 'type'">
                <Tag>
                  {{ getTypeTag(record.type).text }}
                </Tag>
              </template>

              <template v-else-if="column.key === 'title'">
                <span
                  class="font-medium text-foreground text-sm cursor-pointer hover:text-primary"
                  @click="openViewModal(record as Proposal)"
                >
                  {{ record.title }}
                </span>
              </template>

              <template v-else-if="column.key === 'totalAmount'">
                <span class="font-bold text-foreground">
                  {{ record.totalAmount.toLocaleString() }}
                  <span class="text-xs font-normal text-muted-foreground">{{ record.currency }}</span>
                </span>
              </template>

              <template v-else-if="column.key === 'currentApprover'">
                <div class="flex items-center gap-1.5">
                  <span class="text-xs font-medium text-foreground">
                    {{ record.currentApprover }}
                  </span>
                </div>
              </template>

              <template v-else-if="column.key === 'actions'">
                <div class="flex items-center justify-center gap-1">
                  <!-- Action 1: View Details (purely view/print, no approval, no checkboxes) -->
                  <Tooltip :title="$t('cashFund.proposals.viewDetail')">
                    <Button
                      type="text"
                      size="small"
                      class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground hover:text-primary"
                      @click="openViewModal(record as Proposal)"
                    >
                      <template #icon>
                        <IconifyIcon icon="lucide:eye" class="size-4" />
                      </template>
                    </Button>
                  </Tooltip>

                  <!-- Action 2: Process Approval (disabled if already finished) -->
                  <Tooltip
                    :title="
                      record.status.startsWith('pending_') || record.status === 'voucher_issued'
                        ? 'Xử lý phê duyệt hồ sơ'
                        : 'Hồ sơ đã kết thúc luồng duyệt'
                    "
                  >
                    <Button
                      type="text"
                      size="small"
                      :disabled="!record.status.startsWith('pending_') && record.status !== 'voucher_issued'"
                      class="inline-flex size-7 items-center justify-center p-0"
                      :class="
                        record.status.startsWith('pending_') || record.status === 'voucher_issued'
                          ? 'text-primary hover:text-primary'
                          : 'text-muted-foreground/30'
                      "
                      @click="openProcessModal(record as Proposal)"
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
    <ProposalDetailModal
      v-model:open="isViewModalOpen"
      :proposal="selectedProposal"
    />

    <ApprovalDetailModal
      v-model:open="isApprovalModalOpen"
      :proposal="selectedProposal"
    />
  </Page>
</template>

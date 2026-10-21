<script setup lang="ts">
import type { Proposal, ProposalType } from '../types';

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

    if (appliedFilters.value.status !== 'all') {
      if (appliedFilters.value.status === 'pending') {
        if (!p.status.startsWith('pending_') && p.status !== 'pending') {
          return false;
        }
      } else if (p.status !== appliedFilters.value.status) {
        return false;
      }
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
    title: 'STT',
    key: 'sequence',
    width: 55,
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
  },
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
    title: 'Cấp duyệt hiện tại',
    dataIndex: 'currentApprover',
    key: 'currentApprover',
    width: 180,
  },
  {
    title: $t('cashFund.proposals.actions'),
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
        id="approvals-filter-panel"
        class="flex h-full min-h-0 shrink-0 flex-col overflow-hidden rounded border border-border bg-background"
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

      <!-- Main Table Container (matching Masterdata Users Grid) -->
      <div
        class="flex h-full min-h-0 min-w-0 flex-1 flex-col overflow-hidden rounded border border-border bg-background"
      >
        <!-- Table Toolbar matching Masterdata Users -->
        <div class="flex shrink-0 items-center justify-between border-b border-border px-4 py-3">
          <div class="flex min-w-0 flex-col gap-0.5">
            <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
              {{ $t('cashFund.approvals.title') }}
            </h2>
            <p class="m-0 text-xs text-muted-foreground">
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
                  <IconifyIcon aria-hidden="true" icon="lucide:list-filter" />
                </template>
                Bộ lọc
              </Button>
            </Badge>
          </div>
        </div>

        <!-- Approvals Table matching Masterdata Users Grid -->
        <div class="min-h-0 flex-1 overflow-auto">
          <Table
            :data-source="pendingProposals"
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
                  class="font-medium text-foreground text-xs cursor-pointer hover:text-primary"
                  @click="openViewModal(record as Proposal)"
                >
                  {{ record.title }}
                </span>
              </template>

              <template v-else-if="column.key === 'totalAmount'">
                <span class="font-semibold text-foreground text-xs">
                  {{ record.totalAmount.toLocaleString() }}
                  <span class="text-[11px] font-normal text-muted-foreground">{{ record.currency }}</span>
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
  </ResourceListPage>
</template>

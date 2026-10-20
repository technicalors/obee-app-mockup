<script setup lang="ts">
import type { Proposal, ProposalStatus, ProposalType } from '../types';

import { computed, ref } from 'vue';

import { Page } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import {
  Badge,
  Button,
  message,
  Popconfirm,
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
import ProposalDetailModal from './components/ProposalDetailModal.vue';
import ProposalFormModal from './components/ProposalFormModal.vue';
import ProposalReturnEditModal from './components/ProposalReturnEditModal.vue';
import ProposalsFilterPanel from './components/ProposalsFilterPanel.vue';

const { cancelProposal, proposals } = useCashFund();

const filters = ref({
  keyword: '',
  status: 'all',
  type: 'all',
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
const isReturnEditModalOpen = ref(false);
const selectedProposal = ref<null | Proposal>(null);

const activeFilterCount = computed(() => {
  let count = 0;
  if (appliedFilters.value.keyword.trim()) count++;
  if (appliedFilters.value.type !== 'all') count++;
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
    type: 'all',
  };
  appliedFilters.value = { ...filters.value };
}

function closeFilters() {
  filters.value = { ...appliedFilters.value };
  filtersOpen.value = false;
}

const filteredProposals = computed(() => {
  return proposals.value.filter((p) => {
    if (appliedFilters.value.type !== 'all' && p.type !== appliedFilters.value.type) {
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
      const matchDept = p.department.toLowerCase().includes(q);
      if (!matchCode && !matchTitle && !matchApplicant && !matchDept) {
        return false;
      }
    }
    return true;
  });
});

// Summary KPI metrics
const totalCount = computed(() => proposals.value.length);
const pendingCount = computed(
  () =>
    proposals.value.filter((p) =>
      p.status.startsWith('pending_') || p.status === 'approved' || p.status === 'voucher_issued',
    ).length,
);
const returnEditCount = computed(
  () => proposals.value.filter((p) => p.status === 'return_edit').length,
);
const completedCount = computed(
  () => proposals.value.filter((p) => p.status === 'completed').length,
);

function openDetail(record: Proposal) {
  selectedProposal.value = record;
  isDetailModalOpen.value = true;
}

function openEdit(record: Proposal) {
  selectedProposal.value = record;
  if (record.status === 'return_edit') {
    isReturnEditModalOpen.value = true;
  } else {
    isCreateModalOpen.value = true;
  }
}

function handleCancelProposal(record: Proposal) {
  cancelProposal(record.id);
  message.success(`Đã hủy đề xuất ${record.code}`);
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

function getStatusBadge(status: ProposalStatus) {
  switch (status) {
    case 'completed': {
      return { status: 'success', text: $t('cashFund.proposals.statusLabels.completed') };
    }
    case 'approved': {
      return { status: 'processing', text: $t('cashFund.proposals.statusLabels.approved') };
    }
    case 'voucher_issued': {
      return { status: 'processing', text: $t('cashFund.proposals.statusLabels.voucher_issued') };
    }
    case 'return_edit': {
      return { status: 'warning', text: $t('cashFund.proposals.statusLabels.return_edit') };
    }
    case 'rejected': {
      return { status: 'error', text: $t('cashFund.proposals.statusLabels.rejected') };
    }
    case 'canceled': {
      return { status: 'default', text: $t('cashFund.proposals.statusLabels.canceled') };
    }
    case 'draft': {
      return { status: 'default', text: $t('cashFund.proposals.statusLabels.draft') };
    }
    default: {
      return {
        status: 'processing',
        text: $t(`cashFund.proposals.statusLabels.${status}`) || status,
      };
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
    width: 140,
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
    width: 160,
    align: 'right' as const,
  },
  {
    title: $t('cashFund.proposals.createdAt'),
    dataIndex: 'createdAt',
    key: 'createdAt',
    width: 150,
  },
  {
    title: $t('cashFund.proposals.status'),
    dataIndex: 'status',
    key: 'status',
    width: 160,
  },
  {
    title: $t('cashFund.proposals.actions'),
    key: 'actions',
    width: 130,
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
        id="proposals-filter-panel"
        class="flex h-full min-h-0 shrink-0 flex-col overflow-hidden rounded-lg border border-border bg-background shadow-xs"
        :class="compact ? 'max-h-[55%] w-full' : ''"
        :style="compact ? undefined : { width: `${filterWidth}px` }"
      >
        <ProposalsFilterPanel
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
        <!-- Page Header & Action -->
        <div class="flex flex-wrap items-center justify-between gap-4">
          <div>
            <h1 class="text-xl font-bold tracking-tight text-foreground md:text-2xl m-0">
              {{ $t('cashFund.proposals.title') }}
            </h1>
            <p class="text-xs text-muted-foreground mt-1 mb-0">
              {{ $t('cashFund.proposals.description') }}
            </p>
          </div>

          <div class="flex items-center gap-2">
            <Badge v-if="compact" :count="activeFilterCount">
              <Button
                ref="filterTrigger"
                :aria-expanded="filtersOpen"
                aria-controls="proposals-filter-panel"
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
              {{ $t('cashFund.proposals.createNew') }}
            </Button>
          </div>
        </div>

        <!-- KPI Summary Cards -->
        <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Tổng đề xuất</span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ totalCount }}</div>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Chờ phê duyệt</span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ pendingCount }}</div>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Cần chỉnh sửa</span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ returnEditCount }}</div>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Đã hoàn thành</span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ completedCount }}</div>
          </div>
        </div>

        <!-- Main Proposals Data Table -->
        <div class="rounded-lg border border-border bg-card shadow-xs overflow-hidden">
          <Table
            :data-source="filteredProposals"
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
                  @click="openDetail(record as Proposal)"
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
                <div class="flex flex-col">
                  <span
                    class="font-medium text-foreground text-sm cursor-pointer hover:text-primary"
                    @click="openDetail(record as Proposal)"
                  >
                    {{ record.title }}
                  </span>
                  <span
                    v-if="record.type === 'settlement' && record.advanceProposalId"
                    class="text-xs text-muted-foreground font-mono mt-0.5"
                  >
                    Quyết toán tạm ứng
                  </span>
                </div>
              </template>

              <template v-else-if="column.key === 'totalAmount'">
                <span class="font-semibold text-foreground">
                  {{ record.totalAmount.toLocaleString() }}
                  <span class="text-xs font-normal text-muted-foreground">{{ record.currency }}</span>
                </span>
              </template>

              <template v-else-if="column.key === 'status'">
                <div class="flex flex-col gap-0.5">
                  <Badge
                    :status="getStatusBadge(record.status).status as any"
                    :text="getStatusBadge(record.status).text"
                  />
                  <span
                    v-if="record.currentApprover"
                    class="text-[11px] text-muted-foreground truncate max-w-[140px]"
                    :title="record.currentApprover"
                  >
                    {{ record.currentApprover }}
                  </span>
                </div>
              </template>

              <template v-else-if="column.key === 'actions'">
                <div class="flex items-center justify-center gap-1">
                  <!-- Action 1: View Details -->
                  <Tooltip :title="$t('cashFund.proposals.viewDetail')">
                    <Button
                      type="text"
                      size="small"
                      class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground hover:text-primary"
                      @click="openDetail(record as Proposal)"
                    >
                      <template #icon>
                        <IconifyIcon icon="lucide:eye" class="size-4" />
                      </template>
                    </Button>
                  </Tooltip>

                  <!-- Action 2: Edit (disabled when not draft or return_edit) -->
                  <Tooltip
                    :title="
                      record.status === 'return_edit'
                        ? 'Cập nhật đề xuất bị trả về'
                        : record.status === 'draft'
                          ? 'Chỉnh sửa bản nháp'
                          : 'Chỉ chỉnh sửa khi ở trạng thái Nháp hoặc Yêu cầu sửa'
                    "
                  >
                    <Button
                      type="text"
                      size="small"
                      :disabled="record.status !== 'draft' && record.status !== 'return_edit'"
                      class="inline-flex size-7 items-center justify-center p-0"
                      :class="
                        record.status === 'return_edit'
                          ? 'text-amber-600 hover:text-amber-700'
                          : record.status === 'draft'
                            ? 'text-muted-foreground hover:text-foreground'
                            : 'text-muted-foreground/30'
                      "
                      @click="openEdit(record as Proposal)"
                    >
                      <template #icon>
                        <IconifyIcon icon="lucide:pencil" class="size-4" />
                      </template>
                    </Button>
                  </Tooltip>

                  <!-- Action 3: Cancel (disabled when completed, canceled, rejected) -->
                  <Popconfirm
                    v-if="record.status !== 'completed' && record.status !== 'canceled' && record.status !== 'rejected'"
                    title="Bạn có chắc chắn muốn hủy yêu cầu này?"
                    ok-text="Xác nhận hủy"
                    cancel-text="Đóng"
                    @confirm="handleCancelProposal(record as Proposal)"
                  >
                    <Tooltip title="Hủy đề xuất">
                      <Button
                        type="text"
                        size="small"
                        danger
                        class="inline-flex size-7 items-center justify-center p-0"
                      >
                        <template #icon>
                          <IconifyIcon icon="lucide:trash-2" class="size-4" />
                        </template>
                      </Button>
                    </Tooltip>
                  </Popconfirm>

                  <Tooltip v-else title="Không thể hủy đề xuất đã hoàn tất hoặc đã kết thúc">
                    <Button
                      type="text"
                      size="small"
                      disabled
                      class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground/30"
                    >
                      <template #icon>
                        <IconifyIcon icon="lucide:trash-2" class="size-4" />
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
    <ProposalFormModal
      v-model:open="isCreateModalOpen"
    />

    <ProposalDetailModal
      v-model:open="isDetailModalOpen"
      :proposal="selectedProposal"
    />

    <ProposalReturnEditModal
      v-model:open="isReturnEditModalOpen"
      :proposal="selectedProposal"
    />
  </Page>
</template>

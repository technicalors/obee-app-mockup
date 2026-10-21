<script setup lang="ts">
import type { Proposal, ProposalStatus, ProposalType } from '../types';

import { computed, ref } from 'vue';

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
import { ResourceListPage } from '#/shared/resource-table';

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

function getStatusTag(status: ProposalStatus) {
  switch (status) {
    case 'completed': {
      return { color: 'success', text: $t('cashFund.proposals.statusLabels.completed') };
    }
    case 'approved': {
      return { color: 'processing', text: $t('cashFund.proposals.statusLabels.approved') };
    }
    case 'voucher_issued': {
      return { color: 'cyan', text: $t('cashFund.proposals.statusLabels.voucher_issued') };
    }
    case 'return_edit': {
      return { color: 'warning', text: $t('cashFund.proposals.statusLabels.return_edit') };
    }
    case 'rejected': {
      return { color: 'error', text: $t('cashFund.proposals.statusLabels.rejected') };
    }
    case 'canceled': {
      return { color: 'default', text: $t('cashFund.proposals.statusLabels.canceled') };
    }
    case 'draft': {
      return { color: 'default', text: $t('cashFund.proposals.statusLabels.draft') };
    }
    default: {
      return {
        color: 'processing',
        text: $t(`cashFund.proposals.statusLabels.${status}`) || status,
      };
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
    title: $t('cashFund.proposals.createdAt'),
    dataIndex: 'createdAt',
    key: 'createdAt',
    width: 150,
  },
  {
    title: $t('cashFund.proposals.status'),
    dataIndex: 'status',
    key: 'status',
    width: 150,
  },
  {
    title: $t('cashFund.proposals.actions'),
    key: 'actions',
    width: 110,
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
        id="proposals-filter-panel"
        class="flex h-full min-h-0 shrink-0 flex-col overflow-hidden rounded border border-border bg-background"
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

      <!-- Main Table Container (Theme matching Masterdata Users Grid) -->
      <div
        class="flex h-full min-h-0 min-w-0 flex-1 flex-col overflow-hidden rounded border border-border bg-background"
      >
        <!-- Table Toolbar matching Masterdata Users -->
        <div class="flex shrink-0 items-center justify-between border-b border-border px-4 py-3">
          <div class="flex min-w-0 flex-col gap-0.5">
            <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
              {{ $t('cashFund.proposals.title') }}
            </h2>
            <p class="m-0 text-xs text-muted-foreground">
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
                  <IconifyIcon aria-hidden="true" icon="lucide:list-filter" />
                </template>
                Bộ lọc
              </Button>
            </Badge>

            <Button type="primary" @click="isCreateModalOpen = true">
              <template #icon>
                <IconifyIcon aria-hidden="true" icon="lucide:plus" class="size-4" />
              </template>
              {{ $t('cashFund.proposals.createNew') }}
            </Button>
          </div>
        </div>

        <!-- Table matching Masterdata Users Grid -->
        <div class="min-h-0 flex-1 overflow-auto">
          <Table
            :data-source="filteredProposals"
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
                <span
                  class="font-medium text-foreground text-xs cursor-pointer hover:text-primary"
                  @click="openDetail(record as Proposal)"
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

              <template v-else-if="column.key === 'status'">
                <Tag :color="getStatusTag(record.status).color" class="m-0 font-normal">
                  {{ getStatusTag(record.status).text }}
                </Tag>
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
  </ResourceListPage>
</template>

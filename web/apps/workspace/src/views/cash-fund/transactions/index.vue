<script setup lang="ts">
import type { CashTransaction } from '../types';

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
import TransactionConfirmModal from './components/TransactionConfirmModal.vue';
import TransactionDetailModal from './components/TransactionDetailModal.vue';
import TransactionsFilterPanel from './components/TransactionsFilterPanel.vue';

const { fundSources, transactions } = useCashFund();

const filters = ref({
  keyword: '',
  sourceId: 'all',
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

const isDetailModalOpen = ref(false);
const isConfirmModalOpen = ref(false);
const selectedTransaction = ref<CashTransaction | null>(null);

const activeFilterCount = computed(() => {
  let count = 0;
  if (appliedFilters.value.keyword.trim()) count++;
  if (appliedFilters.value.type !== 'all') count++;
  if (appliedFilters.value.sourceId !== 'all') count++;
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
    sourceId: 'all',
    status: 'all',
    type: 'all',
  };
  appliedFilters.value = { ...filters.value };
}

function closeFilters() {
  filters.value = { ...appliedFilters.value };
  filtersOpen.value = false;
}

const filteredTransactions = computed(() => {
  return transactions.value.filter((tx) => {
    if (appliedFilters.value.type !== 'all' && tx.type !== appliedFilters.value.type) return false;
    if (appliedFilters.value.status !== 'all' && tx.status !== appliedFilters.value.status) return false;
    if (appliedFilters.value.sourceId !== 'all' && tx.sourceId !== appliedFilters.value.sourceId) return false;

    if (appliedFilters.value.keyword.trim()) {
      const q = appliedFilters.value.keyword.toLowerCase().trim();
      const matchCode = tx.code.toLowerCase().includes(q);
      const matchProp = tx.proposalCode.toLowerCase().includes(q);
      const matchCounterpart = tx.counterpartName.toLowerCase().includes(q);
      const matchDesc = tx.description.toLowerCase().includes(q);
      if (!matchCode && !matchProp && !matchCounterpart && !matchDesc) return false;
    }

    return true;
  });
});

function openDetail(record: CashTransaction) {
  selectedTransaction.value = record;
  isDetailModalOpen.value = true;
}

function openConfirm(record: CashTransaction) {
  selectedTransaction.value = record;
  isConfirmModalOpen.value = true;
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
    title: $t('cashFund.transactions.code'),
    dataIndex: 'code',
    key: 'code',
    width: 145,
    fixed: 'left' as const,
  },
  {
    title: $t('cashFund.transactions.refProposal'),
    dataIndex: 'proposalCode',
    key: 'proposalCode',
    width: 145,
  },
  {
    title: $t('cashFund.transactions.type'),
    dataIndex: 'type',
    key: 'type',
    width: 120,
  },
  {
    title: $t('cashFund.transactions.counterpart'),
    dataIndex: 'counterpartName',
    key: 'counterpartName',
    width: 160,
  },
  {
    title: $t('cashFund.transactions.fundSource'),
    dataIndex: 'sourceName',
    key: 'sourceName',
    width: 180,
  },
  {
    title: 'Nội dung diễn giải',
    dataIndex: 'description',
    key: 'description',
    ellipsis: true,
  },
  {
    title: $t('cashFund.transactions.amount'),
    dataIndex: 'amount',
    key: 'amount',
    width: 155,
    align: 'right' as const,
  },
  {
    title: $t('cashFund.transactions.issuedDate'),
    dataIndex: 'issuedDate',
    key: 'issuedDate',
    width: 140,
  },
  {
    title: $t('cashFund.transactions.status'),
    dataIndex: 'status',
    key: 'status',
    width: 130,
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
        id="transactions-filter-panel"
        class="flex h-full min-h-0 shrink-0 flex-col overflow-hidden rounded border border-border bg-background"
        :class="compact ? 'max-h-[55%] w-full' : ''"
        :style="compact ? undefined : { width: `${filterWidth}px` }"
      >
        <TransactionsFilterPanel
          v-model:filters="filters"
          :active-filter-count="activeFilterCount"
          :closable="compact"
          :fund-sources="fundSources"
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
              {{ $t('cashFund.transactions.title') }}
            </h2>
            <p class="m-0 text-xs text-muted-foreground">
              {{ $t('cashFund.transactions.description') }}
            </p>
          </div>

          <div v-if="compact">
            <Badge :count="activeFilterCount">
              <Button
                ref="filterTrigger"
                :aria-expanded="filtersOpen"
                aria-controls="transactions-filter-panel"
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

        <!-- Vouchers Table matching Masterdata Users Grid -->
        <div class="min-h-0 flex-1 overflow-auto">
          <Table
            :data-source="filteredTransactions"
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
                  @click="openDetail(record as CashTransaction)"
                >
                  {{ record.code }}
                </span>
              </template>

              <template v-else-if="column.key === 'proposalCode'">
                <span class="font-mono text-xs text-muted-foreground">
                  {{ record.proposalCode }}
                </span>
              </template>

              <template v-else-if="column.key === 'type'">
                <Tag class="m-0 font-normal">
                  {{ record.type === 'expense' ? 'Phiếu chi' : 'Phiếu thu' }}
                </Tag>
              </template>

              <template v-else-if="column.key === 'amount'">
                <span class="font-semibold text-foreground text-xs">
                  {{ record.amount.toLocaleString() }}
                  <span class="text-[11px] font-normal text-muted-foreground">{{ record.currency }}</span>
                </span>
              </template>

              <template v-else-if="column.key === 'status'">
                <Badge
                  :status="record.status === 'completed' ? 'success' : record.status === 'pending' ? 'processing' : 'default'"
                  :text="record.status === 'completed' ? 'Đã thực hiện' : record.status === 'pending' ? 'Chờ thực hiện' : 'Đã hủy'"
                />
              </template>

              <template v-else-if="column.key === 'actions'">
                <div class="flex items-center justify-center gap-1">
                  <!-- Action 1: View Details -->
                  <Tooltip title="Xem chi tiết phiếu">
                    <Button
                      type="text"
                      size="small"
                      class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground hover:text-primary"
                      @click="openDetail(record as CashTransaction)"
                    >
                      <template #icon>
                        <IconifyIcon icon="lucide:eye" class="size-4" />
                      </template>
                    </Button>
                  </Tooltip>

                  <!-- Action 2: Confirm Transaction (disabled if already completed/canceled) -->
                  <Tooltip
                    :title="
                      record.status === 'pending'
                        ? 'Xác nhận thực hiện thu / chi'
                        : record.status === 'completed'
                          ? 'Giao dịch đã thực hiện hoàn tất'
                          : 'Bút toán đã bị hủy'
                    "
                  >
                    <Button
                      type="text"
                      size="small"
                      :disabled="record.status !== 'pending'"
                      class="inline-flex size-7 items-center justify-center p-0"
                      :class="
                        record.status === 'pending'
                          ? 'text-emerald-600 hover:text-emerald-700 hover:bg-emerald-50 dark:hover:bg-emerald-950/40'
                          : 'text-muted-foreground/30'
                      "
                      @click="openConfirm(record as CashTransaction)"
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
    <TransactionDetailModal
      v-model:open="isDetailModalOpen"
      :transaction="selectedTransaction"
    />

    <TransactionConfirmModal
      v-model:open="isConfirmModalOpen"
      :transaction="selectedTransaction"
    />
  </ResourceListPage>
</template>

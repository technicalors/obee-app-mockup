<script setup lang="ts">
import type { CashTransaction } from '../types';

import { computed, ref } from 'vue';

import { Page } from '@vben/common-ui';
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

// Summary metrics
const totalCount = computed(() => transactions.value.length);
const pendingCount = computed(
  () => transactions.value.filter((t) => t.status === 'pending').length,
);
const totalReceiptAmount = computed(() =>
  transactions.value
    .filter((t) => t.type === 'receipt' && t.status === 'completed')
    .reduce((sum, t) => sum + t.actualAmount, 0),
);
const totalExpenseAmount = computed(() =>
  transactions.value
    .filter((t) => t.type === 'expense' && t.status === 'completed')
    .reduce((sum, t) => sum + t.actualAmount, 0),
);

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
    width: 125,
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
    width: 190,
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
    width: 150,
  },
  {
    title: $t('cashFund.transactions.status'),
    dataIndex: 'status',
    key: 'status',
    width: 140,
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
        id="transactions-filter-panel"
        class="flex h-full min-h-0 shrink-0 flex-col overflow-hidden rounded-lg border border-border bg-background shadow-xs"
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

      <!-- Right Main Content Area -->
      <div
        class="flex h-full min-h-0 min-w-0 flex-1 flex-col gap-4 overflow-y-auto rounded-lg border border-border bg-background p-4 shadow-xs"
      >
        <!-- Header -->
        <div class="flex flex-wrap items-center justify-between gap-4">
          <div>
            <h1 class="text-xl font-bold tracking-tight text-foreground md:text-2xl m-0">
              {{ $t('cashFund.transactions.title') }}
            </h1>
            <p class="text-xs text-muted-foreground mt-1 mb-0">
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
                  <IconifyIcon icon="lucide:list-filter" class="size-4" />
                </template>
                Bộ lọc
              </Button>
            </Badge>
          </div>
        </div>

        <!-- KPI Summary Cards -->
        <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Tổng bút toán</span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ totalCount }}</div>
            <span class="text-[10px] text-muted-foreground">Phiếu thu & phiếu chi</span>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Chờ thực hiện</span>
            <div class="mt-1 text-xl font-semibold text-foreground">{{ pendingCount }}</div>
            <span class="text-[10px] text-muted-foreground">Chờ thủ quỹ chi/thu</span>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Tổng thu đã thực hiện</span>
            <div class="mt-1 text-xl font-semibold text-foreground">
              {{ totalReceiptAmount.toLocaleString() }} <span class="text-[11px] font-normal text-muted-foreground">VND</span>
            </div>
            <span class="text-[10px] text-muted-foreground">Tiền đã nộp vào quỹ</span>
          </div>

          <div class="rounded-lg border border-border bg-card p-3 shadow-2xs">
            <span class="text-[11px] text-muted-foreground font-medium block">Tổng chi đã thực hiện</span>
            <div class="mt-1 text-xl font-semibold text-foreground">
              {{ totalExpenseAmount.toLocaleString() }} <span class="text-[11px] font-normal text-muted-foreground">VND</span>
            </div>
            <span class="text-[10px] text-muted-foreground">Tiền mặt đã giải ngân</span>
          </div>
        </div>

        <!-- Vouchers Table -->
        <div class="rounded-lg border border-border bg-card shadow-xs overflow-hidden">
          <Table
            :data-source="filteredTransactions"
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
                <span class="font-semibold text-foreground text-sm">
                  {{ record.amount.toLocaleString() }}
                  <span class="text-xs font-normal text-muted-foreground">{{ record.currency }}</span>
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
  </Page>
</template>

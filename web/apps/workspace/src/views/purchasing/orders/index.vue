<script setup lang="ts">
import type { OrderStatus, PurchaseOrder } from '../types';

import { computed, nextTick, onMounted, ref } from 'vue';
import { useRoute } from 'vue-router';

import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Input,
  Progress,
  Select,
  Table,
  Tag,
  Tooltip,
} from 'ant-design-vue';

import FilterField from '../components/FilterField.vue';
import ListShell from '../components/ListShell.vue';
import { orderTotal, usePurchasing } from '../store';
import { money, ORDER_STATUS } from '../utils';
import OrderDetailModal from './components/OrderDetailModal.vue';

const { deliveries, orderPaid, orders, orderStatus, suppliers } =
  usePurchasing();

/** Bộ lọc riêng "Chờ kiểm tra hàng" bên cạnh các trạng thái PO. */
const PENDING_CHECK = 'pending_check';

const defaults = { keyword: '', status: 'all', supplierId: 'all' };
const filters = ref({ ...defaults });
const applied = ref({ ...defaults });

const activeFilterCount = computed(
  () =>
    Number(Boolean(applied.value.keyword.trim())) +
    Number(applied.value.status !== 'all') +
    Number(applied.value.supplierId !== 'all'),
);

/** Số đợt giao của PO đang chờ Purchasing hoặc người đề xuất kiểm tra. */
function pendingChecks(order: PurchaseOrder) {
  return deliveries.value.filter(
    (d) =>
      d.orderId === order.id &&
      (d.status === 'purchasing_check' || d.status === 'requester_check'),
  ).length;
}

const rows = computed(() =>
  orders.value.filter((order) => {
    if (applied.value.status === PENDING_CHECK) {
      if (pendingChecks(order) === 0) return false;
    } else if (
      applied.value.status !== 'all' &&
      orderStatus(order) !== applied.value.status
    ) {
      return false;
    }
    if (
      applied.value.supplierId !== 'all' &&
      order.supplierId !== applied.value.supplierId
    )
      return false;
    const q = applied.value.keyword.trim().toLowerCase();
    if (
      q &&
      ![
        order.code,
        order.requestCode,
        order.supplierName,
        ...order.lines.map((l) => l.itemName),
      ]
        .join(' ')
        .toLowerCase()
        .includes(q)
    )
      return false;
    return true;
  }),
);

const tiles = computed(() => {
  const counts: Record<OrderStatus, number> = {
    awaiting_payment: 0,
    completed: 0,
    in_progress: 0,
    not_issued: 0,
  };
  for (const order of orders.value) counts[orderStatus(order)]++;
  const order: OrderStatus[] = [
    'not_issued',
    'in_progress',
    'awaiting_payment',
    'completed',
  ];
  return [
    {
      count: orders.value.filter((o) => pendingChecks(o) > 0).length,
      highlight: true,
      key: PENDING_CHECK,
      label: 'Chờ kiểm tra hàng',
    },
    ...order.map((key) => ({
      count: counts[key],
      highlight: false,
      key,
      label: ORDER_STATUS[key].text,
    })),
  ];
});

const statusOptions = [
  { label: 'Tất cả trạng thái', value: 'all' },
  { label: 'Chờ kiểm tra hàng', value: PENDING_CHECK },
  ...(Object.keys(ORDER_STATUS) as OrderStatus[]).map((k) => ({
    label: ORDER_STATUS[k].text,
    value: k,
  })),
];

const detailOpen = ref(false);
const selectedId = ref<null | string>(null);
const initialTab = ref('lines');

/** PO có đợt chờ kiểm tra thì mở thẳng tab Giao nhận. */
async function openDetail(order: PurchaseOrder, tab?: string) {
  selectedId.value = order.id;
  initialTab.value = tab ?? (pendingChecks(order) > 0 ? 'deliveries' : 'lines');
  await nextTick();
  detailOpen.value = true;
}

function selectTile(key: string) {
  filters.value.status = applied.value.status === key ? 'all' : key;
  applied.value = { ...filters.value };
}

/** Liên kết từ thông báo ORSer Messenger: /purchasing/orders?po=PO-...&tab=deliveries */
const route = useRoute();
onMounted(() => {
  const code = route.query.po;
  const target = orders.value.find((o) => o.code === code);
  if (target) {
    openDetail(
      target,
      typeof route.query.tab === 'string' ? route.query.tab : undefined,
    );
  }
});

function receivedPercent(order: PurchaseOrder) {
  let ordered = 0;
  let received = 0;
  for (const line of order.lines) {
    ordered += line.quantity;
    received += Math.min(line.receivedQty, line.quantity);
  }
  return ordered === 0 ? 100 : Math.round((received / ordered) * 100);
}

const columns = [
  {
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
    fixed: 'left' as const,
    key: 'index',
    title: 'STT',
    width: 55,
  },
  { fixed: 'left' as const, key: 'code', title: 'Số PO', width: 160 },
  {
    dataIndex: 'requestCode',
    key: 'requestCode',
    title: 'Đề nghị',
    width: 150,
  },
  {
    dataIndex: 'supplierName',
    ellipsis: true,
    key: 'supplierName',
    title: 'Nhà cung cấp',
  },
  {
    dataIndex: 'requesterName',
    key: 'requesterName',
    title: 'Người đề xuất',
    width: 140,
  },
  { align: 'right' as const, key: 'total', title: 'Giá trị PO', width: 140 },
  { key: 'received', title: 'Nhận hàng', width: 130 },
  { align: 'right' as const, key: 'paid', title: 'Đã thanh toán', width: 140 },
  { key: 'status', title: 'Trạng thái', width: 170 },
  {
    align: 'center' as const,
    fixed: 'right' as const,
    key: 'actions',
    title: 'Thao tác',
    width: 110,
  },
];
</script>

<template>
  <ListShell
    title="Đơn hàng (PO)"
    description="Theo dõi và xử lý toàn bộ vòng đời PO: phát hành, giao nhận và kiểm tra hàng, bổ sung/chỉnh sửa, thanh toán"
    filter-title="Bộ lọc đơn hàng"
    :active-filter-count="activeFilterCount"
    @apply="applied = { ...filters }"
    @reset="
      filters = { ...defaults };
      applied = { ...defaults };
    "
  >
    <template #filters>
      <FilterField label="Từ khóa">
        <Input
          v-model:value="filters.keyword"
          placeholder="Số PO, đề nghị, hàng hóa..."
          allow-clear
        >
          <template #prefix>
            <IconifyIcon
              icon="lucide:search"
              class="size-3.5 text-muted-foreground"
            />
          </template>
        </Input>
      </FilterField>
      <FilterField label="Nhà cung cấp">
        <Select
          v-model:value="filters.supplierId"
          show-search
          option-filter-prop="label"
          class="w-full"
          :options="[
            { label: 'Tất cả NCC', value: 'all' },
            ...suppliers.map((s) => ({ label: s.name, value: s.id })),
          ]"
        />
      </FilterField>
      <FilterField label="Trạng thái">
        <Select
          v-model:value="filters.status"
          class="w-full"
          :options="statusOptions"
        />
      </FilterField>
    </template>

    <template #summary>
      <div
        class="grid shrink-0 grid-cols-2 gap-px border-b border-border bg-border md:grid-cols-5"
      >
        <button
          v-for="tile in tiles"
          :key="tile.key"
          type="button"
          class="flex flex-col items-start bg-background px-4 py-2.5 text-left transition-colors hover:bg-muted/40"
          :class="applied.status === tile.key ? '!bg-primary/10' : ''"
          @click="selectTile(tile.key)"
        >
          <span
            class="flex items-center gap-1 text-[11px] uppercase tracking-wider"
            :class="tile.highlight ? 'text-purple-600' : 'text-muted-foreground'"
          >
            <IconifyIcon
              v-if="tile.highlight"
              icon="lucide:clipboard-check"
              class="size-3"
            />
            {{ tile.label }}
          </span>
          <span
            class="text-lg font-semibold"
            :class="
              tile.highlight && tile.count > 0
                ? 'text-purple-600'
                : 'text-foreground'
            "
          >
            {{ tile.count }}
          </span>
        </button>
      </div>
    </template>

    <Table
      :data-source="rows"
      :columns="columns"
      :scroll="{ x: 1330, y: 'calc(100vh - 340px)' }"
      :pagination="{
        pageSize: 10,
        showSizeChanger: true,
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
            class="cursor-pointer font-mono font-semibold text-primary hover:underline"
            @click="openDetail(record as PurchaseOrder)"
          >
            {{ record.code }}
          </span>
          <Tag v-if="record.version > 1" class="ml-1 font-mono text-[10px]">
            v{{ record.version }}
          </Tag>
        </template>
        <template v-else-if="column.key === 'requestCode'">
          <span class="font-mono text-xs">{{ record.requestCode }}</span>
        </template>
        <template v-else-if="column.key === 'total'">
          <span class="text-xs font-semibold">
            {{ money(orderTotal(record as PurchaseOrder)) }}
          </span>
        </template>
        <template v-else-if="column.key === 'received'">
          <Progress
            :percent="receivedPercent(record as PurchaseOrder)"
            size="small"
          />
        </template>
        <template v-else-if="column.key === 'paid'">
          <span class="text-xs">
            {{ money(orderPaid(record as PurchaseOrder)) }}
          </span>
        </template>
        <template v-else-if="column.key === 'status'">
          <div class="flex flex-col items-start gap-1">
            <Tag
              :color="ORDER_STATUS[orderStatus(record as PurchaseOrder)].color"
              class="m-0 font-normal"
            >
              {{ ORDER_STATUS[orderStatus(record as PurchaseOrder)].text }}
            </Tag>
            <span
              v-if="pendingChecks(record as PurchaseOrder) > 0"
              class="inline-flex items-center gap-1 text-[11px] text-purple-600"
            >
              <IconifyIcon icon="lucide:clipboard-check" class="size-3" />
              {{ pendingChecks(record as PurchaseOrder) }} đợt chờ kiểm tra
            </span>
          </div>
        </template>
        <template v-else-if="column.key === 'actions'">
          <Button
            v-if="pendingChecks(record as PurchaseOrder) > 0"
            type="primary"
            size="small"
            ghost
            @click="openDetail(record as PurchaseOrder, 'deliveries')"
          >
            Kiểm tra
          </Button>
          <Tooltip v-else title="Xem chi tiết">
            <Button
              type="text"
              size="small"
              class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground hover:text-primary"
              @click="openDetail(record as PurchaseOrder)"
            >
              <template #icon>
                <IconifyIcon icon="lucide:eye" class="size-4" />
              </template>
            </Button>
          </Tooltip>
        </template>
      </template>
    </Table>

    <OrderDetailModal
      v-model:open="detailOpen"
      :initial-tab="initialTab"
      :order-id="selectedId"
    />
  </ListShell>
</template>

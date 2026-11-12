<script setup lang="ts">
import type { PurchaseRequest, RequestStatus } from '../types';

import { computed, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Input,
  message,
  Progress,
  Select,
  Table,
  Tag,
} from 'ant-design-vue';

import FilterField from '../components/FilterField.vue';
import ListShell from '../components/ListShell.vue';
import OrderDetailModal from '../orders/components/OrderDetailModal.vue';
import { orderTotal, usePurchasing } from '../store';
import { money, ORDER_STATUS, REQUEST_STATUS } from '../utils';

const {
  orderPaid,
  orders,
  ordersOfRequest,
  orderStatus,
  requests,
  requestStatus,
} = usePurchasing();

const TRACKED: RequestStatus[] = ['approved', 'purchasing', 'completed'];
const TRACKED_SET = new Set<RequestStatus>(TRACKED);

const defaults = { keyword: '', status: 'all' };
const filters = ref({ ...defaults });
const applied = ref({ ...defaults });
const activeFilterCount = computed(
  () =>
    Number(Boolean(applied.value.keyword.trim())) +
    Number(applied.value.status !== 'all'),
);

function progressOf(request: PurchaseRequest) {
  const list = ordersOfRequest(request.id);
  const ordered = list
    .flatMap((o) => o.lines)
    .reduce((s, l) => s + l.quantity, 0);
  const received = list
    .flatMap((o) => o.lines)
    .reduce((s, l) => s + Math.min(l.receivedQty, l.quantity), 0);
  const value = list.reduce((s, o) => s + orderTotal(o), 0);
  const paid = list.reduce((s, o) => s + orderPaid(o), 0);
  return {
    orders: list,
    paid,
    paidPercent: value ? Math.round((paid / value) * 100) : 0,
    receivedPercent: ordered ? Math.round((received / ordered) * 100) : 0,
    value,
  };
}

const rows = computed(() =>
  requests.value
    .filter((r) => TRACKED_SET.has(requestStatus(r)))
    .filter(
      (r) =>
        applied.value.status === 'all' ||
        requestStatus(r) === applied.value.status,
    )
    .filter((r) => {
      const q = applied.value.keyword.trim().toLowerCase();
      return (
        !q ||
        [
          r.code,
          r.requesterName,
          r.department,
          ...r.lines.map((l) => l.itemName),
        ]
          .join(' ')
          .toLowerCase()
          .includes(q)
      );
    })
    .map((r) => ({ ...progressOf(r), request: r, status: requestStatus(r) })),
);

const stats = computed(() => {
  const value = orders.value.reduce((s, o) => s + orderTotal(o), 0);
  const paid = orders.value.reduce((s, o) => s + orderPaid(o), 0);
  return [
    {
      icon: 'lucide:shopping-cart',
      label: 'Đề nghị đang mua hàng',
      value: String(
        requests.value.filter(
          (r) =>
            requestStatus(r) === 'purchasing' ||
            requestStatus(r) === 'approved',
        ).length,
      ),
    },
    {
      icon: 'lucide:truck',
      label: 'PO đang thực hiện',
      value: String(
        orders.value.filter((o) => orderStatus(o) === 'in_progress').length,
      ),
    },
    {
      icon: 'lucide:hourglass',
      label: 'PO chờ thanh toán',
      value: String(
        orders.value.filter((o) => orderStatus(o) === 'awaiting_payment')
          .length,
      ),
    },
    {
      icon: 'lucide:wallet',
      label: 'Đã thanh toán / tổng giá trị PO',
      value: `${money(paid)} / ${money(value)}`,
    },
  ];
});

const orderOpen = ref(false);
const orderId = ref<null | string>(null);
function openOrder(id: string) {
  orderId.value = id;
  orderOpen.value = true;
}

const columns = [
  { key: 'code', title: 'Đề nghị', width: 160 },
  { key: 'requester', title: 'Người đề xuất', width: 220 },
  { align: 'center' as const, key: 'orderCount', title: 'Số PO', width: 80 },
  { align: 'right' as const, key: 'value', title: 'Giá trị PO', width: 150 },
  { key: 'received', title: 'Nhận hàng', width: 170 },
  { key: 'paid', title: 'Thanh toán', width: 170 },
  { key: 'status', title: 'Trạng thái', width: 140 },
];
</script>

<template>
  <ListShell
    title="Tiến độ mua hàng"
    description="Mỗi đề nghị đã hoàn thành đến đâu theo từng PO: số lượng đã nhận và tình trạng thanh toán"
    filter-title="Bộ lọc báo cáo"
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
          placeholder="Đề nghị, người đề xuất, hàng hóa..."
          allow-clear
        />
      </FilterField>
      <FilterField label="Trạng thái đề nghị">
        <Select
          v-model:value="filters.status"
          class="w-full"
          :options="[
            { label: 'Tất cả', value: 'all' },
            ...TRACKED.map((k) => ({
              label: REQUEST_STATUS[k].text,
              value: k,
            })),
          ]"
        />
      </FilterField>
    </template>

    <template #actions>
      <Button
        @click="message.success('Đã xuất báo cáo tiến độ mua hàng ra Excel.')"
      >
        <template #icon>
<IconifyIcon icon="lucide:sheet" class="size-4" />
</template>
        Xuất Excel
      </Button>
    </template>

    <template #summary>
      <div
        class="grid shrink-0 grid-cols-1 gap-px border-b border-border bg-border sm:grid-cols-2 xl:grid-cols-4"
      >
        <div
          v-for="stat in stats"
          :key="stat.label"
          class="flex items-center gap-3 bg-background px-4 py-3"
        >
          <span
            class="flex size-9 items-center justify-center rounded-md bg-primary/10 text-primary"
          >
            <IconifyIcon :icon="stat.icon" class="size-4" />
          </span>
          <div class="min-w-0">
            <div
              class="text-[11px] uppercase tracking-wider text-muted-foreground"
            >
              {{ stat.label }}
            </div>
            <div class="truncate text-base font-semibold">{{ stat.value }}</div>
          </div>
        </div>
      </div>
    </template>

    <Table
      :data-source="rows"
      :columns="columns"
      :scroll="{ x: 1100 }"
      :pagination="{
        pageSize: 10,
        class: '!px-4 !py-2.5 !m-0 border-t border-border',
      }"
      :row-key="(row: any) => row.request.id"
      size="small"
      bordered
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'code'">
          <span class="font-mono font-semibold">{{ record.request.code }}</span>
        </template>
        <template v-else-if="column.key === 'requester'">
          <div class="flex flex-col text-xs">
            <span class="font-medium">{{ record.request.requesterName }}</span>
            <span class="text-muted-foreground">{{
              record.request.department
            }}</span>
          </div>
        </template>
        <template v-else-if="column.key === 'orderCount'">
{{
          record.orders.length
        }}
</template>
        <template v-else-if="column.key === 'value'">
<span class="text-xs font-semibold">{{
            money(record.value)
          }}</span>
</template>
        <template v-else-if="column.key === 'received'">
<Progress :percent="record.receivedPercent" size="small" />
</template>
        <template v-else-if="column.key === 'paid'">
<Progress
            :percent="record.paidPercent"
            size="small"
            stroke-color="#16a34a"
        />
</template>
        <template v-else-if="column.key === 'status'">
          <Tag
            :color="REQUEST_STATUS[record.status as RequestStatus].color"
            class="m-0"
            >
{{ REQUEST_STATUS[record.status as RequestStatus].text }}
</Tag>
        </template>
      </template>
      <template #expandedRowRender="{ record }">
        <div class="flex flex-col divide-y divide-border">
          <div
            v-for="order in record.orders"
            :key="order.id"
            class="flex flex-wrap items-center gap-3 py-1.5 text-xs"
          >
            <button
              type="button"
              class="font-mono font-semibold text-primary hover:underline"
              @click="openOrder(order.id)"
            >
              {{ order.code }}
            </button>
            <span class="text-muted-foreground">{{ order.supplierName }}</span>
            <span class="ml-auto">{{ money(orderPaid(order)) }} /
              {{ money(orderTotal(order)) }}</span>
            <Tag :color="ORDER_STATUS[orderStatus(order)].color" class="m-0">
{{
              ORDER_STATUS[orderStatus(order)].text
            }}
</Tag>
          </div>
        </div>
      </template>
    </Table>

    <OrderDetailModal v-model:open="orderOpen" :order-id="orderId" />
  </ListShell>
</template>

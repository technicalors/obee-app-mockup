<script setup lang="ts">
import type { PurchaseRequest, RequestStatus } from '../types';

import { computed, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Button, Input, Select, Table, Tag, Tooltip } from 'ant-design-vue';

import FilterField from '../components/FilterField.vue';
import ListShell from '../components/ListShell.vue';
import { CURRENT_USER } from '../mock-data';
import OrderDetailModal from '../orders/components/OrderDetailModal.vue';
import { requestTotal, usePurchasing } from '../store';
import { money, REQUEST_STATUS } from '../utils';
import RequestDetailModal from './components/RequestDetailModal.vue';
import RequestFormModal from './components/RequestFormModal.vue';

const { currentApprover, requests, requestStatus } = usePurchasing();

const defaults = { keyword: '', scope: 'all', status: 'all' };
const filters = ref({ ...defaults });
const applied = ref({ ...defaults });

const activeFilterCount = computed(
  () =>
    Number(Boolean(applied.value.keyword.trim())) +
    Number(applied.value.status !== 'all') +
    Number(applied.value.scope !== 'all'),
);

const rows = computed(() =>
  requests.value.filter((request) => {
    const status = requestStatus(request);
    if (applied.value.status !== 'all' && status !== applied.value.status)
      return false;
    if (
      applied.value.scope === 'mine' &&
      request.requesterName !== CURRENT_USER.name
    )
      return false;
    if (
      applied.value.scope === 'dept' &&
      request.department !== CURRENT_USER.department
    )
      return false;
    const q = applied.value.keyword.trim().toLowerCase();
    if (q) {
      const haystack = [
        request.code,
        request.note,
        request.requesterName,
        ...request.lines.map((l) => l.itemName),
      ]
        .join(' ')
        .toLowerCase();
      if (!haystack.includes(q)) return false;
    }
    return true;
  }),
);

const formOpen = ref(false);
const detailOpen = ref(false);
const orderOpen = ref(false);
const editing = ref<null | PurchaseRequest>(null);
const selected = ref<null | PurchaseRequest>(null);
const selectedOrderId = ref<null | string>(null);

function openCreate() {
  editing.value = null;
  formOpen.value = true;
}

function openEdit(request: PurchaseRequest) {
  editing.value = request;
  detailOpen.value = false;
  formOpen.value = true;
}

function openDetail(request: PurchaseRequest) {
  selected.value = request;
  detailOpen.value = true;
}

function openOrder(id: string) {
  selectedOrderId.value = id;
  orderOpen.value = true;
}

function summary(request: PurchaseRequest) {
  const names = request.lines.map((l) => l.itemName);
  return names.length > 2
    ? `${names.slice(0, 2).join(', ')} và ${names.length - 2} mục khác`
    : names.join(', ');
}

function handler(request: PurchaseRequest) {
  const status = requestStatus(request);
  if (status === 'pending')
    return currentApprover(request.approvalSteps, request.currentStep);
  if (status === 'draft' || status === 'return_edit')
    return request.requesterName;
  if (status === 'approved' || status === 'purchasing') return 'Purchasing';
  return '-';
}

const statusOptions = (Object.keys(REQUEST_STATUS) as RequestStatus[]).map(
  (key) => ({
    label: REQUEST_STATUS[key].text,
    value: key,
  }),
);

const columns = [
  {
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
    fixed: 'left' as const,
    key: 'index',
    title: 'STT',
    width: 55,
  },
  {
    dataIndex: 'code',
    fixed: 'left' as const,
    key: 'code',
    title: 'Số phiếu',
    width: 155,
  },
  { key: 'summary', title: 'Nội dung' },
  {
    dataIndex: 'requesterName',
    key: 'requesterName',
    title: 'Người đề xuất',
    width: 150,
  },
  { align: 'right' as const, key: 'total', title: 'Tổng giá trị', width: 150 },
  { dataIndex: 'createdAt', key: 'createdAt', title: 'Ngày tạo', width: 140 },
  { key: 'handler', title: 'Người xử lý', width: 200 },
  { key: 'status', title: 'Trạng thái', width: 150 },
  {
    align: 'center' as const,
    fixed: 'right' as const,
    key: 'actions',
    title: 'Thao tác',
    width: 90,
  },
];
</script>

<template>
  <ListShell
    title="Đề nghị mua hàng"
    description="Tạo, theo dõi đề nghị mua hàng hóa/dịch vụ từ lúc gửi duyệt đến khi hoàn thành"
    filter-title="Bộ lọc đề nghị"
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
          placeholder="Số phiếu, hàng hóa, người đề xuất..."
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
      <FilterField label="Phạm vi">
        <Select
          v-model:value="filters.scope"
          class="w-full"
          :options="[
            { label: 'Tất cả phiếu được xem', value: 'all' },
            { label: 'Phiếu của tôi', value: 'mine' },
            { label: 'Phiếu của bộ phận', value: 'dept' },
          ]"
        />
      </FilterField>
      <FilterField label="Trạng thái">
        <Select
          v-model:value="filters.status"
          class="w-full"
          :options="[
            { label: 'Tất cả trạng thái', value: 'all' },
            ...statusOptions,
          ]"
        />
      </FilterField>
    </template>

    <template #actions>
      <Button type="primary" @click="openCreate">
        <template #icon>
<IconifyIcon icon="lucide:plus" class="size-4" />
</template>
        Tạo đề nghị
      </Button>
    </template>

    <Table
      :data-source="rows"
      :columns="columns"
      :scroll="{ x: 1250, y: 'calc(100vh - 275px)' }"
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
            @click="openDetail(record as PurchaseRequest)"
          >
            {{ record.code }}
          </span>
        </template>
        <template v-else-if="column.key === 'summary'">
          <div class="flex flex-col">
            <span class="text-xs font-medium text-foreground">{{
              summary(record as PurchaseRequest)
            }}</span>
            <span
              v-if="record.note"
              class="truncate text-[11px] text-muted-foreground"
              >{{ record.note }}</span>
          </div>
        </template>
        <template v-else-if="column.key === 'total'">
          <span class="text-xs font-semibold">{{
            money(requestTotal(record as PurchaseRequest))
          }}</span>
        </template>
        <template v-else-if="column.key === 'handler'">
          <span class="text-xs">{{ handler(record as PurchaseRequest) }}</span>
        </template>
        <template v-else-if="column.key === 'status'">
          <Tag
            :color="
              REQUEST_STATUS[requestStatus(record as PurchaseRequest)].color
            "
            class="m-0 font-normal"
          >
            {{ REQUEST_STATUS[requestStatus(record as PurchaseRequest)].text }}
          </Tag>
        </template>
        <template v-else-if="column.key === 'actions'">
          <div class="flex items-center justify-center gap-1">
            <Tooltip title="Xem chi tiết">
              <Button
                type="text"
                size="small"
                class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground hover:text-primary"
                @click="openDetail(record as PurchaseRequest)"
              >
                <template #icon>
<IconifyIcon icon="lucide:eye" class="size-4" />
</template>
              </Button>
            </Tooltip>
            <Tooltip
              :title="
                record.status === 'draft' || record.status === 'return_edit'
                  ? 'Chỉnh sửa'
                  : 'Chỉ sửa khi Nháp hoặc Yêu cầu điều chỉnh'
              "
            >
              <Button
                type="text"
                size="small"
                :disabled="
                  record.status !== 'draft' && record.status !== 'return_edit'
                "
                class="inline-flex size-7 items-center justify-center p-0"
                :class="
                  record.status === 'return_edit'
                    ? 'text-amber-600'
                    : 'text-muted-foreground'
                "
                @click="openEdit(record as PurchaseRequest)"
              >
                <template #icon>
<IconifyIcon icon="lucide:pencil" class="size-4" />
</template>
              </Button>
            </Tooltip>
          </div>
        </template>
      </template>
    </Table>

    <RequestFormModal v-model:open="formOpen" :request="editing" />
    <RequestDetailModal
      v-model:open="detailOpen"
      :request="selected"
      @edit="openEdit"
      @open-order="openOrder"
    />
    <OrderDetailModal v-model:open="orderOpen" :order-id="selectedOrderId" />
  </ListShell>
</template>

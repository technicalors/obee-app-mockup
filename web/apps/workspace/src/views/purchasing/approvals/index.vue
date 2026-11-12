<script setup lang="ts">
import type { ApprovalRole } from '../types';

import { computed, nextTick, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Button, Input, Select, Table, Tag } from 'ant-design-vue';

import FilterField from '../components/FilterField.vue';
import ListShell from '../components/ListShell.vue';
import { requestTotal, usePurchasing } from '../store';
import { money, ROLE_LABELS, ROLE_ORDER } from '../utils';
import ApprovalModal from './components/ApprovalModal.vue';

interface Row {
  code: string;
  createdAt: string;
  department: string;
  id: string;
  kind: 'change' | 'request';
  requesterName: string;
  role: ApprovalRole;
  approverName: string;
  summary: string;
  value: number;
}

const { changeRequests, requests } = usePurchasing();

const defaults = { keyword: '', kind: 'all', role: 'all' };
const filters = ref({ ...defaults });
const applied = ref({ ...defaults });

const activeFilterCount = computed(
  () =>
    Number(Boolean(applied.value.keyword.trim())) +
    Number(applied.value.kind !== 'all') +
    Number(applied.value.role !== 'all'),
);

const allRows = computed<Row[]>(() => {
  const list: Row[] = [];
  for (const r of requests.value) {
    const step = r.approvalSteps[r.currentStep];
    if (r.status !== 'pending' || !step) continue;
    list.push({
      approverName: step.approverName,
      code: r.code,
      createdAt: r.createdAt,
      department: r.department,
      id: r.id,
      kind: 'request',
      requesterName: r.requesterName,
      role: step.role,
      summary: r.lines.map((l) => `${l.itemName} × ${l.quantity}`).join(', '),
      value: requestTotal(r),
    });
  }
  for (const c of changeRequests.value) {
    const step = c.approvalSteps[c.currentStep];
    if (c.status !== 'pending' || !step) continue;
    list.push({
      approverName: step.approverName,
      code: c.code,
      createdAt: c.createdAt,
      department: c.department,
      id: c.id,
      kind: 'change',
      requesterName: c.requesterName,
      role: step.role,
      summary: `${c.orderCode}: ${c.reason}`,
      value: c.lines.reduce(
        (s, l) =>
          s +
          (l.kind === 'quantity' ? l.newQty - l.currentQty : l.newQty) *
            l.unitPrice,
        0,
      ),
    });
  }
  return list.toSorted((a, b) => b.createdAt.localeCompare(a.createdAt));
});

const rows = computed(() =>
  allRows.value.filter((row) => {
    if (applied.value.kind !== 'all' && row.kind !== applied.value.kind)
      return false;
    if (applied.value.role !== 'all' && row.role !== applied.value.role)
      return false;
    const q = applied.value.keyword.trim().toLowerCase();
    if (
      q &&
      ![row.code, row.summary, row.requesterName]
        .join(' ')
        .toLowerCase()
        .includes(q)
    )
      return false;
    return true;
  }),
);

const modalOpen = ref(false);
const selected = ref<null | Row>(null);

/** Mở sau nextTick để Modal được mount ở trạng thái đóng rồi mới mở (giữ hiệu ứng mở). */
async function open(row: Row) {
  selected.value = row;
  await nextTick();
  modalOpen.value = true;
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
  { fixed: 'left' as const, key: 'code', title: 'Số phiếu', width: 155 },
  { key: 'kind', title: 'Loại', width: 140 },
  { dataIndex: 'summary', ellipsis: true, key: 'summary', title: 'Nội dung' },
  {
    dataIndex: 'requesterName',
    key: 'requesterName',
    title: 'Người đề xuất',
    width: 150,
  },
  { align: 'right' as const, key: 'value', title: 'Giá trị', width: 140 },
  { key: 'step', title: 'Cấp đang chờ', width: 200 },
  { dataIndex: 'createdAt', key: 'createdAt', title: 'Ngày gửi', width: 140 },
  {
    align: 'center' as const,
    fixed: 'right' as const,
    key: 'actions',
    title: 'Thao tác',
    width: 100,
  },
];
</script>

<template>
  <ListShell
    title="Phê duyệt mua hàng"
    description="Đề nghị mua hàng và yêu cầu bổ sung/chỉnh sửa đang chờ duyệt theo cây 4 cấp"
    filter-title="Bộ lọc phê duyệt"
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
          placeholder="Số phiếu, nội dung, người đề xuất..."
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
      <FilterField label="Loại phiếu">
        <Select
          v-model:value="filters.kind"
          class="w-full"
          :options="[
            { label: 'Tất cả', value: 'all' },
            { label: 'Đề nghị mua hàng', value: 'request' },
            { label: 'Yêu cầu bổ sung/chỉnh sửa', value: 'change' },
          ]"
        />
      </FilterField>
      <FilterField label="Cấp đang chờ">
        <Select
          v-model:value="filters.role"
          class="w-full"
          :options="[
            { label: 'Tất cả cấp', value: 'all' },
            ...ROLE_ORDER.map((r) => ({ label: ROLE_LABELS[r], value: r })),
          ]"
        />
      </FilterField>
      <p class="m-0 text-[11px] leading-5 text-muted-foreground">
        Bản mockup hiển thị mọi phiếu đang chờ để xem thử từng cấp. Bản thật chỉ
        hiển thị phiếu mà người dùng là người duyệt ở cấp hiện tại.
      </p>
    </template>

    <Table
      :data-source="rows"
      :columns="columns"
      :scroll="{ x: 1250, y: 'calc(100vh - 275px)' }"
      :pagination="{
        pageSize: 10,
        showTotal: (total: number) => `Tổng ${total} phiếu chờ duyệt`,
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
            @click="open(record as Row)"
            >{{ record.code }}</span>
        </template>
        <template v-else-if="column.key === 'kind'">
          <Tag
            :color="record.kind === 'change' ? 'orange' : 'blue'"
            class="m-0"
          >
            {{ record.kind === 'change' ? 'Bổ sung/chỉnh sửa' : 'Đề nghị mua' }}
          </Tag>
        </template>
        <template v-else-if="column.key === 'value'">
          <span class="text-xs font-semibold">{{ record.kind === 'change' && record.value > 0 ? '+' : ''
            }}{{ money(record.value) }}</span>
        </template>
        <template v-else-if="column.key === 'step'">
          <div class="flex flex-col text-xs">
            <span class="font-medium">{{
              ROLE_LABELS[record.role as ApprovalRole]
            }}</span>
            <span class="text-muted-foreground">{{ record.approverName }}</span>
          </div>
        </template>
        <template v-else-if="column.key === 'actions'">
          <Button type="primary" size="small" ghost @click="open(record as Row)">
Xử lý
</Button>
        </template>
      </template>
    </Table>

    <ApprovalModal
      v-if="selected"
      :id="selected.id"
      v-model:open="modalOpen"
      :kind="selected.kind"
    />
  </ListShell>
</template>

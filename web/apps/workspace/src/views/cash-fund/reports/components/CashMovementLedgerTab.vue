<script setup lang="ts">
import { computed, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Button, message, Select, Table } from 'ant-design-vue';

import { useCashFund } from '../../store';

const { fundSources } = useCashFund();

const selectedFundId = ref(fundSources.value[0]?.id || 'src-01');

const selectedFund = computed(() => {
  return fundSources.value.find((s) => s.id === selectedFundId.value) ?? fundSources.value[0];
});

// Mock realistic journal entries with running cumulative balance
const cashBookEntries = computed(() => {
  const initial = selectedFund.value?.initialBalance ?? 100000000;

  // Running ledger calculations
  let running = initial;

  const rawEntries = [
    {
      date: '2026-10-01',
      docNo: 'ĐK-202610',
      description: 'Số dư đầu kỳ kết chuyển sang',
      inAmount: 0,
      outAmount: 0,
      counterpart: 'Kế toán tổng hợp',
      approver: 'Nguyễn Thị Bích (CFO)',
      voucher: '',
    },
    {
      date: '2026-10-06',
      docNo: 'PC-202610-001',
      description: 'Chi tạm ứng công tác hội chợ TechExpo Đà Nẵng',
      inAmount: 0,
      outAmount: 15000000,
      counterpart: 'Nguyễn Văn Nam',
      approver: 'Đỗ Thị Lan (Thủ quỹ)',
      voucher: 'Chung_tu_goc_01.pdf',
    },
    {
      date: '2026-10-09',
      docNo: 'PT-202610-002',
      description: 'Thu tiền hoàn ứng thừa hội thảo quốc tế Q3',
      inAmount: 3200000,
      outAmount: 0,
      counterpart: 'Lê Thu Hà',
      approver: 'Đỗ Thị Lan (Thủ quỹ)',
      voucher: 'Bien_lai_thu_tien.pdf',
    },
    {
      date: '2026-10-12',
      docNo: 'PC-202610-003',
      description: 'Chi mua sắm văn phòng phẩm và mực in Canon VP',
      inAmount: 0,
      outAmount: 4300000,
      counterpart: 'Ngô Phương Thảo',
      approver: 'Trần Minh Đức (Trưởng BP)',
      voucher: 'Hoa_don_GTGT_VPP.pdf',
    },
    {
      date: '2026-10-17',
      docNo: 'PT-202610-001',
      description: 'Thu tiền bồi hoàn sửa chữa LCD Dell làm rơi',
      inAmount: 2500000,
      outAmount: 0,
      counterpart: 'Lê Hoàng Long',
      approver: 'Lê Thu Hà (Kế toán)',
      voucher: 'Bien_ban_boi_thuong.pdf',
    },
    {
      date: '2026-10-18',
      docNo: 'DC-202610-001',
      description: 'Nhận điều chuyển từ Quỹ dự phòng khẩn cấp',
      inAmount: 30000000,
      outAmount: 0,
      counterpart: 'Phòng Tài chính',
      approver: 'Trần Anh Tuấn (TGĐ)',
      voucher: 'Quyet_dinh_dieu_chuyen.pdf',
    },
  ];

  return rawEntries.map((row) => {
    running = running + row.inAmount - row.outAmount;
    return {
      ...row,
      balance: running,
    };
  });
});

const totalIn = computed(() =>
  cashBookEntries.value.reduce((sum, r) => sum + r.inAmount, 0),
);

const totalOut = computed(() =>
  cashBookEntries.value.reduce((sum, r) => sum + r.outAmount, 0),
);

const finalBalance = computed(() => {
  const last = cashBookEntries.value[cashBookEntries.value.length - 1];
  return last ? last.balance : 0;
});

function handleExport() {
  message.success('Đang trích xuất Sổ quỹ tiền mặt (Excel) theo mẫu Bộ Tài chính...');
}

function handlePrint() {
  window.print();
}

const columns = [
  { title: 'Ngày ghi sổ', dataIndex: 'date', key: 'date', width: 110 },
  { title: 'Số chứng từ', dataIndex: 'docNo', key: 'docNo', width: 135 },
  { title: 'Diễn giải nghiệp vụ phát sinh', dataIndex: 'description', key: 'description' },
  {
    title: 'Thu vào (VND)',
    dataIndex: 'inAmount',
    key: 'inAmount',
    width: 140,
    align: 'right' as const,
    customRender: ({ text }: any) => (text > 0 ? `+${text.toLocaleString()}` : '-'),
  },
  {
    title: 'Chi ra (VND)',
    dataIndex: 'outAmount',
    key: 'outAmount',
    width: 140,
    align: 'right' as const,
    customRender: ({ text }: any) => (text > 0 ? `-${text.toLocaleString()}` : '-'),
  },
  {
    title: 'Tồn quỹ luỹ kế (VND)',
    dataIndex: 'balance',
    key: 'balance',
    width: 160,
    align: 'right' as const,
    customRender: ({ text }: any) => text.toLocaleString(),
  },
  { title: 'Người nộp / nhận', dataIndex: 'counterpart', key: 'counterpart', width: 160 },
  { title: 'Người duyệt / Ký', dataIndex: 'approver', key: 'approver', width: 170 },
];
</script>

<template>
  <div class="flex flex-col gap-5">
    <!-- Fund Source Select & Print/Export Bar -->
    <div class="flex flex-wrap items-center justify-between gap-4 rounded-xl border border-border bg-card p-4 shadow-sm">
      <div class="flex flex-wrap items-center gap-3">
        <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
          Chọn sổ quỹ:
        </label>
        <Select v-model:value="selectedFundId" class="w-72">
          <Select.Option v-for="s in fundSources" :key="s.id" :value="s.id">
            {{ s.name }} ({{ s.currency }})
          </Select.Option>
        </Select>
      </div>

      <div class="flex items-center gap-2">
        <Button @click="handlePrint">
          <template #icon>
            <IconifyIcon icon="lucide:printer" class="size-4" />
          </template>
          In sổ quỹ
        </Button>
        <Button type="primary" @click="handleExport">
          <template #icon>
            <IconifyIcon icon="lucide:file-spreadsheet" class="size-4" />
          </template>
          Xuất Excel
        </Button>
      </div>
    </div>

    <!-- 4 KPI Summary Cards for Cash Book -->
    <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
      <div class="rounded-lg border border-border bg-card p-3.5 shadow-sm">
        <span class="text-xs text-muted-foreground block font-medium">Tồn đầu kỳ</span>
        <div class="text-xl font-bold text-foreground mt-1">
          {{ (selectedFund?.initialBalance ?? 0).toLocaleString() }} <span class="text-xs font-normal">VND</span>
        </div>
      </div>

      <div class="rounded-lg border border-border bg-card p-3.5 shadow-sm">
        <span class="text-xs text-muted-foreground block font-medium">Tổng thu trong kỳ</span>
        <div class="text-xl font-bold text-emerald-600 mt-1">
          +{{ totalIn.toLocaleString() }} <span class="text-xs font-normal">VND</span>
        </div>
      </div>

      <div class="rounded-lg border border-border bg-card p-3.5 shadow-sm">
        <span class="text-xs text-muted-foreground block font-medium">Tổng chi trong kỳ</span>
        <div class="text-xl font-bold text-orange-600 mt-1">
          -{{ totalOut.toLocaleString() }} <span class="text-xs font-normal">VND</span>
        </div>
      </div>

      <div class="rounded-lg border border-primary/30 bg-primary/10 p-3.5 shadow-sm">
        <span class="text-xs text-primary font-bold block">Tồn quỹ hiện tại</span>
        <div class="text-xl font-bold text-primary mt-1">
          {{ finalBalance.toLocaleString() }} <span class="text-xs font-normal">VND</span>
        </div>
      </div>
    </div>

    <!-- Official Cash Book Data Table -->
    <div class="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
      <Table
        :data-source="cashBookEntries"
        :columns="columns"
        :pagination="false"
        :scroll="{ x: 1200 }"
        size="middle"
        row-key="docNo"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'docNo'">
            <span class="font-mono font-bold text-primary">
              {{ record.docNo }}
            </span>
          </template>

          <template v-else-if="column.key === 'inAmount'">
            <span v-if="record.inAmount > 0" class="font-semibold text-emerald-600">
              +{{ record.inAmount.toLocaleString() }}
            </span>
            <span v-else class="text-muted-foreground">-</span>
          </template>

          <template v-else-if="column.key === 'outAmount'">
            <span v-if="record.outAmount > 0" class="font-semibold text-orange-600">
              -{{ record.outAmount.toLocaleString() }}
            </span>
            <span v-else class="text-muted-foreground">-</span>
          </template>

          <template v-else-if="column.key === 'balance'">
            <span class="font-bold text-foreground">
              {{ record.balance.toLocaleString() }}
            </span>
          </template>
        </template>
      </Table>
    </div>
  </div>
</template>

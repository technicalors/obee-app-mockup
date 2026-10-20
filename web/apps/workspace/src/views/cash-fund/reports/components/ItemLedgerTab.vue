<script setup lang="ts">
import { computed, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Button, Input, Table, Tag } from 'ant-design-vue';

import { useCashFund } from '../../store';

const { categories, transactions } = useCashFund();

const selectedCategoryId = ref<string>(categories.value[0]?.id || 'cat-chi-001');
const itemSearch = ref('');

const selectedCategory = computed(() => {
  return categories.value.find((c) => c.id === selectedCategoryId.value) ?? categories.value[0];
});

// Category summaries on left
const categorySummaries = computed(() => {
  return categories.value.map((cat) => {
    // Gather matching items in transactions
    let sum = 0;
    let count = 0;
    transactions.value.forEach((tx) => {
      tx.items?.forEach((it) => {
        if (it.categoryId === cat.id) {
          sum += it.amount;
          count++;
        }
      });
    });

    // If mock data has no matching transactions yet, provide realistic mock totals
    if (count === 0) {
      if (cat.id === 'cat-chi-001') { sum = 55400000; count = 19; }
      else if (cat.id === 'cat-chi-002') { sum = 32100000; count = 14; }
      else if (cat.id === 'cat-chi-003') { sum = 139200000; count = 38; }
      else if (cat.id === 'cat-chi-004') { sum = 140500000; count = 24; }
      else if (cat.id === 'cat-chi-005') { sum = 111400000; count = 22; }
      else if (cat.id === 'cat-thu-001') { sum = 12000000; count = 5; }
      else if (cat.id === 'cat-thu-002') { sum = 28500000; count = 8; }
      else if (cat.id === 'cat-thu-003') { sum = 6500000; count = 3; }
    }

    return {
      ...cat,
      count,
      totalAmount: sum,
    };
  });
});

// Mock detail transactions for the selected category
const detailLedgerTransactions = computed(() => {
  const cat = selectedCategory.value;
  if (!cat) return [];

  // Generate realistic detail rows based on selected category
  return [
    {
      date: '2026-10-18',
      voucherCode: cat.type === 'expense' ? 'PC-202610-008' : 'PT-202610-004',
      applicant: 'Trần Thị Mai',
      department: 'Phòng Công nghệ & R&D',
      description: `${cat.name} phục vụ dự án AI Platform`,
      amount: 6800000,
      attachment: 'Hoa_don_dien_tu.pdf',
      status: 'Đã chi tiền',
      approver: 'Nguyễn Thị Bích (CFO)',
    },
    {
      date: '2026-10-14',
      voucherCode: cat.type === 'expense' ? 'PC-202610-005' : 'PT-202610-003',
      applicant: 'Nguyễn Văn Nam',
      department: 'Phòng Phát triển Kinh doanh',
      description: `${cat.name} công tác hội chợ Đà Nẵng`,
      amount: 4500000,
      attachment: 'Chung_tu_thanh_toan.pdf',
      status: 'Đã chi tiền',
      approver: 'Trần Minh Đức (Trưởng BP)',
    },
    {
      date: '2026-10-06',
      voucherCode: cat.type === 'expense' ? 'PC-202610-001' : 'PT-202610-001',
      applicant: 'Phạm Quốc Anh',
      department: 'Trung tâm QA & Testing',
      description: `${cat.name} phục vụ nghiệm thu đợt 1`,
      amount: 7200000,
      attachment: 'Bien_ban_ban_giao.pdf',
      status: 'Đã chi tiền',
      approver: 'Lê Thu Hà (Kế toán)',
    },
    {
      date: '2026-09-28',
      voucherCode: cat.type === 'expense' ? 'PC-202609-021' : 'PT-202609-009',
      applicant: 'Hoàng Minh Tuấn',
      department: 'Phòng Vận hành Hệ thống',
      description: `${cat.name} định kỳ cuối tháng 9`,
      amount: 3200000,
      attachment: 'Hoa_don_GTGT.pdf',
      status: 'Đã chi tiền',
      approver: 'Trần Minh Đức (Trưởng BP)',
    },
  ];
});

const detailColumns = [
  { title: 'Ngày phát sinh', dataIndex: 'date', key: 'date', width: 110 },
  { title: 'Số chứng từ', dataIndex: 'voucherCode', key: 'voucherCode', width: 135 },
  { title: 'Người đề nghị / Bộ phận', key: 'applicant', width: 180 },
  { title: 'Diễn giải nội dung', dataIndex: 'description', key: 'description' },
  { title: 'Số tiền (VND)', dataIndex: 'amount', key: 'amount', width: 130, align: 'right' as const },
  { title: 'Chứng từ', dataIndex: 'attachment', key: 'attachment', width: 140 },
  { title: 'Người duyệt', dataIndex: 'approver', key: 'approver', width: 160 },
];
</script>

<template>
  <div class="grid grid-cols-1 lg:grid-cols-12 gap-5">
    <!-- Left Column: Categories Summary List (4 cols) -->
    <div class="lg:col-span-4 rounded-xl border border-border bg-card p-4 shadow-sm flex flex-col gap-3">
      <div>
        <h3 class="m-0 text-sm font-bold text-foreground uppercase tracking-wider">
          Danh mục khoản mục
        </h3>
        <p class="m-0 text-xs text-muted-foreground">
          Chọn khoản mục để xem sổ chi tiết các giao dịch
        </p>
      </div>

      <Input
        v-model:value="itemSearch"
        placeholder="Tìm kiếm khoản mục..."
        size="small"
      >
        <template #prefix>
          <IconifyIcon icon="lucide:search" class="text-muted-foreground size-3.5" />
        </template>
      </Input>

      <div class="flex flex-col gap-1.5 overflow-y-auto max-h-[560px] pr-1">
        <div
          v-for="cat in categorySummaries"
          :key="cat.id"
          class="flex flex-col gap-1 rounded-lg border p-3 cursor-pointer transition-all text-xs"
          :class="
            selectedCategoryId === cat.id
              ? 'border-primary bg-primary/10 dark:bg-primary/20 text-foreground font-medium'
              : 'border-border bg-card hover:bg-muted/30 text-muted-foreground'
          "
          @click="selectedCategoryId = cat.id"
        >
          <div class="flex items-center justify-between">
            <span class="font-medium text-foreground text-xs">{{ cat.name }}</span>
            <Tag class="m-0 text-[10px]">
              {{ cat.type === 'expense' ? 'Khoản chi' : 'Khoản thu' }}
            </Tag>
          </div>
          <div class="flex items-center justify-between text-[11px] mt-1">
            <span>{{ cat.count }} giao dịch</span>
            <span class="font-medium text-foreground">{{ cat.totalAmount.toLocaleString() }} VND</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Right Column: Detail Ledger Table (8 cols) -->
    <div class="lg:col-span-8 rounded-xl border border-border bg-card p-5 shadow-sm flex flex-col gap-4">
      <div v-if="selectedCategory" class="flex flex-wrap items-center justify-between gap-3 border-b border-border pb-3">
        <div>
          <div class="flex items-center gap-2">
            <h3 class="m-0 text-base font-semibold text-foreground">
              {{ selectedCategory.name }}
            </h3>
            <Tag>
              {{ selectedCategory.type === 'expense' ? 'Khoản chi' : 'Khoản thu' }}
            </Tag>
          </div>
          <p class="m-0 text-xs text-muted-foreground mt-0.5">
            Mã: {{ selectedCategory.code }} • Nhóm: {{ selectedCategory.group }} • {{ selectedCategory.description }}
          </p>
        </div>

        <Button size="small">
          <template #icon>
            <IconifyIcon icon="lucide:download" class="size-3.5" />
          </template>
          Xuất sổ khoản mục
        </Button>
      </div>

      <!-- Detail Table -->
      <Table
        :data-source="detailLedgerTransactions"
        :columns="detailColumns"
        :pagination="{ pageSize: 5 }"
        size="small"
        row-key="voucherCode"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'voucherCode'">
            <span class="font-mono font-semibold text-primary">
              {{ record.voucherCode }}
            </span>
          </template>

          <template v-else-if="column.key === 'applicant'">
            <div class="flex flex-col text-xs">
              <span class="font-medium text-foreground">{{ record.applicant }}</span>
              <span class="text-[11px] text-muted-foreground">{{ record.department }}</span>
            </div>
          </template>

          <template v-else-if="column.key === 'amount'">
            <span class="font-bold text-foreground">
              {{ record.amount.toLocaleString() }}
            </span>
          </template>

          <template v-else-if="column.key === 'attachment'">
            <span class="text-primary text-xs flex items-center gap-1 cursor-pointer hover:underline">
              <IconifyIcon icon="lucide:file-text" class="size-3" />
              {{ record.attachment }}
            </span>
          </template>
        </template>
      </Table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

import { Progress, Tag } from 'ant-design-vue';

import { useCashFund } from '../../store';

const { fundSources, transactions } = useCashFund();

const totalOpeningBalance = computed(() => {
  return fundSources.value
    .filter((s) => s.currency === 'VND')
    .reduce((sum, s) => sum + s.initialBalance, 0);
});

const totalReceipts = computed(() => {
  return transactions.value
    .filter((t) => t.type === 'receipt' && t.status === 'completed' && t.currency === 'VND')
    .reduce((sum, t) => sum + t.actualAmount, 0);
});

const totalExpenses = computed(() => {
  return transactions.value
    .filter((t) => t.type === 'expense' && t.status === 'completed' && t.currency === 'VND')
    .reduce((sum, t) => sum + t.actualAmount, 0);
});

const totalClosingBalance = computed(() => {
  return totalOpeningBalance.value + totalReceipts.value - totalExpenses.value;
});

// Mock 6-month trend data
const monthlyTrend = [
  { month: '05/2026', in: 45000000, out: 38000000, balance: 265000000 },
  { month: '06/2026', in: 52000000, out: 49000000, balance: 268000000 },
  { month: '07/2026', in: 48000000, out: 42000000, balance: 274000000 },
  { month: '08/2026', in: 61000000, out: 57000000, balance: 278000000 },
  { month: '09/2026', in: 55000000, out: 51000000, balance: 282000000 },
  { month: '10/2026', in: 38500000, out: 32000000, balance: 288500000 },
];
</script>

<template>
  <div class="flex flex-col gap-5">
    <!-- Top 4 Core KPI Cards -->
    <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
      <!-- Opening Balance -->
      <div class="rounded-xl border border-border bg-card p-4 shadow-2xs">
        <span class="text-xs text-muted-foreground font-medium uppercase tracking-wider block">
          Tồn đầu kỳ
        </span>
        <div class="mt-2 text-2xl font-semibold text-foreground">
          {{ totalOpeningBalance.toLocaleString() }} <span class="text-xs font-normal text-muted-foreground">VND</span>
        </div>
        <span class="text-[11px] text-muted-foreground">Số dư kết chuyển đầu tháng</span>
      </div>

      <!-- Total Receipts -->
      <div class="rounded-xl border border-border bg-card p-4 shadow-2xs">
        <span class="text-xs text-muted-foreground font-medium uppercase tracking-wider block">
          Tổng thu trong kỳ
        </span>
        <div class="mt-2 text-2xl font-semibold text-foreground">
          {{ totalReceipts.toLocaleString() }} <span class="text-xs font-normal text-muted-foreground">VND</span>
        </div>
        <span class="text-[11px] text-muted-foreground">Doanh thu & hoàn ứng nộp vào</span>
      </div>

      <!-- Total Expenses -->
      <div class="rounded-xl border border-border bg-card p-4 shadow-2xs">
        <span class="text-xs text-muted-foreground font-medium uppercase tracking-wider block">
          Tổng chi trong kỳ
        </span>
        <div class="mt-2 text-2xl font-semibold text-foreground">
          {{ totalExpenses.toLocaleString() }} <span class="text-xs font-normal text-muted-foreground">VND</span>
        </div>
        <span class="text-[11px] text-muted-foreground">Tạm ứng & thanh toán chi phí</span>
      </div>

      <!-- Closing Balance -->
      <div class="rounded-xl border border-border bg-card p-4 shadow-2xs">
        <span class="text-xs text-muted-foreground font-medium uppercase tracking-wider block">
          Dư cuối kỳ (Tồn + Thu - Chi)
        </span>
        <div class="mt-2 text-2xl font-semibold text-foreground">
          {{ totalClosingBalance.toLocaleString() }} <span class="text-xs font-normal text-muted-foreground">VND</span>
        </div>
        <span class="text-[11px] text-muted-foreground">Số dư tiền mặt khả dụng</span>
      </div>
    </div>

    <!-- 6-Month Visual Trend & Source Breakdown -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
      <!-- Trend Graph (2 Columns) -->
      <div class="lg:col-span-2 rounded-xl border border-border bg-card p-5 shadow-sm flex flex-col justify-between">
        <div class="flex items-center justify-between mb-4">
          <div>
            <h3 class="m-0 text-base font-bold text-foreground">
              Xu hướng biến động quỹ 6 tháng gần nhất
            </h3>
            <p class="m-0 text-xs text-muted-foreground">
              So sánh tỷ lệ thu vào, chi ra và quỹ tồn dư luỹ kế
            </p>
          </div>
          <div class="flex items-center gap-3 text-xs">
            <span class="flex items-center gap-1.5 text-muted-foreground">
              <span class="size-2.5 rounded-full bg-emerald-500" /> Thu
            </span>
            <span class="flex items-center gap-1.5 text-muted-foreground">
              <span class="size-2.5 rounded-full bg-orange-500" /> Chi
            </span>
            <span class="flex items-center gap-1.5 text-muted-foreground">
              <span class="size-2.5 rounded-full bg-blue-600" /> Tồn quỹ
            </span>
          </div>
        </div>

        <!-- Custom SVG Chart Visualization -->
        <div class="flex flex-col gap-4">
          <div class="grid grid-cols-6 gap-3 items-end h-44 pt-4 border-b border-border">
            <div
              v-for="(t, idx) in monthlyTrend"
              :key="idx"
              class="flex flex-col items-center gap-1.5 h-full justify-end group"
            >
              <div class="flex items-end gap-1.5 w-full justify-center">
                <!-- Bar Thu -->
                <div
                  class="w-3 rounded-t bg-foreground/70 hover:bg-foreground transition-all cursor-pointer"
                  :style="{ height: `${(t.in / 70000000) * 110}px` }"
                  :title="`Thu: ${t.in.toLocaleString()} đ`"
                />
                <!-- Bar Chi -->
                <div
                  class="w-3 rounded-t bg-muted-foreground/40 hover:bg-muted-foreground transition-all cursor-pointer"
                  :style="{ height: `${(t.out / 70000000) * 110}px` }"
                  :title="`Chi: ${t.out.toLocaleString()} đ`"
                />
              </div>
              <span class="text-[11px] font-mono text-muted-foreground group-hover:text-foreground">
                {{ t.month }}
              </span>
            </div>
          </div>

          <div class="grid grid-cols-3 gap-2 text-center text-xs bg-muted/20 p-2.5 rounded-lg border border-border">
            <div>
              <span class="text-muted-foreground block text-[11px]">Tỷ lệ giải ngân</span>
              <span class="font-bold text-foreground">84.2%</span>
            </div>
            <div>
              <span class="text-muted-foreground block text-[11px]">Tốc độ quay vòng quỹ</span>
              <span class="font-bold text-foreground">1.8 lần/tháng</span>
            </div>
            <div>
              <span class="text-muted-foreground block text-[11px]">Tăng trưởng ròng</span>
              <span class="font-bold text-emerald-600">+8.8%</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Fund Sources Breakdown (1 Column) -->
      <div class="rounded-xl border border-border bg-card p-5 shadow-sm flex flex-col gap-3">
        <div>
          <h3 class="m-0 text-base font-bold text-foreground">
            Số dư theo nguồn tiền
          </h3>
          <p class="m-0 text-xs text-muted-foreground">
            Tình hình tồn quỹ tại từng chi nhánh & văn phòng
          </p>
        </div>

        <div class="flex flex-col gap-3 divide-y divide-border/60">
          <div
            v-for="s in fundSources"
            :key="s.id"
            class="pt-3 first:pt-1 flex flex-col gap-1"
          >
            <div class="flex items-center justify-between text-xs">
              <span class="font-medium text-foreground truncate max-w-[180px]">
                {{ s.name }}
              </span>
              <Tag :color="s.status === 'active' ? 'success' : 'default'" class="m-0 text-[10px]">
                {{ s.status === 'active' ? 'Hoạt động' : 'Khóa' }}
              </Tag>
            </div>
            <div class="flex items-center justify-between text-sm">
              <span class="font-bold text-foreground">
                {{ s.currentBalance.toLocaleString() }} <span class="text-xs font-normal text-muted-foreground">{{ s.currency }}</span>
              </span>
              <span class="text-[11px] text-muted-foreground">
                Định mức: {{ s.initialBalance.toLocaleString() }}
              </span>
            </div>
            <Progress
              :percent="Math.min(100, Math.round((s.currentBalance / s.initialBalance) * 100))"
              size="small"
              :status="s.currentBalance < s.initialBalance * 0.3 ? 'exception' : 'normal'"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

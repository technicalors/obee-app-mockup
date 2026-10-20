<script setup lang="ts">
import { ref } from 'vue';

import { Page } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import { Select, Tabs } from 'ant-design-vue';

import { $t } from '#/locales';

import AnalyticsFrequencyTab from './components/AnalyticsFrequencyTab.vue';
import CashMovementLedgerTab from './components/CashMovementLedgerTab.vue';
import FundOverviewTab from './components/FundOverviewTab.vue';
import ItemLedgerTab from './components/ItemLedgerTab.vue';

const activeReportTab = ref('overview');
const reportPeriod = ref('2026-10');
const reportCurrency = ref('VND');
</script>

<template>
  <Page>
    <div class="flex flex-col gap-5 p-4 md:p-6">
      <!-- Header Bar -->
      <div class="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 class="text-xl font-bold tracking-tight text-foreground md:text-2xl m-0">
            {{ $t('cashFund.reports.title') }}
          </h1>
          <p class="text-xs text-muted-foreground mt-1 mb-0">
            {{ $t('cashFund.reports.description') }}
          </p>
        </div>

        <div class="flex flex-wrap items-center gap-3">
          <div class="flex items-center gap-1.5 text-xs text-muted-foreground">
            <span>Kỳ báo cáo:</span>
            <Select v-model:value="reportPeriod" size="small" class="w-36">
              <Select.Option value="2026-10">Tháng 10/2026</Select.Option>
              <Select.Option value="2026-09">Tháng 09/2026</Select.Option>
              <Select.Option value="2026-Q4">Quý 4/2026</Select.Option>
              <Select.Option value="2026-Y">Cả năm 2026</Select.Option>
            </Select>
          </div>

          <div class="flex items-center gap-1.5 text-xs text-muted-foreground">
            <span>Đơn vị tiền:</span>
            <Select v-model:value="reportCurrency" size="small" class="w-24">
              <Select.Option value="VND">VND</Select.Option>
              <Select.Option value="USD">USD</Select.Option>
            </Select>
          </div>
        </div>
      </div>

      <!-- Navigation Tabs for 4 Reports -->
      <div class="rounded-xl border border-border bg-card p-4 shadow-sm">
        <Tabs v-model:activeKey="activeReportTab">
          <!-- Tab 1: CM-UI-06 Tổng hợp quỹ -->
          <Tabs.TabPane key="overview">
            <template #tab>
              <span class="flex items-center gap-1.5">
                <IconifyIcon icon="lucide:layout-dashboard" class="size-4" />
                {{ $t('cashFund.reports.tabs.overview') }}
              </span>
            </template>
            <div class="pt-3">
              <FundOverviewTab />
            </div>
          </Tabs.TabPane>

          <!-- Tab 2: CM-UI-07 Thống kê Thu - Chi & Tần suất -->
          <Tabs.TabPane key="analytics">
            <template #tab>
              <span class="flex items-center gap-1.5">
                <IconifyIcon icon="lucide:bar-chart-2" class="size-4" />
                {{ $t('cashFund.reports.tabs.analytics') }}
              </span>
            </template>
            <div class="pt-3">
              <AnalyticsFrequencyTab />
            </div>
          </Tabs.TabPane>

          <!-- Tab 3: CM-UI-08 Sổ chi tiết khoản Thu - Chi -->
          <Tabs.TabPane key="itemLedger">
            <template #tab>
              <span class="flex items-center gap-1.5">
                <IconifyIcon icon="lucide:book-open" class="size-4" />
                {{ $t('cashFund.reports.tabs.itemLedger') }}
              </span>
            </template>
            <div class="pt-3">
              <ItemLedgerTab />
            </div>
          </Tabs.TabPane>

          <!-- Tab 4: CM-UI-09 Sổ quỹ tiền mặt -->
          <Tabs.TabPane key="cashBook">
            <template #tab>
              <span class="flex items-center gap-1.5">
                <IconifyIcon icon="lucide:receipt" class="size-4" />
                {{ $t('cashFund.reports.tabs.cashBook') }}
              </span>
            </template>
            <div class="pt-3">
              <CashMovementLedgerTab />
            </div>
          </Tabs.TabPane>
        </Tabs>
      </div>
    </div>
  </Page>
</template>

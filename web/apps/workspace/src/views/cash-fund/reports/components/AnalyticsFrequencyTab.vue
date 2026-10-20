<script setup lang="ts">
import { ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Progress, Select, Table, Tag } from 'ant-design-vue';

const selectedYear = ref('2026');

// Matrix data for 12 months
const matrixData = [
  {
    category: 'Chi phí tiếp khách & Đối tác',
    group: 'Chi phí vận hành',
    m1: 4200000,
    m2: 3800000,
    m3: 5100000,
    m4: 6300000,
    m5: 4800000,
    m6: 5500000,
    m7: 4900000,
    m8: 7200000,
    m9: 6800000,
    m10: 6800000,
    m11: 0,
    m12: 0,
    total: 55400000,
  },
  {
    category: 'Công tác phí & Vé máy bay',
    group: 'Chi phí nhân sự',
    m1: 12000000,
    m2: 8500000,
    m3: 14200000,
    m4: 16500000,
    m5: 11000000,
    m6: 18000000,
    m7: 13500000,
    m8: 15000000,
    m9: 14000000,
    m10: 16500000,
    m11: 0,
    m12: 0,
    total: 139200000,
  },
  {
    category: 'Văn phòng phẩm & Tiện ích',
    group: 'Chi phí vận hành',
    m1: 3200000,
    m2: 2900000,
    m3: 3100000,
    m4: 3400000,
    m5: 2800000,
    m6: 3500000,
    m7: 3100000,
    m8: 3300000,
    m9: 3600000,
    m10: 3200000,
    m11: 0,
    m12: 0,
    total: 32100000,
  },
  {
    category: 'Thiết bị & Công cụ CNTT',
    group: 'Mua sắm tài sản',
    m1: 18000000,
    m2: 5000000,
    m3: 22000000,
    m4: 8000000,
    m5: 14000000,
    m6: 25000000,
    m7: 9000000,
    m8: 16000000,
    m9: 11000000,
    m10: 12500000,
    m11: 0,
    m12: 0,
    total: 140500000,
  },
  {
    category: 'Phúc lợi & Bồi dưỡng thêm giờ',
    group: 'Chi phí nhân sự',
    m1: 8500000,
    m2: 15000000,
    m3: 7200000,
    m4: 9100000,
    m5: 8400000,
    m6: 12000000,
    m7: 7800000,
    m8: 9500000,
    m9: 8900000,
    m10: 25000000,
    m11: 0,
    m12: 0,
    total: 111400000,
  },
];

// Frequency Ranking Table
const frequencyRankings = [
  { rank: 1, name: 'Công tác phí & Di chuyển', count: 38, totalAmount: 139200000, percent: 29.1, trend: 'up' },
  { rank: 2, name: 'Thiết bị & Công cụ CNTT', count: 24, totalAmount: 140500000, percent: 29.4, trend: 'up' },
  { rank: 3, name: 'Phúc lợi & Hoạt động tập thể', count: 22, totalAmount: 111400000, percent: 23.3, trend: 'flat' },
  { rank: 4, name: 'Chi phí tiếp khách', count: 19, totalAmount: 55400000, percent: 11.6, trend: 'down' },
  { rank: 5, name: 'Văn phòng phẩm & Tiêu hao', count: 14, totalAmount: 32100000, percent: 6.6, trend: 'flat' },
];

const matrixColumns = [
  { title: 'Khoản mục chi', dataIndex: 'category', key: 'category', width: 200, fixed: 'left' as const },
  { title: 'T1', dataIndex: 'm1', key: 'm1', width: 90, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'T2', dataIndex: 'm2', key: 'm2', width: 90, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'T3', dataIndex: 'm3', key: 'm3', width: 90, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'T4', dataIndex: 'm4', key: 'm4', width: 90, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'T5', dataIndex: 'm5', key: 'm5', width: 90, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'T6', dataIndex: 'm6', key: 'm6', width: 90, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'T7', dataIndex: 'm7', key: 'm7', width: 90, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'T8', dataIndex: 'm8', key: 'm8', width: 90, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'T9', dataIndex: 'm9', key: 'm9', width: 90, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'T10', dataIndex: 'm10', key: 'm10', width: 95, align: 'right' as const, customRender: ({ text }: any) => text ? text.toLocaleString() : '-' },
  { title: 'Tổng lũy kế', dataIndex: 'total', key: 'total', width: 140, align: 'right' as const, fixed: 'right' as const },
];
</script>

<template>
  <div class="flex flex-col gap-5">
    <!-- Top Alert Insight & Warnings -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div class="rounded-xl border border-border bg-muted/20 p-4">
        <div class="flex items-start gap-2.5">
          <IconifyIcon icon="lucide:alert-circle" class="size-4 text-muted-foreground mt-0.5 shrink-0" />
          <div class="text-xs flex flex-col gap-1">
            <span class="font-semibold text-foreground">
              Cảnh báo hạn mức ngân sách tháng 10/2026
            </span>
            <p class="m-0 text-muted-foreground">
              Hạng mục <strong>Phúc lợi & Hoạt động tập thể</strong> đã đạt 92% ngân sách quý do phát sinh tạm ứng Team Building. Đề nghị Kế toán trưởng kiểm soát các khoản chi phát sinh mới.
            </p>
          </div>
        </div>
      </div>

      <div class="rounded-xl border border-border bg-muted/20 p-4">
        <div class="flex items-start gap-2.5">
          <IconifyIcon icon="lucide:trending-up" class="size-4 text-muted-foreground mt-0.5 shrink-0" />
          <div class="text-xs flex flex-col gap-1">
            <span class="font-semibold text-foreground">
              Nhận định tần suất chi tiêu
            </span>
            <p class="m-0 text-muted-foreground">
              Công tác phí và Mua sắm thiết bị CNTT là 02 khoản mục phát sinh thường xuyên nhất (chiếm hơn 58% tổng dòng tiền mặt).
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Frequency Ranking Table (Top phát sinh) -->
    <div class="rounded-xl border border-border bg-card p-5 shadow-sm flex flex-col gap-3">
      <div class="flex items-center justify-between">
        <div>
          <h3 class="m-0 text-base font-bold text-foreground">
            Bảng xếp hạng tần suất các khoản chi tiền mặt
          </h3>
          <p class="m-0 text-xs text-muted-foreground">
            Sắp xếp theo số lần phát sinh hồ sơ đề xuất và tổng số tiền chi trả
          </p>
        </div>
      </div>

      <div class="overflow-x-auto rounded-lg border border-border">
        <table class="w-full text-left text-xs border-collapse">
          <thead class="bg-muted/40 border-b border-border text-muted-foreground uppercase font-semibold">
            <tr>
              <th class="p-3 w-16 text-center">Hạng</th>
              <th class="p-3">Khoản mục chi tiêu</th>
              <th class="p-3 w-32 text-center">Số lượt phát sinh</th>
              <th class="p-3 w-44 text-right">Tổng số tiền đã chi</th>
              <th class="p-3 w-40">Tỷ trọng cơ cấu</th>
              <th class="p-3 w-28 text-center">Xu hướng</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-border/60 bg-card">
            <tr v-for="r in frequencyRankings" :key="r.rank" class="hover:bg-muted/20">
              <td class="p-3 text-center font-mono font-medium text-muted-foreground">
                #{{ r.rank }}
              </td>
              <td class="p-3 font-medium text-foreground text-xs">
                {{ r.name }}
              </td>
              <td class="p-3 text-center text-foreground text-xs">
                {{ r.count }} lần
              </td>
              <td class="p-3 text-right font-medium text-foreground text-xs">
                {{ r.totalAmount.toLocaleString() }} VND
              </td>
              <td class="p-3">
                <div class="flex items-center gap-2">
                  <Progress :percent="r.percent" size="small" class="flex-1 m-0" />
                  <span class="text-xs text-muted-foreground font-mono w-10 text-right">{{ r.percent }}%</span>
                </div>
              </td>
              <td class="p-3 text-center">
                <Tag class="m-0 text-[11px]">
                  {{ r.trend === 'up' ? 'Tăng' : r.trend === 'down' ? 'Giảm' : 'Ổn định' }}
                </Tag>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 12-Month Matrix Table -->
    <div class="rounded-xl border border-border bg-card p-5 shadow-sm flex flex-col gap-3">
      <div class="flex items-center justify-between">
        <div>
          <h3 class="m-0 text-base font-bold text-foreground">
            Ma trận chi tiết chi tiêu 12 tháng (Năm {{ selectedYear }})
          </h3>
          <p class="m-0 text-xs text-muted-foreground">
            Số liệu luỹ kế từng tháng theo nhóm danh mục chi phí tiền mặt
          </p>
        </div>

        <Select v-model:value="selectedYear" size="small" class="w-28">
          <Select.Option value="2026">Năm 2026</Select.Option>
          <Select.Option value="2025">Năm 2025</Select.Option>
        </Select>
      </div>

      <Table
        :data-source="matrixData"
        :columns="matrixColumns"
        :pagination="false"
        :scroll="{ x: 1300 }"
        size="small"
        row-key="category"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'category'">
            <div class="flex flex-col">
              <span class="font-semibold text-foreground text-xs">{{ record.category }}</span>
              <span class="text-[10px] text-muted-foreground">{{ record.group }}</span>
            </div>
          </template>
          <template v-else-if="column.key === 'total'">
            <span class="font-bold text-primary">
              {{ record.total.toLocaleString() }}
            </span>
          </template>
        </template>
      </Table>
    </div>
  </div>
</template>

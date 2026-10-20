<script setup lang="ts">
import type { FundSource, MasterCategory } from '../types';

import { ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Badge,
  Button,
  Table,
  Tabs,
  Tag,
  Tooltip,
} from 'ant-design-vue';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useCashFund } from '../store';
import CategoryFormModal from './components/CategoryFormModal.vue';
import FundSourceFormModal from './components/FundSourceFormModal.vue';

const {
  categories,
  currencies,
  fundSources,
  toggleCategoryStatus,
} = useCashFund();

const activeTab = ref('categories');

const isCategoryModalOpen = ref(false);
const selectedCategory = ref<MasterCategory | null>(null);

const isFundSourceModalOpen = ref(false);
const selectedFundSource = ref<FundSource | null>(null);

function openCreateCategory() {
  selectedCategory.value = null;
  isCategoryModalOpen.value = true;
}

function openEditCategory(cat: MasterCategory) {
  selectedCategory.value = cat;
  isCategoryModalOpen.value = true;
}

function openCreateFundSource() {
  selectedFundSource.value = null;
  isFundSourceModalOpen.value = true;
}

function openEditFundSource(src: FundSource) {
  selectedFundSource.value = src;
  isFundSourceModalOpen.value = true;
}

// Workflows configuration table
const workflowRules = [
  {
    type: 'Tạm ứng tiền mặt',
    steps: 'Người lập → Trưởng BP → Kế toán thanh toán → CFO → Thủ quỹ chi tiền',
    note: 'Áp dụng cho mọi khoản chi công tác, mua sắm trước giải ngân.',
  },
  {
    type: 'Thanh toán khoản chi',
    steps: 'Người lập → Trưởng BP → Kế toán thanh toán → CFO → Thủ quỹ',
    note: 'Bắt buộc hóa đơn, chứng từ hợp lệ trước khi thanh toán.',
  },
  {
    type: 'Thu tiền vào quỹ',
    steps: 'Người nộp → Kế toán duyệt thu → Thủ quỹ thu tiền & ký biên lai',
    note: 'Thu hoàn ứng thừa, thu phạt, thu phí dịch vụ tiền mặt.',
  },
  {
    type: 'Quyết toán hoàn ứng',
    steps: 'Người lập → Trưởng BP → Kế toán kiểm tra hóa đơn → CFO duyệt chênh lệch',
    note: 'Sinh phiếu chi nếu chi thêm; sinh phiếu thu nếu hoàn trả thừa.',
  },
  {
    type: 'Điều chỉnh chuyển quỹ',
    steps: 'Kế toán trưởng → CFO → TGĐ công ty nguồn → TGĐ cấp cuối',
    note: 'Chuyển số dư giữa 2 nguồn tiền; tổng quỹ không thay đổi.',
  },
];

const categoryColumns = [
  {
    title: 'STT',
    key: 'sequence',
    width: 55,
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
  },
  { title: 'Mã', dataIndex: 'code', key: 'code', width: 110, fixed: 'left' as const },
  { title: 'Tên khoản mục', dataIndex: 'name', key: 'name', width: 220 },
  { title: 'Loại', dataIndex: 'type', key: 'type', width: 120 },
  { title: 'Nhóm phân loại', dataIndex: 'group', key: 'group', width: 180 },
  { title: 'Mô tả', dataIndex: 'description', key: 'description' },
  { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 140 },
  { title: 'Thao tác', key: 'actions', width: 110, align: 'center' as const, fixed: 'right' as const },
];

const fundSourceColumns = [
  {
    title: 'STT',
    key: 'sequence',
    width: 55,
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
  },
  { title: 'Mã nguồn', dataIndex: 'code', key: 'code', width: 120 },
  { title: 'Tên nguồn tiền quỹ', dataIndex: 'name', key: 'name', width: 240 },
  { title: 'Đơn vị sở hữu', dataIndex: 'company', key: 'company' },
  { title: 'Loại tiền', dataIndex: 'currency', key: 'currency', width: 100 },
  { title: 'Hạn mức ban đầu', dataIndex: 'initialBalance', key: 'initialBalance', width: 160, align: 'right' as const },
  { title: 'Số dư hiện tại', dataIndex: 'currentBalance', key: 'currentBalance', width: 160, align: 'right' as const },
  { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 130 },
  { title: 'Thao tác', key: 'actions', width: 80, align: 'center' as const, fixed: 'right' as const },
];

const currencyColumns = [
  {
    title: 'STT',
    key: 'sequence',
    width: 55,
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
  },
  { title: 'Mã tiền tệ', dataIndex: 'code', key: 'code', width: 120 },
  { title: 'Tên loại tiền', dataIndex: 'name', key: 'name', width: 220 },
  { title: 'Ký hiệu', dataIndex: 'symbol', key: 'symbol', width: 100 },
  { title: 'Tỷ giá tham chiếu (VND)', dataIndex: 'exchangeRate', key: 'exchangeRate', width: 200, align: 'right' as const },
  { title: 'Mặc định', dataIndex: 'isDefault', key: 'isDefault', width: 120 },
  { title: 'Trạng thái', dataIndex: 'status', key: 'status', width: 130 },
];
</script>

<template>
  <ResourceListPage>
    <div class="flex h-full min-h-0 flex-col overflow-hidden rounded border border-border bg-background">
      <!-- Toolbar matching Masterdata Users -->
      <div class="flex shrink-0 items-center justify-between border-b border-border px-4 py-3">
        <div class="flex min-w-0 flex-col gap-0.5">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('cashFund.masterData.title') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('cashFund.masterData.description') }}
          </p>
        </div>
      </div>

      <!-- Main Content Tabs Container -->
      <div class="flex-1 min-h-0 overflow-auto p-4">
        <Tabs v-model:activeKey="activeTab">
          <!-- TAB 1: Khoản thu / chi -->
          <Tabs.TabPane key="categories">
            <template #tab>
              <span class="flex items-center gap-1.5">
                <IconifyIcon icon="lucide:list-tree" class="size-4" />
                {{ $t('cashFund.masterData.tabs.categories') }} ({{ categories.length }})
              </span>
            </template>

            <div class="flex flex-col gap-3 pt-1">
              <div class="flex justify-between items-center">
                <span class="text-xs text-muted-foreground">
                  Khoản thu/chi chuẩn hóa phục vụ nhập liệu cho các đề xuất tiền mặt
                </span>
                <Button type="primary" size="small" @click="openCreateCategory">
                  <template #icon>
                    <IconifyIcon icon="lucide:plus" class="size-3.5" />
                  </template>
                  {{ $t('cashFund.masterData.addCategory') }}
                </Button>
              </div>

              <Table
                :data-source="categories"
                :columns="categoryColumns"
                :pagination="{ pageSize: 10, showSizeChanger: true }"
                size="small"
                bordered
                row-key="id"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'code'">
                    <span class="font-mono font-bold text-foreground">{{ record.code }}</span>
                  </template>

                  <template v-else-if="column.key === 'type'">
                    <Tag>
                      {{ record.type === 'expense' ? 'Khoản chi' : 'Khoản thu' }}
                    </Tag>
                  </template>

                  <template v-else-if="column.key === 'status'">
                    <Badge
                      :status="record.status === 'active' ? 'success' : 'default'"
                      :text="record.status === 'active' ? $t('cashFund.masterData.active') : $t('cashFund.masterData.inactive')"
                    />
                  </template>

                  <template v-else-if="column.key === 'actions'">
                    <div class="flex items-center justify-center gap-1">
                      <Tooltip title="Chỉnh sửa">
                        <Button
                          type="text"
                          size="small"
                          class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground hover:text-primary"
                          @click="openEditCategory(record as MasterCategory)"
                        >
                          <template #icon>
                            <IconifyIcon icon="lucide:pencil" class="size-4" />
                          </template>
                        </Button>
                      </Tooltip>

                      <Tooltip :title="record.status === 'active' ? 'Ngưng sử dụng' : 'Kích hoạt lại'">
                        <Button
                          type="text"
                          size="small"
                          class="inline-flex size-7 items-center justify-center p-0"
                          :class="record.status === 'active' ? 'text-destructive hover:text-destructive' : 'text-emerald-600 hover:text-emerald-700'"
                          @click="toggleCategoryStatus(record.id)"
                        >
                          <template #icon>
                            <IconifyIcon :icon="record.status === 'active' ? 'lucide:ban' : 'lucide:check-circle-2'" class="size-4" />
                          </template>
                        </Button>
                      </Tooltip>
                    </div>
                  </template>
                </template>
              </Table>
            </div>
          </Tabs.TabPane>

          <!-- TAB 2: Nguồn tiền -->
          <Tabs.TabPane key="fundSources">
            <template #tab>
              <span class="flex items-center gap-1.5">
                <IconifyIcon icon="lucide:wallet" class="size-4" />
                {{ $t('cashFund.masterData.tabs.fundSources') }} ({{ fundSources.length }})
              </span>
            </template>

            <div class="flex flex-col gap-3 pt-1">
              <div class="flex justify-between items-center">
                <span class="text-xs text-muted-foreground">
                  Các quỹ tiền mặt và tài khoản tiền mặt tại trụ sở và các chi nhánh
                </span>
                <Button type="primary" size="small" @click="openCreateFundSource">
                  <template #icon>
                    <IconifyIcon icon="lucide:plus" class="size-3.5" />
                  </template>
                  {{ $t('cashFund.masterData.addFundSource') }}
                </Button>
              </div>

              <Table
                :data-source="fundSources"
                :columns="fundSourceColumns"
                :pagination="false"
                size="small"
                bordered
                row-key="id"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'code'">
                    <span class="font-mono font-bold text-foreground">{{ record.code }}</span>
                  </template>

                  <template v-else-if="column.key === 'initialBalance'">
                    <span>{{ record.initialBalance.toLocaleString() }} {{ record.currency }}</span>
                  </template>

                  <template v-else-if="column.key === 'currentBalance'">
                    <span class="font-semibold text-foreground">
                      {{ record.currentBalance.toLocaleString() }} {{ record.currency }}
                    </span>
                  </template>

                  <template v-else-if="column.key === 'status'">
                    <Badge
                      :status="record.status === 'active' ? 'success' : record.status === 'locked' ? 'warning' : 'default'"
                      :text="record.status === 'active' ? 'Hoạt động' : record.status === 'locked' ? 'Tạm khóa' : 'Ngưng dùng'"
                    />
                  </template>

                  <template v-else-if="column.key === 'actions'">
                    <div class="flex items-center justify-center">
                      <Tooltip title="Chỉnh sửa nguồn tiền">
                        <Button
                          type="text"
                          size="small"
                          class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground hover:text-primary"
                          @click="openEditFundSource(record as FundSource)"
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
            </div>
          </Tabs.TabPane>

          <!-- TAB 3: Loại tiền -->
          <Tabs.TabPane key="currencies">
            <template #tab>
              <span class="flex items-center gap-1.5">
                <IconifyIcon icon="lucide:coins" class="size-4" />
                {{ $t('cashFund.masterData.tabs.currencies') }}
              </span>
            </template>

            <div class="flex flex-col gap-3 pt-1">
              <span class="text-xs text-muted-foreground">
                Đồng tiền giao dịch hợp lệ và bảng tỷ giá quy đổi tham chiếu
              </span>

              <Table
                :data-source="currencies"
                :columns="currencyColumns"
                :pagination="false"
                size="small"
                bordered
                row-key="code"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'code'">
                    <span class="font-mono font-bold text-foreground">{{ record.code }}</span>
                  </template>
                  <template v-else-if="column.key === 'exchangeRate'">
                    <span class="font-mono font-medium">{{ record.exchangeRate.toLocaleString() }}</span>
                  </template>
                  <template v-else-if="column.key === 'isDefault'">
                    <Tag v-if="record.isDefault">Mặc định</Tag>
                    <span v-else class="text-muted-foreground">-</span>
                  </template>
                  <template v-else-if="column.key === 'status'">
                    <Badge status="success" text="Đang sử dụng" />
                  </template>
                </template>
              </Table>
            </div>
          </Tabs.TabPane>

          <!-- TAB 4: Tuyến phê duyệt -->
          <Tabs.TabPane key="workflows">
            <template #tab>
              <span class="flex items-center gap-1.5">
                <IconifyIcon icon="lucide:git-branch" class="size-4" />
                {{ $t('cashFund.masterData.tabs.workflows') }}
              </span>
            </template>

            <div class="flex flex-col gap-3 pt-1">
              <span class="text-xs text-muted-foreground">
                Cấu hình phân cấp các bước phê duyệt theo từng nghiệp vụ quỹ tiền mặt
              </span>

              <div class="flex flex-col gap-3">
                <div
                  v-for="(wf, idx) in workflowRules"
                  :key="idx"
                  class="rounded-lg border border-border bg-card p-3.5 flex flex-col gap-2"
                >
                  <div class="flex items-center justify-between">
                    <span class="font-medium text-sm text-foreground">{{ wf.type }}</span>
                  </div>
                  <div class="rounded-lg bg-muted/20 p-2.5 font-medium text-xs text-foreground flex items-center gap-2">
                    <IconifyIcon icon="lucide:arrow-right" class="size-4 shrink-0 text-muted-foreground" />
                    <span>{{ wf.steps }}</span>
                  </div>
                  <p class="m-0 text-xs text-muted-foreground italic">
                    Ghi chú: {{ wf.note }}
                  </p>
                </div>
              </div>
            </div>
          </Tabs.TabPane>
        </Tabs>
      </div>
    </div>

    <!-- Modals -->
    <CategoryFormModal
      v-model:open="isCategoryModalOpen"
      :category="selectedCategory"
    />

    <FundSourceFormModal
      v-model:open="isFundSourceModalOpen"
      :fund-source="selectedFundSource"
    />
  </ResourceListPage>
</template>

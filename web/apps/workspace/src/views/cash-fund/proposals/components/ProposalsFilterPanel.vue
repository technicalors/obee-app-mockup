<script setup lang="ts">
import { IconifyIcon } from '@vben/icons';

import { Badge, Button, Form, Input, Select } from 'ant-design-vue';

import { $t } from '#/locales';

interface FilterModel {
  keyword: string;
  status: string;
  type: string;
}

const props = defineProps<{
  activeFilterCount: number;
  closable?: boolean;
}>();

const emit = defineEmits<{
  apply: [];
  close: [];
  reset: [];
}>();

const filters = defineModel<FilterModel>('filters', {
  required: true,
});
</script>

<template>
  <section
    aria-labelledby="proposals-filter-title"
    class="flex h-full min-h-0 flex-col overflow-hidden bg-background"
  >
    <header class="shrink-0 border-b border-border px-4 py-2.5">
      <div class="flex items-center gap-2">
        <IconifyIcon
          aria-hidden="true"
          class="size-4 text-primary"
          icon="lucide:list-filter"
        />
        <h3 id="proposals-filter-title" class="m-0 text-sm font-semibold">
          Bộ lọc đề xuất
        </h3>
        <Badge
          :count="activeFilterCount"
          color="var(--ant-color-primary)"
        />
        <Button
          v-if="closable"
          type="text"
          size="small"
          class="inline-flex size-6 items-center justify-center p-0"
          @click="emit('close')"
        >
          <template #icon>
            <IconifyIcon icon="lucide:x" class="size-4" />
          </template>
        </Button>
        <Button
          class="ml-auto h-auto p-0 text-xs"
          type="link"
          @click="emit('reset')"
        >
          Đặt lại
        </Button>
      </div>
    </header>

    <Form
      class="flex min-h-0 flex-1 flex-col"
      layout="vertical"
      :model="filters"
      @finish="emit('apply')"
    >
      <div class="flex min-h-0 flex-1 flex-col gap-3.5 overflow-y-auto p-4 text-xs">
        <!-- Search Keyword -->
        <div>
          <label class="font-semibold text-muted-foreground uppercase tracking-wider block mb-1 text-[11px]">
            Từ khóa tìm kiếm
          </label>
          <Input
            v-model:value="filters.keyword"
            placeholder="Mã phiếu, nội dung, người đề nghị..."
            allow-clear
          >
            <template #prefix>
              <IconifyIcon icon="lucide:search" class="text-muted-foreground size-3.5" />
            </template>
          </Input>
        </div>

        <!-- Proposal Type -->
        <div>
          <label class="font-semibold text-muted-foreground uppercase tracking-wider block mb-1 text-[11px]">
            Loại đề xuất
          </label>
          <Select v-model:value="filters.type" class="w-full">
            <Select.Option value="all">
              {{ $t('cashFund.proposals.filter.allTypes') }}
            </Select.Option>
            <Select.Option value="advance">
              {{ $t('cashFund.proposals.types.advance') }}
            </Select.Option>
            <Select.Option value="payment">
              {{ $t('cashFund.proposals.types.payment') }}
            </Select.Option>
            <Select.Option value="receipt">
              {{ $t('cashFund.proposals.types.receipt') }}
            </Select.Option>
            <Select.Option value="settlement">
              {{ $t('cashFund.proposals.types.settlement') }}
            </Select.Option>
          </Select>
        </div>

        <!-- Status -->
        <div>
          <label class="font-semibold text-muted-foreground uppercase tracking-wider block mb-1 text-[11px]">
            Trạng thái xử lý
          </label>
          <Select v-model:value="filters.status" class="w-full">
            <Select.Option value="all">
              {{ $t('cashFund.proposals.filter.allStatus') }}
            </Select.Option>
            <Select.Option value="pending_dept">Chờ Trưởng BP</Select.Option>
            <Select.Option value="pending_accountant">Chờ Kế toán</Select.Option>
            <Select.Option value="pending_cfo">Chờ CFO</Select.Option>
            <Select.Option value="voucher_issued">Đã phát hành phiếu</Select.Option>
            <Select.Option value="completed">Hoàn thành</Select.Option>
            <Select.Option value="return_edit">Yêu cầu chỉnh sửa</Select.Option>
            <Select.Option value="rejected">Từ chối</Select.Option>
            <Select.Option value="draft">Nháp</Select.Option>
          </Select>
        </div>
      </div>

      <footer class="mt-auto shrink-0 border-t border-border p-4">
        <Button
          block
          html-type="submit"
          type="primary"
        >
          <template #icon>
            <IconifyIcon icon="lucide:search" class="size-4" />
          </template>
          Áp dụng
        </Button>
      </footer>
    </Form>
  </section>
</template>

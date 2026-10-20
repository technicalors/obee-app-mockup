<script setup lang="ts">
import { IconifyIcon } from '@vben/icons';

import { Badge, Button, Form, Input, Select } from 'ant-design-vue';

interface FilterModel {
  keyword: string;
  status: string;
}

defineProps<{
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
    aria-labelledby="adjustments-filter-title"
    class="flex h-full min-h-0 flex-col overflow-hidden bg-background"
  >
    <header class="shrink-0 border-b border-border px-4 py-2.5">
      <div class="flex items-center gap-2">
        <IconifyIcon
          aria-hidden="true"
          class="size-4 text-primary"
          icon="lucide:list-filter"
        />
        <h3 id="adjustments-filter-title" class="m-0 text-sm font-semibold">
          Bộ lọc điều chỉnh
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
        <div>
          <label class="font-semibold text-muted-foreground uppercase tracking-wider block mb-1 text-[11px]">
            Từ khóa
          </label>
          <Input
            v-model:value="filters.keyword"
            placeholder="Mã điều chỉnh, tên nguồn, lý do..."
            allow-clear
          >
            <template #prefix>
              <IconifyIcon icon="lucide:search" class="text-muted-foreground size-3.5" />
            </template>
          </Input>
        </div>

        <div>
          <label class="font-semibold text-muted-foreground uppercase tracking-wider block mb-1 text-[11px]">
            Trạng thái điều chuyển
          </label>
          <Select v-model:value="filters.status" class="w-full">
            <Select.Option value="all">Tất cả trạng thái</Select.Option>
            <Select.Option value="pending_accountant">Chờ Kế toán trưởng</Select.Option>
            <Select.Option value="pending_cfo">Chờ CFO</Select.Option>
            <Select.Option value="pending_source_ceo">Chờ TGĐ nguồn</Select.Option>
            <Select.Option value="completed">Đã hoàn thành</Select.Option>
            <Select.Option value="rejected">Từ chối</Select.Option>
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

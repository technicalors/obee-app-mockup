<script setup lang="ts">
import { ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Badge, Button, Form } from 'ant-design-vue';

import {
  MAX_SIDEBAR_WIDTH,
  MIN_SIDEBAR_WIDTH,
  useResizableFilterSidebar,
} from '#/shared/filter-sidebar/use-resizable-filter-sidebar';
import { ResourceListPage } from '#/shared/resource-table';

defineProps<{
  activeFilterCount: number;
  description: string;
  filterTitle: string;
  title: string;
}>();

const emit = defineEmits<{
  apply: [];
  reset: [];
}>();

const filtersOpen = ref(false);
const content = ref<HTMLElement | null>(null);
const filterTrigger = ref<null | { $el: HTMLElement }>(null);

const {
  compact,
  resize,
  resizeWithKeyboard,
  startResize,
  stopResize,
  width: filterWidth,
} = useResizableFilterSidebar({
  content,
  open: filtersOpen,
  trigger: filterTrigger,
});

function apply() {
  emit('apply');
  filtersOpen.value = false;
}
</script>

<template>
  <ResourceListPage>
    <div
      ref="content"
      class="flex h-full min-h-0 min-w-0 flex-1 items-stretch"
      :class="compact ? 'flex-col gap-4 overflow-y-auto' : 'flex-row'"
    >
      <aside
        v-if="!compact || filtersOpen"
        class="flex h-full min-h-0 shrink-0 flex-col overflow-hidden rounded border border-border bg-background"
        :class="compact ? 'max-h-[55%] w-full' : ''"
        :style="compact ? undefined : { width: `${filterWidth}px` }"
      >
        <section
          class="flex h-full min-h-0 flex-col overflow-hidden bg-background"
        >
          <header class="shrink-0 border-b border-border px-4 py-2.5">
            <div class="flex items-center gap-2">
              <IconifyIcon
                aria-hidden="true"
                class="size-4 text-primary"
                icon="lucide:list-filter"
              />
              <h3 class="m-0 text-sm font-semibold">{{ filterTitle }}</h3>
              <Badge
                :count="activeFilterCount"
                color="var(--ant-color-primary)"
              />
              <Button
                v-if="compact"
                type="text"
                size="small"
                class="inline-flex size-6 items-center justify-center p-0"
                @click="filtersOpen = false"
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
            @finish="apply"
          >
            <div
              class="flex min-h-0 flex-1 flex-col gap-3.5 overflow-y-auto p-4 text-xs"
            >
              <slot name="filters"></slot>
            </div>
            <footer class="mt-auto shrink-0 border-t border-border p-4">
              <Button block html-type="submit" type="primary">
                <template #icon>
                  <IconifyIcon icon="lucide:search" class="size-4" />
                </template>
                Áp dụng
              </Button>
            </footer>
          </Form>
        </section>
      </aside>

      <div
        v-if="!compact"
        aria-orientation="vertical"
        aria-label="Kéo để điều chỉnh kích thước bộ lọc"
        :aria-valuemax="MAX_SIDEBAR_WIDTH"
        :aria-valuemin="MIN_SIDEBAR_WIDTH"
        :aria-valuenow="filterWidth"
        class="group flex w-2 shrink-0 cursor-col-resize touch-none items-center justify-center outline-none focus-visible:ring-2 focus-visible:ring-primary"
        role="separator"
        tabindex="0"
        @keydown="resizeWithKeyboard"
        @pointercancel="stopResize"
        @pointerdown="startResize"
        @pointermove="resize"
        @pointerup="stopResize"
      >
        <span
          class="h-10 w-1 rounded-full bg-border transition-colors group-hover:bg-primary group-focus-visible:bg-primary"
        ></span>
      </div>

      <div
        class="flex h-full min-h-0 min-w-0 flex-1 flex-col overflow-hidden rounded border border-border bg-background"
      >
        <div
          class="flex shrink-0 flex-wrap items-center justify-between gap-2 border-b border-border px-4 py-3"
        >
          <div class="flex min-w-0 flex-col gap-0.5">
            <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
              {{ title }}
            </h2>
            <p class="m-0 text-xs text-muted-foreground">{{ description }}</p>
          </div>
          <div class="flex items-center gap-2">
            <Badge v-if="compact" :count="activeFilterCount">
              <Button
                ref="filterTrigger"
                :aria-expanded="filtersOpen"
                @click="filtersOpen = true"
              >
                <template #icon>
                  <IconifyIcon aria-hidden="true" icon="lucide:list-filter" />
                </template>
                Bộ lọc
              </Button>
            </Badge>
            <slot name="actions"></slot>
          </div>
        </div>
        <slot name="summary"></slot>
        <div class="min-h-0 flex-1 overflow-auto">
          <slot></slot>
        </div>
      </div>
    </div>
  </ResourceListPage>
</template>

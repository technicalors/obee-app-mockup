<script setup lang="ts">
import type { ApprovalHistoryItem, ApprovalStep } from '../types';

import { computed } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Empty, Tag, Timeline } from 'ant-design-vue';

import { HISTORY_COLOR, HISTORY_LABEL, ROLE_LABELS } from '../utils';

const props = defineProps<{
  currentStep: number;
  history: ApprovalHistoryItem[];
  /** pending | approved | rejected | return_edit | draft | ... */
  status: string;
  steps: ApprovalStep[];
}>();

type StepState = 'current' | 'done' | 'skipped' | 'stopped' | 'waiting';

const stepStates = computed<StepState[]>(() =>
  props.steps.map((step, index) => {
    if (step.skipped) return 'skipped';
    if (index < props.currentStep) return 'done';
    if (index === props.currentStep) {
      if (props.status === 'pending') return 'current';
      if (props.status === 'rejected' || props.status === 'return_edit')
        return 'stopped';
    }
    return 'waiting';
  }),
);

const STATE_STYLE: Record<
  StepState,
  { cls: string; icon: string; text: string }
> = {
  current: {
    cls: 'border-primary bg-primary/5 text-primary',
    icon: 'lucide:loader',
    text: 'Đang chờ duyệt',
  },
  done: {
    cls: 'border-green-500/50 bg-green-500/5 text-green-600',
    icon: 'lucide:check',
    text: 'Đã duyệt',
  },
  skipped: {
    cls: 'border-dashed border-border text-muted-foreground',
    icon: 'lucide:skip-forward',
    text: 'Bỏ qua (người tạo giữ vai trò)',
  },
  stopped: {
    cls: 'border-orange-400/60 bg-orange-400/5 text-orange-600',
    icon: 'lucide:corner-up-left',
    text: 'Dừng tại cấp này',
  },
  waiting: {
    cls: 'border-border text-muted-foreground',
    icon: 'lucide:clock',
    text: 'Chưa đến lượt',
  },
};
</script>

<template>
  <div class="flex flex-col gap-4">
    <ol class="m-0 grid list-none grid-cols-2 gap-2 p-0 md:grid-cols-4">
      <li
        v-for="(step, index) in steps"
        :key="step.role"
        class="flex flex-col gap-1 rounded-md border p-2.5"
        :class="STATE_STYLE[stepStates[index]!].cls"
      >
        <div
          class="flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-wider"
        >
          <IconifyIcon
            :icon="STATE_STYLE[stepStates[index]!].icon"
            class="size-3.5"
          />
          {{ index + 1 }}. {{ ROLE_LABELS[step.role] }}
        </div>
        <span
          class="text-sm font-medium text-foreground"
          :class="step.skipped ? 'line-through opacity-60' : ''"
        >
          {{ step.approverName }}
        </span>
        <span class="text-[11px]">{{
          STATE_STYLE[stepStates[index]!].text
        }}</span>
      </li>
    </ol>

    <Empty
      v-if="history.length === 0"
      :image="Empty.PRESENTED_IMAGE_SIMPLE"
      description="Chưa có lịch sử (phiếu nháp)."
    />
    <Timeline v-else class="mt-1 pl-1">
      <Timeline.Item
        v-for="(item, index) in history"
        :key="index"
        :color="HISTORY_COLOR[item.action]"
      >
        <div class="flex flex-col gap-1">
          <div class="flex flex-wrap items-center gap-2">
            <span class="text-sm font-semibold text-foreground">{{
              item.actorName
            }}</span>
            <Tag class="m-0 text-xs font-normal">{{ item.role }}</Tag>
            <span class="text-xs text-muted-foreground">{{
              HISTORY_LABEL[item.action]
            }}</span>
            <span class="ml-auto font-mono text-xs text-muted-foreground">{{
              item.timestamp
            }}</span>
          </div>
          <p
            v-if="item.comment"
            class="m-0 rounded border border-border/50 bg-muted/40 p-2 text-xs text-muted-foreground"
          >
            {{ item.comment }}
          </p>
        </div>
      </Timeline.Item>
    </Timeline>
  </div>
</template>

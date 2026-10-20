<script setup lang="ts">
import type { FundAdjustment } from '../../types';

import { computed } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Badge,
  Button,
  Card,
  Descriptions,
  Modal,
  Tag,
  Timeline,
} from 'ant-design-vue';

import { $t } from '#/locales';

const props = defineProps<{
  adjustment: FundAdjustment | null;
  open: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:open', val: boolean): void;
}>();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

function getStatusBadge(status: string) {
  switch (status) {
    case 'completed': {
      return { status: 'success', text: 'Hoàn thành' };
    }
    case 'rejected': {
      return { status: 'error', text: 'Từ chối' };
    }
    case 'return_edit': {
      return { status: 'warning', text: 'Yêu cầu sửa' };
    }
    default: {
      return { status: 'processing', text: 'Chờ phê duyệt' };
    }
  }
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="$t('cashFund.adjustments.viewDetail')"
    width="760px"
    destroy-on-close
    :footer="null"
  >
    <div v-if="adjustment" class="flex flex-col gap-4 py-2">
      <!-- Header Banner -->
      <div class="flex flex-wrap items-center justify-between gap-4 rounded-lg bg-muted/40 p-4 border border-border">
        <div>
          <span class="font-mono text-base font-bold text-foreground">{{ adjustment.code }}</span>
          <div class="mt-1">
            <Badge
              :status="getStatusBadge(adjustment.status).status as any"
              :text="getStatusBadge(adjustment.status).text"
            />
          </div>
        </div>

        <div class="text-right">
          <div class="text-xs text-muted-foreground">Số tiền điều chuyển</div>
          <div class="text-2xl font-bold text-primary">
            {{ adjustment.amount.toLocaleString() }} {{ adjustment.currency }}
          </div>
        </div>
      </div>

      <!-- Transfer Flow Graphic -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 rounded-lg bg-card p-4 border border-border">
        <div class="rounded border border-border bg-muted/20 p-3 text-xs">
          <div class="font-semibold text-muted-foreground uppercase tracking-wider mb-1">
            Nguồn chuyển (Đi)
          </div>
          <div class="text-sm font-semibold text-foreground">{{ adjustment.fromSourceName }}</div>
          <div class="text-muted-foreground mt-0.5">{{ adjustment.fromCompany }}</div>
        </div>

        <div class="rounded border border-border bg-muted/20 p-3 text-xs">
          <div class="font-semibold text-muted-foreground uppercase tracking-wider mb-1">
            Nguồn nhận (Đến)
          </div>
          <div class="text-sm font-semibold text-foreground">{{ adjustment.toSourceName }}</div>
          <div class="text-muted-foreground mt-0.5">{{ adjustment.toCompany }}</div>
        </div>
      </div>

      <!-- Information Descriptions -->
      <Descriptions bordered size="small" :column="{ xs: 1, sm: 2 }">
        <Descriptions.Item label="Ngày gửi yêu cầu">
          {{ adjustment.requestDate }}
        </Descriptions.Item>
        <Descriptions.Item label="Thời gian hiệu lực">
          {{ adjustment.effectiveDate }}
        </Descriptions.Item>
        <Descriptions.Item label="Cấp xử lý hiện tại">
          {{ adjustment.currentApprover }}
        </Descriptions.Item>
        <Descriptions.Item label="Hồ sơ chứng từ">
          <span v-if="adjustment.attachmentName" class="flex items-center gap-1 text-primary cursor-pointer hover:underline">
            <IconifyIcon icon="lucide:file-text" class="size-3.5" />
            {{ adjustment.attachmentName }} ({{ adjustment.attachmentSize }})
          </span>
          <span v-else class="text-muted-foreground italic">Không có</span>
        </Descriptions.Item>
        <Descriptions.Item label="Lý do điều chuyển" :span="2">
          {{ adjustment.reason }}
        </Descriptions.Item>
      </Descriptions>

      <!-- Approval Timeline -->
      <Card size="small" title="Tiến trình phê duyệt điều chuyển" class="border border-border">
        <Timeline class="pl-2 mt-2">
          <Timeline.Item
            v-for="(hist, idx) in adjustment.approvalHistory"
            :key="idx"
            :color="hist.action === 'approved' || hist.action === 'completed' ? 'green' : hist.action === 'rejected' ? 'red' : 'blue'"
          >
            <div class="flex flex-col gap-0.5 text-xs">
              <div class="flex items-center gap-2">
                <span class="font-semibold text-foreground">{{ hist.approverName }}</span>
                <Tag size="small">{{ hist.role }}</Tag>
                <Tag size="small" :color="hist.action === 'completed' || hist.action === 'approved' ? 'success' : 'processing'">
                  {{ hist.actionLabel }}
                </Tag>
                <span class="text-muted-foreground ml-auto">{{ hist.timestamp }}</span>
              </div>
              <p v-if="hist.comment" class="m-0 text-muted-foreground italic">
                "{{ hist.comment }}"
              </p>
            </div>
          </Timeline.Item>
        </Timeline>
      </Card>

      <div class="flex justify-end pt-2">
        <Button @click="visible = false">Đóng</Button>
      </div>
    </div>
  </Modal>
</template>

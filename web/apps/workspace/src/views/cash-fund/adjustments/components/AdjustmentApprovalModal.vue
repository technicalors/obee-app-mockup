<script setup lang="ts">
import type { FundAdjustment } from '../../types';

import { computed, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Descriptions,
  Input,
  message,
  Modal,
  Popconfirm,
} from 'ant-design-vue';

import { useCashFund } from '../../store';

const props = defineProps<{
  adjustment: FundAdjustment | null;
  open: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:open', val: boolean): void;
  (e: 'processed'): void;
}>();

const { approveAdjustment, rejectAdjustment } = useCashFund();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const comment = ref('');
const showRejectModal = ref(false);

function handleApprove() {
  if (!props.adjustment) return;
  approveAdjustment(props.adjustment.id, comment.value);
  message.success(`Đã phê duyệt điều chỉnh quỹ ${props.adjustment.code}!`);
  comment.value = '';
  visible.value = false;
  emit('processed');
}

function handleConfirmReject() {
  if (!props.adjustment) return;
  if (!comment.value.trim()) {
    message.error('Bắt buộc phải nhập lý do từ chối điều chỉnh quỹ.');
    return;
  }
  rejectAdjustment(props.adjustment.id, comment.value);
  message.error(`Đã từ chối điều chỉnh quỹ ${props.adjustment.code}.`);
  comment.value = '';
  showRejectModal.value = false;
  visible.value = false;
  emit('processed');
}
</script>

<template>
  <Modal
    v-model:open="visible"
    title="Phê duyệt điều chỉnh quỹ tiền mặt"
    width="780px"
    destroy-on-close
    :footer="null"
  >
    <div v-if="adjustment" class="flex flex-col gap-4 py-2">
      <!-- Header Summary -->
      <div class="flex flex-wrap items-center justify-between gap-4 rounded-lg bg-muted/40 p-4 border border-border">
        <div>
          <span class="font-mono text-base font-bold text-foreground">{{ adjustment.code }}</span>
          <div class="text-xs text-muted-foreground mt-0.5">
            Cấp duyệt hiện tại: <strong class="text-amber-600">{{ adjustment.currentApprover }}</strong>
          </div>
        </div>

        <div class="text-right">
          <div class="text-xs text-muted-foreground">Số tiền điều chuyển</div>
          <div class="text-2xl font-bold text-primary">
            {{ adjustment.amount.toLocaleString() }} {{ adjustment.currency }}
          </div>
        </div>
      </div>

      <!-- Sources Visual -->
      <div class="grid grid-cols-2 gap-4 rounded-lg bg-card p-3 border border-border text-xs">
        <div class="rounded bg-muted/20 p-2.5 border border-border">
          <span class="text-muted-foreground font-semibold block">Nguồn chuyển (Trừ số dư)</span>
          <div class="font-semibold text-sm text-foreground mt-1">{{ adjustment.fromSourceName }}</div>
          <div class="text-muted-foreground text-[11px]">{{ adjustment.fromCompany }}</div>
        </div>

        <div class="rounded bg-muted/20 p-2.5 border border-border">
          <span class="text-muted-foreground font-semibold block">Nguồn nhận (Cộng số dư)</span>
          <div class="font-semibold text-sm text-foreground mt-1">{{ adjustment.toSourceName }}</div>
          <div class="text-muted-foreground text-[11px]">{{ adjustment.toCompany }}</div>
        </div>
      </div>

      <Descriptions bordered size="small" :column="{ xs: 1, sm: 2 }">
        <Descriptions.Item label="Thời gian hiệu lực">
          {{ adjustment.effectiveDate }}
        </Descriptions.Item>
        <Descriptions.Item label="Chứng từ đính kèm">
          <span class="text-primary font-medium flex items-center gap-1 cursor-pointer hover:underline">
            <IconifyIcon icon="lucide:file-text" class="size-3.5" />
            {{ adjustment.attachmentName }}
          </span>
        </Descriptions.Item>
        <Descriptions.Item label="Lý do điều chuyển" :span="2">
          {{ adjustment.reason }}
        </Descriptions.Item>
      </Descriptions>

      <!-- Approver Comment Input -->
      <div class="flex flex-col gap-1.5 rounded-lg bg-muted/20 p-3.5 border border-border">
        <label class="text-xs font-semibold text-foreground uppercase tracking-wider">
          Ý kiến phê duyệt
        </label>
        <Input.TextArea
          v-model:value="comment"
          placeholder="Nhập ý kiến hoặc ghi chú xử lý điều chỉnh quỹ..."
          :rows="2"
        />
      </div>

      <!-- Actions -->
      <div class="flex items-center justify-between pt-2 border-t border-border">
        <Button @click="visible = false">Đóng</Button>

        <div class="flex items-center gap-2">
          <Button danger @click="showRejectModal = true">
            <template #icon>
              <IconifyIcon icon="lucide:x-circle" class="size-4" />
            </template>
            Từ chối
          </Button>

          <Popconfirm
            title="Xác nhận phê duyệt điều chỉnh quỹ?"
            description="Số tiền sẽ được ghi nhận điều chuyển giữa 2 nguồn tiền sau cấp phê duyệt cuối cùng."
            ok-text="Xác nhận duyệt"
            cancel-text="Hủy"
            @confirm="handleApprove"
          >
            <Button type="primary">
              <template #icon>
                <IconifyIcon icon="lucide:check-circle" class="size-4" />
              </template>
              Duyệt điều chuyển
            </Button>
          </Popconfirm>
        </div>
      </div>
    </div>

    <!-- Reject Reason Input Modal -->
    <Modal
      v-model:open="showRejectModal"
      title="Lý do từ chối điều chỉnh quỹ"
      width="460px"
      ok-text="Xác nhận từ chối"
      cancel-text="Hủy"
      :ok-button-props="{ danger: true }"
      @ok="handleConfirmReject"
    >
      <div class="flex flex-col gap-2 py-2">
        <p class="text-xs text-muted-foreground m-0">
          Vui lòng nêu rõ lý do không chấp thuận điều chuyển nguồn tiền này:
        </p>
        <Input.TextArea
          v-model:value="comment"
          placeholder="Nhập lý do chi tiết..."
          :rows="4"
        />
      </div>
    </Modal>
  </Modal>
</template>

<script setup lang="ts">
import type { PaymentKind, PurchaseOrder } from '../../types';

import { computed, ref, watch } from 'vue';

import {
  Alert,
  Button,
  Input,
  InputNumber,
  message,
  Modal,
  Radio,
} from 'ant-design-vue';

import { orderTotal, usePurchasing } from '../../store';
import { money } from '../../utils';

const props = defineProps<{
  open: boolean;
  order: PurchaseOrder;
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
}>();

const { createPayment, orderCommitted } = usePurchasing();

const visible = computed({
  get: () => props.open,
  set: (value) => emit('update:open', value),
});

const kind = ref<PaymentKind>('payment');
const amount = ref(0);
const note = ref('');

const total = computed(() => orderTotal(props.order));
const available = computed(() =>
  Math.max(0, total.value - orderCommitted(props.order)),
);

watch(
  () => props.open,
  (open) => {
    if (!open) return;
    kind.value = props.order.lines.every((l) => l.receivedQty === 0)
      ? 'advance'
      : 'payment';
    amount.value = available.value;
    note.value = '';
  },
);

function submit() {
  if (!amount.value || amount.value <= 0) {
    message.error('Số tiền phải lớn hơn 0.');
    return;
  }
  if (amount.value > available.value) {
    message.error('Tổng các yêu cầu thanh toán không được vượt giá trị PO.');
    return;
  }
  const proposal = createPayment(props.order.id, {
    amount: amount.value,
    kind: kind.value,
    note: note.value.trim(),
  });
  message.success(`Đã tạo đề xuất ${proposal?.code} tại Quỹ tiền mặt.`);
  visible.value = false;
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="`Yêu cầu thanh toán - ${order.code}`"
    width="560px"
    :footer="null"
    destroy-on-close
  >
    <div class="flex flex-col gap-4 py-2">
      <Alert
        type="info"
        show-icon
        message="Yêu cầu được chuyển thành đề xuất thanh toán tại Quỹ tiền mặt và đi theo luồng duyệt của Quỹ. Kết quả thanh toán tự cập nhật về PO."
      />
      <div class="grid grid-cols-2 gap-3 rounded-md bg-muted/40 p-3 text-sm">
        <div>
          <div class="text-xs text-muted-foreground">Giá trị PO</div>
          <div class="font-semibold">{{ money(total) }}</div>
        </div>
        <div>
          <div class="text-xs text-muted-foreground">Còn được yêu cầu</div>
          <div class="font-semibold text-primary">{{ money(available) }}</div>
        </div>
      </div>
      <div>
        <label
          class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
          >Loại</label>
        <Radio.Group v-model:value="kind">
          <Radio value="advance">Ứng trước / đặt cọc</Radio>
          <Radio value="payment">Thanh toán theo đợt / phần còn lại</Radio>
        </Radio.Group>
      </div>
      <div>
        <label
          class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
          >Số tiền <span class="text-red-500">*</span></label>
        <InputNumber
          v-model:value="amount"
          :min="0"
          :max="available"
          :step="100000"
          :formatter="
            (value: any) => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, '.')
          "
          :parser="(value: any) => value.replace(/\./g, '')"
          addon-after="₫"
          class="w-full"
        />
      </div>
      <div>
        <label
          class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
          >Ghi chú</label>
        <Input
          v-model:value="note"
          placeholder="Ví dụ: thanh toán đợt 1 theo biên bản giao nhận"
        />
      </div>
      <div class="flex justify-end gap-2 border-t border-border pt-3">
        <Button @click="visible = false">Đóng</Button>
        <Button type="primary" :disabled="available <= 0" @click="submit">
Gửi sang Quỹ tiền mặt
</Button>
      </div>
    </div>
  </Modal>
</template>

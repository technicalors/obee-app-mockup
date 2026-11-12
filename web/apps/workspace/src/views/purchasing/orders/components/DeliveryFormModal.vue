<script setup lang="ts">
import type { PurchaseOrder } from '../../types';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Alert,
  Button,
  InputNumber,
  message,
  Modal,
  Tag,
} from 'ant-design-vue';

import { usePurchasing } from '../../store';
import { num, todayText } from '../../utils';

const props = defineProps<{
  open: boolean;
  order: PurchaseOrder;
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
}>();

const { deliveries, recordDelivery, requests } = usePurchasing();

const visible = computed({
  get: () => props.open,
  set: (value) => emit('update:open', value),
});

const deliveredAt = ref(todayText());
const documents = ref<string[]>([]);
const quantities = ref<Record<string, number>>({});

const requireInspection = computed(
  () =>
    requests.value.find((r) => r.id === props.order.requestId)
      ?.requireInspection ?? false,
);

/** Số lượng đang nằm trong các đợt chưa kết thúc (chưa xác nhận/báo lỗi). */
function inTransit(lineId: string) {
  return deliveries.value
    .filter(
      (d) =>
        d.orderId === props.order.id &&
        (d.status === 'purchasing_check' || d.status === 'requester_check'),
    )
    .flatMap((d) => d.lines)
    .filter((l) => l.orderLineId === lineId)
    .reduce((sum, l) => sum + (l.passedQty ?? l.deliveredQty), 0);
}

function remaining(lineId: string) {
  const line = props.order.lines.find((l) => l.id === lineId);
  if (!line) return 0;
  return Math.max(0, line.quantity - line.receivedQty - inTransit(lineId));
}

watch(
  () => props.open,
  (open) => {
    if (!open) return;
    deliveredAt.value = todayText();
    documents.value = [];
    quantities.value = Object.fromEntries(
      props.order.lines.map((l) => [l.id, 0]),
    );
  },
);

function attach() {
  documents.value.push(
    `Phieu_giao_hang_${Date.now().toString().slice(-5)}.pdf`,
  );
}

function submit() {
  const total = Object.values(quantities.value).reduce(
    (s, v) => s + (v || 0),
    0,
  );
  if (total <= 0) {
    message.error('Nhập số lượng thực nhận cho ít nhất 1 mặt hàng.');
    return;
  }
  const batch = recordDelivery(props.order.id, {
    deliveredAt: deliveredAt.value,
    documents: documents.value,
    quantities: quantities.value,
  });
  if (!batch) return;
  message.success(
    requireInspection.value
      ? `Đã ghi nhận ${batch.code}. Chờ Purchasing kiểm tra.`
      : `Đã ghi nhận ${batch.code} và chuyển người đề xuất kiểm tra.`,
  );
  visible.value = false;
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="`Ghi nhận giao hàng - ${order.code}`"
    width="760px"
    :footer="null"
    destroy-on-close
  >
    <div class="flex flex-col gap-4 py-2">
      <Alert
        :type="requireInspection ? 'info' : 'success'"
        show-icon
        :message="
          requireInspection
            ? 'Phiếu bắt buộc kiểm tra tại Purchasing: đợt hàng sẽ chờ Purchasing kiểm tra trước khi chuyển người đề xuất.'
            : 'Phiếu không bắt buộc kiểm tra tại Purchasing: đợt hàng chuyển thẳng cho người đề xuất kiểm tra.'
        "
      />
      <div class="flex flex-wrap items-end gap-3">
        <div>
          <label
            class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
            >Ngày giao</label>
          <input
            v-model="deliveredAt"
            type="date"
            class="h-8 rounded border border-input bg-background px-2 text-sm"
          />
        </div>
        <Button @click="attach">
          <template #icon>
<IconifyIcon icon="lucide:paperclip" class="size-4" />
</template>
          Đính kèm chứng từ
        </Button>
        <div class="flex flex-wrap gap-1">
          <Tag
            v-for="(file, i) in documents"
            :key="file"
            closable
            @close="documents.splice(i, 1)"
            >
{{ file }}
</Tag>
        </div>
      </div>
      <table class="w-full border-collapse text-sm">
        <thead
          class="border-b border-border bg-muted/50 text-left text-xs text-muted-foreground"
        >
          <tr>
            <th class="p-2">Hàng hóa / dịch vụ</th>
            <th class="p-2 text-right">Còn phải giao</th>
            <th class="w-40 p-2 text-right">Thực nhận đợt này</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="line in order.lines"
            :key="line.id"
            class="border-b border-border/50"
          >
            <td class="p-2">
              {{ line.itemName }}
              <Tag v-if="line.onHold" color="orange" class="ml-1 text-[10px]">
Tạm dừng - chờ duyệt bổ sung
</Tag>
            </td>
            <td class="p-2 text-right text-muted-foreground">
              {{ num(remaining(line.id)) }} {{ line.unit }}
            </td>
            <td class="p-2 text-right">
              <InputNumber
                v-model:value="quantities[line.id]"
                :min="0"
                :max="remaining(line.id)"
                :precision="0"
                :disabled="line.onHold || remaining(line.id) === 0"
                size="small"
                class="w-full"
              />
            </td>
          </tr>
        </tbody>
      </table>
      <div class="flex justify-end gap-2 border-t border-border pt-3">
        <Button @click="visible = false">Đóng</Button>
        <Button type="primary" @click="submit">Ghi nhận</Button>
      </div>
    </div>
  </Modal>
</template>

<script setup lang="ts">
import type { DeliveryBatch } from '../../types';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Alert,
  Button,
  Input,
  InputNumber,
  message,
  Modal,
  Tag,
  Timeline,
} from 'ant-design-vue';

import { usePurchasing } from '../../store';
import { DELIVERY_STATUS, num } from '../../utils';

const props = defineProps<{
  batch: DeliveryBatch | null;
  open: boolean;
}>();

const emit = defineEmits<{
  (e: 'change', orderId: string): void;
  (e: 'update:open', value: boolean): void;
}>();

const { orders, purchasingCheck, requesterConfirm, requesterReport, requests } =
  usePurchasing();

const visible = computed({
  get: () => props.open,
  set: (value) => emit('update:open', value),
});

const mode = computed(() => {
  if (props.batch?.status === 'purchasing_check') return 'purchasing';
  if (props.batch?.status === 'requester_check') return 'requester';
  return 'view';
});

const isService = computed(() => {
  const order = orders.value.find((o) => o.id === props.batch?.orderId);
  return Boolean(order?.lines.some((l) => l.kind === 'service'));
});

const needContract = computed(
  () =>
    requests.value.find((r) => r.id === props.batch?.requestId)?.needContract ??
    false,
);

const quantities = ref<Record<string, number>>({});
const comment = ref('');

watch(
  () => [props.open, props.batch?.id],
  () => {
    if (!props.open || !props.batch) return;
    comment.value = '';
    quantities.value = Object.fromEntries(
      props.batch.lines.map((l) => [
        l.orderLineId,
        mode.value === 'requester'
          ? (l.passedQty ?? l.deliveredQty)
          : l.deliveredQty,
      ]),
    );
  },
  { immediate: true },
);

function maxOf(orderLineId: string) {
  const line = props.batch?.lines.find((l) => l.orderLineId === orderLineId);
  if (!line) return 0;
  return mode.value === 'requester'
    ? (line.passedQty ?? line.deliveredQty)
    : line.deliveredQty;
}

function confirm() {
  if (!props.batch) return;
  const total = Object.values(quantities.value).reduce(
    (s, v) => s + (v || 0),
    0,
  );
  if (mode.value === 'purchasing') {
    purchasingCheck(props.batch.id, quantities.value, comment.value.trim());
    message.success(
      total === 0
        ? 'Đợt hàng không đạt, xử lý lại với NCC.'
        : 'Đã kiểm tra. Phần đạt được chuyển người đề xuất kiểm tra.',
    );
  } else {
    if (total === 0) {
      message.error(
        'Số lượng xác nhận bằng 0 - dùng "Báo lỗi" để trả về Purchasing.',
      );
      return;
    }
    requesterConfirm(props.batch.id, quantities.value, comment.value.trim());
    message.success(
      isService.value
        ? 'Đã nghiệm thu dịch vụ.'
        : 'Đã xác nhận nhận hàng. Số lượng đã cộng dồn vào PO.',
    );
  }
  visible.value = false;
}

function report() {
  if (!props.batch) return;
  if (!comment.value.trim()) {
    message.error('Nhập lý do báo lỗi.');
    return;
  }
  requesterReport(props.batch.id, comment.value.trim());
  message.success('Đã báo lỗi, Purchasing sẽ xử lý với NCC.');
  visible.value = false;
}

function requestChange() {
  if (!props.batch) return;
  emit('change', props.batch.orderId);
  visible.value = false;
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="
      mode === 'purchasing'
        ? 'Purchasing kiểm tra hàng'
        : mode === 'requester'
          ? isService
            ? 'Nghiệm thu dịch vụ'
            : 'Kiểm tra và xác nhận nhận hàng'
          : 'Chi tiết đợt giao'
    "
    width="860px"
    :footer="null"
    destroy-on-close
  >
    <div v-if="batch" class="flex flex-col gap-4 py-2">
      <div
        class="flex flex-wrap items-center gap-3 rounded-lg border border-border bg-muted/40 p-3"
      >
        <span class="font-mono font-bold">{{ batch.code }}</span>
        <Tag :color="DELIVERY_STATUS[batch.status].color" class="m-0">
{{
          DELIVERY_STATUS[batch.status].text
        }}
</Tag>
        <Tag v-if="needContract" color="purple" class="m-0">Cần hợp đồng</Tag>
        <span class="text-sm text-muted-foreground">{{ batch.orderCode }} · {{ batch.supplierName }} · giao ngày
          {{ batch.deliveredAt }}</span>
        <span class="ml-auto flex flex-wrap gap-1">
          <Tag v-for="file in batch.documents" :key="file" class="m-0"><IconifyIcon
              icon="lucide:file-text"
              class="mr-1 inline size-3"
            />{{ file }}</Tag>
        </span>
      </div>

      <Alert
        v-if="mode === 'purchasing'"
        type="info"
        show-icon
        message="Kiểm tra số lượng, chủng loại, quy cách so với PO. Nhập số lượng đạt; phần không đạt xử lý với NCC (sửa, thay thế, giao bù) ngoài hệ thống."
      />
      <Alert
        v-else-if="mode === 'requester'"
        type="info"
        show-icon
        message="Nhập số lượng thực nhận đạt yêu cầu. Phần còn thiếu được coi là chưa giao hoặc lỗi và tiếp tục chờ NCC giao bù."
      />

      <table class="w-full border-collapse text-sm">
        <thead
          class="border-b border-border bg-muted/50 text-left text-xs text-muted-foreground"
        >
          <tr>
            <th class="p-2">Hàng hóa / dịch vụ</th>
            <th class="p-2 text-right">NCC giao</th>
            <th class="p-2 text-right">Purchasing đạt</th>
            <th class="p-2 text-right">
              {{
                mode === 'view'
                  ? 'Đã nhận'
                  : mode === 'purchasing'
                    ? 'Số lượng đạt'
                    : 'Xác nhận nhận'
              }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="line in batch.lines"
            :key="line.orderLineId"
            class="border-b border-border/50"
          >
            <td class="p-2">{{ line.itemName }}</td>
            <td class="p-2 text-right">
              {{ num(line.deliveredQty) }} {{ line.unit }}
            </td>
            <td class="p-2 text-right text-muted-foreground">
              {{
                line.passedQty === undefined
                  ? 'Không kiểm tra'
                  : num(line.passedQty)
              }}
            </td>
            <td class="w-40 p-2 text-right">
              <InputNumber
                v-if="mode !== 'view'"
                v-model:value="quantities[line.orderLineId]"
                :min="0"
                :max="maxOf(line.orderLineId)"
                :precision="0"
                size="small"
                class="w-full"
              />
              <span v-else>{{
                line.acceptedQty === undefined ? '-' : num(line.acceptedQty)
              }}</span>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="mode !== 'view'">
        <label
          class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
        >
          Ghi chú
          <span v-if="mode === 'requester'" class="font-normal normal-case">(bắt buộc khi báo lỗi)</span>
        </label>
        <Input.TextArea
          v-model:value="comment"
          :rows="2"
          placeholder="Tình trạng thực tế, lỗi phát hiện..."
        />
      </div>

      <div>
        <div class="mb-1 text-sm font-semibold">Diễn biến</div>
        <Timeline class="pl-1">
          <Timeline.Item v-for="(event, index) in batch.events" :key="index">
            <div class="flex flex-wrap items-center gap-2 text-xs">
              <span class="font-semibold">{{ event.actorName }}</span>
              <Tag class="m-0 text-[10px]">{{ event.role }}</Tag>
              <span>{{ event.action }}</span>
              <span class="ml-auto font-mono text-muted-foreground">{{
                event.timestamp
              }}</span>
            </div>
            <p
              v-if="event.comment"
              class="m-0 mt-1 rounded bg-muted/40 p-1.5 text-xs text-muted-foreground"
            >
              {{ event.comment }}
            </p>
          </Timeline.Item>
        </Timeline>
      </div>

      <div
        class="flex flex-wrap items-center justify-end gap-2 border-t border-border pt-3"
      >
        <Button
          v-if="mode === 'requester'"
          class="mr-auto"
          @click="requestChange"
        >
          <template #icon>
<IconifyIcon icon="lucide:file-diff" class="size-4" />
</template>
          Yêu cầu bổ sung/chỉnh sửa
        </Button>
        <Button @click="visible = false">Đóng</Button>
        <Button v-if="mode === 'requester'" danger @click="report">
Báo lỗi - trả Purchasing
</Button>
        <Button v-if="mode !== 'view'" type="primary" @click="confirm">
          <template #icon>
<IconifyIcon icon="lucide:check" class="size-4" />
</template>
          {{
            mode === 'purchasing'
              ? 'Xác nhận kết quả kiểm tra'
              : isService
                ? 'Nghiệm thu'
                : 'Xác nhận nhận hàng'
          }}
        </Button>
      </div>
    </div>
  </Modal>
</template>

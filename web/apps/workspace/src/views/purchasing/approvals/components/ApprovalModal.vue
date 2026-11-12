<script setup lang="ts">
import type { ChangeRequest, PurchaseRequest, RequestLine } from '../../types';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Alert,
  Button,
  Card,
  Checkbox,
  Input,
  message,
  Modal,
  Radio,
  Table,
  Tag,
} from 'ant-design-vue';

import ApprovalFlow from '../../components/ApprovalFlow.vue';
import { requestTotal, selectedQuote, usePurchasing } from '../../store';
import { CHANGE_KIND, KIND_LABELS, money, num, ROLE_LABELS } from '../../utils';

const props = defineProps<{
  id: null | string;
  kind: 'change' | 'request';
  open: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
}>();

const {
  approveChange,
  approveRequest,
  changeRequests,
  rejectChange,
  rejectRequest,
  requests,
  returnChange,
  returnRequest,
} = usePurchasing();

const visible = computed({
  get: () => props.open,
  set: (value) => emit('update:open', value),
});

const request = computed<null | PurchaseRequest>(() =>
  props.kind === 'request'
    ? (requests.value.find((r) => r.id === props.id) ?? null)
    : null,
);
const change = computed<ChangeRequest | null>(() =>
  props.kind === 'change'
    ? (changeRequests.value.find((c) => c.id === props.id) ?? null)
    : null,
);
const doc = computed(() => request.value ?? change.value);
const step = computed(() =>
  doc.value ? doc.value.approvalSteps[doc.value.currentStep] : undefined,
);
const isPurchasingStep = computed(
  () => props.kind === 'request' && step.value?.role === 'purchasing',
);

const comment = ref('');
const selections = ref<Record<string, string>>({});
const requireInspection = ref(false);

watch(
  () => props.open,
  (open) => {
    if (!open) return;
    comment.value = '';
    requireInspection.value = request.value?.requireInspection ?? false;
    selections.value = {};
    for (const line of request.value?.lines ?? []) {
      const cheapest = line.quotes.toSorted(
        (a, b) => a.unitPrice - b.unitPrice,
      )[0];
      selections.value[line.id] = line.selectedQuoteId ?? cheapest?.id ?? '';
    }
  },
  { immediate: true },
);

const previewTotal = computed(() => {
  if (!request.value) return 0;
  if (!isPurchasingStep.value) return requestTotal(request.value);
  let sum = 0;
  for (const line of request.value.lines) {
    const quote = line.quotes.find((q) => q.id === selections.value[line.id]);
    sum += line.quantity * (quote?.unitPrice ?? 0);
  }
  return sum;
});

const changeDiff = computed(() => {
  let sum = 0;
  for (const l of change.value?.lines ?? []) {
    sum +=
      (l.kind === 'quantity' ? l.newQty - l.currentQty : l.newQty) *
      l.unitPrice;
  }
  return sum;
});

const requestColumns = [
  { key: 'item', title: 'Hàng hóa / dịch vụ', width: 260 },
  { align: 'right' as const, key: 'quantity', title: 'Số lượng', width: 100 },
  { key: 'quotes', title: 'Nhà cung cấp' },
];

const changeColumns = [
  { key: 'kind', title: 'Loại', width: 150 },
  { dataIndex: 'itemName', key: 'itemName', title: 'Mặt hàng' },
  { key: 'qty', title: 'Số lượng', width: 150 },
  { key: 'supplier', title: 'NCC', width: 240 },
  { align: 'right' as const, key: 'price', title: 'Đơn giá', width: 120 },
];

function newSupplierCount(line: RequestLine) {
  return line.quotes.filter((q) => q.isNewSupplier).length;
}

function act(action: 'approve' | 'reject' | 'return') {
  if (!doc.value || !step.value) return;
  if (action !== 'approve' && !comment.value.trim()) {
    message.error('Nhập lý do khi từ chối hoặc yêu cầu điều chỉnh.');
    return;
  }
  const code = doc.value.code;
  const reason = comment.value.trim();
  if (props.kind === 'request') {
    if (action === 'approve') {
      approveRequest(doc.value.id, {
        comment: reason,
        requireInspection: requireInspection.value,
        selections: selections.value,
      });
    } else if (action === 'return') {
      returnRequest(doc.value.id, reason);
    } else {
      rejectRequest(doc.value.id, reason);
    }
  } else if (action === 'approve') {
    approveChange(doc.value.id, reason);
  } else if (action === 'return') {
    returnChange(doc.value.id, reason);
  } else {
    rejectChange(doc.value.id, reason);
  }
  const last = doc.value.currentStep >= doc.value.approvalSteps.length;
  const finalText =
    props.kind === 'request'
      ? `Đã duyệt cuối ${code}. Hệ thống đã sinh PO.`
      : `Đã duyệt cuối ${code}. PO đã được cập nhật.`;
  const text = {
    approve: last ? finalText : `Đã duyệt ${code}, chuyển cấp kế tiếp.`,
    reject: `Đã từ chối ${code}.`,
    return: `Đã trả ${code} về người đề xuất để điều chỉnh.`,
  };
  message.success(text[action]);
  visible.value = false;
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="
      kind === 'request'
        ? 'Duyệt đề nghị mua hàng'
        : 'Duyệt yêu cầu bổ sung/chỉnh sửa'
    "
    width="1080px"
    :footer="null"
    destroy-on-close
  >
    <div v-if="doc && step" class="flex flex-col gap-4 py-2">
      <div
        class="flex flex-wrap items-center justify-between gap-4 rounded-lg border border-border bg-muted/40 p-4"
      >
        <div class="flex flex-col gap-1">
          <div class="flex items-center gap-2">
            <span class="font-mono text-base font-bold">{{ doc.code }}</span>
            <Tag color="processing" class="m-0">
Chờ {{ ROLE_LABELS[step.role] }} duyệt
</Tag>
            <Tag v-if="request?.needContract" color="purple" class="m-0">
Cần hợp đồng
</Tag>
          </div>
          <span class="text-sm text-muted-foreground">
            {{ doc.requesterName }} · {{ doc.department }} · {{ doc.createdAt }}
          </span>
          <span v-if="request?.note" class="text-sm text-foreground">{{
            request.note
          }}</span>
          <span v-if="change" class="text-sm text-foreground">
            Gắn với <span class="font-mono">{{ change.orderCode }}</span> ({{
              change.requestCode
            }}) · Lý do: {{ change.reason }}
          </span>
        </div>
        <div class="flex flex-col items-end">
          <span class="text-xs text-muted-foreground">{{
            kind === 'request' ? 'Tổng giá trị' : 'Giá trị thay đổi'
          }}</span>
          <span class="text-xl font-bold text-primary">
            {{
              kind === 'request'
                ? money(previewTotal)
                : `${changeDiff >= 0 ? '+' : ''}${money(changeDiff)}`
            }}
          </span>
        </div>
      </div>

      <Card
        v-if="request"
        size="small"
        :bordered="false"
        class="border border-border"
      >
        <template #title>
          <span>Hàng hóa / dịch vụ</span>
          <span
            v-if="isPurchasingStep"
            class="ml-2 text-xs font-normal text-muted-foreground"
          >
            Chọn NCC cuối cho từng dòng (mặc định NCC giá thấp nhất). NCC mới
            được thêm vào danh mục khi duyệt.
          </span>
        </template>
        <Table
          :data-source="request.lines"
          :columns="requestColumns"
          :pagination="false"
          row-key="id"
          size="small"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'item'">
              <div class="flex flex-col">
                <span class="font-medium">{{ record.itemName }}
                  <Tag class="ml-1 text-[10px]">{{
                    KIND_LABELS[record.kind as 'goods']
                  }}</Tag></span>
                <span class="text-xs text-muted-foreground">{{
                  record.spec || '-'
                }}</span>
                <span class="text-xs text-muted-foreground">{{ record.purpose }} · cần ngày {{ record.neededDate }}</span>
              </div>
            </template>
            <template v-else-if="column.key === 'quantity'">
{{ num(record.quantity) }} {{ record.unit }}
</template>
            <template v-else-if="column.key === 'quotes'">
              <Radio.Group
                v-if="isPurchasingStep"
                v-model:value="selections[record.id]"
                class="flex w-full flex-col gap-1"
              >
                <Radio
                  v-for="quote in (record as RequestLine).quotes"
                  :key="quote.id"
                  :value="quote.id"
                  class="!mr-0 w-full"
                >
                  <span class="inline-flex w-full items-center gap-2 text-xs">
                    <span>{{ quote.supplierName }}</span>
                    <Tag
                      v-if="quote.isNewSupplier"
                      color="orange"
                      class="m-0 text-[10px]"
                      >NCC mới</Tag>
                    <IconifyIcon
                      v-if="quote.quoteFile"
                      icon="lucide:paperclip"
                      class="size-3 text-primary"
                      :title="quote.quoteFile"
                    />
                    <span class="ml-auto font-medium">{{
                      money(quote.unitPrice)
                    }}</span>
                  </span>
                </Radio>
              </Radio.Group>
              <div v-else class="flex flex-col gap-0.5 text-xs">
                <span
                  v-for="quote in (record as RequestLine).quotes"
                  :key="quote.id"
                  :class="
                    selectedQuote(record as RequestLine)?.id === quote.id &&
                    record.selectedQuoteId
                      ? 'font-semibold'
                      : 'text-muted-foreground'
                  "
                >
                  {{ quote.supplierName }} · {{ money(quote.unitPrice) }}
                  <template v-if="record.selectedQuoteId === quote.id">
                    (đã chọn)</template>
                </span>
              </div>
              <span
                v-if="
                  isPurchasingStep && newSupplierCount(record as RequestLine)
                "
                class="mt-1 block text-[11px] text-orange-600"
              >
                Có NCC mới chưa có trong danh mục.
              </span>
            </template>
          </template>
        </Table>
        <div
          v-if="isPurchasingStep"
          class="mt-3 rounded-md border border-dashed border-border p-3"
        >
          <Checkbox v-model:checked="requireInspection">
            <span class="font-medium">Bắt buộc kiểm tra tại Purchasing</span>
          </Checkbox>
          <p class="m-0 mt-1 pl-6 text-xs text-muted-foreground">
            Áp dụng cho cả phiếu và không sửa được sau khi PO phát hành. Khi
            bật, mỗi đợt giao phải được Purchasing kiểm tra đạt trước khi chuyển
            người đề xuất.
          </p>
        </div>
      </Card>

      <Card
        v-if="change"
        size="small"
        title="Nội dung thay đổi"
        :bordered="false"
        class="border border-border"
      >
        <Table
          :data-source="change.lines"
          :columns="changeColumns"
          :pagination="false"
          row-key="id"
          size="small"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'kind'">
<Tag class="m-0">
{{
                CHANGE_KIND[record.kind as 'add']
              }}
</Tag>
</template>
            <template v-else-if="column.key === 'qty'">
              <span v-if="record.kind === 'quantity'">{{ num(record.currentQty) }} → <b>{{ num(record.newQty) }}</b>
                {{ record.unit }}</span>
              <span v-else><b>{{ num(record.newQty) }}</b> {{ record.unit }}</span>
            </template>
            <template v-else-if="column.key === 'supplier'">
              <span
                v-if="record.kind === 'quantity'"
                class="text-muted-foreground"
                >{{ record.currentSupplier }}</span>
              <span v-else>
                {{ record.newSupplierName }}
                <Tag
                  v-if="
                    record.kind === 'supplier' ||
                    record.newSupplierName !== record.currentSupplier
                  "
                  color="blue"
                  class="ml-1 text-[10px]"
                  >PO mới</Tag>
              </span>
            </template>
            <template v-else-if="column.key === 'price'">
{{
              money(record.unitPrice)
            }}
</template>
          </template>
        </Table>
      </Card>

      <Card
        size="small"
        title="Phê duyệt"
        :bordered="false"
        class="border border-border"
      >
        <ApprovalFlow
          :current-step="doc.currentStep"
          :history="doc.history"
          :status="doc.status"
          :steps="doc.approvalSteps"
        />
      </Card>

      <Alert
        v-if="doc.currentStep === doc.approvalSteps.length - 1"
        type="info"
        show-icon
        :message="
          kind === 'request'
            ? 'Đây là cấp duyệt cuối. Sau khi duyệt, hệ thống sinh PO theo từng NCC đã chọn.'
            : 'Đây là cấp duyệt cuối. Sau khi duyệt, PO được cập nhật phiên bản mới hoặc sinh PO mới nếu đổi NCC.'
        "
      />

      <div>
        <label
          class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
        >
          Ý kiến
          <span class="font-normal normal-case">(bắt buộc khi từ chối hoặc yêu cầu điều chỉnh)</span>
        </label>
        <Input.TextArea
          v-model:value="comment"
          :rows="2"
          placeholder="Nhập ý kiến..."
        />
      </div>

      <div
        class="flex flex-wrap items-center justify-end gap-2 border-t border-border pt-3"
      >
        <span class="mr-auto text-xs text-muted-foreground">
          Duyệt với tư cách <b>{{ step.approverName }}</b> ({{
            ROLE_LABELS[step.role]
          }})
        </span>
        <Button @click="visible = false">Đóng</Button>
        <Button danger @click="act('reject')">Từ chối</Button>
        <Button @click="act('return')">Yêu cầu điều chỉnh</Button>
        <Button type="primary" @click="act('approve')">
          <template #icon>
<IconifyIcon icon="lucide:check" class="size-4" />
</template>
          Duyệt
        </Button>
      </div>
    </div>
  </Modal>
</template>

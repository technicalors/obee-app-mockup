<script setup lang="ts">
import type { PurchaseRequest, RequestLine } from '../../types';

import { computed } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Card,
  Descriptions,
  message,
  Modal,
  Popconfirm,
  Table,
  Tag,
} from 'ant-design-vue';

import ApprovalFlow from '../../components/ApprovalFlow.vue';
import {
  orderTotal,
  requestTotal,
  selectedQuote,
  usePurchasing,
} from '../../store';
import {
  KIND_LABELS,
  money,
  num,
  ORDER_STATUS,
  REQUEST_STATUS,
} from '../../utils';

const props = defineProps<{
  open: boolean;
  request: null | PurchaseRequest;
}>();

const emit = defineEmits<{
  (e: 'edit', value: PurchaseRequest): void;
  (e: 'openOrder', id: string): void;
  (e: 'update:open', value: boolean): void;
}>();

const {
  currentApprover,
  ordersOfRequest,
  orderStatus,
  recallRequest,
  requestStatus,
} = usePurchasing();

const visible = computed({
  get: () => props.open,
  set: (value) => emit('update:open', value),
});

const status = computed(() =>
  props.request ? requestStatus(props.request) : 'draft',
);
const relatedOrders = computed(() =>
  props.request ? ordersOfRequest(props.request.id) : [],
);

const columns = [
  {
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
    key: 'index',
    title: '#',
    width: 44,
  },
  { key: 'item', title: 'Hàng hóa / dịch vụ', width: 230 },
  { dataIndex: 'purpose', key: 'purpose', title: 'Mục đích', width: 150 },
  { align: 'right' as const, key: 'quantity', title: 'Số lượng', width: 100 },
  { dataIndex: 'neededDate', key: 'neededDate', title: 'Ngày cần', width: 105 },
  { key: 'quotes', title: 'Nhà cung cấp & đơn giá (sau thuế)' },
  { align: 'right' as const, key: 'amount', title: 'Thành tiền', width: 140 },
];

function lineAmount(line: RequestLine) {
  return line.quantity * (selectedQuote(line)?.unitPrice ?? 0);
}

function recall() {
  if (!props.request) return;
  recallRequest(props.request.id);
  message.success(`Đã thu hồi ${props.request.code}.`);
}
</script>

<template>
  <Modal
    v-model:open="visible"
    title="Chi tiết đề nghị mua hàng"
    width="1100px"
    :footer="null"
    destroy-on-close
  >
    <div v-if="request" class="flex flex-col gap-5 py-2">
      <div
        class="flex flex-wrap items-center justify-between gap-4 rounded-lg border border-border bg-muted/40 p-4"
      >
        <div class="flex flex-col gap-1">
          <div class="flex items-center gap-2">
            <span class="font-mono text-base font-bold text-foreground">{{
              request.code
            }}</span>
            <Tag :color="REQUEST_STATUS[status].color" class="m-0">
{{
              REQUEST_STATUS[status].text
            }}
</Tag>
            <Tag v-if="request.needContract" color="purple" class="m-0">
Cần hợp đồng
</Tag>
            <Tag v-if="request.requireInspection" color="geekblue" class="m-0">
Bắt buộc kiểm tra tại Purchasing
</Tag>
          </div>
          <span class="text-sm text-muted-foreground">{{
            request.note || 'Không có ghi chú'
          }}</span>
        </div>
        <div class="flex flex-col items-end">
          <span class="text-xs text-muted-foreground">Tổng giá trị đề xuất</span>
          <span class="text-xl font-bold text-primary">{{
            money(requestTotal(request))
          }}</span>
        </div>
      </div>

      <div
        v-if="status === 'return_edit' && request.returnReason"
        class="flex items-start gap-2 rounded-lg border border-orange-300/60 bg-orange-50/50 p-3 text-xs dark:bg-orange-500/5"
      >
        <IconifyIcon
          icon="lucide:corner-up-left"
          class="mt-0.5 size-4 text-orange-500"
        />
        <div>
          <div class="font-semibold text-foreground">Yêu cầu điều chỉnh</div>
          <div class="text-muted-foreground">{{ request.returnReason }}</div>
        </div>
      </div>

      <Card
        size="small"
        title="Thông tin chung"
        :bordered="false"
        class="border border-border"
      >
        <Descriptions :column="{ xs: 1, sm: 2, md: 3 }" size="small">
          <Descriptions.Item label="Người đề xuất">
            <span class="font-medium">{{ request.requesterName }}</span>
          </Descriptions.Item>
          <Descriptions.Item label="Bộ phận">
{{
            request.department
          }}
</Descriptions.Item>
          <Descriptions.Item label="Ngày tạo">
{{
            request.createdAt
          }}
</Descriptions.Item>
          <Descriptions.Item label="Người xử lý hiện tại">
            <span class="font-medium text-primary">
              {{
                status === 'pending'
                  ? currentApprover(request.approvalSteps, request.currentStep)
                  : status === 'return_edit' || status === 'draft'
                    ? request.requesterName
                    : '-'
              }}
            </span>
          </Descriptions.Item>
          <Descriptions.Item label="Tài liệu đính kèm" :span="2">
            <span
              v-if="request.attachments.length === 0"
              class="text-muted-foreground"
              >Không có</span>
            <span
              v-for="file in request.attachments"
              :key="file"
              class="mr-3 inline-flex items-center gap-1 text-primary"
            >
              <IconifyIcon icon="lucide:file-text" class="size-3.5" />{{ file }}
            </span>
          </Descriptions.Item>
        </Descriptions>
      </Card>

      <Card
        size="small"
        title="Hàng hóa / dịch vụ"
        :bordered="false"
        class="border border-border"
      >
        <Table
          :data-source="request.lines"
          :columns="columns"
          :pagination="false"
          :scroll="{ x: 1000 }"
          row-key="id"
          size="small"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'item'">
              <div class="flex flex-col">
                <span class="font-medium text-foreground">
                  {{ record.itemName }}
                  <Tag
                    class="ml-1 text-[10px]"
                    :color="record.kind === 'service' ? 'cyan' : ''"
                    >{{ KIND_LABELS[record.kind as 'goods'] }}</Tag>
                </span>
                <span class="text-xs text-muted-foreground">{{
                  record.spec || '-'
                }}</span>
              </div>
            </template>
            <template v-else-if="column.key === 'quantity'">
{{ num(record.quantity) }} {{ record.unit }}
</template>
            <template v-else-if="column.key === 'quotes'">
              <ul class="m-0 flex list-none flex-col gap-1 p-0">
                <li
                  v-for="quote in (record as RequestLine).quotes"
                  :key="quote.id"
                  class="flex items-center gap-2 text-xs"
                  :class="
                    record.selectedQuoteId === quote.id
                      ? 'font-semibold text-foreground'
                      : 'text-muted-foreground'
                  "
                >
                  <IconifyIcon
                    v-if="record.selectedQuoteId === quote.id"
                    icon="lucide:circle-check"
                    class="size-3.5 text-green-600"
                  />
                  <span v-else class="inline-block size-3.5"></span>
                  <span class="truncate">{{ quote.supplierName }}</span>
                  <Tag
                    v-if="quote.isNewSupplier"
                    color="orange"
                    class="m-0 text-[10px]"
                    >
NCC mới
</Tag>
                  <span class="ml-auto whitespace-nowrap">{{
                    money(quote.unitPrice)
                  }}</span>
                  <IconifyIcon
                    v-if="quote.quoteFile"
                    icon="lucide:paperclip"
                    class="size-3 text-primary"
                    :title="quote.quoteFile"
                  />
                </li>
              </ul>
            </template>
            <template v-else-if="column.key === 'amount'">
              <span class="font-semibold">{{
                money(lineAmount(record as RequestLine))
              }}</span>
            </template>
          </template>
        </Table>
        <p class="m-0 mt-2 text-[11px] text-muted-foreground">
          <IconifyIcon
            icon="lucide:circle-check"
            class="inline size-3 text-green-600"
          />
          NCC được Purchasing chọn. Khi chưa chọn, thành tiền tạm tính theo NCC
          đầu tiên.
        </p>
      </Card>

      <Card
        v-if="relatedOrders.length"
        size="small"
        title="Đơn hàng (PO) đã sinh"
        :bordered="false"
        class="border border-border"
      >
        <div class="flex flex-col divide-y divide-border">
          <div
            v-for="order in relatedOrders"
            :key="order.id"
            class="flex flex-wrap items-center gap-3 py-2 text-sm"
          >
            <button
              type="button"
              class="font-mono font-semibold text-primary hover:underline"
              @click="emit('openOrder', order.id)"
            >
              {{ order.code
              }}<span v-if="order.version > 1" class="text-xs font-normal">
                (v{{ order.version }})</span>
            </button>
            <span class="text-muted-foreground">{{ order.supplierName }}</span>
            <span class="ml-auto font-medium">{{
              money(orderTotal(order))
            }}</span>
            <Tag :color="ORDER_STATUS[orderStatus(order)].color" class="m-0">
{{
              ORDER_STATUS[orderStatus(order)].text
            }}
</Tag>
          </div>
        </div>
      </Card>

      <Card
        size="small"
        title="Phê duyệt"
        :bordered="false"
        class="border border-border"
      >
        <ApprovalFlow
          :current-step="request.currentStep"
          :history="request.history"
          :status="request.status"
          :steps="request.approvalSteps"
        />
      </Card>

      <div
        class="flex items-center justify-end gap-2 border-t border-border pt-3"
      >
        <Popconfirm
          v-if="status === 'pending'"
          title="Thu hồi đề nghị này?"
          ok-text="Thu hồi"
          cancel-text="Đóng"
          @confirm="recall"
        >
          <Button danger>
            <template #icon>
<IconifyIcon icon="lucide:undo-2" class="size-4" />
</template>
            Thu hồi
          </Button>
        </Popconfirm>
        <Button
          v-if="status === 'draft' || status === 'return_edit'"
          type="primary"
          ghost
          @click="emit('edit', request)"
        >
          <template #icon>
<IconifyIcon icon="lucide:pencil" class="size-4" />
</template>
          {{ status === 'draft' ? 'Sửa bản nháp' : 'Điều chỉnh và gửi lại' }}
        </Button>
        <Button>
          <template #icon>
<IconifyIcon icon="lucide:printer" class="size-4" />
</template>
          In đơn đề nghị
        </Button>
        <Button @click="visible = false">Đóng</Button>
      </div>
    </div>
  </Modal>
</template>

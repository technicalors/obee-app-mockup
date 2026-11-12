<script setup lang="ts">
import type { DeliveryBatch, OrderLine } from '../../types';

import { computed, nextTick, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Descriptions,
  Empty,
  message,
  Modal,
  Popconfirm,
  Progress,
  Table,
  Tabs,
  Tag,
  Timeline,
} from 'ant-design-vue';

import { orderTotal, usePurchasing } from '../../store';
import {
  CHANGE_STATUS,
  DELIVERY_STATUS,
  KIND_LABELS,
  money,
  num,
  ORDER_STATUS,
  PAYMENT_KIND,
  PAYMENT_STATUS,
} from '../../utils';
import ChangeRequestFormModal from './ChangeRequestFormModal.vue';
import DeliveryFormModal from './DeliveryFormModal.vue';
import InspectModal from './InspectModal.vue';
import PaymentFormModal from './PaymentFormModal.vue';

const props = defineProps<{
  /** Tab mở sẵn khi vào chi tiết (vd. 'deliveries' khi có đợt chờ kiểm tra). */
  initialTab?: string;
  open: boolean;
  orderId: null | string;
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
}>();

const {
  changeRequests,
  deliveries,
  issueOrder,
  orderPaid,
  orders,
  orderStatus,
  paymentStatus,
  requests,
} = usePurchasing();

const visible = computed({
  get: () => props.open,
  set: (value) => emit('update:open', value),
});

const order = computed(
  () => orders.value.find((o) => o.id === props.orderId) ?? null,
);
const request = computed(
  () => requests.value.find((r) => r.id === order.value?.requestId) ?? null,
);
const status = computed(() =>
  order.value ? orderStatus(order.value) : 'not_issued',
);
const total = computed(() => (order.value ? orderTotal(order.value) : 0));
const paid = computed(() => (order.value ? orderPaid(order.value) : 0));
const batches = computed(() =>
  deliveries.value.filter((d) => d.orderId === props.orderId),
);
const changes = computed(() =>
  changeRequests.value.filter((c) => c.orderId === props.orderId),
);
const receivedPercent = computed(() => {
  if (!order.value) return 0;
  const ordered = order.value.lines.reduce((s, l) => s + l.quantity, 0);
  const received = order.value.lines.reduce(
    (s, l) => s + Math.min(l.receivedQty, l.quantity),
    0,
  );
  return ordered === 0 ? 100 : Math.round((received / ordered) * 100);
});

const pendingBatches = computed(
  () =>
    batches.value.filter(
      (b) => b.status === 'purchasing_check' || b.status === 'requester_check',
    ).length,
);

const activeTab = ref('lines');
const deliveryOpen = ref(false);
const paymentOpen = ref(false);
const changeOpen = ref(false);
const inspectOpen = ref(false);
const inspectBatch = ref<DeliveryBatch | null>(null);

watch(
  () => props.open,
  (open) => {
    if (open) activeTab.value = props.initialTab ?? 'lines';
  },
  { immediate: true },
);

async function openInspect(batch: DeliveryBatch) {
  inspectBatch.value = batch;
  await nextTick();
  inspectOpen.value = true;
}

async function openChangeFromBatch() {
  await nextTick();
  changeOpen.value = true;
}

const BATCH_ACTION: Partial<
  Record<DeliveryBatch['status'], { icon: string; label: string; who: string }>
> = {
  purchasing_check: {
    icon: 'lucide:clipboard-check',
    label: 'Kiểm tra',
    who: 'Purchasing',
  },
  requester_check: {
    icon: 'lucide:package-check',
    label: 'Xác nhận nhận / báo lỗi',
    who: 'Người đề xuất',
  },
};

const lineColumns = [
  {
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
    key: 'index',
    title: '#',
    width: 44,
  },
  { key: 'item', title: 'Hàng hóa / dịch vụ' },
  { align: 'right' as const, key: 'quantity', title: 'SL đặt', width: 95 },
  { align: 'right' as const, key: 'unitPrice', title: 'Đơn giá', width: 130 },
  { align: 'right' as const, key: 'amount', title: 'Thành tiền', width: 140 },
  { key: 'received', title: 'Đã nhận', width: 190 },
];

function issue() {
  if (!order.value) return;
  issueOrder(order.value.id);
  message.success(
    `Đã phát hành ${order.value.code}. Gửi PO cho NCC ngoài hệ thống (email/Zalo).`,
  );
}

function exportFile(kind: string) {
  message.success(
    `Đã xuất ${order.value?.code} (v${order.value?.version}) ra ${kind}.`,
  );
}
</script>

<template>
  <Modal
    v-model:open="visible"
    title="Chi tiết đơn hàng (PO)"
    width="1100px"
    :footer="null"
    destroy-on-close
  >
    <div v-if="order" class="flex flex-col gap-4 py-2">
      <div
        class="flex flex-wrap items-center justify-between gap-4 rounded-lg border border-border bg-muted/40 p-4"
      >
        <div class="flex flex-col gap-1">
          <div class="flex flex-wrap items-center gap-2">
            <span class="font-mono text-base font-bold text-foreground">{{
              order.code
            }}</span>
            <Tag class="m-0 font-mono">v{{ order.version }}</Tag>
            <Tag :color="ORDER_STATUS[status].color" class="m-0">
{{
              ORDER_STATUS[status].text
            }}
</Tag>
            <Tag v-if="request?.needContract" color="purple" class="m-0">
Cần hợp đồng
</Tag>
          </div>
          <span class="text-sm font-medium text-foreground">{{
            order.supplierName
          }}</span>
          <span class="text-xs text-muted-foreground">
            Theo đề nghị {{ order.requestCode }} · {{ order.requesterName }}
            <template v-if="order.parentOrderCode">
              · Tham chiếu PO gốc {{ order.parentOrderCode }}</template>
          </span>
        </div>
        <div class="grid min-w-[300px] grid-cols-2 gap-3">
          <div>
            <div class="text-xs text-muted-foreground">Giá trị PO</div>
            <div class="text-lg font-bold text-primary">{{ money(total) }}</div>
          </div>
          <div>
            <div class="text-xs text-muted-foreground">Đã thanh toán</div>
            <div class="text-lg font-bold text-foreground">
              {{ money(paid) }}
            </div>
          </div>
          <div class="col-span-2">
            <div class="flex justify-between text-[11px] text-muted-foreground">
              <span>Nhận hàng</span><span>{{ receivedPercent }}%</span>
            </div>
            <Progress
              :percent="receivedPercent"
              :show-info="false"
              size="small"
            />
            <div class="flex justify-between text-[11px] text-muted-foreground">
              <span>Thanh toán</span><span>{{ total ? Math.round((paid / total) * 100) : 0 }}%</span>
            </div>
            <Progress
              :percent="total ? Math.round((paid / total) * 100) : 0"
              :show-info="false"
              size="small"
              stroke-color="#16a34a"
            />
          </div>
        </div>
      </div>

      <div class="flex flex-wrap items-center gap-2">
        <Popconfirm
          v-if="status === 'not_issued'"
          title="Phát hành PO và gửi cho NCC?"
          ok-text="Phát hành"
          cancel-text="Đóng"
          @confirm="issue"
        >
          <Button type="primary">
            <template #icon>
<IconifyIcon icon="lucide:send" class="size-4" />
</template>
            Phát hành PO
          </Button>
        </Popconfirm>
        <Button
          v-if="status === 'in_progress'"
          type="primary"
          @click="deliveryOpen = true"
        >
          <template #icon>
<IconifyIcon icon="lucide:package-check" class="size-4" />
</template>
          Ghi nhận giao hàng
        </Button>
        <Button
          v-if="status !== 'not_issued' && status !== 'completed'"
          @click="paymentOpen = true"
        >
          <template #icon>
<IconifyIcon icon="lucide:wallet" class="size-4" />
</template>
          Tạo yêu cầu thanh toán
        </Button>
        <Button v-if="status === 'in_progress'" @click="changeOpen = true">
          <template #icon>
<IconifyIcon icon="lucide:file-diff" class="size-4" />
</template>
          Yêu cầu bổ sung/chỉnh sửa
        </Button>
        <div class="ml-auto flex gap-2">
          <Button @click="exportFile('PDF')">
            <template #icon>
<IconifyIcon icon="lucide:file-down" class="size-4" />
</template>
            PDF
          </Button>
          <Button @click="exportFile('Excel')">
            <template #icon>
<IconifyIcon icon="lucide:sheet" class="size-4" />
</template>
            Excel
          </Button>
        </div>
      </div>

      <Tabs v-model:active-key="activeTab">
        <Tabs.TabPane key="lines" tab="Hàng hóa & tiến độ nhận">
          <Table
            :data-source="order.lines"
            :columns="lineColumns"
            :pagination="false"
            row-key="id"
            size="small"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'item'">
                <div class="flex flex-col">
                  <span class="font-medium">
                    {{ record.itemName }}
                    <Tag
                      class="ml-1 text-[10px]"
                      :color="record.kind === 'service' ? 'cyan' : ''"
                      >{{ KIND_LABELS[record.kind as 'goods'] }}</Tag>
                    <Tag v-if="record.onHold" color="orange" class="text-[10px]">Tạm dừng - chờ duyệt bổ sung</Tag>
                  </span>
                  <span class="text-xs text-muted-foreground">{{
                    record.spec || '-'
                  }}</span>
                </div>
              </template>
              <template v-else-if="column.key === 'quantity'">
{{ num(record.quantity) }} {{ record.unit }}
</template>
              <template v-else-if="column.key === 'unitPrice'">
{{
                money(record.unitPrice)
              }}
</template>
              <template v-else-if="column.key === 'amount'">
                <span class="font-semibold">{{
                  money(record.quantity * record.unitPrice)
                }}</span>
              </template>
              <template v-else-if="column.key === 'received'">
                <div class="flex flex-col">
                  <span class="text-xs">
                    {{ num(record.receivedQty) }}/{{ num(record.quantity) }}
                    <span
                      v-if="record.quantity - record.receivedQty > 0"
                      class="text-muted-foreground"
                    >
                      · còn thiếu
                      {{
                        num(
                          (record as OrderLine).quantity -
                            (record as OrderLine).receivedQty,
                        )
                      }}
                    </span>
                  </span>
                  <Progress
                    :percent="
                      record.quantity
                        ? Math.round(
                            (record.receivedQty / record.quantity) * 100,
                          )
                        : 100
                    "
                    :show-info="false"
                    size="small"
                  />
                </div>
              </template>
            </template>
          </Table>
          <Descriptions class="mt-3" :column="{ xs: 1, sm: 3 }" size="small">
            <Descriptions.Item label="Ngày sinh PO">
{{
              order.createdAt
            }}
</Descriptions.Item>
            <Descriptions.Item label="Ngày phát hành">
{{
              order.issuedAt ?? 'Chưa phát hành'
            }}
</Descriptions.Item>
            <Descriptions.Item label="Kiểm tra tại Purchasing">
{{
              request?.requireInspection ? 'Bắt buộc' : 'Không bắt buộc'
            }}
</Descriptions.Item>
          </Descriptions>
        </Tabs.TabPane>

        <Tabs.TabPane key="deliveries">
          <template #tab>
            Giao nhận ({{ batches.length }})
            <Tag v-if="pendingBatches" color="purple" class="ml-1 text-[10px]">
              {{ pendingBatches }} chờ kiểm tra
            </Tag>
          </template>
          <div class="mb-3 flex flex-wrap items-center justify-between gap-2">
            <span class="text-xs text-muted-foreground">
              {{
                request?.requireInspection
                  ? 'Phiếu bắt buộc kiểm tra: Purchasing kiểm tra trước, sau đó người đề xuất xác nhận nhận.'
                  : 'Phiếu không bắt buộc kiểm tra tại Purchasing: người đề xuất kiểm tra và xác nhận nhận.'
              }}
            </span>
            <Button
              v-if="status === 'in_progress'"
              type="primary"
              size="small"
              @click="deliveryOpen = true"
            >
              <template #icon>
                <IconifyIcon icon="lucide:plus" class="size-3.5" />
              </template>
              Ghi nhận đợt giao
            </Button>
          </div>
          <Empty
            v-if="batches.length === 0"
            :image="Empty.PRESENTED_IMAGE_SIMPLE"
            description="Chưa có đợt giao hàng."
          />
          <div v-else class="flex flex-col gap-2">
            <div
              v-for="batch in batches"
              :key="batch.id"
              class="rounded-md border p-3"
              :class="
                BATCH_ACTION[batch.status]
                  ? 'border-primary/40 bg-primary/5'
                  : 'border-border'
              "
            >
              <div class="flex flex-wrap items-center gap-2">
                <span class="font-mono font-semibold">{{ batch.code }}</span>
                <span class="text-xs text-muted-foreground">
                  Giao ngày {{ batch.deliveredAt }}
                </span>
                <Tag :color="DELIVERY_STATUS[batch.status].color" class="m-0">
                  {{ DELIVERY_STATUS[batch.status].text }}
                </Tag>
                <div class="ml-auto flex items-center gap-2">
                  <template v-if="BATCH_ACTION[batch.status]">
                    <span class="text-[11px] text-muted-foreground">
                      Việc của {{ BATCH_ACTION[batch.status]!.who }}
                    </span>
                    <Button
                      type="primary"
                      size="small"
                      @click="openInspect(batch)"
                    >
                      <template #icon>
                        <IconifyIcon
                          :icon="BATCH_ACTION[batch.status]!.icon"
                          class="size-3.5"
                        />
                      </template>
                      {{ BATCH_ACTION[batch.status]!.label }}
                    </Button>
                  </template>
                  <Button
                    v-else
                    type="link"
                    size="small"
                    class="h-auto p-0 text-xs"
                    @click="openInspect(batch)"
                  >
                    Xem diễn biến
                  </Button>
                </div>
              </div>
              <ul class="m-0 mt-2 list-none p-0 text-xs">
                <li
                  v-for="line in batch.lines"
                  :key="line.orderLineId"
                  class="flex gap-2"
                >
                  <span class="text-foreground">{{ line.itemName }}</span>
                  <span class="ml-auto text-muted-foreground">
                    Giao {{ num(line.deliveredQty) }}
                    <template v-if="line.passedQty !== undefined">
                      · Purchasing đạt {{ num(line.passedQty) }}
                    </template>
                    <template v-if="line.acceptedQty !== undefined">
                      · Nhận {{ num(line.acceptedQty) }}
                    </template>
                    {{ line.unit }}
                  </span>
                </li>
              </ul>
              <div
                v-if="batch.events.length"
                class="mt-2 border-t border-border/60 pt-1.5 text-[11px] text-muted-foreground"
              >
                Gần nhất: {{ batch.events.at(-1)!.action }} ·
                {{ batch.events.at(-1)!.actorName }} ·
                {{ batch.events.at(-1)!.timestamp }}
              </div>
            </div>
          </div>
        </Tabs.TabPane>

        <Tabs.TabPane
          key="payments"
          :tab="`Thanh toán (${order.payments.length})`"
        >
          <p class="m-0 mb-2 text-xs text-muted-foreground">
            Yêu cầu thanh toán do Purchasing tạo và xử lý tại Quỹ tiền mặt. PO
            chỉ hoàn thành khi đã nhận đủ hàng và tổng thanh toán hoàn thành
            bằng giá trị PO.
          </p>
          <Empty
            v-if="order.payments.length === 0"
            :image="Empty.PRESENTED_IMAGE_SIMPLE"
            description="Chưa có yêu cầu thanh toán."
          />
          <table v-else class="w-full border-collapse text-xs">
            <thead
              class="border-b border-border bg-muted/50 text-left text-muted-foreground"
            >
              <tr>
                <th class="p-2">Đề xuất bên Quỹ</th>
                <th class="p-2">Loại</th>
                <th class="p-2">Ghi chú</th>
                <th class="p-2">Ngày tạo</th>
                <th class="p-2 text-right">Số tiền</th>
                <th class="p-2">Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="payment in order.payments"
                :key="payment.id"
                class="border-b border-border/50"
              >
                <td class="p-2 font-mono text-primary">
                  {{ payment.cashProposalCode }}
                </td>
                <td class="p-2">{{ PAYMENT_KIND[payment.kind] }}</td>
                <td class="p-2 text-muted-foreground">
                  {{ payment.note || '-' }}
                </td>
                <td class="p-2">{{ payment.createdAt }}</td>
                <td
                  class="p-2 text-right font-semibold"
                  :class="
                    paymentStatus(payment) === 'rejected'
                      ? 'text-muted-foreground line-through'
                      : ''
                  "
                >
                  {{ money(payment.amount) }}
                </td>
                <td class="p-2">
                  <Tag
                    :color="PAYMENT_STATUS[paymentStatus(payment)].color"
                    class="m-0"
                    >
{{ PAYMENT_STATUS[paymentStatus(payment)].text }}
</Tag>
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="font-semibold">
                <td colspan="4" class="p-2 text-right">
                  Đã thanh toán / Giá trị PO
                </td>
                <td class="p-2 text-right">
                  {{ money(paid) }} / {{ money(total) }}
                </td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </Tabs.TabPane>

        <Tabs.TabPane key="history" tab="Phiên bản & bổ sung">
          <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div>
              <div class="mb-2 text-sm font-semibold">Lịch sử phiên bản</div>
              <Timeline>
                <Timeline.Item
                  v-for="v in [...order.versions].reverse()"
                  :key="v.version"
                  :color="v.version === order.version ? 'blue' : 'gray'"
                >
                  <div class="text-sm font-medium">
                    v{{ v.version }} · {{ v.note }}
                  </div>
                  <div class="text-xs text-muted-foreground">
                    {{ v.at }} · {{ v.by }}
                  </div>
                </Timeline.Item>
              </Timeline>
            </div>
            <div>
              <div class="mb-2 text-sm font-semibold">
                Yêu cầu bổ sung/chỉnh sửa
              </div>
              <Empty
                v-if="changes.length === 0"
                :image="Empty.PRESENTED_IMAGE_SIMPLE"
                description="Chưa có yêu cầu."
              />
              <div
                v-for="change in changes"
                :key="change.id"
                class="mb-2 rounded-md border border-border p-2.5 text-xs"
              >
                <div class="flex items-center gap-2">
                  <span class="font-mono font-semibold">{{ change.code }}</span>
                  <Tag
                    :color="CHANGE_STATUS[change.status].color"
                    class="m-0 ml-auto"
                    >
{{ CHANGE_STATUS[change.status].text }}
</Tag>
                </div>
                <p class="m-0 mt-1 text-muted-foreground">
                  {{ change.reason }}
                </p>
              </div>
            </div>
          </div>
        </Tabs.TabPane>
      </Tabs>

      <div class="flex justify-end border-t border-border pt-3">
        <Button @click="visible = false">Đóng</Button>
      </div>
    </div>

    <DeliveryFormModal
      v-if="order"
      v-model:open="deliveryOpen"
      :order="order"
    />
    <PaymentFormModal v-if="order" v-model:open="paymentOpen" :order="order" />
    <ChangeRequestFormModal
      v-if="order"
      v-model:open="changeOpen"
      :order="order"
    />
    <InspectModal
      v-model:open="inspectOpen"
      :batch="inspectBatch"
      @change="openChangeFromBatch"
    />
  </Modal>
</template>

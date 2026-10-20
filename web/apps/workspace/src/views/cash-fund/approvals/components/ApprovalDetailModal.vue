<script setup lang="ts">
import type { Proposal } from '../../types';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Card,
  Input,
  message,
  Modal,
  Popconfirm,
  Table,
  Tag,
  Timeline,
} from 'ant-design-vue';

import { $t } from '#/locales';

import { useCashFund } from '../../store';

const props = defineProps<{
  open: boolean;
  proposal: null | Proposal;
}>();

const emit = defineEmits<{
  (e: 'update:open', val: boolean): void;
  (e: 'processed'): void;
}>();

const { approveProposal, rejectProposal, returnEditProposal } = useCashFund();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const comment = ref('');
const showRejectInputModal = ref(false);
const showReturnInputModal = ref(false);
const selectedRowKeys = ref<string[]>([]);

watch(
  () => props.proposal,
  (newProp: null | Proposal) => {
    if (newProp) {
      selectedRowKeys.value = newProp.items.map((i) => i.id);
    } else {
      selectedRowKeys.value = [];
    }
  },
  { immediate: true },
);

const rowSelection = computed(() => ({
  selectedRowKeys: selectedRowKeys.value,
  onChange: (keys: (number | string)[]) => {
    selectedRowKeys.value = keys as string[];
  },
}));

const selectedItems = computed(() => {
  if (!props.proposal) return [];
  return props.proposal.items.filter((i) => selectedRowKeys.value.includes(i.id));
});

const selectedTotalAmount = computed(() => {
  return selectedItems.value.reduce((sum, i) => sum + i.amount, 0);
});

function resetState() {
  comment.value = '';
}

function handleApprove() {
  if (!props.proposal) return;

  if (selectedRowKeys.value.length === 0) {
    message.error('Vui lòng chọn ít nhất 01 khoản mục để phê duyệt.');
    return;
  }

  const isPartial = selectedRowKeys.value.length < props.proposal.items.length;
  const auditNote = isPartial
    ? `Duyệt ${selectedItems.value.length}/${props.proposal.items.length} khoản mục (Tổng duyệt: ${selectedTotalAmount.value.toLocaleString()} ${props.proposal.currency}). ${comment.value}`
    : comment.value;

  approveProposal(props.proposal.id, auditNote);
  message.success(
    `Đã phê duyệt ${selectedItems.value.length}/${props.proposal.items.length} khoản mục của đề xuất ${props.proposal.code}!`,
  );
  resetState();
  visible.value = false;
  emit('processed');
}

function handleConfirmReturn() {
  if (!props.proposal) return;
  if (!comment.value.trim()) {
    message.error('Bắt buộc phải nhập lý do yêu cầu chỉnh sửa.');
    return;
  }

  const isPartial = selectedRowKeys.value.length < props.proposal.items.length;
  const returnNote = isPartial
    ? `[Yêu cầu sửa ${selectedItems.value.length}/${props.proposal.items.length} khoản mục]: ${comment.value}`
    : comment.value;

  returnEditProposal(props.proposal.id, returnNote);
  message.warning(`Đã gửi yêu cầu chỉnh sửa cho đề xuất ${props.proposal.code}.`);
  resetState();
  showReturnInputModal.value = false;
  visible.value = false;
  emit('processed');
}

function handleConfirmReject() {
  if (!props.proposal) return;
  if (!comment.value.trim()) {
    message.error('Bắt buộc phải nhập lý do từ chối đề xuất.');
    return;
  }

  const isPartial = selectedRowKeys.value.length < props.proposal.items.length;
  const rejectNote = isPartial
    ? `[Từ chối ${selectedItems.value.length}/${props.proposal.items.length} khoản mục]: ${comment.value}`
    : comment.value;

  rejectProposal(props.proposal.id, rejectNote);
  message.error(`Đã từ chối đề xuất ${props.proposal.code}.`);
  resetState();
  showRejectInputModal.value = false;
  visible.value = false;
  emit('processed');
}

const itemColumns = computed(() => {
  const isSettlement = props.proposal?.type === 'settlement';

  const cols: any[] = [
    {
      title: 'STT',
      key: 'index',
      width: 48,
      align: 'center' as const,
      customRender: ({ index }: { index: number }) => index + 1,
    },
    {
      title: 'Khoản thu / chi',
      dataIndex: 'categoryName',
      key: 'categoryName',
      width: 170,
    },
    {
      title: 'Lý do / Diễn giải',
      dataIndex: 'reason',
      key: 'reason',
      minWidth: 320,
    },
    {
      title: 'Ngày',
      dataIndex: 'expectedDate',
      key: 'expectedDate',
      width: 110,
    },
    {
      title: 'Số tiền & Loại tiền',
      key: 'amountWithCurrency',
      width: 155,
      align: 'right' as const,
    },
  ];

  if (isSettlement) {
    cols.push({
      title: 'Tiền thực tế',
      dataIndex: 'actualAmount',
      key: 'actualAmount',
      width: 130,
      align: 'right' as const,
    });
  }

  cols.push({
    title: 'Chứng từ',
    key: 'attachment',
    width: 130,
  });

  return cols;
});
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="$t('cashFund.approvals.approvalProcess')"
    width="1050px"
    destroy-on-close
    :footer="null"
  >
    <div v-if="proposal" class="flex flex-col gap-5 py-2">
      <!-- Header Banner -->
      <div
        class="flex flex-wrap items-center justify-between gap-4 rounded-lg bg-muted/40 p-4 border border-border"
      >
        <div class="flex flex-col gap-1">
          <div class="flex items-center gap-2">
            <span class="text-xs font-semibold text-muted-foreground uppercase tracking-wider font-mono">
              {{ proposal.code }}
            </span>
            <Tag color="blue">{{ proposal.type }}</Tag>
            <span class="text-xs text-muted-foreground">Người lập: <strong>{{ proposal.applicantName }}</strong> ({{ proposal.department }})</span>
          </div>
          <h3 class="m-0 text-base font-semibold text-foreground">
            {{ proposal.title }}
          </h3>
        </div>

        <div class="text-right">
          <div class="text-xs text-muted-foreground">Tổng tiền duyệt</div>
          <div class="text-2xl font-bold text-primary">
            {{ proposal.totalAmount.toLocaleString() }} {{ proposal.currency }}
          </div>
        </div>
      </div>

      <!-- Settlement Info if applicable -->
      <div
        v-if="proposal.type === 'settlement'"
        class="rounded-lg border border-border bg-muted/20 p-3.5 text-xs"
      >
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div>
            <span class="text-muted-foreground block">Tạm ứng ban đầu:</span>
            <span class="font-semibold text-sm text-foreground">
              {{ (proposal.advanceOriginalAmount ?? 0).toLocaleString() }} {{ proposal.currency }}
            </span>
          </div>
          <div>
            <span class="text-muted-foreground block">Thực tế chi tiêu:</span>
            <span class="font-semibold text-sm text-foreground">
              {{ proposal.totalAmount.toLocaleString() }} {{ proposal.currency }}
            </span>
          </div>
          <div>
            <span class="text-muted-foreground block">Chênh lệch xử lý:</span>
            <span class="font-semibold text-sm text-foreground">
              {{ (proposal.settlementDifference ?? 0) > 0 ? '+' : '' }}
              {{ (proposal.settlementDifference ?? 0).toLocaleString() }} {{ proposal.currency }}
              ({{ (proposal.settlementDifference ?? 0) > 0 ? 'Chi thêm' : (proposal.settlementDifference ?? 0) < 0 ? 'Hoàn nộp quỹ' : 'Cân bằng' }})
            </span>
          </div>
        </div>
      </div>

      <!-- Line Items Table -->
      <Card size="small" class="border border-border">
        <template #title>
          <div class="flex flex-wrap items-center justify-between gap-2">
            <span class="font-semibold text-foreground text-xs">
              Danh sách khoản mục đề xuất (Chọn các khoản mục cần phê duyệt)
            </span>
            <div class="flex items-center gap-2 text-xs">
              <span class="text-muted-foreground">
                Đã chọn: <strong class="text-foreground">{{ selectedRowKeys.length }} / {{ proposal.items.length }}</strong> khoản
              </span>
              <span class="text-muted-foreground">|</span>
              <span class="text-muted-foreground">
                Tổng duyệt: <strong class="text-foreground">{{ selectedTotalAmount.toLocaleString() }} {{ proposal.currency }}</strong>
              </span>
            </div>
          </div>
        </template>
        <Table
          :data-source="proposal.items"
          :columns="itemColumns"
          :row-selection="rowSelection"
          :pagination="false"
          :scroll="{ x: 920 }"
          size="small"
          row-key="id"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'amountWithCurrency'">
              <span class="font-medium text-foreground">
                {{ record.amount.toLocaleString() }}
                <Tag class="ml-1 text-[11px]">
                  {{ record.currency || proposal.currency }}
                </Tag>
              </span>
            </template>
            <template v-else-if="column.key === 'attachment'">
              <div v-if="record.attachmentName" class="flex items-center gap-1 text-xs text-primary cursor-pointer hover:underline">
                <IconifyIcon icon="lucide:file-text" class="size-3.5 shrink-0" />
                <span class="truncate max-w-[110px]" :title="record.attachmentName">
                  {{ record.attachmentName }}
                </span>
              </div>
              <span v-else class="text-muted-foreground text-xs italic">-</span>
            </template>
          </template>
        </Table>
      </Card>

      <!-- Approval History -->
      <Card size="small" title="Lịch sử các bước duyệt trước" class="border border-border">
        <Timeline class="pl-2 mt-2">
          <Timeline.Item
            v-for="(hist, idx) in proposal.approvalHistory"
            :key="idx"
            :color="hist.action === 'approved' || hist.action === 'completed' ? 'green' : 'blue'"
          >
            <div class="flex flex-col gap-0.5 text-xs">
              <div class="flex items-center gap-2">
                <span class="font-semibold text-foreground">{{ hist.approverName }} ({{ hist.role }})</span>
                <Tag size="small">{{ hist.actionLabel }}</Tag>
                <span class="text-muted-foreground ml-auto">{{ hist.timestamp }}</span>
              </div>
              <p v-if="hist.comment" class="m-0 text-muted-foreground italic">
                "{{ hist.comment }}"
              </p>
            </div>
          </Timeline.Item>
        </Timeline>
      </Card>

      <!-- Approver Comment Input -->
      <div class="flex flex-col gap-2 rounded-lg bg-muted/20 p-4 border border-border">
        <label class="text-xs font-semibold text-foreground uppercase tracking-wider">
          Ý kiến / Ghi chú phê duyệt
        </label>
        <Input.TextArea
          v-model:value="comment"
          :placeholder="$t('cashFund.approvals.commentPlaceholder')"
          :rows="2"
        />
      </div>

      <!-- Action Footer -->
      <div class="flex items-center justify-between pt-2 border-t border-border">
        <Button @click="visible = false">
          {{ $t('cashFund.proposals.modal.close') }}
        </Button>

        <div class="flex items-center gap-2">
          <!-- Return for Revision -->
          <Button danger ghost @click="showReturnInputModal = true">
            <template #icon>
              <IconifyIcon icon="lucide:rotate-ccw" class="size-4" />
            </template>
            {{ $t('cashFund.approvals.returnEdit') }}
          </Button>

          <!-- Reject -->
          <Button danger @click="showRejectInputModal = true">
            <template #icon>
              <IconifyIcon icon="lucide:x-circle" class="size-4" />
            </template>
            {{ $t('cashFund.approvals.reject') }}
          </Button>

          <!-- Approve -->
          <Popconfirm
            :title="$t('cashFund.approvals.confirmApproveTitle')"
            description="Bạn có chắc chắn muốn phê duyệt đề xuất này?"
            ok-text="Xác nhận duyệt"
            cancel-text="Hủy"
            @confirm="handleApprove"
          >
            <Button type="primary">
              <template #icon>
                <IconifyIcon icon="lucide:check-circle" class="size-4" />
              </template>
              {{ $t('cashFund.approvals.approve') }}
            </Button>
          </Popconfirm>
        </div>
      </div>
    </div>

    <!-- Reason Modal for Reject -->
    <Modal
      v-model:open="showRejectInputModal"
      :title="$t('cashFund.approvals.confirmRejectTitle')"
      width="480px"
      ok-text="Xác nhận từ chối"
      cancel-text="Hủy"
      :ok-button-props="{ danger: true }"
      @ok="handleConfirmReject"
    >
      <div class="flex flex-col gap-3 py-2">
        <p class="text-xs text-muted-foreground m-0">
          Theo quy tắc <strong>CASH-BR-082</strong>, việc từ chối đề xuất bắt buộc phải ghi rõ lý do.
        </p>
        <Input.TextArea
          v-model:value="comment"
          placeholder="Nhập lý do từ chối cụ thể..."
          :rows="4"
        />
      </div>
    </Modal>

    <!-- Reason Modal for Return Edit -->
    <Modal
      v-model:open="showReturnInputModal"
      :title="$t('cashFund.approvals.confirmReturnTitle')"
      width="480px"
      ok-text="Xác nhận yêu cầu sửa"
      cancel-text="Hủy"
      @ok="handleConfirmReturn"
    >
      <div class="flex flex-col gap-3 py-2">
        <p class="text-xs text-muted-foreground m-0">
          Vui lòng chỉ rõ nội dung, chứng từ hoặc khoản mục cần nhân viên điều chỉnh trước khi gửi lại.
        </p>
        <Input.TextArea
          v-model:value="comment"
          placeholder="Nhập yêu cầu chỉnh sửa chi tiết..."
          :rows="4"
        />
      </div>
    </Modal>
  </Modal>
</template>

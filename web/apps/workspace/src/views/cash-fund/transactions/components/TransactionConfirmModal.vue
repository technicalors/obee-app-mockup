<script setup lang="ts">
import type { CashTransaction } from '../../types';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Alert,
  Button,
  Input,
  InputNumber,
  message,
  Modal,
  Popconfirm,
  Radio,
  Tag,
} from 'ant-design-vue';

import { $t } from '#/locales';

import { useCashFund } from '../../store';

const props = defineProps<{
  open: boolean;
  transaction: CashTransaction | null;
}>();

const emit = defineEmits<{
  (e: 'update:open', val: boolean): void;
  (e: 'confirmed'): void;
}>();

const { confirmTransaction } = useCashFund();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const actualAmount = ref<number>(0);
const paymentMethod = ref<'cash' | 'internal_transfer'>('cash');
const performedBy = ref('Đỗ Thị Lan (Thủ quỹ)');
const signedBy = ref('');

watch(
  () => props.transaction,
  (tx) => {
    if (tx) {
      actualAmount.value = tx.amount;
      paymentMethod.value = tx.paymentMethod;
      signedBy.value = tx.counterpartName;
    }
  },
  { immediate: true },
);

function handleConfirm() {
  if (!props.transaction) return;
  if (!actualAmount.value || actualAmount.value <= 0) {
    message.error('Số tiền thực tế phải lớn hơn 0.');
    return;
  }
  if (!signedBy.value.trim()) {
    message.error('Vui lòng nhập họ tên người ký nhận / nộp tiền.');
    return;
  }

  confirmTransaction({
    actualAmount: actualAmount.value,
    paymentMethod: paymentMethod.value,
    performedBy: performedBy.value,
    signedBy: signedBy.value,
    transactionId: props.transaction.id,
  });

  message.success(
    `Đã xác nhận thực hiện thành công bút toán ${props.transaction.code}! Số dư quỹ đã được cập nhật.`,
  );
  visible.value = false;
  emit('confirmed');
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="$t('cashFund.transactions.confirmTitle')"
    width="680px"
    destroy-on-close
    :footer="null"
  >
    <div v-if="transaction" class="flex flex-col gap-4 py-2">
      <!-- Top Alert -->
      <Alert
        type="info"
        show-icon
        message="Xác nhận giao dịch quỹ tiền mặt thực tế"
        description="Thủ quỹ kiểm tra tiền mặt thực tế, đối chiếu giấy tờ tùy thân của người nhận/nộp và ký biên lai trước khi xác nhận giao dịch."
      />

      <!-- Voucher Read-only summary -->
      <div class="rounded-lg border border-border bg-muted/30 p-3.5 flex flex-col gap-2">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <Tag class="font-medium">
              {{ transaction.type === 'expense' ? 'PHIẾU CHI' : 'PHIẾU THU' }}
            </Tag>
            <span class="font-mono font-bold text-foreground">{{ transaction.code }}</span>
          </div>
          <span class="text-xs text-muted-foreground">Liên kết: {{ transaction.proposalCode }}</span>
        </div>

        <div class="grid grid-cols-2 gap-2 text-xs pt-1 border-t border-border/60">
          <div>
            <span class="text-muted-foreground">Nguồn tiền quỹ:</span>
            <span class="font-medium text-foreground ml-1">{{ transaction.sourceName }}</span>
          </div>
          <div>
            <span class="text-muted-foreground">{{ transaction.type === 'expense' ? 'Người nhận:' : 'Người nộp:' }}</span>
            <span class="font-medium text-foreground ml-1">{{ transaction.counterpartName }}</span>
          </div>
          <div class="col-span-2">
            <span class="text-muted-foreground">Diễn giải:</span>
            <span class="text-foreground ml-1">{{ transaction.description }}</span>
          </div>
        </div>
      </div>

      <!-- Execution Form Inputs -->
      <div class="rounded-lg border border-border bg-card p-4 flex flex-col gap-3">
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
              Số tiền đề xuất (Readonly)
            </label>
            <Input :value="`${transaction.amount.toLocaleString()} ${transaction.currency}`" disabled class="bg-muted/40 font-bold" />
          </div>

          <div>
            <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
              Số tiền thực tế <span class="text-red-500">*</span>
            </label>
            <InputNumber
              v-model:value="actualAmount"
              :min="1"
              :formatter="(val) => `${val}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
              :parser="(val) => val.replace(/\$\s?|(,*)/g, '')"
              class="w-full font-bold text-primary"
            />
          </div>
        </div>

        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            Phương thức giao dịch
          </label>
          <Radio.Group v-model:value="paymentMethod" button-style="solid" size="small">
            <Radio.Button value="cash">
              <span class="flex items-center gap-1">
                <IconifyIcon icon="lucide:banknote" class="size-3.5" />
                Tiền mặt trực tiếp
              </span>
            </Radio.Button>
            <Radio.Button value="internal_transfer">
              <span class="flex items-center gap-1">
                <IconifyIcon icon="lucide:arrow-left-right" class="size-3.5" />
                Chuyển khoản nội bộ quỹ
              </span>
            </Radio.Button>
          </Radio.Group>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
              {{ transaction.type === 'expense' ? 'Họ tên người nhận tiền' : 'Họ tên người nộp tiền' }} <span class="text-red-500">*</span>
            </label>
            <Input v-model:value="signedBy" />
          </div>

          <div>
            <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
              Thủ quỹ phụ trách xác nhận
            </label>
            <Input v-model:value="performedBy" disabled class="bg-muted/40" />
          </div>
        </div>
      </div>

      <!-- Action Footer -->
      <div class="flex items-center justify-end gap-2 pt-2 border-t border-border">
        <Button @click="visible = false">Hủy</Button>
        <Popconfirm
          title="Xác nhận thực hiện giao dịch này?"
          description="Hệ thống sẽ cập nhật số dư tiền mặt của nguồn quỹ và ghi nhận hoàn tất giao dịch."
          ok-text="Xác nhận thực hiện"
          cancel-text="Đóng"
          @confirm="handleConfirm"
        >
          <Button type="primary">
            <template #icon>
              <IconifyIcon icon="lucide:check-circle-2" class="size-4" />
            </template>
            Xác nhận thực hiện
          </Button>
        </Popconfirm>
      </div>
    </div>
  </Modal>
</template>

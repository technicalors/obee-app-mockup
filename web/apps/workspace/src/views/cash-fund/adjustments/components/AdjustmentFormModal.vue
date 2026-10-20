<script setup lang="ts">
import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Alert,
  Button,
  Input,
  InputNumber,
  message,
  Modal,
  Select,
} from 'ant-design-vue';

import { $t } from '#/locales';

import { useCashFund } from '../../store';

const props = defineProps<{
  open: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:open', val: boolean): void;
  (e: 'created'): void;
}>();

const { createAdjustment, fundSources } = useCashFund();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const fromSourceId = ref<string>('');
const toSourceId = ref<string>('');
const amount = ref<number>(10000000);
const effectiveDate = ref<string>(new Date().toISOString().substring(0, 10));
const reason = ref('');
const attachmentName = ref('');

const selectedFromSource = computed(() =>
  fundSources.value.find((s) => s.id === fromSourceId.value),
);

const selectedToSource = computed(() =>
  fundSources.value.find((s) => s.id === toSourceId.value),
);

// Filter destination sources so that destination source != origin source
const destinationOptions = computed(() => {
  return fundSources.value.filter((s) => s.id !== fromSourceId.value);
});

function resetForm() {
  if (fundSources.value.length >= 2) {
    fromSourceId.value = fundSources.value[0]!.id;
    toSourceId.value = fundSources.value[1]!.id;
  }
  amount.value = 10000000;
  effectiveDate.value = new Date().toISOString().substring(0, 10);
  reason.value = '';
  attachmentName.value = '';
}

watch(
  () => props.open,
  (val) => {
    if (val) resetForm();
  },
);

function handleMockFileUpload() {
  attachmentName.value = `To_trinh_dieu_chuyen_quy_${Date.now().toString().slice(-4)}.pdf`;
  message.success(`Đã đính kèm chứng từ: ${attachmentName.value}`);
}

function handleCreate() {
  if (!fromSourceId.value || !toSourceId.value) {
    message.error('Vui lòng chọn đầy đủ nguồn chuyển và nguồn nhận.');
    return;
  }
  if (fromSourceId.value === toSourceId.value) {
    message.error('Nguồn chuyển và nguồn nhận phải khác nhau.');
    return;
  }
  if (!amount.value || amount.value <= 0) {
    message.error('Số tiền điều chuyển phải lớn hơn 0.');
    return;
  }
  if (selectedFromSource.value && amount.value > selectedFromSource.value.currentBalance) {
    message.error(
      `Số tiền điều chuyển vượt quá số dư hiện tại của nguồn chuyển (${selectedFromSource.value.currentBalance.toLocaleString()} ${selectedFromSource.value.currency}).`,
    );
    return;
  }
  if (!reason.value.trim()) {
    message.error('Vui lòng nhập lý do điều chuyển quỹ.');
    return;
  }
  if (!attachmentName.value) {
    message.error('Theo quy định CASH-BR, điều chỉnh quỹ bắt buộc phải có chứng từ đính kèm.');
    return;
  }

  createAdjustment({
    amount: amount.value,
    attachmentName: attachmentName.value,
    effectiveDate: effectiveDate.value,
    fromSourceId: fromSourceId.value,
    reason: reason.value,
    toSourceId: toSourceId.value,
  });

  message.success('Đã tạo đề xuất điều chỉnh quỹ thành công và chuyển vào tuyến phê duyệt!');
  visible.value = false;
  emit('created');
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="$t('cashFund.adjustments.create')"
    width="760px"
    destroy-on-close
    :footer="null"
  >
    <div class="flex flex-col gap-4 py-2">
      <!-- Validation Rules Notice -->
      <Alert
        type="info"
        show-icon
        message="Quy tắc điều chỉnh quỹ tiền mặt"
        description="Điều chuyển chỉ thực hiện giữa 02 nguồn tiền khác nhau trong cùng quỹ; bắt buộc có chứng từ đính kèm và không thực hiện một phần."
      />

      <!-- Source Transfer Pair -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 rounded-lg bg-muted/20 p-4 border border-border">
        <!-- From Source -->
        <div class="flex flex-col gap-2">
          <label class="text-xs font-semibold text-foreground uppercase tracking-wider flex items-center gap-1">
            <IconifyIcon icon="lucide:arrow-up-right" class="size-4" />
            {{ $t('cashFund.adjustments.fromSource') }} <span class="text-destructive">*</span>
          </label>
          <Select v-model:value="fromSourceId" class="w-full">
            <Select.Option v-for="s in fundSources" :key="s.id" :value="s.id">
              {{ s.name }} (Dư: {{ s.currentBalance.toLocaleString() }} {{ s.currency }})
            </Select.Option>
          </Select>
          <div v-if="selectedFromSource" class="text-xs text-muted-foreground bg-card p-2 rounded border border-border">
            <div>Công ty: <span class="font-medium text-foreground">{{ selectedFromSource.company }}</span></div>
            <div>Số dư khả dụng: <span class="font-semibold text-foreground">{{ selectedFromSource.currentBalance.toLocaleString() }} {{ selectedFromSource.currency }}</span></div>
          </div>
        </div>

        <!-- To Source -->
        <div class="flex flex-col gap-2">
          <label class="text-xs font-semibold text-foreground uppercase tracking-wider flex items-center gap-1">
            <IconifyIcon icon="lucide:arrow-down-left" class="size-4" />
            {{ $t('cashFund.adjustments.toSource') }} <span class="text-destructive">*</span>
          </label>
          <Select v-model:value="toSourceId" class="w-full">
            <Select.Option v-for="s in destinationOptions" :key="s.id" :value="s.id">
              {{ s.name }} (Dư: {{ s.currentBalance.toLocaleString() }} {{ s.currency }})
            </Select.Option>
          </Select>
          <div v-if="selectedToSource" class="text-xs text-muted-foreground bg-card p-2 rounded border border-border">
            <div>Công ty: <span class="font-medium text-foreground">{{ selectedToSource.company }}</span></div>
            <div>Số dư hiện tại: <span class="font-semibold text-foreground">{{ selectedToSource.currentBalance.toLocaleString() }} {{ selectedToSource.currency }}</span></div>
          </div>
        </div>
      </div>

      <!-- Amount & Date -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            {{ $t('cashFund.adjustments.amount') }} (VND) <span class="text-red-500">*</span>
          </label>
          <InputNumber
            v-model:value="amount"
            :min="1000"
            :step="1000000"
            :formatter="(val) => `${val}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
            :parser="(val) => val.replace(/\$\s?|(,*)/g, '')"
            class="w-full font-bold text-base text-primary"
          />
        </div>

        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            {{ $t('cashFund.adjustments.effectiveDate') }} <span class="text-red-500">*</span>
          </label>
          <input
            v-model="effectiveDate"
            type="date"
            class="w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm"
          />
        </div>
      </div>

      <!-- Reason -->
      <div>
        <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
          {{ $t('cashFund.adjustments.reason') }} <span class="text-red-500">*</span>
        </label>
        <Input.TextArea
          v-model:value="reason"
          placeholder="Nêu rõ mục đích điều chuyển nội bộ giữa hai nguồn tiền..."
          :rows="3"
        />
      </div>

      <!-- Attachment File Upload -->
      <div>
        <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
          Hồ sơ chứng từ đính kèm <span class="text-red-500">*</span>
        </label>
        <div class="flex items-center gap-2">
          <Button type="dashed" @click="handleMockFileUpload">
            <template #icon>
              <IconifyIcon icon="lucide:upload" class="size-4" />
            </template>
            Tải lên tờ trình / quyết định phê duyệt
          </Button>
          <span v-if="attachmentName" class="text-xs font-medium text-primary flex items-center gap-1">
            <IconifyIcon icon="lucide:file-text" class="size-4" />
            {{ attachmentName }}
          </span>
          <span v-else class="text-xs text-muted-foreground italic">Chưa chọn tệp</span>
        </div>
      </div>

      <!-- Action Footer -->
      <div class="flex items-center justify-end gap-2 pt-3 border-t border-border">
        <Button @click="visible = false">Hủy bỏ</Button>
        <Button type="primary" @click="handleCreate">
          Tạo & Gửi phê duyệt
        </Button>
      </div>
    </div>
  </Modal>
</template>

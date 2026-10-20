<script setup lang="ts">
import type { ProposalItem, ProposalType } from '../../types';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
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
  (e: 'success'): void;
  (e: 'update:open', val: boolean): void;
}>();

const { addProposal, categories, currencies, proposals } = useCashFund();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const formType = ref<ProposalType>('advance');
const formTitle = ref('');
const selectedAdvanceProposalId = ref<string | undefined>(undefined);

const formItems = ref<
  Array<{
    actualAmount?: number;
    amount: number;
    attachmentName?: string;
    categoryId: string;
    categoryName: string;
    currency: string;
    exchangeRate?: number;
    expectedDate: string;
    id: string;
    reason: string;
  }>
>([]);

// Filter categories according to proposal type
const availableCategories = computed(() => {
  const isReceipt = formType.value === 'receipt';
  return categories.value.filter(
    (c) => c.status === 'active' && (isReceipt ? c.type === 'receipt' : c.type === 'expense'),
  );
});

// Available completed advance proposals for settlement
const availableAdvanceProposals = computed(() => {
  return proposals.value.filter(
    (p) => p.type === 'advance' && (p.status === 'completed' || p.status === 'voucher_issued'),
  );
});

// Selected advance proposal details
const selectedAdvanceProposal = computed(() => {
  if (!selectedAdvanceProposalId.value) return null;
  return proposals.value.find((p) => p.id === selectedAdvanceProposalId.value) ?? null;
});

// Total amounts breakdown per currency
const totalBreakdown = computed(() => {
  const map = new Map<string, number>();
  formItems.value.forEach((item) => {
    const curr = item.currency || 'VND';
    const amt = Number(item.amount) || 0;
    map.set(curr, (map.get(curr) || 0) + amt);
  });
  return Array.from(map.entries())
    .map(([curr, total]) => `${total.toLocaleString()} ${curr}`)
    .join(' + ');
});

const hasForeignCurrency = computed(() => {
  return formItems.value.some((item) => item.currency && item.currency !== 'VND');
});

const totalConvertedVND = computed(() => {
  return formItems.value.reduce((sum, item) => {
    const amt = Number(item.amount) || 0;
    const rate = item.currency === 'VND' ? 1 : Number(item.exchangeRate) || 1;
    return sum + amt * rate;
  }, 0);
});

// Calculate total actual expense for settlement
const totalActualAmount = computed(() => {
  return formItems.value.reduce(
    (sum, item) =>
      sum +
      (item.actualAmount !== undefined
        ? Number(item.actualAmount)
        : Number(item.amount) || 0),
    0,
  );
});

// Calculate variance for settlement
const settlementDifference = computed(() => {
  if (formType.value !== 'settlement' || !selectedAdvanceProposal.value) return 0;
  return totalActualAmount.value - selectedAdvanceProposal.value.totalAmount;
});

function initEmptyItem() {
  const defaultCat = availableCategories.value[0];
  const defaultCurr = currencies.value.find((c) => c.isDefault) || currencies.value[0];
  return {
    actualAmount: 0,
    amount: 1000000,
    attachmentName: '',
    categoryId: defaultCat?.id ?? '',
    categoryName: defaultCat?.name ?? '',
    currency: defaultCurr?.code || 'VND',
    exchangeRate: defaultCurr?.exchangeRate || 1,
    expectedDate: new Date().toISOString().substring(0, 10),
    id: `item-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
    reason: '',
  };
}

function handleCategoryChange(record: any, catId: string) {
  const cat = categories.value.find((c) => c.id === catId);
  if (cat) {
    record.categoryId = cat.id;
    record.categoryName = cat.name;
  }
}

function handleItemCurrencyChange(item: any, newCurrCode: string) {
  item.currency = newCurrCode;
  const curr = currencies.value.find((c) => c.code === newCurrCode);
  if (curr) {
    item.exchangeRate = curr.exchangeRate;
  }
}

function addItemRow() {
  formItems.value.push(initEmptyItem());
}

function removeItemRow(index: number) {
  if (formItems.value.length <= 1) {
    message.warning('Đề xuất phải có ít nhất 01 khoản mục.');
    return;
  }
  formItems.value.splice(index, 1);
}

function handleMockFileUpload(record: any) {
  record.attachmentName = `Chung_tu_${record.categoryName.replace(/\s+/g, '_')}_${Date.now().toString().slice(-4)}.pdf`;
  message.success(`Đã đính kèm tệp: ${record.attachmentName}`);
}

function resetForm() {
  formType.value = 'advance';
  formTitle.value = '';
  selectedAdvanceProposalId.value = undefined;
  formItems.value = [initEmptyItem()];
}

watch(
  () => props.open,
  (newVal) => {
    if (newVal) {
      resetForm();
    }
  },
);

watch(formType, (newType) => {
  formItems.value.forEach((item) => {
    const valid = availableCategories.value.find((c) => c.id === item.categoryId);
    if (!valid && availableCategories.value.length > 0) {
      item.categoryId = availableCategories.value[0]!.id;
      item.categoryName = availableCategories.value[0]!.name;
    }
  });

  if (newType === 'settlement' && availableAdvanceProposals.value.length > 0) {
    selectedAdvanceProposalId.value = availableAdvanceProposals.value[0]!.id;
    onAdvanceSelected(selectedAdvanceProposalId.value);
  }
});

function onAdvanceSelected(advId?: string) {
  if (!advId) return;
  const adv = proposals.value.find((p) => p.id === advId);
  if (adv) {
    formTitle.value = `Quyết toán hoàn ứng cho: ${adv.title}`;
    formItems.value = adv.items.map((i) => ({
      ...i,
      actualAmount: i.amount,
      id: `item-settle-${Date.now()}-${Math.random().toString(36).substring(2, 5)}`,
    }));
  }
}

function handleSubmit(asDraft = false) {
  if (!formTitle.value.trim()) {
    message.error('Vui lòng nhập nội dung đề xuất.');
    return;
  }

  if (formItems.value.length === 0) {
    message.error('Vui lòng thêm ít nhất 01 khoản mục.');
    return;
  }

  for (const item of formItems.value) {
    if (!item.amount || item.amount <= 0) {
      message.error('Số tiền mỗi khoản mục phải lớn hơn 0.');
      return;
    }
    if (!item.reason.trim()) {
      message.error('Vui lòng nhập lý do / diễn giải cho tất cả các khoản mục.');
      return;
    }
  }

  if (formType.value === 'settlement' && !selectedAdvanceProposalId.value) {
    message.error('Vui lòng chọn đề xuất tạm ứng gốc cần quyết toán hoàn ứng.');
    return;
  }

  const itemsToSave: ProposalItem[] = formItems.value.map((i) => ({
    actualAmount: formType.value === 'settlement' ? i.actualAmount : undefined,
    amount: i.amount,
    attachmentName: i.attachmentName || undefined,
    categoryId: i.categoryId,
    categoryName: i.categoryName,
    categoryType: formType.value === 'receipt' ? 'receipt' : 'expense',
    currency: i.currency || 'VND',
    exchangeRate: i.currency === 'VND' ? 1 : i.exchangeRate || 1,
    expectedDate: i.expectedDate,
    id: i.id,
    reason: i.reason,
  }));

  addProposal({
    advanceProposalId: selectedAdvanceProposalId.value,
    items: itemsToSave,
    status: asDraft ? 'draft' : 'pending_dept',
    title: formTitle.value,
    type: formType.value,
  });

  message.success(
    asDraft
      ? 'Đã lưu bản nháp đề xuất thành công!'
      : 'Đã gửi đề xuất thành công! Hồ sơ đã được chuyển đến Trưởng bộ phận phê duyệt.',
  );

  visible.value = false;
  emit('success');
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="$t('cashFund.proposals.modal.createTitle')"
    width="1180px"
    destroy-on-close
    :footer="null"
  >
    <div class="flex flex-col gap-5 py-2">
      <!-- Top Form Controls (Mã đề xuất & Loại đề xuất - tiền tệ được cấu hình theo từng khoản mục) -->
      <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            {{ $t('cashFund.proposals.code') }}
          </label>
          <Input value="Hệ thống tự sinh (DX-YYYYMM-XXX)" disabled class="bg-muted/40 font-mono text-sm" />
        </div>

        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            {{ $t('cashFund.proposals.type') }} <span class="text-red-500">*</span>
          </label>
          <Select v-model:value="formType" class="w-full">
            <Select.Option value="advance">
              {{ $t('cashFund.proposals.types.advance') }}
            </Select.Option>
            <Select.Option value="payment">
              {{ $t('cashFund.proposals.types.payment') }}
            </Select.Option>
            <Select.Option value="receipt">
              {{ $t('cashFund.proposals.types.receipt') }}
            </Select.Option>
            <Select.Option value="settlement">
              {{ $t('cashFund.proposals.types.settlement') }}
            </Select.Option>
          </Select>
        </div>
      </div>

      <!-- Settlement Original Advance Selection -->
      <div
        v-if="formType === 'settlement'"
        class="rounded-lg border border-border bg-muted/20 p-4"
      >
        <div class="flex flex-col gap-3">
          <div class="flex flex-wrap items-center justify-between gap-2">
            <span class="text-sm font-semibold text-foreground">
              {{ $t('cashFund.proposals.modal.advanceRef') }} <span class="text-destructive">*</span>
            </span>
            <span v-if="selectedAdvanceProposal" class="text-xs text-muted-foreground">
              Giải ngân ngày: {{ selectedAdvanceProposal.createdAt }}
            </span>
          </div>

          <Select
            v-model:value="selectedAdvanceProposalId"
            :placeholder="$t('cashFund.proposals.modal.advanceRefPlaceholder')"
            class="w-full"
            @change="onAdvanceSelected(selectedAdvanceProposalId)"
          >
            <Select.Option v-for="adv in availableAdvanceProposals" :key="adv.id" :value="adv.id">
              [{{ adv.code }}] {{ adv.title }} - {{ adv.totalAmount.toLocaleString() }} {{ adv.currency }}
            </Select.Option>
          </Select>

          <div v-if="selectedAdvanceProposal" class="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-2 text-sm">
            <div class="bg-card rounded p-2.5 border border-border">
              <span class="text-xs text-muted-foreground block">
                {{ $t('cashFund.proposals.modal.originalAdvanceAmount') }}:
              </span>
              <span class="text-base font-semibold text-foreground">
                {{ selectedAdvanceProposal.totalAmount.toLocaleString() }} {{ selectedAdvanceProposal.currency }}
              </span>
            </div>
            <div class="bg-card rounded p-2.5 border border-border">
              <span class="text-xs text-muted-foreground block">
                {{ $t('cashFund.proposals.modal.actualExpense') }}:
              </span>
              <span class="text-base font-semibold text-foreground">
                {{ totalActualAmount.toLocaleString() }}
              </span>
            </div>
            <div class="bg-card rounded p-2.5 border border-border">
              <span class="text-xs text-muted-foreground block">
                {{ $t('cashFund.proposals.modal.difference') }}:
              </span>
              <span class="text-base font-semibold text-foreground">
                {{ settlementDifference > 0 ? '+' : '' }}
                {{ settlementDifference.toLocaleString() }}
              </span>
              <div class="text-[11px] text-muted-foreground mt-0.5">
                {{
                  settlementDifference > 0
                    ? $t('cashFund.proposals.modal.additionalAdvice')
                    : settlementDifference < 0
                      ? $t('cashFund.proposals.modal.refundAdvice')
                      : $t('cashFund.proposals.modal.balancedAdvice')
                }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Proposal Title / Purpose -->
      <div>
        <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
          {{ $t('cashFund.proposals.titleCol') }} <span class="text-red-500">*</span>
        </label>
        <Input
          v-model:value="formTitle"
          placeholder="Nhập mục đích, lý do đề xuất chi tiết..."
          size="middle"
        />
      </div>

      <!-- Dynamic Line Items Section with Currency configured per line item -->
      <div class="flex flex-col gap-2">
        <div class="flex items-center justify-between">
          <span class="text-sm font-semibold text-foreground">
            {{ $t('cashFund.proposals.modal.itemDetails') }} ({{ formItems.length }} khoản)
          </span>
          <Button type="dashed" size="small" @click="addItemRow">
            <template #icon>
              <IconifyIcon icon="lucide:plus" class="size-3.5" />
            </template>
            {{ $t('cashFund.proposals.modal.addItem') }}
          </Button>
        </div>

        <div class="overflow-x-auto rounded-lg border border-border">
          <table class="min-w-[1100px] w-full text-left text-xs border-collapse">
            <thead class="bg-muted/50 border-b border-border text-muted-foreground uppercase font-semibold">
              <tr>
                <th class="p-2.5 w-10 text-center">#</th>
                <th class="p-2.5 w-40">Khoản mục</th>
                <th class="p-2.5 min-w-[320px]">Lý do / Diễn giải</th>
                <th class="p-2.5 w-32">Ngày mong muốn</th>
                <th class="p-2.5 w-32 text-right">Số tiền</th>
                <th class="p-2.5 w-24">Loại tiền</th>
                <th class="p-2.5 w-28 text-right">Tỷ giá</th>
                <th v-if="formType === 'settlement'" class="p-2.5 w-32 text-right">Tiền thực tế</th>
                <th class="p-2.5 w-32">Chứng từ</th>
                <th class="p-2.5 w-10 text-center">Xóa</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-border/60 bg-card">
              <tr v-for="(item, idx) in formItems" :key="item.id" class="hover:bg-muted/20">
                <td class="p-2.5 text-center font-mono text-muted-foreground">
                  {{ idx + 1 }}
                </td>
                <td class="p-2.5">
                  <Select
                    :value="item.categoryId"
                    class="w-full"
                    size="small"
                    @change="(val: any) => handleCategoryChange(item, val)"
                  >
                    <Select.Option v-for="cat in availableCategories" :key="cat.id" :value="cat.id">
                      {{ cat.name }}
                    </Select.Option>
                  </Select>
                </td>
                <td class="p-2.5 min-w-[320px]">
                  <Input
                    v-model:value="item.reason"
                    placeholder="Diễn giải chi tiết..."
                    size="small"
                    class="w-full"
                  />
                </td>
                <td class="p-2.5">
                  <input
                    v-model="item.expectedDate"
                    type="date"
                    class="w-full rounded border border-input bg-background px-2 py-1 text-xs"
                  />
                </td>
                <td class="p-2.5 text-right">
                  <InputNumber
                    v-model:value="item.amount"
                    :min="1"
                    :step="100000"
                    :formatter="(value) => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
                    :parser="(value) => value.replace(/\$\s?|(,*)/g, '')"
                    size="small"
                    class="w-full text-right"
                  />
                </td>
                <!-- Currency per item -->
                <td class="p-2.5">
                  <Select
                    :value="item.currency"
                    class="w-full"
                    size="small"
                    @change="(val: any) => handleItemCurrencyChange(item, val)"
                  >
                    <Select.Option v-for="c in currencies" :key="c.code" :value="c.code">
                      {{ c.code }}
                    </Select.Option>
                  </Select>
                </td>
                <!-- Exchange Rate per item -->
                <td class="p-2.5 text-right">
                  <InputNumber
                    v-model:value="item.exchangeRate"
                    :disabled="item.currency === 'VND'"
                    :min="1"
                    :step="100"
                    :formatter="(value) => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
                    :parser="(value) => value.replace(/\$\s?|(,*)/g, '')"
                    size="small"
                    class="w-full text-right"
                  />
                </td>
                <td v-if="formType === 'settlement'" class="p-2.5 text-right">
                  <InputNumber
                    v-model:value="item.actualAmount"
                    :min="0"
                    :step="100000"
                    :formatter="(value) => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
                    :parser="(value) => value.replace(/\$\s?|(,*)/g, '')"
                    size="small"
                    class="w-full text-right font-medium text-primary"
                  />
                </td>
                <td class="p-2.5">
                  <div class="flex items-center gap-1.5">
                    <span v-if="item.attachmentName" class="truncate max-w-[80px] text-[11px] text-primary" :title="item.attachmentName">
                      {{ item.attachmentName }}
                    </span>
                    <Button
                      size="small"
                      type="text"
                      class="px-1 text-xs text-muted-foreground hover:text-foreground"
                      @click="handleMockFileUpload(item)"
                    >
                      <template #icon>
                        <IconifyIcon icon="lucide:paperclip" class="size-3.5" />
                      </template>
                    </Button>
                  </div>
                </td>
                <td class="p-2.5 text-center">
                  <Button
                    size="small"
                    type="text"
                    danger
                    class="p-0.5"
                    @click="removeItemRow(idx)"
                  >
                    <template #icon>
                      <IconifyIcon icon="lucide:trash-2" class="size-3.5" />
                    </template>
                  </Button>
                </td>
              </tr>
            </tbody>
            <tfoot class="bg-muted/40 font-semibold border-t border-border">
              <tr>
                <td colspan="4" class="p-2.5 text-right">
                  Tổng theo loại tiền:
                </td>
                <td colspan="3" class="p-2.5 text-sm font-bold text-foreground">
                  {{ totalBreakdown }}
                  <span v-if="hasForeignCurrency" class="block text-xs font-normal text-muted-foreground mt-0.5">
                    ≈ {{ totalConvertedVND.toLocaleString() }} VND (quy đổi)
                  </span>
                </td>
                <td v-if="formType === 'settlement'" class="p-2.5 text-right text-sm text-primary font-bold">
                  {{ totalActualAmount.toLocaleString() }}
                </td>
                <td colspan="2" />
              </tr>
            </tfoot>
          </table>
        </div>
      </div>

      <!-- Action Footer -->
      <div class="flex items-center justify-end gap-3 pt-3 border-t border-border">
        <Button @click="visible = false">
          {{ $t('cashFund.proposals.modal.close') }}
        </Button>
        <Button @click="handleSubmit(true)">
          {{ $t('cashFund.proposals.modal.saveDraft') }}
        </Button>
        <Button type="primary" @click="handleSubmit(false)">
          {{ $t('cashFund.proposals.modal.submit') }}
        </Button>
      </div>
    </div>
  </Modal>
</template>

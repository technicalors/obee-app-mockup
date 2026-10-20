<script setup lang="ts">
import type { Proposal, ProposalItem } from '../../types';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Card,
  Divider,
  Input,
  InputNumber,
  message,
  Modal,
  Popconfirm,
  Select,
  Tabs,
} from 'ant-design-vue';

import { $t } from '#/locales';

import { useCashFund } from '../../store';

const props = defineProps<{
  open: boolean;
  proposal: null | Proposal;
}>();

const emit = defineEmits<{
  (e: 'update:open', val: boolean): void;
  (e: 'success'): void;
}>();

const { categories, currencies, resubmitProposal } = useCashFund();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const activeTab = ref('edit');
const formTitle = ref('');
const formItems = ref<ProposalItem[]>([]);

// Keep snapshot of original before edit for comparison
const originalSnapshot = ref<{
  items: ProposalItem[];
  title: string;
  totalAmount: number;
} | null>(null);

watch(
  () => props.proposal,
  (p) => {
    if (p) {
      formTitle.value = p.title;
      formItems.value = JSON.parse(JSON.stringify(p.items));
      originalSnapshot.value = {
        items: JSON.parse(JSON.stringify(p.items)),
        title: p.title,
        totalAmount: p.totalAmount,
      };
    }
  },
  { immediate: true },
);

const currentTotalAmount = computed(() => {
  return formItems.value.reduce((sum, item) => sum + (Number(item.amount) || 0), 0);
});

function handleCategoryChange(item: ProposalItem, catId: string) {
  const cat = categories.value.find((c) => c.id === catId);
  if (cat) {
    item.categoryId = cat.id;
    item.categoryName = cat.name;
  }
}

function handleItemCurrencyChange(item: ProposalItem, newCurrCode: string) {
  item.currency = newCurrCode;
  const curr = currencies.value.find((c) => c.code === newCurrCode);
  if (curr) {
    item.exchangeRate = curr.exchangeRate;
  }
}

function addItemRow() {
  const defaultCat = categories.value[0];
  const defaultCurr = currencies.value.find((c) => c.isDefault) || currencies.value[0];
  formItems.value.push({
    amount: 1000000,
    attachmentName: '',
    categoryId: defaultCat?.id ?? '',
    categoryName: defaultCat?.name ?? '',
    categoryType: 'expense',
    currency: defaultCurr?.code || 'VND',
    exchangeRate: defaultCurr?.exchangeRate || 1,
    expectedDate: new Date().toISOString().substring(0, 10),
    id: `item-edit-${Date.now()}`,
    reason: '',
  });
}

function removeItemRow(index: number) {
  if (formItems.value.length <= 1) {
    message.warning('Phải giữ ít nhất 01 khoản mục.');
    return;
  }
  formItems.value.splice(index, 1);
}

function handleMockFileUpload(item: ProposalItem) {
  item.attachmentName = `Chung_tu_bo_sung_${Date.now().toString().slice(-4)}.pdf`;
  message.success(`Đã đính kèm tệp bổ sung: ${item.attachmentName}`);
}

function handleResubmit() {
  if (!props.proposal) return;

  if (!formTitle.value.trim()) {
    message.error('Vui lòng nhập nội dung đề xuất.');
    return;
  }

  for (const item of formItems.value) {
    if (!item.amount || item.amount <= 0) {
      message.error('Số tiền phải lớn hơn 0.');
      return;
    }
    if (!item.reason.trim()) {
      message.error('Vui lòng nhập lý do cho tất cả các khoản mục.');
      return;
    }
  }

  resubmitProposal(props.proposal.id, {
    items: formItems.value,
    title: formTitle.value,
  });

  message.success(
    'Đã gửi lại đề xuất thành công! Tuyến phê duyệt đã được khởi động lại từ cấp đầu tiên.',
  );
  visible.value = false;
  emit('success');
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="$t('cashFund.proposals.modal.returnEditTitle')"
    width="1180px"
    destroy-on-close
    :footer="null"
  >
    <div v-if="proposal" class="flex flex-col gap-5 py-2">
      <!-- Callout: Reason for Return -->
      <div
        class="rounded-lg border border-border bg-muted/20 p-3.5"
      >
        <div class="flex items-start gap-2.5">
          <IconifyIcon icon="lucide:alert-circle" class="size-4 text-muted-foreground mt-0.5 shrink-0" />
          <div class="flex flex-col gap-1 text-xs">
            <span class="font-semibold text-foreground">
              Lý do yêu cầu chỉnh sửa từ {{ proposal.returnedBy || 'Người phê duyệt' }} ({{ proposal.returnedAt }}):
            </span>
            <p class="m-0 text-muted-foreground bg-muted/40 p-2.5 rounded border border-border">
              "{{ proposal.returnReason }}"
            </p>
            <span class="text-[11px] text-muted-foreground mt-0.5">
              * Lưu ý: Sau khi chỉnh sửa và gửi lại, hồ sơ sẽ được khởi động duyệt lại từ cấp đầu tiên theo quy định.
            </span>
          </div>
        </div>
      </div>

      <Tabs v-model:activeKey="activeTab" type="card" size="small">
        <Tabs.TabPane key="edit" tab="Chỉnh sửa nội dung & khoản mục">
          <div class="flex flex-col gap-4 pt-2">
            <div>
              <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
                {{ $t('cashFund.proposals.titleCol') }}
              </label>
              <Input v-model:value="formTitle" size="middle" />
            </div>

            <div class="flex items-center justify-between">
              <span class="text-sm font-semibold text-foreground">
                Danh sách khoản mục ({{ formItems.length }})
              </span>
              <Button type="dashed" size="small" @click="addItemRow">
                <template #icon>
                  <IconifyIcon icon="lucide:plus" class="size-3.5" />
                </template>
                Thêm dòng
              </Button>
            </div>

            <div class="overflow-x-auto rounded-lg border border-border">
              <table class="min-w-[1080px] w-full text-left text-xs border-collapse">
                <thead class="bg-muted/50 border-b border-border text-muted-foreground uppercase font-semibold">
                  <tr>
                    <th class="p-2.5 w-10 text-center">#</th>
                    <th class="p-2.5 w-40">Khoản mục</th>
                    <th class="p-2.5 min-w-[320px]">Lý do / Diễn giải</th>
                    <th class="p-2.5 w-32">Ngày mong muốn</th>
                    <th class="p-2.5 w-32 text-right">Số tiền</th>
                    <th class="p-2.5 w-24">Loại tiền</th>
                    <th class="p-2.5 w-24 text-right">Tỷ giá</th>
                    <th class="p-2.5 w-28">Chứng từ</th>
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
                        <Select.Option v-for="cat in categories" :key="cat.id" :value="cat.id">
                          {{ cat.name }}
                        </Select.Option>
                      </Select>
                    </td>
                    <td class="p-2.5 min-w-[320px]">
                      <Input
                        v-model:value="item.reason"
                        placeholder="Nhập lý do / diễn giải chi tiết..."
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
                        :formatter="(val) => `${val}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
                        :parser="(val) => val.replace(/\$\s?|(,*)/g, '')"
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
                        :formatter="(val) => `${val}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
                        :parser="(val) => val.replace(/\$\s?|(,*)/g, '')"
                        size="small"
                        class="w-full text-right"
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
                          <IconifyIcon icon="lucide:paperclip" class="size-3.5" />
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
                        <IconifyIcon icon="lucide:trash-2" class="size-3.5" />
                      </Button>
                    </td>
                  </tr>
                </tbody>
                <tfoot class="bg-muted/40 font-semibold border-t border-border">
                  <tr>
                    <td colspan="4" class="p-2.5 text-right">
                      Tổng tiền mới:
                    </td>
                    <td class="p-2.5 text-right text-sm text-primary font-bold">
                      {{ currentTotalAmount.toLocaleString() }} {{ proposal.currency }}
                    </td>
                    <td colspan="2" />
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
        </Tabs.TabPane>

        <!-- Tab: Side-by-side comparison with original version -->
        <Tabs.TabPane key="diff" tab="So sánh thay đổi (Trước & Sau khi sửa)">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-2">
            <!-- Left: Before -->
            <Card size="small" title="Bản gốc trước khi sửa" class="bg-muted/20 border-border">
              <div class="flex flex-col gap-3 text-xs">
                <div>
                  <span class="font-semibold text-muted-foreground block">Nội dung:</span>
                  <span class="text-foreground">{{ originalSnapshot?.title }}</span>
                </div>
                <div>
                  <span class="font-semibold text-muted-foreground block">Tổng tiền:</span>
                  <span class="text-foreground font-bold">
                    {{ originalSnapshot?.totalAmount.toLocaleString() }} {{ proposal.currency }}
                  </span>
                </div>
                <Divider class="my-1" />
                <div class="font-semibold text-muted-foreground">Khoản mục ban đầu:</div>
                <div v-for="(it, i) in originalSnapshot?.items" :key="i" class="p-2 rounded bg-background border border-border">
                  <div class="font-medium text-foreground">{{ it.categoryName }}: {{ it.amount.toLocaleString() }} {{ it.currency }}</div>
                  <div class="text-muted-foreground text-[11px]">{{ it.reason }}</div>
                  <div v-if="it.attachmentName" class="text-[10px] text-primary mt-1">Tệp: {{ it.attachmentName }}</div>
                </div>
              </div>
            </Card>

            <!-- Right: After -->
            <Card size="small" title="Bản cập nhật hiện tại" class="bg-card border-border">
              <div class="flex flex-col gap-3 text-xs">
                <div>
                  <span class="font-semibold text-foreground block">Nội dung mới:</span>
                  <span class="text-foreground font-medium">{{ formTitle }}</span>
                </div>
                <div>
                  <span class="font-semibold text-foreground block">Tổng tiền mới:</span>
                  <span class="text-foreground font-bold text-sm">
                    {{ currentTotalAmount.toLocaleString() }} {{ proposal.currency }}
                  </span>
                </div>
                <Divider class="my-1" />
                <div class="font-semibold text-foreground">Khoản mục sau khi chỉnh sửa:</div>
                <div v-for="(it, i) in formItems" :key="i" class="p-2 rounded bg-background border border-border">
                  <div class="font-medium text-foreground">{{ it.categoryName }}: {{ it.amount.toLocaleString() }} {{ it.currency }}</div>
                  <div class="text-muted-foreground text-[11px]">{{ it.reason }}</div>
                  <div v-if="it.attachmentName" class="text-[10px] text-muted-foreground mt-1">Tệp: {{ it.attachmentName }}</div>
                </div>
              </div>
            </Card>
          </div>
        </Tabs.TabPane>
      </Tabs>

      <!-- Action Footer -->
      <div class="flex items-center justify-end gap-3 pt-3 border-t border-border">
        <Button @click="visible = false">
          {{ $t('cashFund.proposals.modal.close') }}
        </Button>
        <Popconfirm
          title="Xác nhận gửi lại phê duyệt?"
          description="Hồ sơ sẽ bắt đầu lại toàn bộ quy trình phê duyệt từ cấp 1."
          ok-text="Xác nhận gửi lại"
          cancel-text="Hủy"
          @confirm="handleResubmit"
        >
          <Button type="primary">
            {{ $t('cashFund.proposals.modal.resubmit') }}
          </Button>
        </Popconfirm>
      </div>
    </div>
  </Modal>
</template>

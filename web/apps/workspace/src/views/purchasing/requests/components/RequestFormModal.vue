<script setup lang="ts">
import type {
  ApprovalRole,
  ApprovalStep,
  PurchaseRequest,
  RequestLine,
  SupplierQuote,
} from '../../types';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Alert,
  Button,
  Checkbox,
  Input,
  InputNumber,
  message,
  Modal,
  Select,
  Switch,
  Tag,
} from 'ant-design-vue';

import { CURRENT_USER } from '../../mock-data';
import { usePurchasing } from '../../store';
import {
  KIND_LABELS,
  money,
  ROLE_LABELS,
  ROLE_ORDER,
  todayText,
} from '../../utils';

const props = defineProps<{
  open: boolean;
  request: null | PurchaseRequest;
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
}>();

const { approverPools, catalog, purposes, saveRequest, suppliers } =
  usePurchasing();

const visible = computed({
  get: () => props.open,
  set: (value) => emit('update:open', value),
});

interface QuoteDraft extends SupplierQuote {
  isNewSupplier: boolean;
}
interface LineDraft extends Omit<RequestLine, 'quotes'> {
  quotes: QuoteDraft[];
}

const note = ref('');
const needContract = ref(false);
const attachments = ref<string[]>([]);
const lines = ref<LineDraft[]>([]);
const approvers = ref<Record<ApprovalRole, string>>({
  ceo: '',
  dept: '',
  finance: '',
  purchasing: '',
});

const activeItems = computed(() =>
  catalog.value.filter((c) => c.status === 'active'),
);
const activeSuppliers = computed(() =>
  suppliers.value.filter((s) => s.status === 'active'),
);

const isEdit = computed(() => Boolean(props.request));
const title = computed(() => {
  if (!props.request) return 'Tạo đề nghị mua hàng';
  return props.request.status === 'return_edit'
    ? `Điều chỉnh đề nghị ${props.request.code}`
    : `Sửa bản nháp ${props.request.code}`;
});

/** Người tạo giữ vai trò ở cấp nào thì cây duyệt bỏ qua cấp đó (chỉ hiển thị từ cấp trên gần nhất). */
const skippedRoles = computed(() =>
  ROLE_ORDER.filter((role) =>
    approverPools.value[role].includes(CURRENT_USER.name),
  ),
);

function uid(prefix: string) {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
}

function emptyQuote(): QuoteDraft {
  return {
    id: uid('q'),
    isNewSupplier: false,
    supplierId: '',
    supplierName: '',
    unitPrice: 0,
  };
}

function emptyLine(): LineDraft {
  return {
    id: uid('rl'),
    itemId: '',
    itemName: '',
    kind: 'goods',
    neededDate: todayText(),
    purpose: '',
    quantity: 1,
    quotes: [emptyQuote()],
    spec: '',
    unit: '',
  };
}

function lineAmount(line: LineDraft) {
  return (line.quantity || 0) * (line.quotes[0]?.unitPrice || 0);
}

const total = computed(() =>
  lines.value.reduce((sum, line) => sum + lineAmount(line), 0),
);

watch(
  () => props.open,
  (open) => {
    if (!open) return;
    const source = props.request;
    note.value = source?.note ?? '';
    needContract.value = source?.needContract ?? false;
    attachments.value = [...(source?.attachments ?? [])];
    lines.value = source
      ? source.lines.map((line) => ({
          ...JSON.parse(JSON.stringify(line)),
          quotes: line.quotes.map((q) => ({
            ...q,
            isNewSupplier: Boolean(q.isNewSupplier),
          })),
        }))
      : [emptyLine()];
    for (const role of ROLE_ORDER) {
      approvers.value[role] =
        source?.approvalSteps.find((s) => s.role === role)?.approverName ??
        approverPools.value[role][0] ??
        '';
    }
  },
);

function onItemChange(line: LineDraft, itemId: string) {
  const item = catalog.value.find((c) => c.id === itemId);
  if (!item) return;
  line.itemId = item.id;
  line.itemName = item.name;
  line.kind = item.kind;
  line.unit = item.unit;
}

function onSupplierChange(quote: QuoteDraft, supplierId: string) {
  const supplier = suppliers.value.find((s) => s.id === supplierId);
  quote.supplierId = supplierId;
  quote.supplierName = supplier?.name ?? '';
}

function toggleNewSupplier(quote: QuoteDraft, value: boolean) {
  quote.isNewSupplier = value;
  quote.supplierId = value ? uid('new') : '';
  quote.supplierName = '';
}

function attachQuote(quote: QuoteDraft) {
  quote.quoteFile = `Bao_gia_${Date.now().toString().slice(-5)}.pdf`;
}

function attachFile() {
  attachments.value.push(`Tai_lieu_${Date.now().toString().slice(-5)}.pdf`);
}

function removeLine(index: number) {
  if (lines.value.length <= 1) {
    message.warning('Đề nghị phải có ít nhất 1 dòng hàng hóa/dịch vụ.');
    return;
  }
  lines.value.splice(index, 1);
}

function removeQuote(line: LineDraft, index: number) {
  if (line.quotes.length <= 1) {
    message.warning('Mỗi dòng cần tối thiểu 1 nhà cung cấp.');
    return;
  }
  line.quotes.splice(index, 1);
}

function validate(submit: boolean) {
  for (const [index, line] of lines.value.entries()) {
    const label = `Dòng ${index + 1}`;
    if (!line.itemId) return `${label}: chọn hàng hóa/dịch vụ.`;
    if (!submit) continue;
    if (!Number.isInteger(line.quantity) || line.quantity <= 0)
      return `${label}: số lượng phải là số nguyên lớn hơn 0.`;
    if (!line.purpose) return `${label}: chọn mục đích mua.`;
    if (!line.neededDate) return `${label}: nhập ngày cần hàng.`;
    for (const quote of line.quotes) {
      if (!quote.supplierName.trim())
        return `${label}: chọn hoặc nhập tên nhà cung cấp.`;
      if (!quote.unitPrice || quote.unitPrice <= 0)
        return `${label}: đơn giá phải lớn hơn 0.`;
    }
  }
  if (submit) {
    for (const role of ROLE_ORDER) {
      if (!skippedRoles.value.includes(role) && !approvers.value[role])
        return `Chọn người duyệt cấp ${ROLE_LABELS[role]}.`;
    }
  }
  return '';
}

function handleSave(submit: boolean) {
  const error = validate(submit);
  if (error) {
    message.error(error);
    return;
  }
  const approvalSteps: ApprovalStep[] = ROLE_ORDER.map((role) => ({
    approverName: approvers.value[role],
    role,
    skipped: skippedRoles.value.includes(role) || undefined,
  }));
  const saved = saveRequest(
    props.request?.id ?? null,
    {
      approvalSteps,
      attachments: attachments.value,
      lines: lines.value.map((line) => ({
        ...line,
        quotes: line.quotes.map((q) => ({
          ...q,
          isNewSupplier: q.isNewSupplier || undefined,
        })),
      })),
      needContract: needContract.value,
      note: note.value.trim(),
    },
    submit,
  );
  message.success(
    submit
      ? `Đã gửi ${saved.code}. Phiếu chuyển đến ${approvers.value.dept || 'cấp duyệt kế tiếp'}.`
      : `Đã lưu nháp ${saved.code}.`,
  );
  visible.value = false;
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="title"
    width="1180px"
    destroy-on-close
    :footer="null"
  >
    <div class="flex flex-col gap-5 py-2">
      <Alert
        v-if="request?.status === 'return_edit' && request.returnReason"
        type="warning"
        show-icon
        :message="`Lý do yêu cầu điều chỉnh: ${request.returnReason}`"
        description="Sau khi gửi lại, phiếu được duyệt lại từ đầu."
      />

      <div class="grid grid-cols-1 gap-4 md:grid-cols-3">
        <div>
          <label
            class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
            >Số phiếu</label>
          <Input
            :value="request?.code ?? 'Hệ thống tự sinh (DNMH-<năm>-<5 số>)'"
            disabled
            class="font-mono"
          />
        </div>
        <div>
          <label
            class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
            >Người đề xuất</label>
          <Input
            :value="`${CURRENT_USER.name} - ${CURRENT_USER.department}`"
            disabled
          />
        </div>
        <div class="flex items-end gap-3">
          <div class="flex items-center gap-2 pb-1.5">
            <Switch v-model:checked="needContract" size="small" />
            <span class="text-sm text-foreground">Cần hợp đồng</span>
          </div>
          <Button size="small" class="mb-1" @click="attachFile">
            <template #icon>
<IconifyIcon icon="lucide:paperclip" class="size-3.5" />
</template>
            Đính kèm
          </Button>
        </div>
      </div>

      <div>
        <label
          class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
          >Ghi chú (không bắt buộc)</label>
        <Input.TextArea
          v-model:value="note"
          :rows="2"
          placeholder="Bối cảnh, lý do chung của đề nghị..."
        />
        <div v-if="attachments.length" class="mt-2 flex flex-wrap gap-1.5">
          <Tag
            v-for="(file, index) in attachments"
            :key="file"
            closable
            @close="attachments.splice(index, 1)"
          >
            <IconifyIcon icon="lucide:file-text" class="mr-1 inline size-3" />{{
              file
            }}
          </Tag>
        </div>
      </div>

      <div class="flex flex-col gap-3">
        <div class="flex items-center justify-between">
          <span class="text-sm font-semibold text-foreground">Hàng hóa / dịch vụ ({{ lines.length }} dòng)</span>
          <Button type="dashed" size="small" @click="lines.push(emptyLine())">
            <template #icon>
<IconifyIcon icon="lucide:plus" class="size-3.5" />
</template>
            Thêm dòng
          </Button>
        </div>

        <div
          v-for="(line, index) in lines"
          :key="line.id"
          class="rounded-lg border border-border bg-card"
        >
          <div class="grid grid-cols-12 gap-3 p-3">
            <div
              class="col-span-12 flex items-center justify-between md:hidden"
            >
              <span class="font-mono text-xs text-muted-foreground">#{{ index + 1 }}</span>
            </div>
            <div class="col-span-12 md:col-span-3">
              <label class="mb-1 block text-[11px] text-muted-foreground">
                <span class="hidden font-mono md:inline">#{{ index + 1 }} · </span>Hàng hóa / dịch vụ <span class="text-red-500">*</span>
              </label>
              <Select
                :value="line.itemId || undefined"
                show-search
                option-filter-prop="label"
                placeholder="Chọn từ danh mục"
                class="w-full"
                size="small"
                :options="
                  activeItems.map((c) => ({
                    label: `${c.name} (${KIND_LABELS[c.kind]})`,
                    value: c.id,
                  }))
                "
                @change="(value: any) => onItemChange(line, value)"
              />
            </div>
            <div class="col-span-12 md:col-span-3">
              <label class="mb-1 block text-[11px] text-muted-foreground">Quy cách / thông số</label>
              <Input
                v-model:value="line.spec"
                size="small"
                placeholder="Model, hãng, thông số..."
              />
            </div>
            <div class="col-span-4 md:col-span-1">
              <label class="mb-1 block text-[11px] text-muted-foreground">Số lượng <span class="text-red-500">*</span></label>
              <InputNumber
                v-model:value="line.quantity"
                :min="1"
                :precision="0"
                size="small"
                class="w-full"
              />
            </div>
            <div class="col-span-3 md:col-span-1">
              <label class="mb-1 block text-[11px] text-muted-foreground">ĐVT</label>
              <Input :value="line.unit" size="small" disabled />
            </div>
            <div class="col-span-5 md:col-span-2">
              <label class="mb-1 block text-[11px] text-muted-foreground">Mục đích <span class="text-red-500">*</span></label>
              <Select
                v-model:value="line.purpose"
                size="small"
                class="w-full"
                placeholder="Chọn"
                :options="
                  purposes.map((p) => ({ label: p.name, value: p.name }))
                "
              />
            </div>
            <div class="col-span-10 md:col-span-2">
              <label class="mb-1 block text-[11px] text-muted-foreground">Ngày cần hàng <span class="text-red-500">*</span></label>
              <input
                v-model="line.neededDate"
                type="date"
                class="h-6 w-full rounded border border-input bg-background px-2 text-xs"
              />
            </div>
          </div>

          <div class="border-t border-border/60 bg-muted/20 px-3 py-2">
            <div class="mb-1.5 flex items-center justify-between">
              <span
                class="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground"
              >
                Nhà cung cấp đề xuất · Purchasing chọn NCC cuối khi duyệt
              </span>
              <Button
                type="link"
                size="small"
                class="h-auto p-0 text-xs"
                @click="line.quotes.push(emptyQuote())"
              >
                + Thêm NCC so sánh
              </Button>
            </div>
            <div class="overflow-x-auto">
              <table class="w-full min-w-[760px] border-collapse text-xs">
                <tbody>
                  <tr
                    v-for="(quote, qIndex) in line.quotes"
                    :key="quote.id"
                    class="border-b border-border/40 last:border-0"
                  >
                    <td class="w-24 py-1.5 pr-2">
                      <Checkbox
                        :checked="quote.isNewSupplier"
                        @update:checked="
                          (value: boolean) => toggleNewSupplier(quote, value)
                        "
                      >
                        <span class="text-xs">NCC mới</span>
                      </Checkbox>
                    </td>
                    <td class="py-1.5 pr-2">
                      <Input
                        v-if="quote.isNewSupplier"
                        v-model:value="quote.supplierName"
                        size="small"
                        placeholder="Tên NCC chưa có trong danh mục"
                      />
                      <Select
                        v-else
                        :value="quote.supplierId || undefined"
                        show-search
                        option-filter-prop="label"
                        size="small"
                        class="w-full"
                        placeholder="Chọn NCC trong danh mục"
                        :options="
                          activeSuppliers.map((s) => ({
                            label: s.name,
                            value: s.id,
                          }))
                        "
                        @change="(value: any) => onSupplierChange(quote, value)"
                      />
                    </td>
                    <td class="w-44 py-1.5 pr-2">
                      <InputNumber
                        v-model:value="quote.unitPrice"
                        :min="0"
                        :step="10000"
                        :formatter="
                          (value: any) =>
                            `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, '.')
                        "
                        :parser="(value: any) => value.replace(/\./g, '')"
                        size="small"
                        class="w-full"
                        addon-after="₫"
                        placeholder="Đơn giá sau thuế"
                      />
                    </td>
                    <td class="w-44 py-1.5 pr-2">
                      <span
                        v-if="quote.quoteFile"
                        class="inline-flex max-w-[150px] items-center gap-1 truncate text-primary"
                      >
                        <IconifyIcon
                          icon="lucide:file-text"
                          class="size-3.5 shrink-0"
                        />{{ quote.quoteFile }}
                      </span>
                      <Button
                        v-else
                        type="text"
                        size="small"
                        class="px-1 text-xs text-muted-foreground"
                        @click="attachQuote(quote)"
                      >
                        <template #icon>
<IconifyIcon
                            icon="lucide:paperclip"
                            class="size-3.5"
                        />
</template>
                        Báo giá
                      </Button>
                    </td>
                    <td class="w-8 py-1.5 text-center">
                      <Button
                        type="text"
                        size="small"
                        danger
                        class="p-0.5"
                        @click="removeQuote(line, qIndex)"
                      >
                        <template #icon>
<IconifyIcon icon="lucide:x" class="size-3.5" />
</template>
                      </Button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <div
            class="flex items-center justify-between border-t border-border/60 px-3 py-2 text-xs"
          >
            <span class="text-muted-foreground">
              Thành tiền tạm tính (theo NCC đầu tiên):
              <span class="font-semibold text-foreground">{{
                money(lineAmount(line))
              }}</span>
            </span>
            <Button type="text" size="small" danger @click="removeLine(index)">
              <template #icon>
<IconifyIcon icon="lucide:trash-2" class="size-3.5" />
</template>
              Xóa dòng
            </Button>
          </div>
        </div>

        <div
          class="flex items-center justify-end gap-2 rounded-md bg-muted/40 px-3 py-2 text-sm"
        >
          <span class="text-muted-foreground">Tổng giá trị đề xuất:</span>
          <span class="text-base font-bold text-primary">{{
            money(total)
          }}</span>
        </div>
      </div>

      <div class="rounded-lg border border-border p-3">
        <div class="mb-2 flex flex-wrap items-baseline justify-between gap-2">
          <span class="text-sm font-semibold text-foreground">Cây phê duyệt</span>
          <span class="text-xs text-muted-foreground">
            Thứ tự cấp duyệt cố định. Chọn người duyệt ở từng vị trí; cấp mà bạn
            đang giữ vai trò sẽ được bỏ qua.
          </span>
        </div>
        <div class="grid grid-cols-1 gap-3 md:grid-cols-4">
          <div v-for="(role, index) in ROLE_ORDER" :key="role">
            <label class="mb-1 block text-[11px] text-muted-foreground">
              {{ index + 1 }}. {{ ROLE_LABELS[role] }}
              <span v-if="!skippedRoles.includes(role)" class="text-red-500">*</span>
            </label>
            <Input
              v-if="skippedRoles.includes(role)"
              value="Bỏ qua - bạn giữ vai trò này"
              disabled
              size="small"
            />
            <Select
              v-else
              v-model:value="approvers[role]"
              size="small"
              class="w-full"
              :options="
                approverPools[role].map((name) => ({
                  label: name,
                  value: name,
                }))
              "
            />
          </div>
        </div>
      </div>

      <div
        class="flex items-center justify-end gap-3 border-t border-border pt-3"
      >
        <Button @click="visible = false">Đóng</Button>
        <Button
          v-if="!isEdit || request?.status === 'draft'"
          @click="handleSave(false)"
          >
Lưu nháp
</Button>
        <Button type="primary" @click="handleSave(true)">
          {{
            request?.status === 'return_edit' ? 'Gửi lại duyệt' : 'Gửi duyệt'
          }}
        </Button>
      </div>
    </div>
  </Modal>
</template>

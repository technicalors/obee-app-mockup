<script setup lang="ts">
import type { ChangeKind, ChangeLine, PurchaseOrder } from '../../types';

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

import { usePurchasing } from '../../store';
import { CHANGE_KIND, money, num } from '../../utils';

const props = defineProps<{
  open: boolean;
  order: PurchaseOrder;
}>();

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void;
}>();

const { catalog, createChangeRequest, suppliers } = usePurchasing();

const visible = computed({
  get: () => props.open,
  set: (value) => emit('update:open', value),
});

interface Row {
  id: string;
  kind: ChangeKind;
  orderLineId?: string;
  itemId?: string;
  newQty: number;
  supplierId?: string;
  unitPrice: number;
}

const reason = ref('');
const rows = ref<Row[]>([]);

function newRow(): Row {
  const first = props.order.lines[0];
  return {
    id: `row-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
    kind: 'quantity',
    newQty: first?.quantity ?? 0,
    orderLineId: first?.id,
    unitPrice: first?.unitPrice ?? 0,
  };
}

watch(
  () => props.open,
  (open) => {
    if (!open) return;
    reason.value = '';
    rows.value = [newRow()];
  },
  { immediate: true },
);

function lineOf(row: Row) {
  return props.order.lines.find((l) => l.id === row.orderLineId);
}

function onKindChange(row: Row, kind: ChangeKind) {
  row.kind = kind;
  const line = lineOf(row);
  if (kind === 'quantity') row.newQty = line?.quantity ?? 0;
  if (kind === 'supplier')
    row.newQty = line ? line.quantity - line.receivedQty : 0;
  if (kind === 'add') {
    row.itemId = undefined;
    row.newQty = 1;
    row.supplierId = props.order.supplierId;
  }
}

function onLineChange(row: Row, id: string) {
  row.orderLineId = id;
  onKindChange(row, row.kind);
  row.unitPrice = lineOf(row)?.unitPrice ?? 0;
}

function submit() {
  if (!reason.value.trim()) {
    message.error('Nhập lý do phát sinh.');
    return;
  }
  const lines: ChangeLine[] = [];
  for (const row of rows.value) {
    const line = lineOf(row);
    const supplier = suppliers.value.find((s) => s.id === row.supplierId);
    if (row.kind === 'add') {
      const item = catalog.value.find((c) => c.id === row.itemId);
      if (!item || row.newQty <= 0 || row.unitPrice <= 0) {
        message.error('Thêm mặt hàng: chọn hàng hóa, số lượng và đơn giá.');
        return;
      }
      lines.push({
        currentQty: 0,
        currentSupplier: '-',
        id: row.id,
        itemName: item.name,
        kind: 'add',
        newQty: row.newQty,
        newSupplierId: supplier?.id,
        newSupplierName: supplier?.name,
        unit: item.unit,
        unitPrice: row.unitPrice,
      });
      continue;
    }
    if (!line) return;
    if (row.kind === 'quantity') {
      if (row.newQty < line.receivedQty) {
        message.error(
          `${line.itemName}: số lượng mới không được nhỏ hơn số đã nhận (${line.receivedQty}).`,
        );
        return;
      }
      lines.push({
        currentQty: line.quantity,
        currentSupplier: props.order.supplierName,
        id: row.id,
        itemName: line.itemName,
        kind: 'quantity',
        newQty: row.newQty,
        orderLineId: line.id,
        unit: line.unit,
        unitPrice: line.unitPrice,
      });
    } else {
      if (!supplier || row.newQty <= 0) {
        message.error(`${line.itemName}: chọn NCC mới và số lượng chuyển.`);
        return;
      }
      lines.push(
        {
          currentQty: line.quantity,
          currentSupplier: props.order.supplierName,
          id: `${row.id}-q`,
          itemName: line.itemName,
          kind: 'quantity',
          newQty: line.quantity - row.newQty,
          orderLineId: line.id,
          unit: line.unit,
          unitPrice: line.unitPrice,
        },
        {
          currentQty: 0,
          currentSupplier: props.order.supplierName,
          id: row.id,
          itemName: line.itemName,
          kind: 'supplier',
          newQty: row.newQty,
          newSupplierId: supplier.id,
          newSupplierName: supplier.name,
          orderLineId: line.id,
          unit: line.unit,
          unitPrice: row.unitPrice,
        },
      );
    }
  }
  const change = createChangeRequest(props.order.id, {
    lines,
    reason: reason.value.trim(),
  });
  message.success(
    `Đã gửi ${change?.code}. Yêu cầu được duyệt lại đủ 4 cấp; các mặt hàng liên quan tạm dừng giao nhận.`,
  );
  visible.value = false;
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="`Yêu cầu bổ sung/chỉnh sửa - ${order.code} (v${order.version})`"
    width="980px"
    :footer="null"
    destroy-on-close
  >
    <div class="flex flex-col gap-4 py-2">
      <Alert
        type="warning"
        show-icon
        message="Yêu cầu làm thay đổi nội dung đã duyệt sẽ đi lại đủ 4 cấp duyệt. Hàng lỗi (NG) không cần tạo yêu cầu - báo lỗi để Purchasing xử lý với NCC."
      />
      <div>
        <label
          class="mb-1 block text-xs font-semibold uppercase tracking-wider text-muted-foreground"
          >Lý do phát sinh <span class="text-red-500">*</span></label>
        <Input.TextArea
          v-model:value="reason"
          :rows="2"
          placeholder="Ví dụ: NCC báo hết hàng phần còn lại, cần chuyển NCC khác"
        />
      </div>

      <div class="flex items-center justify-between">
        <span class="text-sm font-semibold">Nội dung thay đổi</span>
        <Button type="dashed" size="small" @click="rows.push(newRow())">
          <template #icon>
<IconifyIcon icon="lucide:plus" class="size-3.5" />
</template>
          Thêm thay đổi
        </Button>
      </div>

      <div
        v-for="(row, index) in rows"
        :key="row.id"
        class="grid grid-cols-12 items-end gap-2 rounded-md border border-border p-3"
      >
        <div class="col-span-12 md:col-span-2">
          <label class="mb-1 block text-[11px] text-muted-foreground">Loại thay đổi</label>
          <Select
            :value="row.kind"
            size="small"
            class="w-full"
            :options="
              (Object.keys(CHANGE_KIND) as ChangeKind[]).map((k) => ({
                label: CHANGE_KIND[k],
                value: k,
              }))
            "
            @change="(v: any) => onKindChange(row, v)"
          />
        </div>

        <div v-if="row.kind !== 'add'" class="col-span-12 md:col-span-3">
          <label class="mb-1 block text-[11px] text-muted-foreground">Mặt hàng trên PO</label>
          <Select
            :value="row.orderLineId"
            size="small"
            class="w-full"
            :options="
              order.lines.map((l) => ({
                label: `${l.itemName} (đặt ${num(l.quantity)}, đã nhận ${num(l.receivedQty)})`,
                value: l.id,
              }))
            "
            @change="(v: any) => onLineChange(row, v)"
          />
        </div>
        <div v-else class="col-span-12 md:col-span-3">
          <label class="mb-1 block text-[11px] text-muted-foreground">Hàng hóa / dịch vụ</label>
          <Select
            v-model:value="row.itemId"
            show-search
            option-filter-prop="label"
            size="small"
            class="w-full"
            placeholder="Chọn từ danh mục"
            :options="
              catalog
                .filter((c) => c.status === 'active')
                .map((c) => ({ label: c.name, value: c.id }))
            "
          />
        </div>

        <div class="col-span-6 md:col-span-2">
          <label class="mb-1 block text-[11px] text-muted-foreground">
            {{
              row.kind === 'quantity'
                ? 'Số lượng mới (0 = không mua nữa)'
                : row.kind === 'supplier'
                  ? 'SL chuyển NCC khác'
                  : 'Số lượng'
            }}
          </label>
          <InputNumber
            v-model:value="row.newQty"
            :min="0"
            :precision="0"
            size="small"
            class="w-full"
          />
        </div>

        <div v-if="row.kind !== 'quantity'" class="col-span-12 md:col-span-3">
          <label class="mb-1 block text-[11px] text-muted-foreground">NCC</label>
          <Select
            v-model:value="row.supplierId"
            show-search
            option-filter-prop="label"
            size="small"
            class="w-full"
            placeholder="Chọn NCC"
            :options="
              suppliers
                .filter(
                  (s) =>
                    s.status === 'active' &&
                    (row.kind === 'add' || s.id !== order.supplierId),
                )
                .map((s) => ({ label: s.name, value: s.id }))
            "
          />
        </div>
        <div v-if="row.kind !== 'quantity'" class="col-span-5 md:col-span-1">
          <label class="mb-1 block text-[11px] text-muted-foreground">Đơn giá</label>
          <InputNumber
            v-model:value="row.unitPrice"
            :min="0"
            :step="10000"
            size="small"
            class="w-full"
          />
        </div>
        <div
          v-if="row.kind === 'quantity'"
          class="col-span-5 text-xs text-muted-foreground md:col-span-4"
        >
          <template v-if="lineOf(row)">
            Hiện tại {{ num(lineOf(row)!.quantity) }} → {{ num(row.newQty) }}
            {{ lineOf(row)!.unit }} · chênh lệch
            {{
              money(
                (row.newQty - lineOf(row)!.quantity) * lineOf(row)!.unitPrice,
              )
            }}
          </template>
        </div>
        <div class="col-span-1 flex justify-end">
          <Button
            type="text"
            danger
            size="small"
            :disabled="rows.length === 1"
            @click="rows.splice(index, 1)"
          >
            <template #icon>
<IconifyIcon icon="lucide:trash-2" class="size-3.5" />
</template>
          </Button>
        </div>
      </div>

      <div class="flex justify-end gap-2 border-t border-border pt-3">
        <Button @click="visible = false">Đóng</Button>
        <Button type="primary" @click="submit">Gửi duyệt</Button>
      </div>
    </div>
  </Modal>
</template>

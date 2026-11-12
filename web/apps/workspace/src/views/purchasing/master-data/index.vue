<script setup lang="ts">
import type { ApprovalRole, CatalogItem, Supplier } from '../types';

import { reactive, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Input,
  message,
  Modal,
  Select,
  Table,
  Tabs,
  Tag,
  Tooltip,
} from 'ant-design-vue';

import { ResourceListPage } from '#/shared/resource-table';

import { usePurchasing } from '../store';
import { KIND_LABELS, ROLE_LABELS, ROLE_ORDER } from '../utils';

const {
  approverPools,
  catalog,
  purposes,
  suppliers,
  units,
  upsertCatalogItem,
  upsertSupplier,
} = usePurchasing();

const STAFF = [
  'Trần Minh Đức',
  'Hoàng Thị Mai',
  'Phạm Quốc Huy',
  'Vũ Thanh Tùng',
  'Lê Thu Hà',
  'Nguyễn Thị Bích',
  'Trần Anh Tuấn',
  'Đặng Thu Phương',
  'Bùi Văn Khánh',
];

const activeTab = ref('items');

// ---------- Hàng hóa / dịch vụ ----------
const itemOpen = ref(false);
const itemForm = reactive<CatalogItem>({
  code: '',
  id: '',
  kind: 'goods',
  name: '',
  status: 'active',
  unit: '',
});

function editItem(item?: CatalogItem) {
  Object.assign(
    itemForm,
    item ?? {
      code: `HH-${String(catalog.value.length + 1).padStart(4, '0')}`,
      id: '',
      kind: 'goods',
      name: '',
      status: 'active',
      unit: units.value[0]?.name ?? '',
    },
  );
  itemOpen.value = true;
}

function saveItem() {
  if (!itemForm.name.trim() || !itemForm.unit) {
    message.error('Nhập tên và chọn đơn vị tính.');
    return;
  }
  upsertCatalogItem({ ...itemForm, name: itemForm.name.trim() });
  itemOpen.value = false;
  message.success('Đã lưu hàng hóa/dịch vụ.');
}

// ---------- NCC ----------
const supplierOpen = ref(false);
const supplierForm = reactive<Supplier>({
  code: '',
  contact: '',
  id: '',
  name: '',
  phone: '',
  status: 'active',
  taxCode: '',
});

function editSupplier(supplier?: Supplier) {
  Object.assign(
    supplierForm,
    supplier ?? {
      code: `NCC-${String(suppliers.value.length + 1).padStart(3, '0')}`,
      contact: '',
      id: '',
      name: '',
      phone: '',
      status: 'active',
      taxCode: '',
    },
  );
  supplierOpen.value = true;
}

function saveSupplier() {
  if (!supplierForm.name.trim()) {
    message.error('Nhập tên nhà cung cấp.');
    return;
  }
  upsertSupplier({ ...supplierForm, name: supplierForm.name.trim() });
  supplierOpen.value = false;
  message.success('Đã lưu nhà cung cấp.');
}

// ---------- ĐVT / mục đích ----------
const newUnit = ref('');
const newPurpose = ref('');

function addUnit() {
  const name = newUnit.value.trim();
  if (!name || units.value.some((u) => u.name === name)) return;
  units.value.push({ id: `unit-${Date.now()}`, name });
  newUnit.value = '';
}

function addPurpose() {
  const name = newPurpose.value.trim();
  if (!name || purposes.value.some((p) => p.name === name)) return;
  purposes.value.push({ id: `pur-${Date.now()}`, name });
  newPurpose.value = '';
}

const itemColumns = [
  { dataIndex: 'code', key: 'code', title: 'Mã', width: 110 },
  { dataIndex: 'name', key: 'name', title: 'Tên hàng hóa / dịch vụ' },
  { key: 'kind', title: 'Loại', width: 120 },
  { dataIndex: 'unit', key: 'unit', title: 'ĐVT mặc định', width: 130 },
  { key: 'status', title: 'Trạng thái', width: 130 },
  { align: 'center' as const, key: 'actions', title: 'Thao tác', width: 100 },
];

const supplierColumns = [
  { dataIndex: 'code', key: 'code', title: 'Mã', width: 100 },
  { dataIndex: 'name', key: 'name', title: 'Tên nhà cung cấp' },
  { dataIndex: 'taxCode', key: 'taxCode', title: 'Mã số thuế', width: 140 },
  { dataIndex: 'contact', key: 'contact', title: 'Người liên hệ', width: 160 },
  { dataIndex: 'phone', key: 'phone', title: 'Điện thoại', width: 130 },
  { key: 'status', title: 'Trạng thái', width: 130 },
  { align: 'center' as const, key: 'actions', title: 'Thao tác', width: 100 },
];
</script>

<template>
  <ResourceListPage>
    <div
      class="flex h-full min-h-0 flex-col overflow-hidden rounded border border-border bg-background"
    >
      <div class="shrink-0 border-b border-border px-4 py-3">
        <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
          Danh mục mua hàng
        </h2>
        <p class="m-0 text-xs text-muted-foreground">
          Hàng hóa/dịch vụ, đơn vị tính, mục đích mua, nhà cung cấp và cây phê
          duyệt
        </p>
      </div>
      <div class="min-h-0 flex-1 overflow-auto px-4">
        <Tabs v-model:active-key="activeTab">
          <Tabs.TabPane key="items" tab="Hàng hóa / dịch vụ">
            <div class="mb-3 flex justify-end">
              <Button type="primary" @click="editItem()">
                <template #icon>
<IconifyIcon icon="lucide:plus" class="size-4" />
</template>
                Thêm hàng hóa/dịch vụ
              </Button>
            </div>
            <Table
              :data-source="catalog"
              :columns="itemColumns"
              row-key="id"
              size="small"
              bordered
              :pagination="{ pageSize: 10 }"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'code'">
<span class="font-mono text-xs">{{
                    record.code
                  }}</span>
</template>
                <template v-else-if="column.key === 'kind'">
                  <Tag
                    :color="record.kind === 'service' ? 'cyan' : ''"
                    class="m-0"
                    >
{{ KIND_LABELS[record.kind as 'goods'] }}
</Tag>
                </template>
                <template v-else-if="column.key === 'status'">
                  <Tag
                    :color="record.status === 'active' ? 'success' : 'default'"
                    class="m-0"
                    >
{{
                      record.status === 'active' ? 'Đang dùng' : 'Ngừng dùng'
                    }}
</Tag>
                </template>
                <template v-else-if="column.key === 'actions'">
                  <Tooltip title="Sửa">
                    <Button
                      type="text"
                      size="small"
                      class="text-muted-foreground"
                      @click="editItem(record as CatalogItem)"
                    >
                      <template #icon>
<IconifyIcon icon="lucide:pencil" class="size-4" />
</template>
                    </Button>
                  </Tooltip>
                  <Tooltip
                    :title="
                      record.status === 'active' ? 'Ngừng dùng' : 'Dùng lại'
                    "
                  >
                    <Button
                      type="text"
                      size="small"
                      class="text-muted-foreground"
                      @click="
                        record.status =
                          record.status === 'active' ? 'inactive' : 'active'
                      "
                    >
                      <template #icon>
<IconifyIcon
                          :icon="
                            record.status === 'active'
                              ? 'lucide:circle-pause'
                              : 'lucide:circle-play'
                          "
                          class="size-4"
                      />
</template>
                    </Button>
                  </Tooltip>
                </template>
              </template>
            </Table>
          </Tabs.TabPane>

          <Tabs.TabPane key="units" tab="Đơn vị tính & mục đích">
            <div class="grid grid-cols-1 gap-6 pb-4 md:grid-cols-2">
              <div class="rounded-md border border-border p-4">
                <div class="mb-3 text-sm font-semibold">Đơn vị tính</div>
                <div class="mb-3 flex gap-2">
                  <Input
                    v-model:value="newUnit"
                    placeholder="Tên đơn vị tính"
                    @press-enter="addUnit"
                  />
                  <Button type="primary" @click="addUnit">Thêm</Button>
                </div>
                <div class="flex flex-wrap gap-1.5">
                  <Tag
                    v-for="(unit, i) in units"
                    :key="unit.id"
                    closable
                    class="m-0"
                    @close="units.splice(i, 1)"
                    >
{{ unit.name }}
</Tag>
                </div>
              </div>
              <div class="rounded-md border border-border p-4">
                <div class="mb-3 text-sm font-semibold">Mục đích mua</div>
                <div class="mb-3 flex gap-2">
                  <Input
                    v-model:value="newPurpose"
                    placeholder="Mục đích mua"
                    @press-enter="addPurpose"
                  />
                  <Button type="primary" @click="addPurpose">Thêm</Button>
                </div>
                <div class="flex flex-wrap gap-1.5">
                  <Tag
                    v-for="(purpose, i) in purposes"
                    :key="purpose.id"
                    closable
                    class="m-0"
                    @close="purposes.splice(i, 1)"
                    >
{{ purpose.name }}
</Tag>
                </div>
              </div>
            </div>
          </Tabs.TabPane>

          <Tabs.TabPane key="suppliers" tab="Nhà cung cấp">
            <div class="mb-3 flex items-center justify-between gap-2">
              <span class="text-xs text-muted-foreground">NCC đề xuất mới trên phiếu được thêm tự động khi Purchasing
                duyệt. Đánh giá NCC thuộc phân hệ Quản lý nhà cung cấp.</span>
              <Button type="primary" @click="editSupplier()">
                <template #icon>
<IconifyIcon icon="lucide:plus" class="size-4" />
</template>
                Thêm NCC
              </Button>
            </div>
            <Table
              :data-source="suppliers"
              :columns="supplierColumns"
              row-key="id"
              size="small"
              bordered
              :pagination="{ pageSize: 10 }"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'code'">
<span class="font-mono text-xs">{{
                    record.code
                  }}</span>
</template>
                <template v-else-if="column.key === 'status'">
                  <Tag
                    :color="record.status === 'active' ? 'success' : 'default'"
                    class="m-0"
                    >
{{
                      record.status === 'active' ? 'Đang giao dịch' : 'Ngừng'
                    }}
</Tag>
                </template>
                <template v-else-if="column.key === 'actions'">
                  <Button
                    type="text"
                    size="small"
                    class="text-muted-foreground"
                    @click="editSupplier(record as Supplier)"
                  >
                    <template #icon>
<IconifyIcon icon="lucide:pencil" class="size-4" />
</template>
                  </Button>
                </template>
              </template>
            </Table>
          </Tabs.TabPane>

          <Tabs.TabPane key="approval" tab="Cây phê duyệt">
            <p class="m-0 mb-3 text-xs text-muted-foreground">
              Thứ tự 4 cấp cố định, không phụ thuộc giá trị hay loại chi phí.
              Người tạo đề nghị chọn người duyệt trong danh sách dưới đây ở từng
              vị trí.
            </p>
            <div class="flex flex-col gap-3 pb-4">
              <div
                v-for="(role, index) in ROLE_ORDER"
                :key="role"
                class="grid grid-cols-1 items-center gap-2 rounded-md border border-border p-3 md:grid-cols-[220px_1fr]"
              >
                <div class="flex items-center gap-2">
                  <span
                    class="flex size-6 items-center justify-center rounded-full bg-primary/10 text-xs font-semibold text-primary"
                    >{{ index + 1 }}</span>
                  <span class="font-medium">{{
                    ROLE_LABELS[role as ApprovalRole]
                  }}</span>
                </div>
                <Select
                  v-model:value="approverPools[role as ApprovalRole]"
                  mode="multiple"
                  class="w-full"
                  placeholder="Chọn người được phép duyệt ở vị trí này"
                  :options="STAFF.map((name) => ({ label: name, value: name }))"
                />
              </div>
            </div>
          </Tabs.TabPane>
        </Tabs>
      </div>
    </div>

    <Modal
      v-model:open="itemOpen"
      :title="itemForm.id ? 'Sửa hàng hóa/dịch vụ' : 'Thêm hàng hóa/dịch vụ'"
      ok-text="Lưu"
      cancel-text="Đóng"
      @ok="saveItem"
    >
      <div class="flex flex-col gap-3 py-2">
        <div>
          <label class="mb-1 block text-xs text-muted-foreground">Mã</label><Input v-model:value="itemForm.code" />
        </div>
        <div>
          <label class="mb-1 block text-xs text-muted-foreground">Tên <span class="text-red-500">*</span></label><Input v-model:value="itemForm.name" />
        </div>
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="mb-1 block text-xs text-muted-foreground">Loại</label>
            <Select
              v-model:value="itemForm.kind"
              class="w-full"
              :options="[
                { label: 'Hàng hóa', value: 'goods' },
                { label: 'Dịch vụ', value: 'service' },
              ]"
            />
          </div>
          <div>
            <label class="mb-1 block text-xs text-muted-foreground">ĐVT mặc định <span class="text-red-500">*</span></label>
            <Select
              v-model:value="itemForm.unit"
              class="w-full"
              :options="units.map((u) => ({ label: u.name, value: u.name }))"
            />
          </div>
        </div>
      </div>
    </Modal>

    <Modal
      v-model:open="supplierOpen"
      :title="supplierForm.id ? 'Sửa nhà cung cấp' : 'Thêm nhà cung cấp'"
      ok-text="Lưu"
      cancel-text="Đóng"
      @ok="saveSupplier"
    >
      <div class="grid grid-cols-2 gap-3 py-2">
        <div>
          <label class="mb-1 block text-xs text-muted-foreground">Mã</label><Input v-model:value="supplierForm.code" />
        </div>
        <div>
          <label class="mb-1 block text-xs text-muted-foreground">Mã số thuế</label><Input v-model:value="supplierForm.taxCode" />
        </div>
        <div class="col-span-2">
          <label class="mb-1 block text-xs text-muted-foreground">Tên <span class="text-red-500">*</span></label><Input v-model:value="supplierForm.name" />
        </div>
        <div>
          <label class="mb-1 block text-xs text-muted-foreground">Người liên hệ</label><Input v-model:value="supplierForm.contact" />
        </div>
        <div>
          <label class="mb-1 block text-xs text-muted-foreground">Điện thoại</label><Input v-model:value="supplierForm.phone" />
        </div>
      </div>
    </Modal>
  </ResourceListPage>
</template>

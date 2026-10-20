<script setup lang="ts">
import type { MasterCategory } from '../../types';

import { computed, ref, watch } from 'vue';

import {
  Button,
  Input,
  message,
  Modal,
  Radio,
  Select,
} from 'ant-design-vue';

import { useCashFund } from '../../store';

const props = defineProps<{
  category: MasterCategory | null;
  open: boolean;
}>();

const emit = defineEmits<{
  (e: 'saved'): void;
  (e: 'update:open', val: boolean): void;
}>();

const { addCategory, updateCategory } = useCashFund();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const formCode = ref('');
const formName = ref('');
const formType = ref<'expense' | 'receipt'>('expense');
const formGroup = ref('Chi phí vận hành');
const formDesc = ref('');

const isEdit = computed(() => !!props.category);

watch(
  () => props.category,
  (c) => {
    if (c) {
      formCode.value = c.code;
      formName.value = c.name;
      formType.value = c.type;
      formGroup.value = c.group;
      formDesc.value = c.description;
    } else {
      formCode.value = `KM-${Date.now().toString().slice(-4)}`;
      formName.value = '';
      formType.value = 'expense';
      formGroup.value = 'Chi phí vận hành';
      formDesc.value = '';
    }
  },
  { immediate: true },
);

function handleSave() {
  if (!formName.value.trim()) {
    message.error('Vui lòng nhập tên khoản mục.');
    return;
  }
  if (!formCode.value.trim()) {
    message.error('Vui lòng nhập mã khoản mục.');
    return;
  }

  if (isEdit.value && props.category) {
    updateCategory(props.category.id, {
      code: formCode.value,
      description: formDesc.value,
      group: formGroup.value,
      name: formName.value,
      type: formType.value,
    });
    message.success('Đã cập nhật khoản mục thành công!');
  } else {
    addCategory({
      code: formCode.value,
      description: formDesc.value,
      group: formGroup.value,
      name: formName.value,
      status: 'active',
      type: formType.value,
    });
    message.success('Đã thêm mới khoản mục thành công!');
  }

  visible.value = false;
  emit('saved');
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="isEdit ? 'Chỉnh sửa khoản thu / chi' : 'Thêm mới khoản thu / chi'"
    width="560px"
    destroy-on-close
    :footer="null"
  >
    <div class="flex flex-col gap-4 py-2">
      <div>
        <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
          Loại khoản mục
        </label>
        <Radio.Group v-model:value="formType" button-style="solid" size="small">
          <Radio.Button value="expense">Khoản chi</Radio.Button>
          <Radio.Button value="receipt">Khoản thu</Radio.Button>
        </Radio.Group>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            Mã khoản mục <span class="text-red-500">*</span>
          </label>
          <Input v-model:value="formCode" :disabled="isEdit" class="font-mono" />
        </div>

        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            Nhóm khoản mục <span class="text-red-500">*</span>
          </label>
          <Select v-model:value="formGroup" class="w-full">
            <Select.Option value="Chi phí vận hành">Chi phí vận hành</Select.Option>
            <Select.Option value="Chi phí nhân sự">Chi phí nhân sự</Select.Option>
            <Select.Option value="Mua sắm tài sản">Mua sắm tài sản</Select.Option>
            <Select.Option value="Doanh thu hoạt động">Doanh thu hoạt động</Select.Option>
            <Select.Option value="Thu hồi công nợ">Thu hồi công nợ</Select.Option>
            <Select.Option value="Thu nhập khác">Thu nhập khác</Select.Option>
          </Select>
        </div>
      </div>

      <div>
        <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
          Tên khoản mục <span class="text-red-500">*</span>
        </label>
        <Input v-model:value="formName" placeholder="Ví dụ: Công tác phí, Chi phí tiếp khách..." />
      </div>

      <div>
        <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
          Mô tả / Hướng dẫn áp dụng
        </label>
        <Input.TextArea v-model:value="formDesc" :rows="3" placeholder="Ghi chú quy định, hạn mức hoặc hồ sơ cần thiết..." />
      </div>

      <div class="flex items-center justify-end gap-2 pt-2 border-t border-border">
        <Button @click="visible = false">Hủy</Button>
        <Button type="primary" @click="handleSave">Lưu thông tin</Button>
      </div>
    </div>
  </Modal>
</template>

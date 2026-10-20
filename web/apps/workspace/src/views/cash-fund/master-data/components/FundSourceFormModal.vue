<script setup lang="ts">
import type { FundSource } from '../../types';

import { computed, ref, watch } from 'vue';

import {
  Button,
  Input,
  InputNumber,
  message,
  Modal,
  Select,
} from 'ant-design-vue';

import { useCashFund } from '../../store';

const props = defineProps<{
  fundSource: FundSource | null;
  open: boolean;
}>();

const emit = defineEmits<{
  (e: 'saved'): void;
  (e: 'update:open', val: boolean): void;
}>();

const { addFundSource, currencies, updateFundSource } = useCashFund();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const formCode = ref('');
const formName = ref('');
const formCompany = ref('Công ty Cổ phần Obee Tech');
const formCurrency = ref('VND');
const formInitialBalance = ref(50000000);
const formStatus = ref<'active' | 'inactive' | 'locked'>('active');

const isEdit = computed(() => !!props.fundSource);

watch(
  () => props.fundSource,
  (s) => {
    if (s) {
      formCode.value = s.code;
      formName.value = s.name;
      formCompany.value = s.company;
      formCurrency.value = s.currency;
      formInitialBalance.value = s.initialBalance;
      formStatus.value = s.status;
    } else {
      formCode.value = `QTM-${Date.now().toString().slice(-3)}`;
      formName.value = '';
      formCompany.value = 'Công ty Cổ phần Obee Tech';
      formCurrency.value = 'VND';
      formInitialBalance.value = 50000000;
      formStatus.value = 'active';
    }
  },
  { immediate: true },
);

function handleSave() {
  if (!formName.value.trim()) {
    message.error('Vui lòng nhập tên nguồn tiền.');
    return;
  }
  if (!formCode.value.trim()) {
    message.error('Vui lòng nhập mã nguồn tiền.');
    return;
  }

  if (isEdit.value && props.fundSource) {
    updateFundSource(props.fundSource.id, {
      code: formCode.value,
      company: formCompany.value,
      currency: formCurrency.value,
      initialBalance: formInitialBalance.value,
      name: formName.value,
      status: formStatus.value,
    });
    message.success('Đã cập nhật thông tin nguồn tiền thành công!');
  } else {
    addFundSource({
      code: formCode.value,
      company: formCompany.value,
      currency: formCurrency.value,
      currentBalance: formInitialBalance.value,
      initialBalance: formInitialBalance.value,
      name: formName.value,
      status: formStatus.value,
    });
    message.success('Đã thêm mới nguồn tiền thành công!');
  }

  visible.value = false;
  emit('saved');
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="isEdit ? 'Chỉnh sửa nguồn tiền quỹ' : 'Thêm mới nguồn tiền quỹ'"
    width="580px"
    destroy-on-close
    :footer="null"
  >
    <div class="flex flex-col gap-4 py-2">
      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            Mã nguồn tiền <span class="text-red-500">*</span>
          </label>
          <Input v-model:value="formCode" class="font-mono" />
        </div>

        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            Loại tiền tệ <span class="text-red-500">*</span>
          </label>
          <Select v-model:value="formCurrency" class="w-full">
            <Select.Option v-for="c in currencies" :key="c.code" :value="c.code">
              {{ c.code }} ({{ c.name }})
            </Select.Option>
          </Select>
        </div>
      </div>

      <div>
        <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
          Tên nguồn tiền quỹ <span class="text-red-500">*</span>
        </label>
        <Input v-model:value="formName" placeholder="Ví dụ: Quỹ tiền mặt VP Hà Nội..." />
      </div>

      <div>
        <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
          Đơn vị / Công ty sở hữu <span class="text-red-500">*</span>
        </label>
        <Input v-model:value="formCompany" />
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            Hạn mức / Tồn ban đầu
          </label>
          <InputNumber
            v-model:value="formInitialBalance"
            :min="0"
            :step="1000000"
            :formatter="(val) => `${val}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
            :parser="(val) => val.replace(/\$\s?|(,*)/g, '')"
            class="w-full font-bold"
          />
        </div>

        <div>
          <label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider block mb-1">
            Trạng thái hoạt động
          </label>
          <Select v-model:value="formStatus" class="w-full">
            <Select.Option value="active">Đang hoạt động</Select.Option>
            <Select.Option value="locked">Tạm khóa</Select.Option>
            <Select.Option value="inactive">Ngưng sử dụng</Select.Option>
          </Select>
        </div>
      </div>

      <div class="flex items-center justify-end gap-2 pt-2 border-t border-border">
        <Button @click="visible = false">Hủy</Button>
        <Button type="primary" @click="handleSave">Lưu thông tin</Button>
      </div>
    </div>
  </Modal>
</template>

<script setup lang="ts">
import type { DepartmentWithRelations } from '#/api';

import { computed, nextTick, reactive, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { App, Button } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { departmentsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import DepartmentDetailContent from './department-detail-content.vue';
import {
  buildDepartmentUpdatePayload,
  toDepartmentFormValues,
  useDepartmentFormSchema,
} from './form';

interface ModalData {
  department: DepartmentWithRelations;
  mode: 'edit' | 'view';
  onSaved: () => Promise<void>;
}

const department = ref<DepartmentWithRelations | null>(null);
const mode = ref<'edit' | 'view'>('view');
const { editFormSchema } = useDepartmentFormSchema();
const { notification } = App.useApp();

const [Form, formApi] = useVbenForm(
  reactive({
    commonConfig: {
      componentProps: {
        class: 'w-full',
      },
    },
    layout: 'vertical',
    schema: computed(() => (mode.value === 'edit' ? editFormSchema.value : [])),
    showDefaultActions: false,
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);

const [Modal, modalApi] = useVbenModal({
  class: 'w-[760px]',
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) {
      await loadModal();
    }
  },
});

async function loadModal(): Promise<void> {
  const data = modalApi.getData<ModalData>();
  department.value = data.department;
  mode.value = data.mode;
  modalApi.setState({
    cancelText: $t('page.departments.actions.cancel'),
    confirmText: $t('page.departments.actions.save'),
    showCancelButton: data.mode === 'edit',
    showConfirmButton: data.mode === 'edit',
    title:
      data.mode === 'edit'
        ? $t('page.departments.edit.title')
        : $t('page.departments.detail.title'),
  });

  if (data.mode === 'edit') {
    await nextTick();
    await formApi.setValues(toDepartmentFormValues(data.department));
  }
}

async function resetForm(): Promise<void> {
  if (department.value === null) {
    return;
  }

  await formApi.resetForm();
  await formApi.setValues(toDepartmentFormValues(department.value));
}

async function submit(): Promise<void> {
  if (mode.value !== 'edit' || department.value === null) {
    return;
  }

  const { valid } = await formApi.validate();
  if (!valid) {
    return;
  }

  modalApi.lock();
  try {
    department.value = await departmentsResource.update(
      department.value.id,
      buildDepartmentUpdatePayload(await formApi.getValues()),
    );
    notification.success({
      message: $t('page.departments.messages.updated'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('page.departments.messages.unexpectedError'),
      'Unexpected department update error:',
      notification,
    );
  } finally {
    modalApi.unlock();
  }
}
</script>

<template>
  <Modal :close-on-click-modal="false" :draggable="true">
    <div v-if="department !== null" class="px-6 pb-4 pt-4">
      <Form v-if="mode === 'edit'" />
      <template v-else>
        <h2 class="mb-6 text-xl font-semibold text-foreground">
          {{ $t('page.departments.fields.department') }}:
          {{ department.name }}
        </h2>
        <DepartmentDetailContent :department @failed="modalApi.close" />
      </template>
    </div>
    <template v-if="mode === 'edit'" #prepend-footer>
      <div class="flex-auto">
        <Button danger type="primary" @click="resetForm">
          {{ $t('common.reset') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

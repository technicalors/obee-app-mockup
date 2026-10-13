<script setup lang="ts">
import { computed, reactive } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { App, Button } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { departmentsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import { buildDepartmentCreatePayload, useDepartmentFormSchema } from './form';

interface ModalData {
  companyId?: string;
  onSaved: () => Promise<void>;
  parentId?: string;
}

const { createFormSchema } = useDepartmentFormSchema();
const { notification } = App.useApp();

const [Form, formApi] = useVbenForm(
  reactive({
    commonConfig: {
      componentProps: {
        class: 'w-full',
      },
    },
    layout: 'vertical',
    schema: computed(() => createFormSchema.value),
    showDefaultActions: false,
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);

const [Modal, modalApi] = useVbenModal({
  cancelText: $t('page.departments.actions.cancel'),
  class: 'w-[560px]',
  confirmText: $t('page.departments.actions.create'),
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) {
      await formApi.resetForm();

      const { companyId, parentId } = modalApi.getData<ModalData>();
      if (companyId !== undefined) {
        await formApi.setValues({ company_id: companyId });
      }

      if (parentId !== undefined) {
        await formApi.setValues({ parent_id: parentId });
      }
    }
  },
  title: $t('page.departments.create.title'),
});

async function submit(): Promise<void> {
  const { valid } = await formApi.validate();
  if (!valid) {
    return;
  }

  modalApi.lock();
  try {
    await departmentsResource.create(
      buildDepartmentCreatePayload(await formApi.getValues()),
    );
    notification.success({
      message: $t('page.departments.messages.created'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('page.departments.messages.unexpectedError'),
      'Unexpected department create error:',
      notification,
    );
  } finally {
    modalApi.unlock();
  }
}
</script>

<template>
  <Modal :close-on-click-modal="false" :draggable="true">
    <Form class="px-6 pb-1 pt-2" />
    <template #prepend-footer>
      <div class="flex-auto">
        <Button danger type="primary" @click="formApi.resetForm()">
          {{ $t('common.reset') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

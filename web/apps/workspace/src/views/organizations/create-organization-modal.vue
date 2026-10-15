<script setup lang="ts">
import { computed, reactive } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { App, Button } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { organizationsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import {
  buildOrganizationCreatePayload,
  useOrganizationFormSchema,
} from './form';

interface ModalData {
  onSaved: () => Promise<void>;
  parentId: null | string;
}

const { createFormSchema } = useOrganizationFormSchema();
const { notification } = App.useApp();

const [Form, formApi] = useVbenForm(
  reactive({
    commonConfig: { componentProps: { class: 'w-full' } },
    layout: 'vertical',
    schema: computed(() => createFormSchema.value),
    showDefaultActions: false,
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);

const [Modal, modalApi] = useVbenModal({
  cancelText: $t('organizations.actions.cancel'),
  class: 'w-[640px]',
  confirmText: $t('organizations.actions.create'),
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (!open) return;
    await formApi.resetForm();
    await formApi.setValues({
      parent_id: modalApi.getData<ModalData>().parentId,
      tax_identification_number: null,
    });
  },
  title: $t('organizations.create.title'),
});

async function submit(): Promise<void> {
  const { valid } = await formApi.validate();
  if (!valid) return;

  modalApi.lock();
  try {
    await organizationsResource.create(
      buildOrganizationCreatePayload(await formApi.getValues()),
    );
    notification.success({
      message: $t('organizations.messages.created'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('organizations.messages.unexpectedError'),
      'Unexpected organization create error:',
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
        <Button danger @click="formApi.resetForm()">
          {{ $t('common.reset') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

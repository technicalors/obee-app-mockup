<script setup lang="ts">
import { computed, reactive } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { App, Button } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { equipmentsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import { buildEquipmentCreatePayload, useEquipmentFormSchema } from './form';

interface ModalData {
  onSaved: () => Promise<void>;
}

const { createFormSchema } = useEquipmentFormSchema();
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
  class: 'w-[560px]',
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) {
      modalApi.setState({
        cancelText: $t('page.equipment.actions.cancel'),
        confirmText: $t('page.equipment.actions.create'),
        title: $t('page.equipment.create.title'),
      });
      await formApi.resetForm();
    }
  },
});

async function submit(): Promise<void> {
  const { valid } = await formApi.validate();
  if (!valid) {
    return;
  }

  modalApi.lock();
  try {
    await equipmentsResource.create(
      buildEquipmentCreatePayload(await formApi.getValues()),
    );
    notification.success({
      message: $t('page.equipment.messages.created'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('page.equipment.messages.unexpectedError'),
      'Unexpected equipment create error:',
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

<script setup lang="ts">
import { computed, reactive } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { Button, notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { positionsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import { buildPositionCreatePayload, createPositionFormSchema } from './form';

interface ModalData {
  onSaved: () => Promise<void>;
}

const formSchema = createPositionFormSchema();

const [Form, formApi] = useVbenForm(
  reactive({
    commonConfig: {
      componentProps: {
        class: 'w-full',
      },
    },
    layout: 'vertical',
    schema: computed(() => formSchema),
    showDefaultActions: false,
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);

const [Modal, modalApi] = useVbenModal({
  class: 'w-[640px]',
  confirmText: $t('page.positions.actions.create'),
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) {
      await formApi.resetForm();
    }
  },
  title: $t('page.positions.create.title'),
});

async function submit(): Promise<void> {
  const { valid } = await formApi.validate();
  if (!valid) {
    return;
  }

  modalApi.lock();
  try {
    await positionsResource.create(
      buildPositionCreatePayload(await formApi.getValues()),
    );
    notification.success({
      message: $t('page.positions.messages.created'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('page.positions.messages.unexpectedError'),
      'Unexpected position create error:',
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

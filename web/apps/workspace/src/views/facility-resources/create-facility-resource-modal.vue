<script setup lang="ts">
import { computed, reactive } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { App, Button } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { facilityResourcesResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import {
  buildFacilityResourceCreatePayload,
  useFacilityResourceFormSchema,
} from './form';

interface ModalData {
  onSaved: () => Promise<void>;
}

const { createFormSchema } = useFacilityResourceFormSchema();
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
  class: 'w-[680px]',
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) {
      modalApi.setState({
        cancelText: $t('facilityResource.actions.cancel'),
        confirmText: $t('facilityResource.actions.create'),
        title: $t('facilityResource.create.title'),
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
    await facilityResourcesResource.create(
      buildFacilityResourceCreatePayload(await formApi.getValues()),
    );
    notification.success({
      message: $t('facilityResource.messages.created'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('facilityResource.messages.unexpectedError'),
      'Unexpected facility resource create error:',
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

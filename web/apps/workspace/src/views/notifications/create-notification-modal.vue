<script setup lang="ts">
import { reactive } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { Button, notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import {
  getNotificationRecipientsApi,
  manualNotificationPayloadSchema,
} from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useNotificationStore } from '#/store';

interface ModalData {
  onSaved: () => Promise<void>;
}

const notificationStore = useNotificationStore();

const [Form, formApi] = useVbenForm(
  reactive({
    commonConfig: {
      componentProps: {
        class: 'w-full',
      },
    },
    layout: 'vertical',
    schema: [
      {
        component: 'ApiSelect',
        componentProps: {
          api: getNotificationRecipientsApi,
          labelFn: (recipient) => `${recipient.name} (${recipient.username})`,
          mode: 'multiple',
          optionFilterProp: 'label',
          placeholder: $t('page.notifications.placeholders.recipients'),
          showSearch: true,
          valueField: 'id',
        },
        defaultValue: [],
        fieldName: 'recipient_ids',
        label: $t('page.notifications.fields.recipients'),
        rules: manualNotificationPayloadSchema.shape.recipient_ids,
      },
      {
        component: 'Textarea',
        componentProps: {
          autoSize: { maxRows: 8, minRows: 4 },
          maxlength: 10_000,
          placeholder: $t('page.notifications.placeholders.message'),
        },
        fieldName: 'message',
        label: $t('page.notifications.fields.message'),
        rules: manualNotificationPayloadSchema.shape.message,
      },
    ],
    showDefaultActions: false,
  }),
);

const [Modal, modalApi] = useVbenModal({
  class: 'w-[560px]',
  confirmText: $t('page.notifications.actions.send'),
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) {
      await formApi.resetForm();
    }
  },
  title: $t('page.notifications.create.title'),
});

async function submit(): Promise<void> {
  const { valid } = await formApi.validate();
  if (!valid) {
    return;
  }

  modalApi.lock();
  try {
    await notificationStore.sendManualNotification(
      manualNotificationPayloadSchema.parse(await formApi.getValues()),
    );
    notification.success({
      message: $t('page.notifications.messages.sent'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('page.notifications.messages.unexpectedError'),
      'Unexpected notification create error:',
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

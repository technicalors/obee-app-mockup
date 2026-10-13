<script setup lang="ts">
import type { Position } from '#/api';

import { computed, nextTick, reactive, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import {
  Button,
  Descriptions,
  DescriptionsItem,
  notification,
} from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { positionsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import {
  buildPositionUpdatePayload,
  createPositionFormSchema,
  toPositionFormValues,
} from './form';

interface ModalData {
  mode: 'edit' | 'view';
  onSaved: () => Promise<void>;
  position: Position;
}

const mode = ref<'edit' | 'view'>('view');
const position = ref<null | Position>(null);
const formSchema = createPositionFormSchema();

const [Form, formApi] = useVbenForm(
  reactive({
    commonConfig: {
      componentProps: {
        class: 'w-full',
      },
    },
    layout: 'vertical',
    schema: computed(() => (mode.value === 'edit' ? formSchema : [])),
    showDefaultActions: false,
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);

const [Modal, modalApi] = useVbenModal({
  class: 'w-[640px]',
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) {
      await loadModal();
    }
  },
});

async function loadModal(): Promise<void> {
  const data = modalApi.getData<ModalData>();
  mode.value = data.mode;
  position.value = data.position;
  modalApi.setState({
    confirmText: $t('page.positions.actions.save'),
    showCancelButton: data.mode === 'edit',
    showConfirmButton: data.mode === 'edit',
    title:
      data.mode === 'edit'
        ? $t('page.positions.edit.title')
        : $t('page.positions.detail.title'),
  });

  if (data.mode === 'edit') {
    await nextTick();
    await formApi.setValues(toPositionFormValues(data.position));
  }
}

async function resetForm(): Promise<void> {
  if (position.value === null) {
    return;
  }

  await formApi.resetForm();
  await formApi.setValues(toPositionFormValues(position.value));
}

async function submit(): Promise<void> {
  if (mode.value !== 'edit' || position.value === null) {
    return;
  }

  const { valid } = await formApi.validate();
  if (!valid) {
    return;
  }

  modalApi.lock();
  try {
    position.value = await positionsResource.update(
      position.value.id,
      buildPositionUpdatePayload(await formApi.getValues()),
    );
    notification.success({
      message: $t('page.positions.messages.updated'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('page.positions.messages.unexpectedError'),
      'Unexpected position update error:',
    );
  } finally {
    modalApi.unlock();
  }
}
</script>

<template>
  <Modal :close-on-click-modal="false" :draggable="true">
    <div v-if="position !== null" class="px-6 pb-4 pt-4">
      <Form v-if="mode === 'edit'" />
      <Descriptions v-else :column="1" bordered size="small">
        <DescriptionsItem :label="$t('page.positions.fields.name')">
          {{ position.name }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('page.positions.fields.description')">
          {{ position.description ?? $t('page.positions.values.notProvided') }}
        </DescriptionsItem>
      </Descriptions>
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

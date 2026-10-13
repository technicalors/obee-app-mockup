<script setup lang="ts">
import type { Equipment } from '#/api';

import { computed, nextTick, reactive, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';
import { formatDateTime } from '@vben/utils';

import { App, Button, Divider } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { equipmentsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import {
  buildEquipmentUpdatePayload,
  toEquipmentFormValues,
  useEquipmentFormSchema,
} from './form';

interface ModalData {
  equipment: Equipment;
  mode: 'edit' | 'view';
  onSaved: () => Promise<void>;
}

const equipment = ref<Equipment | null>(null);
const mode = ref<'edit' | 'view'>('view');
const { editFormSchema } = useEquipmentFormSchema();
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
  class: 'w-[560px]',
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) {
      await loadModal();
    }
  },
});

async function loadModal(): Promise<void> {
  const data = modalApi.getData<ModalData>();
  equipment.value = data.equipment;
  mode.value = data.mode;
  modalApi.setState({
    cancelText: $t('page.equipment.actions.cancel'),
    confirmText: $t('page.equipment.actions.save'),
    showCancelButton: data.mode === 'edit',
    showConfirmButton: data.mode === 'edit',
    title:
      data.mode === 'edit'
        ? $t('page.equipment.edit.title')
        : $t('page.equipment.detail.title'),
  });

  if (data.mode === 'edit') {
    await nextTick();
    await formApi.setValues(toEquipmentFormValues(data.equipment));
  }
}

async function resetForm(): Promise<void> {
  if (equipment.value === null) {
    return;
  }

  await formApi.resetForm();
  await formApi.setValues(toEquipmentFormValues(equipment.value));
}

async function submit(): Promise<void> {
  if (mode.value !== 'edit' || equipment.value === null) {
    return;
  }

  const { valid } = await formApi.validate();
  if (!valid) {
    return;
  }

  modalApi.lock();
  try {
    equipment.value = await equipmentsResource.update(
      equipment.value.id,
      buildEquipmentUpdatePayload(await formApi.getValues()),
    );
    notification.success({
      message: $t('page.equipment.messages.updated'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('page.equipment.messages.unexpectedError'),
      'Unexpected equipment update error:',
    );
  } finally {
    modalApi.unlock();
  }
}
</script>

<template>
  <Modal :close-on-click-modal="false" :draggable="true">
    <div v-if="equipment !== null" class="px-6 pb-4 pt-4">
      <Form v-if="mode === 'edit'" />
      <section v-else>
        <Divider
          class="!my-2 [&_.ant-divider-inner-text]:!px-0 [&_.ant-divider-inner-text]:text-sm [&_.ant-divider-inner-text]:font-semibold [&_.ant-divider-inner-text]:text-foreground [&::after]:!border-border [&::before]:!border-border"
          orientation="left"
          plain
        >
          <span class="inline-flex items-center gap-2">
            <IconifyIcon
              class="size-4 text-muted-foreground"
              icon="lucide:package"
            />
            <span>{{ $t('page.equipment.sections.equipment') }}</span>
          </span>
        </Divider>
        <dl class="grid grid-cols-1 gap-x-8 gap-y-4 md:grid-cols-2">
          <div class="min-w-0 space-y-1">
            <dt class="text-xs font-medium text-muted-foreground">
              {{ $t('page.equipment.fields.code') }}
            </dt>
            <dd class="m-0 text-sm text-foreground">
              {{ equipment.code }}
            </dd>
          </div>
          <div class="min-w-0 space-y-1">
            <dt class="text-xs font-medium text-muted-foreground">
              {{ $t('page.equipment.fields.name') }}
            </dt>
            <dd class="m-0 text-sm text-foreground">
              {{ equipment.name }}
            </dd>
          </div>
          <div class="min-w-0 space-y-1">
            <dt class="text-xs font-medium text-muted-foreground">
              {{ $t('page.equipment.fields.createdAt') }}
            </dt>
            <dd class="m-0 text-sm text-foreground">
              {{ formatDateTime(equipment.created_at) }}
            </dd>
          </div>
          <div class="min-w-0 space-y-1">
            <dt class="text-xs font-medium text-muted-foreground">
              {{ $t('page.equipment.fields.updatedAt') }}
            </dt>
            <dd class="m-0 text-sm text-foreground">
              {{ formatDateTime(equipment.updated_at) }}
            </dd>
          </div>
        </dl>
      </section>
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

<script setup lang="ts">
import type { FacilityResource } from '#/api';

import { computed, nextTick, reactive, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { formatDateTime } from '@vben/utils';

import { App, Button, Spin } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { facilityResourcesResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import {
  buildFacilityResourceUpdatePayload,
  toFacilityResourceFormValues,
  useFacilityResourceFormSchema,
} from './form';

interface ModalData {
  facilityResourceId: string;
  mode: 'edit' | 'view';
  onSaved: () => Promise<void>;
}

const facilityResource = ref<FacilityResource | null>(null);
const loading = ref(false);
const mode = ref<'edit' | 'view'>('view');
const { editFormSchema } = useFacilityResourceFormSchema();
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
  class: 'w-[680px]',
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) {
      await loadModal();
    }
  },
});

async function loadModal(): Promise<void> {
  const data = modalApi.getData<ModalData>();
  facilityResource.value = null;
  mode.value = data.mode;
  modalApi.setState({
    cancelText: $t('facilityResource.actions.cancel'),
    confirmText: $t('facilityResource.actions.save'),
    showCancelButton: data.mode === 'edit',
    showConfirmButton: data.mode === 'edit',
    title:
      data.mode === 'edit'
        ? $t('facilityResource.edit.title')
        : $t('facilityResource.detail.title'),
  });

  loading.value = true;
  try {
    const detail = await facilityResourcesResource.getById(
      data.facilityResourceId,
    );
    facilityResource.value = detail;

    if (data.mode === 'edit') {
      await nextTick();
      await formApi.setValues(toFacilityResourceFormValues(detail));
    }
  } catch (error) {
    showRequestError(
      error,
      $t('facilityResource.messages.unexpectedError'),
      'Unexpected facility resource detail load error:',
    );
  } finally {
    loading.value = false;
  }
}

async function resetForm(): Promise<void> {
  if (facilityResource.value === null) {
    return;
  }

  await formApi.resetForm();
  await formApi.setValues(toFacilityResourceFormValues(facilityResource.value));
}

async function submit(): Promise<void> {
  if (mode.value !== 'edit' || facilityResource.value === null) {
    return;
  }

  const { valid } = await formApi.validate();
  if (!valid) {
    return;
  }

  modalApi.lock();
  try {
    facilityResource.value = await facilityResourcesResource.update(
      facilityResource.value.id,
      buildFacilityResourceUpdatePayload(await formApi.getValues()),
    );
    notification.success({
      message: $t('facilityResource.messages.updated'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('facilityResource.messages.unexpectedError'),
      'Unexpected facility resource update error:',
    );
  } finally {
    modalApi.unlock();
  }
}
</script>

<template>
  <Modal :close-on-click-modal="false" :draggable="true">
    <Spin :spinning="loading" class="min-h-24">
      <div v-if="facilityResource !== null" class="px-6 pb-4 pt-4">
        <Form v-if="mode === 'edit'" />
        <section v-else>
          <dl class="grid grid-cols-1 gap-x-7 gap-y-6 md:grid-cols-2">
            <div class="min-w-0 space-y-1">
              <dt class="text-sm font-medium text-foreground">
                {{ $t('facilityResource.fields.code') }}
              </dt>
              <dd
                class="m-0 flex h-10 items-center rounded-md border border-input bg-muted px-3 text-sm text-muted-foreground"
              >
                {{ facilityResource.code }}
              </dd>
            </div>
            <div class="min-w-0 space-y-1">
              <dt class="text-sm font-medium text-foreground">
                {{ $t('facilityResource.fields.name') }}
              </dt>
              <dd
                class="m-0 flex h-10 items-center rounded-md border border-input px-3 text-sm text-foreground"
              >
                {{ facilityResource.name }}
              </dd>
            </div>
            <div class="min-w-0 space-y-1">
              <dt class="text-sm font-medium text-foreground">
                {{ $t('facilityResource.fields.type') }}
              </dt>
              <dd
                class="m-0 flex h-10 items-center rounded-md border border-input px-3 text-sm text-foreground"
              >
                {{ $t(`facilityResource.types.${facilityResource.type}`) }}
              </dd>
            </div>
            <div class="min-w-0 space-y-1">
              <dt class="text-sm font-medium text-foreground">
                {{ $t('facilityResource.fields.quantity') }}
              </dt>
              <dd
                class="m-0 flex h-10 items-center rounded-md border border-input px-3 text-sm text-foreground"
              >
                {{ facilityResource.quantity }}
              </dd>
            </div>
            <div class="min-w-0 space-y-1">
              <dt class="text-sm font-medium text-foreground">
                {{ $t('facilityResource.fields.createdAt') }}
              </dt>
              <dd
                class="m-0 flex h-10 items-center rounded-md border border-input px-3 text-sm text-foreground"
              >
                {{ formatDateTime(facilityResource.created_at) }}
              </dd>
            </div>
            <div class="min-w-0 space-y-1">
              <dt class="text-sm font-medium text-foreground">
                {{ $t('facilityResource.fields.updatedAt') }}
              </dt>
              <dd
                class="m-0 flex h-10 items-center rounded-md border border-input px-3 text-sm text-foreground"
              >
                {{ formatDateTime(facilityResource.updated_at) }}
              </dd>
            </div>
            <div class="min-w-0 space-y-1 md:col-span-2">
              <dt class="text-sm font-medium text-foreground">
                {{ $t('facilityResource.fields.note') }}
              </dt>
              <dd
                class="m-0 h-[94px] overflow-y-auto break-words whitespace-pre-wrap rounded-md border border-input px-3 py-2 text-sm text-foreground"
              >
                {{ facilityResource.note ?? $t('common.notProvided') }}
              </dd>
            </div>
          </dl>
        </section>
      </div>
    </Spin>
    <template v-if="mode === 'edit'" #prepend-footer>
      <div class="flex-auto">
        <Button danger @click="resetForm">
          {{ $t('common.reset') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

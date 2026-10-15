<script setup lang="ts">
import type { Organization } from '#/api';

import { computed, nextTick, reactive, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { App, Button } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { organizationsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useAuthStore } from '#/store';

import {
  buildOrganizationUpdatePayload,
  toOrganizationFormValues,
  useOrganizationFormSchema,
} from './form';
import OrganizationDetailContent from './organization-detail-content.vue';
import { getOrganizationTypeLabel } from './organization-types';

interface ModalData {
  mode: 'edit' | 'view';
  onSaved: () => Promise<void>;
  organization: Organization;
  organizations: Organization[];
}

const mode = ref<'edit' | 'view'>('view');
const organization = ref<null | Organization>(null);
const organizations = ref<Organization[]>([]);
const authStore = useAuthStore();
const { editFormSchema } = useOrganizationFormSchema();
const { notification } = App.useApp();

const [Form, formApi] = useVbenForm(
  reactive({
    commonConfig: { componentProps: { class: 'w-full' } },
    layout: 'vertical',
    schema: computed(() => (mode.value === 'edit' ? editFormSchema.value : [])),
    showDefaultActions: false,
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);

const [Modal, modalApi] = useVbenModal({
  class: 'w-[900px]',
  onConfirm: submit,
  onOpenChange: async (open) => {
    if (open) await loadModal();
  },
});

async function loadModal(): Promise<void> {
  const data = modalApi.getData<ModalData>();
  mode.value = data.mode;
  organization.value = data.organization;
  organizations.value = data.organizations;
  modalApi.setState({
    confirmText: $t('organizations.actions.save'),
    showCancelButton: data.mode === 'edit',
    showConfirmButton: data.mode === 'edit',
    title:
      data.mode === 'edit'
        ? $t('organizations.edit.title')
        : $t('organizations.detail.title'),
  });
  if (data.mode === 'edit') {
    await nextTick();
    await formApi.setValues(toOrganizationFormValues(data.organization));
  }
}

async function resetForm(): Promise<void> {
  if (organization.value === null) return;
  await formApi.resetForm();
  await formApi.setValues(toOrganizationFormValues(organization.value));
}

async function submit(): Promise<void> {
  if (mode.value !== 'edit' || organization.value === null) return;
  const { valid } = await formApi.validate();
  if (!valid) return;

  modalApi.lock();
  try {
    const previousParentId = organization.value.parent_id;
    organization.value = await organizationsResource.update(
      organization.value.id,
      buildOrganizationUpdatePayload(await formApi.getValues()),
    );
    if (previousParentId !== organization.value.parent_id) {
      await authStore.fetchUserInfo();
    }
    notification.success({
      message: $t('organizations.messages.updated'),
    });
    await modalApi.getData<ModalData>().onSaved();
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('organizations.messages.unexpectedError'),
      'Unexpected organization update error:',
      notification,
    );
  } finally {
    modalApi.unlock();
  }
}
</script>

<template>
  <Modal :close-on-click-modal="false" :draggable="true">
    <div v-if="organization !== null" class="px-6 pb-4 pt-4">
      <Form v-if="mode === 'edit'" />
      <template v-else>
        <h2 class="mb-6 text-xl font-semibold text-foreground">
          {{ getOrganizationTypeLabel(organization.type) }}:
          {{ organization.name }}
        </h2>
        <OrganizationDetailContent
          :organization
          :organizations
          @failed="modalApi.close"
        />
      </template>
    </div>
    <template v-if="mode === 'edit'" #prepend-footer>
      <div class="flex-auto">
        <Button danger @click="resetForm">
          {{ $t('common.reset') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

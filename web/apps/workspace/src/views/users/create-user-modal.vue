<script setup lang="ts">
// --- 3. Types & Local Imports ---
import type { UserFormValues } from './form';

// --- 1. Vue & Thư viện ---
import { computed, reactive, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { Button, notification, Tabs } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
// --- 2. API & Utils ---
import { usersResource, ValidationProblemError } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import {
  buildUserCreatePayload,
  mergeUserFormValues,
  useUserFormSchema,
} from './form';

interface ModalData {
  onSaved: () => Promise<void>;
}

// --- 4. State & Composables ---
const activeTab = ref('basic');
let refreshAfterClose: (() => Promise<void>) | null = null;
const {
  canEditRoles,
  createAdditionalFormSchema,
  createBasicFormSchema,
  loadOptions,
} = useUserFormSchema();

const formConfig = {
  commonConfig: {
    componentProps: { class: 'w-full' },
  },
  layout: 'vertical',
  showDefaultActions: false,
} as const;

const [BasicForm, basicFormApi] = useVbenForm(
  reactive({
    ...formConfig,
    schema: computed(() => createBasicFormSchema.value),
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);

const [AdditionalForm, additionalFormApi] = useVbenForm(
  reactive({
    ...formConfig,
    schema: computed(() => createAdditionalFormSchema.value),
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-3',
  }),
);

const [Modal, modalApi] = useVbenModal({
  class: 'w-[1120px] !top-2 !max-h-[calc(100dvh-20px)]',
  title: $t('page.users.create.title'),
  confirmText: $t('page.users.actions.create'),
  onConfirm: submit,
  onClosed: async () => {
    const refresh = refreshAfterClose;
    refreshAfterClose = null;

    if (refresh === null) return;

    try {
      await refresh();
    } catch (error) {
      showRequestError(
        error,
        $t('page.users.messages.unexpectedError'),
        'Unexpected user list refresh error:',
      );
    }
  },
  onOpenChange: async (open) => {
    if (open) {
      refreshAfterClose = null;
      activeTab.value = 'basic';
      await loadOptions();
      await resetForms();
    }
  },
});

async function resetForms(): Promise<void> {
  await Promise.all([basicFormApi.resetForm(), additionalFormApi.resetForm()]);
}

function setRequestValidationErrors(error: unknown): boolean {
  if (!(error instanceof ValidationProblemError)) {
    return false;
  }

  const basicFieldNames = new Set(
    createBasicFormSchema.value.map((field) => field.fieldName),
  );
  const additionalFieldNames = new Set(
    createAdditionalFormSchema.value.map((field) => field.fieldName),
  );
  let hasBasicErrors = false;
  let hasAdditionalErrors = false;

  for (const [field, messages] of Object.entries(error.problem.errors)) {
    const fieldName = field.replace(/\.\d+$/, '');
    const message = messages.join(' ');

    if (basicFieldNames.has(fieldName)) {
      basicFormApi.form.setFieldError(fieldName, message);
      hasBasicErrors = true;
      continue;
    }

    if (additionalFieldNames.has(fieldName)) {
      additionalFormApi.form.setFieldError(fieldName, message);
      hasAdditionalErrors = true;
    }
  }

  if (hasBasicErrors) {
    activeTab.value = 'basic';
  } else if (hasAdditionalErrors) {
    activeTab.value = 'additional';
  }

  return hasBasicErrors || hasAdditionalErrors;
}

async function submit(): Promise<void> {
  const [basicValidation, additionalValidation] = await Promise.all([
    basicFormApi.validate(),
    additionalFormApi.validate(),
  ]);

  if (!basicValidation.valid || !additionalValidation.valid) {
    if (!basicValidation.valid) activeTab.value = 'basic';
    else if (!additionalValidation.valid) activeTab.value = 'additional';
    return;
  }

  modalApi.lock();

  try {
    // Lấy values của 2 form song song để tối ưu tốc độ
    const [basicValues, additionalValues] = await Promise.all([
      basicFormApi.getValues<UserFormValues>(),
      additionalFormApi.getValues<UserFormValues>(),
    ]);

    const values = mergeUserFormValues(basicValues, additionalValues);
    const payload = buildUserCreatePayload(values, canEditRoles.value);

    await usersResource.create(payload);

    notification.success({
      message: $t('page.users.messages.created'),
    });

    refreshAfterClose = modalApi.getData<ModalData>().onSaved;
    modalApi.close();
  } catch (error) {
    if (!setRequestValidationErrors(error)) {
      showRequestError(
        error,
        $t('page.users.messages.unexpectedError'),
        'Unexpected user create error:',
      );
    }
  } finally {
    modalApi.unlock();
  }
}
</script>

<template>
  <Modal :close-on-click-modal="false" draggable>
    <Tabs v-model:active-key="activeTab" class="px-6 pt-3">
      <Tabs.TabPane key="basic" :tab="$t('page.users.tabs.basic')" force-render>
        <BasicForm class="pb-1" />
      </Tabs.TabPane>

      <Tabs.TabPane
        key="additional"
        :tab="$t('page.users.tabs.additional')"
        force-render
      >
        <AdditionalForm class="pb-1" />
      </Tabs.TabPane>
    </Tabs>

    <template #prepend-footer>
      <div class="flex-auto">
        <Button type="primary" danger @click="resetForms">
          {{ $t('common.reset') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

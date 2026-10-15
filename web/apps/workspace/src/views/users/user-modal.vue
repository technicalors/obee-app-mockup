<script setup lang="ts">
import type { UserFormValues } from './form';

import type { User } from '#/api';

import { computed, nextTick, reactive, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { Button, notification, Tabs } from 'ant-design-vue';
import _ from 'lodash';

import { useVbenForm } from '#/adapter/form';
import { usersResource, ValidationProblemError } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useAuthStore } from '#/store';

import {
  buildUserCreatePayload,
  buildUserDetail,
  buildUserPasswordResetPayload,
  buildUserUpdatePayload,
  mergeUserFormValues,
  userEditFormValuesSchema,
  useUserFormSchema,
  waitForMinimumUserModalLoading,
} from './form';

type ModalData =
  | { mode: 'create'; onSaved: () => Promise<void> }
  | {
      mode: 'edit' | 'view';
      onSaved: () => Promise<void>;
      userId: User['id'];
    };

const activeTab = ref('basic');
const mode = ref<ModalData['mode']>('create');
const loading = ref(false);
const loadFailed = ref(false);
const user = ref<null | User>(null);
const ready = computed(() => !loading.value && !loadFailed.value);
const detail = computed(() =>
  user.value === null ? null : buildUserDetail(user.value),
);
let loadVersion = 0;
let refreshAfterClose: (() => Promise<void>) | null = null;
const authStore = useAuthStore();

const {
  canEditRoles,
  createAdditionalFormSchema,
  createBasicFormSchema,
  editAdditionalFormSchema,
  editBasicFormSchema,
  loadOptions,
} = useUserFormSchema();

const basicSchema = computed(() =>
  mode.value === 'edit'
    ? editBasicFormSchema.value
    : createBasicFormSchema.value,
);
const additionalSchema = computed(() =>
  mode.value === 'edit'
    ? editAdditionalFormSchema.value
    : createAdditionalFormSchema.value,
);
const formConfig = {
  commonConfig: { componentProps: { class: 'w-full' } },
  layout: 'vertical',
  showDefaultActions: false,
} as const;

const [BasicForm, basicFormApi] = useVbenForm(
  reactive({
    ...formConfig,
    schema: basicSchema,
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);
const [AdditionalForm, additionalFormApi] = useVbenForm(
  reactive({
    ...formConfig,
    schema: additionalSchema,
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);

const [Modal, modalApi] = useVbenModal({
  cancelText: $t('users.actions.cancel'),
  class: 'w-[880px]',
  closeOnClickModal: false,
  contentClass: 'px-5 pb-4 pt-1',
  draggable: true,
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
        $t('users.messages.unexpectedError'),
        'Unexpected user list refresh error:',
      );
    }
  },
  onOpenChange: (open) => {
    if (open) {
      refreshAfterClose = null;
      void loadModal();
    } else {
      loadVersion += 1;
      user.value = null;
      loadFailed.value = false;
      loading.value = false;
    }
  },
});

async function resetEmptyForms(): Promise<void> {
  await Promise.all([basicFormApi.resetForm(), additionalFormApi.resetForm()]);
}

async function fillEditForms(
  currentUser: User,
  version: number,
): Promise<void> {
  await resetEmptyForms();
  if (version !== loadVersion) return;

  const values = userEditFormValuesSchema.parse(currentUser);
  for (const field of basicSchema.value) {
    const value = _.get(values.basic, field.fieldName);
    if (value !== undefined) {
      await basicFormApi.setFieldValue(field.fieldName, value, false);
      if (version !== loadVersion) return;
    }
  }
  for (const field of additionalSchema.value) {
    const value = _.get(values.additional, field.fieldName);
    if (value !== undefined) {
      await additionalFormApi.setFieldValue(field.fieldName, value, false);
      if (version !== loadVersion) return;
    }
  }
}

async function loadModal(): Promise<void> {
  const data = modalApi.getData<ModalData>();
  const version = ++loadVersion;
  const startedAt = Date.now();

  mode.value = data.mode;
  activeTab.value = 'basic';
  user.value = null;
  loadFailed.value = false;
  loading.value = true;
  modalApi.setState({
    cancelText:
      data.mode === 'view'
        ? $t('users.actions.close')
        : $t('users.actions.cancel'),
    confirmDisabled: true,
    confirmText:
      data.mode === 'create'
        ? $t('users.actions.create')
        : $t('users.actions.save'),
    loading: true,
    showConfirmButton: data.mode !== 'view',
    title: $t(`users.${data.mode === 'view' ? 'detail' : data.mode}.title`),
  });

  try {
    if (data.mode === 'view') {
      const currentUser = await usersResource.getById(data.userId);
      if (version === loadVersion) user.value = currentUser;
    } else {
      await nextTick();
      if (version !== loadVersion) return;

      if (data.mode === 'create') {
        await loadOptions();
        if (version !== loadVersion) return;
        await nextTick();
        await resetEmptyForms();
      } else {
        const [currentUser] = await Promise.all([
          usersResource.getById(data.userId),
          loadOptions(),
        ]);
        if (version !== loadVersion) return;
        await nextTick();
        await fillEditForms(currentUser, version);
        if (version === loadVersion) user.value = currentUser;
      }
    }
  } catch (error) {
    if (version !== loadVersion) return;
    console.error('Unexpected user modal load error:', error);
    user.value = null;
    loadFailed.value = true;
  } finally {
    await waitForMinimumUserModalLoading(startedAt);
    if (version === loadVersion) {
      loading.value = false;
      modalApi.setState({
        confirmDisabled: loadFailed.value,
        loading: false,
      });
    }
  }
}

async function resetForms(): Promise<void> {
  if (!ready.value || mode.value === 'view') return;
  if (mode.value === 'create') {
    await resetEmptyForms();
  } else if (user.value !== null) {
    await fillEditForms(user.value, loadVersion);
  }
  activeTab.value = 'basic';
}

function setRequestValidationErrors(error: unknown): boolean {
  if (!(error instanceof ValidationProblemError)) return false;

  const basicFields = new Set(
    basicSchema.value.map((field) => field.fieldName),
  );
  const additionalFields = new Set(
    additionalSchema.value.map((field) => field.fieldName),
  );
  let basicHasErrors = false;
  let additionalHasErrors = false;

  for (const [field, messages] of Object.entries(error.problem.errors)) {
    const fieldName = field.replace(/\.\d+$/, '');
    const message = messages.join(' ');
    if (basicFields.has(fieldName)) {
      basicFormApi.form.setFieldError(fieldName, message);
      basicHasErrors = true;
    } else if (additionalFields.has(fieldName)) {
      additionalFormApi.form.setFieldError(fieldName, message);
      additionalHasErrors = true;
    }
  }

  if (basicHasErrors) activeTab.value = 'basic';
  else if (additionalHasErrors) activeTab.value = 'additional';
  return basicHasErrors || additionalHasErrors;
}

async function submit(): Promise<void> {
  if (!ready.value || mode.value === 'view') return;
  const [basicValidation, additionalValidation] = await Promise.all([
    basicFormApi.validate(),
    additionalFormApi.validate(),
  ]);
  if (!basicValidation.valid || !additionalValidation.valid) {
    activeTab.value = basicValidation.valid ? 'additional' : 'basic';
    return;
  }

  modalApi.lock();
  try {
    const [basicValues, additionalValues] = await Promise.all([
      basicFormApi.getValues<UserFormValues>(),
      additionalFormApi.getValues<UserFormValues>(),
    ]);
    const values = mergeUserFormValues(basicValues, additionalValues);

    if (mode.value === 'create') {
      await usersResource.create(
        buildUserCreatePayload(values, canEditRoles.value),
      );
      notification.success({ message: $t('users.messages.created') });
    } else {
      if (user.value === null) return;
      const updatedUser = await usersResource.update(
        user.value.id,
        buildUserUpdatePayload(values, canEditRoles.value),
      );
      const passwordPayload = buildUserPasswordResetPayload(values);
      if (passwordPayload !== null) {
        await usersResource.resetPassword(updatedUser.id, passwordPayload);
      }
      if (updatedUser.id === authStore.user?.id) {
        await authStore.fetchUserInfo();
      }
      notification.success({ message: $t('users.messages.updated') });
    }

    refreshAfterClose = modalApi.getData<ModalData>().onSaved;
    modalApi.close();
  } catch (error) {
    if (!setRequestValidationErrors(error)) {
      showRequestError(
        error,
        $t('users.messages.unexpectedError'),
        'Unexpected user save error:',
      );
    }
  } finally {
    modalApi.unlock();
  }
}
</script>

<template>
  <Modal>
    <div
      v-if="loadFailed"
      class="flex min-h-40 flex-col items-center justify-center gap-4 text-center"
      role="alert"
    >
      <p class="m-0 text-sm text-destructive">
        {{ $t('users.messages.loadFailed') }}
      </p>
      <Button @click="loadModal">
        {{ $t('users.actions.retry') }}
      </Button>
    </div>

    <Tabs v-show="!loading && !loadFailed" v-model:active-key="activeTab">
      <Tabs.TabPane key="basic" :tab="$t('users.tabs.basic')" force-render>
        <BasicForm v-if="mode !== 'view'" class="pt-2" />
        <div
          v-else-if="detail !== null"
          class="grid grid-cols-1 gap-x-5 gap-y-4 pt-2 md:grid-cols-2"
        >
          <div
            v-for="row in detail.sections[0]?.rows"
            :key="row.key"
            :class="row.span === 'full' ? 'md:col-span-2' : ''"
            class="min-w-0"
          >
            <div class="mb-1 text-xs text-muted-foreground">
              {{ row.label }}
            </div>
            <div
              class="break-words text-sm"
              :class="
                row.value === null ? 'text-muted-foreground' : 'text-foreground'
              "
            >
              {{ row.value ?? '—' }}
            </div>
          </div>
        </div>
      </Tabs.TabPane>
      <Tabs.TabPane
        key="additional"
        :tab="$t('users.tabs.additional')"
        force-render
      >
        <AdditionalForm v-if="mode !== 'view'" class="pt-2" />
        <div
          v-else-if="detail !== null"
          class="grid grid-cols-1 gap-x-5 gap-y-4 pt-2 md:grid-cols-2"
        >
          <div
            v-for="row in detail.sections[1]?.rows"
            :key="row.key"
            :class="row.span === 'full' ? 'md:col-span-2' : ''"
            class="min-w-0"
          >
            <div class="mb-1 text-xs text-muted-foreground">
              {{ row.label }}
            </div>
            <div
              class="break-words text-sm"
              :class="
                row.value === null ? 'text-muted-foreground' : 'text-foreground'
              "
            >
              {{ row.value ?? '—' }}
            </div>
          </div>
        </div>
      </Tabs.TabPane>
    </Tabs>

    <template v-if="mode !== 'view'" #prepend-footer>
      <div class="flex-auto">
        <Button :disabled="!ready" @click="resetForms">
          {{ $t('common.reset') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

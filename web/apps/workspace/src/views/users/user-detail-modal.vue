<script setup lang="ts">
import type { UserFormValues } from './form';

import type { User } from '#/api';

import { computed, nextTick, reactive, ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { Button, notification, Spin, Tabs } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { getUserInfoApi, usersResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useAuthStore } from '#/store';

import {
  buildUserDetail,
  buildUserPasswordResetPayload,
  buildUserUpdatePayload,
  mergeUserFormValues,
  toUserFormValues,
  useUserFormSchema,
} from './form';

interface ModalData {
  mode: 'edit' | 'view';
  onSaved: () => Promise<void>;
  user: User;
}

const activeTab = ref('basic');
const loading = ref(false);
const mode = ref<'edit' | 'view'>('view');
const user = ref<null | User>(null);
let refreshAfterClose: (() => Promise<void>) | null = null;
const authStore = useAuthStore();

const {
  canEditRoles,
  editAdditionalFormSchema,
  editBasicFormSchema,
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
    schema: computed(() =>
      mode.value === 'edit' ? editBasicFormSchema.value : [],
    ),
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2',
  }),
);

const [AdditionalForm, additionalFormApi] = useVbenForm(
  reactive({
    ...formConfig,
    schema: computed(() =>
      mode.value === 'edit' ? editAdditionalFormSchema.value : [],
    ),
    wrapperClass: 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-3',
  }),
);

const detail = computed(() =>
  user.value === null ? null : buildUserDetail(user.value),
);

const [Modal, modalApi] = useVbenModal({
  class: 'w-[1120px] !top-2 !max-h-[calc(100dvh-20px)]',
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
      await loadModal();
    }
  },
});

async function setFormValues(currentUser: User): Promise<void> {
  const values = toUserFormValues(currentUser);
  await Promise.all([
    basicFormApi.setValues(values),
    additionalFormApi.setValues(values),
  ]);
}

async function loadModal(): Promise<void> {
  const data = modalApi.getData<ModalData>();

  activeTab.value = 'basic';
  mode.value = data.mode;
  user.value = data.user;
  loading.value = data.mode === 'edit';

  modalApi.setState({
    confirmText: $t('page.users.actions.save'),
    showCancelButton: data.mode === 'edit',
    showConfirmButton: data.mode === 'edit',
    title:
      data.mode === 'edit'
        ? $t('page.users.edit.title')
        : $t('page.users.detail.title'),
  });

  try {
    if (data.mode === 'edit') {
      await loadOptions();
      await nextTick();
      await setFormValues(data.user);
    }
  } catch (error) {
    showRequestError(
      error,
      $t('page.users.messages.unexpectedError'),
      'Unexpected user detail load error:',
    );
    modalApi.close();
  } finally {
    loading.value = false;
  }
}

async function resetForms(): Promise<void> {
  if (user.value === null) return;
  await Promise.all([basicFormApi.resetForm(), additionalFormApi.resetForm()]);
  await setFormValues(user.value);
}

async function submit(): Promise<void> {
  if (mode.value !== 'edit' || user.value === null) return;

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
    const [basicValues, additionalValues] = await Promise.all([
      basicFormApi.getValues<UserFormValues>(),
      additionalFormApi.getValues<UserFormValues>(),
    ]);

    const values = mergeUserFormValues(basicValues, additionalValues);

    const updatedUser = await usersResource.update(
      user.value.id,
      buildUserUpdatePayload(values, canEditRoles.value),
    );

    const passwordPayload = buildUserPasswordResetPayload(values);
    if (passwordPayload !== null) {
      await usersResource.resetPassword(updatedUser.id, passwordPayload);
    }

    user.value = updatedUser;

    if (updatedUser.id === authStore.user?.id) {
      authStore.setAuthenticatedUser(await getUserInfoApi());
    }

    notification.success({
      message: $t('page.users.messages.updated'),
    });

    refreshAfterClose = modalApi.getData<ModalData>().onSaved;
    modalApi.close();
  } catch (error) {
    showRequestError(
      error,
      $t('page.users.messages.unexpectedError'),
      'Unexpected user update error:',
    );
  } finally {
    modalApi.unlock();
  }
}
</script>

<template>
  <Modal :close-on-click-modal="false" draggable>
    <div class="relative min-h-48">
      <div v-if="detail !== null" class="px-6 pb-1 pt-3">
        <template v-if="mode === 'edit'">
          <Tabs v-model:active-key="activeTab">
            <Tabs.TabPane
              key="basic"
              :tab="$t('page.users.tabs.basic')"
              force-render
            >
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
        </template>

        <template v-else>
          <Tabs v-model:active-key="activeTab">
            <Tabs.TabPane
              v-for="section in detail.sections"
              :key="section.key"
              :tab="section.title"
              force-render
            >
              <div
                :class="
                  section.key === 'additional'
                    ? 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-3'
                    : 'grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2'
                "
              >
                <div
                  v-for="row in section.rows"
                  :key="row.key"
                  class="mb-4 min-w-0"
                  :class="row.span === 'full' ? 'col-span-full' : ''"
                >
                  <span class="mb-1 block text-sm font-medium text-foreground">
                    {{ row.label }}
                  </span>
                  <div
                    class="min-h-9 rounded-md border border-input bg-muted/40 px-3 py-1.5 text-sm text-foreground break-words whitespace-pre-wrap"
                  >
                    {{ row.value }}
                  </div>
                </div>
              </div>
            </Tabs.TabPane>
          </Tabs>
        </template>
      </div>

      <div
        v-if="loading"
        class="absolute inset-0 flex items-center justify-center bg-background/80"
      >
        <Spin />
      </div>
    </div>

    <template v-if="mode === 'edit'" #prepend-footer>
      <div class="flex-auto">
        <Button danger type="primary" @click="resetForms">
          {{ $t('common.reset') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>

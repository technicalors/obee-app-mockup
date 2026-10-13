<script lang="ts" setup>
import type { VbenFormSchema } from '@vben/common-ui';

import type { LoginPayload } from '#/api';

import { computed } from 'vue';

import { AuthenticationLogin, z } from '@vben/common-ui';

import { loginPayloadSchema } from '#/api';
import { $t } from '#/locales';
import { useAuthStore } from '#/store';

defineOptions({ name: 'Login' });

const authStore = useAuthStore();

function localizedRule<TSchema extends z.ZodTypeAny>(
  schema: TSchema,
  message: string,
) {
  return z.custom<z.input<TSchema>>(
    (value) => schema.safeParse(value).success,
    {
      message,
    },
  );
}

function handleSubmit(values: Record<string, unknown>) {
  return authStore.authLogin(loginPayloadSchema.parse(values) as LoginPayload);
}

const formSchema = computed((): VbenFormSchema[] => {
  return [
    {
      component: 'VbenInput',
      componentProps: {
        autocomplete: 'username',
        placeholder: $t('page.auth.emailOrUsernamePlaceholder'),
      },
      fieldName: 'email',
      label: $t('page.auth.emailOrUsername'),
      rules: localizedRule(
        loginPayloadSchema.shape.email,
        $t('page.auth.emailOrUsernameRequired'),
      ),
    },
    {
      component: 'VbenInputPassword',
      componentProps: {
        autocomplete: 'current-password',
        placeholder: $t('authentication.password'),
      },
      fieldName: 'password',
      label: $t('authentication.password'),
      rules: localizedRule(
        loginPayloadSchema.shape.password,
        $t('authentication.passwordTip'),
      ),
    },
  ];
});
</script>

<template>
  <AuthenticationLogin
    :form-schema="formSchema"
    :loading="authStore.loginLoading"
    :show-code-login="false"
    :show-forget-password="true"
    :show-qrcode-login="false"
    :show-register="false"
    :show-remember-me="true"
    :show-third-party-login="false"
    :submit-button-text="$t('common.login')"
    :sub-title="$t('page.auth.loginSubtitle')"
    :title="$t('page.auth.welcomeBack')"
    @submit="handleSubmit"
  />
</template>

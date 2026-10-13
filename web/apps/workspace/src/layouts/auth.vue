<script lang="ts" setup>
import { computed } from 'vue';

import { AuthPageLayout } from '@vben/layouts';
import { preferences } from '@vben/preferences';

import { $t } from '#/locales';

const appName = computed(() => preferences.app.name);
const logo = computed(() => preferences.logo.source);
const logoDark = computed(() => preferences.logo.sourceDark);
</script>

<template>
  <AuthPageLayout
    :app-name="appName"
    :logo="logo"
    :logo-dark="logoDark"
    :page-description="$t('page.auth.loginPageDescription')"
    :page-title="$t('page.auth.loginPageTitle')"
  >
    <template #copyright>
      <div class="text-md flex-center">
        {{ $t('page.auth.copyright') }}
        <a
          href="https://ouransoft.vn"
          class="mx-1 hover:text-primary-hover"
          rel="noopener noreferrer"
          target="_blank"
        >
          {{ $t('page.auth.companyName') }}
        </a>
      </div>
    </template>
    <!-- 自定义工具栏 -->
    <!-- <template #toolbar></template> -->
  </AuthPageLayout>
</template>

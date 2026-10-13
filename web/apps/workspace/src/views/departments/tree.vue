<script setup lang="ts">
import { useRouter } from 'vue-router';

import { Page, VbenButton } from '@vben/common-ui';

import { $t } from '#/locales';

import DepartmentTree from './department-tree.vue';

const router = useRouter();

function openList(): void {
  void router.push({ name: 'MasterDataDepartments' });
}
</script>

<template>
  <Page :title="$t('page.departments.tree.title')" auto-content-height>
    <template #extra>
      <VbenButton variant="outline" @click="openList">
        {{ $t('page.departments.actions.viewList') }}
      </VbenButton>
    </template>

    <DepartmentTree />
  </Page>
</template>

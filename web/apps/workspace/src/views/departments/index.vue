<script setup lang="ts">
import { VbenButton } from '@vben/common-ui';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useDepartmentsPage } from './use-departments-page';

const {
  canCreateDepartments,
  CreateDepartmentModal,
  DepartmentDetailModal,
  Grid,
  openCreate,
  openTree,
} = useDepartmentsPage();
</script>

<template>
  <ResourceListPage>
    <Grid>
      <template #table-title>
        <div class="flex min-w-0 flex-col gap-1">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('page.departments.listTitle') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('page.departments.listDescription') }}
          </p>
        </div>
      </template>

      <template #toolbar-tools>
        <VbenButton class="mr-2" variant="outline" @click="openTree">
          {{ $t('page.departments.actions.viewTree') }}
        </VbenButton>
        <VbenButton
          v-if="canCreateDepartments"
          class="mr-2"
          @click="openCreate"
        >
          <span class="flex items-center gap-1.5">
            <span aria-hidden="true" class="text-lg leading-none">+</span>
            {{ $t('page.departments.actions.create') }}
          </span>
        </VbenButton>
      </template>
    </Grid>

    <CreateDepartmentModal />
    <DepartmentDetailModal />
  </ResourceListPage>
</template>

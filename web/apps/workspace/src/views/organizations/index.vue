<script setup lang="ts">
import { IconifyIcon } from '@vben/icons';

import { Button } from 'ant-design-vue';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useOrganizationsPage } from './use-organizations-page';

const {
  canCreateOrganizations,
  CreateOrganizationModal,
  Grid,
  openCreate,
  openTree,
  OrganizationDetailModal,
} = useOrganizationsPage();
</script>

<template>
  <ResourceListPage>
    <Grid>
      <template #table-title>
        <div class="flex min-w-0 flex-col gap-1">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('organizations.listTitle') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('organizations.listDescription') }}
          </p>
        </div>
      </template>

      <template #toolbar-tools>
        <Button class="mr-2" @click="openTree">
          {{ $t('organizations.actions.viewTree') }}
        </Button>
        <Button
          v-if="canCreateOrganizations"
          class="mr-2"
          type="primary"
          @click="openCreate()"
        >
          <IconifyIcon aria-hidden="true" icon="lucide:plus" />
          {{ $t('organizations.actions.createRoot') }}
        </Button>
      </template>
    </Grid>

    <CreateOrganizationModal />
    <OrganizationDetailModal />
  </ResourceListPage>
</template>

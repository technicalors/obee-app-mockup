<script setup lang="ts">
import { IconifyIcon } from '@vben/icons';

import { Button } from 'ant-design-vue';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useFacilityResourcesPage } from './use-facility-resources-page';

const {
  canCreateFacilityResources,
  CreateFacilityResourceModal,
  FacilityResourceDetailModal,
  Grid,
  openCreate,
} = useFacilityResourcesPage();
</script>

<template>
  <ResourceListPage>
    <Grid>
      <template #table-title>
        <div class="flex min-w-0 flex-col gap-1">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('facilityResource.listTitle') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('facilityResource.listDescription') }}
          </p>
        </div>
      </template>

      <template #toolbar-tools>
        <Button
          v-if="canCreateFacilityResources"
          class="mr-2"
          type="primary"
          @click="openCreate"
        >
          <IconifyIcon aria-hidden="true" icon="lucide:plus" />
          {{ $t('facilityResource.actions.create') }}
        </Button>
      </template>
    </Grid>

    <CreateFacilityResourceModal />
    <FacilityResourceDetailModal />
  </ResourceListPage>
</template>

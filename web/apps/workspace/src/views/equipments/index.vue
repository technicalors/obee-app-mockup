<script setup lang="ts">
import { VbenButton } from '@vben/common-ui';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useEquipmentsPage } from './use-equipments-page';

const {
  canCreateEquipments,
  CreateEquipmentModal,
  EquipmentDetailModal,
  Grid,
  openCreate,
} = useEquipmentsPage();
</script>

<template>
  <ResourceListPage>
    <Grid>
      <template #table-title>
        <div class="flex min-w-0 flex-col gap-1">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('page.equipment.listTitle') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('page.equipment.listDescription') }}
          </p>
        </div>
      </template>

      <template #toolbar-tools>
        <VbenButton v-if="canCreateEquipments" class="mr-2" @click="openCreate">
          <span class="flex items-center gap-1.5">
            <span aria-hidden="true" class="text-lg leading-none">+</span>
            {{ $t('page.equipment.actions.create') }}
          </span>
        </VbenButton>
      </template>
    </Grid>

    <CreateEquipmentModal />
    <EquipmentDetailModal />
  </ResourceListPage>
</template>

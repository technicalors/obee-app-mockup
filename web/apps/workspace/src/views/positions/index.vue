<script setup lang="ts">
import { VbenButton } from '@vben/common-ui';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { usePositionsPage } from './use-positions-page';

const {
  canCreatePositions,
  CreatePositionModal,
  Grid,
  openCreate,
  PositionDetailModal,
} = usePositionsPage();
</script>

<template>
  <ResourceListPage>
    <Grid>
      <template #table-title>
        <div class="flex min-w-0 flex-col gap-1">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('page.positions.listTitle') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('page.positions.listDescription') }}
          </p>
        </div>
      </template>

      <template #toolbar-tools>
        <VbenButton v-if="canCreatePositions" class="mr-2" @click="openCreate">
          <span class="flex items-center gap-1.5">
            <span aria-hidden="true" class="text-lg leading-none">+</span>
            {{ $t('page.positions.actions.create') }}
          </span>
        </VbenButton>
      </template>
    </Grid>

    <CreatePositionModal />
    <PositionDetailModal />
  </ResourceListPage>
</template>

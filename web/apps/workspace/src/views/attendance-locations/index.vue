<script setup lang="ts">
import { VbenButton } from '@vben/common-ui';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useAttendanceLocationsPage } from './use-attendance-locations-page';

const { canCreateAttendanceLocations, Grid, openCreate } =
  useAttendanceLocationsPage();
</script>

<template>
  <ResourceListPage>
    <Grid>
      <template #table-title>
        <div class="flex min-w-0 flex-col gap-1">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('page.attendanceLocations.listTitle') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('page.attendanceLocations.listDescription') }}
          </p>
        </div>
      </template>

      <template #toolbar-tools>
        <VbenButton
          v-if="canCreateAttendanceLocations"
          @click="openCreate"
          class="mr-2"
        >
          <span class="flex items-center gap-1.5">
            <span aria-hidden="true" class="text-lg leading-none">+</span>
            {{ $t('page.attendanceLocations.actions.create') }}
          </span>
        </VbenButton>
      </template>
    </Grid>
  </ResourceListPage>
</template>

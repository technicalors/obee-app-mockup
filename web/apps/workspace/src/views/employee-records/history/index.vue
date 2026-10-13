<script setup lang="ts">
import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useEmployeeHistoryList } from './use-employee-history-list';

const { Grid, UserDetailModal } = useEmployeeHistoryList();
</script>

<template>
  <ResourceListPage>
    <Grid>
      <template #table-title>
        <div class="flex min-w-0 flex-col gap-1">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('page.employeeHistory.listTitle') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('page.employeeHistory.listDescription') }}
          </p>
        </div>
      </template>
    </Grid>

    <UserDetailModal />
  </ResourceListPage>
</template>

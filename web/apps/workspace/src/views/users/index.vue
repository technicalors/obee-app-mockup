<script setup lang="ts">
import { IconifyIcon } from '@vben/icons';

import { Button } from 'ant-design-vue';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useUsersPage } from './use-users-page';

const { canCreateUsers, Grid, openCreate, UserModal } = useUsersPage();
</script>

<template>
  <ResourceListPage>
    <Grid>
      <template #table-title>
        <div class="flex min-w-0 flex-col gap-1">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('users.listTitle') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('users.listDescription') }}
          </p>
        </div>
      </template>

      <template #toolbar-tools>
        <Button
          v-if="canCreateUsers"
          class="mr-2"
          type="primary"
          @click="openCreate"
        >
          <IconifyIcon aria-hidden="true" icon="lucide:plus" />
          {{ $t('users.actions.create') }}
        </Button>
      </template>
    </Grid>

    <UserModal />
  </ResourceListPage>
</template>

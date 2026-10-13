<script setup lang="ts">
import { VbenButton } from '@vben/common-ui';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useUsersPage } from './use-users-page';

const { canCreateUsers, CreateUserModal, Grid, openCreate, UserDetailModal } =
  useUsersPage();
</script>

<template>
  <ResourceListPage>
    <Grid>
      <template #table-title>
        <div class="flex min-w-0 flex-col gap-1">
          <h2 class="m-0 text-base font-semibold leading-6 text-foreground">
            {{ $t('page.users.listTitle') }}
          </h2>
          <p class="m-0 text-xs text-muted-foreground">
            {{ $t('page.users.listDescription') }}
          </p>
        </div>
      </template>

      <template #toolbar-tools>
        <VbenButton v-if="canCreateUsers" @click="openCreate" class="mr-2">
          <span class="flex items-center gap-1.5">
            <span aria-hidden="true" class="text-lg leading-none">+</span>
            {{ $t('page.users.actions.create') }}
          </span>
        </VbenButton>
      </template>
    </Grid>

    <CreateUserModal />
    <UserDetailModal />
  </ResourceListPage>
</template>

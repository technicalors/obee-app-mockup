<script setup lang="ts">
import type { Organization } from '#/api';

import { IconifyIcon } from '@vben/icons';

import { Button, Drawer } from 'ant-design-vue';

import { $t } from '#/locales';

import OrganizationDetailContent from './organization-detail-content.vue';
import { getOrganizationTypeLabel } from './organization-types';

interface Props {
  canCreate: boolean;
  canDelete: boolean;
  canEdit: boolean;
  canView: boolean;
  open: boolean;
  organization: null | Organization;
  organizations: Organization[];
}

defineProps<Props>();
const emit = defineEmits<{
  close: [];
  createChild: [organization: Organization];
  delete: [organization: Organization];
  edit: [organization: Organization];
  failed: [];
  view: [organization: Organization];
}>();
</script>

<template>
  <Drawer :open="open" placement="right" width="720" @close="emit('close')">
    <template #title>
      <span class="block max-w-72 truncate">
        {{
          organization === null
            ? $t('organizations.tree.title')
            : `${getOrganizationTypeLabel(organization.type)}: ${organization.name}`
        }}
      </span>
    </template>

    <template #extra>
      <div
        v-if="organization !== null"
        class="flex flex-wrap items-center justify-end gap-2"
      >
        <Button v-if="canView" size="small" @click="emit('view', organization)">
          <IconifyIcon icon="lucide:eye" />
          {{ $t('organizations.actions.view') }}
        </Button>
        <Button v-if="canEdit" size="small" @click="emit('edit', organization)">
          <IconifyIcon icon="lucide:pencil" />
          {{ $t('organizations.actions.edit') }}
        </Button>
        <Button
          v-if="canCreate"
          size="small"
          type="primary"
          @click="emit('createChild', organization)"
        >
          <IconifyIcon icon="lucide:plus" />
          {{ $t('organizations.actions.createChild') }}
        </Button>
        <Button
          v-if="canDelete"
          danger
          size="small"
          type="primary"
          @click="emit('delete', organization)"
        >
          <IconifyIcon icon="lucide:trash-2" />
          {{ $t('organizations.actions.delete') }}
        </Button>
      </div>
    </template>

    <OrganizationDetailContent
      v-if="canView && organization !== null"
      :key="organization.id"
      :organization="organization"
      :organizations
      @failed="emit('failed')"
    />
  </Drawer>
</template>

<script setup lang="ts">
import type { Department, DepartmentWithRelations } from '#/api';

import { ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Button, Drawer } from 'ant-design-vue';

import { $t } from '#/locales';

import DepartmentDetailContent from './department-detail-content.vue';

interface Props {
  canCreate: boolean;
  canDelete: boolean;
  canEdit: boolean;
  department: Department | null;
  open: boolean;
}

const props = defineProps<Props>();
const emit = defineEmits<{
  close: [];
  createChild: [department: DepartmentWithRelations];
  delete: [department: DepartmentWithRelations];
  edit: [department: DepartmentWithRelations];
}>();

const departmentDetails = ref<DepartmentWithRelations | null>(null);

watch(
  () => props.department,
  () => {
    departmentDetails.value = null;
  },
);
</script>

<template>
  <Drawer :open="open" placement="right" width="720" @close="emit('close')">
    <template #title>
      <span class="block max-w-72 truncate">
        {{
          department === null
            ? $t('page.departments.tree.detailTitle')
            : `${$t('page.departments.routeTitle')}: ${department.name}`
        }}
      </span>
    </template>

    <template #extra>
      <div
        v-if="departmentDetails !== null"
        class="flex flex-wrap items-center justify-end gap-2"
      >
        <Button
          v-if="canEdit"
          size="small"
          @click="emit('edit', departmentDetails)"
        >
          <IconifyIcon icon="lucide:pencil" />
          {{ $t('page.departments.actions.edit') }}
        </Button>
        <Button
          v-if="canCreate"
          size="small"
          type="primary"
          @click="emit('createChild', departmentDetails)"
        >
          <IconifyIcon icon="lucide:plus" />
          {{ $t('page.departments.tree.createChild') }}
        </Button>
        <Button
          v-if="canDelete"
          danger
          size="small"
          type="primary"
          @click="emit('delete', departmentDetails)"
        >
          {{ $t('page.departments.actions.delete') }}
        </Button>
      </div>
    </template>

    <DepartmentDetailContent
      v-if="department !== null"
      :department="department"
      @failed="emit('close')"
      @loaded="departmentDetails = $event"
    />
  </Drawer>
</template>

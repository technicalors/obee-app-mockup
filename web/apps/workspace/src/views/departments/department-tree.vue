<script setup lang="ts">
import type { Company, Department, DepartmentWithRelations } from '#/api';

import { computed, defineAsyncComponent, onMounted, ref } from 'vue';

import { useAccess } from '@vben/access';
import { useVbenModal, VbenButton } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import { Empty, Modal, notification, Select, Spin } from 'ant-design-vue';

import {
  companiesResource,
  departmentOptionsResource,
  departmentsResource,
} from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import DepartmentOrganizationGraph from './department-organization-graph.vue';
import { buildDepartmentTree } from './department-tree';
import DepartmentTreeDrawer from './department-tree-drawer.vue';

const CreateDepartmentModalComponent = defineAsyncComponent(
  () => import('./create-department-modal.vue'),
);
const DepartmentDetailModalComponent = defineAsyncComponent(
  () => import('./department-detail-modal.vue'),
);
const DRAWER_FORM_MODAL_Z_INDEX = 2100;

const companies = ref<Company[]>([]);
const departments = ref<Department[]>([]);
const loading = ref(false);
const selectedDepartment = ref<Department | null>(null);
const selectedCompanyId = ref<string>();
const treeDrawerOpen = ref(false);
const { hasAccessByCodes } = useAccess();
const canCreateDepartments = computed(() =>
  hasAccessByCodes(['departments.create']),
);
const canDeleteDepartments = computed(() =>
  hasAccessByCodes(['departments.delete']),
);
const canEditDepartments = computed(() =>
  hasAccessByCodes(['departments.view', 'departments.update']),
);
const [CreateDepartmentModal, createDepartmentModalApi] = useVbenModal({
  connectedComponent: CreateDepartmentModalComponent,
  zIndex: DRAWER_FORM_MODAL_Z_INDEX,
});
const [DepartmentDetailModal, departmentDetailModalApi] = useVbenModal({
  connectedComponent: DepartmentDetailModalComponent,
  zIndex: DRAWER_FORM_MODAL_Z_INDEX,
});

const selectedCompany = computed(() =>
  companies.value.find((company) => company.id === selectedCompanyId.value),
);
const tree = computed(() => {
  const company = selectedCompany.value;

  if (company === undefined) {
    return [];
  }

  return buildDepartmentTree(
    departments.value.filter(
      (department) => department.company_id === company.id,
    ),
  );
});

async function load(): Promise<void> {
  loading.value = true;

  try {
    [companies.value, departments.value] = await Promise.all([
      companiesResource.getAll(),
      departmentOptionsResource.getAll(),
    ]);

    const [firstCompany] = companies.value;

    if (selectedCompanyId.value === undefined && firstCompany !== undefined) {
      selectedCompanyId.value = firstCompany.id;
    }
  } catch (error) {
    showRequestError(
      error,
      $t('page.departments.messages.unexpectedError'),
      'Unexpected department tree load error:',
    );
  } finally {
    loading.value = false;
  }
}

onMounted(load);

function openCreate(parentDepartment?: DepartmentWithRelations): void {
  const companyId =
    parentDepartment === undefined
      ? selectedCompanyId.value
      : parentDepartment.company_id;

  if (companyId === undefined || companyId === null) {
    return;
  }

  createDepartmentModalApi.setData({
    companyId,
    onSaved: reloadTree,
    parentId: parentDepartment === undefined ? undefined : parentDepartment.id,
  });
  createDepartmentModalApi.open();
}

async function reloadTree(): Promise<void> {
  closeDepartmentDrawer();
  await load();
}

function openEdit(department: DepartmentWithRelations): void {
  departmentDetailModalApi.setData({
    department,
    mode: 'edit',
    onSaved: reloadTree,
  });
  departmentDetailModalApi.open();
}

function confirmDelete(department: DepartmentWithRelations): void {
  const childCount =
    department.children?.length ??
    departments.value.filter((d) => d.parent_id === department.id).length;
  const isParent = childCount > 0;

  Modal.confirm({
    cancelText: $t('page.departments.actions.cancel'),
    content: isParent
      ? $t('page.departments.delete.parentDescription', {
          name: department.name,
        })
      : $t('page.departments.delete.description', {
          name: department.name,
        }),
    okButtonProps: { danger: true },
    okText: isParent
      ? $t('page.departments.delete.confirmCascade')
      : $t('page.departments.actions.delete'),
    onOk: async () => {
      try {
        await departmentsResource.delete(department.id);
        notification.success({
          message: $t('page.departments.messages.deleted'),
        });
        await reloadTree();
      } catch (error) {
        showRequestError(
          error,
          $t('page.departments.messages.unexpectedError'),
          'Unexpected department tree delete error:',
        );
        throw error;
      }
    },
    title: isParent
      ? $t('page.departments.delete.parentTitle')
      : $t('page.departments.delete.title'),
  });
}

function openDepartment(department: Department): void {
  selectedDepartment.value = department;
  treeDrawerOpen.value = true;
}

function closeDepartmentDrawer(): void {
  selectedDepartment.value = null;
  treeDrawerOpen.value = false;
}
</script>

<template>
  <section class="rounded-lg border border-border bg-card p-4 shadow-sm">
    <div
      class="-mx-4 -mt-4 mb-4 flex flex-wrap items-center justify-between gap-4 border-b border-border px-8 py-4"
    >
      <label class="flex items-center gap-3 text-sm font-semibold">
        <span>{{ $t('page.departments.tree.company') }}:</span>
        <Select
          v-model:value="selectedCompanyId"
          class="w-96 max-w-full"
          :loading="loading"
        >
          <Select.Option
            v-for="company in companies"
            :key="company.id"
            :value="company.id"
          >
            {{ company.name }}
          </Select.Option>
        </Select>
      </label>
      <VbenButton
        v-if="canCreateDepartments"
        :disabled="selectedCompanyId === undefined"
        size="sm"
        @click="openCreate()"
      >
        <IconifyIcon icon="lucide:plus" />
        {{ $t('page.departments.tree.create') }}
      </VbenButton>
    </div>

    <Spin :spinning="loading">
      <DepartmentOrganizationGraph
        v-if="selectedCompany !== undefined && tree.length > 0"
        :company="selectedCompany"
        :tree="tree"
        @select="openDepartment"
      />
      <Empty v-else :description="$t('page.departments.tree.empty')" />
    </Spin>

    <CreateDepartmentModal />
    <DepartmentTreeDrawer
      :can-create="canCreateDepartments"
      :can-delete="canDeleteDepartments"
      :can-edit="canEditDepartments"
      :department="selectedDepartment"
      :open="treeDrawerOpen"
      @create-child="openCreate"
      @delete="confirmDelete"
      @edit="openEdit"
      @close="closeDepartmentDrawer"
    />
    <DepartmentDetailModal />
  </section>
</template>

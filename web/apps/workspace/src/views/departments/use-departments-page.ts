import type { DepartmentTableFilters } from './query';
import type { DepartmentTableAction } from './schema';

import type { DepartmentIndexQuery, DepartmentWithRelations } from '#/api';

import { computed, defineAsyncComponent } from 'vue';
import { useRouter } from 'vue-router';

import { useAccess } from '@vben/access';
import { useVbenModal } from '@vben/common-ui';

import { Modal, notification } from 'ant-design-vue';

import { departmentsResource } from '#/api';
import { $t } from '#/locales';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import { createDepartmentIndexQuery } from './query';
import {
  createDepartmentTableColumns,
  createDepartmentTableFilterSchema,
} from './schema';

const CreateDepartmentModalComponent = defineAsyncComponent(
  () => import('./create-department-modal.vue'),
);
const DepartmentDetailModalComponent = defineAsyncComponent(
  () => import('./department-detail-modal.vue'),
);

export function useDepartmentsPage() {
  const authStore = useAuthStore();
  const router = useRouter();
  const { hasAccessByCodes } = useAccess();
  const [CreateDepartmentModal, createDepartmentModalApi] = useVbenModal({
    connectedComponent: CreateDepartmentModalComponent,
  });
  const [DepartmentDetailModal, departmentDetailModalApi] = useVbenModal({
    connectedComponent: DepartmentDetailModalComponent,
  });
  const [Grid, table] = useResourceTable<
    DepartmentWithRelations,
    DepartmentIndexQuery,
    DepartmentTableFilters
  >({
    buildQuery: createDepartmentIndexQuery,
    enabled: () => authStore.hasSession,
    errorMessage: $t('page.departments.messages.unexpectedError'),
    formOptions: {
      schema: createDepartmentTableFilterSchema(),
      showCollapseButton: false,
      submitOnChange: true,
    },
    gridOptions: {
      border: true,
      columns: createDepartmentTableColumns({
        hasAccessByCodes,
        onAction: handleTableAction,
      }),
      rowConfig: {
        keyField: 'id',
      },
    },
    resource: departmentsResource,
    tableTitle: $t('page.departments.listTitle'),
  });

  const canCreateDepartments = computed(() =>
    hasAccessByCodes(['departments.create']),
  );

  function openCreate(): void {
    createDepartmentModalApi.setData({
      onSaved: table.reload,
    });
    createDepartmentModalApi.open();
  }

  function openTree(): void {
    void router.push({ name: 'MasterDataDepartmentTree' });
  }

  function openDetail(
    department: DepartmentWithRelations,
    mode: 'edit' | 'view',
  ): void {
    departmentDetailModalApi.setData({
      department,
      mode,
      onSaved: table.reload,
    });
    departmentDetailModalApi.open();
  }

  function handleTableAction(
    action: DepartmentTableAction,
    department: DepartmentWithRelations,
  ): void {
    if (action === 'view') {
      openDetail(department, 'view');
      return;
    }

    if (action === 'edit') {
      openDetail(department, 'edit');
      return;
    }

    if (action === 'delete') {
      void confirmDelete(department);
    }
  }

  async function confirmDelete(
    department: DepartmentWithRelations,
  ): Promise<void> {
    let target = department;
    if (target.children === undefined) {
      try {
        target = await departmentsResource.getById(department.id);
      } catch {
        target = department;
      }
    }

    const childCount = target.children?.length ?? 0;
    const isParent = childCount > 0;

    Modal.confirm({
      cancelText: $t('page.departments.actions.cancel'),
      content: isParent
        ? $t('page.departments.delete.parentDescription', {
            name: target.name,
          })
        : $t('page.departments.delete.description', {
            name: target.name,
          }),
      okButtonProps: { danger: true },
      okText: isParent
        ? $t('page.departments.delete.confirmCascade')
        : $t('page.departments.actions.delete'),
      onOk: async () => {
        if (await table.remove(target.id)) {
          notification.success({
            message: $t('page.departments.messages.deleted'),
          });
        }
      },
      title: isParent
        ? $t('page.departments.delete.parentTitle')
        : $t('page.departments.delete.title'),
    });
  }

  return {
    canCreateDepartments,
    CreateDepartmentModal,
    DepartmentDetailModal,
    Grid,
    openCreate,
    openTree,
  };
}

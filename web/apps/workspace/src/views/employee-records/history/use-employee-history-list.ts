import type { EmployeeHistoryTableFilters } from './query';
import type { EmployeeHistoryTableAction } from './schema';

import type { User, UserIndexQuery } from '#/api';

import { defineAsyncComponent } from 'vue';
import { useRouter } from 'vue-router';

import { useAccess } from '@vben/access';
import { useVbenModal } from '@vben/common-ui';

import { Modal, notification } from 'ant-design-vue';

import { usersResource } from '#/api';
import { $t } from '#/locales';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import { createEmployeeHistoryIndexQuery } from './query';
import {
  createEmployeeHistoryTableColumns,
  createEmployeeHistoryTableFilterSchema,
} from './schema';

const UserModalComponent = defineAsyncComponent(
  () => import('#/views/users/user-modal.vue'),
);

export function useEmployeeHistoryList() {
  const authStore = useAuthStore();
  const { hasAccessByCodes } = useAccess();
  const router = useRouter();

  const [UserDetailModal, userDetailModalApi] = useVbenModal({
    connectedComponent: UserModalComponent,
  });

  const [Grid, table] = useResourceTable<
    User,
    UserIndexQuery,
    EmployeeHistoryTableFilters
  >({
    buildQuery: createEmployeeHistoryIndexQuery,
    enabled: () => authStore.hasSession,
    errorMessage: $t('users.messages.unexpectedError'),
    formOptions: {
      schema: createEmployeeHistoryTableFilterSchema(),
      showCollapseButton: false,
      submitOnChange: true,
    },
    gridOptions: {
      border: true,
      columns: createEmployeeHistoryTableColumns({
        hasAccessByCodes,
        onAction: handleTableAction,
      }),
      rowConfig: {
        keyField: 'id',
      },
    },
    resource: usersResource,
    tableTitle: $t('employeeHistory.listTitle'),
  });

  function openEdit(user: User): void {
    userDetailModalApi.setData({
      mode: 'edit',
      onSaved: table.reload,
      userId: user.id,
    });
    userDetailModalApi.open();
  }

  function confirmDelete(user: User): void {
    Modal.confirm({
      cancelText: $t('users.actions.cancel'),
      content: $t('users.delete.description', { name: user.name }),
      okButtonProps: { danger: true },
      okText: $t('users.actions.delete'),
      onOk: async () => {
        if (await table.remove(user.id)) {
          notification.success({
            message: $t('users.messages.deleted'),
          });
        }
      },
      title: $t('users.delete.title'),
    });
  }

  function handleTableAction(
    action: EmployeeHistoryTableAction,
    user: User,
  ): void {
    if (action === 'detail') {
      router.push(`/employee-records/history/${user.id}`);
      return;
    }

    if (action === 'edit') {
      openEdit(user);
      return;
    }

    if (action === 'delete') {
      confirmDelete(user);
    }
  }

  return {
    Grid,
    table,
    UserDetailModal,
  };
}

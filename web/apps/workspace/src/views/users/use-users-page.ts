import type { UserTableFilters } from './query';
import type { UserTableAction } from './schema';

import type { User, UserIndexQuery } from '#/api';

import { computed, defineAsyncComponent } from 'vue';

import { useAccess } from '@vben/access';
import { useVbenModal } from '@vben/common-ui';

import { Modal, notification } from 'ant-design-vue';

import { usersResource } from '#/api';
import { $t } from '#/locales';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import { createUserIndexQuery } from './query';
import { createUserTableColumns, createUserTableFilterSchema } from './schema';

const CreateUserModalComponent = defineAsyncComponent(
  () => import('./create-user-modal.vue'),
);
const UserDetailModalComponent = defineAsyncComponent(
  () => import('./user-detail-modal.vue'),
);

export function useUsersPage() {
  const authStore = useAuthStore();
  const { hasAccessByCodes } = useAccess();

  const [CreateUserModal, createUserModalApi] = useVbenModal({
    connectedComponent: CreateUserModalComponent,
  });
  const [UserDetailModal, userDetailModalApi] = useVbenModal({
    connectedComponent: UserDetailModalComponent,
  });

  const [Grid, table] = useResourceTable<
    User,
    UserIndexQuery,
    UserTableFilters
  >({
    buildQuery: createUserIndexQuery,
    enabled: () => authStore.hasSession,
    errorMessage: $t('page.users.messages.unexpectedError'),
    formOptions: {
      schema: createUserTableFilterSchema(),
      showCollapseButton: false,
      submitOnChange: true,
    },
    gridOptions: {
      border: true,
      columns: createUserTableColumns({
        hasAccessByCodes,
        onAction: handleTableAction,
      }),
      rowConfig: {
        keyField: 'id',
      },
    },
    resource: usersResource,
    tableTitle: $t('page.users.listTitle'),
  });

  const canCreateUsers = computed(() => hasAccessByCodes(['users.create']));

  function openCreate(): void {
    createUserModalApi.setData({
      onSaved: table.reload,
    });
    createUserModalApi.open();
  }

  function openDetail(user: User, mode: 'edit' | 'view'): void {
    userDetailModalApi.setData({
      mode,
      onSaved: table.reload,
      user,
    });
    userDetailModalApi.open();
  }

  function handleTableAction(action: UserTableAction, user: User): void {
    if (action === 'view') {
      openDetail(user, 'view');
      return;
    }

    if (action === 'edit') {
      openDetail(user, 'edit');
      return;
    }

    confirmDelete(user);
  }

  function confirmDelete(user: User): void {
    Modal.confirm({
      cancelText: $t('page.users.actions.cancel'),
      content: $t('page.users.delete.description', { name: user.name }),
      okButtonProps: { danger: true },
      okText: $t('page.users.actions.delete'),
      onOk: async () => {
        if (await table.remove(user.id)) {
          notification.success({
            message: $t('page.users.messages.deleted'),
          });
        }
      },
      title: $t('page.users.delete.title'),
    });
  }

  return {
    canCreateUsers,
    CreateUserModal,
    Grid,
    openCreate,
    UserDetailModal,
  };
}

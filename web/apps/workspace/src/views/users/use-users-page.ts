import type { UserTableFilters } from './query';
import type { UserTableAction } from './schema';

import type { User, UserIndexQuery } from '#/api';

import { computed, defineAsyncComponent } from 'vue';

import { useAccess } from '@vben/access';
import { useVbenModal } from '@vben/common-ui';

import { Modal, notification } from 'ant-design-vue';

import { usersResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import { createUserIndexQuery } from './query';
import { createUserTableColumns, createUserTableFilterSchema } from './schema';

const UserModalComponent = defineAsyncComponent(
  () => import('./user-modal.vue'),
);

export function useUsersPage() {
  const authStore = useAuthStore();
  const { hasAccessByCodes } = useAccess();

  const [UserModal, userModalApi] = useVbenModal({
    connectedComponent: UserModalComponent,
  });

  const [Grid, table] = useResourceTable<
    User,
    UserIndexQuery,
    UserTableFilters
  >({
    buildQuery: createUserIndexQuery,
    enabled: () => authStore.hasSession,
    errorMessage: $t('users.messages.unexpectedError'),
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
    tableTitle: $t('users.listTitle'),
  });

  const canCreateUsers = computed(() => hasAccessByCodes(['users.create']));

  function openCreate(): void {
    userModalApi.setData({
      mode: 'create',
      onSaved: table.reload,
    });
    userModalApi.open();
  }

  function openDetail(user: User, mode: 'edit' | 'view'): void {
    userModalApi.setData({
      mode,
      onSaved: table.reload,
      userId: user.id,
    });
    userModalApi.open();
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

    if (action === 'restore') {
      void restore(user);
      return;
    }

    confirmDelete(user);
  }

  async function restore(user: User): Promise<void> {
    try {
      await usersResource.restore(user.id);
      notification.success({ message: $t('users.messages.restored') });
      await table.reload();
    } catch (error) {
      showRequestError(
        error,
        $t('users.messages.unexpectedError'),
        'Failed to restore user:',
      );
    }
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

  return {
    canCreateUsers,
    Grid,
    openCreate,
    UserModal,
  };
}

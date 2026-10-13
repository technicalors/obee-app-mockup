import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { User } from '#/api';

import { $t } from '#/locales';
import { useRoleOptionsStore } from '#/store/role-options';

interface UserTableActions {
  hasAccessByCodes: (codes: string[]) => boolean;
  onAction: (action: UserTableAction, user: User) => void;
}

export type UserTableAction = 'delete' | 'edit' | 'view';

export function createUserTableFilterSchema(): VbenFormSchema[] {
  const roleOptionsStore = useRoleOptionsStore();

  return [
    {
      component: 'Input',
      componentProps: {
        allowClear: true,
        placeholder: $t('page.users.filters.searchPlaceholder'),
      },
      fieldName: 'search',
      label: $t('page.users.filters.search'),
    },
    {
      component: 'Select',
      componentProps: {
        allowClear: true,
        options: [
          { label: $t('page.users.status.active'), value: false },
          { label: $t('page.users.status.all'), value: true },
        ],
      },
      defaultValue: false,
      fieldName: 'with_inactive',
      label: $t('page.users.filters.status'),
    },
    {
      component: 'ApiSelect',
      componentProps: {
        allowClear: true,
        api: roleOptionsStore.loadOnce,
        labelField: 'name',
        mode: 'multiple',
        valueField: 'name',
      },
      fieldName: 'role_names',
      label: $t('page.users.filters.roleGroup'),
    },
  ];
}

export function createUserTableColumns(
  actions: UserTableActions,
): VxeTableGridOptions<User>['columns'] {
  const notProvided = $t('common.notProvided');

  return [
    {
      title: $t('page.users.columns.sequence'),
      type: 'seq',
      width: 60,
    },
    {
      field: 'username',
      minWidth: 160,
      title: $t('page.users.columns.username'),
    },
    {
      formatter: ({ row }) =>
        row.profile === null ? notProvided : row.profile.code,
      minWidth: 160,
      title: $t('page.users.columns.employeeId'),
    },
    {
      cellRender: {
        name: 'CellTag',
        options: [
          {
            color: 'green',
            label: $t('page.users.status.active'),
            value: true,
          },
          {
            color: 'red',
            label: $t('page.users.status.locked'),
            value: false,
          },
        ],
      },
      field: 'is_active',
      minWidth: 120,
      title: $t('page.users.columns.status'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: User) => {
            if (code === 'view' || code === 'edit' || code === 'delete') {
              actions.onAction(code, row);
              return;
            }

            throw new Error(`Unsupported user table action: ${code}`);
          },
        },
        name: 'CellOperation',
        options: [
          {
            code: 'view',
            icon: 'lucide:eye',
            label: $t('page.users.actions.view'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['users.view']),
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('page.users.actions.edit'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['users.view']) &&
              actions.hasAccessByCodes(['users.update']),
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('page.users.actions.delete'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['users.delete']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('page.users.columns.actions'),
      width: 132,
    },
  ];
}

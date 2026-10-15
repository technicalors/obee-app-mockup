import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { User } from '#/api';

import { $t } from '#/locales';
import { useRoleOptionsStore } from '#/store/role-options';

interface UserTableActions {
  hasAccessByCodes: (codes: string[]) => boolean;
  onAction: (action: UserTableAction, user: User) => void;
}

export type UserTableAction = 'delete' | 'edit' | 'restore' | 'view';

export function createUserTableFilterSchema(): VbenFormSchema[] {
  const roleOptionsStore = useRoleOptionsStore();

  return [
    {
      component: 'Input',
      componentProps: {
        allowClear: true,
        placeholder: $t('users.filters.searchPlaceholder'),
      },
      fieldName: 'search',
      label: $t('users.filters.search'),
    },
    {
      component: 'Select',
      componentProps: {
        allowClear: true,
        options: [
          { label: $t('users.status.active'), value: 'active' },
          { label: $t('users.status.all'), value: 'all' },
          { label: $t('users.status.deleted'), value: 'deleted' },
        ],
      },
      defaultValue: 'active',
      fieldName: 'status',
      label: $t('users.filters.status'),
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
      label: $t('users.filters.roleGroup'),
    },
  ];
}

export function createUserTableColumns(
  actions: UserTableActions,
): VxeTableGridOptions<User>['columns'] {
  const notProvided = $t('common.notProvided');

  return [
    {
      title: $t('users.columns.sequence'),
      type: 'seq',
      width: 60,
    },
    {
      field: 'name',
      minWidth: 170,
      title: $t('users.columns.name'),
    },
    {
      field: 'username',
      minWidth: 140,
      title: $t('users.columns.username'),
    },
    {
      formatter: ({ row }) =>
        row.profile === null ? notProvided : row.profile.code,
      minWidth: 120,
      title: $t('users.columns.employeeId'),
    },
    {
      field: 'email',
      formatter: ({ row }) => row.email ?? notProvided,
      minWidth: 190,
      title: $t('users.columns.email'),
    },
    {
      field: 'organization',
      formatter: ({ row }) => row.organization?.name ?? notProvided,
      minWidth: 160,
      title: $t('users.columns.organization'),
    },
    {
      field: 'roles',
      formatter: ({ row }) =>
        row.roles.length === 0
          ? notProvided
          : row.roles.map((role) => role.name).join(', '),
      minWidth: 145,
      title: $t('users.columns.roles'),
    },
    {
      cellRender: {
        attrs: {
          getColor: (deleted: unknown) => (deleted === true ? 'red' : 'green'),
          getItems: (row: User) => [row.deleted_at !== null],
          getKey: (_deleted: unknown, index: number) => index,
          getLabel: (deleted: unknown) =>
            deleted === true
              ? $t('users.status.deleted')
              : $t('users.status.active'),
        },
        name: 'CellTags',
      },
      field: 'deleted_at',
      minWidth: 110,
      title: $t('users.columns.status'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: User) => {
            if (
              code === 'view' ||
              code === 'edit' ||
              code === 'delete' ||
              code === 'restore'
            ) {
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
            label: $t('users.actions.view'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['users.view']),
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('users.actions.edit'),
            type: 'text',
            visible: (row: User) =>
              row.deleted_at === null &&
              actions.hasAccessByCodes(['users.view']) &&
              actions.hasAccessByCodes(['users.update']),
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('users.actions.delete'),
            type: 'text',
            visible: (row: User) =>
              row.deleted_at === null &&
              actions.hasAccessByCodes(['users.delete']),
          },
          {
            code: 'restore',
            icon: 'lucide:archive-restore',
            label: $t('users.actions.restore'),
            type: 'text',
            visible: (row: User) =>
              row.deleted_at !== null &&
              actions.hasAccessByCodes(['users.delete']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('users.columns.actions'),
      width: 132,
    },
  ];
}

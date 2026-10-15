import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { User } from '#/api';

import { $t } from '#/locales';

export type EmployeeHistoryTableAction = 'delete' | 'detail' | 'edit';

export interface EmployeeHistoryTableActions {
  hasAccessByCodes?: (codes: string[]) => boolean;
  onAction: (action: EmployeeHistoryTableAction, user: User) => void;
}

export function createEmployeeHistoryTableFilterSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      componentProps: {
        allowClear: true,
        placeholder: $t('employeeHistory.filters.searchPlaceholder'),
      },
      fieldName: 'search',
      label: $t('employeeHistory.filters.search'),
    },
  ];
}

export function createEmployeeHistoryTableColumns(
  actions: EmployeeHistoryTableActions,
): VxeTableGridOptions<User>['columns'] {
  const notProvided = $t('common.notProvided');

  return [
    {
      title: $t('employeeHistory.columns.sequence'),
      type: 'seq',
      width: 60,
    },
    {
      formatter: ({ row }) =>
        row.profile === null ? notProvided : row.profile.code,
      minWidth: 140,
      title: $t('employeeHistory.columns.employeeCode'),
    },
    {
      field: 'name',
      minWidth: 160,
      title: $t('employeeHistory.columns.fullName'),
    },
    {
      formatter: ({ row }) => {
        const sex = row.profile?.sex;
        if (sex === 'male') {
          return $t('users.gender.male');
        }
        if (sex === 'female') {
          return $t('users.gender.female');
        }
        return notProvided;
      },
      minWidth: 100,
      title: $t('employeeHistory.columns.gender'),
    },
    {
      formatter: ({ row }) => row.organization?.name ?? notProvided,
      minWidth: 180,
      title: $t('employeeHistory.columns.organization'),
    },
    {
      formatter: ({ row }) =>
        row.profile?.position === null || row.profile?.position === undefined
          ? notProvided
          : row.profile.position.name,
      minWidth: 140,
      title: $t('employeeHistory.columns.position'),
    },
    {
      formatter: ({ row }) => row.profile?.joined_at ?? notProvided,
      minWidth: 140,
      title: $t('employeeHistory.columns.joinedAt'),
    },
    {
      formatter: ({ row }) => row.profile?.starting_date ?? notProvided,
      minWidth: 140,
      title: $t('employeeHistory.columns.startingDate'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: User) => {
            if (code === 'detail' || code === 'edit' || code === 'delete') {
              actions.onAction(code, row);
              return;
            }

            throw new Error(
              `Unsupported employee history table action: ${code}`,
            );
          },
        },
        name: 'CellOperation',
        options: [
          {
            code: 'detail',
            icon: 'lucide:eye',
            label: $t('employeeHistory.actions.detail'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes
                ? actions.hasAccessByCodes(['users.view'])
                : true,
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('users.actions.edit'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes
                ? actions.hasAccessByCodes(['users.view']) &&
                  actions.hasAccessByCodes(['users.update'])
                : true,
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('users.actions.delete'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes
                ? actions.hasAccessByCodes(['users.delete'])
                : true,
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('employeeHistory.columns.actions'),
      width: 140,
    },
  ];
}

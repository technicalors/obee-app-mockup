import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { DepartmentWithRelations } from '#/api';

import { companiesResource, departmentOptionsResource } from '#/api';
import { $t } from '#/locales';

interface DepartmentTableActions {
  hasAccessByCodes: (codes: string[]) => boolean;
  onAction: (
    action: DepartmentTableAction,
    row: DepartmentWithRelations,
  ) => void;
}

export type DepartmentTableAction = 'delete' | 'edit' | 'view';

export function createDepartmentTableFilterSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      componentProps: {
        allowClear: true,
        placeholder: $t('page.departments.filters.searchPlaceholder'),
      },
      fieldName: 'search',
      label: $t('page.departments.filters.search'),
    },
    {
      component: 'ApiSelect',
      componentProps: {
        allowClear: true,
        api: companiesResource.getAll,
        labelField: 'name',
        valueField: 'id',
      },
      fieldName: 'company_id',
      label: $t('page.departments.filters.company'),
    },
    {
      component: 'ApiSelect',
      componentProps: {
        allowClear: true,
        api: departmentOptionsResource.getAll,
        labelField: 'name',
        valueField: 'id',
      },
      fieldName: 'parent_id',
      label: $t('page.departments.filters.parent'),
    },
  ];
}

export function createDepartmentTableColumns(
  actions: DepartmentTableActions,
): VxeTableGridOptions<DepartmentWithRelations>['columns'] {
  return [
    {
      title: 'STT',
      type: 'seq',
      width: 60,
    },
    {
      field: 'name',
      minWidth: 180,
      title: $t('page.departments.columns.name'),
    },
    {
      className: ({ row }) =>
        row.parent === null ? 'text-muted-foreground' : '',
      field: 'parent_id',
      formatter: ({ row }) =>
        row.parent === null
          ? $t('page.departments.values.noParent')
          : row.parent.name,
      minWidth: 180,
      title: $t('page.departments.columns.parent'),
    },
    {
      field: 'company_id',
      formatter: ({ row }) =>
        row.company === null
          ? $t('page.departments.values.notProvided')
          : row.company.name,
      minWidth: 180,
      title: $t('page.departments.columns.company'),
    },
    {
      field: 'created_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: $t('page.departments.columns.createdAt'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: DepartmentWithRelations) => {
            if (code === 'view' || code === 'edit' || code === 'delete') {
              actions.onAction(code, row);
              return;
            }

            throw new Error(`Unsupported department table action: ${code}`);
          },
        },
        name: 'CellOperation',
        options: [
          {
            code: 'view',
            icon: 'lucide:eye',
            label: $t('page.departments.actions.view'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['departments.view']),
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('page.departments.actions.edit'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['departments.view']) &&
              actions.hasAccessByCodes(['departments.update']),
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('page.departments.actions.delete'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['departments.delete']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('page.departments.columns.actions'),
      width: 132,
    },
  ];
}

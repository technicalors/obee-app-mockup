import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { Organization } from '#/api';

import { $t } from '#/locales';

import {
  createOrganizationTypeOptions,
  getOrganizationTypeLabel,
} from './organization-types';

interface OrganizationTableActions {
  hasAccessByCodes: (codes: string[]) => boolean;
  parentOrganizationName: (parentId: null | string) => string;
  onAction: (action: OrganizationTableAction, row: Organization) => void;
}

export type OrganizationTableAction =
  | 'create-child'
  | 'delete'
  | 'edit'
  | 'view';

export function createOrganizationTableFilterSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      componentProps: () => ({
        allowClear: true,
        placeholder: $t('organizations.filters.searchPlaceholder'),
      }),
      fieldName: 'search',
      label: () => $t('organizations.filters.search'),
    },
    {
      component: 'Select',
      componentProps: () => ({
        allowClear: true,
        options: createOrganizationTypeOptions(),
      }),
      fieldName: 'type',
      label: () => $t('organizations.filters.type'),
    },
  ];
}

export function createOrganizationTableColumns(
  actions: OrganizationTableActions,
): VxeTableGridOptions<Organization>['columns'] {
  return [
    { title: 'STT', type: 'seq', width: 60 },
    {
      field: 'name',
      minWidth: 180,
      title: $t('organizations.columns.name'),
    },
    {
      field: 'type',
      minWidth: 140,
      slots: {
        default: ({ row }) => [
          <span>{getOrganizationTypeLabel(row.type)}</span>,
        ],
      },
      title: $t('organizations.columns.type'),
    },
    {
      field: 'parent_id',
      minWidth: 180,
      slots: {
        default: ({ row }) => [
          <span>{actions.parentOrganizationName(row.parent_id)}</span>,
        ],
      },
      title: $t('organizations.columns.parent'),
    },
    {
      field: 'created_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: $t('organizations.columns.createdAt'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: Organization) => {
            if (
              code === 'view' ||
              code === 'edit' ||
              code === 'delete' ||
              code === 'create-child'
            ) {
              actions.onAction(code, row);
              return;
            }
            throw new Error(`Unsupported organization table action: ${code}`);
          },
        },
        name: 'CellOperation',
        options: [
          {
            code: 'view',
            icon: 'lucide:eye',
            label: $t('organizations.actions.view'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['organizations.view']),
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('organizations.actions.edit'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['organizations.view']) &&
              actions.hasAccessByCodes(['organizations.update']),
          },
          {
            code: 'create-child',
            icon: 'lucide:folder-plus',
            label: $t('organizations.actions.createChild'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['organizations.create']),
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('organizations.actions.delete'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['organizations.delete']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('organizations.columns.actions'),
      width: 260,
    },
  ];
}

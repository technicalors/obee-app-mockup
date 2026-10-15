import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { FacilityResource } from '#/api';

import { $t } from '#/locales';

interface FacilityResourceTableActions {
  hasAccessByCodes: (codes: string[]) => boolean;
  onAction: (
    action: FacilityResourceTableAction,
    row: FacilityResource,
  ) => void;
}

export type FacilityResourceTableAction = 'delete' | 'edit' | 'view';

export function createFacilityResourceTableFilterSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      componentProps: {
        allowClear: true,
        placeholder: $t('facilityResource.filters.searchPlaceholder'),
      },
      fieldName: 'search',
      label: $t('facilityResource.filters.search'),
    },
    {
      component: 'Select',
      componentProps: {
        allowClear: true,
        options: [
          {
            label: $t('facilityResource.types.room'),
            value: 'room',
          },
          {
            label: $t('facilityResource.types.equipment'),
            value: 'equipment',
          },
        ],
      },
      fieldName: 'type',
      label: $t('facilityResource.filters.type'),
    },
  ];
}

export function createFacilityResourceTableColumns(
  actions: FacilityResourceTableActions,
): VxeTableGridOptions<FacilityResource>['columns'] {
  return [
    {
      title: $t('facilityResource.columns.sequence'),
      type: 'seq',
      width: 60,
    },
    {
      field: 'code',
      minWidth: 160,
      title: $t('facilityResource.columns.code'),
    },
    {
      field: 'name',
      minWidth: 220,
      title: $t('facilityResource.columns.name'),
    },
    {
      field: 'type',
      formatter: ({ cellValue }) =>
        $t(
          cellValue === 'room'
            ? 'facilityResource.types.room'
            : 'facilityResource.types.equipment',
        ),
      minWidth: 120,
      title: $t('facilityResource.columns.type'),
    },
    {
      field: 'quantity',
      minWidth: 100,
      title: $t('facilityResource.columns.quantity'),
    },
    {
      field: 'note',
      formatter: ({ cellValue }) => cellValue ?? $t('common.notProvided'),
      minWidth: 180,
      title: $t('facilityResource.columns.note'),
    },
    {
      field: 'created_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: $t('facilityResource.columns.createdAt'),
    },
    {
      field: 'updated_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: $t('facilityResource.columns.updatedAt'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: FacilityResource) => {
            if (code === 'view' || code === 'edit' || code === 'delete') {
              actions.onAction(code, row);
              return;
            }

            throw new Error(
              `Unsupported facility resource table action: ${code}`,
            );
          },
        },
        name: 'CellOperation',
        options: [
          {
            code: 'view',
            icon: 'lucide:eye',
            label: $t('facilityResource.actions.view'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['facility-resources.view']),
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('facilityResource.actions.edit'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['facility-resources.view']) &&
              actions.hasAccessByCodes(['facility-resources.update']),
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('facilityResource.actions.delete'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['facility-resources.delete']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('facilityResource.columns.actions'),
      width: 132,
    },
  ];
}

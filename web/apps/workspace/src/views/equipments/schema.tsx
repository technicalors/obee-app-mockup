import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { Equipment } from '#/api';

import { $t } from '#/locales';

interface EquipmentTableActions {
  hasAccessByCodes: (codes: string[]) => boolean;
  onAction: (action: EquipmentTableAction, row: Equipment) => void;
}

export type EquipmentTableAction = 'delete' | 'edit' | 'view';

export function createEquipmentTableFilterSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      componentProps: {
        allowClear: true,
        placeholder: $t('page.equipment.filters.searchPlaceholder'),
      },
      fieldName: 'search',
      label: $t('page.equipment.filters.search'),
    },
  ];
}

export function createEquipmentTableColumns(
  actions: EquipmentTableActions,
): VxeTableGridOptions<Equipment>['columns'] {
  return [
    {
      title: 'STT',
      type: 'seq',
      width: 60,
    },
    {
      field: 'code',
      minWidth: 160,
      title: $t('page.equipment.columns.code'),
    },
    {
      field: 'name',
      minWidth: 220,
      title: $t('page.equipment.columns.name'),
    },
    {
      field: 'created_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: $t('page.equipment.columns.createdAt'),
    },
    {
      field: 'updated_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: $t('page.equipment.columns.updatedAt'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: Equipment) => {
            if (code === 'view' || code === 'edit' || code === 'delete') {
              actions.onAction(code, row);
              return;
            }

            throw new Error(`Unsupported equipment table action: ${code}`);
          },
        },
        name: 'CellOperation',
        options: [
          {
            code: 'view',
            icon: 'lucide:eye',
            label: $t('page.equipment.actions.view'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['equipments.view']),
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('page.equipment.actions.edit'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['equipments.view']) &&
              actions.hasAccessByCodes(['equipments.update']),
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('page.equipment.actions.delete'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['equipments.delete']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('page.equipment.columns.actions'),
      width: 132,
    },
  ];
}

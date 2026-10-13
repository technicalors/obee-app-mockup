import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { Position } from '#/api';

import { $t } from '#/locales';

export type PositionTableAction = 'delete' | 'edit' | 'view';

interface PositionTableActions {
  hasAccessByCodes: (codes: string[]) => boolean;
  onAction: (action: PositionTableAction, position: Position) => void;
}

export function createPositionTableFilterSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      componentProps: {
        allowClear: true,
        placeholder: $t('page.positions.filters.searchPlaceholder'),
      },
      fieldName: 'search',
      label: $t('page.positions.filters.search'),
    },
  ];
}

export function createPositionTableColumns(
  actions: PositionTableActions,
): VxeTableGridOptions<Position>['columns'] {
  return [
    {
      title: 'STT',
      type: 'seq',
      width: 60,
    },
    {
      field: 'name',
      minWidth: 180,
      title: $t('page.positions.columns.name'),
    },
    {
      field: 'description',
      minWidth: 260,
      title: $t('page.positions.columns.description'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: Position) => {
            if (code === 'view' || code === 'edit' || code === 'delete') {
              actions.onAction(code, row);
              return;
            }

            throw new Error(`Unsupported position table action: ${code}`);
          },
        },
        name: 'CellOperation',
        options: [
          {
            code: 'view',
            icon: 'lucide:eye',
            label: $t('page.positions.actions.view'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['positions.view']),
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('page.positions.actions.edit'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['positions.view']) &&
              actions.hasAccessByCodes(['positions.update']),
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('page.positions.actions.delete'),
            type: 'text',
            visible: () => actions.hasAccessByCodes(['positions.delete']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('page.positions.columns.actions'),
      width: 132,
    },
  ];
}

import type { VbenFormSchema } from '#/adapter/form';
import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { AttendanceLocation } from '#/api';

import { $t } from '#/locales';

interface AttendanceLocationTableActions {
  hasAccessByCodes: (codes: string[]) => boolean;
  onAction: (
    action: AttendanceLocationTableAction,
    row: AttendanceLocation,
  ) => void;
}

export type AttendanceLocationTableAction =
  | 'delete'
  | 'edit'
  | 'restore'
  | 'view';

export function createAttendanceLocationTableFilterSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      componentProps: {
        allowClear: true,
        placeholder: $t('attendanceLocations.filters.searchPlaceholder'),
      },
      fieldName: 'search',
      label: $t('attendanceLocations.filters.search'),
    },
    {
      component: 'Select',
      componentProps: {
        allowClear: true,
        options: [
          { label: $t('attendanceLocations.status.active'), value: 'active' },
          { label: $t('attendanceLocations.status.all'), value: 'all' },
          {
            label: $t('attendanceLocations.status.deleted'),
            value: 'deleted',
          },
        ],
      },
      defaultValue: 'active',
      fieldName: 'status',
      label: $t('attendanceLocations.filters.status'),
    },
    {
      component: 'Select',
      componentProps: {
        allowClear: true,
        options: [
          {
            label: $t('attendanceLocations.validationMode.location'),
            value: 'location',
          },
          {
            label: $t('attendanceLocations.validationMode.ip'),
            value: 'ip',
          },
          {
            label: $t('attendanceLocations.validationMode.both'),
            value: 'both',
          },
          {
            label: $t('attendanceLocations.validationMode.either'),
            value: 'either',
          },
        ],
      },
      fieldName: 'validation_mode',
      label: $t('attendanceLocations.filters.validationMode'),
    },
  ];
}

export function createAttendanceLocationTableColumns(
  actions: AttendanceLocationTableActions,
): VxeTableGridOptions<AttendanceLocation>['columns'] {
  return [
    {
      title: 'STT',
      type: 'seq',
      width: 60,
    },
    {
      field: 'name',
      minWidth: 180,
      title: $t('attendanceLocations.columns.name'),
    },
    {
      field: 'coordinates',
      formatter: ({ row }) => `${row.latitude}, ${row.longitude}`,
      minWidth: 180,
      title: $t('attendanceLocations.columns.coordinates'),
    },
    {
      field: 'radius_meters',
      formatter: ({ cellValue }) => `${cellValue}m`,
      minWidth: 120,
      title: $t('attendanceLocations.columns.radius'),
    },
    {
      field: 'validation_mode',
      cellRender: {
        name: 'CellTag',
        options: [
          {
            color: 'blue',
            label: $t('attendanceLocations.validationMode.location'),
            value: 'location',
          },
          {
            color: 'purple',
            label: $t('attendanceLocations.validationMode.ip'),
            value: 'ip',
          },
          {
            color: 'green',
            label: $t('attendanceLocations.validationMode.both'),
            value: 'both',
          },
          {
            color: 'orange',
            label: $t('attendanceLocations.validationMode.either'),
            value: 'either',
          },
        ],
      },
      minWidth: 140,
      title: $t('attendanceLocations.columns.validationMode'),
    },
    {
      cellRender: {
        attrs: {
          getColor: (deleted: unknown) => (deleted === true ? 'red' : 'green'),
          getItems: (row: AttendanceLocation) => [row.deleted_at !== null],
          getKey: (_deleted: unknown, index: number) => index,
          getLabel: (deleted: unknown) =>
            deleted === true
              ? $t('attendanceLocations.status.deleted')
              : $t('attendanceLocations.status.active'),
        },
        name: 'CellTags',
      },
      field: 'deleted_at',
      minWidth: 120,
      title: $t('attendanceLocations.columns.status'),
    },
    {
      field: 'created_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: $t('attendanceLocations.columns.createdAt'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: AttendanceLocation) => {
            if (
              code === 'view' ||
              code === 'edit' ||
              code === 'delete' ||
              code === 'restore'
            ) {
              actions.onAction(code, row);
              return;
            }

            throw new Error(
              `Unsupported attendance location table action: ${code}`,
            );
          },
        },
        name: 'CellOperation',
        options: [
          {
            code: 'view',
            icon: 'lucide:eye',
            label: $t('attendanceLocations.actions.view'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['attendance-locations.viewAny']),
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('attendanceLocations.actions.edit'),
            type: 'text',
            visible: (row: AttendanceLocation) =>
              row.deleted_at === null &&
              actions.hasAccessByCodes(['attendance-locations.update']),
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('attendanceLocations.actions.delete'),
            type: 'text',
            visible: (row: AttendanceLocation) =>
              row.deleted_at === null &&
              actions.hasAccessByCodes(['attendance-locations.delete']),
          },
          {
            code: 'restore',
            icon: 'lucide:archive-restore',
            label: $t('attendanceLocations.actions.restore'),
            type: 'text',
            visible: (row: AttendanceLocation) =>
              row.deleted_at !== null &&
              actions.hasAccessByCodes(['attendance-locations.delete']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('attendanceLocations.columns.actions'),
      width: 160,
    },
  ];
}

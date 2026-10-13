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

export type AttendanceLocationTableAction = 'delete' | 'edit' | 'view';

export function createAttendanceLocationTableFilterSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      componentProps: {
        allowClear: true,
        placeholder: $t('page.attendanceLocations.filters.searchPlaceholder'),
      },
      fieldName: 'search',
      label: $t('page.attendanceLocations.filters.search'),
    },
    {
      component: 'Select',
      componentProps: {
        allowClear: true,
        options: [
          { label: $t('page.attendanceLocations.status.active'), value: true },
          {
            label: $t('page.attendanceLocations.status.inactive'),
            value: false,
          },
        ],
      },
      fieldName: 'is_active',
      label: $t('page.attendanceLocations.filters.status'),
    },
    {
      component: 'Select',
      componentProps: {
        allowClear: true,
        options: [
          {
            label: $t('page.attendanceLocations.validationMode.location'),
            value: 'location',
          },
          {
            label: $t('page.attendanceLocations.validationMode.ip'),
            value: 'ip',
          },
          {
            label: $t('page.attendanceLocations.validationMode.both'),
            value: 'both',
          },
          {
            label: $t('page.attendanceLocations.validationMode.either'),
            value: 'either',
          },
        ],
      },
      fieldName: 'validation_mode',
      label: $t('page.attendanceLocations.filters.validationMode'),
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
      title: $t('page.attendanceLocations.columns.name'),
    },
    {
      field: 'coordinates',
      formatter: ({ row }) => `${row.latitude}, ${row.longitude}`,
      minWidth: 180,
      title: $t('page.attendanceLocations.columns.coordinates'),
    },
    {
      field: 'radius_meters',
      formatter: ({ cellValue }) => `${cellValue}m`,
      minWidth: 120,
      title: $t('page.attendanceLocations.columns.radius'),
    },
    {
      field: 'validation_mode',
      cellRender: {
        name: 'CellTag',
        options: [
          {
            color: 'blue',
            label: $t('page.attendanceLocations.validationMode.location'),
            value: 'location',
          },
          {
            color: 'purple',
            label: $t('page.attendanceLocations.validationMode.ip'),
            value: 'ip',
          },
          {
            color: 'green',
            label: $t('page.attendanceLocations.validationMode.both'),
            value: 'both',
          },
          {
            color: 'orange',
            label: $t('page.attendanceLocations.validationMode.either'),
            value: 'either',
          },
        ],
      },
      minWidth: 140,
      title: $t('page.attendanceLocations.columns.validationMode'),
    },
    {
      cellRender: {
        name: 'CellTag',
        options: [
          {
            color: 'green',
            label: $t('page.attendanceLocations.status.active'),
            value: true,
          },
          {
            color: 'red',
            label: $t('page.attendanceLocations.status.inactive'),
            value: false,
          },
        ],
      },
      field: 'is_active',
      minWidth: 120,
      title: $t('page.attendanceLocations.columns.status'),
    },
    {
      field: 'created_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: $t('page.attendanceLocations.columns.createdAt'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: AttendanceLocation) => {
            if (code === 'view' || code === 'edit' || code === 'delete') {
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
            label: $t('page.attendanceLocations.actions.view'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['attendance-locations.viewAny']),
          },
          {
            code: 'edit',
            icon: 'lucide:pencil',
            label: $t('page.attendanceLocations.actions.edit'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['attendance-locations.update']),
          },
          {
            code: 'delete',
            danger: true,
            icon: 'lucide:trash-2',
            label: $t('page.attendanceLocations.actions.delete'),
            type: 'text',
            visible: () =>
              actions.hasAccessByCodes(['attendance-locations.delete']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('page.attendanceLocations.columns.actions'),
      width: 160,
    },
  ];
}

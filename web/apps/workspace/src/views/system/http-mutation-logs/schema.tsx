import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { HttpMutationLog } from '#/api';

import { $t } from '#/locales';

export function createHttpMutationLogTableColumns(
  hasAccessByCodes: (codes: string[]) => boolean,
  openDetail: (row: HttpMutationLog) => void,
): VxeTableGridOptions<HttpMutationLog>['columns'] {
  return [
    {
      field: 'logged_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: $t('mutationLogs.columns.loggedAt'),
    },
    {
      field: 'code',
      minWidth: 105,
      title: $t('mutationLogs.columns.code'),
    },
    {
      field: 'uri',
      minWidth: 240,
      title: $t('mutationLogs.columns.uri'),
    },
    {
      field: 'action',
      minWidth: 190,
      title: $t('mutationLogs.columns.action'),
    },
    {
      field: 'requested_by_user',
      formatter: ({ row }) =>
        row.requested_by_user?.username ?? $t('common.notProvided'),
      minWidth: 150,
      title: $t('mutationLogs.columns.requestedBy'),
    },
    {
      field: 'response_status',
      minWidth: 90,
      title: $t('mutationLogs.columns.status'),
    },
    {
      align: 'center',
      cellRender: {
        attrs: {
          onClick: (code: string, row: HttpMutationLog) => {
            if (code !== 'view') {
              throw new Error(`Unsupported mutation-log table action: ${code}`);
            }
            openDetail(row);
          },
        },
        name: 'CellOperation',
        options: [
          {
            code: 'view',
            icon: 'lucide:eye',
            label: $t('mutationLogs.actions.view'),
            type: 'text',
            visible: () => hasAccessByCodes(['http-mutation-logs.view']),
          },
        ],
      },
      field: 'actions',
      fixed: 'right',
      showOverflow: false,
      title: $t('mutationLogs.columns.actions'),
      width: 100,
    },
  ];
}

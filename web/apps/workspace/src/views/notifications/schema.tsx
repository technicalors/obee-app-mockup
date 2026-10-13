import type { VxeTableGridOptions } from '#/adapter/vxe-table';
import type { InboxNotification } from '#/api';

export function createNotificationTableColumns(): VxeTableGridOptions<InboxNotification>['columns'] {
  return [
    {
      field: 'id',
      minWidth: 320,
      slots: {
        default: 'notification',
      },
    },
  ];
}

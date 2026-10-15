import type { AttendanceLocationTableFilters } from './query';
import type { AttendanceLocationTableAction } from './schema';

import type { AttendanceLocation, AttendanceLocationIndexQuery } from '#/api';

import { computed } from 'vue';
import { useRouter } from 'vue-router';

import { useAccess } from '@vben/access';
import { confirm } from '@vben/common-ui';

import { notification } from 'ant-design-vue';

import { attendanceLocationsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import { createAttendanceLocationIndexQuery } from './query';
import {
  createAttendanceLocationTableColumns,
  createAttendanceLocationTableFilterSchema,
} from './schema';

export function useAttendanceLocationsPage() {
  const authStore = useAuthStore();
  const { hasAccessByCodes } = useAccess();
  const router = useRouter();

  const [Grid, table] = useResourceTable<
    AttendanceLocation,
    AttendanceLocationIndexQuery,
    AttendanceLocationTableFilters
  >({
    buildQuery: createAttendanceLocationIndexQuery,
    enabled: () => authStore.hasSession,
    errorMessage: $t('attendanceLocations.messages.unexpectedError'),
    formOptions: {
      schema: createAttendanceLocationTableFilterSchema(),
      showCollapseButton: false,
      submitOnChange: true,
    },
    gridOptions: {
      border: true,
      columns: createAttendanceLocationTableColumns({
        hasAccessByCodes,
        onAction: handleTableAction,
      }),
      rowConfig: {
        keyField: 'id',
      },
    },
    resource: attendanceLocationsResource,
    tableTitle: $t('attendanceLocations.listTitle'),
  });

  const canCreateAttendanceLocations = computed(() =>
    hasAccessByCodes(['attendance-locations.create']),
  );

  function openCreate(): void {
    router.push('/master-data/attendance-locations/create');
  }

  function openDetail(
    location: AttendanceLocation,
    mode: 'edit' | 'view',
  ): void {
    if (mode === 'edit') {
      router.push(`/master-data/attendance-locations/${location.id}/edit`);
    } else {
      router.push(`/master-data/attendance-locations/${location.id}`);
    }
  }

  function handleTableAction(
    action: AttendanceLocationTableAction,
    location: AttendanceLocation,
  ): void {
    if (action === 'view') {
      openDetail(location, 'view');
      return;
    }

    if (action === 'edit') {
      openDetail(location, 'edit');
      return;
    }

    if (action === 'restore') {
      void restore(location);
      return;
    }

    void confirmDelete(location);
  }

  async function restore(location: AttendanceLocation): Promise<void> {
    try {
      await attendanceLocationsResource.restore(location.id);
      notification.success({
        message: $t('attendanceLocations.messages.restored'),
      });
      await table.reload();
    } catch (error) {
      showRequestError(
        error,
        $t('attendanceLocations.messages.unexpectedError'),
        'Failed to restore attendance location:',
      );
    }
  }

  async function confirmDelete(location: AttendanceLocation): Promise<void> {
    try {
      await confirm({
        cancelText: $t('attendanceLocations.actions.cancel'),
        confirmText: $t('attendanceLocations.actions.delete'),
        content: $t('attendanceLocations.delete.description', {
          name: location.name,
        }),
        icon: 'warning',
        title: $t('attendanceLocations.delete.title'),
      });
    } catch {
      return;
    }

    if (await table.remove(location.id)) {
      notification.success({
        message: $t('attendanceLocations.messages.deleted'),
      });
    }
  }

  return {
    canCreateAttendanceLocations,
    Grid,
    openCreate,
  };
}

import type { PositionTableFilters } from './query';
import type { PositionTableAction } from './schema';

import type { Position, PositionIndexQuery } from '#/api';

import { computed, defineAsyncComponent } from 'vue';

import { useAccess } from '@vben/access';
import { useVbenModal } from '@vben/common-ui';

import { Modal, notification } from 'ant-design-vue';

import { positionsResource } from '#/api';
import { $t } from '#/locales';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import { createPositionIndexQuery } from './query';
import {
  createPositionTableColumns,
  createPositionTableFilterSchema,
} from './schema';

const CreatePositionModalComponent = defineAsyncComponent(
  () => import('./create-position-modal.vue'),
);
const PositionDetailModalComponent = defineAsyncComponent(
  () => import('./position-detail-modal.vue'),
);

export function usePositionsPage() {
  const authStore = useAuthStore();
  const { hasAccessByCodes } = useAccess();

  const [CreatePositionModal, createPositionModalApi] = useVbenModal({
    connectedComponent: CreatePositionModalComponent,
  });
  const [PositionDetailModal, positionDetailModalApi] = useVbenModal({
    connectedComponent: PositionDetailModalComponent,
  });

  const [Grid, table] = useResourceTable<
    Position,
    PositionIndexQuery,
    PositionTableFilters
  >({
    buildQuery: createPositionIndexQuery,
    enabled: () => authStore.hasSession,
    errorMessage: $t('page.positions.messages.unexpectedError'),
    formOptions: {
      schema: createPositionTableFilterSchema(),
      showCollapseButton: false,
      submitOnChange: true,
    },
    gridOptions: {
      border: true,
      columns: createPositionTableColumns({
        hasAccessByCodes,
        onAction: handleTableAction,
      }),
      rowConfig: {
        keyField: 'id',
      },
    },
    resource: positionsResource,
    tableTitle: $t('page.positions.listTitle'),
  });

  const canCreatePositions = computed(() =>
    hasAccessByCodes(['positions.create']),
  );

  function openCreate(): void {
    createPositionModalApi.setData({
      onSaved: table.reload,
    });
    createPositionModalApi.open();
  }

  function openDetail(position: Position, mode: 'edit' | 'view'): void {
    positionDetailModalApi.setData({
      mode,
      onSaved: table.reload,
      position,
    });
    positionDetailModalApi.open();
  }

  function handleTableAction(
    action: PositionTableAction,
    position: Position,
  ): void {
    if (action === 'view') {
      openDetail(position, 'view');
      return;
    }

    if (action === 'edit') {
      openDetail(position, 'edit');
      return;
    }

    Modal.confirm({
      cancelText: $t('page.positions.actions.cancel'),
      content: $t('page.positions.delete.description', {
        name: position.name,
      }),
      okButtonProps: { danger: true },
      okText: $t('page.positions.actions.delete'),
      onOk: async () => {
        if (await table.remove(position.id)) {
          notification.success({
            message: $t('page.positions.messages.deleted'),
          });
        }
      },
      title: $t('page.positions.delete.title'),
    });
  }

  return {
    canCreatePositions,
    CreatePositionModal,
    Grid,
    openCreate,
    PositionDetailModal,
  };
}

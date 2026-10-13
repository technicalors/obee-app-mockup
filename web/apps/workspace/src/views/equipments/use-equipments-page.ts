import type { EquipmentTableFilters } from './query';
import type { EquipmentTableAction } from './schema';

import type { Equipment, EquipmentIndexQuery } from '#/api';

import { computed, defineAsyncComponent } from 'vue';

import { useAccess } from '@vben/access';
import { useVbenModal } from '@vben/common-ui';

import { Modal, notification } from 'ant-design-vue';

import { equipmentsResource } from '#/api';
import { $t } from '#/locales';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import { createEquipmentIndexQuery } from './query';
import {
  createEquipmentTableColumns,
  createEquipmentTableFilterSchema,
} from './schema';

const CreateEquipmentModalComponent = defineAsyncComponent(
  () => import('./create-equipment-modal.vue'),
);
const EquipmentDetailModalComponent = defineAsyncComponent(
  () => import('./equipment-detail-modal.vue'),
);

export function useEquipmentsPage() {
  const authStore = useAuthStore();
  const { hasAccessByCodes } = useAccess();
  const [CreateEquipmentModal, createEquipmentModalApi] = useVbenModal({
    connectedComponent: CreateEquipmentModalComponent,
  });
  const [EquipmentDetailModal, equipmentDetailModalApi] = useVbenModal({
    connectedComponent: EquipmentDetailModalComponent,
  });
  const [Grid, table] = useResourceTable<
    Equipment,
    EquipmentIndexQuery,
    EquipmentTableFilters
  >({
    buildQuery: createEquipmentIndexQuery,
    enabled: () => authStore.hasSession,
    errorMessage: $t('page.equipment.messages.unexpectedError'),
    formOptions: {
      schema: createEquipmentTableFilterSchema(),
      showCollapseButton: false,
      submitOnChange: true,
    },
    gridOptions: {
      border: true,
      columns: createEquipmentTableColumns({
        hasAccessByCodes,
        onAction: handleTableAction,
      }),
      rowConfig: {
        keyField: 'id',
      },
    },
    resource: equipmentsResource,
    tableTitle: $t('page.equipment.listTitle'),
  });

  const canCreateEquipments = computed(() =>
    hasAccessByCodes(['equipments.create']),
  );

  function openCreate(): void {
    createEquipmentModalApi.setData({
      onSaved: table.reload,
    });
    createEquipmentModalApi.open();
  }

  function openDetail(equipment: Equipment, mode: 'edit' | 'view'): void {
    equipmentDetailModalApi.setData({
      equipment,
      mode,
      onSaved: table.reload,
    });
    equipmentDetailModalApi.open();
  }

  function handleTableAction(
    action: EquipmentTableAction,
    equipment: Equipment,
  ): void {
    if (action === 'view') {
      openDetail(equipment, 'view');
      return;
    }

    if (action === 'edit') {
      openDetail(equipment, 'edit');
      return;
    }

    confirmDelete(equipment);
  }

  function confirmDelete(equipment: Equipment): void {
    Modal.confirm({
      cancelText: $t('page.equipment.actions.cancel'),
      content: $t('page.equipment.delete.description', {
        name: equipment.name,
      }),
      okButtonProps: { danger: true },
      okText: $t('page.equipment.actions.delete'),
      onOk: async () => {
        if (await table.remove(equipment.id)) {
          notification.success({
            message: $t('page.equipment.messages.deleted'),
          });
        }
      },
      title: $t('page.equipment.delete.title'),
    });
  }

  return {
    canCreateEquipments,
    CreateEquipmentModal,
    EquipmentDetailModal,
    Grid,
    openCreate,
  };
}

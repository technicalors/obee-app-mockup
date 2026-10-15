import type { FacilityResourceTableFilters } from './query';
import type { FacilityResourceTableAction } from './schema';

import type { FacilityResource, FacilityResourceIndexQuery } from '#/api';

import { computed, defineAsyncComponent } from 'vue';

import { useAccess } from '@vben/access';
import { useVbenModal } from '@vben/common-ui';

import { Modal, notification } from 'ant-design-vue';

import { facilityResourcesResource } from '#/api';
import { $t } from '#/locales';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import { createFacilityResourceIndexQuery } from './query';
import {
  createFacilityResourceTableColumns,
  createFacilityResourceTableFilterSchema,
} from './schema';

const CreateFacilityResourceModalComponent = defineAsyncComponent(
  () => import('./create-facility-resource-modal.vue'),
);
const FacilityResourceDetailModalComponent = defineAsyncComponent(
  () => import('./facility-resource-detail-modal.vue'),
);

export function useFacilityResourcesPage() {
  const authStore = useAuthStore();
  const { hasAccessByCodes } = useAccess();
  const [CreateFacilityResourceModal, createFacilityResourceModalApi] =
    useVbenModal({
      connectedComponent: CreateFacilityResourceModalComponent,
    });
  const [FacilityResourceDetailModal, facilityResourceDetailModalApi] =
    useVbenModal({
      connectedComponent: FacilityResourceDetailModalComponent,
    });
  const [Grid, table] = useResourceTable<
    FacilityResource,
    FacilityResourceIndexQuery,
    FacilityResourceTableFilters
  >({
    buildQuery: createFacilityResourceIndexQuery,
    enabled: () => authStore.hasSession,
    errorMessage: $t('facilityResource.messages.unexpectedError'),
    formOptions: {
      schema: createFacilityResourceTableFilterSchema(),
      showCollapseButton: false,
      submitOnChange: true,
    },
    gridOptions: {
      border: true,
      columns: createFacilityResourceTableColumns({
        hasAccessByCodes,
        onAction: handleTableAction,
      }),
      rowConfig: {
        keyField: 'id',
      },
    },
    resource: facilityResourcesResource,
    tableTitle: $t('facilityResource.listTitle'),
  });

  const canCreateFacilityResources = computed(() =>
    hasAccessByCodes(['facility-resources.create']),
  );

  function openCreate(): void {
    createFacilityResourceModalApi.setData({
      onSaved: table.reload,
    });
    createFacilityResourceModalApi.open();
  }

  function openDetail(
    facilityResource: FacilityResource,
    mode: 'edit' | 'view',
  ): void {
    facilityResourceDetailModalApi.setData({
      facilityResourceId: facilityResource.id,
      mode,
      onSaved: table.reload,
    });
    facilityResourceDetailModalApi.open();
  }

  function handleTableAction(
    action: FacilityResourceTableAction,
    facilityResource: FacilityResource,
  ): void {
    if (action === 'view') {
      openDetail(facilityResource, 'view');
      return;
    }

    if (action === 'edit') {
      openDetail(facilityResource, 'edit');
      return;
    }

    confirmDelete(facilityResource);
  }

  function confirmDelete(facilityResource: FacilityResource): void {
    Modal.confirm({
      cancelText: $t('facilityResource.actions.cancel'),
      content: $t('facilityResource.delete.description', {
        name: facilityResource.name,
      }),
      okButtonProps: { danger: true },
      okText: $t('facilityResource.actions.delete'),
      onOk: async () => {
        if (await table.remove(facilityResource.id)) {
          notification.success({
            message: $t('facilityResource.messages.deleted'),
          });
        }
      },
      title: $t('facilityResource.delete.title'),
    });
  }

  return {
    canCreateFacilityResources,
    CreateFacilityResourceModal,
    FacilityResourceDetailModal,
    Grid,
    openCreate,
  };
}

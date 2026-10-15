import type { OrganizationTableFilters } from './query';
import type { OrganizationTableAction } from './schema';

import type { Organization, OrganizationIndexQuery } from '#/api';

import { computed, onMounted, ref, shallowRef } from 'vue';
import { useRouter } from 'vue-router';

import { useAccess } from '@vben/access';
import { useVbenModal } from '@vben/common-ui';

import { Modal, notification } from 'ant-design-vue';

import { organizationsResource } from '#/api';
import { $t } from '#/locales';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import CreateOrganizationModalComponent from './create-organization-modal.vue';
import OrganizationDetailModalComponent from './organization-detail-modal.vue';
import { createOrganizationIndexQuery } from './query';
import {
  createOrganizationTableColumns,
  createOrganizationTableFilterSchema,
} from './schema';

export function useOrganizationsPage() {
  const authStore = useAuthStore();
  const router = useRouter();
  const { hasAccessByCodes } = useAccess();
  const parentOrganizations = shallowRef(new Map<string, Organization>());
  const parentOrganizationsState = ref<'failed' | 'loaded' | 'loading'>(
    'loading',
  );
  let parentOrganizationsRequest = 0;
  let parentOrganizationsLoad: Promise<void> = Promise.resolve();
  const [CreateOrganizationModal, createModalApi] = useVbenModal({
    connectedComponent: CreateOrganizationModalComponent,
  });
  const [OrganizationDetailModal, detailModalApi] = useVbenModal({
    connectedComponent: OrganizationDetailModalComponent,
  });
  const [Grid, table] = useResourceTable<
    Organization,
    OrganizationIndexQuery,
    OrganizationTableFilters
  >({
    buildQuery: createOrganizationIndexQuery,
    enabled: () => authStore.hasSession,
    errorMessage: $t('organizations.messages.unexpectedError'),
    formOptions: {
      schema: createOrganizationTableFilterSchema(),
      showCollapseButton: false,
      submitOnChange: true,
    },
    gridOptions: {
      border: true,
      columns: createOrganizationTableColumns({
        hasAccessByCodes,
        parentOrganizationName: (parentId) => {
          if (parentId === null) {
            return $t('organizations.values.root');
          }
          if (parentOrganizationsState.value === 'loading') {
            return $t('organizations.values.parentLoading');
          }
          if (parentOrganizationsState.value === 'failed') {
            return $t('organizations.values.parentUnavailable');
          }
          const parentOrganization = parentOrganizations.value.get(parentId);
          if (parentOrganization === undefined) {
            throw new Error(`Organization parent ${parentId} is unavailable.`);
          }
          return parentOrganization.name;
        },
        onAction: handleTableAction,
      }),
      rowConfig: { keyField: 'id' },
    },
    resource: organizationsResource,
    tableTitle: $t('organizations.listTitle'),
  });

  const canCreateOrganizations = computed(() =>
    hasAccessByCodes(['organizations.create']),
  );

  function reloadParentOrganizations(): Promise<void> {
    const request = ++parentOrganizationsRequest;
    parentOrganizationsState.value = 'loading';
    parentOrganizationsLoad = organizationsResource
      .getAllRows()
      .then((organizations) => {
        if (request !== parentOrganizationsRequest) return;
        parentOrganizations.value = new Map(
          organizations.map((organization) => [organization.id, organization]),
        );
        parentOrganizationsState.value = 'loaded';
      })
      .catch(() => {
        if (request !== parentOrganizationsRequest) return;
        parentOrganizationsState.value = 'failed';
        notification.error({
          message: $t('organizations.messages.unexpectedError'),
        });
      });
    return parentOrganizationsLoad;
  }

  async function reloadAfterSave(): Promise<void> {
    await Promise.all([table.reload(), reloadParentOrganizations()]);
  }

  onMounted(reloadParentOrganizations);

  function openCreate(parentId: null | string = null): void {
    createModalApi.setData({ onSaved: reloadAfterSave, parentId });
    createModalApi.open();
  }

  function openTree(): void {
    void router.push({ name: 'MasterDataOrganizationTree' });
  }

  async function openDetail(
    organization: Organization,
    mode: 'edit' | 'view',
  ): Promise<void> {
    if (parentOrganizationsState.value === 'loading') {
      await parentOrganizationsLoad;
    }
    if (parentOrganizationsState.value === 'failed') {
      return;
    }
    detailModalApi.setData({
      mode,
      onSaved: reloadAfterSave,
      organization,
      organizations: [...parentOrganizations.value.values()],
    });
    detailModalApi.open();
  }

  function handleTableAction(
    action: OrganizationTableAction,
    organization: Organization,
  ): void {
    if (action === 'view' || action === 'edit') {
      void openDetail(organization, action);
      return;
    }
    if (action === 'create-child') {
      openCreate(organization.id);
      return;
    }
    confirmDelete(organization);
  }

  function confirmDelete(organization: Organization): void {
    Modal.confirm({
      cancelText: $t('organizations.actions.cancel'),
      content: $t('organizations.delete.description', {
        name: organization.name,
      }),
      okButtonProps: { danger: true },
      okText: $t('organizations.actions.delete'),
      onOk: async () => {
        if (await table.remove(organization.id)) {
          await reloadParentOrganizations();
          notification.success({
            message: $t('organizations.messages.deleted'),
          });
        }
      },
      title: $t('organizations.delete.title'),
    });
  }

  return {
    canCreateOrganizations,
    CreateOrganizationModal,
    Grid,
    openCreate,
    openTree,
    OrganizationDetailModal,
  };
}

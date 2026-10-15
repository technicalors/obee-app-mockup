<script setup lang="ts">
import type { Organization } from '#/api';

import { computed, onMounted, ref, watch } from 'vue';
import { useRouter } from 'vue-router';

import { useAccess } from '@vben/access';
import { useVbenModal } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Empty,
  Modal,
  notification,
  Select,
  Spin,
} from 'ant-design-vue';

import { organizationsResource } from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import CreateOrganizationModalComponent from './create-organization-modal.vue';
import OrganizationDetailModalComponent from './organization-detail-modal.vue';
import OrganizationGraph from './organization-graph.vue';
import { buildOrganizationTree } from './organization-tree';
import OrganizationTreeDrawer from './organization-tree-drawer.vue';

const DRAWER_FORM_MODAL_Z_INDEX = 2100;
const [CreateOrganizationModal, createModalApi] = useVbenModal({
  connectedComponent: CreateOrganizationModalComponent,
  zIndex: DRAWER_FORM_MODAL_Z_INDEX,
});
const [OrganizationDetailModal, detailModalApi] = useVbenModal({
  connectedComponent: OrganizationDetailModalComponent,
  zIndex: DRAWER_FORM_MODAL_Z_INDEX,
});
const router = useRouter();
const { hasAccessByCodes } = useAccess();
const organizations = ref<Organization[]>([]);
const loading = ref(false);
const selectedOrganization = ref<null | Organization>(null);
const selectedRootId = ref<string>();
const treeDrawerOpen = ref(false);
let organizationsLoadRequest = 0;

const tree = computed(() => buildOrganizationTree(organizations.value));
const roots = computed(() =>
  tree.value.map(({ organization }) => organization),
);
const selectedRoot = computed(() =>
  tree.value.find(
    ({ organization }) => organization.id === selectedRootId.value,
  ),
);
const canCreate = computed(() => hasAccessByCodes(['organizations.create']));
const canDelete = computed(() => hasAccessByCodes(['organizations.delete']));
const canView = computed(() => hasAccessByCodes(['organizations.view']));
const canEdit = computed(() =>
  hasAccessByCodes(['organizations.view', 'organizations.update']),
);

async function loadOrganizations(): Promise<void> {
  const request = ++organizationsLoadRequest;
  loading.value = true;
  try {
    const rows = await organizationsResource.getAllRows();
    if (request !== organizationsLoadRequest) return;
    const organizationRoots = buildOrganizationTree(rows);
    organizations.value = rows;

    if (
      !organizationRoots.some(
        ({ organization }) => organization.id === selectedRootId.value,
      )
    ) {
      selectedRootId.value = organizationRoots[0]?.organization.id;
    }
  } catch (error) {
    if (request !== organizationsLoadRequest) return;
    showRequestError(
      error,
      $t('organizations.messages.unexpectedError'),
      'Unexpected organization tree load error:',
    );
  } finally {
    if (request === organizationsLoadRequest) loading.value = false;
  }
}

function openCreate(parentId: null | string): void {
  createModalApi.setData({
    onSaved: reloadOrganizationTree,
    parentId,
  });
  createModalApi.open();
}

function openSelected(mode: 'edit' | 'view', organization: Organization): void {
  detailModalApi.setData({
    mode,
    onSaved: reloadOrganizationTree,
    organization,
    organizations: organizations.value,
  });
  detailModalApi.open();
}

function openOrganization(organization: Organization): void {
  selectedOrganization.value = organization;
  treeDrawerOpen.value = true;
}

function closeOrganizationDrawer(): void {
  selectedOrganization.value = null;
  treeDrawerOpen.value = false;
}

async function reloadOrganizationTree(): Promise<void> {
  closeOrganizationDrawer();
  await loadOrganizations();
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
      try {
        await organizationsResource.delete(organization.id);
        notification.success({
          message: $t('organizations.messages.deleted'),
        });
        await reloadOrganizationTree();
      } catch (error) {
        showRequestError(
          error,
          $t('organizations.messages.unexpectedError'),
          'Unexpected organization tree delete error:',
          notification,
        );
        throw error;
      }
    },
    title: $t('organizations.delete.title'),
  });
}

onMounted(() => void loadOrganizations());

watch(selectedRootId, closeOrganizationDrawer);
</script>

<template>
  <section class="rounded-lg border border-border bg-card p-4 shadow-sm">
    <div
      class="-mx-4 -mt-4 mb-4 flex flex-wrap items-center justify-between gap-4 border-b border-border px-8 py-4"
    >
      <div>
        <h2 class="m-0 text-base font-semibold">
          {{ $t('organizations.tree.title') }}
        </h2>
        <p class="m-0 mt-1 text-xs text-muted-foreground">
          {{ $t('organizations.tree.description') }}
        </p>
      </div>
      <div class="flex flex-wrap items-center gap-3">
        <label class="flex items-center gap-3 text-sm font-semibold">
          <span>{{ $t('organizations.tree.root') }}:</span>
          <Select
            v-model:value="selectedRootId"
            class="w-72 max-w-full"
            :loading="loading"
          >
            <Select.Option
              v-for="root in roots"
              :key="root.id"
              :value="root.id"
            >
              {{ root.name }}
            </Select.Option>
          </Select>
        </label>
        <Button
          v-if="canCreate"
          size="small"
          type="primary"
          @click="openCreate(null)"
        >
          <IconifyIcon aria-hidden="true" icon="lucide:plus" />
          {{ $t('organizations.actions.createRoot') }}
        </Button>
        <Button @click="router.push({ name: 'MasterDataOrganizations' })">
          {{ $t('organizations.actions.backToList') }}
        </Button>
      </div>
    </div>

    <Spin :spinning="loading">
      <OrganizationGraph
        v-if="selectedRoot !== undefined"
        :root="selectedRoot"
        @select="openOrganization"
      />
      <Empty v-else :description="$t('organizations.tree.empty')" />
    </Spin>
    <CreateOrganizationModal />
    <OrganizationTreeDrawer
      :can-create="canCreate"
      :can-delete="canDelete"
      :can-edit="canEdit"
      :can-view="canView"
      :open="treeDrawerOpen"
      :organization="selectedOrganization"
      :organizations="organizations"
      @close="closeOrganizationDrawer"
      @create-child="openCreate($event.id)"
      @delete="confirmDelete"
      @edit="openSelected('edit', $event)"
      @view="openSelected('view', $event)"
    />
    <OrganizationDetailModal />
  </section>
</template>

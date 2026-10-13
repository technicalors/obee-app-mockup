<script setup lang="ts">
import type { Permission, Role } from '#/api';

import { computed, ref } from 'vue';
import { onBeforeRouteLeave } from 'vue-router';

import { useAccess } from '@vben/access';
import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Checkbox,
  Input,
  Modal,
  notification,
  Spin,
} from 'ant-design-vue';

import {
  ApiProblemError,
  getUserInfoApi,
  permissionsResource,
  rolesManagementResource,
  rolesResource,
} from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useAuthStore } from '#/store';

import {
  createPermissionMatrix,
  CRUD_ACTIONS,
  hasSamePermissionIds,
  mergeMatrixPermissionIds,
} from './matrix';

const authStore = useAuthStore();
const { hasAccessByCodes } = useAccess();
const roles = ref<Role[]>([]);
const permissions = ref<Permission[]>([]);
const drafts = ref<Record<string, string[]>>({});
const selectedRoleId = ref<null | string>(null);
const resourceSearch = ref('');
const loading = ref(true);
const retrying = ref(false);
const error = ref<null | string>(null);
const permissionsUnavailable = ref(false);

const selectedRole = computed<null | Role>(() => {
  const role = roles.value.find(
    (candidate) => candidate.id === selectedRoleId.value,
  );

  return role === undefined ? null : role;
});
const matrix = computed(() => createPermissionMatrix(permissions.value));
const filteredMatrix = computed(() =>
  matrix.value.filter((resource) =>
    resource.displayName
      .toLocaleLowerCase()
      .includes(resourceSearch.value.toLocaleLowerCase()),
  ),
);
const canUpdate = computed(() => hasAccessByCodes(['roles.update']));
const canEditSelectedRole = computed(
  () => canUpdate.value && selectedRole.value !== null,
);
const selectedDraftIds = computed(() => {
  if (selectedRole.value === null) {
    return [];
  }

  return draftIdsForRole(selectedRole.value.id);
});
const hasSelectedRoleChanges = computed(
  () => selectedRole.value !== null && hasRoleChanges(selectedRole.value),
);
const hasDirtyDrafts = computed(() =>
  roles.value.some((role) => hasRoleChanges(role)),
);

function initializeRoles(nextRoles: readonly Role[]): void {
  roles.value = [...nextRoles];
  drafts.value = Object.fromEntries(
    nextRoles.map((role) => [
      role.id,
      role.permissions.map((permission) => permission.id),
    ]),
  );
  const [firstRole] = nextRoles;
  selectedRoleId.value = firstRole === undefined ? null : firstRole.id;
}

async function load(): Promise<void> {
  error.value = null;
  loading.value = true;

  try {
    const nextRoles = await rolesResource.getAll();

    try {
      permissions.value = [...(await permissionsResource.getAll())];
      permissionsUnavailable.value = false;
    } catch (requestError) {
      if (
        requestError instanceof ApiProblemError &&
        requestError.problem.status === 403
      ) {
        permissionsUnavailable.value = true;
      } else {
        throw requestError;
      }
    }

    initializeRoles(nextRoles);
  } catch (requestError) {
    error.value = $t('page.roles.messages.loadFailed');
    showRequestError(
      requestError,
      $t('page.roles.messages.unexpectedError'),
      'Unexpected role page load error:',
    );
  } finally {
    loading.value = false;
    retrying.value = false;
  }
}

async function retry(): Promise<void> {
  retrying.value = true;
  await load();
}

function selectRole(roleId: string): void {
  selectedRoleId.value = roleId;
}

function isSelected(permissionId: string): boolean {
  return selectedDraftIds.value.includes(permissionId);
}

function draftIdsForRole(roleId: string): string[] {
  const draftIds = drafts.value[roleId];
  if (draftIds === undefined) {
    throw new Error(`Missing permission draft for role ${roleId}`);
  }

  return draftIds;
}

function hasRoleChanges(role: Role): boolean {
  return !hasSamePermissionIds(
    role.permissions.map((permission) => permission.id),
    draftIdsForRole(role.id),
  );
}

function setDraftPermissionIds(
  permissionIds: readonly string[],
  selected: boolean,
): void {
  if (selectedRole.value === null || !canEditSelectedRole.value) {
    return;
  }

  const selectedIds = new Set(selectedDraftIds.value);
  for (const permissionId of permissionIds) {
    if (selected) {
      selectedIds.add(permissionId);
    } else {
      selectedIds.delete(permissionId);
    }
  }

  drafts.value[selectedRole.value.id] = [...selectedIds];
}

function togglePermission(permissionId: string): void {
  setDraftPermissionIds([permissionId], !isSelected(permissionId));
}

function idsForResource(resource: (typeof matrix.value)[number]): string[] {
  return Object.values(resource.permissions).flatMap((permission) =>
    permission === undefined ? [] : [permission.id],
  );
}

function idsForAction(action: (typeof CRUD_ACTIONS)[number]): string[] {
  return filteredMatrix.value.flatMap((resource) => {
    const permission = resource.permissions[action];

    return permission === undefined ? [] : [permission.id];
  });
}

function allSelected(permissionIds: readonly string[]): boolean {
  return (
    permissionIds.length > 0 &&
    permissionIds.every((permissionId) => isSelected(permissionId))
  );
}

function isPartiallySelected(permissionIds: readonly string[]): boolean {
  return (
    permissionIds.some((permissionId) => isSelected(permissionId)) &&
    !allSelected(permissionIds)
  );
}

function resetSelectedDraft(): void {
  if (selectedRole.value === null) {
    return;
  }

  drafts.value[selectedRole.value.id] = selectedRole.value.permissions.map(
    (permission) => permission.id,
  );
}

async function saveMatrix(): Promise<void> {
  if (selectedRole.value === null || !canEditSelectedRole.value) {
    return;
  }

  try {
    const updatedRole = await rolesManagementResource.update(
      selectedRole.value.id,
      {
        permission_ids: mergeMatrixPermissionIds(
          selectedRole.value.permissions.map((permission) => permission.id),
          matrix.value,
          selectedDraftIds.value,
        ),
      },
    );
    replaceRole(updatedRole);
    await refreshAuthentication();
    notification.success({ message: $t('page.roles.messages.updated') });
  } catch (requestError) {
    showRequestError(
      requestError,
      $t('page.roles.messages.unexpectedError'),
      'Unexpected role permission update error:',
    );
  }
}

function replaceRole(updatedRole: Role): void {
  roles.value = roles.value.map((role) =>
    role.id === updatedRole.id ? updatedRole : role,
  );
  drafts.value[updatedRole.id] = updatedRole.permissions.map(
    (permission) => permission.id,
  );
}

async function refreshAuthentication(): Promise<void> {
  authStore.setAuthenticatedUser(await getUserInfoApi());
}

onBeforeRouteLeave(() => {
  if (!hasDirtyDrafts.value) {
    return true;
  }

  return new Promise<boolean>((resolve) => {
    Modal.confirm({
      cancelText: $t('page.roles.actions.cancel'),
      content: $t('page.roles.leave.confirm'),
      okText: $t('page.roles.leave.discard'),
      onCancel: () => resolve(false),
      onOk: () => resolve(true),
      title: $t('page.roles.leave.title'),
    });
  });
});

void load();
</script>

<template>
  <main class="flex h-full min-h-0 flex-col gap-4 p-4">
    <header class="flex flex-wrap items-start justify-between gap-3">
      <div>
        <h2 class="m-0 text-lg font-semibold text-foreground">
          {{ $t('page.roles.listTitle') }}
        </h2>
        <p class="m-0 mt-1 text-sm text-muted-foreground">
          {{ $t('page.roles.listDescription') }}
        </p>
      </div>
    </header>

    <div v-if="loading" class="flex min-h-64 items-center justify-center">
      <Spin />
    </div>

    <div
      v-else-if="error !== null"
      class="flex min-h-64 flex-col items-center justify-center gap-3"
    >
      <p class="m-0 text-sm text-destructive">{{ error }}</p>
      <Button :loading="retrying" @click="retry">
        {{ $t('page.roles.actions.retry') }}
      </Button>
    </div>

    <template v-else>
      <div
        :aria-label="$t('page.roles.routeTitle')"
        class="inline-flex w-fit flex-wrap items-center gap-0.5 rounded-lg border border-border bg-muted/60 p-1"
        role="group"
      >
        <button
          v-for="role in roles"
          :key="role.id"
          :aria-pressed="role.id === selectedRoleId"
          class="relative inline-flex h-8 items-center justify-center gap-2 rounded-md border px-3 text-sm font-medium outline-none transition-[color,background-color,border-color,box-shadow] focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background"
          :class="
            role.id === selectedRoleId
              ? [
                  'z-10',
                  'border-border',
                  'bg-background',
                  'text-foreground',
                  'shadow-sm',
                ]
              : [
                  'border-transparent',
                  'text-muted-foreground',
                  'hover:bg-background/60',
                  'hover:text-foreground',
                ]
          "
          type="button"
          @click="selectRole(role.id)"
        >
          <span
            v-if="hasRoleChanges(role)"
            aria-hidden="true"
            class="size-1.5 shrink-0 rounded-full bg-primary"
          ></span>

          <span>{{ role.name }}</span>
        </button>
      </div>

      <section
        v-if="selectedRole !== null"
        class="flex min-h-0 flex-1 flex-col gap-4"
      >
        <div
          v-if="permissionsUnavailable"
          class="rounded border border-border p-4 text-sm text-muted-foreground"
        >
          {{ $t('page.roles.permissionAccessDenied') }}
        </div>

        <template v-else>
          <div class="flex flex-wrap items-center justify-between gap-3">
            <Input
              v-model:value="resourceSearch"
              class="max-w-sm"
              :placeholder="$t('page.roles.filters.resource')"
            >
              <template #prefix>
                <IconifyIcon
                  class="size-4 text-muted-foreground"
                  icon="lucide:search"
                />
              </template>
            </Input>
            <div v-if="hasSelectedRoleChanges" class="flex items-center gap-2">
              <Button
                class="!h-9 border-border bg-card px-3 text-foreground shadow-sm hover:border-primary/50 hover:bg-accent"
                :disabled="!canEditSelectedRole"
                @click="resetSelectedDraft"
              >
                <IconifyIcon icon="lucide:undo-2" class="size-4" />
                {{ $t('page.roles.actions.undo') }}
              </Button>
              <Button
                class="!h-9 !border-blue-600 !bg-blue-600 px-3 !text-white shadow-sm hover:!border-blue-700 hover:!bg-blue-700 disabled:!border-muted disabled:!bg-muted disabled:!text-muted-foreground dark:!border-blue-500 dark:!bg-blue-500 dark:hover:!border-blue-400 dark:hover:!bg-blue-400"
                :disabled="!canEditSelectedRole"
                type="primary"
                @click="saveMatrix"
              >
                <IconifyIcon icon="lucide:save" class="size-4" />
                {{ $t('page.roles.actions.save') }}
              </Button>
            </div>
          </div>

          <div
            class="role-permission-matrix min-h-0 overflow-auto rounded-xl border border-border bg-card shadow-sm"
          >
            <table class="w-full border-separate border-spacing-0 text-sm">
              <thead class="bg-muted/30">
                <tr>
                  <th
                    class="sticky left-0 top-0 z-20 min-w-60 border-b border-border bg-card p-3 text-left"
                  >
                    {{ $t('page.roles.columns.resource') }}
                  </th>
                  <th
                    v-for="action in CRUD_ACTIONS"
                    :key="action"
                    class="sticky top-0 z-10 min-w-24 border-b border-border bg-card p-3 text-center"
                  >
                    <div class="flex flex-col items-center gap-1.5">
                      <span class="text-xs font-semibold">
                        {{ $t(`page.roles.matrixActions.${action}`) }}
                      </span>
                      <Checkbox
                        :checked="allSelected(idsForAction(action))"
                        :indeterminate="
                          isPartiallySelected(idsForAction(action))
                        "
                        :disabled="!canEditSelectedRole"
                        @change="
                          setDraftPermissionIds(
                            idsForAction(action),
                            !allSelected(idsForAction(action)),
                          )
                        "
                      />
                    </div>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="resource in filteredMatrix"
                  :key="resource.resource"
                  class="hover:bg-muted/30"
                >
                  <th
                    class="sticky left-0 z-10 border-b border-border bg-card p-3 text-left font-medium"
                  >
                    <div class="flex items-center gap-2">
                      <Checkbox
                        :checked="allSelected(idsForResource(resource))"
                        :indeterminate="
                          isPartiallySelected(idsForResource(resource))
                        "
                        :disabled="!canEditSelectedRole"
                        @change="
                          setDraftPermissionIds(
                            idsForResource(resource),
                            !allSelected(idsForResource(resource)),
                          )
                        "
                      />
                      <span class="font-semibold">{{
                        resource.displayName
                      }}</span>
                    </div>
                  </th>
                  <td
                    v-for="action in CRUD_ACTIONS"
                    :key="action"
                    class="border-b border-border p-3 text-center"
                  >
                    <div
                      v-if="resource.permissions[action] !== undefined"
                      class="flex justify-center"
                    >
                      <Checkbox
                        :aria-label="
                          $t('page.roles.aria.permission', {
                            action,
                            resource: resource.displayName,
                          })
                        "
                        :checked="isSelected(resource.permissions[action].id)"
                        :disabled="!canEditSelectedRole"
                        @change="
                          togglePermission(resource.permissions[action].id)
                        "
                      />
                    </div>
                    <span v-else aria-hidden="true">—</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </template>
      </section>
    </template>
  </main>
</template>

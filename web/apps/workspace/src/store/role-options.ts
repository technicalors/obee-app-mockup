import type { Role } from '#/api';

import { ref } from 'vue';

import { acceptHMRUpdate, defineStore } from 'pinia';

import { rolesResource } from '#/api/roles';

export const useRoleOptionsStore = defineStore('role-options', () => {
  const roles = ref<readonly Role[]>([]);
  const loading = ref(false);
  const loaded = ref(false);
  let pendingRequest: null | Promise<readonly Role[]> = null;

  async function refresh(): Promise<readonly Role[]> {
    loading.value = true;

    try {
      const nextRoles = await rolesResource.getAll();
      roles.value = nextRoles;
      loaded.value = true;

      return roles.value;
    } finally {
      loading.value = false;
      pendingRequest = null;
    }
  }

  async function loadOnce(): Promise<readonly Role[]> {
    if (loaded.value) {
      return roles.value;
    }

    pendingRequest ??= refresh();

    return pendingRequest;
  }

  function $reset(): void {
    roles.value = [];
    loading.value = false;
    loaded.value = false;
    pendingRequest = null;
  }

  return {
    $reset,
    loaded,
    loading,
    loadOnce,
    refresh,
    roles,
  };
});

const hot = import.meta.hot;
if (hot) {
  hot.accept(acceptHMRUpdate(useRoleOptionsStore, hot));
}

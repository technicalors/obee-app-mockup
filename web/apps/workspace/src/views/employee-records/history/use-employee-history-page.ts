import type { User } from '#/api';

import { ref } from 'vue';

import { usersResource } from '#/api';

export function useEmployeeHistoryPage() {
  const selectedUser = ref<null | User>(null);
  const isLoading = ref(false);

  async function selectUser(id: string): Promise<void> {
    isLoading.value = true;
    try {
      selectedUser.value = await usersResource.getById(id);
    } finally {
      isLoading.value = false;
    }
  }

  function clearUser(): void {
    selectedUser.value = null;
  }

  return {
    clearUser,
    isLoading,
    selectUser,
    selectedUser,
  };
}

import type { User } from '#/api';

import { computed, ref } from 'vue';

import { useUserStore } from '@vben/stores';

import { getNotificationRecipientsApi } from '#/api';

export function useColleagues() {
  const userStore = useUserStore();
  const colleagues = ref<User[]>([]);
  const isLoadingColleagues = ref(false);

  const selectableColleagues = computed(() => {
    const myUsername = userStore.userInfo?.username?.toLowerCase();
    return colleagues.value.filter(
      (c) => c.username?.toLowerCase() !== myUsername,
    );
  });

  async function fetchColleagues(): Promise<void> {
    isLoadingColleagues.value = true;
    try {
      colleagues.value = await getNotificationRecipientsApi();
    } finally {
      isLoadingColleagues.value = false;
    }
  }

  return {
    colleagues,
    fetchColleagues,
    isLoadingColleagues,
    selectableColleagues,
  };
}

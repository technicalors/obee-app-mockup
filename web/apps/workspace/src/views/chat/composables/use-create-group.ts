import type { User } from '#/api';

import { ref } from 'vue';

import { useChatStore } from '#/store';

export function useCreateGroup(
  colleagues: { value: User[] },
  fetchColleagues: () => Promise<void>,
  onGroupCreated?: (roomId: string) => void,
) {
  const store = useChatStore();

  const isGroupModalOpen = ref(false);
  const isSubmittingGroup = ref(false);

  async function openCreateGroupModal(): Promise<void> {
    isGroupModalOpen.value = true;

    if (colleagues.value.length === 0) {
      await fetchColleagues();
    }
  }

  async function handleCreateGroup(
    name: string,
    selectedUserIds: string[],
  ): Promise<void> {
    if (!name || selectedUserIds.length === 0 || isSubmittingGroup.value) {
      return;
    }

    const inviteMatrixIds = selectedUserIds.map((userId) => {
      const user = colleagues.value.find(
        (colleague) => colleague.id === userId,
      );
      if (!user) {
        throw new Error(`Selected colleague ${userId} was not found.`);
      }

      if (!user.matrix_user_id) {
        throw new Error(`Selected colleague ${userId} has not activated chat.`);
      }

      return user.matrix_user_id;
    });

    isSubmittingGroup.value = true;
    try {
      const roomId = await store.createGroupChat(name, inviteMatrixIds);
      isGroupModalOpen.value = false;
      onGroupCreated?.(roomId);
    } finally {
      isSubmittingGroup.value = false;
    }
  }

  return {
    handleCreateGroup,
    isGroupModalOpen,
    isSubmittingGroup,
    openCreateGroupModal,
  };
}

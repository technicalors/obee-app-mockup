import type { ComponentPublicInstance } from 'vue';

import { computed, onMounted, ref } from 'vue';

import { storeToRefs } from 'pinia';

import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useChatStore } from '#/store';

import { useChatSession } from './use-chat-session';
import { formatHeaderTypingText } from './use-chat-typing';
import { useColleagues } from './use-colleagues';
import { useConversations } from './use-conversations';
import { useCreateGroup } from './use-create-group';

type ChatMessagesExpose = ComponentPublicInstance & {
  scrollToBottom: () => void;
  scrollToMessage: (eventId: string) => void;
};

interface GroupSubmitPayload {
  name: string;
  userIds: string[];
}

type GroupAction = 'delete' | 'leave';

export function useChatPage() {
  const store = useChatStore();
  const {
    activeRoomId,
    activeRoomMembers,
    activeTypingUsers,
    activeRemovableMemberIds,
    canDeleteActiveGroup,
    canInviteActiveRoomMembers,
    canPinActiveRoomMessages,
    currentUserId,
    hasMoreHistory,
    isInitializing,
    isLoadingMessages,
    isLoadingOlder,
    isReady,
    messages,
    pinnedEventIds,
    pinnedMessages,
    rooms,
    activeRoom,
    cryptoStatus,
    cryptoError,
    recoveryError,
    recoveryKey,
    isRecoveryActionLoading,
    uploadProgress,
  } = storeToRefs(store);
  const messagesRef = ref<ChatMessagesExpose | null>(null);
  const groupAction = ref<GroupAction | null>(null);
  const isMemberActionLoading = ref(false);
  const removingMemberId = ref<null | string>(null);

  const {
    colleagues,
    fetchColleagues,
    isLoadingColleagues,
    selectableColleagues,
  } = useColleagues();
  const { allConversations, displayedConversations, searchQuery } =
    useConversations(selectableColleagues, rooms, colleagues);
  const chatSession = useChatSession(
    allConversations,
    () => {
      messagesRef.value?.scrollToBottom();
    },
    colleagues,
  );
  const {
    handleCreateGroup,
    isGroupModalOpen,
    isSubmittingGroup,
    openCreateGroupModal,
  } = useCreateGroup(colleagues, fetchColleagues, (newRoomId) => {
    chatSession.selectedConversationId.value = newRoomId;
  });

  const { loadOlderMessages } = store;

  function handleJumpToMessage(eventId: string): void {
    messagesRef.value?.scrollToMessage(eventId);
  }

  function handleNextMatch(): void {
    const targetId = chatSession.nextMatch();
    if (targetId) {
      handleJumpToMessage(targetId);
    }
  }

  function handlePrevMatch(): void {
    const targetId = chatSession.prevMatch();
    if (targetId) {
      handleJumpToMessage(targetId);
    }
  }

  async function handleGroupSubmit({
    name,
    userIds,
  }: GroupSubmitPayload): Promise<void> {
    try {
      await handleCreateGroup(name, userIds);
    } catch (error) {
      showRequestError(
        error,
        $t('chat.groupActionError'),
        'Failed to create chat group:',
      );
    }
  }

  async function handleInviteMember(userId: string): Promise<void> {
    const roomId = activeRoomId.value;
    if (!roomId || isMemberActionLoading.value) return;

    isMemberActionLoading.value = true;
    try {
      await store.inviteRoomMember(roomId, userId);
    } catch (error) {
      showRequestError(
        error,
        $t('chat.memberActionError'),
        'Failed to invite chat member:',
      );
    } finally {
      isMemberActionLoading.value = false;
    }
  }

  async function handleRemoveMember(userId: string): Promise<void> {
    const roomId = activeRoomId.value;
    if (!roomId || isMemberActionLoading.value) return;

    isMemberActionLoading.value = true;
    removingMemberId.value = userId;
    try {
      await store.removeRoomMember(roomId, userId);
    } catch (error) {
      showRequestError(
        error,
        $t('chat.memberActionError'),
        'Failed to remove chat member:',
      );
    } finally {
      isMemberActionLoading.value = false;
      removingMemberId.value = null;
    }
  }

  async function handleGroupAction(action: GroupAction): Promise<void> {
    const roomId = activeRoomId.value;
    if (!roomId || isMemberActionLoading.value || groupAction.value !== null) {
      return;
    }

    isMemberActionLoading.value = true;
    groupAction.value = action;
    try {
      await (action === 'leave'
        ? store.leaveGroup(roomId)
        : store.deleteGroup(roomId));
      chatSession.selectedConversationId.value = null;
    } catch (error) {
      showRequestError(
        error,
        $t('chat.groupActionError'),
        action === 'leave'
          ? 'Failed to leave chat group:'
          : 'Failed to delete chat group:',
      );
    } finally {
      isMemberActionLoading.value = false;
      groupAction.value = null;
    }
  }

  async function handleLeaveGroup(): Promise<void> {
    await handleGroupAction('leave');
  }

  async function handleDeleteGroup(): Promise<void> {
    await handleGroupAction('delete');
  }

  const isMinDelayActive = ref(true);

  const isRecoveryModalOpen = computed(
    () =>
      cryptoStatus.value === 'setup-required' ||
      cryptoStatus.value === 'recovery-required',
  );
  const recoveryMode = computed(() =>
    cryptoStatus.value === 'setup-required' ? 'setup' : 'restore',
  );
  const isComposerDisabled = computed(
    () =>
      !store.isCryptoReady ||
      chatSession.isActiveConversationUnavailable.value ||
      (activeRoomId.value !== null &&
        activeRoom.value?.encryptionStatus !== 'encrypted'),
  );

  async function handleRecoverySetup(): Promise<void> {
    try {
      await store.setupRecovery();
    } catch (error) {
      console.error('Failed to set up Matrix recovery:', error);
    }
  }

  async function handleRecoveryRestore(key: string): Promise<void> {
    try {
      await store.restoreFromRecoveryKey(key);
    } catch (error) {
      console.error('Failed to restore Matrix recovery:', error);
    }
  }

  async function handleDownloadAttachment(
    messageId: string,
    attachmentIndex: number,
  ): Promise<void> {
    try {
      await store.downloadAttachment(messageId, attachmentIndex);
    } catch (error) {
      showRequestError(
        error,
        $t('chat.encryption.decryptionFailed'),
        'Failed to download encrypted attachment:',
      );
    }
  }

  const isSidebarLoading = computed(() => {
    return (
      isLoadingColleagues.value ||
      isInitializing.value ||
      !isReady.value ||
      isMinDelayActive.value
    );
  });

  const headerTypingText = computed(() =>
    formatHeaderTypingText(
      activeTypingUsers.value,
      chatSession.isCurrentChatDirect.value,
    ),
  );

  onMounted(() => {
    setTimeout(() => {
      isMinDelayActive.value = false;
    }, 1000);
    void store.initialize();
    void fetchColleagues();
  });

  return {
    ...chatSession,
    activeAvatarUrl: chatSession.activeAvatarUrl,
    activeRoom,
    activeRoomId,
    activeRoomMembers,
    activeRemovableMemberIds,
    activeTypingUsers,
    headerTypingText,
    canDeleteActiveGroup,
    canInviteActiveRoomMembers,
    canPinActiveRoomMessages,
    colleagues,
    createDirectChat: store.createDirectChat,
    currentUserId,
    displayedConversations,
    handleGroupSubmit,
    handleInviteMember,
    handleDeleteGroup,
    handleLeaveGroup,
    handleJumpToMessage,
    handleNextMatch,
    handlePrevMatch,
    handleRemoveMember,
    handleRecoveryRestore,
    handleRecoverySetup,
    isComposerDisabled,
    hasMoreHistory,
    ensureMessageLoaded: store.ensureMessageLoaded,
    isGroupModalOpen,
    isInitializing,
    isLoadingColleagues,
    isLoadingMessages,
    isLoadingOlder,
    isMemberActionLoading,
    isRecoveryActionLoading,
    isRecoveryModalOpen,
    recoveryError,
    recoveryKey,
    recoveryMode,
    isReady,
    isSidebarLoading,
    isSubmittingGroup,
    loadOlderMessages,
    messages,
    messagesRef,
    openCreateGroupModal,
    pinnedEventIds,
    pinnedMessages,
    groupAction,
    removingMemberId,
    searchQuery,
    selectableColleagues,
    cryptoStatus,
    cryptoError,
    downloadAttachment: handleDownloadAttachment,
    uploadProgress,
  };
}

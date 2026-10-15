import type { Ref } from 'vue';

import type {
  ConversationItem,
  GroupMemberAvatarInfo,
  PendingColleague,
} from '../types';

import type { User } from '#/api';
import type { ChatMessageItem } from '#/store';

import { computed, ref, watch } from 'vue';

import { $t } from '#/locales';
import { resolveChatUserDisplayName, useChatStore } from '#/store';
import { getUserAvatarSource } from '#/views/users/avatar';

import { findColleagueByMatrixId } from './use-conversations';

export function useChatSession(
  allConversations: Ref<ConversationItem[]>,
  onMessageSent?: () => void,
  colleagues?: Ref<User[]>,
) {
  const store = useChatStore();

  const selectedConversationId = ref<null | string>(null);
  const pendingColleague = ref<null | PendingColleague>(null);
  const isSending = ref(false);
  const failedFiles = ref<File[]>([]);
  const sendFilesError = ref(false);

  // 1. Reply State
  const replyingTo = ref<ChatMessageItem | null>(null);

  function startReply(msg: ChatMessageItem): void {
    if (msg.isRedacted) return;
    const colleague = findColleagueByMatrixId(
      msg.senderId,
      colleagues?.value ?? [],
    );
    replyingTo.value = {
      ...msg,
      senderName: resolveChatUserDisplayName(
        msg.senderId,
        [colleague?.name, msg.senderName],
        $t('chat.unknownUser'),
      ),
    };
  }

  function cancelReply(): void {
    replyingTo.value = null;
  }

  // 2. In-Room Search State
  const isSearchOpen = ref(false);
  const inRoomSearchQuery = ref('');
  const currentMatchIndex = ref(0);

  function toggleSearch(): void {
    isSearchOpen.value = !isSearchOpen.value;
    if (!isSearchOpen.value) {
      inRoomSearchQuery.value = '';
      currentMatchIndex.value = 0;
    }
  }

  function closeSearch(): void {
    isSearchOpen.value = false;
    inRoomSearchQuery.value = '';
    currentMatchIndex.value = 0;
  }

  const searchMatchingIds = computed<string[]>(() => {
    const q = inRoomSearchQuery.value.trim().toLowerCase();
    if (!q) return [];
    return store.messages
      .filter((m) => !m.isRedacted && m.body.toLowerCase().includes(q))
      .map((m) => m.id);
  });

  watch(
    () => searchMatchingIds.value.length,
    (len) => {
      if (len === 0) {
        currentMatchIndex.value = 0;
      } else if (currentMatchIndex.value >= len) {
        currentMatchIndex.value = 0;
      }
    },
  );

  function nextMatch(): string | undefined {
    if (searchMatchingIds.value.length === 0) return undefined;
    currentMatchIndex.value =
      (currentMatchIndex.value + 1) % searchMatchingIds.value.length;
    return searchMatchingIds.value[currentMatchIndex.value];
  }

  function prevMatch(): string | undefined {
    if (searchMatchingIds.value.length === 0) return undefined;
    currentMatchIndex.value =
      (currentMatchIndex.value - 1 + searchMatchingIds.value.length) %
      searchMatchingIds.value.length;
    return searchMatchingIds.value[currentMatchIndex.value];
  }

  const isChatActive = computed(() => {
    return store.activeRoomId !== null || pendingColleague.value !== null;
  });

  const isActiveConversationUnavailable = computed(() => {
    if (pendingColleague.value) {
      return !pendingColleague.value.targetMatrixUserId;
    }

    const activeConversation = allConversations.value.find(
      (conversation) =>
        conversation.id === selectedConversationId.value ||
        conversation.roomId === store.activeRoomId,
    );

    return Boolean(
      activeConversation?.user && !activeConversation.targetMatrixUserId,
    );
  });

  const activeChatTitle = computed(() => {
    if (pendingColleague.value) return pendingColleague.value.name;
    if (store.activeRoomId) {
      const item = allConversations.value.find(
        (c) => c.roomId === store.activeRoomId,
      );
      if (item) return item.name;
    }
    if (store.activeRoom) {
      return resolveChatUserDisplayName(
        store.activeRoom.directUserId ?? '',
        [store.activeRoom.name],
        $t('chat.unknownUser'),
      );
    }
    return '';
  });

  const activeAvatarUrl = computed(() => {
    const activeRoomId = store.activeRoomId;
    return allConversations.value.find(
      (conversation) =>
        conversation.id === selectedConversationId.value ||
        conversation.roomId === activeRoomId,
    )?.avatarUrl;
  });

  const isCurrentChatDirect = computed(() => {
    if (pendingColleague.value) return true;
    if (store.activeRoom) return store.activeRoom.isDirect;
    if (store.activeRoomId) {
      const item = allConversations.value.find(
        (c) => c.roomId === store.activeRoomId,
      );
      if (item) return item.isDirect;
    }
    return false;
  });

  const activeMemberCount = computed(() => {
    if (pendingColleague.value) return 2;
    if (store.activeRoomMembers.length > 0) {
      return store.activeRoomMembers.length;
    }
    if (store.activeRoom) return store.activeRoom.memberCount;
    return 2;
  });

  const activeGroupMemberAvatars = computed<GroupMemberAvatarInfo[]>(() => {
    if (isCurrentChatDirect.value) return [];

    const colleagueList = colleagues?.value ?? [];

    if (store.activeRoomMembers.length > 0) {
      return store.activeRoomMembers.map((m) => {
        const colleague = findColleagueByMatrixId(m.userId, colleagueList);
        return {
          avatarUrl: colleague ? getUserAvatarSource(colleague) : m.avatarUrl,
          displayName: resolveChatUserDisplayName(
            m.userId,
            [colleague?.name, m.displayName],
            $t('chat.unknownUser'),
          ),
          userId: m.userId,
        };
      });
    }

    const currentConversation = allConversations.value.find(
      (c) =>
        c.id === selectedConversationId.value ||
        c.roomId === store.activeRoomId,
    );
    if (currentConversation?.groupMemberAvatars) {
      return currentConversation.groupMemberAvatars;
    }

    return [];
  });

  async function selectConversation(item: ConversationItem): Promise<void> {
    selectedConversationId.value = item.id;
    replyingTo.value = null;
    closeSearch();

    if (item.roomId) {
      pendingColleague.value = null;
      await store.selectRoom(item.roomId);
    } else if (item.user) {
      store.clearActiveRoom();
      pendingColleague.value = {
        name: item.name,
        targetMatrixUserId: item.targetMatrixUserId,
        user: item.user,
      };
    }
  }

  async function handleRedactMessage(msg: ChatMessageItem): Promise<void> {
    const roomId = store.activeRoomId;
    if (!roomId) return;
    if (replyingTo.value?.id === msg.id) {
      cancelReply();
    }
    await store.redactMessage(roomId, msg.id);
  }

  async function handleSendMessage(text: string): Promise<boolean> {
    const trimmed = text.trim();
    if (!trimmed || isSending.value || isActiveConversationUnavailable.value) {
      return false;
    }

    isSending.value = true;
    const replyTargetId = replyingTo.value?.id;

    try {
      if (!store.activeRoomId && pendingColleague.value) {
        const colleague = pendingColleague.value;
        const targetMatrixUserId = colleague.targetMatrixUserId;
        if (!targetMatrixUserId) return false;
        const newRoomId = await store.createDirectChat(targetMatrixUserId);
        selectedConversationId.value = newRoomId;
        pendingColleague.value = null;
        await store.sendMessage(trimmed, replyTargetId);
      } else if (store.activeRoomId) {
        await store.sendMessage(trimmed, replyTargetId);
      }
      replyingTo.value = null;
      onMessageSent?.();
      return true;
    } catch (error) {
      console.error('Failed to send message:', error);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  async function handleSendFiles(files: File[]): Promise<boolean> {
    if (
      files.length === 0 ||
      isSending.value ||
      isActiveConversationUnavailable.value
    ) {
      return false;
    }

    isSending.value = true;
    sendFilesError.value = false;
    try {
      if (!store.activeRoomId && pendingColleague.value) {
        const colleague = pendingColleague.value;
        const targetMatrixUserId = colleague.targetMatrixUserId;
        if (!targetMatrixUserId) return false;
        const newRoomId = await store.createDirectChat(targetMatrixUserId);
        selectedConversationId.value = newRoomId;
        pendingColleague.value = null;
      }

      for (const [index, file] of files.entries()) {
        try {
          await store.sendAttachment(file);
        } catch (error) {
          failedFiles.value = files.slice(index);
          throw error;
        }
      }

      failedFiles.value = [];
      replyingTo.value = null;
      onMessageSent?.();
      return true;
    } catch (error) {
      failedFiles.value = files;
      sendFilesError.value = true;
      console.error('Failed to send encrypted files:', error);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  async function handleRetryFiles(): Promise<boolean> {
    const files = failedFiles.value;
    if (files.length === 0) return false;
    return handleSendFiles(files);
  }

  function handleToggleReaction(msg: ChatMessageItem, emoji: string): void {
    void store.toggleReaction(msg.id, emoji);
  }

  function handleTyping(isTyping: boolean): void {
    void store.sendTyping(isTyping);
  }

  function handleMarkAsRead(): void {
    void store.markRoomAsRead();
  }

  return {
    activeAvatarUrl,
    activeChatTitle,
    activeGroupMemberAvatars,
    activeMemberCount,
    cancelReply,
    closeSearch,
    currentMatchIndex,
    handleMarkAsRead,
    handleRedactMessage,
    handleRetryFiles,
    handleSendFiles,
    handleSendMessage,
    handleToggleReaction,
    handleTyping,
    inRoomSearchQuery,
    isChatActive,
    isActiveConversationUnavailable,
    isCurrentChatDirect,
    isSearchOpen,
    isSending,
    nextMatch,
    pendingColleague,
    prevMatch,
    replyingTo,
    searchMatchingIds,
    sendFilesError,
    selectConversation,
    selectedConversationId,
    startReply,
    toggleSearch,
  };
}

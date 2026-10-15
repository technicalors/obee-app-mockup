<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue';

import { Page } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import { Alert, Empty, Spin } from 'ant-design-vue';

import { $t } from '#/locales';

import {
  ChatComposer,
  ChatFilePreviewModal,
  ChatHeader,
  ChatInfoPanel,
  ChatMessages,
  ChatSidebar,
  CreateGroupModal,
  GroupMembersModal,
  MatrixRecoveryKeyPreviewModal,
} from './components';
import { useChatPage } from './composables';

const INFO_PANEL_COLLAPSE_WIDTH = 1280;
const SIDEBAR_COLLAPSE_WIDTH = 900;

const isSidebarCollapsed = ref(false);
const isInfoPanelOpen = ref(true);
const isMembersModalOpen = ref(false);
const chatDragDepth = ref(0);
const isChatDropActive = ref(false);

function handleResponsiveLayout(): void {
  if (window.innerWidth < INFO_PANEL_COLLAPSE_WIDTH) {
    isInfoPanelOpen.value = false;
  }
  if (window.innerWidth < SIDEBAR_COLLAPSE_WIDTH) {
    isSidebarCollapsed.value = true;
  }
}

function isFileDrag(event: DragEvent): boolean {
  return event.dataTransfer?.types.includes('Files') ?? false;
}

function handleChatDragEnter(event: DragEvent): void {
  if (!isFileDrag(event)) return;
  event.preventDefault();
  if (!isChatActive.value || isComposerDisabled.value || isSending.value) {
    return;
  }
  chatDragDepth.value += 1;
  isChatDropActive.value = true;
}

function handleChatDragOver(event: DragEvent): void {
  if (!isFileDrag(event)) return;
  event.preventDefault();
  if (!isChatActive.value || isComposerDisabled.value || isSending.value) {
    return;
  }
  if (event.dataTransfer) {
    event.dataTransfer.dropEffect = 'copy';
  }
}

function handleChatDragLeave(event: DragEvent): void {
  if (!isFileDrag(event)) return;
  event.preventDefault();
  chatDragDepth.value = Math.max(0, chatDragDepth.value - 1);
  if (chatDragDepth.value === 0) {
    isChatDropActive.value = false;
  }
}

function handleChatDrop(event: DragEvent): void {
  if (!isFileDrag(event)) return;
  event.preventDefault();
  chatDragDepth.value = 0;
  isChatDropActive.value = false;
  if (!isChatActive.value || isComposerDisabled.value || isSending.value) {
    return;
  }

  const files = [...(event.dataTransfer?.files ?? [])];
  if (files.length > 0) {
    void handleSendFiles(files);
  }
}

onMounted(() => {
  handleResponsiveLayout();
  window.addEventListener('resize', handleResponsiveLayout);
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResponsiveLayout);
});

const {
  activeAvatarUrl,
  activeChatTitle,
  activeGroupMemberAvatars,
  activeMemberCount,
  activeRemovableMemberIds,
  activeRoom,
  activeRoomId,
  activeRoomMembers,
  activeTypingUsers,
  canDeleteActiveGroup,
  canPinActiveRoomMessages,
  cancelReply,
  closeSearch,
  colleagues,
  createDirectChat,
  currentMatchIndex,
  currentUserId,
  cryptoError,
  displayedConversations,
  canInviteActiveRoomMembers,
  downloadAttachment,
  ensureMessageLoaded,
  handleGroupSubmit,
  handleJumpToMessage,
  handleMarkAsRead,
  handleNextMatch,
  handlePrevMatch,
  handleRedactMessage,
  handleDeleteGroup,
  handleInviteMember,
  handleLeaveGroup,
  handleRemoveMember,
  handleRecoveryRestore,
  handleRecoverySetup,
  handleRetryFiles,
  handleSendFiles,
  handleSendMessage,
  handleToggleReaction,
  handleTyping,
  hasMoreHistory,
  headerTypingText,
  inRoomSearchQuery,
  isChatActive,
  isCurrentChatDirect,
  isGroupModalOpen,
  isInitializing,
  isLoadingColleagues,
  isLoadingMessages,
  isLoadingOlder,
  isMemberActionLoading,
  isComposerDisabled,
  isActiveConversationUnavailable,
  isRecoveryActionLoading,
  isRecoveryModalOpen,
  recoveryError,
  recoveryKey,
  recoveryMode,
  isReady,
  isSearchOpen,
  isSending,
  isSidebarLoading,
  isSubmittingGroup,
  loadOlderMessages,
  messages,
  messagesRef,
  pinnedEventIds,
  pinnedMessages,
  openCreateGroupModal,
  groupAction,
  removingMemberId,
  replyingTo,
  searchMatchingIds,
  searchQuery,
  selectableColleagues,
  selectConversation,
  selectedConversationId,
  startReply,
  toggleSearch,
  uploadProgress,
  sendFilesError,
} = useChatPage();

async function handleStartDirectChat(targetUserId: string): Promise<void> {
  isMembersModalOpen.value = false;
  const directRoomId = await createDirectChat(targetUserId);
  if (directRoomId) {
    const conversation = displayedConversations.value.find(
      (c) => c.roomId === directRoomId || c.id === directRoomId,
    );
    if (conversation) {
      await selectConversation(conversation);
    }
  }
}

void messagesRef;
</script>

<template>
  <Page
    auto-content-height
    content-class="relative h-full min-h-0 min-w-0 w-full overflow-hidden p-0"
  >
    <div class="flex h-full min-h-0 min-w-0 w-full overflow-hidden bg-card">
      <ChatSidebar
        :is-collapsed="isSidebarCollapsed"
        :loading="isSidebarLoading"
        v-model:search-query="searchQuery"
        :conversations="displayedConversations"
        :active-room-id="activeRoomId"
        :selected-conversation-id="selectedConversationId"
        @open-create-group="openCreateGroupModal"
        @select="selectConversation"
        @update:collapsed="isSidebarCollapsed = $event"
      />

      <main
        class="relative flex min-h-0 min-w-0 flex-1 flex-col overflow-hidden bg-slate-100 dark:bg-background"
        data-testid="chat-dropzone"
        :class="
          isChatDropActive
            ? 'ring-2 ring-inset ring-primary/50 transition-shadow'
            : ''
        "
        @dragenter="handleChatDragEnter"
        @dragleave="handleChatDragLeave"
        @dragover="handleChatDragOver"
        @drop="handleChatDrop"
      >
        <Transition
          enter-active-class="transition duration-200 ease-out"
          enter-from-class="scale-95 opacity-0"
          enter-to-class="scale-100 opacity-100"
          leave-active-class="transition duration-150 ease-in"
          leave-from-class="scale-100 opacity-100"
          leave-to-class="scale-95 opacity-0"
        >
          <div
            v-if="isChatDropActive"
            aria-live="polite"
            class="pointer-events-none absolute inset-0 z-20 flex items-center justify-center bg-primary/10 backdrop-blur-[2px]"
            data-testid="chat-drop-overlay"
            role="status"
          >
            <div
              class="flex flex-col items-center gap-2 rounded-xl bg-background/90 px-5 py-4 text-center text-primary shadow-lg"
            >
              <div
                class="relative flex size-14 items-center justify-center rounded-full bg-primary/10"
              >
                <span
                  class="absolute inset-0 animate-ping rounded-full bg-primary/20"
                ></span>
                <IconifyIcon
                  icon="lucide:upload-cloud"
                  class="relative size-7"
                />
              </div>
              <span class="text-sm font-semibold">
                {{ $t('chat.dropFileToSend') }}
              </span>
            </div>
          </div>
        </Transition>

        <ChatHeader
          :is-empty="!isChatActive"
          :is-sidebar-collapsed="isSidebarCollapsed"
          :is-info-panel-open="isInfoPanelOpen"
          v-model:search-query="inRoomSearchQuery"
          :avatar-url="activeAvatarUrl"
          :group-member-avatars="activeGroupMemberAvatars"
          :title="isChatActive ? activeChatTitle : $t('chat.title')"
          :is-direct="isChatActive && isCurrentChatDirect"
          :member-count="isChatActive ? activeMemberCount : 0"
          :is-search-open="isSearchOpen"
          :search-match-count="searchMatchingIds.length"
          :current-match-index="currentMatchIndex"
          :encryption-status="activeRoom?.encryptionStatus"
          :typing-text="headerTypingText"
          @toggle-search="toggleSearch"
          @close-search="closeSearch"
          @next-match="handleNextMatch"
          @prev-match="handlePrevMatch"
          @jump-to-message="handleJumpToMessage"
          @toggle-sidebar="isSidebarCollapsed = !isSidebarCollapsed"
          @toggle-info-panel="isInfoPanelOpen = !isInfoPanelOpen"
          @open-members="isMembersModalOpen = true"
        />

        <Alert
          v-if="cryptoError"
          class="mx-3 mt-3 shrink-0"
          :message="$t(`chat.encryption.errors.${cryptoError}`)"
          type="error"
          show-icon
        />

        <Alert
          v-if="isActiveConversationUnavailable"
          class="mx-3 mt-3 shrink-0"
          :message="$t('chat.userNotActivatedHint')"
          type="warning"
          show-icon
        />

        <div
          v-if="isInitializing && !isReady"
          class="flex flex-1 flex-col items-center justify-center gap-3 p-8 text-muted-foreground"
        >
          <Spin size="large" :tip="$t('chat.connecting')" />
        </div>

        <template v-else-if="isChatActive">
          <ChatMessages
            ref="messagesRef"
            :messages="messages"
            :can-pin-messages="canPinActiveRoomMessages"
            :colleagues="selectableColleagues"
            :avatar-url="activeAvatarUrl"
            :group-member-avatars="activeGroupMemberAvatars"
            :member-count="activeMemberCount"
            :is-direct="isCurrentChatDirect"
            :is-loading-messages="isLoadingMessages"
            :search-query="isSearchOpen ? inRoomSearchQuery : ''"
            :is-loading-older="isLoadingOlder"
            :has-more-history="hasMoreHistory"
            :pinned-event-ids="pinnedEventIds"
            :pinned-messages="pinnedMessages"
            :typing-users="activeTypingUsers"
            :ensure-message-loaded="ensureMessageLoaded"
            :download-attachment="downloadAttachment"
            @load-more="loadOlderMessages"
            @reply="startReply"
            @redact="handleRedactMessage"
            @toggle-reaction="handleToggleReaction"
          />

          <ChatComposer
            :is-sending="isSending"
            :is-disabled="isComposerDisabled"
            :send-files-error="sendFilesError"
            :upload-progress="uploadProgress"
            :replying-to="replyingTo"
            @read="handleMarkAsRead"
            @send="handleSendMessage"
            @send-files="handleSendFiles"
            @retry-upload="handleRetryFiles"
            @cancel-reply="cancelReply"
            @typing="handleTyping"
          />
        </template>

        <div
          v-else
          class="flex min-h-0 flex-1 flex-col items-center justify-center bg-background p-8 text-center bg-muted/35 dark:bg-card/20"
        >
          <Empty
            :image="Empty.PRESENTED_IMAGE_SIMPLE"
            :description="$t('chat.emptyRoom')"
          >
            <template #description>
              <div class="space-y-1">
                <h3 class="text-sm font-semibold text-foreground">
                  {{ $t('chat.emptyRoom') }}
                </h3>
                <p class="mx-auto max-w-xs text-xs text-muted-foreground">
                  {{ $t('chat.emptyRoomDescription') }}
                </p>
              </div>
            </template>
          </Empty>
        </div>
      </main>

      <ChatInfoPanel
        v-if="isChatActive"
        :is-open="isInfoPanelOpen"
        :title="activeChatTitle"
        :avatar-url="activeAvatarUrl"
        :group-member-avatars="activeGroupMemberAvatars"
        :is-direct="isCurrentChatDirect"
        :member-count="activeMemberCount"
        :colleagues="selectableColleagues"
        :can-delete-group="canDeleteActiveGroup"
        :group-action="groupAction"
        :is-member-action-loading="isMemberActionLoading"
        :has-more-history="hasMoreHistory"
        :is-loading-older="isLoadingOlder"
        :load-older-messages="loadOlderMessages"
        :messages="messages"
        :room-id="activeRoomId"
        :download-attachment="downloadAttachment"
        @close="isInfoPanelOpen = false"
        @create-group="openCreateGroupModal"
        @delete-group="handleDeleteGroup"
        @leave-group="handleLeaveGroup"
        @open-members="isMembersModalOpen = true"
      />
    </div>

    <CreateGroupModal
      v-model:open="isGroupModalOpen"
      :colleagues="selectableColleagues"
      :is-loading-colleagues="isLoadingColleagues"
      :is-submitting="isSubmittingGroup"
      @submit="handleGroupSubmit"
    />

    <GroupMembersModal
      v-model:open="isMembersModalOpen"
      :room-title="activeChatTitle"
      :members="activeRoomMembers"
      :colleagues="colleagues"
      :current-user-id="currentUserId"
      :can-invite-members="canInviteActiveRoomMembers"
      :is-adding-member="isMemberActionLoading && !removingMemberId"
      :removable-member-ids="activeRemovableMemberIds"
      :removing-member-id="removingMemberId"
      @invite-member="handleInviteMember"
      @remove-member="handleRemoveMember"
      @direct-chat="handleStartDirectChat"
    />

    <MatrixRecoveryKeyPreviewModal
      :open="isRecoveryModalOpen"
      :mode="recoveryMode"
      :recovery-key="recoveryKey"
      :error="recoveryError"
      :loading="isRecoveryActionLoading"
      @setup="handleRecoverySetup"
      @restore="handleRecoveryRestore"
    />

    <ChatFilePreviewModal />
  </Page>
</template>

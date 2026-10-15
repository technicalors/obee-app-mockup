import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { createApp, nextTick } from 'vue';

import { describe, expect, it } from 'vitest';

import ChatGroupAvatar from './components/chat-group-avatar.vue';
import {
  extractUrls,
  getDomainFromUrl,
  parseMessageSegments,
} from './composables/use-chat-links';
import {
  CHAT_REACTION_EMOJIS,
  formatReactionTooltip,
  QUICK_LIKE_EMOJI,
} from './composables/use-chat-reactions';
import {
  formatHeaderTypingText,
  formatTypingIndicatorText,
} from './composables/use-chat-typing';
import { detectFileType, useFilePreview } from './composables/use-file-preview';

const chatViewSource = readFileSync(
  resolve(process.cwd(), 'apps/workspace/src/views/chat/index.vue'),
  'utf8',
);

const chatSidebarSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/chat-sidebar.vue',
  ),
  'utf8',
);

const chatHeaderSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/chat-header.vue',
  ),
  'utf8',
);

const chatMessagesSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/chat-messages.vue',
  ),
  'utf8',
);

const chatMessageActionsSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/chat-message-actions.vue',
  ),
  'utf8',
);

const chatComposerSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/chat-composer.vue',
  ),
  'utf8',
);

const chatConversationsSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/composables/use-conversations.ts',
  ),
  'utf8',
);

const createGroupSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/composables/use-create-group.ts',
  ),
  'utf8',
);

const createGroupModalSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/create-group-modal.vue',
  ),
  'utf8',
);

const chatInfoPanelSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/chat-info-panel.vue',
  ),
  'utf8',
);

const groupMembersModalSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/group-members-modal.vue',
  ),
  'utf8',
);

const recoveryKeyPreviewModalSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/matrix-recovery-key-preview-modal.vue',
  ),
  'utf8',
);

describe('chat view refactoring', () => {
  it('drives the recovery key modal from the crypto lifecycle state', () => {
    expect(chatViewSource).toContain(':open="isRecoveryModalOpen"');
    expect(chatViewSource).toContain('@setup="handleRecoverySetup"');
    expect(chatViewSource).toContain('@restore="handleRecoveryRestore"');
    expect(recoveryKeyPreviewModalSource).toContain(
      "mode: 'restore' | 'setup'",
    );
    expect(recoveryKeyPreviewModalSource).toContain('defineEmits');
    expect(recoveryKeyPreviewModalSource).not.toContain('recoveryKeyGroups');
    expect(recoveryKeyPreviewModalSource).not.toContain('isModalVisible');
    expect(recoveryKeyPreviewModalSource).toContain('savedConfirmation');
    expect(recoveryKeyPreviewModalSource).toContain('function finish');
    expect(recoveryKeyPreviewModalSource).toContain('downloadRecoveryKey');
    expect(recoveryKeyPreviewModalSource).toContain(
      'userStore.userInfo?.username',
    );
    expect(recoveryKeyPreviewModalSource).toContain('_key.txt');
    expect(recoveryKeyPreviewModalSource).not.toContain('canDismiss');
    expect(recoveryKeyPreviewModalSource).toContain('flex flex-col gap-4');
    expect(recoveryKeyPreviewModalSource).toContain('@press-enter="finish"');
    expect(recoveryKeyPreviewModalSource).not.toContain('<Tag');
    expect(recoveryKeyPreviewModalSource).not.toContain('dashed');
    expect(recoveryKeyPreviewModalSource).not.toContain('!important');
  });

  it('uses Vben Page component with auto-content-height', () => {
    expect(chatViewSource).toContain("from '@vben/common-ui'");
    expect(chatViewSource).toContain('<Page');
    expect(chatViewSource).toContain('auto-content-height');
    expect(chatViewSource).toContain(
      'relative h-full min-h-0 min-w-0 w-full overflow-hidden',
    );
    expect(chatViewSource).not.toContain(
      'rounded-xl border border-border bg-card shadow-xs',
    );
    expect(chatViewSource).toContain('isSidebarCollapsed');
  });

  it('uses Ant Design Spin and Empty in main index view', () => {
    expect(chatViewSource).toContain('<Spin size="large"');
    expect(chatViewSource).toContain('<Empty');
    expect(chatViewSource).toContain('Empty.PRESENTED_IMAGE_SIMPLE');
    expect(chatViewSource).toContain(
      ':is-loading-messages="isLoadingMessages"',
    );
    expect(chatViewSource).toContain(':is-empty="!isChatActive"');
  });

  it('sidebar adheres strictly to Ant Design components including Segmented filter', () => {
    expect(chatSidebarSource).toContain('<Segmented');
    expect(chatSidebarSource).toContain('<Tooltip');
    expect(chatSidebarSource).toContain('<Badge');
    expect(chatSidebarSource).toContain('<Avatar');
    expect(chatSidebarSource).toContain(':src="item.avatarUrl"');
    expect(chatSidebarSource).toContain('<Empty');
    expect(chatSidebarSource).toContain(
      'formatMessagePreview(item.lastMessage)',
    );
    expect(chatSidebarSource).not.toContain('isFullscreen');
    expect(chatSidebarSource).not.toContain('toggleFullscreen');
    expect(chatSidebarSource).not.toContain('lucide:maximize-2');
    expect(chatSidebarSource).not.toContain('useVbenDrawer');
    expect(chatSidebarSource).toContain('<aside');
    expect(chatSidebarSource).not.toContain('transition-[width]');
    expect(chatSidebarSource).not.toContain('role="separator"');
    expect(chatSidebarSource).not.toContain('MIN_SIDEBAR_WIDTH');
  });

  it('header uses Ant Design components without raw button elements', () => {
    expect(chatHeaderSource).toContain('<Avatar');
    expect(chatHeaderSource).toContain('<Badge');
    expect(chatHeaderSource).toContain('<Tooltip');
    expect(chatHeaderSource).toContain('<Button');
    expect(chatHeaderSource).toContain(':src="avatarUrl"');
    expect(chatHeaderSource).toContain('isSidebarCollapsed');
    expect(chatHeaderSource).toContain('isEmpty?: boolean');
    expect(chatHeaderSource).toContain('toggleSidebar');
    expect(chatHeaderSource).toContain('lucide:panel-left-close');
    expect(chatHeaderSource).toContain('class="w-full rounded-lg"');
    expect(chatHeaderSource).toContain('icon="lucide:search"');
    const rightHeaderActions =
      chatHeaderSource.split('<Space v-if="isSearchOpen"')[1] ?? '';
    expect(rightHeaderActions).not.toContain('<template v-else>');
    expect(rightHeaderActions).toContain("emit('toggleInfoPanel')");
    expect(chatHeaderSource).not.toContain('Search Toolbar Bar');
    expect(chatHeaderSource).not.toContain('<button');
  });

  it('styles date-separated compact message clusters with nested replies and content-only actions', () => {
    expect(chatMessagesSource).toContain('<Divider');
    expect(chatMessagesSource).toContain('<ChatMessageActions');
    expect(chatMessagesSource).toContain('<Tooltip');
    expect(chatMessagesSource).toContain('<Spin');
    expect(chatMessagesSource).toContain('<Skeleton');
    expect(chatMessagesSource).toContain('isLoadingMessages?: boolean');
    expect(chatMessagesSource).toContain('canPinMessages: boolean');
    expect(chatMessagesSource).toContain('ensureMessageLoaded:');
    expect(chatMessagesSource).toContain('pinnedEventIds: string[]');
    expect(chatMessagesSource).toContain('pinnedMessages: ChatMessageItem[]');
    expect(chatMessagesSource).toContain('chat.loadingMessages');
    expect(chatMessagesSource).toContain('props.isLoadingMessages');
    expect(chatMessagesSource).toContain('scrollToBottom();');
    expect(chatMessagesSource).toContain(':src="getSenderAvatarSrc(msg)"');
    expect(chatMessagesSource).toContain('getSenderInitials(msg.senderName)');
    expect(chatMessagesSource).toContain('handleAvatarError(msg)');
    expect(chatMessagesSource).toContain("msg.status === 'sent' && msg.isRead");
    expect(chatMessagesSource).toContain('icon="lucide:check-check"');
    expect(chatMessagesSource).toContain('interface MessageCluster');
    expect(chatMessagesSource).toContain('group.clusters');
    expect(chatMessagesSource).toContain('MESSAGE_CLUSTER_WINDOW_MS = 60_000');
    expect(chatMessagesSource).toContain('cluster.lastMessage.timestamp');
    expect(chatMessagesSource).toContain(
      'messageIndex === cluster.messages.length - 1',
    );
    expect(chatMessagesSource).toContain('getBubbleShapeClass');
    expect(chatMessagesSource).toContain(
      'group/message relative flex w-full items-end',
    );
    expect(chatMessagesSource).toContain(
      'relative min-w-0 w-fit max-w-[min(calc(100vw/3),85%)]',
    );
    expect(chatMessagesSource).toContain('chat-message-bubble');
    expect(chatMessagesSource).toContain('text-sm');
    expect(chatMessageActionsSource).toContain('<Popconfirm');
    expect(chatMessageActionsSource).toContain(
      'group-hover/message:opacity-100',
    );
    expect(chatMessageActionsSource).not.toContain('delay-200');
    expect(chatMessagesSource).not.toContain('border-l-2');
    expect(chatMessagesSource).toContain('focus-visible:ring-2');
    expect(chatMessagesSource).not.toContain('border-l-3');
    expect(chatMessagesSource).not.toContain('bg-black/20');
    expect(chatMessagesSource).not.toContain('ring-2 ring-primary/80');
    expect(chatMessagesSource).not.toContain('<button');
    expect(chatMessagesSource).toContain('isPinnedBannerExpanded');
    expect(chatMessagesSource).toContain('handlePinnedMessageClick');

    // Skeletons follow the same compact incoming/outgoing rhythm as messages.
    expect(chatMessagesSource).toContain(
      'bg-muted-foreground/15 animate-pulse',
    );
    expect(chatMessagesSource).toContain('h-10 w-48 rounded-2xl rounded-bl-md');
    expect(chatMessagesSource).toContain('h-10 w-40 rounded-2xl rounded-br-md');
    expect(chatMessagesSource).toContain('h-16 w-64 rounded-2xl rounded-bl-md');
    expect(chatMessagesSource).toContain('h-16 w-56 rounded-2xl rounded-br-md');
    expect(chatMessagesSource).not.toContain('bg-primary/20 px-4 py-3');
    expect(chatMessagesSource).not.toContain('h-3.5 w-44');
  });

  it('uses the persisted user avatar for direct conversations', () => {
    const conversationsSource = readFileSync(
      resolve(
        process.cwd(),
        'apps/workspace/src/views/chat/composables/use-conversations.ts',
      ),
      'utf8',
    );

    expect(conversationsSource).toContain('getUserAvatarSource(colleague)');
  });

  it('does not synthesize Matrix IDs for users who have not activated chat', () => {
    expect(chatConversationsSource).toContain(
      'const targetMatrixUserId = colleague.matrix_user_id;',
    );
    expect(chatConversationsSource).not.toContain(
      'colleague.matrix_user_id ||',
    );
    expect(chatConversationsSource).not.toContain('myUsername');
    expect(chatSidebarSource).toContain('chat.userNotActivated');
    expect(chatViewSource).toContain('isActiveConversationUnavailable');
    expect(chatViewSource).toContain('chat.userNotActivatedHint');
  });

  it('does not synthesize Matrix IDs for inactive group members', () => {
    expect(createGroupSource).toContain('has not activated chat.');
    expect(createGroupSource).not.toContain('user.matrix_user_id ||');
    expect(createGroupModalSource).toContain('disabled: !u.matrix_user_id');
  });

  it('composer component includes shortcut hint, textarea and send button', () => {
    expect(chatComposerSource).toContain('<Input.TextArea');
    expect(chatComposerSource).toContain('<Button');
    expect(chatComposerSource).toContain('chat.inputPlaceholder');
    expect(chatComposerSource).toContain('chat.attachFile');
  });

  it('composer renders a compact file picker and send action row', () => {
    expect(chatComposerSource).toContain('data-testid="chat-composer-input"');
    expect(chatComposerSource).toContain('icon="lucide:paperclip"');
    expect(chatComposerSource).toContain('icon="mdi:send"');
    expect(chatComposerSource).toContain('!border-0');
    expect(chatComposerSource).toContain("'!text-muted-foreground/50");
    expect(chatComposerSource).toContain('focusMessageInput');
    expect(chatComposerSource).toContain('ref="messageInput"');
    expect(chatComposerSource).not.toContain('@drop=');
    expect(chatViewSource).toContain('data-testid="chat-dropzone"');
    expect(chatViewSource).toContain('data-testid="chat-drop-overlay"');
    expect(chatViewSource).toContain('chat.dropFileToSend');
    expect(chatViewSource).toContain('animate-ping');
    expect(chatViewSource).toContain('handleChatDrop');
    expect(chatViewSource).toContain('void handleSendFiles(files)');
    expect(chatComposerSource).toContain(
      ':auto-size="{ minRows: 1, maxRows: 5 }"',
    );
    expect(chatComposerSource).toContain('type="file"');
    expect(chatComposerSource).toContain('shape="circle"');
    expect(chatComposerSource).toContain(
      'cursor-not-allowed border-border/70 bg-slate-200/80',
    );
  });

  it('collapses chat panels progressively on narrow viewports', () => {
    expect(chatViewSource).toContain('INFO_PANEL_COLLAPSE_WIDTH = 1280');
    expect(chatViewSource).toContain('SIDEBAR_COLLAPSE_WIDTH = 900');
    expect(chatViewSource).toContain("window.addEventListener('resize'");
    expect(chatViewSource).toContain('isInfoPanelOpen.value = false');
    expect(chatViewSource).toContain('isSidebarCollapsed.value = true');
  });

  it('composer uses a compact Vben-style reply context card', () => {
    expect(chatComposerSource).toContain('data-testid="chat-reply-preview"');
    expect(chatComposerSource).toContain('role="status"');
    expect(chatComposerSource).toContain('chat.replyingTo');
    expect(chatComposerSource).toContain('bg-primary/5');
    expect(chatComposerSource).not.toContain('bg-primary/70');
    expect(chatComposerSource).toContain('data-testid="chat-cancel-reply"');
    expect(chatComposerSource).toContain('!size-7');
    expect(chatComposerSource).toContain('icon="lucide:x" class="size-3.5"');
    expect(chatComposerSource).toContain(
      ':aria-label="$t(\'chat.cancelReply\')"',
    );
  });

  it('create group modal uses Ant Design Form and Form.Item with validation', () => {
    expect(createGroupModalSource).toContain('<Form layout="vertical"');
    expect(createGroupModalSource).toContain('<Form.Item');
    expect(createGroupModalSource).toContain('<Select');
  });

  it('enforces Vben Antd message styling, 1/3 screen width wrapping, and seamless fast-message clusters', () => {
    // 1/3 screen width constraint
    expect(chatMessagesSource).toContain('max-w-[min(calc(100vw/3),85%)]');
    // Standard font size sm
    expect(chatMessagesSource).toContain('text-sm');
    // Ant Design primary styling for outgoing messages
    expect(chatMessagesSource).toContain(
      'border-primary bg-primary text-primary-foreground',
    );
    // Tight cluster spacing for fast consecutive messages
    expect(chatMessagesSource).toContain('space-y-1');
    expect(chatMessagesSource).toContain('rounded-br-md');
    expect(chatMessagesSource).toContain('rounded-bl-md');
    // Minute timestamp underneath when gap > 1 min or cluster ends
    expect(chatMessagesSource).toContain(
      "dayjs(msg.timestamp).format('HH:mm')",
    );
    // Custom font-family override removed to keep standard Vben typography
    expect(chatMessagesSource).not.toContain('font-family: var(--font-family)');
  });

  it('renders encrypted attachments as downloadable file cards', () => {
    expect(chatMessagesSource).toContain('formatAttachmentSize');
    expect(chatMessagesSource).toContain('getAttachmentExtension');
    expect(chatMessagesSource).toContain('handleAttachmentDownload');
    expect(chatMessagesSource).toContain('chat.fileAvailableInCloud');
    expect(chatMessagesSource).toContain('chat.downloadFile');
    expect(chatMessagesSource).toContain('lucide:download');
    expect(chatMessagesSource).toContain('props.downloadAttachment');
    expect(chatMessagesSource).toContain('msg.attachments?.some');
  });

  it('includes conversation info right sidebar template with avatar, media, and files', () => {
    expect(chatViewSource).toContain('ChatInfoPanel');
    expect(chatViewSource).toContain('isInfoPanelOpen');
    expect(chatHeaderSource).toContain('isInfoPanelOpen');
    expect(chatHeaderSource).toContain('toggleInfoPanel');
    expect(chatInfoPanelSource).toContain('Avatar');
    expect(chatInfoPanelSource).toContain('chat.conversationInfo');
    expect(chatInfoPanelSource).not.toContain('chat.muteNotifications');
    expect(chatInfoPanelSource).not.toContain('chat.pinConversation');
    expect(chatInfoPanelSource).toContain('chat.leaveGroup');
    expect(chatInfoPanelSource).toContain('chat.deleteGroup');
    expect(chatInfoPanelSource).toContain('v-if="!isDirect"');
    expect(chatInfoPanelSource).toContain('canDeleteGroup');
    expect(chatInfoPanelSource).toContain('v-if="!canDeleteGroup"');
    expect(chatInfoPanelSource).toContain('type="text"');
    expect(chatInfoPanelSource).toContain("emit('leaveGroup')");
    expect(chatInfoPanelSource).toContain("emit('deleteGroup')");
    expect(chatInfoPanelSource).toContain('chat.media');
    expect(chatInfoPanelSource).toContain('chat.files');
    expect(chatInfoPanelSource).toContain('chat.viewMore');
    expect(chatInfoPanelSource).toContain('isAttachmentBrowserOpen');
    expect(chatInfoPanelSource).toContain('handleAttachmentTab');
    expect(chatInfoPanelSource).toContain('handleBackToInfo');
    expect(chatInfoPanelSource).toContain('groupedMediaList');
    expect(chatInfoPanelSource).toContain('chat.links');
    expect(chatInfoPanelSource).toContain('ATTACHMENT_PAGE_SIZE = 30');
    expect(chatInfoPanelSource).toContain('loadOlderMessages?:');
    expect(chatInfoPanelSource).toContain('roomId?: null | string');
    expect(chatInfoPanelSource).toContain(
      '@scroll.passive="handlePanelScroll"',
    );
    expect(chatInfoPanelSource).toContain("handleViewMore('media')");
    expect(chatInfoPanelSource).toContain("handleViewMore('files')");
    expect(chatInfoPanelSource).toContain("handleViewMore('links')");
    expect(chatViewSource).toContain(':has-more-history="hasMoreHistory"');
    expect(chatViewSource).toContain(':is-loading-older="isLoadingOlder"');
    expect(chatViewSource).toContain(
      ':load-older-messages="loadOlderMessages"',
    );
    expect(chatViewSource).toContain(':room-id="activeRoomId"');
    expect(chatInfoPanelSource).toContain('mediaList');
    expect(chatInfoPanelSource).toContain('fileList');
    expect(chatInfoPanelSource).toContain('linkList');
    expect(chatInfoPanelSource).not.toContain('sampleMediaList');
    expect(chatInfoPanelSource).not.toContain('sampleFileList');
    expect(chatInfoPanelSource).toContain('previewImage');
    expect(chatMessagesSource).toContain('previewImage');
    expect(chatViewSource).toContain('ChatFilePreviewModal');
  });

  it('hides member count for direct rooms and triggers group members modal on click for groups', () => {
    expect(chatHeaderSource).toContain('v-if="!isDirect"');
    expect(chatHeaderSource).toContain('<span');
    expect(chatHeaderSource).toContain('role="button"');
    expect(chatHeaderSource).toContain('tabindex="0"');
    expect(chatHeaderSource).toContain(
      'cursor-pointer items-center gap-1 text-xs text-muted-foreground transition-colors hover:text-foreground',
    );
    expect(chatHeaderSource).toContain("emit('openMembers')");
    expect(chatHeaderSource).toContain(
      '@keydown.enter="emit(\'openMembers\')"',
    );
    expect(chatHeaderSource).toContain(
      '@keydown.space.prevent="emit(\'openMembers\')"',
    );
    expect(chatHeaderSource).toContain('openMembers: [];');
    expect(chatViewSource).toContain('<GroupMembersModal');
    expect(chatViewSource).toContain(
      '@open-members="isMembersModalOpen = true"',
    );
    expect(
      chatViewSource.match(/@open-members="isMembersModalOpen = true"/g),
    ).toHaveLength(2);
    expect(chatViewSource).toContain(':members="activeRoomMembers"');
    expect(chatViewSource).toContain(
      ':can-delete-group="canDeleteActiveGroup"',
    );
    expect(chatViewSource).toContain('@leave-group="handleLeaveGroup"');
    expect(chatViewSource).toContain('@delete-group="handleDeleteGroup"');
    expect(chatViewSource).toContain(
      ':can-invite-members="canInviteActiveRoomMembers"',
    );
    expect(chatViewSource).toContain('@invite-member="handleInviteMember"');
    expect(groupMembersModalSource).toContain('<Modal');
    expect(groupMembersModalSource).toContain('chat.groupMembers');
    expect(groupMembersModalSource).toContain('chat.searchMembers');
    expect(groupMembersModalSource).toContain('chat.groupAdmin');
    expect(groupMembersModalSource).toContain('chat.groupMember');
    expect(groupMembersModalSource).toContain('chat.directMessage');
    expect(groupMembersModalSource).toContain('chat.addMember');
    expect(groupMembersModalSource).toContain('isCurrentUserAdmin');
    expect(groupMembersModalSource).toContain(
      'canInviteMembers && isCurrentUserAdmin',
    );
    expect(groupMembersModalSource).toContain('lucide:user-plus');
    expect(groupMembersModalSource).not.toContain('isAddMemberOpen');
    expect(groupMembersModalSource).toContain('chat.removeMember');
    expect(groupMembersModalSource).toContain('chat.removeMemberConfirm');
    expect(groupMembersModalSource).toContain(
      "emit('inviteMember', selectedMemberId.value)",
    );
    expect(groupMembersModalSource).toContain(
      "emit('removeMember', member.userId)",
    );
  });

  it('restricts adding members to group admins only in group members modal', () => {
    expect(groupMembersModalSource).toContain(
      'const isCurrentUserAdmin = computed(() =>',
    );
    expect(groupMembersModalSource).toContain('member.isMe && member.isAdmin');
    expect(groupMembersModalSource).toContain(
      'v-if="canInviteMembers && isCurrentUserAdmin"',
    );
    expect(groupMembersModalSource).toContain(
      'if (!props.canInviteMembers || !isCurrentUserAdmin.value) return [];',
    );
  });

  it('integrates ChatGroupAvatar in sidebar, header, and info panel for group chats', () => {
    expect(chatSidebarSource).toContain('<ChatGroupAvatar');
    expect(chatSidebarSource).toContain('v-if="!item.isDirect"');
    expect(chatSidebarSource).toContain(':members="item.groupMemberAvatars"');
    expect(chatSidebarSource).toContain(':total-count="item.memberCount"');

    expect(chatHeaderSource).toContain('<ChatGroupAvatar');
    expect(chatHeaderSource).toContain('v-if="!isDirect"');
    expect(chatHeaderSource).toContain(':members="groupMemberAvatars"');

    expect(chatInfoPanelSource).toContain('<ChatGroupAvatar');
    expect(chatInfoPanelSource).toContain('v-if="!isDirect"');
    expect(chatInfoPanelSource).toContain(':members="groupMemberAvatars"');

    expect(chatViewSource).toContain(
      ':group-member-avatars="activeGroupMemberAvatars"',
    );
  });

  it('renders group avatar collage with 2x2 grid and overflow count matching reference design', async () => {
    const root = document.createElement('div');
    const app = createApp(ChatGroupAvatar, {
      members: [
        { displayName: 'Alice', userId: '@alice:obee.local' },
        { displayName: 'Bob', userId: '@bob:obee.local' },
        { displayName: 'Charlie', userId: '@charlie:obee.local' },
      ],
      totalCount: 91,
    });
    app.mount(root);
    await nextTick();

    expect(root.textContent).toContain('88');
    expect(root.textContent).toContain('A');
    expect(root.textContent).toContain('B');
    expect(root.textContent).toContain('C');
    app.unmount();
  });

  it('renders avatar in empty conversation state and skeleton in sidebar while loading users and groups', () => {
    expect(chatMessagesSource).toContain(':size="56"');
    expect(chatMessagesSource).toContain('lucide:message-square');
    expect(chatMessagesSource).toContain('<ChatGroupAvatar');

    expect(chatSidebarSource).toContain('v-if="loading"');
    expect(chatSidebarSource).toContain('animate-pulse');
    expect(chatViewSource).toContain(':loading="isSidebarLoading"');
  });

  it('supports multi-format preview for PDF, DOCX, text, video, audio and images', () => {
    expect(detectFileType('report.pdf')).toBe('pdf');
    expect(detectFileType('document.docx')).toBe('docx');
    expect(detectFileType('photo.png')).toBe('image');
    expect(detectFileType('video.mp4')).toBe('video');
    expect(detectFileType('audio.mp3')).toBe('audio');
    expect(detectFileType('notes.txt')).toBe('text');
    expect(detectFileType('data.json')).toBe('text');
    expect(detectFileType('table.csv')).toBe('text');
    expect(detectFileType('archive.zip')).toBe('unsupported');

    const preview = useFilePreview();
    expect(typeof preview.previewFile).toBe('function');
    expect(typeof preview.closePreview).toBe('function');
    expect(typeof preview.previewImage).toBe('function');

    expect(chatViewSource).toContain('ChatFilePreviewModal');
    expect(chatInfoPanelSource).toContain('handleFileItemClick');
    expect(chatInfoPanelSource).toContain('previewFile');
    expect(chatMessagesSource).toContain('handleAttachmentClick');
    expect(chatMessagesSource).toContain('previewFile');
  });

  it('renders Zalo-style group join and leave system notifications', () => {
    expect(chatMessagesSource).toContain('cluster.isSystem');
    expect(chatMessagesSource).toContain('getSystemEventIcon');
    expect(chatMessagesSource).toContain('getSystemEventText');
    expect(chatMessagesSource).toContain('rounded-full bg-muted/70');
  });

  it('formats image attachments cleanly without duplicate file card and non-images with compact card', () => {
    expect(chatMessagesSource).toContain("attachment.msgtype === 'm.image'");
    expect(chatMessagesSource).toContain('isPureImageMessage');
    expect(chatMessagesSource).toContain(
      '!border-0 !bg-transparent !p-0 !shadow-none',
    );
    expect(chatMessagesSource).toContain('getAttachmentBadgeClass');
    expect(chatMessagesSource).not.toContain('lucide:files');
    expect(chatMessagesSource).toContain('getAttachmentExtension');
    expect(chatMessagesSource).toContain('formatAttachmentSize');
  });

  it('detects URLs in messages, renders clickable links, and displays links in chat info panel', () => {
    expect(
      extractUrls('Check https://example.com/test and www.google.com!'),
    ).toEqual([
      { href: 'https://example.com/test', url: 'https://example.com/test' },
      { href: 'https://www.google.com', url: 'www.google.com' },
    ]);

    expect(
      extractUrls('Wiki: https://en.wikipedia.org/wiki/React_(software).'),
    ).toEqual([
      {
        href: 'https://en.wikipedia.org/wiki/React_(software)',
        url: 'https://en.wikipedia.org/wiki/React_(software)',
      },
    ]);

    expect(getDomainFromUrl('https://sub.domain.com:8080/path?q=1')).toBe(
      'sub.domain.com',
    );
    expect(getDomainFromUrl('www.google.com')).toBe('google.com');

    const segments = parseMessageSegments('Hello https://obee.vn world');
    expect(segments).toEqual([
      { isUrl: false, text: 'Hello ' },
      { href: 'https://obee.vn', isUrl: true, text: 'https://obee.vn' },
      { isUrl: false, text: ' world' },
    ]);

    const pureUrlSegments = parseMessageSegments('https://obee.vn');
    expect(pureUrlSegments).toEqual([
      { href: 'https://obee.vn', isUrl: true, text: 'https://obee.vn' },
    ]);

    expect(chatMessagesSource).toMatch(
      /parseMessageSegments\s*\(\s*msg\.body\s*,?\s*\)/,
    );
    expect(chatMessagesSource).toContain('target="_blank"');
    expect(chatMessagesSource).toContain('rel="noopener noreferrer"');
    expect(chatMessagesSource).toContain('@click.stop');

    expect(chatInfoPanelSource).toContain('linkList');
    expect(chatInfoPanelSource).toContain('displayedLinkList');
    expect(chatInfoPanelSource).toContain("handleViewMore('links')");
    expect(chatInfoPanelSource).toContain('isLinksExpanded');
  });

  it('supports quick like, emoji reactions palette, seen read status, and typing indicator', () => {
    // Reactions constants
    expect(QUICK_LIKE_EMOJI).toBe('👍');
    expect(CHAT_REACTION_EMOJIS).toEqual(['👍', '❤️', '😂', '😮', '😢', '😡']);

    // Reaction tooltip formatter
    const singleUserReaction = {
      count: 1,
      hasReacted: false,
      key: '👍',
      users: [{ displayName: 'Alice', userId: '@alice:test' }],
    };
    expect(formatReactionTooltip(singleUserReaction)).toBe('Alice: 👍');

    const multiUserReaction = {
      count: 2,
      hasReacted: true,
      key: '❤️',
      users: [
        { displayName: 'Alice', userId: '@alice:test' },
        { displayName: 'Bob', userId: '@bob:test' },
      ],
    };
    expect(formatReactionTooltip(multiUserReaction)).toContain('❤️');

    // Typing indicator text formatter
    expect(formatTypingIndicatorText([])).toBe('');
    expect(
      formatTypingIndicatorText([
        { displayName: 'Alice', userId: '@alice:test' },
      ]),
    ).toBe('chat.typingSingle');

    expect(
      formatHeaderTypingText(
        [{ displayName: 'Alice', userId: '@alice:test' }],
        true,
      ),
    ).toBe('chat.typing');

    // chat-message-actions has Reaction Palette Popover dock without Quick Like button
    expect(chatMessageActionsSource).toContain('CHAT_REACTION_DEFINITIONS');
    expect(chatMessageActionsSource).toContain('<Popover');
    expect(chatMessageActionsSource).toContain('chat-reaction-popover');
    expect(chatMessageActionsSource).toContain('chat.react');
    expect(chatMessageActionsSource).not.toContain('handleQuickLike');
    expect(chatMessageActionsSource).not.toContain('QUICK_LIKE_EMOJI');

    // chat-messages renders borderless reaction pills at bottom-right corner, opens details modal, seen status with tooltip, and bottom typing indicator
    expect(chatMessagesSource).toContain('formatReactionTooltip(reaction)');
    expect(chatMessagesSource).toContain('openReactionDetails(msg)');
    expect(chatMessagesSource).toContain('<ChatReactionDetailsModal');
    expect(chatMessagesSource).toContain("emit('toggleReaction'");
    expect(chatMessagesSource).not.toContain('border-primary/50');
    expect(chatMessagesSource).not.toContain('border-border/80');
    expect(chatMessagesSource).toContain('data-testid="chat-typing-indicator"');
    expect(chatMessagesSource).toContain(
      ':src="getTypingAvatarSrc(typingUsers[0])"',
    );
    expect(chatMessagesSource).toContain(
      'formatTypingIndicatorText(typingUsers)',
    );
    expect(chatMessagesSource).toContain('animate-bounce');
    expect(chatMessagesSource).toContain('chat.seen');
    expect(chatMessagesSource).toContain('chat.seenBy');
    expect(chatMessagesSource).not.toContain('<button');

    // chat-header renders typingText in subtitle
    expect(chatHeaderSource).toContain('typingText?: string');
    expect(chatHeaderSource).toContain('v-if="typingText"');
    expect(chatHeaderSource).toContain('animate-pulse');

    // chat-composer emits typing and read events and defaults to quick like button when input is empty
    expect(chatComposerSource).toContain('read: []');
    expect(chatComposerSource).toContain('@click="emit(\'read\')"');
    expect(chatComposerSource).toContain('@focus="emit(\'read\')"');
    expect(chatViewSource).toContain('@read="handleMarkAsRead"');
    expect(chatComposerSource).toContain('typing: [isTyping: boolean]');
    expect(chatComposerSource).toContain('useTypingSender');
    expect(chatComposerSource).toContain('handleSendLike');
    expect(chatComposerSource).toContain("emit('send', '👍')");
    expect(chatComposerSource).toContain('v-if="inputMessage.trim()"');
    expect(chatComposerSource).toContain('chat.like');
  });
});

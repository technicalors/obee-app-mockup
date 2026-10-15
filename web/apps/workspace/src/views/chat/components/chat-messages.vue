<script setup lang="ts">
import type { GroupMemberAvatarInfo } from '../types';

import type { User } from '#/api';
import type {
  ChatMessageAttachment,
  ChatMessageItem,
  ChatTypingUser,
} from '#/store';

import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Avatar,
  Button,
  Divider,
  Modal,
  SkeletonAvatar,
  Spin,
  Tooltip,
} from 'ant-design-vue';
import dayjs from 'dayjs';
import { escapeRegExp } from 'lodash';

import { $t } from '#/locales';
import { resolveChatUserDisplayName, useChatStore } from '#/store';
import {
  getUserAvatarSource,
  getUserPlaceholderAvatar,
} from '#/views/users/avatar';

import { parseMessageSegments } from '../composables/use-chat-links';
import { formatReactionTooltip } from '../composables/use-chat-reactions';
import { formatTypingIndicatorText } from '../composables/use-chat-typing';
import {
  detectFileType,
  useFilePreview,
} from '../composables/use-file-preview';
import ChatGroupAvatar from './chat-group-avatar.vue';
import ChatMessageActions from './chat-message-actions.vue';
import ChatReactionDetailsModal from './chat-reaction-details-modal.vue';

interface Props {
  avatarUrl?: string;
  canPinMessages: boolean;
  colleagues?: User[];
  downloadAttachment: (
    messageId: string,
    attachmentIndex: number,
  ) => Promise<void>;
  ensureMessageLoaded: (eventId: string) => Promise<boolean>;
  groupMemberAvatars?: GroupMemberAvatarInfo[];
  hasMoreHistory?: boolean;
  isDirect: boolean;
  isLoadingMessages?: boolean;
  isLoadingOlder?: boolean;
  memberCount?: number;
  messages: ChatMessageItem[];
  pinnedEventIds: string[];
  pinnedMessages: ChatMessageItem[];
  searchQuery?: string;
  typingUsers?: ChatTypingUser[];
}

const props = withDefaults(defineProps<Props>(), {
  avatarUrl: undefined,
  colleagues: () => [],
  groupMemberAvatars: () => [],
  hasMoreHistory: true,
  isLoadingMessages: false,
  isLoadingOlder: false,
  memberCount: 0,
  searchQuery: '',
  typingUsers: () => [],
});

const emit = defineEmits<{
  loadMore: [];
  redact: [msg: ChatMessageItem];
  reply: [msg: ChatMessageItem];
  toggleReaction: [msg: ChatMessageItem, key: string];
}>();

const containerRef = ref<HTMLDivElement | null>(null);
const highlightedEventId = ref<null | string>(null);
const isPinnedBannerExpanded = ref(false);
const loadingPinnedEventId = ref<null | string>(null);
const olderMessagesScrollHeight = ref<null | number>(null);
const downloadingAttachmentKey = ref<null | string>(null);
const revealedTimestampIds = ref(new Set<string>());
const reactionDetailsMessageId = ref<null | string>(null);
const reactionDetailsMessage = computed<ChatMessageItem | null>(() => {
  if (!reactionDetailsMessageId.value) return null;
  return (
    props.messages.find((m) => m.id === reactionDetailsMessageId.value) ?? null
  );
});
const isReactionDetailsModalOpen = ref(false);

function openReactionDetails(msg: ChatMessageItem): void {
  reactionDetailsMessageId.value = msg.id;
  isReactionDetailsModalOpen.value = true;
}

const pinnedMessagesById = computed(
  () => new Map(props.pinnedMessages.map((message) => [message.id, message])),
);
const latestPinnedMessage = computed(() => {
  const latestEventId = props.pinnedEventIds.at(-1);
  return latestEventId
    ? pinnedMessagesById.value.get(latestEventId)
    : undefined;
});

function toggleMessageTimestamp(messageId: string): void {
  const next = new Set(revealedTimestampIds.value);
  if (next.has(messageId)) {
    next.delete(messageId);
  } else {
    next.add(messageId);
  }
  revealedTimestampIds.value = next;
}

function scrollToBottom(): void {
  nextTick(() => {
    if (containerRef.value) {
      containerRef.value.scrollTop = containerRef.value.scrollHeight;
    }
  });
}

watch(
  () => props.typingUsers?.length,
  (len) => {
    if (len && len > 0) {
      scrollToBottom();
    }
  },
);

function handleScroll(): void {
  const el = containerRef.value;
  if (
    !el ||
    showSkeleton.value ||
    props.isLoadingMessages ||
    props.isLoadingOlder ||
    !props.hasMoreHistory
  ) {
    return;
  }

  if (el.scrollTop <= 40) {
    olderMessagesScrollHeight.value = el.scrollHeight;
    emit('loadMore');
  }
}

function scrollToMessage(eventId: string): void {
  nextTick(() => {
    const el = containerRef.value?.querySelector<HTMLElement>(
      `[id="msg-${eventId}"]`,
    );
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      highlightedEventId.value = eventId;
      setTimeout(() => {
        if (highlightedEventId.value === eventId) {
          highlightedEventId.value = null;
        }
      }, 1800);
    }
  });
}

async function handlePinnedMessageClick(eventId: string): Promise<void> {
  if (loadingPinnedEventId.value) return;

  loadingPinnedEventId.value = eventId;
  try {
    if (!props.messages.some((message) => message.id === eventId)) {
      olderMessagesScrollHeight.value =
        containerRef.value?.scrollHeight ?? null;
      const loaded = await props.ensureMessageLoaded(eventId);
      if (!loaded) {
        olderMessagesScrollHeight.value = null;
        return;
      }
    }
    scrollToMessage(eventId);
  } finally {
    loadingPinnedEventId.value = null;
  }
}

function handlePinnedModalItemClick(eventId: string): void {
  isPinnedBannerExpanded.value = false;
  void handlePinnedMessageClick(eventId);
}

function getHighlightSegments(
  text: string,
  query?: string,
): Array<{ isMatch: boolean; text: string }> {
  if (!query || !query.trim()) {
    return [{ isMatch: false, text }];
  }
  const q = query.trim();
  const regex = new RegExp(`(${escapeRegExp(q)})`, 'gi');
  const parts = text.split(regex);
  return parts.map((part) => ({
    isMatch: part.toLowerCase() === q.toLowerCase(),
    text: part,
  }));
}

interface MessageDateGroup {
  clusters: MessageCluster[];
  date: string;
}

interface MessageCluster {
  firstMessage: ChatMessageItem;
  isMe: boolean;
  isSystem?: boolean;
  lastMessage: ChatMessageItem;
  messages: ChatMessageItem[];
  senderId: string;
}

const MESSAGE_CLUSTER_WINDOW_MS = 60_000;

const groupedMessages = computed<MessageDateGroup[]>(() => {
  const groups: MessageDateGroup[] = [];

  for (const msg of props.messages) {
    const msgDate = dayjs(msg.timestamp).format('YYYY-MM-DD');
    let group = groups.at(-1);

    if (!group || group.date !== msgDate) {
      group = { clusters: [], date: msgDate };
      groups.push(group);
    }

    if (msg.isSystem) {
      group.clusters.push({
        firstMessage: msg,
        isMe: false,
        isSystem: true,
        lastMessage: msg,
        messages: [msg],
        senderId: msg.senderId,
      });
      continue;
    }

    const cluster = group.clusters.at(-1);
    if (cluster && !cluster.isSystem) {
      const elapsed = msg.timestamp - cluster.lastMessage.timestamp;
      if (
        cluster.isMe === msg.isMe &&
        cluster.senderId === msg.senderId &&
        elapsed >= 0 &&
        elapsed <= MESSAGE_CLUSTER_WINDOW_MS
      ) {
        cluster.lastMessage = msg;
        cluster.messages.push(msg);
        continue;
      }
    }

    group.clusters.push({
      firstMessage: msg,
      isMe: msg.isMe,
      isSystem: false,
      lastMessage: msg,
      messages: [msg],
      senderId: msg.senderId,
    });
  }

  return groups;
});

function getBubbleShapeClass(
  isMe: boolean,
  _isFirstInCluster = false,
  _isLastInCluster = false,
): string {
  return isMe ? 'rounded-2xl rounded-br-md' : 'rounded-2xl rounded-bl-md';
}

function isPureImageMessage(msg: ChatMessageItem): boolean {
  if (
    msg.isRedacted ||
    msg.decryptionStatus === 'failed' ||
    msg.decryptionStatus === 'pending' ||
    msg.replyTo ||
    !msg.attachments ||
    msg.attachments.length === 0
  ) {
    return false;
  }

  const hasOnlyImages = msg.attachments.every(
    (att) => att.msgtype === 'm.image',
  );
  if (!hasOnlyImages) {
    return false;
  }

  const hasCaption =
    Boolean(msg.body) &&
    !msg.attachments.some((att) => att.filename === msg.body);
  return !hasCaption;
}

function formatDateDivider(dateStr: string): string {
  const d = dayjs(dateStr);
  const now = dayjs();
  if (d.isSame(now, 'day')) {
    return $t('chat.today');
  }
  if (d.isSame(now.subtract(1, 'day'), 'day')) {
    return $t('chat.yesterday');
  }
  return d.format('DD/MM/YYYY');
}

const failedAvatarUrls = ref(new Set<string>());

function getSenderColleague(senderId: string): undefined | User {
  if (!props.colleagues || props.colleagues.length === 0) return undefined;
  const username = senderId.replace(/^@/, '').split(':')[0]?.toLowerCase();
  return props.colleagues.find(
    (c) =>
      c.username.toLowerCase() === username ||
      (c.matrix_user_id &&
        c.matrix_user_id.toLowerCase() === senderId.toLowerCase()),
  );
}

function getSenderDisplayName(msg: ChatMessageItem): string {
  const colleague = getSenderColleague(msg.senderId);
  return resolveChatUserDisplayName(
    msg.senderId,
    [colleague?.name, msg.senderName],
    $t('chat.unknownUser'),
  )
    .replaceAll(/[\p{Emoji}\p{Extended_Pictographic}]/gu, '')
    .trim();
}

function getReplySenderDisplayName(senderName: string): string {
  const colleague = getSenderColleague(senderName);
  return resolveChatUserDisplayName(
    '',
    [colleague?.name, senderName],
    $t('chat.unknownUser'),
  );
}

function getPinnedSenderDisplayName(eventId: string): string {
  const message = pinnedMessagesById.value.get(eventId);
  return message ? getSenderDisplayName(message) : '...';
}

function getMemberDisplayName(userId: string, fallbackName?: string): string {
  if (userId === store.currentUserId) {
    return $t('chat.you');
  }
  const colleague = getSenderColleague(userId);
  if (colleague?.name) {
    return colleague.name;
  }
  return resolveChatUserDisplayName(
    userId,
    [colleague?.name, fallbackName],
    $t('chat.unknownUser'),
  )
    .replaceAll(/[\p{Emoji}\p{Extended_Pictographic}]/gu, '')
    .trim();
}

const resolvedTypingUsers = computed<ChatTypingUser[]>(() =>
  props.typingUsers.map((typingUser) => ({
    ...typingUser,
    displayName: getMemberDisplayName(
      typingUser.userId,
      typingUser.displayName,
    ),
  })),
);

function getSystemEventIcon(msg: ChatMessageItem): string {
  const type = msg.systemEvent?.type;
  switch (type) {
    case 'member_add': {
      return 'lucide:user-plus';
    }
    case 'member_create': {
      return 'lucide:users';
    }
    case 'member_join': {
      return 'lucide:log-in';
    }
    case 'member_kick': {
      return 'lucide:user-minus';
    }
    case 'member_leave': {
      return 'lucide:log-out';
    }
    default: {
      return 'lucide:info';
    }
  }
}

function getSystemEventText(msg: ChatMessageItem): string {
  if (!msg.systemEvent) {
    return msg.body;
  }

  const { actorId, actorName, targetId, targetName, type } = msg.systemEvent;
  const isActorMe = actorId === store.currentUserId;
  const isTargetMe = targetId === store.currentUserId;
  const actor = isActorMe
    ? $t('chat.you')
    : getMemberDisplayName(actorId, actorName);
  const target = isTargetMe
    ? $t('chat.you')
    : getMemberDisplayName(targetId, targetName);

  switch (type) {
    case 'member_add': {
      if (isActorMe) {
        return $t('chat.system.youAddedUser', { user: target });
      }
      if (isTargetMe) {
        return $t('chat.system.userAddedYou', { user: actor });
      }
      return $t('chat.system.userAddedUser', { actor, target });
    }
    case 'member_create': {
      return isActorMe
        ? $t('chat.system.youCreatedGroup')
        : $t('chat.system.userCreatedGroup', { user: actor });
    }
    case 'member_join': {
      return isTargetMe
        ? $t('chat.system.youJoined')
        : $t('chat.system.userJoined', { user: target });
    }
    case 'member_kick': {
      if (isActorMe) {
        return $t('chat.system.youRemovedUser', { user: target });
      }
      if (isTargetMe) {
        return $t('chat.system.userRemovedYou', { user: actor });
      }
      return $t('chat.system.userRemovedUser', { actor, target });
    }
    case 'member_leave': {
      return isTargetMe
        ? $t('chat.system.youLeft')
        : $t('chat.system.userLeft', { user: target });
    }
    default: {
      return msg.body;
    }
  }
}

function getSenderAvatarSrc(msg: ChatMessageItem): string | undefined {
  let url: string | undefined;

  const colleague = getSenderColleague(msg.senderId);
  if (colleague) {
    url = getUserAvatarSource(colleague);
  } else if (props.isDirect && props.avatarUrl) {
    url = props.avatarUrl;
  } else {
    url = getUserPlaceholderAvatar({
      id: '',
      username: msg.senderId,
    });
  }

  if (url && failedAvatarUrls.value.has(url)) {
    return undefined;
  }
  return url || undefined;
}

function getTypingAvatarSrc(typingUser?: ChatTypingUser): string | undefined {
  if (!typingUser) return undefined;

  let url: string | undefined;
  const colleague = getSenderColleague(typingUser.userId);
  if (colleague) {
    url = getUserAvatarSource(colleague);
  } else if (props.isDirect && props.avatarUrl) {
    url = props.avatarUrl;
  } else if (typingUser.avatarUrl) {
    url = typingUser.avatarUrl;
  } else {
    url = getUserPlaceholderAvatar({
      id: '',
      username: typingUser.userId,
    });
  }

  if (url && failedAvatarUrls.value.has(url)) {
    return undefined;
  }
  return url || undefined;
}

function handleAvatarError(msg: ChatMessageItem): boolean {
  const url = getSenderAvatarSrc(msg);
  if (url) {
    failedAvatarUrls.value.add(url);
  }
  return false;
}

function getSenderInitials(name?: string): string {
  if (!name || !name.trim()) return '';
  const clean = name
    .replaceAll(
      /[\p{Emoji}\p{Extended_Pictographic}\p{Symbol}\p{Punctuation}]/gu,
      '',
    )
    .trim();
  if (!clean) return '';
  const parts = clean.split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '';
  const firstWord = parts[0];
  if (parts.length === 1 && firstWord) {
    return firstWord.slice(0, 2).toUpperCase();
  }
  const first = parts[0]?.[0] ?? '';
  const last = parts[parts.length - 1]?.[0] ?? '';
  return `${first}${last}`.toUpperCase();
}

function formatAttachmentSize(size?: number): string {
  if (size === undefined || size < 0) {
    return '—';
  }
  if (size < 1024) {
    return `${size} B`;
  }

  const units = ['KB', 'MB', 'GB', 'TB'];
  let value = size;
  let unitIndex = -1;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex += 1;
  }

  return `${value >= 10 ? value.toFixed(0) : value.toFixed(1)} ${units[unitIndex]}`;
}

function getAttachmentExtension(filename: string): string {
  const extension = filename.split('.').at(-1)?.trim();
  return extension && extension.length <= 5 ? extension.toUpperCase() : 'FILE';
}

function getAttachmentBadgeClass(filename: string, isMe: boolean): string {
  if (isMe) {
    return 'bg-white/15 text-white';
  }
  const ext = filename.split('.').at(-1)?.toLowerCase() ?? '';
  switch (ext) {
    case '7z':
    case 'gz':
    case 'rar':
    case 'tar':
    case 'zip': {
      return 'bg-orange-500/15 text-orange-500 dark:bg-orange-500/20 dark:text-orange-400';
    }
    case 'csv':
    case 'xls':
    case 'xlsx': {
      return 'bg-emerald-500/15 text-emerald-500 dark:bg-emerald-500/20 dark:text-emerald-400';
    }
    case 'doc':
    case 'docx': {
      return 'bg-blue-500/15 text-blue-500 dark:bg-blue-500/20 dark:text-blue-400';
    }
    case 'pdf': {
      return 'bg-red-500/15 text-red-500 dark:bg-red-500/20 dark:text-red-400';
    }
    case 'ppt':
    case 'pptx': {
      return 'bg-amber-500/15 text-amber-500 dark:bg-amber-500/20 dark:text-amber-400';
    }
    default: {
      return 'bg-primary/10 text-primary';
    }
  }
}

function getAttachmentKey(messageId: string, attachmentIndex: number): string {
  return `${messageId}-${attachmentIndex}`;
}

async function handleAttachmentDownload(
  messageId: string,
  attachmentIndex: number,
): Promise<void> {
  if (downloadingAttachmentKey.value !== null) {
    return;
  }

  const key = getAttachmentKey(messageId, attachmentIndex);
  downloadingAttachmentKey.value = key;
  try {
    await props.downloadAttachment(messageId, attachmentIndex);
  } finally {
    if (downloadingAttachmentKey.value === key) {
      downloadingAttachmentKey.value = null;
    }
  }
}

const store = useChatStore();
const { previewFile, previewImage } = useFilePreview();
const loadedImageUrls = ref(new Map<string, string>());
const loadingImageKeys = ref(new Set<string>());

async function ensureImageUrl(
  messageId: string,
  attachmentIndex: number,
): Promise<string | undefined> {
  const key = getAttachmentKey(messageId, attachmentIndex);
  if (loadedImageUrls.value.has(key)) {
    return loadedImageUrls.value.get(key);
  }
  if (loadingImageKeys.value.has(key)) {
    return undefined;
  }
  loadingImageKeys.value.add(key);
  try {
    const url = await store.getAttachmentUrl(messageId, attachmentIndex);
    loadedImageUrls.value.set(key, url);
    return url;
  } catch (error) {
    console.error('Failed to load image attachment URL:', error);
    return undefined;
  } finally {
    loadingImageKeys.value.delete(key);
  }
}

watch(
  () => props.messages,
  (msgs) => {
    for (const msg of msgs) {
      if (!msg.attachments) continue;
      msg.attachments.forEach((att, idx) => {
        if (att.msgtype === 'm.image') {
          void ensureImageUrl(msg.id, idx);
        }
      });
    }
  },
  { deep: true, immediate: true },
);

async function handleImageClick(
  messageId: string,
  attachmentIndex: number,
  filename: string,
): Promise<void> {
  const key = getAttachmentKey(messageId, attachmentIndex);
  let url = loadedImageUrls.value.get(key);
  if (!url) {
    url = await ensureImageUrl(messageId, attachmentIndex);
  }
  if (url) {
    previewImage(url, filename);
  }
}

async function handleAttachmentClick(
  messageId: string,
  attachmentIndex: number,
  attachment: ChatMessageAttachment,
): Promise<void> {
  const type = detectFileType(attachment.filename, attachment.info?.mimetype);
  if (type === 'unsupported') {
    void handleAttachmentDownload(messageId, attachmentIndex);
    return;
  }
  try {
    const url = await store.getAttachmentUrl(messageId, attachmentIndex);
    if (url) {
      await previewFile({
        filename: attachment.filename || 'File',
        mimeType: attachment.info?.mimetype,
        size: formatAttachmentSize(attachment.info?.size),
        url,
      });
    }
  } catch (error) {
    console.error('Failed to preview attachment:', error);
  }
}

onMounted(() => {
  if (!props.isLoadingMessages) {
    scrollToBottom();
  }
});

watch(
  [() => props.messages.length, () => props.messages.at(-1)?.id],
  ([newLength, newLastMessageId], [oldLength, oldLastMessageId]) => {
    if (
      props.isLoadingMessages ||
      props.isLoadingOlder ||
      newLength <= oldLength
    ) {
      return;
    }

    if (newLength - oldLength === 1 || newLastMessageId !== oldLastMessageId) {
      scrollToBottom();
    }
  },
);

const showSkeleton = ref(props.isLoadingMessages);
let skeletonTimer: null | ReturnType<typeof setTimeout> = null;
let skeletonStartedAt = props.isLoadingMessages ? Date.now() : 0;

watch(
  () => props.isLoadingMessages,
  (val) => {
    if (val) {
      skeletonStartedAt = Date.now();
      showSkeleton.value = true;
      if (skeletonTimer) {
        clearTimeout(skeletonTimer);
        skeletonTimer = null;
      }
    } else {
      const elapsed = Date.now() - skeletonStartedAt;
      const remaining = Math.max(0, 1000 - elapsed);
      if (remaining > 0) {
        skeletonTimer = setTimeout(() => {
          showSkeleton.value = false;
          skeletonTimer = null;
        }, remaining);
      } else {
        showSkeleton.value = false;
      }
    }
  },
  { immediate: true },
);

watch(
  () => showSkeleton.value,
  (isLoading, wasLoading) => {
    if (wasLoading && !isLoading) {
      scrollToBottom();
    }
  },
);

onUnmounted(() => {
  if (skeletonTimer) {
    clearTimeout(skeletonTimer);
    skeletonTimer = null;
  }
});

watch(
  () => props.isLoadingOlder,
  (isLoading, wasLoading) => {
    if (!wasLoading || isLoading || olderMessagesScrollHeight.value === null) {
      return;
    }

    const previousScrollHeight = olderMessagesScrollHeight.value;
    olderMessagesScrollHeight.value = null;
    nextTick(() => {
      if (!containerRef.value) return;
      const addedHeight =
        containerRef.value.scrollHeight - previousScrollHeight;
      if (addedHeight > 0) {
        containerRef.value.scrollTop += addedHeight;
      }
    });
  },
);

watch(
  () => props.pinnedEventIds,
  (eventIds) => {
    if (eventIds.length === 0) {
      isPinnedBannerExpanded.value = false;
    }
  },
  { deep: true },
);

defineExpose({
  scrollToBottom,
  scrollToMessage,
});
</script>

<template>
  <div class="flex min-h-0 flex-1 flex-col">
    <div
      v-if="pinnedEventIds.length > 0"
      class="shrink-0 border-b border-border/60 bg-card/80 px-3 py-1.5 backdrop-blur-xs transition-colors"
    >
      <div class="flex items-center justify-between gap-2">
        <div
          role="button"
          tabindex="0"
          class="flex min-w-0 flex-1 cursor-pointer items-center gap-2.5 rounded-md px-1.5 py-1 text-left transition-colors hover:bg-accent/50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/40"
          :aria-label="$t('chat.pinnedTitle')"
          @click="
            latestPinnedMessage
              ? handlePinnedMessageClick(latestPinnedMessage.id)
              : (isPinnedBannerExpanded = !isPinnedBannerExpanded)
          "
          @keydown.enter.prevent="
            latestPinnedMessage
              ? handlePinnedMessageClick(latestPinnedMessage.id)
              : (isPinnedBannerExpanded = !isPinnedBannerExpanded)
          "
          @keydown.space.prevent="
            latestPinnedMessage
              ? handlePinnedMessageClick(latestPinnedMessage.id)
              : (isPinnedBannerExpanded = !isPinnedBannerExpanded)
          "
        >
          <IconifyIcon
            icon="lucide:message-circle-more"
            class="size-5 shrink-0 text-primary"
          />

          <div
            class="flex min-w-0 flex-1 flex-col items-start justify-center text-left"
          >
            <div class="flex items-center gap-1.5 leading-tight">
              <span class="text-xs font-semibold text-foreground">
                {{ $t('chat.pinnedTitle') }}
              </span>
              <span
                v-if="pinnedEventIds.length > 1"
                class="rounded-full bg-primary/10 px-1.5 py-0.2 text-[10px] font-semibold text-primary"
              >
                {{ pinnedEventIds.length }}
              </span>
            </div>

            <div
              class="w-full truncate text-xs text-muted-foreground mt-0.5 text-left leading-tight"
            >
              <span v-if="latestPinnedMessage">
                <span
                  v-if="latestPinnedMessage.senderName"
                  class="font-medium text-foreground/90"
                >
                  {{ getSenderDisplayName(latestPinnedMessage) }}:
                </span>
                {{
                  latestPinnedMessage.isRedacted
                    ? $t('chat.messageRedacted')
                    : latestPinnedMessage.body || $t('chat.pinnedMessage')
                }}
              </span>
              <Spin
                v-else-if="isLoadingMessages || isLoadingOlder"
                size="small"
              />
              <span v-else>{{ $t('chat.pinnedMessage') }}</span>
            </div>
          </div>
        </div>

        <Tooltip :title="$t('chat.pinnedTitle')">
          <Button
            type="text"
            shape="circle"
            size="small"
            class="flex size-7 shrink-0 items-center justify-center !rounded-md text-muted-foreground transition-colors hover:!bg-accent hover:text-foreground focus-visible:ring-2 focus-visible:ring-primary/20"
            :aria-expanded="isPinnedBannerExpanded"
            :aria-label="$t('chat.pinnedTitle')"
            @click="isPinnedBannerExpanded = true"
          >
            <template #icon>
              <IconifyIcon icon="lucide:list" class="size-4" />
            </template>
          </Button>
        </Tooltip>
      </div>
    </div>

    <!-- Pinned Messages Modal -->
    <Modal
      :open="isPinnedBannerExpanded"
      :title="$t('chat.pinnedTitle')"
      :footer="null"
      destroy-on-close
      width="480px"
      @cancel="isPinnedBannerExpanded = false"
    >
      <div class="space-y-1.5 pt-2">
        <div
          v-if="pinnedEventIds.length === 0"
          class="py-8 text-center text-xs text-muted-foreground"
        >
          {{ $t('chat.pinnedMessage') }}
        </div>

        <div
          v-else
          class="max-h-[60vh] divide-y divide-border/40 overflow-y-auto pr-1"
        >
          <div
            v-for="eventId in pinnedEventIds"
            :key="eventId"
            role="button"
            tabindex="0"
            class="group/item flex w-full cursor-pointer items-start gap-3 rounded-lg p-2.5 text-left transition-colors hover:bg-accent/50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/40"
            @click="handlePinnedModalItemClick(eventId)"
            @keydown.enter.prevent="handlePinnedModalItemClick(eventId)"
            @keydown.space.prevent="handlePinnedModalItemClick(eventId)"
          >
            <Avatar
              :size="32"
              :src="
                pinnedMessagesById.get(eventId)
                  ? getSenderAvatarSrc(pinnedMessagesById.get(eventId)!)
                  : undefined
              "
              class="shrink-0 text-xs font-medium bg-primary/15 text-primary"
            >
              {{
                pinnedMessagesById.get(eventId)
                  ? getSenderInitials(getPinnedSenderDisplayName(eventId))
                  : ''
              }}
            </Avatar>

            <div class="min-w-0 flex-1 space-y-1 text-left">
              <div
                class="flex items-center justify-between gap-2 leading-tight"
              >
                <span class="truncate text-xs font-semibold text-foreground">
                  {{ getPinnedSenderDisplayName(eventId) }}
                </span>
                <span
                  v-if="pinnedMessagesById.get(eventId)?.timestamp"
                  class="shrink-0 text-[11px] text-muted-foreground/60"
                >
                  {{
                    dayjs(pinnedMessagesById.get(eventId)?.timestamp).format(
                      'HH:mm · DD/MM/YYYY',
                    )
                  }}
                </span>
              </div>

              <p
                class="text-xs text-muted-foreground leading-relaxed line-clamp-3 break-words"
              >
                {{
                  pinnedMessagesById.get(eventId)?.isRedacted
                    ? $t('chat.messageRedacted')
                    : pinnedMessagesById.get(eventId)?.body ||
                      $t('chat.pinnedMessage')
                }}
              </p>
            </div>

            <div
              class="flex size-6 shrink-0 items-center justify-center rounded-md text-muted-foreground/40 transition-colors group-hover/item:text-primary group-hover/item:bg-primary/10"
            >
              <IconifyIcon icon="lucide:corner-down-right" class="size-3.5" />
            </div>
          </div>
        </div>
      </div>
    </Modal>

    <div
      ref="containerRef"
      class="chat-message-list flex-1 space-y-5 overflow-y-auto bg-muted/35 px-4 py-4 dark:bg-card/20 sm:px-6"
      @scroll="handleScroll"
    >
      <!-- Messages Loading Skeleton -->
      <div
        v-if="showSkeleton"
        class="flex min-h-full flex-col justify-center space-y-3 py-2 select-none"
        :aria-label="$t('chat.loadingMessages')"
      >
        <!-- Message Skeleton 1: Incoming -->
        <div class="relative flex items-end gap-2">
          <div class="size-8 shrink-0">
            <SkeletonAvatar active size="default" shape="circle" />
          </div>
          <div
            class="h-10 w-48 rounded-2xl rounded-bl-md bg-muted-foreground/15 animate-pulse"
          ></div>
        </div>

        <!-- Message Skeleton 2: Outgoing (Me) -->
        <div class="relative flex justify-end">
          <div
            class="h-10 w-40 rounded-2xl rounded-br-md bg-primary/15 animate-pulse"
          ></div>
        </div>

        <!-- Message Skeleton 3: Incoming Multiline -->
        <div class="relative flex items-end gap-2">
          <div class="size-8 shrink-0">
            <SkeletonAvatar active size="default" shape="circle" />
          </div>
          <div
            class="h-16 w-64 rounded-2xl rounded-bl-md bg-muted-foreground/15 animate-pulse"
          ></div>
        </div>

        <!-- Message Skeleton 4: Outgoing (Me) Multiline -->
        <div class="relative flex justify-end">
          <div
            class="h-16 w-56 rounded-2xl rounded-br-md bg-primary/15 animate-pulse"
          ></div>
        </div>

        <!-- Message Skeleton 5: Incoming -->
        <div class="relative flex items-end gap-2">
          <div class="size-8 shrink-0">
            <SkeletonAvatar active size="default" shape="circle" />
          </div>
          <div
            class="h-10 w-52 rounded-2xl rounded-bl-md bg-muted-foreground/15 animate-pulse"
          ></div>
        </div>
      </div>

      <template v-else-if="messages.length > 0">
        <!-- Loading Older Messages Spinner -->
        <div
          v-if="isLoadingOlder"
          class="flex justify-center py-2 text-muted-foreground"
        >
          <Spin size="small" />
        </div>

        <!-- Date Grouped Message List -->
        <div
          v-for="group in groupedMessages"
          :key="group.date"
          class="space-y-4"
        >
          <!-- Date Divider -->
          <Divider
            plain
            class="!my-0 !text-xs text-muted-foreground select-none"
          >
            <span
              class="rounded-full bg-muted/80 px-2.5 py-0.5 text-[11px] font-medium text-muted-foreground"
            >
              {{ formatDateDivider(group.date) }}
            </span>
          </Divider>

          <div
            v-for="cluster in group.clusters"
            :key="
              cluster.isSystem
                ? `sys-${cluster.firstMessage.id}`
                : `${cluster.senderId}-${cluster.firstMessage.id}`
            "
            class="space-y-1"
          >
            <!-- Zalo-style Group System Notification -->
            <div
              v-if="cluster.isSystem"
              class="my-3 flex w-full justify-center select-none"
            >
              <div
                v-for="msg in cluster.messages"
                :id="`msg-${msg.id}`"
                :key="msg.id"
                class="inline-flex max-w-[85%] items-center gap-1.5 rounded-full bg-muted/70 border-0 px-3.5 py-1 text-center font-normal text-xs text-muted-foreground shadow-none backdrop-blur-xs dark:bg-card/50"
              >
                <IconifyIcon
                  :icon="getSystemEventIcon(msg)"
                  class="size-3.5 shrink-0 text-muted-foreground/80"
                />
                <span class="leading-relaxed">{{
                  getSystemEventText(msg)
                }}</span>
              </div>
            </div>

            <template v-else>
              <span
                v-if="!cluster.isMe && !isDirect"
                class="block pl-10 text-xs font-medium text-muted-foreground select-none"
              >
                {{ getSenderDisplayName(cluster.firstMessage) }}
              </span>

              <div
                v-for="(msg, messageIndex) in cluster.messages"
                :id="`msg-${msg.id}`"
                :key="msg.id"
                class="group/message relative flex w-full items-end"
                :class="[
                  msg.isMe ? 'justify-end' : 'justify-start',
                  highlightedEventId === msg.id ? 'bg-primary/5' : '',
                ]"
              >
                <div
                  v-if="!msg.isMe"
                  class="mr-2 flex size-8 shrink-0 items-end justify-center"
                >
                  <Avatar
                    v-if="messageIndex === cluster.messages.length - 1"
                    :size="32"
                    :src="getSenderAvatarSrc(msg)"
                    class="cursor-pointer overflow-hidden border-0 font-semibold text-xs shadow-none transition-transform hover:scale-105 bg-primary/10 text-primary"
                    @error="() => handleAvatarError(msg)"
                  >
                    <span v-if="getSenderInitials(getSenderDisplayName(msg))">{{
                      getSenderInitials(getSenderDisplayName(msg))
                    }}</span>
                    <IconifyIcon
                      v-else
                      icon="lucide:user"
                      class="size-4 opacity-80"
                    />
                  </Avatar>
                </div>

                <div
                  class="relative min-w-0 w-fit max-w-[min(calc(100vw/3),85%)]"
                  :class="
                    msg.isMe
                      ? 'flex flex-col items-end'
                      : 'flex flex-col items-start'
                  "
                >
                  <div class="relative w-fit max-w-full">
                    <div
                      class="chat-message-bubble text-sm leading-relaxed"
                      :class="[
                        isPureImageMessage(msg)
                          ? '!border-0 !bg-transparent !p-0 !shadow-none'
                          : [
                              'px-3.5 py-2 shadow-xs',
                              msg.isRedacted
                                ? 'border border-border/50 bg-muted/70 text-muted-foreground'
                                : msg.isMe
                                  ? 'border border-primary bg-primary text-primary-foreground'
                                  : 'border border-border/70 bg-card text-card-foreground dark:bg-muted/40',
                              getBubbleShapeClass(
                                msg.isMe,
                                messageIndex === 0,
                                messageIndex === cluster.messages.length - 1,
                              ),
                            ],
                        msg.isMe ? 'self-end' : 'self-start',
                      ]"
                    >
                      <div
                        v-if="msg.replyTo && !msg.isRedacted"
                        role="button"
                        tabindex="0"
                        class="mb-1.5 flex min-w-0 max-w-full cursor-pointer items-center rounded-lg px-2.5 py-1.5 text-xs transition-colors focus-visible:outline-none focus-visible:ring-2"
                        :class="
                          msg.isMe
                            ? 'bg-black/15 text-white hover:bg-black/25 focus-visible:ring-white/50'
                            : 'bg-primary/5 text-foreground hover:bg-primary/10 focus-visible:ring-primary/40 dark:bg-primary/10 dark:hover:bg-primary/15'
                        "
                        @click="scrollToMessage(msg.replyTo.id)"
                        @keydown.enter="scrollToMessage(msg.replyTo.id)"
                        @keydown.space.prevent="scrollToMessage(msg.replyTo.id)"
                      >
                        <div class="min-w-0 flex-1">
                          <div
                            class="truncate text-xs font-semibold leading-4"
                            :class="msg.isMe ? 'text-white' : 'text-primary'"
                          >
                            {{
                              getReplySenderDisplayName(msg.replyTo.senderName)
                            }}
                          </div>
                          <div
                            class="truncate text-xs leading-4"
                            :class="
                              msg.isMe
                                ? 'text-white/85'
                                : 'text-muted-foreground'
                            "
                          >
                            {{ msg.replyTo.body || $t('chat.messageRedacted') }}
                          </div>
                        </div>
                      </div>

                      <div
                        v-if="msg.isRedacted"
                        class="flex items-center gap-1.5 text-xs italic select-none"
                      >
                        <span>{{ $t('chat.messageRedacted') }}</span>
                      </div>

                      <div
                        v-else-if="msg.decryptionStatus === 'failed'"
                        class="flex items-center gap-1.5 text-xs italic select-none"
                      >
                        <IconifyIcon
                          icon="lucide:lock-keyhole"
                          class="size-3.5"
                        />
                        <span>{{
                          $t('chat.encryption.decryptionFailed')
                        }}</span>
                      </div>

                      <div
                        v-else-if="msg.decryptionStatus === 'pending'"
                        class="flex items-center gap-1.5 text-xs italic select-none"
                      >
                        <IconifyIcon
                          icon="lucide:loader-circle"
                          class="size-3.5 animate-spin"
                        />
                        <span>{{ $t('chat.encryption.decrypting') }}</span>
                      </div>

                      <div
                        v-if="msg.attachments && msg.attachments.length > 0"
                        class="space-y-2"
                        :class="[
                          msg.replyTo ? 'mt-1.5' : '',
                          msg.isMe
                            ? 'flex flex-col items-end'
                            : 'flex flex-col items-start',
                        ]"
                      >
                        <div
                          v-for="(
                            attachment, attachmentIndex
                          ) in msg.attachments"
                          :key="getAttachmentKey(msg.id, attachmentIndex)"
                          class="max-w-full overflow-hidden text-left"
                          :class="[
                            isPureImageMessage(msg)
                              ? [
                                  'w-fit shadow-xs',
                                  getBubbleShapeClass(
                                    msg.isMe,
                                    messageIndex === 0,
                                    messageIndex ===
                                      cluster.messages.length - 1,
                                  ),
                                ]
                              : [
                                  'w-[min(100%,26rem)] rounded-lg border',
                                  msg.isMe
                                    ? 'border-white/20 bg-black/10'
                                    : 'border-border/70 bg-muted/25 dark:bg-black/10',
                                ],
                            msg.isMe ? 'ml-auto' : 'mr-auto',
                          ]"
                          :aria-busy="
                            downloadingAttachmentKey ===
                            getAttachmentKey(msg.id, attachmentIndex)
                          "
                        >
                          <!-- Image Attachment: Image thumbnail only -->
                          <div
                            v-if="attachment.msgtype === 'm.image'"
                            class="group/img relative flex max-h-80 min-h-28 cursor-pointer items-center justify-center overflow-hidden"
                            :class="[
                              isPureImageMessage(msg)
                                ? [
                                    'w-fit',
                                    getBubbleShapeClass(
                                      msg.isMe,
                                      messageIndex === 0,
                                      messageIndex ===
                                        cluster.messages.length - 1,
                                    ),
                                  ]
                                : 'w-full rounded-md bg-black/5 dark:bg-white/5',
                            ]"
                            @click="
                              void handleImageClick(
                                msg.id,
                                attachmentIndex,
                                attachment.filename,
                              )
                            "
                          >
                            <img
                              v-if="
                                loadedImageUrls.get(
                                  getAttachmentKey(msg.id, attachmentIndex),
                                )
                              "
                              :src="
                                loadedImageUrls.get(
                                  getAttachmentKey(msg.id, attachmentIndex),
                                )
                              "
                              :alt="attachment.filename"
                              class="max-h-80 w-auto max-w-full object-contain transition-transform duration-200 group-hover/img:scale-102"
                              :class="
                                isPureImageMessage(msg)
                                  ? getBubbleShapeClass(
                                      msg.isMe,
                                      messageIndex === 0,
                                      messageIndex ===
                                        cluster.messages.length - 1,
                                    )
                                  : ''
                              "
                            />
                            <div
                              v-else-if="
                                loadingImageKeys.has(
                                  getAttachmentKey(msg.id, attachmentIndex),
                                )
                              "
                              class="flex h-28 items-center justify-center"
                            >
                              <Spin size="small" />
                            </div>
                            <div
                              v-else
                              class="flex h-28 items-center justify-center"
                            >
                              <IconifyIcon
                                icon="lucide:image"
                                class="size-14"
                                :class="
                                  msg.isMe
                                    ? 'text-white/30'
                                    : 'text-muted-foreground/30'
                                "
                              />
                            </div>
                            <div
                              class="absolute inset-0 flex items-center justify-center bg-black/25 opacity-0 transition-opacity group-hover/img:opacity-100"
                            >
                              <IconifyIcon
                                icon="lucide:maximize-2"
                                class="size-6 text-white drop-shadow-md"
                              />
                            </div>
                          </div>

                          <!-- Document / Non-Image File Attachment: Compact file card -->
                          <div
                            v-else
                            class="flex min-w-0 cursor-pointer items-center gap-2.5 p-2.5 transition-colors hover:bg-black/5 dark:hover:bg-white/5"
                            @click="
                              void handleAttachmentClick(
                                msg.id,
                                attachmentIndex,
                                attachment,
                              )
                            "
                          >
                            <div
                              class="flex size-10 shrink-0 items-center justify-center rounded-md text-[10px] font-bold uppercase shadow-2xs"
                              :class="
                                getAttachmentBadgeClass(
                                  attachment.filename,
                                  msg.isMe,
                                )
                              "
                            >
                              {{ getAttachmentExtension(attachment.filename) }}
                            </div>

                            <div class="min-w-0 flex-1">
                              <div class="truncate text-xs font-semibold">
                                {{ attachment.filename || $t('chat.files') }}
                              </div>
                              <div
                                class="mt-0.5 flex min-w-0 items-center gap-1 text-[11px]"
                                :class="
                                  msg.isMe
                                    ? 'text-white/65'
                                    : 'text-muted-foreground'
                                "
                              >
                                <span v-if="attachment.info.size !== undefined">
                                  {{
                                    formatAttachmentSize(attachment.info.size)
                                  }}
                                </span>
                                <span v-if="attachment.info.size !== undefined">
                                  ·
                                </span>
                                <span class="truncate">{{
                                  $t('chat.fileAvailableInCloud')
                                }}</span>
                              </div>
                            </div>

                            <Button
                              type="text"
                              shape="circle"
                              size="small"
                              class="flex size-8 shrink-0 items-center justify-center !rounded-md"
                              :class="
                                msg.isMe
                                  ? '!text-white hover:!bg-white/15'
                                  : '!text-foreground hover:!bg-accent'
                              "
                              :loading="
                                downloadingAttachmentKey ===
                                getAttachmentKey(msg.id, attachmentIndex)
                              "
                              :disabled="downloadingAttachmentKey !== null"
                              :aria-label="$t('chat.downloadFile')"
                              @click.stop="
                                void handleAttachmentDownload(
                                  msg.id,
                                  attachmentIndex,
                                )
                              "
                            >
                              <template #icon>
                                <IconifyIcon
                                  icon="lucide:download"
                                  class="size-4"
                                />
                              </template>
                            </Button>
                          </div>
                        </div>
                      </div>

                      <p
                        v-if="
                          !msg.isRedacted &&
                          msg.decryptionStatus !== 'failed' &&
                          msg.decryptionStatus !== 'pending' &&
                          !msg.attachments?.some(
                            (attachment) => attachment.filename === msg.body,
                          )
                        "
                        class="break-words [overflow-wrap:anywhere] text-left leading-relaxed"
                        :class="
                          msg.attachments && msg.attachments.length > 0
                            ? 'mt-2'
                            : ''
                        "
                      >
                        <template
                          v-for="(seg, segIdx) in parseMessageSegments(
                            msg.body,
                          )"
                          :key="segIdx"
                        >
                          <a
                            v-if="seg.isUrl"
                            :href="seg.href"
                            target="_blank"
                            rel="noopener noreferrer"
                            class="chat-msg-link inline font-medium break-all [overflow-wrap:anywhere]"
                            :class="
                              msg.isMe
                                ? 'chat-msg-link-me'
                                : 'chat-msg-link-other'
                            "
                            @click.stop
                          >
                            <template
                              v-for="(h, hIdx) in getHighlightSegments(
                                seg.text,
                                searchQuery,
                              )"
                              :key="hIdx"
                            >
                              <!-- eslint-disable vue/html-closing-bracket-newline -->
                              <mark
                                v-if="h.isMatch"
                                class="chat-search-match"
                                >{{ h.text }}</mark
                              >
                              <!-- eslint-enable vue/html-closing-bracket-newline -->
                              <span v-else>{{ h.text }}</span>
                            </template>
                            <IconifyIcon
                              icon="lucide:external-link"
                              class="inline size-3 ml-0.5 align-baseline opacity-80"
                            />
                          </a>
                          <template v-else>
                            <template
                              v-for="(h, hIdx) in getHighlightSegments(
                                seg.text,
                                searchQuery,
                              )"
                              :key="hIdx"
                            >
                              <!-- eslint-disable vue/html-closing-bracket-newline -->
                              <mark
                                v-if="h.isMatch"
                                class="chat-search-match"
                                >{{ h.text }}</mark
                              >
                              <!-- eslint-enable vue/html-closing-bracket-newline -->
                              <span v-else class="whitespace-pre-wrap">{{
                                h.text
                              }}</span>
                            </template>
                          </template>
                        </template>
                      </p>
                    </div>

                    <!-- Reaction button and badges at bottom-right corner (matches media_1789591397246.png) -->
                    <!-- Reaction badges at bottom-right corner -->
                    <div
                      v-if="
                        !msg.isRedacted &&
                        msg.status === 'sent' &&
                        msg.reactions &&
                        msg.reactions.length > 0
                      "
                      role="button"
                      tabindex="0"
                      class="absolute -bottom-2.5 -right-2.5 z-10 inline-flex cursor-pointer items-center gap-1 rounded-full bg-white px-2 py-0.5 text-xs text-slate-800 shadow-sm transition-transform select-none hover:scale-105 dark:bg-neutral-800 dark:text-neutral-200"
                      @click.stop="openReactionDetails(msg)"
                      @keydown.enter.stop="openReactionDetails(msg)"
                      @keydown.space.stop.prevent="openReactionDetails(msg)"
                    >
                      <span
                        v-for="reaction in msg.reactions"
                        :key="reaction.key"
                        :aria-label="formatReactionTooltip(reaction)"
                      >
                        {{ reaction.key }}
                      </span>
                      <span
                        v-if="
                          msg.reactions.reduce(
                            (sum, reaction) => sum + reaction.count,
                            0,
                          ) > 1
                        "
                        class="text-[11px] font-semibold"
                      >
                        {{
                          msg.reactions.reduce(
                            (sum, reaction) => sum + reaction.count,
                            0,
                          )
                        }}
                      </span>
                    </div>
                  </div>

                  <div
                    v-if="
                      messageIndex === cluster.messages.length - 1 ||
                      revealedTimestampIds.has(msg.id)
                    "
                    class="mt-1 flex items-center gap-1 px-1 text-[11px] leading-3 text-muted-foreground select-none"
                    :class="[
                      msg.isMe
                        ? 'justify-end self-end'
                        : 'justify-start self-start',
                    ]"
                  >
                    <span>{{ dayjs(msg.timestamp).format('HH:mm') }}</span>

                    <template v-if="msg.isMe">
                      <span
                        v-if="msg.status === 'sent' && msg.isRead"
                        class="inline-flex items-center"
                        :aria-label="
                          msg.readers && msg.readers.length > 0
                            ? $t('chat.seenBy', {
                                users: msg.readers
                                  .map((r) =>
                                    getMemberDisplayName(
                                      r.userId,
                                      r.displayName,
                                    ),
                                  )
                                  .join(', '),
                              })
                            : $t('chat.seen')
                        "
                      >
                        <IconifyIcon
                          icon="lucide:check-check"
                          class="size-3 text-primary"
                        />
                      </span>
                      <IconifyIcon
                        v-else-if="msg.status === 'sent'"
                        icon="lucide:check"
                        class="size-3 text-primary"
                      />
                      <IconifyIcon
                        v-else-if="msg.status === 'sending'"
                        icon="lucide:clock"
                        class="size-3"
                      />
                      <IconifyIcon
                        v-else-if="msg.status === 'error'"
                        icon="lucide:alert-circle"
                        class="size-3 text-destructive"
                      />
                    </template>
                  </div>

                  <ChatMessageActions
                    :message="msg"
                    :can-pin="canPinMessages"
                    :is-pinned="pinnedEventIds.includes(msg.id)"
                    :is-last-in-cluster="
                      messageIndex === cluster.messages.length - 1
                    "
                    @react="
                      (m: ChatMessageItem, emoji: string) =>
                        emit('toggleReaction', m, emoji)
                    "
                    @reply="emit('reply', $event)"
                    @toggle-timestamp="toggleMessageTimestamp(msg.id)"
                    @redact="emit('redact', $event)"
                  />
                </div>
              </div>
            </template>
          </div>
        </div>

        <!-- Typing Indicator at Bottom of Message List -->
        <div
          v-if="resolvedTypingUsers.length > 0"
          class="flex w-full items-end justify-start transition-opacity duration-200 select-none"
          data-testid="chat-typing-indicator"
          role="status"
          aria-live="polite"
          :aria-label="formatTypingIndicatorText(resolvedTypingUsers)"
        >
          <div class="mr-2 flex size-8 shrink-0 items-end justify-center">
            <Avatar
              :size="32"
              :src="getTypingAvatarSrc(resolvedTypingUsers[0])"
              class="overflow-hidden border-0 bg-primary/10 text-xs font-semibold text-primary shadow-none"
            >
              <span
                v-if="getSenderInitials(resolvedTypingUsers[0]?.displayName)"
                >{{ getSenderInitials(resolvedTypingUsers[0]?.displayName) }}
              </span>
              <IconifyIcon
                v-else
                icon="lucide:user"
                class="size-4 opacity-80"
              />
            </Avatar>
          </div>
          <div
            class="inline-flex items-center gap-1 rounded-2xl rounded-bl-md border border-border/60 bg-card px-3.5 py-3 shadow-xs dark:border-border/50 dark:bg-accent/70"
          >
            <span
              class="size-1.5 rounded-full bg-primary/70 animate-bounce [animation-delay:-0.3s]"
            ></span>
            <span
              class="size-1.5 rounded-full bg-primary/70 animate-bounce [animation-delay:-0.15s]"
            ></span>
            <span
              class="size-1.5 rounded-full bg-primary/70 animate-bounce"
            ></span>
          </div>
        </div>
      </template>

      <!-- Empty conversation placeholder -->
      <div
        v-else
        class="flex h-full flex-col items-center justify-center p-8 text-center select-none"
      >
        <div class="flex flex-col items-center gap-3">
          <ChatGroupAvatar
            v-if="!isDirect"
            :members="groupMemberAvatars"
            :size="56"
            :total-count="memberCount"
          />
          <Avatar
            v-else
            :size="56"
            :src="avatarUrl"
            class="font-semibold text-base shadow-xs"
            :class="
              isDirect ? 'bg-blue-500 text-white' : 'bg-primary/20 text-primary'
            "
          >
            <template #icon>
              <IconifyIcon
                :icon="isDirect ? 'lucide:message-square' : 'lucide:users'"
                class="size-6"
              />
            </template>
          </Avatar>

          <div class="space-y-1">
            <h3 class="text-sm font-semibold text-foreground">
              {{
                isDirect
                  ? $t('chat.startConversation')
                  : $t('chat.startGroupConversation')
              }}
            </h3>
            <p class="mx-auto max-w-xs text-xs text-muted-foreground">
              {{
                isDirect
                  ? $t('chat.startConversationHint')
                  : $t('chat.startGroupConversationHint')
              }}
            </p>
          </div>
        </div>
      </div>
    </div>

    <ChatReactionDetailsModal
      v-model:open="isReactionDetailsModalOpen"
      :colleagues="colleagues"
      :message="reactionDetailsMessage"
      @toggle-reaction="
        (m: ChatMessageItem, emoji: string) => emit('toggleReaction', m, emoji)
      "
    />
  </div>
</template>

<style scoped>
.chat-search-match {
  @apply rounded-xs bg-amber-300 px-0.5 font-medium whitespace-pre-wrap text-black dark:bg-amber-500;
}

.chat-msg-link-me {
  color: #fff !important;
  text-decoration: underline !important;
  text-decoration-color: rgb(255 255 255 / 70%) !important;
  text-underline-offset: 2px !important;
}

.chat-msg-link-me:hover {
  color: #fff !important;
  text-decoration-color: #fff !important;
  opacity: 0.9;
}

.chat-msg-link-other {
  color: #1677ff !important;
  text-decoration: underline !important;
  text-decoration-color: rgb(22 119 255 / 50%) !important;
  text-underline-offset: 2px !important;
}

.chat-msg-link-other:hover {
  color: #0958d9 !important;
  text-decoration-color: #1677ff !important;
}

:global(.dark) .chat-msg-link-other {
  color: #38bdf8 !important;
  text-decoration-color: rgb(56 189 248 / 50%) !important;
}

:global(.dark) .chat-msg-link-other:hover {
  color: #7dd3fc !important;
  text-decoration-color: #38bdf8 !important;
}
</style>

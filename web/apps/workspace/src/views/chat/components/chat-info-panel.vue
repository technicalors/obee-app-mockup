<script setup lang="ts">
import type { LinkItem } from '../composables/use-chat-links';
import type { GroupMemberAvatarInfo } from '../types';

import type { User } from '#/api';
import type { ChatMessageItem } from '#/store';

import { computed, nextTick, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Avatar, Button, Popconfirm, Spin } from 'ant-design-vue';
import dayjs from 'dayjs';

import { $t } from '#/locales';
import { useChatStore } from '#/store';

import { extractUrls, getDomainFromUrl } from '../composables/use-chat-links';
import {
  detectFileType,
  useFilePreview,
} from '../composables/use-file-preview';
import ChatGroupAvatar from './chat-group-avatar.vue';

interface Props {
  avatarUrl?: string;
  canDeleteGroup?: boolean;
  colleagues?: User[];
  downloadAttachment?: (
    messageId: string,
    attachmentIndex: number,
  ) => Promise<void>;
  groupAction?: 'delete' | 'leave' | null;
  groupMemberAvatars?: GroupMemberAvatarInfo[];
  hasMoreHistory?: boolean;
  isDirect?: boolean;
  isMemberActionLoading?: boolean;
  isLoadingOlder?: boolean;
  isOpen?: boolean;
  loadOlderMessages?: (perPage: number) => Promise<boolean>;
  memberCount?: number;
  messages?: ChatMessageItem[];
  roomId?: null | string;
  title?: string;
}

const props = withDefaults(defineProps<Props>(), {
  avatarUrl: undefined,
  canDeleteGroup: false,
  colleagues: () => [],
  downloadAttachment: undefined,
  groupMemberAvatars: () => [],
  groupAction: null,
  hasMoreHistory: true,
  isDirect: true,
  isMemberActionLoading: false,
  isLoadingOlder: false,
  isOpen: true,
  loadOlderMessages: undefined,
  memberCount: 0,
  messages: () => [],
  roomId: null,
  title: '',
});

const emit = defineEmits<{
  close: [];
  createGroup: [];
  deleteGroup: [];
  leaveGroup: [];
  openMembers: [];
  toggleMute: [];
  togglePin: [];
}>();

const store = useChatStore();
const { previewFile, previewImage } = useFilePreview();

const ATTACHMENT_PAGE_SIZE = 30;
const MEDIA_PREVIEW_LIMIT = 6;
const FILE_PREVIEW_LIMIT = 5;
const LINK_PREVIEW_LIMIT = 5;
const ATTACHMENT_SCROLL_THRESHOLD = 80;
const attachmentBrowserTabs = ['media', 'files', 'links'] as const;

const isMediaExpanded = ref(true);
const isFilesExpanded = ref(true);
const isLinksExpanded = ref(true);
const isAllMediaShown = ref(false);
const isAllFilesShown = ref(false);
const isAllLinksShown = ref(false);
const isAttachmentBrowserOpen = ref(false);
const attachmentBrowserTab = ref<AttachmentBrowserTab>('media');
const isLoadingMoreAttachments = ref(false);

const panelBodyRef = ref<HTMLDivElement | null>(null);
const loadedImageUrls = ref(new Map<string, string>());
const loadingImageKeys = ref(new Set<string>());
const downloadingFileKey = ref<null | string>(null);

const initials = computed(() => {
  if (!props.title) return '';
  const clean = props.title.replaceAll(/[^\p{L}\p{N}\s]/gu, '').trim();
  const parts = clean.split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '';
  if (parts.length === 1) return parts[0]?.slice(0, 2).toUpperCase() ?? '';
  return `${parts[0]?.[0] ?? ''}${parts.at(-1)?.[0] ?? ''}`.toUpperCase();
});

interface MediaItem {
  attachmentIndex: number;
  filename: string;
  id: string;
  messageId: string;
  size?: number;
  timestamp: number;
}

interface FileItem {
  attachmentIndex: number;
  badgeBg: string;
  badgeText: string;
  date: string;
  filename: string;
  id: string;
  messageId: string;
  size: string;
  timestamp: number;
}

interface MediaGroup {
  dateKey: string;
  items: MediaItem[];
  label: string;
}

type AttachmentBrowserTab = 'files' | 'links' | 'media';

function getAttachmentExtension(filename: string): string {
  const ext = filename.split('.').at(-1)?.trim();
  return ext && ext.length <= 5 ? ext.toUpperCase() : 'FILE';
}

function getBadgeBg(ext: string): string {
  switch (ext) {
    case '7Z':
    case 'RAR':
    case 'TAR':
    case 'ZIP': {
      return 'bg-amber-500 text-white dark:bg-amber-600';
    }
    case 'CSV':
    case 'XLS':
    case 'XLSX': {
      return 'bg-emerald-500 text-white dark:bg-emerald-600';
    }
    case 'DOC':
    case 'DOCX': {
      return 'bg-indigo-500 text-white dark:bg-indigo-600';
    }
    case 'PDF': {
      return 'bg-rose-500 text-white dark:bg-rose-600';
    }
    case 'TXT': {
      return 'bg-cyan-500 text-white dark:bg-cyan-600';
    }
    default: {
      return 'bg-blue-500 text-white dark:bg-blue-600';
    }
  }
}

function formatAttachmentSize(size?: number): string {
  if (size === undefined || size < 0) return '—';
  if (size < 1024) return `${size} B`;
  const units = ['KB', 'MB', 'GB', 'TB'];
  let value = size;
  let unitIndex = -1;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex += 1;
  }
  return `${value >= 10 ? value.toFixed(0) : value.toFixed(1)} ${units[unitIndex]}`;
}

const mediaList = computed<MediaItem[]>(() => {
  const items: MediaItem[] = [];
  for (const msg of props.messages) {
    if (msg.isRedacted || !msg.attachments) continue;
    msg.attachments.forEach((att, idx) => {
      if (att.msgtype === 'm.image') {
        items.push({
          attachmentIndex: idx,
          filename: att.filename || 'image',
          id: `${msg.id}-${idx}`,
          messageId: msg.id,
          size: att.info.size,
          timestamp: msg.timestamp,
        });
      }
    });
  }
  return items.toReversed();
});

const fileList = computed<FileItem[]>(() => {
  const items: FileItem[] = [];
  for (const msg of props.messages) {
    if (msg.isRedacted || !msg.attachments) continue;
    msg.attachments.forEach((att, idx) => {
      if (att.msgtype === 'm.file') {
        const ext = getAttachmentExtension(att.filename);
        items.push({
          attachmentIndex: idx,
          badgeBg: getBadgeBg(ext),
          badgeText: ext,
          date: dayjs(msg.timestamp).format('DD/MM/YYYY'),
          filename: att.filename || 'file',
          id: `${msg.id}-${idx}`,
          messageId: msg.id,
          size: formatAttachmentSize(att.info.size),
          timestamp: msg.timestamp,
        });
      }
    });
  }
  return items.toReversed();
});

const displayedMediaList = computed(() => {
  return isAllMediaShown.value
    ? mediaList.value
    : mediaList.value.slice(0, MEDIA_PREVIEW_LIMIT);
});

const displayedFileList = computed(() => {
  return isAllFilesShown.value
    ? fileList.value
    : fileList.value.slice(0, FILE_PREVIEW_LIMIT);
});

const linkList = computed<LinkItem[]>(() => {
  const items: LinkItem[] = [];
  for (const msg of props.messages) {
    if (
      msg.isRedacted ||
      msg.decryptionStatus === 'failed' ||
      msg.decryptionStatus === 'pending' ||
      !msg.body
    ) {
      continue;
    }
    const urls = extractUrls(msg.body);
    urls.forEach((u, idx) => {
      items.push({
        date: dayjs(msg.timestamp).format('DD/MM/YYYY'),
        domain: getDomainFromUrl(u.href),
        href: u.href,
        id: `${msg.id}-${idx}`,
        messageId: msg.id,
        senderName: msg.senderName,
        timestamp: msg.timestamp,
        url: u.url,
      });
    });
  }
  return items.toReversed();
});

const displayedLinkList = computed(() => {
  return isAllLinksShown.value
    ? linkList.value
    : linkList.value.slice(0, LINK_PREVIEW_LIMIT);
});

const groupedMediaList = computed<MediaGroup[]>(() => {
  const grouped = new Map<string, MediaItem[]>();
  for (const item of mediaList.value) {
    const dateKey = dayjs(item.timestamp).format('YYYY-MM-DD');
    const items = grouped.get(dateKey);
    if (items) {
      items.push(item);
    } else {
      grouped.set(dateKey, [item]);
    }
  }

  return [...grouped.entries()].map(([dateKey, items]) => ({
    dateKey,
    items,
    label: $t('chat.mediaDate', {
      day: dayjs(dateKey).format('D'),
      month: dayjs(dateKey).format('M'),
    }),
  }));
});

const attachmentBrowserTitle = computed(() => {
  if (attachmentBrowserTab.value === 'files') {
    return $t('chat.files');
  }
  if (attachmentBrowserTab.value === 'links') {
    return $t('chat.links');
  }
  return $t('chat.media');
});

const hasExpandedAttachmentList = computed(
  () =>
    isAttachmentBrowserOpen.value ||
    isAllMediaShown.value ||
    isAllFilesShown.value ||
    isAllLinksShown.value,
);
const isAttachmentHistoryLoading = computed(
  () => props.isLoadingOlder || isLoadingMoreAttachments.value,
);
const canLoadAttachmentHistory = computed(
  () => props.hasMoreHistory && props.loadOlderMessages !== undefined,
);
const shouldShowMediaMore = computed(
  () =>
    isAllMediaShown.value ||
    mediaList.value.length > MEDIA_PREVIEW_LIMIT ||
    canLoadAttachmentHistory.value,
);
const shouldShowFileMore = computed(
  () =>
    isAllFilesShown.value ||
    fileList.value.length > FILE_PREVIEW_LIMIT ||
    canLoadAttachmentHistory.value,
);
const shouldShowLinkMore = computed(
  () =>
    isAllLinksShown.value ||
    linkList.value.length > LINK_PREVIEW_LIMIT ||
    canLoadAttachmentHistory.value,
);

async function loadMoreAttachmentHistory(): Promise<void> {
  const loadOlderMessages = props.loadOlderMessages;
  if (
    !loadOlderMessages ||
    !canLoadAttachmentHistory.value ||
    isAttachmentHistoryLoading.value
  ) {
    return;
  }

  isLoadingMoreAttachments.value = true;
  try {
    await loadOlderMessages(ATTACHMENT_PAGE_SIZE);
  } finally {
    isLoadingMoreAttachments.value = false;
    await nextTick();
    handlePanelScroll();
  }
}

function handlePanelScroll(): void {
  const element = panelBodyRef.value;
  if (
    !element ||
    !hasExpandedAttachmentList.value ||
    isAttachmentHistoryLoading.value ||
    !canLoadAttachmentHistory.value
  ) {
    return;
  }

  const distanceFromBottom =
    element.scrollHeight - element.scrollTop - element.clientHeight;
  if (distanceFromBottom <= ATTACHMENT_SCROLL_THRESHOLD) {
    void loadMoreAttachmentHistory();
  }
}

async function handleViewMore(
  section: 'files' | 'links' | 'media',
): Promise<void> {
  isAttachmentBrowserOpen.value = true;
  attachmentBrowserTab.value = section;
  if (section === 'media') {
    isAllMediaShown.value = true;
  } else if (section === 'files') {
    isAllFilesShown.value = true;
  } else {
    isAllLinksShown.value = true;
  }

  await nextTick();
  panelBodyRef.value?.scrollTo({ top: 0 });
  await loadMoreAttachmentHistory();
}

async function handleAttachmentTab(tab: AttachmentBrowserTab): Promise<void> {
  attachmentBrowserTab.value = tab;
  if (tab === 'media') {
    isAllMediaShown.value = true;
  } else if (tab === 'files') {
    isAllFilesShown.value = true;
  } else if (tab === 'links') {
    isAllLinksShown.value = true;
  }

  await nextTick();
  panelBodyRef.value?.scrollTo({ top: 0 });
  await loadMoreAttachmentHistory();
}

async function handleBackToInfo(): Promise<void> {
  isAttachmentBrowserOpen.value = false;
  isAllMediaShown.value = false;
  isAllFilesShown.value = false;
  isAllLinksShown.value = false;
  await nextTick();
  panelBodyRef.value?.scrollTo({ top: 0 });
}

async function ensureImageUrl(
  messageId: string,
  attachmentIndex: number,
): Promise<string | undefined> {
  const key = `${messageId}-${attachmentIndex}`;
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
    console.error('Failed to load attachment image URL:', error);
    return undefined;
  } finally {
    loadingImageKeys.value.delete(key);
  }
}

watch(
  () => displayedMediaList.value,
  (items) => {
    for (const item of items) {
      void ensureImageUrl(item.messageId, item.attachmentIndex);
    }
  },
  { immediate: true },
);

watch(
  () => props.roomId,
  () => {
    isAllMediaShown.value = false;
    isAllFilesShown.value = false;
    isAllLinksShown.value = false;
    isAttachmentBrowserOpen.value = false;
    attachmentBrowserTab.value = 'media';
  },
  { immediate: true },
);

watch(
  () => props.messages,
  (items) => {
    if (items.length === 0) {
      isAllMediaShown.value = false;
      isAllFilesShown.value = false;
      isAllLinksShown.value = false;
      return;
    }

    if (hasExpandedAttachmentList.value) {
      void nextTick(handlePanelScroll);
    }
  },
);

async function handleImageClick(item: MediaItem): Promise<void> {
  const key = `${item.messageId}-${item.attachmentIndex}`;
  let url = loadedImageUrls.value.get(key);
  if (!url) {
    url = await ensureImageUrl(item.messageId, item.attachmentIndex);
  }
  if (url) {
    previewImage(url, item.filename);
  }
}

async function handleDownloadFile(
  messageId: string,
  attachmentIndex: number,
): Promise<void> {
  const key = `${messageId}-${attachmentIndex}`;
  if (downloadingFileKey.value !== null) return;
  downloadingFileKey.value = key;
  try {
    await (props.downloadAttachment
      ? props.downloadAttachment(messageId, attachmentIndex)
      : store.downloadAttachment(messageId, attachmentIndex));
  } catch (error) {
    console.error('Failed to download file:', error);
  } finally {
    downloadingFileKey.value = null;
  }
}

async function handleFileItemClick(file: FileItem): Promise<void> {
  const type = detectFileType(file.filename);
  if (type === 'unsupported') {
    await handleDownloadFile(file.messageId, file.attachmentIndex);
    return;
  }
  try {
    const url = await store.getAttachmentUrl(
      file.messageId,
      file.attachmentIndex,
    );
    if (url) {
      await previewFile({
        filename: file.filename,
        size: file.size,
        url,
      });
    }
  } catch (error) {
    console.error('Failed to preview file:', error);
  }
}
</script>

<template>
  <aside
    :aria-hidden="!isOpen"
    :inert="!isOpen"
    class="relative flex h-full shrink-0 flex-col overflow-hidden bg-card/60 backdrop-blur-xs select-none"
    :class="isOpen ? 'w-80 border-l border-border' : 'hidden'"
  >
    <!-- Card Header -->
    <div class="flex items-center justify-between px-3 py-3">
      <div class="flex min-w-0 items-center gap-1">
        <Button
          v-if="isAttachmentBrowserOpen"
          type="text"
          shape="circle"
          :aria-label="$t('chat.back')"
          class="flex shrink-0 items-center justify-center text-muted-foreground hover:text-foreground"
          @click="handleBackToInfo"
        >
          <template #icon>
            <IconifyIcon icon="lucide:arrow-left" class="size-4" />
          </template>
        </Button>
        <h3 class="truncate font-semibold text-sm text-foreground">
          {{
            isAttachmentBrowserOpen
              ? attachmentBrowserTitle
              : $t('chat.conversationInfo')
          }}
        </h3>
      </div>
      <Button
        type="text"
        shape="circle"
        class="flex shrink-0 items-center justify-center text-muted-foreground hover:text-foreground"
        @click="emit('close')"
      >
        <template #icon>
          <IconifyIcon icon="lucide:x" class="size-4" />
        </template>
      </Button>
    </div>

    <!-- Scrollable Panel Body -->
    <div
      ref="panelBodyRef"
      class="flex-1 divide-y divide-border/60 overflow-y-auto"
      @scroll.passive="handlePanelScroll"
    >
      <template v-if="isAttachmentBrowserOpen">
        <div class="sticky top-0 z-10 bg-card px-3 pt-3">
          <div class="grid grid-cols-3 border-b border-border/60">
            <button
              v-for="tab in attachmentBrowserTabs"
              :key="tab"
              type="button"
              class="relative px-2 pb-3 font-semibold text-xs transition-colors"
              :class="
                attachmentBrowserTab === tab
                  ? 'text-primary'
                  : 'text-muted-foreground hover:text-foreground'
              "
              @click="handleAttachmentTab(tab)"
            >
              {{
                tab === 'media'
                  ? $t('chat.media')
                  : tab === 'files'
                    ? $t('chat.files')
                    : $t('chat.links')
              }}
              <span
                v-if="attachmentBrowserTab === tab"
                class="absolute inset-x-0 bottom-0 h-0.5 bg-primary"
              ></span>
            </button>
          </div>

          <div class="flex gap-2 py-3">
            <div
              class="flex min-w-0 flex-1 items-center justify-between rounded-full bg-muted/70 px-3 py-1.5 text-xs text-muted-foreground"
            >
              <span>{{ $t('chat.senderFilter') }}</span>
              <IconifyIcon icon="lucide:chevron-down" class="size-3.5" />
            </div>
            <div
              class="flex min-w-0 flex-1 items-center justify-between rounded-full bg-muted/70 px-3 py-1.5 text-xs text-muted-foreground"
            >
              <span>{{ $t('chat.dateFilter') }}</span>
              <IconifyIcon icon="lucide:chevron-down" class="size-3.5" />
            </div>
          </div>
        </div>

        <template v-if="attachmentBrowserTab === 'media'">
          <template v-if="groupedMediaList.length > 0">
            <section
              v-for="group in groupedMediaList"
              :key="group.dateKey"
              class="border-b border-border/60 px-4 py-4 last:border-b-0"
            >
              <h4 class="mb-3 font-semibold text-sm text-foreground">
                {{ group.label }}
              </h4>
              <div class="grid grid-cols-3 gap-2">
                <div
                  v-for="item in group.items"
                  :key="item.id"
                  class="group relative aspect-square cursor-pointer overflow-hidden rounded-md border border-border/50 bg-muted/60"
                  @click="handleImageClick(item)"
                >
                  <img
                    v-if="
                      loadedImageUrls.get(
                        `${item.messageId}-${item.attachmentIndex}`,
                      )
                    "
                    :src="
                      loadedImageUrls.get(
                        `${item.messageId}-${item.attachmentIndex}`,
                      )
                    "
                    :alt="item.filename"
                    loading="lazy"
                    class="size-full object-cover transition-transform duration-200 group-hover:scale-105"
                  />
                  <div
                    v-else-if="
                      loadingImageKeys.has(
                        `${item.messageId}-${item.attachmentIndex}`,
                      )
                    "
                    class="flex size-full items-center justify-center"
                  >
                    <Spin size="small" />
                  </div>
                  <div
                    v-else
                    class="flex size-full items-center justify-center text-muted-foreground"
                  >
                    <IconifyIcon
                      icon="lucide:image"
                      class="size-6 opacity-40"
                    />
                  </div>
                  <div
                    class="absolute inset-0 flex items-center justify-center bg-black/20 opacity-0 transition-opacity group-hover:opacity-100"
                  >
                    <IconifyIcon
                      icon="lucide:maximize-2"
                      class="size-4 text-white drop-shadow-xs"
                    />
                  </div>
                </div>
              </div>
            </section>
          </template>
          <div
            v-else
            class="flex min-h-40 items-center justify-center px-4 text-center text-xs text-muted-foreground"
          >
            <Spin v-if="isAttachmentHistoryLoading" size="small" />
            <span v-else>{{ $t('chat.noMedia') }}</span>
          </div>
        </template>

        <template v-else-if="attachmentBrowserTab === 'files'">
          <div v-if="displayedFileList.length > 0" class="space-y-1 px-4 py-3">
            <div
              v-for="file in displayedFileList"
              :key="file.id"
              class="group flex cursor-pointer items-center gap-2.5 rounded-lg px-2 py-2 transition-colors hover:bg-muted/70"
              @click="handleFileItemClick(file)"
            >
              <div
                class="flex size-10 shrink-0 items-center justify-center rounded-lg font-bold text-[10px] tracking-wide shadow-2xs"
                :class="file.badgeBg"
              >
                {{ file.badgeText }}
              </div>
              <div class="min-w-0 flex-1">
                <div
                  class="truncate font-medium text-xs text-foreground group-hover:text-primary"
                  :title="file.filename"
                >
                  {{ file.filename }}
                </div>
                <div class="mt-0.5 text-[11px] text-muted-foreground">
                  {{ file.size }} · {{ file.date }}
                </div>
              </div>
              <button
                type="button"
                class="flex size-7 shrink-0 items-center justify-center rounded-full text-muted-foreground opacity-0 transition-opacity hover:bg-muted hover:text-foreground group-hover:opacity-100"
                :aria-label="$t('chat.downloadFile')"
                @click.stop="
                  handleDownloadFile(file.messageId, file.attachmentIndex)
                "
              >
                <Spin
                  v-if="
                    downloadingFileKey ===
                    `${file.messageId}-${file.attachmentIndex}`
                  "
                  size="small"
                />
                <IconifyIcon v-else icon="lucide:download" class="size-3.5" />
              </button>
            </div>
          </div>
          <div
            v-else
            class="flex min-h-40 items-center justify-center px-4 text-center text-xs text-muted-foreground"
          >
            <Spin v-if="isAttachmentHistoryLoading" size="small" />
            <span v-else>{{ $t('chat.noFiles') }}</span>
          </div>
        </template>

        <template v-else-if="attachmentBrowserTab === 'links'">
          <div v-if="displayedLinkList.length > 0" class="space-y-1 px-4 py-3">
            <a
              v-for="link in displayedLinkList"
              :key="link.id"
              :href="link.href"
              target="_blank"
              rel="noopener noreferrer"
              class="group flex items-center gap-2.5 rounded-lg px-2 py-2 text-foreground transition-colors hover:bg-muted/70"
            >
              <div
                class="flex size-10 shrink-0 items-center justify-center rounded-lg bg-blue-500/10 text-blue-500 shadow-2xs dark:bg-blue-500/20 dark:text-blue-400"
              >
                <IconifyIcon icon="lucide:link-2" class="size-5" />
              </div>
              <div class="min-w-0 flex-1">
                <div
                  class="truncate font-medium text-xs text-foreground group-hover:text-primary"
                  :title="link.url"
                >
                  {{ link.domain || link.url }}
                </div>
                <div
                  class="mt-0.5 truncate text-[11px] text-muted-foreground"
                  :title="link.url"
                >
                  {{ link.url }}
                </div>
                <div class="mt-0.5 text-[10px] text-muted-foreground/70">
                  {{ link.date }}
                </div>
              </div>
              <div
                class="flex size-7 shrink-0 items-center justify-center rounded-full text-muted-foreground opacity-0 transition-opacity hover:bg-muted hover:text-foreground group-hover:opacity-100"
              >
                <IconifyIcon icon="lucide:external-link" class="size-3.5" />
              </div>
            </a>
          </div>
          <div
            v-else
            class="flex min-h-40 items-center justify-center px-4 text-center text-xs text-muted-foreground"
          >
            <Spin v-if="isAttachmentHistoryLoading" size="small" />
            <span v-else>{{ $t('chat.noLinks') }}</span>
          </div>
        </template>

        <div
          v-if="isAttachmentHistoryLoading"
          class="flex items-center justify-center py-4"
        >
          <Spin size="small" />
        </div>
      </template>

      <template v-else>
        <!-- Profile Header & Quick Actions -->
        <div class="flex flex-col items-center px-4 py-5 text-center">
          <ChatGroupAvatar
            v-if="!isDirect"
            :members="groupMemberAvatars"
            :size="72"
            :total-count="memberCount"
          />
          <Avatar
            v-else
            :size="72"
            :src="avatarUrl"
            class="border-2 border-border font-bold text-xl shadow-xs"
            :class="
              isDirect ? 'bg-blue-500 text-white' : 'bg-primary/20 text-primary'
            "
          >
            <span v-if="initials">{{ initials }}</span>
            <IconifyIcon
              v-else
              :icon="isDirect ? 'lucide:user' : 'lucide:users'"
              class="size-9"
            />
          </Avatar>

          <div class="mt-3 flex items-center justify-center gap-1.5 px-2">
            <h3 class="truncate font-semibold text-base text-foreground">
              {{ title }}
            </h3>
          </div>

          <span
            v-if="!isDirect && memberCount > 0"
            class="mt-0.5 text-xs text-muted-foreground"
          >
            {{ $t('chat.memberCount', { count: memberCount }) }}
          </span>
        </div>

        <!-- Photos & Videos Section -->
        <div class="p-4">
          <button
            type="button"
            class="flex w-full cursor-pointer items-center justify-between font-semibold text-sm text-foreground transition-colors hover:text-primary"
            @click="isMediaExpanded = !isMediaExpanded"
          >
            <span>{{ $t('chat.media') }}</span>
            <IconifyIcon
              :icon="
                isMediaExpanded ? 'lucide:chevron-down' : 'lucide:chevron-right'
              "
              class="size-4 text-muted-foreground transition-transform"
            />
          </button>

          <div v-if="isMediaExpanded" class="mt-3 space-y-3">
            <div
              v-if="mediaList.length === 0 && !props.hasMoreHistory"
              class="py-4 text-center text-xs text-muted-foreground"
            >
              {{ $t('chat.noMedia') }}
            </div>

            <template v-else>
              <div
                v-if="displayedMediaList.length > 0"
                class="grid grid-cols-3 gap-1.5"
              >
                <div
                  v-for="item in displayedMediaList"
                  :key="item.id"
                  class="group relative aspect-square cursor-pointer overflow-hidden rounded-md border border-border/50 bg-muted/60"
                  @click="handleImageClick(item)"
                >
                  <img
                    v-if="
                      loadedImageUrls.get(
                        `${item.messageId}-${item.attachmentIndex}`,
                      )
                    "
                    :src="
                      loadedImageUrls.get(
                        `${item.messageId}-${item.attachmentIndex}`,
                      )
                    "
                    :alt="item.filename"
                    loading="lazy"
                    class="size-full object-cover transition-transform duration-200 group-hover:scale-105"
                  />
                  <div
                    v-else-if="
                      loadingImageKeys.has(
                        `${item.messageId}-${item.attachmentIndex}`,
                      )
                    "
                    class="size-full animate-pulse bg-muted-foreground/15"
                  ></div>
                  <div
                    v-else
                    class="flex size-full items-center justify-center text-muted-foreground"
                  >
                    <IconifyIcon
                      icon="lucide:image"
                      class="size-6 opacity-40"
                    />
                  </div>
                  <div
                    class="absolute inset-0 flex items-center justify-center bg-black/20 opacity-0 transition-opacity group-hover:opacity-100"
                  >
                    <IconifyIcon
                      icon="lucide:maximize-2"
                      class="size-4 text-white drop-shadow-xs"
                    />
                  </div>
                </div>
              </div>

              <div
                v-else-if="isAttachmentHistoryLoading"
                class="grid grid-cols-3 gap-1.5"
              >
                <div
                  v-for="i in 6"
                  :key="i"
                  class="aspect-square rounded-md bg-muted-foreground/15 animate-pulse"
                ></div>
              </div>

              <div
                v-else
                class="flex items-center justify-center py-4 text-center text-xs text-muted-foreground"
              >
                {{ $t('chat.noMedia') }}
              </div>

              <Button
                v-if="shouldShowMediaMore"
                block
                size="small"
                :disabled="isAttachmentHistoryLoading"
                :loading="isAttachmentHistoryLoading"
                class="!h-7 rounded-md text-muted-foreground text-xs hover:text-foreground"
                @click="handleViewMore('media')"
              >
                {{ $t('chat.viewMore') }}
              </Button>
            </template>
          </div>
        </div>

        <!-- Files Section -->
        <div class="p-4">
          <button
            type="button"
            class="flex w-full cursor-pointer items-center justify-between font-semibold text-sm text-foreground transition-colors hover:text-primary"
            @click="isFilesExpanded = !isFilesExpanded"
          >
            <span>{{ $t('chat.files') }}</span>
            <IconifyIcon
              :icon="
                isFilesExpanded ? 'lucide:chevron-down' : 'lucide:chevron-right'
              "
              class="size-4 text-muted-foreground transition-transform"
            />
          </button>

          <div v-if="isFilesExpanded" class="mt-3 space-y-2">
            <div
              v-if="fileList.length === 0 && !props.hasMoreHistory"
              class="py-4 text-center text-xs text-muted-foreground"
            >
              {{ $t('chat.noFiles') }}
            </div>

            <template v-else>
              <div
                v-for="file in displayedFileList"
                :key="file.id"
                class="group -mx-2 flex cursor-pointer items-center gap-2.5 rounded-lg px-2 py-1.5 transition-colors hover:bg-muted/70"
                @click="handleFileItemClick(file)"
              >
                <!-- Badge Icon -->
                <div
                  class="flex size-9 shrink-0 items-center justify-center rounded-lg font-bold text-[10px] tracking-wide shadow-2xs"
                  :class="file.badgeBg"
                >
                  {{ file.badgeText }}
                </div>

                <!-- File Info -->
                <div class="min-w-0 flex-1">
                  <div
                    class="truncate font-medium text-xs text-foreground group-hover:text-primary"
                    :title="file.filename"
                  >
                    {{ file.filename }}
                  </div>
                  <div
                    class="mt-0.5 flex items-center gap-1.5 text-[11px] text-muted-foreground"
                  >
                    <span>{{ file.size }}</span>
                    <IconifyIcon
                      icon="lucide:check-circle-2"
                      class="size-3 text-emerald-500"
                    />
                    <span class="text-border/80">•</span>
                    <span>{{ file.date }}</span>
                  </div>
                </div>

                <!-- Hover Download Icon / Loading -->
                <div
                  class="flex size-6 shrink-0 items-center justify-center text-muted-foreground transition-opacity hover:text-foreground"
                  :class="
                    downloadingFileKey ===
                    `${file.messageId}-${file.attachmentIndex}`
                      ? 'opacity-100'
                      : 'opacity-0 group-hover:opacity-100'
                  "
                  @click.stop="
                    handleDownloadFile(file.messageId, file.attachmentIndex)
                  "
                >
                  <Spin
                    v-if="
                      downloadingFileKey ===
                      `${file.messageId}-${file.attachmentIndex}`
                    "
                    size="small"
                  />
                  <IconifyIcon v-else icon="lucide:download" class="size-3.5" />
                </div>
              </div>

              <div
                v-if="displayedFileList.length === 0"
                class="flex items-center justify-center py-4 text-center text-xs text-muted-foreground"
              >
                <Spin v-if="isAttachmentHistoryLoading" size="small" />
                <span v-else>{{ $t('chat.noFiles') }}</span>
              </div>

              <Button
                v-if="shouldShowFileMore"
                block
                size="small"
                :disabled="isAttachmentHistoryLoading"
                :loading="isAttachmentHistoryLoading"
                class="!h-7 rounded-md text-muted-foreground text-xs hover:text-foreground"
                @click="handleViewMore('files')"
              >
                {{ $t('chat.viewMore') }}
              </Button>
            </template>
          </div>
        </div>

        <!-- Links Section -->
        <div class="p-4">
          <button
            type="button"
            class="flex w-full cursor-pointer items-center justify-between font-semibold text-sm text-foreground transition-colors hover:text-primary"
            @click="isLinksExpanded = !isLinksExpanded"
          >
            <span>{{ $t('chat.links') }}</span>
            <IconifyIcon
              :icon="
                isLinksExpanded ? 'lucide:chevron-down' : 'lucide:chevron-right'
              "
              class="size-4 text-muted-foreground transition-transform"
            />
          </button>

          <div v-if="isLinksExpanded" class="mt-3 space-y-2">
            <div
              v-if="linkList.length === 0 && !props.hasMoreHistory"
              class="py-4 text-center text-xs text-muted-foreground"
            >
              {{ $t('chat.noLinks') }}
            </div>

            <template v-else>
              <a
                v-for="link in displayedLinkList"
                :key="link.id"
                :href="link.href"
                target="_blank"
                rel="noopener noreferrer"
                class="group -mx-2 flex items-center gap-2.5 rounded-lg px-2 py-1.5 text-foreground transition-colors hover:bg-muted/70"
              >
                <!-- Badge Icon -->
                <div
                  class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-blue-500/10 text-blue-500 shadow-2xs dark:bg-blue-500/20 dark:text-blue-400"
                >
                  <IconifyIcon icon="lucide:link-2" class="size-4" />
                </div>

                <!-- Link Info -->
                <div class="min-w-0 flex-1">
                  <div
                    class="truncate font-medium text-xs text-foreground group-hover:text-primary"
                    :title="link.url"
                  >
                    {{ link.domain || link.url }}
                  </div>
                  <div
                    class="mt-0.5 flex items-center gap-1.5 text-[11px] text-muted-foreground"
                  >
                    <span class="max-w-[130px] truncate" :title="link.url">{{
                      link.url
                    }}</span>
                    <span class="text-border/80">•</span>
                    <span class="shrink-0">{{ link.date }}</span>
                  </div>
                </div>

                <!-- Hover External Link Icon -->
                <div
                  class="flex size-6 shrink-0 items-center justify-center text-muted-foreground opacity-0 transition-opacity hover:text-foreground group-hover:opacity-100"
                >
                  <IconifyIcon icon="lucide:external-link" class="size-3.5" />
                </div>
              </a>

              <div
                v-if="displayedLinkList.length === 0"
                class="flex items-center justify-center py-4 text-center text-xs text-muted-foreground"
              >
                <Spin v-if="isAttachmentHistoryLoading" size="small" />
                <span v-else>{{ $t('chat.noLinks') }}</span>
              </div>

              <Button
                v-if="shouldShowLinkMore"
                block
                size="small"
                :disabled="isAttachmentHistoryLoading"
                :loading="isAttachmentHistoryLoading"
                class="!h-7 rounded-md text-muted-foreground text-xs hover:text-foreground"
                @click="handleViewMore('links')"
              >
                {{ $t('chat.viewMore') }}
              </Button>
            </template>
          </div>
        </div>
      </template>
    </div>

    <!-- Group Actions -->
    <div
      v-if="!isDirect && !isAttachmentBrowserOpen"
      class="border-t border-border/60 p-4"
    >
      <Popconfirm
        v-if="!canDeleteGroup"
        :title="$t('chat.leaveGroupConfirm')"
        :ok-text="$t('chat.leaveGroup')"
        :cancel-text="$t('chat.cancel')"
        :disabled="isMemberActionLoading || groupAction !== null"
        @confirm="emit('leaveGroup')"
      >
        <Button
          block
          danger
          type="text"
          :loading="groupAction === 'leave'"
          :disabled="isMemberActionLoading || groupAction !== null"
          class="justify-start text-muted-foreground hover:text-destructive"
        >
          <template #icon>
            <IconifyIcon icon="lucide:log-out" class="size-4" />
          </template>
          {{ $t('chat.leaveGroup') }}
        </Button>
      </Popconfirm>

      <Popconfirm
        v-if="canDeleteGroup"
        :title="$t('chat.deleteGroupConfirm')"
        :ok-text="$t('chat.deleteGroup')"
        :cancel-text="$t('chat.cancel')"
        :disabled="isMemberActionLoading || groupAction !== null"
        @confirm="emit('deleteGroup')"
      >
        <Button
          block
          danger
          type="text"
          :loading="groupAction === 'delete'"
          :disabled="isMemberActionLoading || groupAction !== null"
          class="justify-start text-muted-foreground hover:text-destructive"
        >
          <template #icon>
            <IconifyIcon icon="lucide:trash-2" class="size-4" />
          </template>
          {{ $t('chat.deleteGroup') }}
        </Button>
      </Popconfirm>
    </div>
  </aside>
</template>

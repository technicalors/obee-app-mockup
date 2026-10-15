<script setup lang="ts">
import type { ConversationItem } from '../types';

import { computed, ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Avatar,
  Badge,
  Button,
  Empty,
  Input,
  Segmented,
  Tooltip,
} from 'ant-design-vue';
import dayjs from 'dayjs';

import { $t } from '#/locales';
import { stripReplyFallback } from '#/store';

import ChatGroupAvatar from './chat-group-avatar.vue';

interface Props {
  activeRoomId?: null | string;
  conversations: ConversationItem[];
  isCollapsed: boolean;
  loading?: boolean;
  searchQuery: string;
  selectedConversationId?: null | string;
}

const props = withDefaults(defineProps<Props>(), {
  activeRoomId: null,
  loading: false,
  selectedConversationId: null,
});

const emit = defineEmits<{
  openCreateGroup: [];
  select: [item: ConversationItem];
  'update:collapsed': [collapsed: boolean];
  'update:searchQuery': [val: string];
}>();

type FilterType = 'all' | 'direct' | 'group';
const activeFilter = ref<FilterType>('all');

const filterOptions = computed(() => [
  { label: $t('chat.all'), value: 'all' },
  { label: $t('chat.directMessages'), value: 'direct' },
  { label: $t('chat.channels'), value: 'group' },
]);

const filteredConversations = computed(() => {
  let list = props.conversations;
  if (activeFilter.value === 'direct') {
    list = list.filter((c) => c.isDirect);
  } else if (activeFilter.value === 'group') {
    list = list.filter((c) => !c.isDirect);
  }
  return list;
});

function isSelected(item: ConversationItem): boolean {
  return Boolean(
    (item.roomId && item.roomId === props.activeRoomId) ||
    (!item.roomId && item.id === props.selectedConversationId),
  );
}

/**
 * Formats a conversation's last event timestamp for the sidebar list item.
 * Displays 'HH:mm' if the event occurred today or yesterday,
 * otherwise falls back to 'DD/MM' date format.
 */
function formatTime(timestamp: number): string {
  if (!timestamp) return '';
  const target = dayjs(timestamp);
  const now = dayjs();
  if (target.isSame(now, 'day')) {
    return target.format('HH:mm');
  }
  if (target.isSame(now.subtract(1, 'day'), 'day')) {
    return target.format('HH:mm');
  }
  return target.format('DD/MM');
}

/**
 * Sanitizes and normalizes the last message text for single-line sidebar preview.
 * Strips rich reply fallbacks/quotes and collapses whitespace/newlines into a single line.
 */
function formatMessagePreview(text?: string): string {
  if (!text) return '';
  const clean = stripReplyFallback(text);
  return clean.replaceAll(/\s+/g, ' ').trim();
}
</script>

<template>
  <aside
    :aria-hidden="isCollapsed"
    :inert="isCollapsed"
    class="relative flex h-full shrink-0 flex-col overflow-hidden bg-card/60 backdrop-blur-xs"
    :class="isCollapsed ? 'hidden' : 'w-80 border-r border-border'"
  >
    <!-- Top Header & Actions -->
    <div class="space-y-3 border-b border-border p-4">
      <div class="flex items-center justify-between">
        <h1 class="text-lg font-bold tracking-tight text-foreground">
          {{ $t('chat.title') }}
        </h1>
        <div class="flex items-center gap-1">
          <Tooltip :title="$t('chat.createGroup')" placement="bottom">
            <Button
              type="text"
              shape="circle"
              class="flex items-center justify-center text-muted-foreground hover:text-foreground"
              @click="emit('openCreateGroup')"
            >
              <template #icon>
                <div class="relative inline-flex items-center justify-center">
                  <IconifyIcon icon="lucide:users" class="size-4" />
                  <IconifyIcon
                    icon="lucide:plus"
                    class="absolute -top-1 -right-1.5 size-2.5 stroke-[2.5]"
                  />
                </div>
              </template>
            </Button>
          </Tooltip>
        </div>
      </div>

      <!-- Search Input -->
      <Input
        :value="searchQuery"
        :placeholder="$t('chat.searchPlaceholder')"
        allow-clear
        class="rounded-lg"
        @update:value="emit('update:searchQuery', $event)"
      >
        <template #prefix>
          <IconifyIcon
            icon="lucide:search"
            class="size-4 text-muted-foreground"
          />
        </template>
      </Input>

      <!-- Category Filter Segmented -->
      <Segmented
        v-model:value="activeFilter"
        :options="filterOptions"
        block
        class="w-full rounded-lg bg-muted/60 p-0.5 text-xs"
      />
    </div>

    <!-- Conversations List -->
    <div class="flex-1 space-y-1.5 overflow-y-auto p-2.5">
      <!-- Loading Skeleton (wait for both users and groups, min 1000ms) -->
      <template v-if="loading">
        <div
          v-for="n in 6"
          :key="n"
          class="flex items-center gap-3 rounded-xl p-3 animate-pulse"
        >
          <div
            class="size-[42px] shrink-0 rounded-full bg-muted-foreground/15"
          ></div>
          <div class="min-w-0 flex-1 space-y-2">
            <div class="flex items-center justify-between gap-2">
              <div class="h-3.5 w-28 rounded-md bg-muted-foreground/15"></div>
              <div class="h-2.5 w-10 rounded-md bg-muted-foreground/15"></div>
            </div>
            <div class="h-3 w-40 rounded-md bg-muted-foreground/10"></div>
          </div>
        </div>
      </template>

      <template v-else-if="filteredConversations.length > 0">
        <div
          v-for="item in filteredConversations"
          :key="item.id"
          role="button"
          tabindex="0"
          class="group relative flex w-full cursor-pointer select-none items-center gap-3 rounded-xl p-3 text-left transition-all duration-200"
          :class="[
            isSelected(item)
              ? 'border border-primary/25 bg-primary/10 font-medium text-primary shadow-xs'
              : 'border border-transparent text-foreground hover:bg-muted/70',
          ]"
          @click="emit('select', item)"
          @keydown.enter="emit('select', item)"
        >
          <!-- Left Avatar with Online Badge -->
          <div class="relative shrink-0">
            <Badge
              :dot="item.isDirect && Boolean(item.targetMatrixUserId)"
              :status="
                item.isDirect && item.targetMatrixUserId ? 'success' : undefined
              "
              :offset="[-2, 34]"
            >
              <ChatGroupAvatar
                v-if="!item.isDirect"
                :members="item.groupMemberAvatars"
                :size="42"
                :total-count="item.memberCount"
                class="transition-transform duration-200 group-hover:scale-105"
              />
              <Avatar
                v-else
                :size="42"
                :src="item.avatarUrl"
                class="shrink-0 font-medium transition-transform duration-200 group-hover:scale-105"
                :class="
                  item.isDirect
                    ? 'bg-blue-500 text-white'
                    : 'bg-primary/20 text-primary'
                "
              >
                <template #icon>
                  <IconifyIcon
                    :icon="item.isDirect ? 'lucide:user' : 'lucide:users'"
                    class="size-5"
                  />
                </template>
              </Avatar>
            </Badge>
          </div>

          <!-- Middle Content (Name & Last message) -->
          <div class="min-w-0 flex-1">
            <div class="flex items-center justify-between gap-1">
              <span
                class="truncate text-sm font-semibold text-foreground"
                :class="{ '!text-primary': isSelected(item) }"
              >
                {{ item.name }}
              </span>
              <span
                v-if="item.lastEventTimestamp > 0"
                class="shrink-0 text-[11px] text-muted-foreground"
              >
                {{ formatTime(item.lastEventTimestamp) }}
              </span>
            </div>

            <div class="mt-1 flex items-center justify-between gap-2">
              <p
                class="min-h-[16px] truncate text-xs leading-relaxed text-muted-foreground"
                :class="{
                  'font-medium text-foreground/80': item.unreadCount > 0,
                }"
              >
                <template v-if="item.user && !item.targetMatrixUserId">
                  {{ $t('chat.userNotActivated') }}
                </template>
                <template v-else>
                  {{
                    formatMessagePreview(item.lastMessage) ||
                    (item.isDirect
                      ? $t('chat.startConversation')
                      : $t('chat.startGroupConversation'))
                  }}
                </template>
              </p>
              <Badge
                v-if="item.unreadCount > 0"
                :count="item.unreadCount"
                size="small"
              />
            </div>
          </div>
        </div>
      </template>

      <!-- Empty State -->
      <div
        v-else
        class="flex h-56 flex-col items-center justify-center p-4 text-center"
      >
        <Empty
          :image="Empty.PRESENTED_IMAGE_SIMPLE"
          :description="$t('chat.noSearchResults')"
        />
      </div>
    </div>
  </aside>
</template>

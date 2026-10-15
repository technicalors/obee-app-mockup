<script setup lang="ts">
import type { GroupMemberAvatarInfo } from '../types';

import type { RoomEncryptionStatus } from '#/store';

import { IconifyIcon } from '@vben/icons';

import { Avatar, Badge, Button, Input, Space, Tooltip } from 'ant-design-vue';

import { $t } from '#/locales';

import ChatGroupAvatar from './chat-group-avatar.vue';

interface Props {
  avatarUrl?: string;
  currentMatchIndex?: number;
  encryptionStatus?: RoomEncryptionStatus;
  groupMemberAvatars?: GroupMemberAvatarInfo[];
  isDirect: boolean;
  isEmpty?: boolean;
  isInfoPanelOpen?: boolean;
  isSidebarCollapsed: boolean;
  isSearchOpen?: boolean;
  memberCount: number;
  searchMatchCount?: number;
  searchQuery?: string;
  title: string;
  typingText?: string;
}

const props = withDefaults(defineProps<Props>(), {
  avatarUrl: undefined,
  currentMatchIndex: 0,
  encryptionStatus: 'unknown',
  groupMemberAvatars: () => [],
  isEmpty: false,
  isInfoPanelOpen: true,
  isSearchOpen: false,
  searchMatchCount: 0,
  searchQuery: '',
  typingText: '',
});

const emit = defineEmits<{
  closeSearch: [];
  jumpToMessage: [eventId: string];
  nextMatch: [];
  openMembers: [];
  prevMatch: [];
  toggleInfoPanel: [];
  toggleSearch: [];
  toggleSidebar: [];
  'update:searchQuery': [query: string];
}>();
</script>

<template>
  <div class="shrink-0">
    <!-- Main Chat Header Bar -->
    <header
      class="flex items-center justify-between border-b border-border bg-card/60 py-3.5 pl-3 pr-6 backdrop-blur-xs"
    >
      <div class="flex min-w-0 flex-1 items-center gap-3.5">
        <Tooltip
          :title="
            $t(isSidebarCollapsed ? 'chat.openSidebar' : 'chat.closeSidebar')
          "
          placement="bottom"
        >
          <Button
            type="text"
            shape="circle"
            :aria-label="
              $t(isSidebarCollapsed ? 'chat.openSidebar' : 'chat.closeSidebar')
            "
            class="flex shrink-0 items-center justify-center text-muted-foreground hover:text-foreground"
            @click="emit('toggleSidebar')"
          >
            <template #icon>
              <IconifyIcon
                :icon="
                  isSidebarCollapsed
                    ? 'lucide:panel-left-open'
                    : 'lucide:panel-left-close'
                "
                class="size-4"
              />
            </template>
          </Button>
        </Tooltip>
        <template v-if="isEmpty">
          <h2 class="text-base font-semibold leading-tight text-foreground">
            {{ title }}
          </h2>
        </template>
        <template v-else>
          <ChatGroupAvatar
            v-if="!isDirect"
            :members="groupMemberAvatars"
            :size="42"
            :total-count="memberCount"
            class="shadow-xs"
          />
          <Badge
            v-else
            :dot="isDirect"
            :status="isDirect ? 'success' : undefined"
            :offset="[-2, 34]"
          >
            <Avatar
              :size="42"
              :src="avatarUrl"
              class="shrink-0 font-medium shadow-xs"
              :class="
                isDirect
                  ? 'bg-blue-500 text-white'
                  : 'bg-primary/20 text-primary'
              "
            >
              <template #icon>
                <IconifyIcon
                  :icon="isDirect ? 'lucide:user' : 'lucide:users'"
                  class="size-5"
                />
              </template>
            </Avatar>
          </Badge>
          <div class="min-w-0">
            <h2
              class="truncate text-base font-semibold leading-tight text-foreground"
            >
              {{ title }}
            </h2>
            <div
              v-if="typingText"
              class="mt-0.5 flex items-center gap-1.5 text-xs text-primary font-medium animate-pulse"
            >
              <span>{{ typingText }}</span>
            </div>
            <div v-else-if="!isDirect" class="mt-0.5 flex items-center gap-2">
              <span
                role="button"
                tabindex="0"
                class="inline-flex cursor-pointer items-center gap-1 text-xs text-muted-foreground transition-colors hover:text-foreground"
                @click="emit('openMembers')"
                @keydown.enter="emit('openMembers')"
                @keydown.space.prevent="emit('openMembers')"
              >
                <IconifyIcon icon="lucide:users" class="size-3.5" />
                <span>{{
                  $t('chat.memberCount', { count: memberCount })
                }}</span>
              </span>
            </div>
            <div
              v-if="encryptionStatus !== 'unknown'"
              class="mt-1 flex items-center gap-1 text-[11px] text-muted-foreground hidden"
            >
              <IconifyIcon
                :icon="
                  encryptionStatus === 'encrypted'
                    ? 'lucide:lock-keyhole'
                    : 'lucide:unlock-keyhole'
                "
                class="size-3"
              />
              <span>
                {{
                  $t(
                    encryptionStatus === 'encrypted'
                      ? 'chat.encryption.encrypted'
                      : 'chat.encryption.unencrypted',
                  )
                }}
              </span>
            </div>
          </div>
        </template>
      </div>

      <div
        v-if="!isEmpty"
        class="flex min-w-0 flex-1 items-center justify-end gap-2"
      >
        <div v-if="isSearchOpen" class="min-w-0 max-w-xl flex-1">
          <Input
            :value="searchQuery"
            :placeholder="$t('chat.searchInRoom')"
            allow-clear
            class="w-full rounded-lg"
            @update:value="(val) => emit('update:searchQuery', val)"
            @press-enter="emit('nextMatch')"
          >
            <template #prefix>
              <IconifyIcon
                icon="lucide:search"
                class="size-4 text-muted-foreground"
              />
            </template>
            <template #suffix>
              <span
                v-if="searchQuery"
                class="text-[11px] text-muted-foreground select-none"
              >
                {{
                  searchMatchCount > 0
                    ? `${currentMatchIndex + 1}/${searchMatchCount}`
                    : $t('chat.noSearchResults')
                }}
              </span>
            </template>
          </Input>
        </div>

        <Space v-if="isSearchOpen" size="small" class="shrink-0">
          <Button
            type="text"
            shape="circle"
            :disabled="searchMatchCount <= 1"
            class="flex shrink-0 items-center justify-center text-muted-foreground hover:text-foreground"
            @click="emit('prevMatch')"
          >
            <template #icon>
              <IconifyIcon icon="lucide:chevron-up" class="size-4" />
            </template>
          </Button>
          <Button
            type="text"
            shape="circle"
            :disabled="searchMatchCount <= 1"
            class="flex shrink-0 items-center justify-center text-muted-foreground hover:text-foreground"
            @click="emit('nextMatch')"
          >
            <template #icon>
              <IconifyIcon icon="lucide:chevron-down" class="size-4" />
            </template>
          </Button>
          <Button
            type="text"
            shape="circle"
            class="flex shrink-0 items-center justify-center text-muted-foreground hover:text-foreground"
            @click="emit('closeSearch')"
          >
            <template #icon>
              <IconifyIcon icon="lucide:x" class="size-4" />
            </template>
          </Button>
        </Space>

        <Tooltip v-else :title="$t('chat.searchInRoom')" placement="bottom">
          <Button
            type="text"
            shape="circle"
            :aria-label="$t('chat.searchInRoom')"
            class="flex shrink-0 items-center justify-center text-muted-foreground hover:text-foreground"
            @click="emit('toggleSearch')"
          >
            <template #icon>
              <IconifyIcon icon="lucide:search" class="size-4" />
            </template>
          </Button>
        </Tooltip>

        <Tooltip :title="$t('chat.conversationInfo')" placement="bottom">
          <Button
            type="text"
            shape="circle"
            :aria-label="$t('chat.conversationInfo')"
            class="flex shrink-0 items-center justify-center text-muted-foreground hover:text-foreground"
            @click="emit('toggleInfoPanel')"
          >
            <template #icon>
              <IconifyIcon
                :icon="
                  isInfoPanelOpen
                    ? 'lucide:panel-right-close'
                    : 'lucide:panel-right-open'
                "
                class="size-4"
              />
            </template>
          </Button>
        </Tooltip>
      </div>
    </header>
  </div>
</template>

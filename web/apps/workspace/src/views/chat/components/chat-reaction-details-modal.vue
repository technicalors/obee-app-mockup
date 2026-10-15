<script setup lang="ts">
import type { User } from '#/api';
import type { ChatMessageItem } from '#/store';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';
import { useUserStore } from '@vben/stores';

import { Avatar, Empty, Modal, TabPane, Tabs, Tooltip } from 'ant-design-vue';

import { $t } from '#/locales';
import { resolveChatUserDisplayName, useChatStore } from '#/store';
import { getUserAvatarSource } from '#/views/users/avatar';

import { getTotalReactionsCount } from '../composables/use-chat-reactions';

interface Props {
  colleagues?: User[];
  message: ChatMessageItem | null;
  open: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  colleagues: () => [],
});

const emit = defineEmits<{
  toggleReaction: [msg: ChatMessageItem, emoji: string];
  'update:open': [val: boolean];
}>();

const userStore = useUserStore();
const chatStore = useChatStore();
const activeTab = ref('all');
const locallyRemovedReactions = ref<Array<{ emoji: string; userId: string }>>(
  [],
);

watch(
  () => props.open,
  (val) => {
    if (val) {
      activeTab.value = 'all';
      locallyRemovedReactions.value = [];
    }
  },
);

const reactions = computed(() => {
  const baseReactions = props.message?.reactions || [];
  if (locallyRemovedReactions.value.length === 0) {
    return baseReactions;
  }
  return baseReactions
    .map((r) => {
      const remainingUsers = (r.users || []).filter(
        (u) =>
          !locallyRemovedReactions.value.some(
            (rem) => rem.userId === u.userId && rem.emoji === r.key,
          ),
      );
      return {
        ...r,
        count: remainingUsers.length,
        hasReacted: remainingUsers.some(
          (u) =>
            u.userId === chatStore.currentUserId ||
            u.userId.replace(/^@/, '').split(':')[0]?.toLowerCase() ===
              userStore.userInfo?.username?.toLowerCase(),
        ),
        users: remainingUsers,
      };
    })
    .filter((r) => r.count > 0);
});
const totalCount = computed(() => getTotalReactionsCount(reactions.value));

interface ReactionUserEntry {
  avatarUrl?: string;
  displayName: string;
  emoji: string;
  isMe: boolean;
  userId: string;
}

function resolveUserColleague(userId: string): undefined | User {
  if (!props.colleagues || props.colleagues.length === 0) return undefined;
  const username = userId.replace(/^@/, '').split(':')[0]?.toLowerCase();
  return props.colleagues.find(
    (c) =>
      c.username.toLowerCase() === username ||
      (c.matrix_user_id &&
        c.matrix_user_id.toLowerCase() === userId.toLowerCase()),
  );
}

function resolveUserAvatar(
  userId: string,
  fallbackAvatar?: string,
): string | undefined {
  const username = userId.replace(/^@/, '').split(':')[0]?.toLowerCase();
  const isCurrentMe =
    userId === chatStore.currentUserId ||
    username === userStore.userInfo?.username?.toLowerCase();

  if (isCurrentMe && userStore.userInfo?.avatar) {
    return userStore.userInfo.avatar;
  }

  const colleague = resolveUserColleague(userId);
  if (colleague) {
    const url = getUserAvatarSource(colleague);
    if (url) return url;
  }

  return fallbackAvatar;
}

function resolveUserDisplayName(userId: string, defaultName?: string): string {
  const username = userId.replace(/^@/, '').split(':')[0]?.toLowerCase();
  const isCurrentMe =
    userId === chatStore.currentUserId ||
    username === userStore.userInfo?.username?.toLowerCase();

  if (isCurrentMe) {
    return resolveChatUserDisplayName(
      userId,
      [userStore.userInfo?.realName, userStore.userInfo?.username, defaultName],
      $t('chat.unknownUser'),
    );
  }

  const colleague = resolveUserColleague(userId);
  if (colleague?.name) {
    return colleague.name;
  }

  return resolveChatUserDisplayName(
    userId,
    [defaultName],
    $t('chat.unknownUser'),
  );
}

const displayedEntries = computed<ReactionUserEntry[]>(() => {
  if (!props.message) return [];

  const list: ReactionUserEntry[] = [];

  for (const reaction of reactions.value) {
    if (activeTab.value !== 'all' && activeTab.value !== reaction.key) {
      continue;
    }

    for (const user of reaction.users || []) {
      const username = user.userId
        .replace(/^@/, '')
        .split(':')[0]
        ?.toLowerCase();
      const isMe =
        user.userId === chatStore.currentUserId ||
        user.displayName === $t('chat.you') ||
        username === userStore.userInfo?.username?.toLowerCase();

      list.push({
        avatarUrl: resolveUserAvatar(user.userId, user.avatarUrl),
        displayName: resolveUserDisplayName(user.userId, user.displayName),
        emoji: reaction.key,
        isMe,
        userId: user.userId,
      });
    }
  }

  return list;
});

function getInitials(name: string): string {
  const parts = name.trim().split(/\s+/);
  return parts.length > 1
    ? (parts[0]?.[0] || '') + (parts.at(-1)?.[0] || '')
    : parts[0]?.slice(0, 2) || '';
}

function handleRemoveMyReaction(entry: ReactionUserEntry): void {
  if (!props.message) return;
  locallyRemovedReactions.value.push({
    emoji: entry.emoji,
    userId: entry.userId,
  });

  if (
    activeTab.value !== 'all' &&
    !reactions.value.some((r) => r.key === activeTab.value)
  ) {
    activeTab.value = 'all';
  }

  emit('toggleReaction', props.message, entry.emoji);
}
</script>

<template>
  <Modal
    :open="open"
    :title="$t('chat.reactionDetails')"
    :footer="null"
    :width="420"
    destroy-on-close
    @update:open="emit('update:open', $event)"
  >
    <div class="mt-2">
      <Tabs v-model:active-key="activeTab" size="small">
        <TabPane
          key="all"
          :tab="`${$t('chat.allReactions')} (${totalCount})`"
        />
        <TabPane
          v-for="r in reactions"
          :key="r.key"
          :tab="`${r.key} ${r.count}`"
        />
      </Tabs>

      <div class="max-h-72 overflow-y-auto divide-y divide-border/40 py-1">
        <div
          v-for="(entry, index) in displayedEntries"
          :key="`${entry.userId}-${entry.emoji}-${index}`"
          class="flex items-center justify-between py-2 px-1 hover:bg-muted/40 rounded-md transition-colors"
        >
          <div class="flex items-center gap-2.5 min-w-0">
            <Avatar
              :size="32"
              :src="entry.avatarUrl"
              class="shrink-0 bg-primary/10 text-primary font-semibold text-xs"
            >
              <span v-if="getInitials(entry.displayName)">
                {{ getInitials(entry.displayName) }}
              </span>
              <IconifyIcon
                v-else
                icon="lucide:user"
                class="size-4 opacity-80"
              />
            </Avatar>
            <div class="min-w-0">
              <div class="truncate text-sm font-medium text-foreground">
                {{ entry.displayName }}
                <span
                  v-if="entry.isMe"
                  class="ml-1 text-xs text-muted-foreground font-normal"
                >
                  ({{ $t('chat.you') }})
                </span>
              </div>
            </div>
          </div>

          <div class="flex items-center gap-2">
            <span class="text-base select-none">{{ entry.emoji }}</span>
            <Tooltip v-if="entry.isMe" :title="$t('chat.removeReaction')">
              <button
                type="button"
                :aria-label="$t('chat.removeReaction')"
                class="flex size-6 cursor-pointer items-center justify-center rounded-full text-muted-foreground transition-colors hover:bg-destructive/10 hover:text-destructive"
                @click="handleRemoveMyReaction(entry)"
              >
                <IconifyIcon icon="lucide:x" class="size-3.5" />
              </button>
            </Tooltip>
          </div>
        </div>

        <Empty
          v-if="displayedEntries.length === 0"
          :image="Empty.PRESENTED_IMAGE_SIMPLE"
          :description="$t('chat.reactions')"
          class="my-4"
        />
      </div>
    </div>
  </Modal>
</template>

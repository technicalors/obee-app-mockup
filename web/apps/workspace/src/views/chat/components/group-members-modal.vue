<script setup lang="ts">
import type { User } from '#/api';
import type { ChatRoomMemberInfo } from '#/store';

import { computed, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Avatar,
  Button,
  Empty,
  Input,
  Modal,
  Popconfirm,
  Select,
  Tag,
  Tooltip,
} from 'ant-design-vue';

import { $t } from '#/locales';
import { resolveChatUserDisplayName } from '#/store';
import { getUserAvatarSource } from '#/views/users/avatar';

interface Props {
  canInviteMembers?: boolean;
  colleagues?: User[];
  currentUserId?: null | string;
  isAddingMember?: boolean;
  members: ChatRoomMemberInfo[];
  open: boolean;
  removableMemberIds?: string[];
  removingMemberId?: null | string;
  roomTitle?: string;
}

const props = withDefaults(defineProps<Props>(), {
  canInviteMembers: true,
  colleagues: () => [],
  currentUserId: null,
  isAddingMember: false,
  removableMemberIds: () => [],
  removingMemberId: null,
  roomTitle: '',
});

const emit = defineEmits<{
  directChat: [userId: string];
  inviteMember: [userId: string];
  removeMember: [userId: string];
  'update:open': [val: boolean];
}>();

const searchKeyword = ref('');
const selectedMemberId = ref<string>();

watch(
  () => props.open,
  (val) => {
    if (val) {
      searchKeyword.value = '';
      selectedMemberId.value = undefined;
    }
  },
);

function getMemberColleague(userId: string): undefined | User {
  if (!props.colleagues || props.colleagues.length === 0) return undefined;
  const username = userId.replace(/^@/, '').split(':')[0]?.toLowerCase();
  return props.colleagues.find(
    (c) =>
      c.username.toLowerCase() === username ||
      (c.matrix_user_id &&
        c.matrix_user_id.toLowerCase() === userId.toLowerCase()),
  );
}

function getMemberDisplayName(member: ChatRoomMemberInfo): string {
  const colleague = getMemberColleague(member.userId);
  return resolveChatUserDisplayName(
    member.userId,
    [colleague?.name, member.displayName],
    $t('chat.unknownUser'),
  );
}

function getMemberUsername(member: ChatRoomMemberInfo): string {
  const colleague = getMemberColleague(member.userId);
  if (colleague?.username) {
    return `@${colleague.username}`;
  }
  return member.userId;
}

function getMemberAvatar(member: ChatRoomMemberInfo): string | undefined {
  const colleague = getMemberColleague(member.userId);
  if (colleague) {
    return getUserAvatarSource(colleague);
  }
  return member.avatarUrl;
}

function getMemberInitials(name: string): string {
  const clean = name.replaceAll(/[^\p{L}\p{N}\s]/gu, '').trim();
  const parts = clean.split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '';
  if (parts.length === 1) return parts[0]?.slice(0, 2).toUpperCase() ?? '';
  return `${parts[0]?.[0] ?? ''}${parts.at(-1)?.[0] ?? ''}`.toUpperCase();
}

interface EnrichedMember {
  avatarUrl?: string;
  colleague?: User;
  displayName: string;
  initials: string;
  isAdmin: boolean;
  isMe: boolean;
  raw: ChatRoomMemberInfo;
  userId: string;
  username: string;
}

const enrichedMembers = computed<EnrichedMember[]>(() => {
  return props.members
    .map((m) => {
      const colleague = getMemberColleague(m.userId);
      const displayName = getMemberDisplayName(m);
      const username = getMemberUsername(m);
      const avatarUrl = getMemberAvatar(m);
      const initials = getMemberInitials(displayName);
      const isMe =
        Boolean(props.currentUserId) &&
        m.userId.toLowerCase() === props.currentUserId?.toLowerCase();
      const isAdmin = m.isAdmin;

      return {
        avatarUrl,
        colleague,
        displayName,
        initials,
        isAdmin,
        isMe,
        raw: m,
        userId: m.userId,
        username,
      };
    })
    .toSorted((a, b) => {
      if (a.isMe && !b.isMe) return -1;
      if (!a.isMe && b.isMe) return 1;
      if (a.isAdmin && !b.isAdmin) return -1;
      if (!a.isAdmin && b.isAdmin) return 1;
      return a.displayName.localeCompare(b.displayName);
    });
});

const filteredMembers = computed(() => {
  const q = searchKeyword.value.trim().toLowerCase();
  if (!q) return enrichedMembers.value;
  return enrichedMembers.value.filter(
    (m) =>
      m.displayName.toLowerCase().includes(q) ||
      m.username.toLowerCase().includes(q) ||
      m.userId.toLowerCase().includes(q),
  );
});

const isCurrentUserAdmin = computed(() =>
  enrichedMembers.value.some((member) => member.isMe && member.isAdmin),
);

const availableMemberOptions = computed(() => {
  if (!props.canInviteMembers || !isCurrentUserAdmin.value) return [];
  const existingMemberIds = new Set(
    props.members.map((member) => member.userId.toLowerCase()),
  );
  const existingUsernames = new Set(
    props.members.map((member) =>
      getMemberUsername(member).replace(/^@/, '').split(':')[0]?.toLowerCase(),
    ),
  );

  return props.colleagues
    .filter((colleague) => {
      const matrixUserId = colleague.matrix_user_id?.toLowerCase();
      return Boolean(
        matrixUserId &&
        !existingMemberIds.has(matrixUserId) &&
        !existingUsernames.has(colleague.username.toLowerCase()),
      );
    })
    .map((colleague) => ({
      label: colleague.name || colleague.username,
      value: colleague.matrix_user_id as string,
    }));
});

watch(availableMemberOptions, (options) => {
  if (
    selectedMemberId.value &&
    !options.some((option) => option.value === selectedMemberId.value)
  ) {
    selectedMemberId.value = undefined;
  }
});

function handleInviteMember(): void {
  if (
    !selectedMemberId.value ||
    props.isAddingMember ||
    !props.canInviteMembers ||
    !isCurrentUserAdmin.value
  ) {
    return;
  }
  emit('inviteMember', selectedMemberId.value);
}

function handleDirectChat(userId: string): void {
  emit('directChat', userId);
  emit('update:open', false);
}
</script>

<template>
  <Modal
    :open="open"
    :title="$t('chat.groupMembers')"
    :footer="null"
    destroy-on-close
    width="480px"
    @cancel="emit('update:open', false)"
  >
    <div class="space-y-3 pt-2">
      <!-- Search Input -->
      <Input
        v-model:value="searchKeyword"
        :placeholder="$t('chat.searchMembers')"
        allow-clear
        class="rounded-lg"
      >
        <template #prefix>
          <IconifyIcon
            icon="lucide:search"
            class="size-4 text-muted-foreground"
          />
        </template>
      </Input>

      <!-- Add Member -->
      <div
        v-if="canInviteMembers && isCurrentUserAdmin"
        class="flex items-center gap-2"
      >
        <Select
          v-model:value="selectedMemberId"
          show-search
          option-filter-prop="label"
          :options="availableMemberOptions"
          :loading="isAddingMember"
          :disabled="isAddingMember"
          :placeholder="$t('chat.selectMemberPlaceholder')"
          :not-found-content="$t('chat.noAvailableMembers')"
          class="min-w-0 flex-1"
        />
        <Button
          type="primary"
          :loading="isAddingMember"
          :disabled="!selectedMemberId"
          class="flex shrink-0 items-center justify-center"
          @click="handleInviteMember"
        >
          <template #icon>
            <IconifyIcon icon="lucide:user-plus" class="size-3.5" />
          </template>
          {{ $t('chat.addMember') }}
        </Button>
      </div>

      <!-- Member List -->
      <div class="max-h-[380px] divide-y divide-border/50 overflow-y-auto pr-1">
        <div
          v-for="member in filteredMembers"
          :key="member.userId"
          class="flex items-center justify-between gap-3 rounded-lg px-2 py-2.5 transition-colors hover:bg-muted/50"
        >
          <!-- Member Info -->
          <div class="flex min-w-0 flex-1 items-center gap-3">
            <Avatar
              :size="38"
              :src="member.avatarUrl"
              class="shrink-0 border border-border/60 font-medium shadow-2xs"
              :class="
                member.isAdmin
                  ? 'bg-primary/20 text-primary'
                  : 'bg-muted text-foreground'
              "
            >
              <span v-if="member.initials">{{ member.initials }}</span>
              <IconifyIcon v-else icon="lucide:user" class="size-4" />
            </Avatar>

            <div class="min-w-0 flex-1">
              <div class="flex items-center gap-1.5">
                <span
                  class="truncate text-sm font-medium text-foreground"
                  :title="member.displayName"
                >
                  {{ member.displayName }}
                </span>
                <Tag
                  v-if="member.isMe"
                  color="blue"
                  class="!m-0 !px-1 !text-[10px] !leading-normal"
                >
                  {{ $t('chat.you') }}
                </Tag>
                <Tag
                  v-if="member.isAdmin"
                  color="gold"
                  class="!m-0 !px-1 !text-[10px] !leading-normal"
                >
                  {{ $t('chat.groupAdmin') }}
                </Tag>
              </div>
              <div
                class="truncate text-xs text-muted-foreground"
                :title="member.username"
              >
                {{ member.username }}
              </div>
            </div>
          </div>

          <!-- Actions -->
          <div v-if="!member.isMe" class="flex shrink-0 items-center gap-1">
            <Tooltip :title="$t('chat.directMessage')">
              <Button
                type="text"
                shape="circle"
                class="flex items-center justify-center text-muted-foreground hover:text-primary"
                @click="handleDirectChat(member.userId)"
              >
                <template #icon>
                  <IconifyIcon icon="lucide:message-square" class="size-4" />
                </template>
              </Button>
            </Tooltip>

            <Tooltip
              v-if="removableMemberIds.includes(member.userId)"
              :title="$t('chat.removeMember')"
            >
              <Popconfirm
                :title="
                  $t('chat.removeMemberConfirm', {
                    member: member.displayName,
                  })
                "
                :ok-text="$t('chat.removeMember')"
                :cancel-text="$t('chat.cancel')"
                :disabled="Boolean(removingMemberId)"
                @confirm="emit('removeMember', member.userId)"
              >
                <Button
                  type="text"
                  danger
                  shape="circle"
                  :loading="removingMemberId === member.userId"
                  class="flex items-center justify-center text-muted-foreground hover:text-destructive"
                >
                  <template #icon>
                    <IconifyIcon icon="lucide:user-minus" class="size-4" />
                  </template>
                </Button>
              </Popconfirm>
            </Tooltip>
          </div>
        </div>

        <div v-if="filteredMembers.length === 0" class="py-8">
          <Empty
            :image="Empty.PRESENTED_IMAGE_SIMPLE"
            :description="$t('chat.noSearchResults')"
          />
        </div>
      </div>
      <!-- Footer Action -->
      <div class="flex justify-end border-t border-border pt-3">
        <Button @click="emit('update:open', false)">
          {{ $t('chat.close') }}
        </Button>
      </div>
    </div>
  </Modal>
</template>

<script setup lang="ts">
import type { ChatMessageItem } from '#/store';

import { ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Button, Popconfirm, Popover, Space } from 'ant-design-vue';

import { $t } from '#/locales';

import { useChatMessageActions } from '../composables/use-chat-message-actions';
import { CHAT_REACTION_DEFINITIONS } from '../composables/use-chat-reactions';

interface Props {
  canPin?: boolean;
  isPinned?: boolean;
  isLastInCluster?: boolean;
  message: ChatMessageItem;
}

const props = withDefaults(defineProps<Props>(), {
  canPin: false,
  isPinned: false,
  isLastInCluster: false,
});

const emit = defineEmits<{
  react: [msg: ChatMessageItem, emoji: string];
  redact: [msg: ChatMessageItem];
  reply: [msg: ChatMessageItem];
  toggleTimestamp: [msg: ChatMessageItem];
}>();

const isReactionPopoverOpen = ref(false);

function handleSelectReaction(emoji: string): void {
  isReactionPopoverOpen.value = false;
  emit('react', props.message, emoji);
}

const {
  handleRedact,
  handleReply,
  handleTogglePin,
  handleToggleTimestamp,
  isPinning,
  isRedacting,
} = useChatMessageActions({
  onRedact: (msg) => emit('redact', msg),
  onReply: (msg) => emit('reply', msg),
  onToggleTimestamp: (msg) => emit('toggleTimestamp', msg),
});
</script>

<template>
  <div
    v-if="!message.isRedacted"
    class="absolute top-1/2 -translate-y-1/2 z-10 flex items-center rounded-full border border-border bg-card/95 px-1.5 py-0.5 text-muted-foreground shadow-sm backdrop-blur-xs whitespace-nowrap opacity-0 pointer-events-none transition-opacity duration-150 group-hover/message:opacity-100 group-hover/message:pointer-events-auto"
    :class="message.isMe ? 'right-full mr-2' : 'left-full ml-2'"
  >
    <Space :size="2">
      <!-- React Action -->
      <Popover
        v-model:open="isReactionPopoverOpen"
        trigger="click"
        placement="top"
        :arrow="false"
        overlay-class-name="chat-reaction-popover"
      >
        <template #content>
          <div
            class="flex items-center gap-1.5 p-1"
            data-testid="chat-reaction-picker"
          >
            <Button
              v-for="item in CHAT_REACTION_DEFINITIONS"
              :key="item.key"
              size="small"
              type="text"
              shape="circle"
              :aria-label="$t(item.labelKey)"
              class="flex !size-7 cursor-pointer items-center justify-center text-base transition-all duration-150 hover:scale-135 hover:-translate-y-0.5"
              @click="handleSelectReaction(item.key)"
            >
              <span class="leading-none select-none">{{ item.key }}</span>
            </Button>
          </div>
        </template>
        <Button
          size="small"
          type="text"
          shape="circle"
          :aria-label="$t('chat.react')"
          class="flex items-center justify-center !size-6 cursor-pointer text-muted-foreground hover:text-foreground"
        >
          <template #icon>
            <IconifyIcon icon="lucide:smile-plus" class="size-3.5" />
          </template>
        </Button>
      </Popover>
      <!-- Reply Action -->
      <Button
        size="small"
        type="text"
        shape="circle"
        :aria-label="$t('chat.reply')"
        class="flex items-center justify-center !size-6 cursor-pointer text-muted-foreground hover:text-foreground"
        @click="handleReply(message)"
      >
        <template #icon>
          <IconifyIcon icon="lucide:reply" class="size-3.5" />
        </template>
      </Button>

      <!-- Info Action -->
      <Button
        size="small"
        type="text"
        shape="circle"
        :aria-label="$t('chat.info')"
        class="flex items-center justify-center !size-6 cursor-pointer text-muted-foreground hover:text-foreground"
        @click="handleToggleTimestamp(message, isLastInCluster)"
      >
        <template #icon>
          <IconifyIcon icon="lucide:info" class="size-3.5" />
        </template>
      </Button>

      <!-- Pin Action -->
      <Button
        v-if="canPin && message.status === 'sent'"
        size="small"
        type="text"
        shape="circle"
        :loading="isPinning"
        :aria-label="$t(isPinned ? 'chat.unpin' : 'chat.pin')"
        class="flex items-center justify-center !size-6 cursor-pointer text-muted-foreground hover:text-foreground"
        @click="handleTogglePin(message, isPinned)"
      >
        <template #icon>
          <IconifyIcon
            :icon="isPinned ? 'lucide:pin-off' : 'lucide:pin'"
            class="size-3.5"
          />
        </template>
      </Button>

      <!-- Redact Action (sender only) -->
      <Popconfirm
        v-if="message.isMe"
        :title="$t('chat.redactConfirm')"
        :ok-text="$t('chat.ok')"
        :cancel-text="$t('chat.cancel')"
        :ok-button-props="{ loading: isRedacting }"
        @confirm="handleRedact(message)"
      >
        <Button
          size="small"
          type="text"
          shape="circle"
          danger
          :loading="isRedacting"
          :aria-label="$t('chat.redact')"
          class="flex items-center justify-center !size-6 cursor-pointer"
        >
          <template #icon>
            <IconifyIcon icon="lucide:trash-2" class="size-3.5" />
          </template>
        </Button>
      </Popconfirm>
    </Space>
  </div>
</template>

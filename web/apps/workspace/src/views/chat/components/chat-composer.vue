<script setup lang="ts">
import type { ChatMessageItem } from '#/store';

import { nextTick, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { Button, Input, Tooltip } from 'ant-design-vue';

import { $t } from '#/locales';

import { useTypingSender } from '../composables/use-chat-typing';

interface Props {
  isDisabled?: boolean;
  isSending: boolean;
  sendFilesError?: boolean;
  uploadProgress?: null | number;
  replyingTo?: ChatMessageItem | null;
}

const props = withDefaults(defineProps<Props>(), {
  isDisabled: false,
  replyingTo: undefined,
  sendFilesError: false,
  uploadProgress: null,
});

const emit = defineEmits<{
  cancelReply: [];
  read: [];
  retryUpload: [];
  send: [text: string];
  sendFiles: [files: File[]];
  typing: [isTyping: boolean];
}>();

const inputMessage = ref('');
const fileInput = ref<HTMLInputElement | null>(null);
const messageInput = ref<null | { focus: () => void }>(null);

const { handleTyping, stopTyping } = useTypingSender((isTyping) => {
  emit('typing', isTyping);
});

watch(inputMessage, (newVal) => {
  if (newVal.length > 0) {
    handleTyping();
  } else {
    stopTyping();
  }
});

function focusMessageInput(): void {
  void nextTick(() => {
    if (!props.isDisabled && !props.isSending) {
      messageInput.value?.focus();
    }
  });
}

watch(
  () => props.isSending,
  (isSending, wasSending) => {
    if (wasSending && !isSending) {
      focusMessageInput();
    }
  },
);

function handleSubmit(): void {
  if (props.isDisabled) return;
  const text = inputMessage.value.trim();
  if (!text) return;
  stopTyping();
  emit('send', text);
  inputMessage.value = '';
  focusMessageInput();
}

function handleSendLike(): void {
  if (props.isDisabled || props.isSending) return;
  stopTyping();
  emit('send', '👍');
  focusMessageInput();
}

function openFilePicker(): void {
  if (props.isDisabled) return;
  fileInput.value?.click();
}

function handleFilesSelected(event: Event): void {
  const input = event.target;
  if (!(input instanceof HTMLInputElement)) {
    throw new Error('Chat attachment input is unavailable');
  }

  const files = [...(input.files ?? [])];
  input.value = '';
  if (files.length > 0) {
    emit('sendFiles', files);
  }
}
</script>

<template>
  <footer
    class="shrink-0 space-y-2.5 border-t border-border bg-card/60 p-3.5 backdrop-blur-xs"
  >
    <!-- Replying to preview banner -->
    <div
      v-if="replyingTo"
      aria-live="polite"
      class="relative mx-0.5 flex overflow-hidden rounded-lg border border-primary/20 bg-primary/5 text-xs shadow-xs transition-colors"
      data-testid="chat-reply-preview"
      role="status"
    >
      <div class="flex min-w-0 flex-1 items-center gap-2.5 px-3 py-2 pr-8">
        <div
          class="flex size-7 shrink-0 items-center justify-center rounded-md bg-primary/10 text-primary"
          aria-hidden="true"
        >
          <IconifyIcon icon="lucide:reply" class="size-3.5" />
        </div>
        <div class="min-w-0 flex-1 space-y-0.5">
          <div class="flex min-w-0 items-center gap-1.5 leading-4">
            <span class="shrink-0 font-medium text-muted-foreground">
              {{ $t('chat.replyingTo') }}
            </span>
            <span class="text-muted-foreground/60" aria-hidden="true">·</span>
            <span class="truncate font-semibold text-foreground">
              {{ replyingTo.senderName }}
            </span>
          </div>
          <p class="truncate leading-4 text-muted-foreground">
            {{ replyingTo.body }}
          </p>
        </div>
      </div>

      <Tooltip :title="$t('chat.cancelReply')">
        <Button
          size="small"
          type="text"
          shape="circle"
          :aria-label="$t('chat.cancelReply')"
          class="!m-0 !absolute top-0 right-0 flex !size-7 shrink-0 items-center justify-center !bg-transparent text-muted-foreground transition-colors hover:!bg-transparent hover:text-primary focus-visible:!bg-transparent focus-visible:text-primary"
          data-testid="chat-cancel-reply"
          @click="emit('cancelReply')"
        >
          <template #icon>
            <IconifyIcon icon="lucide:x" class="size-3.5" />
          </template>
        </Button>
      </Tooltip>
    </div>

    <!-- Textarea and Actions -->
    <div
      class="flex items-center gap-1.5 rounded-lg border p-1.5 shadow-xs transition-colors"
      :class="
        isDisabled
          ? 'cursor-not-allowed border-border/70 bg-slate-200/80 opacity-80 dark:bg-muted/70'
          : 'border-border bg-background/75 focus-within:border-primary/50 focus-within:ring-2 focus-within:ring-primary/10'
      "
      data-testid="chat-composer-input"
      @click="emit('read')"
      @focusin="emit('read')"
    >
      <input
        ref="fileInput"
        class="hidden"
        :disabled="isDisabled || isSending"
        type="file"
        multiple
        @change="handleFilesSelected"
      />
      <Tooltip :title="$t('chat.attachFile')">
        <Button
          type="text"
          shape="circle"
          :disabled="isDisabled || isSending"
          :aria-label="$t('chat.attachFile')"
          class="flex size-8 shrink-0 items-center justify-center !text-muted-foreground hover:!bg-accent hover:!text-foreground disabled:!cursor-not-allowed"
          @click="openFilePicker"
        >
          <template #icon>
            <IconifyIcon icon="lucide:paperclip" class="size-4" />
          </template>
        </Button>
      </Tooltip>
      <Input.TextArea
        ref="messageInput"
        v-model:value="inputMessage"
        :placeholder="$t('chat.inputPlaceholder')"
        :auto-size="{ minRows: 1, maxRows: 5 }"
        :bordered="false"
        class="min-w-0 flex-1 !px-1.5 !py-1.5 !shadow-none disabled:!cursor-not-allowed disabled:!bg-transparent"
        :disabled="isDisabled || isSending"
        @focus="emit('read')"
        @press-enter.exact.prevent="handleSubmit"
        @keydown.esc="emit('cancelReply')"
      />
      <!-- Send Button (active when input has text) -->
      <Tooltip v-if="inputMessage.trim()" :title="$t('chat.send')">
        <Button
          type="text"
          shape="circle"
          :loading="isSending"
          :disabled="isDisabled || isSending"
          :aria-label="$t('chat.send')"
          class="flex size-8 shrink-0 items-center justify-center !border-0 !bg-transparent !shadow-none disabled:!bg-transparent"
          :class="
            isDisabled || isSending
              ? '!text-muted-foreground/50 hover:!bg-transparent'
              : '!text-primary hover:!bg-accent'
          "
          @click="handleSubmit"
        >
          <template #icon>
            <IconifyIcon icon="mdi:send" class="size-5" />
          </template>
        </Button>
      </Tooltip>
      <!-- Quick Like Button (default when input is empty) -->
      <Tooltip v-else :title="$t('chat.like')">
        <Button
          type="text"
          shape="circle"
          :loading="isSending"
          :disabled="isDisabled || isSending"
          :aria-label="$t('chat.like')"
          class="flex size-8 shrink-0 items-center justify-center !border-0 !bg-transparent !shadow-none transition-transform hover:scale-110 hover:!bg-accent disabled:!bg-transparent"
          :class="
            isDisabled || isSending
              ? '!text-muted-foreground/50 hover:!bg-transparent'
              : ''
          "
          @click="handleSendLike"
        >
          <template #icon>
            <span class="text-base leading-none select-none">👍</span>
          </template>
        </Button>
      </Tooltip>
    </div>
    <div
      v-if="uploadProgress !== null || sendFilesError"
      class="flex min-h-4 items-center gap-2 px-1 text-xs"
    >
      <span v-if="uploadProgress !== null" class="text-muted-foreground">
        {{ Math.round(uploadProgress) }}%
      </span>
      <span v-if="sendFilesError" class="text-destructive">
        {{ $t('chat.encryption.uploadFailed') }}
      </span>
      <Button
        v-if="sendFilesError"
        size="small"
        type="link"
        class="!h-auto !px-0 text-xs"
        @click="emit('retryUpload')"
      >
        {{ $t('chat.encryption.retry') }}
      </Button>
    </div>
  </footer>
</template>

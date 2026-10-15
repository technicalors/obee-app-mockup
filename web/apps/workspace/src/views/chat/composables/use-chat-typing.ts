import type { ChatTypingUser } from '#/store';

import { onUnmounted, ref } from 'vue';

import { $t } from '#/locales';

export function formatTypingIndicatorText(
  typingUsers: ChatTypingUser[],
): string {
  if (!typingUsers || typingUsers.length === 0) {
    return '';
  }

  if (typingUsers.length === 1) {
    return $t('chat.typingSingle', {
      user: typingUsers[0]?.displayName || '',
    });
  }

  if (typingUsers.length === 2) {
    return $t('chat.typingTwo', {
      user1: typingUsers[0]?.displayName || '',
      user2: typingUsers[1]?.displayName || '',
    });
  }

  return $t('chat.typingMultiple', {
    count: typingUsers.length - 1,
    user: typingUsers[0]?.displayName || '',
  });
}

export function formatHeaderTypingText(
  typingUsers: ChatTypingUser[],
  isDirect: boolean,
): string {
  if (!typingUsers || typingUsers.length === 0) {
    return '';
  }

  if (isDirect) {
    return $t('chat.typing');
  }

  return formatTypingIndicatorText(typingUsers);
}

export function useTypingSender(
  sendTypingFn: (isTyping: boolean) => Promise<void> | void,
) {
  const isTypingActive = ref(false);
  let lastSentTimestamp = 0;
  let typingTimeoutTimer: null | ReturnType<typeof setTimeout> = null;
  const THROTTLE_MS = 2000;
  const IDLE_TIMEOUT_MS = 3000;

  function handleTyping(): void {
    const now = Date.now();

    if (!isTypingActive.value || now - lastSentTimestamp >= THROTTLE_MS) {
      isTypingActive.value = true;
      lastSentTimestamp = now;
      void sendTypingFn(true);
    }

    if (typingTimeoutTimer) {
      clearTimeout(typingTimeoutTimer);
    }

    typingTimeoutTimer = setTimeout(() => {
      stopTyping();
    }, IDLE_TIMEOUT_MS);
  }

  function stopTyping(): void {
    if (typingTimeoutTimer) {
      clearTimeout(typingTimeoutTimer);
      typingTimeoutTimer = null;
    }

    if (isTypingActive.value) {
      isTypingActive.value = false;
      lastSentTimestamp = 0;
      void sendTypingFn(false);
    }
  }

  onUnmounted(() => {
    stopTyping();
  });

  return {
    handleTyping,
    stopTyping,
  };
}

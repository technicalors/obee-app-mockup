import type { ChatMessageItem } from '#/store';

import { ref } from 'vue';

import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useChatStore } from '#/store';

export interface UseChatMessageActionsOptions {
  onRedact?: (msg: ChatMessageItem) => void;
  onReply?: (msg: ChatMessageItem) => void;
  onToggleTimestamp?: (msg: ChatMessageItem) => void;
}

export function useChatMessageActions(
  options: UseChatMessageActionsOptions = {},
) {
  const store = useChatStore();
  const isRedacting = ref(false);
  const isPinning = ref(false);

  async function handleRedact(msg: ChatMessageItem): Promise<void> {
    const roomId = store.activeRoomId;
    if (!roomId || isRedacting.value) return;

    isRedacting.value = true;
    try {
      await store.redactMessage(roomId, msg.id);
      options.onRedact?.(msg);
    } catch (error) {
      console.error('Failed to redact message:', error);
    } finally {
      isRedacting.value = false;
    }
  }

  function handleReply(msg: ChatMessageItem): void {
    if (msg.isRedacted) return;
    options.onReply?.(msg);
  }

  function handleToggleTimestamp(
    msg: ChatMessageItem,
    isLastInCluster = false,
  ): void {
    if (isLastInCluster) return;
    options.onToggleTimestamp?.(msg);
  }

  async function handleTogglePin(
    msg: ChatMessageItem,
    isPinned: boolean,
  ): Promise<void> {
    const roomId = store.activeRoomId;
    if (!roomId || msg.isRedacted || isPinning.value) return;

    isPinning.value = true;
    try {
      await (isPinned
        ? store.unpinMessage(roomId, msg.id)
        : store.pinMessage(roomId, msg.id));
    } catch (error) {
      showRequestError(
        error,
        $t('chat.pinActionError'),
        'Failed to update pinned message:',
      );
    } finally {
      isPinning.value = false;
    }
  }

  return {
    handleRedact,
    handleReply,
    handleTogglePin,
    handleToggleTimestamp,
    isPinning,
    isRedacting,
  };
}

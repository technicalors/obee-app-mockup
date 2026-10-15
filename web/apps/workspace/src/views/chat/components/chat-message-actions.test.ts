import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { describe, expect, it } from 'vitest';

const chatMessageActionsSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/chat-message-actions.vue',
  ),
  'utf8',
);

const chatMessagesSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/components/chat-messages.vue',
  ),
  'utf8',
);

const useChatMessageActionsSource = readFileSync(
  resolve(
    process.cwd(),
    'apps/workspace/src/views/chat/composables/use-chat-message-actions.ts',
  ),
  'utf8',
);

describe('chatMessageActions component and composable', () => {
  it('encapsulates message toolbar actions and logic in a separate component and composable', () => {
    expect(chatMessageActionsSource).toContain('interface Props');
    expect(chatMessageActionsSource).toContain('message: ChatMessageItem');
    expect(chatMessageActionsSource).toContain('canPin?: boolean');
    expect(chatMessageActionsSource).toContain('isPinned?: boolean');
    expect(chatMessageActionsSource).toContain('isLastInCluster?: boolean');
    expect(chatMessageActionsSource).toContain('useChatMessageActions');
    expect(chatMessageActionsSource).toContain('handleReply(message)');
    expect(chatMessageActionsSource).toContain(
      'handleTogglePin(message, isPinned)',
    );
    expect(chatMessageActionsSource).toContain('chat.pin');
    expect(chatMessageActionsSource).toContain('chat.unpin');
    expect(chatMessageActionsSource).toContain('lucide:pin-off');
    expect(chatMessageActionsSource).toContain(
      'handleToggleTimestamp(message, isLastInCluster)',
    );
    expect(chatMessageActionsSource).toContain('handleRedact(message)');
    expect(chatMessageActionsSource).toContain('v-if="!message.isRedacted"');
    expect(chatMessageActionsSource).toContain('v-if="message.isMe"');
    expect(chatMessageActionsSource).toContain(
      'group-hover/message:opacity-100',
    );
    expect(chatMessageActionsSource).not.toContain('delay-200');
    expect(chatMessageActionsSource).not.toContain('group-focus-within');
    expect(chatMessageActionsSource).not.toContain('<Tooltip');

    expect(useChatMessageActionsSource).toContain(
      'function useChatMessageActions',
    );
    expect(useChatMessageActionsSource).toContain('store.pinMessage');
    expect(useChatMessageActionsSource).toContain('store.unpinMessage');
    expect(useChatMessageActionsSource).toContain('store.redactMessage');
    expect(useChatMessageActionsSource).toContain('isPinning');
    expect(useChatMessageActionsSource).toContain('isRedacting');
  });

  it('chat-messages delegates action rendering to ChatMessageActions and omits hover tooltips inside containerRef', () => {
    expect(chatMessagesSource).toContain('<ChatMessageActions');
    expect(chatMessagesSource).toContain(':message="msg"');
    expect(chatMessagesSource).toContain(':is-last-in-cluster=');
    expect(chatMessagesSource).toContain(':can-pin="canPinMessages"');
    expect(chatMessagesSource).toContain(
      ':is-pinned="pinnedEventIds.includes(msg.id)"',
    );
    expect(chatMessagesSource).toContain('@reply=');
    expect(chatMessagesSource).toContain('@toggle-timestamp=');
    expect(chatMessagesSource).toContain('@redact=');
    expect(chatMessagesSource).not.toContain('<Popconfirm');
    expect(chatMessagesSource).toContain('pinnedMessages');
    expect(chatMessagesSource).toContain('aria-expanded');

    const containerRefSection =
      chatMessagesSource.split('ref="containerRef"')[1] ?? '';
    expect(containerRefSection).not.toContain('<Tooltip');
    expect(containerRefSection).not.toContain(':title=');
  });
});

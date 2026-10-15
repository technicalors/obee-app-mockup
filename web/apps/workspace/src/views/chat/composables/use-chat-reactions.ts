import type { ChatMessageReaction } from '#/store';

import { $t } from '#/locales';

export const CHAT_REACTION_EMOJIS = [
  '👍',
  '❤️',
  '😂',
  '😮',
  '😢',
  '😡',
] as const;

export type ChatReactionEmoji = (typeof CHAT_REACTION_EMOJIS)[number];

export const QUICK_LIKE_EMOJI: ChatReactionEmoji = '👍';

export interface ChatReactionDefinition {
  key: ChatReactionEmoji;
  labelKey: string;
}

export const CHAT_REACTION_DEFINITIONS: ChatReactionDefinition[] = [
  { key: '👍', labelKey: 'chat.reactionLike' },
  { key: '❤️', labelKey: 'chat.reactionLove' },
  { key: '😂', labelKey: 'chat.reactionHaha' },
  { key: '😮', labelKey: 'chat.reactionWow' },
  { key: '😢', labelKey: 'chat.reactionSad' },
  { key: '😡', labelKey: 'chat.reactionAngry' },
];

export function getReactionLabelKey(key: string): string {
  const match = CHAT_REACTION_DEFINITIONS.find((item) => item.key === key);
  return match ? match.labelKey : 'chat.react';
}

export function getTotalReactionsCount(
  reactions?: ChatMessageReaction[],
): number {
  if (!reactions || reactions.length === 0) return 0;
  return reactions.reduce((acc, curr) => acc + curr.count, 0);
}

export function isSupportedReactionEmoji(emoji: string): boolean {
  return CHAT_REACTION_EMOJIS.includes(emoji as ChatReactionEmoji);
}

export function formatReactionTooltip(reaction: ChatMessageReaction): string {
  if (!reaction.users || reaction.users.length === 0) {
    return reaction.key;
  }

  const userList = [...reaction.users];
  const names: string[] = [];

  if (reaction.hasReacted) {
    names.push($t('chat.you'));
  }

  for (const u of userList) {
    const name = u.displayName || u.userId;
    if (reaction.hasReacted && name === $t('chat.you')) {
      continue;
    }
    if (!names.includes(name)) {
      names.push(name);
    }
  }

  if (names.length === 1) {
    return `${names[0]}: ${reaction.key}`;
  }

  if (names.length <= 3) {
    return `${names.join(', ')}: ${reaction.key}`;
  }

  const remaining = names.length - 2;
  return `${names[0]}, ${names[1]} +${remaining}: ${reaction.key}`;
}

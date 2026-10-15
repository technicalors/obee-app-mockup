import type { User } from '#/api';

export interface GroupMemberAvatarInfo {
  avatarUrl?: string;
  displayName: string;
  userId: string;
}

export interface ConversationItem {
  avatarUrl?: string;
  groupMemberAvatars?: GroupMemberAvatarInfo[];
  id: string;
  isDirect: boolean;
  lastEventTimestamp: number;
  lastMessage: string;
  memberCount?: number;
  name: string;
  roomId?: string;
  targetMatrixUserId?: null | string;
  unreadCount: number;
  user?: User;
}

export interface PendingColleague {
  name: string;
  targetMatrixUserId?: null | string;
  user: User;
}

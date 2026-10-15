import type { EncryptedFile } from 'matrix-js-sdk/lib/@types/media';

export type CryptoStatus =
  | 'error'
  | 'idle'
  | 'initializing'
  | 'ready'
  | 'recovery-required'
  | 'setup-required';

export type CryptoErrorCode = 'device-mismatch' | 'initialization-failed';

export type BrowserTrustStatus = 'not-trusted' | 'trusted' | 'unavailable';

export type RecoveryErrorCode =
  | 'invalid-key'
  | 'not-configured'
  | 'restore-failed'
  | 'setup-failed';

export type RoomEncryptionStatus = 'encrypted' | 'unencrypted' | 'unknown';

export interface ChatMessageAttachment {
  encryptedFile: EncryptedFile;
  filename: string;
  info: {
    mimetype?: string;
    size?: number;
  };
  msgtype: 'm.file' | 'm.image';
}

export interface ChatRoomSummary {
  alias?: string;
  avatarUrl?: string;
  directUserId?: string;
  id: string;
  encryptionStatus: RoomEncryptionStatus;
  isDirect: boolean;
  lastEventTimestamp: number;
  lastMessage: string;
  memberCount: number;
  memberUserIds?: string[];
  name: string;
  unreadCount: number;
}

export interface ChatRoomMemberInfo {
  avatarUrl?: string;
  displayName: string;
  isAdmin: boolean;
  membership?: string;
  powerLevel: number;
  userId: string;
}

export type ChatSystemEventType =
  | 'member_add'
  | 'member_create'
  | 'member_join'
  | 'member_kick'
  | 'member_leave';

export interface ChatSystemEvent {
  actorId: string;
  actorName: string;
  targetId: string;
  targetName: string;
  type: ChatSystemEventType;
}

export interface ChatMessageReaction {
  count: number;
  hasReacted: boolean;
  key: string;
  myEventId?: string;
  users: Array<{ avatarUrl?: string; displayName?: string; userId: string }>;
}

export interface ChatMessageReader {
  avatarUrl?: string;
  displayName: string;
  readTimestamp?: number;
  userId: string;
}

export interface ChatTypingUser {
  avatarUrl?: string;
  displayName: string;
  userId: string;
}

export interface ChatMessageItem {
  attachments?: ChatMessageAttachment[];
  body: string;
  decryptionStatus: 'decrypted' | 'failed' | 'pending' | 'plaintext';
  id: string;
  isMe: boolean;
  isRead: boolean;
  isReadByOther?: boolean;
  isRedacted?: boolean;
  isSystem?: boolean;
  reactions?: ChatMessageReaction[];
  readers?: ChatMessageReader[];
  replyTo?: {
    body: string;
    id: string;
    senderName: string;
  };
  senderId: string;
  senderName: string;
  status: 'error' | 'sending' | 'sent';
  systemEvent?: ChatSystemEvent;
  timestamp: number;
}

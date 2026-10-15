import type { RoomMessageEventContent } from 'matrix-js-sdk/lib/@types/events';
import type { EncryptedFile } from 'matrix-js-sdk/lib/@types/media';
import type {
  CryptoApi,
  CryptoCallbacks,
  GeneratedSecretStorageKey,
} from 'matrix-js-sdk/lib/crypto-api';
import type { MatrixEvent } from 'matrix-js-sdk/lib/models/event';
import type { Room } from 'matrix-js-sdk/lib/models/room';
import type { IPowerLevelsContent } from 'matrix-js-sdk/lib/models/room-state';

import type {
  BrowserTrustStatus,
  ChatMessageAttachment,
  ChatMessageItem,
  ChatMessageReaction,
  ChatMessageReader,
  ChatRoomSummary,
  ChatSystemEventType,
  ChatTypingUser,
  CryptoErrorCode,
  CryptoStatus,
  RecoveryErrorCode,
  RoomEncryptionStatus,
} from './chat.types';

import { computed, markRaw, ref, shallowRef } from 'vue';

import { useUserStore } from '@vben/stores';

import {
  decryptAttachment,
  encryptAttachment,
} from 'matrix-encrypt-attachment';
import {
  ClientEvent,
  createClient,
  EventType,
  HttpApiEvent,
  MatrixClient,
  MatrixError,
  MatrixEventEvent,
  NotificationCountType,
  Preset,
  RelationType,
  RoomEvent,
  RoomMemberEvent,
  RoomStateEvent,
} from 'matrix-js-sdk';
import { MsgType } from 'matrix-js-sdk/lib/@types/event';
import { decodeRecoveryKey } from 'matrix-js-sdk/lib/crypto-api/recovery-key';
import { Method } from 'matrix-js-sdk/lib/http-api';
import { acceptHMRUpdate, defineStore } from 'pinia';

import { getMatrixCredentialsApi } from '#/api/chat';
import { mockAuthUser, mockUsers } from '#/mocks/data';

import { createChatGroupActions } from './chat-group-actions';
import {
  getDirectChatAlias,
  normalizeMatrixLocalpart,
  stripReplyFallback,
} from './chat-utils';
import {
  clearMatrixRecoveryKey,
  loadMatrixRecoveryKey,
  saveMatrixRecoveryKey,
} from './matrix-recovery-vault';
import { loadMatrixSession, saveMatrixSession } from './matrix-session';

export {
  getDirectChatAlias,
  normalizeMatrixLocalpart,
  stripReplyFallback,
} from './chat-utils';
export type {
  BrowserTrustStatus,
  ChatMessageAttachment,
  ChatMessageItem,
  ChatMessageReaction,
  ChatMessageReader,
  ChatRoomMemberInfo,
  ChatRoomSummary,
  ChatSystemEvent,
  ChatSystemEventType,
  ChatTypingUser,
  CryptoErrorCode,
  CryptoStatus,
  RecoveryErrorCode,
  RoomEncryptionStatus,
} from './chat.types';

interface RoomPinnedEventsContent {
  pinned: string[];
}

interface CachedSecretStorageKey {
  key: Uint8Array<ArrayBuffer>;
  keyId: string;
}

interface PendingSecretStorageRequest {
  reject: (error: Error) => void;
  resolve: (value: [string, Uint8Array<ArrayBuffer>] | null) => void;
}

interface MatrixMessageContent {
  'm.relates_to'?: {
    'm.in_reply_to'?: {
      event_id?: string;
    };
  };
  body?: string;
  file?: EncryptedFile;
  filename?: string;
  info?: {
    mimetype?: string;
    size?: number;
  };
  msgtype?: string;
}

const ENCRYPTION_ALGORITHM = 'm.megolm.v1.aes-sha2';

export const useChatStore = defineStore('chat', () => {
  const client = shallowRef<MatrixClient | null>(null);
  const isInitializing = ref(false);
  const isReady = ref(false);
  const cryptoStatus = ref<CryptoStatus>('idle');
  const cryptoError = ref<CryptoErrorCode | null>(null);
  const browserTrustStatus = ref<BrowserTrustStatus>('not-trusted');
  const isCryptoReady = computed(() => cryptoStatus.value === 'ready');
  const recoveryKey = ref<null | string>(null);
  const recoveryError = ref<null | RecoveryErrorCode>(null);
  const isRecoveryActionLoading = ref(false);
  const matrixDeviceId = ref<null | string>(null);
  const activeRoomId = ref<null | string>(null);
  const rooms = ref<ChatRoomSummary[]>([]);
  const messages = ref<ChatMessageItem[]>([]);
  const activeTypingUsers = ref<ChatTypingUser[]>([]);
  const pinnedEventIds = ref<string[]>([]);
  const currentUserId = ref<null | string>(null);
  const isLoadingMessages = ref(false);
  const isLoadingOlder = ref(false);
  const hasMoreHistory = ref(true);
  let roomSelectionVersion = 0;
  const roomSyncVersion = ref(0);
  const userStore = useUserStore();
  let initializationPromise: null | Promise<void> = null;
  let cryptoApi: CryptoApi | null = null;
  let cachedSecretStorageKey: CachedSecretStorageKey | null = null;
  let generatedSecretStorageKey: GeneratedSecretStorageKey | null = null;
  const pendingSecretStorageRequests: PendingSecretStorageRequest[] = [];

  function getRecoveryKeyScope() {
    const obeeUserId = userStore.userInfo?.userId;
    if (!obeeUserId || !currentUserId.value || !matrixDeviceId.value) {
      return null;
    }

    return {
      deviceId: matrixDeviceId.value,
      matrixUserId: currentUserId.value,
      obeeUserId,
    };
  }

  async function persistRecoveryKey(encodedRecoveryKey: string): Promise<void> {
    const scope = getRecoveryKeyScope();
    if (!scope) {
      browserTrustStatus.value = 'unavailable';
      return;
    }

    const persisted = await saveMatrixRecoveryKey(scope, encodedRecoveryKey);
    browserTrustStatus.value = persisted ? 'trusted' : 'unavailable';
  }

  async function restoreStoredRecoveryKey(): Promise<boolean> {
    const scope = getRecoveryKeyScope();
    if (!scope || !client.value) return false;

    const encodedRecoveryKey = await loadMatrixRecoveryKey(scope);
    if (!encodedRecoveryKey) return false;

    let privateKey: null | Uint8Array<ArrayBuffer> = null;
    try {
      privateKey = decodeRecoveryKey(encodedRecoveryKey);
      const storedKey = await client.value.secretStorage.getKey();
      if (!storedKey) return false;

      const [keyId, keyInfo] = storedKey;
      const isValid = await client.value.secretStorage.checkKey(
        privateKey,
        keyInfo,
      );
      if (!isValid) {
        await clearMatrixRecoveryKey(scope);
        return false;
      }

      cachedSecretStorageKey = {
        key: cloneSecretStorageKey(privateKey),
        keyId,
      };
      browserTrustStatus.value = 'trusted';
      return true;
    } catch {
      await clearMatrixRecoveryKey(scope);
      return false;
    } finally {
      privateKey?.fill(0);
    }
  }

  function cloneSecretStorageKey(
    key: Uint8Array<ArrayBuffer>,
  ): Uint8Array<ArrayBuffer> {
    return new Uint8Array(key) as Uint8Array<ArrayBuffer>;
  }

  function rejectPendingSecretStorageRequests(error: Error): void {
    const pendingRequests = pendingSecretStorageRequests.splice(0);
    for (const request of pendingRequests) {
      request.reject(error);
    }
  }

  const cryptoCallbacks: CryptoCallbacks = {
    cacheSecretStorageKey(keyId, _keyInfo, key): void {
      cachedSecretStorageKey?.key.fill(0);
      cachedSecretStorageKey = {
        key: cloneSecretStorageKey(key),
        keyId,
      };
    },
    async getSecretStorageKey({
      keys,
    }): Promise<[string, Uint8Array<ArrayBuffer>] | null> {
      if (cachedSecretStorageKey) {
        if (!(cachedSecretStorageKey.keyId in keys)) {
          throw new Error('The cached Matrix recovery key is not valid');
        }
        return [
          cachedSecretStorageKey.keyId,
          cloneSecretStorageKey(cachedSecretStorageKey.key),
        ];
      }

      cryptoStatus.value = 'recovery-required';
      return new Promise((resolve, reject) => {
        pendingSecretStorageRequests.push({ reject, resolve });
      });
    },
  };

  async function prepareCryptoState(rawClient: MatrixClient): Promise<void> {
    const crypto = rawClient.getCrypto();
    if (!crypto) {
      throw new Error('Matrix Rust Crypto is not available');
    }

    cryptoApi = crypto;
    recoveryError.value = null;

    const [secretStorageStatus, backupInfo] = await Promise.all([
      crypto.getSecretStorageStatus(),
      crypto.getKeyBackupInfo(),
    ]);

    if (secretStorageStatus.defaultKeyId === null) {
      const generatedKey = await crypto.createRecoveryKeyFromPassphrase();
      if (!generatedKey.encodedPrivateKey) {
        generatedKey.privateKey.fill(0);
        throw new Error('Matrix did not return an encoded recovery key');
      }

      generatedSecretStorageKey = generatedKey;
      recoveryKey.value = generatedKey.encodedPrivateKey;
      cryptoStatus.value = 'setup-required';
      return;
    }

    await restoreStoredRecoveryKey();

    if (!backupInfo) {
      cryptoStatus.value = 'recovery-required';
      return;
    }

    try {
      await crypto.loadSessionBackupPrivateKeyFromSecretStorage();
      await crypto.checkKeyBackupAndEnable();
    } catch (error) {
      if (
        error instanceof Error &&
        error.message.includes('missing decryption key in secret storage')
      ) {
        cryptoStatus.value = 'recovery-required';
        return;
      }
      throw error;
    }
    cryptoStatus.value = 'ready';
  }

  async function initializeCrypto(): Promise<void> {
    if (!client.value || !currentUserId.value || !matrixDeviceId.value) {
      throw new Error('Matrix client credentials are not available');
    }

    await client.value.initRustCrypto({
      cryptoDatabasePrefix: `obee-matrix-${currentUserId.value}-${matrixDeviceId.value}`,
      useIndexedDB: true,
    });
    await prepareCryptoState(client.value);
  }

  function getCryptoStatus(): CryptoStatus {
    return cryptoStatus.value;
  }

  async function setupRecovery(): Promise<void> {
    if (!cryptoApi || !generatedSecretStorageKey) {
      throw new Error('Matrix recovery setup is not available');
    }

    const keyToStore = generatedSecretStorageKey;
    const encodedRecoveryKey = keyToStore.encodedPrivateKey;
    if (!encodedRecoveryKey) {
      throw new Error('Matrix recovery key is not available');
    }
    isRecoveryActionLoading.value = true;
    recoveryError.value = null;

    try {
      await cryptoApi.bootstrapSecretStorage({
        createSecretStorageKey: async () => ({
          encodedPrivateKey: encodedRecoveryKey,
          keyInfo: keyToStore.keyInfo,
          privateKey: cloneSecretStorageKey(keyToStore.privateKey),
        }),
        setupNewKeyBackup: true,
      });
      await persistRecoveryKey(encodedRecoveryKey);
      cryptoStatus.value = 'ready';
      recoveryKey.value = null;
    } catch (error) {
      cryptoStatus.value = 'setup-required';
      recoveryError.value = 'setup-failed';
      throw error;
    } finally {
      if (cryptoStatus.value === 'ready') {
        keyToStore.privateKey.fill(0);
        generatedSecretStorageKey = null;
      }
      isRecoveryActionLoading.value = false;
    }
  }

  async function restoreFromRecoveryKey(encodedKey: string): Promise<void> {
    if (!cryptoApi || !client.value) {
      throw new Error('Matrix recovery is not available');
    }

    recoveryError.value = null;
    isRecoveryActionLoading.value = true;
    let privateKey: null | Uint8Array<ArrayBuffer> = null;
    try {
      try {
        privateKey = decodeRecoveryKey(encodedKey);
      } catch (error) {
        recoveryError.value = 'invalid-key';
        throw error;
      }

      const storedKey = await client.value.secretStorage.getKey();
      if (!storedKey) {
        recoveryError.value = 'not-configured';
        throw new Error('Matrix secret storage is not configured');
      }

      const [keyId, keyInfo] = storedKey;
      const isValid = await client.value.secretStorage.checkKey(
        privateKey,
        keyInfo,
      );
      if (!isValid) {
        recoveryError.value = 'invalid-key';
        throw new Error('The Matrix recovery key is invalid');
      }

      cachedSecretStorageKey = {
        key: cloneSecretStorageKey(privateKey),
        keyId,
      };
      const pendingRequests = pendingSecretStorageRequests.splice(0);
      for (const request of pendingRequests) {
        request.resolve([keyId, cloneSecretStorageKey(privateKey)]);
      }

      const backupInfo = await cryptoApi.getKeyBackupInfo();
      if (backupInfo) {
        await cryptoApi.loadSessionBackupPrivateKeyFromSecretStorage();
        await cryptoApi.checkKeyBackupAndEnable();
        await cryptoApi.restoreKeyBackup();
      } else {
        await cryptoApi.bootstrapSecretStorage({ setupNewKeyBackup: true });
        await cryptoApi.checkKeyBackupAndEnable();
      }
      await persistRecoveryKey(encodedKey);
      cryptoStatus.value = 'ready';
    } catch (error) {
      cryptoStatus.value = 'recovery-required';
      recoveryError.value ??= 'restore-failed';
      throw error;
    } finally {
      privateKey?.fill(0);
      isRecoveryActionLoading.value = false;
    }
  }

  async function ensureEncryptedRoom(roomId: string): Promise<Room> {
    if (!client.value || !isCryptoReady.value) {
      throw new Error('Matrix encryption is not ready');
    }

    const crypto = cryptoApi ?? client.value.getCrypto();
    if (!crypto) {
      throw new Error('Matrix Rust Crypto is not available');
    }
    cryptoApi = crypto;

    const room = client.value.getRoom(roomId);
    if (!room) {
      throw new Error(`Matrix room not found: ${roomId}`);
    }

    if (!(await crypto.isEncryptionEnabledInRoom(roomId))) {
      throw new Error('This Matrix room is not encrypted');
    }

    return room;
  }

  function hasEncryptedState(room: Room): boolean {
    const encryptionEvent = room.currentState.getStateEvents(
      EventType.RoomEncryption,
      '',
    );
    return (
      encryptionEvent?.getContent<{ algorithm?: string }>().algorithm ===
      ENCRYPTION_ALGORITHM
    );
  }

  const activeRoom = computed(() =>
    rooms.value.find((r) => r.id === activeRoomId.value),
  );

  const unreadCount = computed(() =>
    rooms.value.reduce((sum, r) => sum + r.unreadCount, 0),
  );

  const directRooms = computed(() => rooms.value.filter((r) => r.isDirect));
  const groupRooms = computed(() => rooms.value.filter((r) => !r.isDirect));

  const pinnedMessages = computed(() => {
    const messagesById = new Map(
      messages.value.map((message) => [message.id, message]),
    );
    return pinnedEventIds.value.flatMap((eventId) => {
      const message = messagesById.get(eventId);
      return message ? [message] : [];
    });
  });

  function isDirectRoom(room: Room): boolean {
    const summary = rooms.value.find((item) => item.id === room.roomId);
    if (summary) return summary.isDirect;
    const myId = currentUserId.value;
    return myId ? extractRoomSummary(room, myId).isDirect : false;
  }

  const canPinActiveRoomMessages = computed(() => {
    void roomSyncVersion.value;
    if (!activeRoomId.value || !currentUserId.value || !client.value) {
      return false;
    }

    const room = client.value.getRoom(activeRoomId.value);
    const currentMember = room?.getMember(currentUserId.value);
    if (
      !room ||
      !currentMember ||
      room.getMyMembership() !== 'join' ||
      currentMember.membership !== 'join'
    ) {
      return false;
    }

    if (isDirectRoom(room)) {
      return true;
    }

    return room.currentState.hasSufficientPowerLevelFor(
      'kick',
      currentMember.powerLevel,
    );
  });

  function extractRoomSummary(room: Room, myUserId: string): ChatRoomSummary {
    const timeline = room.getLiveTimeline().getEvents();
    const lastMsgEvent = [...timeline]
      .toReversed()
      .find(
        (e) =>
          e.getType() === EventType.RoomMessage ||
          (e.getWireType?.() ?? e.getType()) === EventType.RoomMessageEncrypted,
      );

    const content = lastMsgEvent?.getContent<{ body?: string }>();
    const isRedacted = lastMsgEvent?.isRedacted() ?? false;
    const rawBody =
      isRedacted || lastMsgEvent?.isDecryptionFailure?.()
        ? ''
        : (content?.body ?? '');
    const lastMessage = stripReplyFallback(rawBody);
    const createEvent =
      room.currentState.getStateEvents(EventType.RoomCreate, '') ??
      timeline.find((e) => e.getType() === 'm.room.create');
    const creationTimestamp = createEvent?.getTs() ?? timeline[0]?.getTs() ?? 0;

    const lastEventTimestamp = lastMsgEvent?.getTs() ?? creationTimestamp;

    const joinedMembers = room.getJoinedMembers();
    const allMembers = room.getMembers();
    const activeMembers = allMembers.filter(
      (m) => m.membership === 'join' || m.membership === 'invite',
    );
    const memberUserIds = (
      activeMembers.length > 0 ? activeMembers : allMembers
    ).map((m) => m.userId);
    const otherMember =
      activeMembers.find((m) => m.userId !== myUserId) ??
      allMembers.find((m) => m.userId !== myUserId);

    const canonicalAlias = room.getCanonicalAlias() ?? '';
    const altAliases = room.getAltAliases();
    const dmAlias = canonicalAlias.startsWith('#dm_')
      ? canonicalAlias
      : altAliases.find((alias) => alias.startsWith('#dm_'));
    const hasDmAlias = Boolean(dmAlias);

    const hasCustomRoomName = Boolean(
      room.currentState.getStateEvents(EventType.RoomName, ''),
    );

    const isDirect =
      hasDmAlias ||
      (!hasCustomRoomName &&
        (activeMembers.length <= 2 || joinedMembers.length <= 2));

    let directUserId: string | undefined;
    let name: string;
    let avatarUrl: string | undefined;

    if (isDirect) {
      if (otherMember) {
        directUserId = otherMember.userId;
        name = otherMember.name;
        avatarUrl =
          otherMember.getMxcAvatarUrl() ?? room.getMxcAvatarUrl() ?? undefined;
      } else if (hasDmAlias && dmAlias) {
        const match = /^#dm_([^_]+)_([^:]+):(.+)$/.exec(dmAlias);
        const p1 = match?.[1];
        const p2 = match?.[2];
        const host = match?.[3];
        if (p1 && p2 && host) {
          const myLocalpart = normalizeMatrixLocalpart(myUserId);
          const otherLocalpart = p1 === myLocalpart ? p2 : p1;
          directUserId = `@${otherLocalpart}:${host}`;
          name = otherLocalpart;
        } else {
          name = room.name;
        }
      } else {
        name = room.name;
      }
    } else {
      name = room.name;
      avatarUrl = room.getMxcAvatarUrl() ?? undefined;
    }

    const encryptionEvent = room.currentState.getStateEvents(
      EventType.RoomEncryption,
      '',
    );
    const encryptionAlgorithm = encryptionEvent?.getContent<{
      algorithm?: string;
    }>().algorithm;

    let encryptionStatus: RoomEncryptionStatus = 'unencrypted';
    if (encryptionEvent) {
      encryptionStatus =
        encryptionAlgorithm === ENCRYPTION_ALGORITHM ? 'encrypted' : 'unknown';
    }

    return {
      alias: dmAlias || canonicalAlias || undefined,
      avatarUrl,
      directUserId,
      id: room.roomId,
      encryptionStatus,
      isDirect,
      lastEventTimestamp,
      lastMessage,
      memberCount: Math.max(activeMembers.length, joinedMembers.length, 1),
      memberUserIds,
      name,
      unreadCount:
        room.getUnreadNotificationCount(NotificationCountType.Total) ?? 0,
    };
  }

  function isSystemAdminRoom(room: Room): boolean {
    const canonicalAlias = room.getCanonicalAlias() ?? '';
    if (
      canonicalAlias.startsWith('#admins:') ||
      room.getAltAliases().some((alias) => alias.startsWith('#admins:'))
    ) {
      return true;
    }
    if (room.name.endsWith(' Admin Room')) {
      return true;
    }
    return room
      .getMembers()
      .some((member) => member.userId.startsWith('@conduit:'));
  }

  function syncRooms(): void {
    if (!client.value || !currentUserId.value) return;

    const allRooms = client.value.getRooms();
    const myId = currentUserId.value;

    const syncedRooms = allRooms
      .filter((r) => {
        const m = r.getMyMembership();
        return (m === 'join' || m === 'invite') && !isSystemAdminRoom(r);
      })
      .map((r) => extractRoomSummary(r, myId));

    // Preserve any optimistic room summaries not yet received via /sync
    const syncedIds = new Set(syncedRooms.map((r) => r.id));
    const pendingRooms = rooms.value.filter((r) => !syncedIds.has(r.id));

    rooms.value = [...syncedRooms, ...pendingRooms].toSorted(
      (a, b) => b.lastEventTimestamp - a.lastEventTimestamp,
    );
    roomSyncVersion.value += 1;
  }

  function getPinnedEventIds(room: Room): string[] {
    const event = room.currentState.getStateEvents(
      EventType.RoomPinnedEvents,
      '',
    );
    const pinned = event?.getContent<RoomPinnedEventsContent>().pinned;
    return Array.isArray(pinned)
      ? pinned.filter(
          (eventId): eventId is string => typeof eventId === 'string',
        )
      : [];
  }

  function syncPinnedEventIds(room: Room): void {
    if (room.roomId !== activeRoomId.value) return;
    pinnedEventIds.value = getPinnedEventIds(room);
  }

  async function ensureDirectRoomPinPermission(
    roomId: string,
    room: Room,
  ): Promise<void> {
    if (!isDirectRoom(room) || !currentUserId.value || !client.value) return;

    const currentMember = room.getMember(currentUserId.value);
    if (
      !currentMember ||
      !room.currentState.hasSufficientPowerLevelFor(
        'kick',
        currentMember.powerLevel,
      )
    ) {
      return;
    }

    const powerLevelsEvent = room.currentState.getStateEvents(
      EventType.RoomPowerLevels,
      '',
    );
    const powerLevels =
      powerLevelsEvent?.getContent<IPowerLevelsContent>() ?? {};
    if (powerLevels.events?.[EventType.RoomPinnedEvents] === 0) return;

    await client.value.sendStateEvent(
      roomId,
      EventType.RoomPowerLevels,
      {
        ...powerLevels,
        events: {
          ...powerLevels.events,
          [EventType.RoomPinnedEvents]: 0,
        },
      },
      '',
    );
  }

  async function loadPinnedMessages(
    roomId: string,
    selectionVersion: number,
  ): Promise<void> {
    const pinnedIds = [...pinnedEventIds.value];
    for (const eventId of pinnedIds) {
      if (selectionVersion !== roomSelectionVersion) return;
      await ensureMessageLoaded(eventId);
      if (roomId !== activeRoomId.value) return;
    }
  }

  function extractMessageReactions(
    room: Room,
    eventId: string,
    myId: string,
  ): ChatMessageReaction[] {
    const latestReactionByUser = new Map<
      string,
      {
        avatarUrl?: string;
        displayName?: string;
        eventId?: string;
        key: string;
        order: number;
        ts: number;
        userId: string;
      }
    >();
    let eventOrder = 0;

    const recordUserReaction = (key: string, ev: MatrixEvent): void => {
      if (!key || ev.isRedacted?.()) return;
      const sender = ev.getSender?.() ?? '';
      if (!sender) return;
      eventOrder += 1;
      const ts = ev.getTs?.() ?? 0;
      const prev = latestReactionByUser.get(sender);
      if (prev && prev.ts > ts) return;

      const member = room.getMember(sender);
      const mxcUrl = member?.getMxcAvatarUrl?.();
      const avatarUrl =
        mxcUrl && client.value
          ? (client.value.mxcUrlToHttp(mxcUrl, 64, 64, 'crop') ?? undefined)
          : undefined;
      latestReactionByUser.set(sender, {
        avatarUrl,
        displayName: member?.name ?? sender,
        eventId: ev.getId?.(),
        key,
        order: eventOrder,
        ts,
        userId: sender,
      });
    };

    const relations = (room as any).relations?.getChildEventsForEvent?.(
      eventId,
      'm.annotation',
      'm.reaction',
    );
    if (relations?.getSortedAnnotationsByKey) {
      const sorted = relations.getSortedAnnotationsByKey();
      if (Array.isArray(sorted)) {
        for (const [key, eventSet] of sorted) {
          if (!key || !(eventSet instanceof Set)) continue;
          for (const ev of eventSet) {
            recordUserReaction(key, ev);
          }
        }
      }
    }

    const liveEvents = room.getLiveTimeline?.().getEvents?.() ?? [];
    for (const ev of liveEvents) {
      if (ev.isRedacted?.()) continue;
      const type = ev.getType?.();
      if (type === EventType.Reaction || type === 'm.reaction') {
        const rel = ev.getRelation?.() ?? ev.getContent?.()?.['m.relates_to'];
        if (
          rel?.rel_type === 'm.annotation' &&
          rel?.event_id === eventId &&
          rel?.key
        ) {
          recordUserReaction(rel.key as string, ev);
        }
      }
    }

    const reactionsMap = new Map<
      string,
      {
        hasReacted: boolean;
        myEventId?: string;
        users: Map<
          string,
          { avatarUrl?: string; displayName?: string; userId: string }
        >;
      }
    >();

    for (const userReaction of latestReactionByUser.values()) {
      let group = reactionsMap.get(userReaction.key);
      if (!group) {
        group = { hasReacted: false, users: new Map() };
        reactionsMap.set(userReaction.key, group);
      }
      group.users.set(userReaction.userId, {
        avatarUrl: userReaction.avatarUrl,
        displayName: userReaction.displayName,
        userId: userReaction.userId,
      });
      if (userReaction.userId === myId) {
        group.hasReacted = true;
        group.myEventId = userReaction.eventId;
      }
    }

    const results: ChatMessageReaction[] = [];
    for (const [key, group] of reactionsMap) {
      const userArray = [...group.users.values()];
      if (userArray.length > 0) {
        results.push({
          count: userArray.length,
          hasReacted: group.hasReacted,
          key,
          myEventId: group.myEventId,
          users: userArray,
        });
      }
    }
    return results;
  }

  function loadRoomMessages(roomId: string): void {
    if (!client.value || !currentUserId.value) return;

    const room = client.value.getRoom(roomId);
    if (!room) {
      return;
    }

    syncPinnedEventIds(room);

    const events = room.getLiveTimeline().getEvents();
    const myId = currentUserId.value;

    const summary = rooms.value.find((r) => r.id === roomId);
    const isDirect =
      summary?.isDirect ??
      Boolean(
        room.getCanonicalAlias?.()?.startsWith('#dm_') ||
        room.getAltAliases?.().some((a) => a.startsWith('#dm_')),
      );

    const remoteMessages: ChatMessageItem[] = events
      .filter((e) => {
        const type = e.getType();
        const wireType = e.getWireType?.() ?? type;
        if (
          type === EventType.RoomMessage ||
          wireType === EventType.RoomMessageEncrypted
        ) {
          return true;
        }

        if (!isDirect && type === EventType.RoomMember) {
          const content = e.getContent<Record<string, any>>();
          const prevContent = e.getPrevContent?.() as
            | Record<string, any>
            | undefined;
          const membership = content?.membership;
          const prevMembership = prevContent?.membership;

          if (membership === prevMembership) {
            return false;
          }
          if (membership === 'leave' && prevMembership === 'invite') {
            return false;
          }
          if (membership === 'join' && prevMembership === 'invite') {
            return false;
          }

          return (
            membership === 'join' ||
            membership === 'invite' ||
            membership === 'leave' ||
            membership === 'ban'
          );
        }

        return false;
      })
      .map((e) => {
        if (e.getType() === EventType.RoomMember) {
          const content = e.getContent<Record<string, any>>();
          const prevContent = e.getPrevContent?.() as
            | Record<string, any>
            | undefined;
          const membership = content?.membership;
          const prevMembership = prevContent?.membership;
          const actorId = e.getSender() ?? '';
          const targetId = e.getStateKey() ?? '';

          const actorMember = room.getMember(actorId);
          const targetMember = room.getMember(targetId);
          const actorName =
            actorMember?.name ??
            (actorId === targetId
              ? (content?.displayname ?? actorId)
              : actorId);
          const targetName =
            targetMember?.name ?? content?.displayname ?? targetId;

          let type: ChatSystemEventType = 'member_join';
          if (membership === 'invite') {
            type = 'member_add';
          } else if (membership === 'leave' || membership === 'ban') {
            type = actorId === targetId ? 'member_leave' : 'member_kick';
          } else if (membership === 'join') {
            const createEvent = room.currentState.getStateEvents(
              EventType.RoomCreate,
              '',
            );
            const creator = createEvent?.getSender();
            type =
              creator === targetId && !prevMembership
                ? 'member_create'
                : 'member_join';
          }

          const isActorMe = actorId === myId;
          const isTargetMe = targetId === myId;
          const actor = isActorMe ? 'Bạn' : actorName;
          const target = isTargetMe ? 'Bạn' : targetName;

          let body = '';
          switch (type) {
            case 'member_add': {
              if (isActorMe) {
                body = `Bạn đã thêm ${target} vào nhóm`;
              } else if (isTargetMe) {
                body = `${actor} đã thêm bạn vào nhóm`;
              } else {
                body = `${actor} đã thêm ${target} vào nhóm`;
              }
              break;
            }
            case 'member_create': {
              body = isActorMe ? 'Bạn đã tạo nhóm' : `${actor} đã tạo nhóm`;
              break;
            }
            case 'member_join': {
              body = isTargetMe
                ? 'Bạn đã tham gia nhóm'
                : `${target} đã tham gia nhóm`;
              break;
            }
            case 'member_kick': {
              if (isActorMe) {
                body = `Bạn đã xóa ${target} khỏi nhóm`;
              } else if (isTargetMe) {
                body = `${actor} đã xóa bạn khỏi nhóm`;
              } else {
                body = `${actor} đã xóa ${target} khỏi nhóm`;
              }
              break;
            }
            case 'member_leave': {
              body = isTargetMe ? 'Bạn đã rời nhóm' : `${target} đã rời nhóm`;
              break;
            }
          }

          return {
            attachments: [],
            body,
            decryptionStatus: 'plaintext' as const,
            id: e.getId() ?? `member_${e.getTs()}`,
            isMe: false,
            isRead: true,
            isRedacted: false,
            isSystem: true,
            senderId: actorId,
            senderName: actorName,
            status: 'sent' as const,
            systemEvent: {
              actorId,
              actorName,
              targetId,
              targetName,
              type,
            },
            timestamp: e.getTs(),
          };
        }

        const content = e.getContent<MatrixMessageContent>();
        const sender = e.getSender() ?? '';
        const member = room.getMember(sender);
        const isEncrypted =
          (e.getWireType?.() ?? e.getType()) === EventType.RoomMessageEncrypted;
        const isDecryptionFailure = e.isDecryptionFailure?.() ?? false;
        let status: 'error' | 'sending' | 'sent' = 'sent';
        if (e.status === 'not_sent') {
          status = 'error';
        } else if (e.status === 'sending' || e.status === 'queued') {
          status = 'sending';
        }

        const isRedacted = e.isRedacted();
        const rawBody =
          isRedacted || isDecryptionFailure ? '' : (content?.body ?? '');
        const inReplyToId =
          content?.['m.relates_to']?.['m.in_reply_to']?.event_id;
        const body = inReplyToId ? stripReplyFallback(rawBody) : rawBody;

        const attachments: ChatMessageAttachment[] = [];
        if (
          !isDecryptionFailure &&
          content?.file &&
          (content.msgtype === 'm.file' || content.msgtype === 'm.image')
        ) {
          attachments.push({
            encryptedFile: content.file,
            filename: content.filename ?? content.body ?? '',
            info: content.info ?? {},
            msgtype: content.msgtype,
          });
        }

        let replyTo:
          | undefined
          | { body: string; id: string; senderName: string };
        if (inReplyToId) {
          const refEvent = room.findEventById(inReplyToId);
          if (refEvent) {
            const refSender = refEvent.getSender() ?? '';
            const refMember = room.getMember(refSender);
            const refContent = refEvent.getContent<{ body?: string }>();
            const refRawBody = refEvent.isRedacted()
              ? ''
              : (refContent?.body ?? '');
            replyTo = {
              body: refEvent.isRedacted() ? '' : stripReplyFallback(refRawBody),
              id: inReplyToId,
              senderName: refMember?.name ?? refSender,
            };
          } else {
            const localFound = messages.value.find((m) => m.id === inReplyToId);
            replyTo = localFound
              ? {
                  body: localFound.body,
                  id: inReplyToId,
                  senderName: localFound.senderName,
                }
              : {
                  body: '',
                  id: inReplyToId,
                  senderName: '',
                };
          }
        }

        const eventId = e.getId() ?? `temp_${Math.random()}`;
        const readers: ChatMessageReader[] = [];
        if (sender === myId) {
          const joinedMembers = room.getJoinedMembers?.() ?? [];
          for (const m of joinedMembers) {
            if (
              m.userId !== myId &&
              room.hasUserReadEvent?.(m.userId, eventId)
            ) {
              const mxc = m.getMxcAvatarUrl?.();
              const rawAvatar =
                mxc && client.value
                  ? client.value.mxcUrlToHttp(mxc, 32, 32, 'crop')
                  : undefined;
              const avatarUrl = rawAvatar || undefined;
              readers.push({
                avatarUrl,
                displayName: m.name ?? m.userId,
                userId: m.userId,
              });
            }
          }
        }
        const isReadByOther = readers.length > 0;
        const isRead =
          isReadByOther ||
          (sender === myId &&
            room
              .getJoinedMembers()
              .some(
                (member) =>
                  member.userId !== myId &&
                  room.hasUserReadEvent(member.userId, eventId),
              ));
        const reactions = extractMessageReactions(room, eventId, myId);

        let decryptionStatus: ChatMessageItem['decryptionStatus'] = 'plaintext';
        if (isEncrypted) {
          if (isDecryptionFailure) {
            decryptionStatus = 'failed';
          } else if (
            (e.isBeingDecrypted?.() ?? false) ||
            typeof content?.msgtype !== 'string'
          ) {
            decryptionStatus = 'pending';
          } else {
            decryptionStatus = 'decrypted';
          }
        }

        return {
          attachments,
          body,
          decryptionStatus,
          id: eventId,
          isMe: sender === myId,
          isRead,
          isReadByOther,
          isRedacted,
          reactions,
          readers,
          replyTo,
          senderId: sender,
          senderName: member?.name ?? sender,
          status,
          timestamp: e.getTs(),
        };
      });

    messages.value = remoteMessages;
  }

  async function ensureMessageLoaded(eventId: string): Promise<boolean> {
    if (messages.value.some((message) => message.id === eventId)) return true;
    if (!client.value || !activeRoomId.value || isLoadingOlder.value) {
      return false;
    }

    const roomId = activeRoomId.value;
    const selectionVersion = roomSelectionVersion;
    const room = client.value.getRoom(roomId);
    if (!room) return false;

    isLoadingOlder.value = true;
    try {
      while (hasMoreHistory.value) {
        if (selectionVersion !== roomSelectionVersion) return false;
        const previousCount = room.getLiveTimeline().getEvents().length;
        await client.value.scrollback(room, 30);
        if (selectionVersion !== roomSelectionVersion) return false;

        loadRoomMessages(roomId);
        if (messages.value.some((message) => message.id === eventId)) {
          return true;
        }

        const nextCount = room.getLiveTimeline().getEvents().length;
        if (nextCount === previousCount) {
          hasMoreHistory.value = false;
          return false;
        }
      }

      return messages.value.some((message) => message.id === eventId);
    } catch (error) {
      console.error('Failed to load pinned message:', error);
      return false;
    } finally {
      if (selectionVersion === roomSelectionVersion) {
        isLoadingOlder.value = false;
      }
    }
  }

  async function updatePinnedMessages(
    roomId: string,
    eventId: string,
    shouldPin: boolean,
  ): Promise<void> {
    if (!client.value) throw new Error('Matrix client is not ready');

    const room = client.value.getRoom(roomId);
    if (!room) throw new Error(`Matrix room not found: ${roomId}`);

    const currentMember = currentUserId.value
      ? room.getMember(currentUserId.value)
      : null;
    if (
      !currentUserId.value ||
      !currentMember ||
      room.getMyMembership() !== 'join' ||
      currentMember.membership !== 'join' ||
      (!isDirectRoom(room) &&
        !room.currentState.hasSufficientPowerLevelFor(
          'kick',
          currentMember.powerLevel,
        ))
    ) {
      throw new Error('You do not have permission to update pinned messages');
    }

    await ensureDirectRoomPinPermission(roomId, room);

    const currentPinned = getPinnedEventIds(room);
    if (shouldPin && currentPinned.includes(eventId)) return;
    if (!shouldPin && !currentPinned.includes(eventId)) return;

    const nextPinned = shouldPin
      ? [...currentPinned, eventId]
      : currentPinned.filter((pinnedId) => pinnedId !== eventId);

    await client.value.sendStateEvent(
      roomId,
      EventType.RoomPinnedEvents,
      { pinned: nextPinned },
      '',
    );
    if (activeRoomId.value === roomId) {
      pinnedEventIds.value = nextPinned;
    }
  }

  async function pinMessage(roomId: string, eventId: string): Promise<void> {
    await updatePinnedMessages(roomId, eventId, true);
  }

  async function unpinMessage(roomId: string, eventId: string): Promise<void> {
    await updatePinnedMessages(roomId, eventId, false);
  }

  const lastSentReadReceiptByRoom = new Map<string, string>();

  async function markRoomAsRead(roomId = activeRoomId.value): Promise<void> {
    if (!client.value || !roomId) return;

    const room = client.value.getRoom(roomId);
    if (!room) return;

    room.setUnreadNotificationCount?.(NotificationCountType.Total, 0);
    room.setUnreadNotificationCount?.(NotificationCountType.Highlight, 0);

    const events = room.getLiveTimeline?.().getEvents?.() ?? [];
    const lastEvent =
      [...events].toReversed().find((event) => {
        const eventId = event.getId?.();
        return (
          Boolean(eventId) &&
          !event.status &&
          !(eventId && room.hasPendingEvent?.(eventId))
        );
      }) ?? events[events.length - 1];

    if (lastEvent) {
      const lastEventId = lastEvent.getId?.();
      if (
        !lastEventId ||
        lastSentReadReceiptByRoom.get(roomId) !== lastEventId
      ) {
        if (lastEventId) {
          lastSentReadReceiptByRoom.set(roomId, lastEventId);
        }
        try {
          await client.value.sendReadReceipt(lastEvent);
        } catch (error) {
          if (lastEventId) {
            lastSentReadReceiptByRoom.delete(roomId);
          }
          throw error;
        }
      }
    }

    syncRooms();
    if (roomId === activeRoomId.value) {
      loadRoomMessages(roomId);
    }
  }

  async function selectRoom(roomId: string): Promise<void> {
    const selectionVersion = ++roomSelectionVersion;
    const startedAt = Date.now();
    activeRoomId.value = roomId;
    activeTypingUsers.value = [];
    messages.value = [];
    pinnedEventIds.value = [];
    hasMoreHistory.value = true;
    isLoadingMessages.value = true;
    isLoadingOlder.value = false;

    try {
      if (client.value) {
        const room = client.value.getRoom(roomId);
        if (room && room.getMyMembership() === 'invite') {
          await client.value.joinRoom(roomId);
        }
        if (selectionVersion !== roomSelectionVersion) return;

        loadRoomMessages(roomId);
        updateActiveTypingUsers(roomId);

        // Preload more messages if initial live timeline has few events
        if (room && room.getLiveTimeline().getEvents().length < 30) {
          try {
            await client.value.scrollback(room, 30);
            if (selectionVersion !== roomSelectionVersion) return;
            loadRoomMessages(roomId);
          } catch {
            // Ignore if no older history
          }
        }
        if (selectionVersion !== roomSelectionVersion) return;

        await loadPinnedMessages(roomId, selectionVersion);
        if (selectionVersion !== roomSelectionVersion) return;

        await markRoomAsRead(roomId);
      } else {
        // Mock mode messages loading
        if (roomId === '!general:obee.local') {
          messages.value = [
            {
              body: 'Chào mừng toàn thể đội ngũ Ouransoft đến với nền tảng Obee!',
              decryptionStatus: 'decrypted',
              id: 'm-gen-1',
              isMe: false,
              isRead: true,
              senderId: mockUsers[4]!.id,
              senderName: mockUsers[4]!.name,
              status: 'sent',
              timestamp: Date.now() - 7200000,
            },
            {
              body: 'Chào mừng các bạn đến với hệ thống Obee v5.7.0!',
              decryptionStatus: 'decrypted',
              id: 'm-gen-2',
              isMe: true,
              isRead: true,
              senderId: currentUserId.value ?? 'admin',
              senderName: 'Nguyễn Văn An',
              status: 'sent',
              timestamp: Date.now() - 3600000,
            },
          ];
        } else if (roomId === '!tech:obee.local') {
          messages.value = [
            {
              body: 'Mọi người cập nhật code mới nhất từ master nhé, đã merge module Personal Tasks.',
              decryptionStatus: 'decrypted',
              id: 'm-tech-1',
              isMe: false,
              isRead: true,
              senderId: mockUsers[1]!.id,
              senderName: mockUsers[1]!.name,
              status: 'sent',
              timestamp: Date.now() - 3600000,
            },
            {
              body: 'Đã hoàn thành kiểm thử giao diện phân ca và chấm công.',
              decryptionStatus: 'decrypted',
              id: 'm-tech-2',
              isMe: false,
              isRead: true,
              senderId: mockUsers[3]!.id,
              senderName: mockUsers[3]!.name,
              status: 'sent',
              timestamp: Date.now() - 1800000,
            },
          ];
        } else if (roomId === '!direct-quocbao:obee.local') {
          messages.value = [
            {
              body: 'Chào anh An, bên Frontend đã hoàn tất tích hợp Year view và drag-drop cho lịch rồi anh.',
              decryptionStatus: 'decrypted',
              id: 'm-qb-1',
              isMe: false,
              isRead: true,
              senderId: mockUsers[1]!.id,
              senderName: mockUsers[1]!.name,
              status: 'sent',
              timestamp: Date.now() - 1200000,
            },
            {
              body: 'Bảo ơi, kiểm tra giúp anh cấu hình ca làm việc nhé!',
              decryptionStatus: 'decrypted',
              id: 'm-qb-2',
              isMe: true,
              isRead: true,
              senderId: currentUserId.value ?? 'admin',
              senderName: 'Nguyễn Văn An',
              status: 'sent',
              timestamp: Date.now() - 600000,
            },
          ];
        } else {
          messages.value = [
            {
              body: 'Chào anh, em gửi anh xem qua thông tin ạ.',
              decryptionStatus: 'decrypted',
              id: 'm-other-1',
              isMe: false,
              isRead: true,
              senderId: mockUsers[2]!.id,
              senderName: mockUsers[2]!.name,
              status: 'sent',
              timestamp: Date.now() - 1800000,
            },
            {
              body: 'Dạ anh, em vừa gửi đơn công tác tuần tới.',
              decryptionStatus: 'decrypted',
              id: 'm-other-2',
              isMe: false,
              isRead: true,
              senderId: mockUsers[2]!.id,
              senderName: mockUsers[2]!.name,
              status: 'sent',
              timestamp: Date.now() - 900000,
            },
          ];
        }
        isLoadingMessages.value = false;
        return;
      }
    } finally {
      if (selectionVersion === roomSelectionVersion) {
        const elapsed = Date.now() - startedAt;
        if (elapsed < 1000) {
          await new Promise((resolve) => setTimeout(resolve, 1000 - elapsed));
        }
        if (selectionVersion === roomSelectionVersion) {
          isLoadingMessages.value = false;
        }
      }
    }
  }

  async function loadOlderMessages(pageSize = 30): Promise<boolean> {
    if (!client.value || !activeRoomId.value || isLoadingOlder.value) {
      return false;
    }

    const room = client.value.getRoom(activeRoomId.value);
    if (!room) return false;

    isLoadingOlder.value = true;
    try {
      const prevCount = room.getLiveTimeline().getEvents().length;
      await client.value.scrollback(room, pageSize);
      const newCount = room.getLiveTimeline().getEvents().length;

      if (newCount === prevCount) {
        hasMoreHistory.value = false;
        return false;
      }

      loadRoomMessages(activeRoomId.value);
      return true;
    } catch (error) {
      console.error('Failed to scrollback older messages:', error);
      return false;
    } finally {
      isLoadingOlder.value = false;
    }
  }

  function clearActiveRoom(): void {
    roomSelectionVersion += 1;
    activeRoomId.value = null;
    messages.value = [];
    pinnedEventIds.value = [];
    isLoadingMessages.value = false;
    clearAttachmentUrlCache();
  }

  const groupActions = createChatGroupActions({
    activeRoomId,
    clearActiveRoom,
    client,
    currentUserId,
    rooms,
    roomSyncVersion,
    selectRoom,
    syncRooms,
  });

  async function sendMessage(
    body: string,
    replyToEventId?: string,
  ): Promise<void> {
    const text = body.trim();
    if (!text || !activeRoomId.value) return;

    if (!client.value) {
      const newMsg: ChatMessageItem = {
        body: text,
        decryptionStatus: 'decrypted',
        id: `mock-msg-${Date.now()}`,
        isMe: true,
        isRead: true,
        senderId: currentUserId.value ?? 'admin',
        senderName: 'Nguyễn Văn An',
        status: 'sent',
        timestamp: Date.now(),
      };
      messages.value.push(newMsg);
      const targetRoom = rooms.value.find((r) => r.id === activeRoomId.value);
      if (targetRoom) {
        targetRoom.lastMessage = text;
        targetRoom.lastEventTimestamp = Date.now();
      }
      return;
    }

    const roomId = activeRoomId.value;
    const room = client.value.getRoom(roomId);
    if (room && room.getMyMembership() === 'invite') {
      await client.value.joinRoom(roomId);
    }
    await ensureEncryptedRoom(roomId);

    let replyTarget:
      | undefined
      | { body: string; id: string; senderName: string };
    if (replyToEventId) {
      const target = messages.value.find((m) => m.id === replyToEventId);
      if (target) {
        replyTarget = {
          body: target.body,
          id: target.id,
          senderName: target.senderName,
        };
      }
    }

    if (replyToEventId) {
      const replyBody = replyTarget
        ? `> <${replyTarget.senderName}> ${replyTarget.body}\n\n${text}`
        : text;
      const content: RoomMessageEventContent = {
        body: replyBody,
        'm.relates_to': {
          'm.in_reply_to': {
            event_id: replyToEventId,
          },
        },
        msgtype: MsgType.Text,
      };
      await client.value.sendMessage(roomId, content);
    } else {
      await client.value.sendTextMessage(roomId, text);
    }

    loadRoomMessages(roomId);
    syncRooms();
  }

  const uploadProgress = ref<null | number>(null);

  async function sendAttachment(file: File): Promise<void> {
    if (!client.value || !activeRoomId.value) {
      throw new Error('Matrix client is not ready');
    }

    const roomId = activeRoomId.value;
    await ensureEncryptedRoom(roomId);

    uploadProgress.value = 0;
    try {
      const encrypted = await encryptAttachment(await file.arrayBuffer());
      const encryptedVersion = encrypted.info.v;
      const encryptedHash = encrypted.info.hashes?.sha256;
      if (!encryptedVersion || !encryptedHash) {
        throw new Error('Matrix attachment encryption metadata is incomplete');
      }

      const upload = await client.value.uploadContent(
        new Blob([encrypted.data], { type: 'application/octet-stream' }),
        {
          includeFilename: false,
          name: 'encrypted-attachment',
          progressHandler: ({ loaded, total }) => {
            uploadProgress.value = total > 0 ? (loaded / total) * 100 : null;
          },
          type: 'application/octet-stream',
        },
      );

      const isImage = file.type.startsWith('image/');
      const encryptedFile: EncryptedFile = {
        hashes: { sha256: encryptedHash },
        iv: encrypted.info.iv,
        key: encrypted.info.key,
        url: upload.content_uri,
        v: encryptedVersion,
      };
      const content: RoomMessageEventContent = isImage
        ? {
            body: file.name,
            file: encryptedFile,
            filename: file.name,
            info: {
              mimetype: file.type,
              size: file.size,
            },
            msgtype: MsgType.Image,
          }
        : {
            body: file.name,
            file: encryptedFile,
            filename: file.name,
            info: {
              mimetype: file.type,
              size: file.size,
            },
            msgtype: MsgType.File,
          };

      await client.value.sendMessage(roomId, content);
      loadRoomMessages(roomId);
      syncRooms();
    } finally {
      uploadProgress.value = null;
    }
  }

  async function sendFiles(files: File[]): Promise<void> {
    for (const file of files) {
      await sendAttachment(file);
    }
  }

  const attachmentUrlCache = new Map<string, string>();

  function clearAttachmentUrlCache(): void {
    for (const url of attachmentUrlCache.values()) {
      URL.revokeObjectURL(url);
    }
    attachmentUrlCache.clear();
  }

  async function getAttachmentUrl(
    messageId: string,
    attachmentIndex: number,
  ): Promise<string> {
    const cacheKey = `${messageId}-${attachmentIndex}`;
    const cached = attachmentUrlCache.get(cacheKey);
    if (cached) {
      return cached;
    }

    if (!client.value) {
      throw new Error('Matrix client is not ready');
    }

    const message = messages.value.find((item) => item.id === messageId);
    const attachment = message?.attachments?.[attachmentIndex];
    if (!attachment) {
      throw new Error('Matrix attachment is not available');
    }

    const downloadUrl = client.value.mxcUrlToHttp(
      attachment.encryptedFile.url,
      undefined,
      undefined,
      undefined,
      false,
      false,
      true,
    );
    if (!downloadUrl) {
      throw new Error('Matrix attachment URL is invalid');
    }

    const mediaUrl = new URL(downloadUrl);
    const ciphertext = await client.value.http.authedRequest<Blob>(
      Method.Get,
      `${mediaUrl.pathname}${mediaUrl.search}`,
      undefined,
      undefined,
      { prefix: '', rawResponseBody: true },
    );

    const decryptedData = await decryptAttachment(
      await ciphertext.arrayBuffer(),
      attachment.encryptedFile,
    );
    const mime =
      attachment.info.mimetype ||
      (attachment.msgtype === 'm.image'
        ? 'image/jpeg'
        : 'application/octet-stream');
    const objectUrl = URL.createObjectURL(
      new Blob([decryptedData], { type: mime }),
    );
    attachmentUrlCache.set(cacheKey, objectUrl);
    return objectUrl;
  }

  async function downloadAttachment(
    messageId: string,
    attachmentIndex: number,
  ): Promise<void> {
    const message = messages.value.find((item) => item.id === messageId);
    const attachment = message?.attachments?.[attachmentIndex];
    if (!attachment) {
      throw new Error('Matrix attachment is not available');
    }

    const objectUrl = await getAttachmentUrl(messageId, attachmentIndex);
    const anchor = document.createElement('a');
    anchor.href = objectUrl;
    anchor.download = attachment.filename;
    document.body.append(anchor);
    anchor.click();
    anchor.remove();
  }

  async function redactMessage(
    roomId: string,
    eventId: string,
    reason?: string,
  ): Promise<void> {
    if (!client.value) return;
    const msg = messages.value.find((m) => m.id === eventId);
    if (msg) {
      msg.isRedacted = true;
      msg.body = '';
    }
    await client.value.redactEvent(
      roomId,
      null,
      eventId,
      undefined,
      reason ? { reason } : undefined,
    );
    loadRoomMessages(roomId);
  }

  function updateActiveTypingUsers(roomId: string): void {
    if (
      !client.value ||
      !currentUserId.value ||
      roomId !== activeRoomId.value
    ) {
      activeTypingUsers.value = [];
      return;
    }
    const room = client.value.getRoom(roomId);
    if (!room) {
      activeTypingUsers.value = [];
      return;
    }
    const myId = currentUserId.value;
    const members =
      room.getMembersWithMembership?.('join') ??
      room.getJoinedMembers?.() ??
      [];
    const typingMembers = members.filter((m) => m.typing && m.userId !== myId);

    activeTypingUsers.value = typingMembers.map((m) => {
      const mxc = m.getMxcAvatarUrl?.();
      const rawAvatar =
        mxc && client.value
          ? client.value.mxcUrlToHttp(mxc, 32, 32, 'crop')
          : undefined;
      const avatarUrl = rawAvatar || undefined;
      return {
        avatarUrl,
        displayName: m.name ?? m.userId,
        userId: m.userId,
      };
    });
  }

  async function sendTyping(isTyping: boolean): Promise<void> {
    if (!client.value || !activeRoomId.value) return;
    try {
      await client.value.sendTyping(activeRoomId.value, isTyping, 3000);
    } catch {
      // Ignore transient typing notification error
    }
  }

  async function toggleReaction(eventId: string, key: string): Promise<void> {
    if (!client.value || !activeRoomId.value || !currentUserId.value) return;
    const roomId = activeRoomId.value;
    const room = client.value.getRoom(roomId);
    if (!room) return;

    const myId = currentUserId.value;
    const msg = messages.value.find((m) => m.id === eventId);
    let existingSameReaction = Boolean(
      msg?.reactions?.some((r) => r.key === key && r.hasReacted),
    );
    const myReactionEventIds = new Set<string>();

    if (msg?.reactions) {
      for (const reaction of msg.reactions) {
        if (reaction.hasReacted && reaction.myEventId) {
          myReactionEventIds.add(reaction.myEventId);
        }
      }
    }

    const relations = (room as any).relations?.getChildEventsForEvent?.(
      eventId,
      'm.annotation',
      'm.reaction',
    );
    if (relations?.getSortedAnnotationsByKey) {
      const sorted = relations.getSortedAnnotationsByKey();
      if (Array.isArray(sorted)) {
        for (const [rKey, eventSet] of sorted) {
          if (eventSet instanceof Set) {
            for (const ev of eventSet) {
              if (!ev.isRedacted?.() && ev.getSender?.() === myId) {
                const evId = ev.getId?.();
                if (evId) {
                  myReactionEventIds.add(evId);
                }
                if (!msg && rKey === key) {
                  existingSameReaction = true;
                }
              }
            }
          }
        }
      }
    }

    const liveEvents = room.getLiveTimeline?.().getEvents?.() ?? [];
    for (const ev of liveEvents) {
      if (ev.isRedacted?.()) continue;
      const type = ev.getType?.();
      if (
        (type === EventType.Reaction || type === 'm.reaction') &&
        ev.getSender?.() === myId
      ) {
        const rel = ev.getRelation?.() ?? ev.getContent?.()?.['m.relates_to'];
        if (rel?.event_id === eventId) {
          const evId = ev.getId?.();
          if (evId) {
            myReactionEventIds.add(evId);
          }
          if (!msg && rel?.key === key) {
            existingSameReaction = true;
          }
        }
      }
    }

    if (msg?.reactions) {
      for (const reaction of msg.reactions) {
        if (reaction.hasReacted) {
          reaction.hasReacted = false;
          reaction.myEventId = undefined;
          reaction.users = reaction.users.filter((u) => u.userId !== myId);
          reaction.count = reaction.users.length;
        }
      }
      msg.reactions = msg.reactions.filter((r) => r.count > 0);
    }

    try {
      for (const reactionEventId of myReactionEventIds) {
        await client.value.redactEvent(roomId, null, reactionEventId);
      }

      if (!existingSameReaction) {
        await client.value.sendEvent(roomId, EventType.Reaction, {
          'm.relates_to': {
            event_id: eventId,
            key,
            rel_type: RelationType.Annotation,
          },
        });
      }
    } catch (error) {
      console.error('Failed to toggle reaction:', error);
    } finally {
      loadRoomMessages(roomId);
    }
  }

  async function createDirectChat(targetUserId: string): Promise<string> {
    if (!client.value) throw new Error('Matrix client is not ready');

    const myId = currentUserId.value ?? client.value.getUserId() ?? '';
    const serverName = myId.split(':')[1] || 'obee.local';
    const { alias, roomAliasName } = getDirectChatAlias(
      myId,
      targetUserId,
      serverName,
    );

    // 1. Check in-memory rooms for this alias or direct user
    const existing = rooms.value.find((r) => {
      if (!r.isDirect || r.encryptionStatus !== 'encrypted') return false;
      if (r.alias && r.alias === alias) return true;
      if (r.directUserId?.toLowerCase() === targetUserId.toLowerCase()) {
        return true;
      }
      return (
        r.memberUserIds?.some(
          (id) => id.toLowerCase() === targetUserId.toLowerCase(),
        ) ?? false
      );
    });

    if (existing) {
      await selectRoom(existing.id);
      return existing.id;
    }

    // 2. Check client.getRooms() by canonical or alt aliases
    const existingRoomByAlias = client.value.getRooms().find((r) => {
      const canonical = r.getCanonicalAlias();
      const alts = r.getAltAliases();
      return (
        (canonical === alias || alts.includes(alias)) && hasEncryptedState(r)
      );
    });

    if (existingRoomByAlias) {
      if (existingRoomByAlias.getMyMembership() === 'invite') {
        await client.value.joinRoom(existingRoomByAlias.roomId);
      }
      await selectRoom(existingRoomByAlias.roomId);
      syncRooms();
      return existingRoomByAlias.roomId;
    }

    // 3. Query homeserver for alias
    let targetRoomId: null | string = null;
    try {
      const aliasRes = await client.value.getRoomIdForAlias(alias);
      if (aliasRes?.room_id) {
        targetRoomId = aliasRes.room_id;
      }
    } catch {
      // Alias does not exist on homeserver yet (expected 404 M_NOT_FOUND)
    }

    if (targetRoomId) {
      try {
        await client.value.joinRoom(targetRoomId);
      } catch {
        // already joined or join error
      }
      const joinedRoom = client.value.getRoom(targetRoomId);
      if (!joinedRoom || !hasEncryptedState(joinedRoom)) {
        throw new Error('The existing Matrix direct room is not encrypted');
      }
      await selectRoom(targetRoomId);
      syncRooms();
      return targetRoomId;
    }

    // 4. Create room with deterministic alias
    try {
      const result = await client.value.createRoom({
        initial_state: [
          {
            content: {
              history_visibility: 'shared',
            },
            state_key: '',
            type: 'm.room.history_visibility',
          },
          {
            content: {
              algorithm: ENCRYPTION_ALGORITHM,
            },
            state_key: '',
            type: EventType.RoomEncryption,
          },
        ],
        invite: [targetUserId],
        is_direct: true,
        power_level_content_override: {
          events: {
            [EventType.RoomPinnedEvents]: 0,
          },
        },
        preset: Preset.TrustedPrivateChat,
        room_alias_name: roomAliasName,
      });
      targetRoomId = result.room_id;
    } catch (createError: unknown) {
      if (
        createError instanceof MatrixError &&
        createError.errcode === 'M_ROOM_IN_USE'
      ) {
        const aliasRes = await client.value.getRoomIdForAlias(alias);
        targetRoomId = aliasRes.room_id;
        await client.value.joinRoom(targetRoomId);
        const joinedRoom = client.value.getRoom(targetRoomId);
        if (!joinedRoom || !hasEncryptedState(joinedRoom)) {
          throw new Error('The existing Matrix direct room is not encrypted', {
            cause: createError,
          });
        }
      } else {
        throw createError;
      }
    }

    const newSummary: ChatRoomSummary = {
      alias,
      directUserId: targetUserId,
      id: targetRoomId,
      encryptionStatus: 'encrypted',
      isDirect: true,
      lastEventTimestamp: Date.now(),
      lastMessage: '',
      memberCount: 2,
      memberUserIds: [myId, targetUserId],
      name: targetUserId,
      unreadCount: 0,
    };
    if (!rooms.value.some((r) => r.id === targetRoomId)) {
      rooms.value = [newSummary, ...rooms.value];
    }

    await selectRoom(targetRoomId);
    syncRooms();
    return targetRoomId;
  }

  function initMockChatState() {
    currentUserId.value = mockAuthUser.matrix_user_id ?? '@admin:obee.local';
    rooms.value = [
      {
        alias: '#general:obee.local',
        encryptionStatus: 'encrypted',
        id: '!general:obee.local',
        isDirect: false,
        lastEventTimestamp: Date.now() - 3600000,
        lastMessage: 'Chào mừng các bạn đến với hệ thống Obee v5.7.0!',
        memberCount: 8,
        memberUserIds: mockUsers.map((u) => u.matrix_user_id ?? u.id),
        name: 'Thông báo chung',
        unreadCount: 0,
      },
      {
        alias: '#tech:obee.local',
        encryptionStatus: 'encrypted',
        id: '!tech:obee.local',
        isDirect: false,
        lastEventTimestamp: Date.now() - 1800000,
        lastMessage: 'Đã hoàn thành kiểm thử giao diện phân ca và chấm công.',
        memberCount: 5,
        memberUserIds: [mockUsers[0]!.id, mockUsers[1]!.id, mockUsers[2]!.id, mockUsers[3]!.id],
        name: 'Khối Công nghệ & Sản phẩm',
        unreadCount: 2,
      },
      {
        directUserId: mockUsers[1]!.matrix_user_id ?? mockUsers[1]!.id,
        encryptionStatus: 'encrypted',
        id: '!direct-quocbao:obee.local',
        isDirect: true,
        lastEventTimestamp: Date.now() - 600000,
        lastMessage: 'Bảo ơi, kiểm tra giúp anh cấu hình ca làm việc nhé!',
        memberCount: 2,
        memberUserIds: [mockAuthUser.matrix_user_id ?? mockAuthUser.id, mockUsers[1]!.matrix_user_id ?? mockUsers[1]!.id],
        name: 'Trần Quốc Bảo',
        unreadCount: 1,
      },
      {
        directUserId: mockUsers[2]!.matrix_user_id ?? mockUsers[2]!.id,
        encryptionStatus: 'encrypted',
        id: '!direct-hoangyen:obee.local',
        isDirect: true,
        lastEventTimestamp: Date.now() - 900000,
        lastMessage: 'Dạ anh, em vừa gửi đơn công tác tuần tới.',
        memberCount: 2,
        memberUserIds: [mockAuthUser.matrix_user_id ?? mockAuthUser.id, mockUsers[2]!.matrix_user_id ?? mockUsers[2]!.id],
        name: 'Lê Hoàng Yến',
        unreadCount: 0,
      },
    ];

    if (rooms.value[0]) {
      void selectRoom(rooms.value[0].id);
    }
  }

  async function initializeClient(): Promise<void> {
    if (client.value && isReady.value) {
      return;
    }

    isInitializing.value = true;

    try {
      const obeeUserId = userStore.userInfo?.userId;
      if (!obeeUserId) {
        throw new Error('Authenticated Obee user is required for Matrix chat');
      }

      const storedSession = await loadMatrixSession(obeeUserId);
      const credentials = storedSession ?? (await getMatrixCredentialsApi());
      if (!storedSession) {
        await saveMatrixSession(obeeUserId, credentials);
      }
      currentUserId.value = credentials.matrix_user_id;
      matrixDeviceId.value = credentials.device_id;
      cryptoStatus.value = 'initializing';
      cryptoError.value = null;

      const baseUrl =
        typeof window === 'undefined'
          ? credentials.homeserver_url
          : window.location.origin;

      const rawClient = createClient({
        accessToken: credentials.access_token,
        baseUrl,
        disableVoip: true,
        deviceId: credentials.device_id,
        cryptoCallbacks,
        userId: credentials.matrix_user_id,
      });

      client.value = markRaw(rawClient);
      await initializeCrypto();

      let reauthenticationPromise: null | Promise<void> = null;
      rawClient.on(HttpApiEvent.SessionLoggedOut, () => {
        if (reauthenticationPromise) return;

        reauthenticationPromise = (async () => {
          const refreshedCredentials = await getMatrixCredentialsApi(
            credentials.device_id,
          );
          if (refreshedCredentials.device_id !== credentials.device_id) {
            throw new Error('Matrix returned a different device_id');
          }
          await saveMatrixSession(obeeUserId, refreshedCredentials);
          rawClient.setAccessToken(refreshedCredentials.access_token);
          await rawClient.startClient({ initialSyncLimit: 50 });
        })()
          .catch((error: unknown) => {
            const isDeviceMismatch =
              error instanceof Error && error.message.includes('device_id');
            cryptoStatus.value = 'error';
            cryptoError.value = isDeviceMismatch
              ? 'device-mismatch'
              : 'initialization-failed';
            if (isDeviceMismatch) {
              void forgetBrowserTrust();
            }
            isReady.value = false;
            isInitializing.value = false;
            rawClient.stopClient();
            console.error('Failed to re-authenticate Matrix client:', error);
          })
          .finally(() => {
            reauthenticationPromise = null;
          });
      });

      rawClient.on(ClientEvent.Sync, (state) => {
        if (state === 'PREPARED' || state === 'SYNCING') {
          isReady.value = true;
          isInitializing.value = false;

          for (const room of rawClient.getRooms()) {
            if (room.getMyMembership() === 'invite') {
              void rawClient.joinRoom(room.roomId).then(() => {
                syncRooms();
              });
            }
          }

          syncRooms();
          if (activeRoomId.value) {
            loadRoomMessages(activeRoomId.value);
          }
        }
      });

      rawClient.on(ClientEvent.Room, (room: Room) => {
        if (room.getMyMembership() === 'invite') {
          void rawClient.joinRoom(room.roomId).then(() => {
            syncRooms();
            if (room.roomId === activeRoomId.value) {
              loadRoomMessages(room.roomId);
            }
          });
        } else {
          syncRooms();
          if (room.roomId === activeRoomId.value) {
            loadRoomMessages(room.roomId);
          }
        }
      });

      rawClient.on(RoomEvent.Timeline, (_event: MatrixEvent, room?: Room) => {
        if (!room) return;
        syncRooms();
        if (room.roomId === activeRoomId.value) {
          loadRoomMessages(room.roomId);
        }
      });

      rawClient.on(RoomEvent.Receipt, (_event: MatrixEvent, room: Room) => {
        syncRooms();
        if (room.roomId === activeRoomId.value) {
          loadRoomMessages(room.roomId);
        }
      });

      rawClient.on(
        RoomMemberEvent.Typing,
        (event: MatrixEvent, member?: { roomId?: string }) => {
          const roomId = member?.roomId ?? event?.getRoomId?.();
          if (roomId && roomId === activeRoomId.value) {
            updateActiveTypingUsers(roomId);
          }
        },
      );

      rawClient.on(
        RoomEvent.LocalEchoUpdated,
        (_event: MatrixEvent, room: Room) => {
          if (room.roomId === activeRoomId.value) {
            loadRoomMessages(room.roomId);
          }
        },
      );

      rawClient.on(RoomEvent.Redaction, (_event: MatrixEvent, room: Room) => {
        if (room.roomId === activeRoomId.value) {
          loadRoomMessages(room.roomId);
        }
      });

      rawClient.on(MatrixEventEvent.Decrypted, (event: MatrixEvent) => {
        const roomId = event.getRoomId();
        if (!roomId) return;
        syncRooms();
        if (roomId === activeRoomId.value) {
          loadRoomMessages(roomId);
        }
      });

      rawClient.on(RoomStateEvent.Events, (event: MatrixEvent, state) => {
        const room = rawClient.getRoom(state.roomId);
        if (!room) return;

        if (event.getType() === EventType.RoomEncryption) {
          syncRooms();
          return;
        }
        if (event.getType() !== EventType.RoomPinnedEvents) return;
        syncRooms();
        syncPinnedEventIds(room);
      });

      await rawClient.startClient({ initialSyncLimit: 50 });
    } catch (error) {
      console.warn('Matrix client connection failed, activating interactive mock chat mode:', error);
      cryptoStatus.value = 'ready';
      cryptoError.value = null;
      isInitializing.value = false;
      isReady.value = true;
      initMockChatState();
    }
  }

  async function initialize(): Promise<void> {
    if (client.value && isReady.value) {
      return;
    }
    if (initializationPromise) {
      return initializationPromise;
    }

    initializationPromise = initializeClient();
    try {
      await initializationPromise;
    } finally {
      initializationPromise = null;
    }
  }

  async function forgetBrowserTrust(): Promise<void> {
    const scope = getRecoveryKeyScope();
    if (scope) {
      await clearMatrixRecoveryKey(scope);
    }
    browserTrustStatus.value = 'not-trusted';
  }

  function $reset(): void {
    const scope = getRecoveryKeyScope();
    if (scope) {
      void clearMatrixRecoveryKey(scope);
    }
    if (client.value) {
      client.value.stopClient();
      client.value.removeAllListeners();
      client.value = null;
    }
    isInitializing.value = false;
    isReady.value = false;
    cryptoStatus.value = 'idle';
    cryptoError.value = null;
    browserTrustStatus.value = 'not-trusted';
    recoveryKey.value = null;
    recoveryError.value = null;
    cryptoApi = null;
    cachedSecretStorageKey?.key.fill(0);
    cachedSecretStorageKey = null;
    if (generatedSecretStorageKey) {
      generatedSecretStorageKey.privateKey.fill(0);
      generatedSecretStorageKey = null;
    }
    rejectPendingSecretStorageRequests(new Error('Matrix chat was reset'));
    uploadProgress.value = null;
    activeRoomId.value = null;
    rooms.value = [];
    messages.value = [];
    pinnedEventIds.value = [];
    currentUserId.value = null;
    matrixDeviceId.value = null;
    isLoadingMessages.value = false;
    hasMoreHistory.value = true;
    isLoadingOlder.value = false;
    roomSelectionVersion += 1;
    lastSentReadReceiptByRoom.clear();
    clearAttachmentUrlCache();
  }

  return {
    $reset,
    activeRoom,
    activeRoomId,
    activeTypingUsers,
    ...groupActions,
    browserTrustStatus,
    canPinActiveRoomMessages,
    clearActiveRoom,
    client,
    createDirectChat,
    currentUserId,
    directRooms,
    forgetBrowserTrust,
    groupRooms,
    hasMoreHistory,
    initialize,
    initializeCrypto,
    isInitializing,
    isCryptoReady,
    isRecoveryActionLoading,
    isLoadingMessages,
    isLoadingOlder,
    isReady,
    matrixDeviceId,
    cryptoError,
    cryptoStatus,
    getCryptoStatus,
    getAttachmentUrl,
    downloadAttachment,
    loadOlderMessages,
    markRoomAsRead,
    messages,
    pinnedEventIds,
    pinnedMessages,
    pinMessage,
    recoveryError,
    recoveryKey,
    restoreFromRecoveryKey,
    setupRecovery,
    sendAttachment,
    sendFiles,
    sendTyping,
    toggleReaction,
    uploadProgress,
    unpinMessage,
    ensureMessageLoaded,
    redactMessage,
    rooms,
    roomSyncVersion,
    selectRoom,
    sendMessage,
    syncRooms,
    unreadCount,
  };
});

const hot = import.meta.hot;
if (hot) {
  hot.accept(acceptHMRUpdate(useChatStore, hot));
}

import type { MatrixClient } from 'matrix-js-sdk';

import type { ChatMessageAttachment } from './chat.types';

import { useUserStore } from '@vben/stores';

import { EventType, HttpApiEvent } from 'matrix-js-sdk';
import { encodeRecoveryKey } from 'matrix-js-sdk/lib/crypto-api/recovery-key';
import { createPinia, setActivePinia } from 'pinia';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { getDirectChatAlias, useChatStore } from './chat';

const createClientMock = vi.hoisted(() => vi.fn());
const decryptAttachmentMock = vi.hoisted(() => vi.fn());
const encryptAttachmentMock = vi.hoisted(() => vi.fn());
const getMatrixCredentialsMock = vi.hoisted(() => vi.fn());
const loadMatrixSessionMock = vi.hoisted(() => vi.fn());
const saveMatrixSessionMock = vi.hoisted(() => vi.fn());
const clearMatrixRecoveryKeyMock = vi.hoisted(() => vi.fn());
const loadMatrixRecoveryKeyMock = vi.hoisted(() => vi.fn());
const saveMatrixRecoveryKeyMock = vi.hoisted(() => vi.fn());

vi.mock('#/api/chat', () => ({
  getMatrixCredentialsApi: getMatrixCredentialsMock,
}));

vi.mock('matrix-encrypt-attachment', () => ({
  decryptAttachment: decryptAttachmentMock,
  encryptAttachment: encryptAttachmentMock,
}));

vi.mock('matrix-js-sdk', async () => {
  const actual =
    await vi.importActual<typeof import('matrix-js-sdk')>('matrix-js-sdk');
  return {
    ...actual,
    createClient: createClientMock,
  };
});

vi.mock('./matrix-session', () => ({
  loadMatrixSession: loadMatrixSessionMock,
  saveMatrixSession: saveMatrixSessionMock,
}));

vi.mock('./matrix-recovery-vault', () => ({
  clearMatrixRecoveryKey: clearMatrixRecoveryKeyMock,
  loadMatrixRecoveryKey: loadMatrixRecoveryKeyMock,
  saveMatrixRecoveryKey: saveMatrixRecoveryKeyMock,
}));

function createRawMatrixClient(crypto?: Record<string, unknown>): MatrixClient {
  const cryptoApi = crypto ?? {
    checkKeyBackupAndEnable: vi.fn().mockResolvedValue(undefined),
    getKeyBackupInfo: vi.fn().mockResolvedValue({}),
    getSecretStorageStatus: vi.fn().mockResolvedValue({
      defaultKeyId: 'recovery-key',
    }),
    loadSessionBackupPrivateKeyFromSecretStorage: vi
      .fn()
      .mockResolvedValue(undefined),
  };
  return {
    getCrypto: vi.fn().mockReturnValue(cryptoApi),
    getRooms: vi.fn().mockReturnValue([]),
    initRustCrypto: vi.fn().mockResolvedValue(undefined),
    on: vi.fn(),
    setAccessToken: vi.fn(),
    secretStorage: {
      checkKey: vi.fn().mockResolvedValue(true),
      getKey: vi.fn().mockResolvedValue(['recovery-key', {}]),
    },
    startClient: vi.fn().mockResolvedValue(undefined),
    stopClient: vi.fn(),
  } as unknown as MatrixClient;
}

function createEncryptedRoom(roomId: string) {
  return {
    currentState: {
      getStateEvents: vi.fn().mockReturnValue(null),
    },
    getAltAliases: vi.fn().mockReturnValue([]),
    getCanonicalAlias: vi.fn().mockReturnValue(undefined),
    getJoinedMembers: vi.fn().mockReturnValue([]),
    getLiveTimeline: vi.fn().mockReturnValue({
      getEvents: vi.fn().mockReturnValue([]),
    }),
    getMember: vi.fn().mockReturnValue(undefined),
    getMembers: vi.fn().mockReturnValue([]),
    getMxcAvatarUrl: vi.fn().mockReturnValue(undefined),
    getMyMembership: vi.fn().mockReturnValue('join'),
    getUnreadNotificationCount: vi.fn().mockReturnValue(0),
    name: 'Encrypted test room',
    roomId,
  };
}

function setEncryptedClient(
  store: ReturnType<typeof useChatStore>,
  roomId: string,
  overrides: Record<string, unknown> = {},
): void {
  const room = createEncryptedRoom(roomId);
  store.cryptoStatus = 'ready';
  store.client = {
    getCrypto: vi.fn().mockReturnValue({
      isEncryptionEnabledInRoom: vi.fn().mockResolvedValue(true),
    }),
    getRoom: vi.fn().mockReturnValue(room),
    getRooms: vi.fn().mockReturnValue([]),
    ...overrides,
  } as unknown as MatrixClient;
}

function setAuthenticatedUser(): void {
  useUserStore().setUserInfo({
    avatar: '',
    realName: 'Admin User',
    roles: ['admin'],
    userId: 'user-1',
    username: 'admin',
  });
}

describe('chat store encrypted client lifecycle', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
    createClientMock.mockReset();
    decryptAttachmentMock.mockReset();
    encryptAttachmentMock.mockReset();
    getMatrixCredentialsMock.mockReset();
    loadMatrixSessionMock.mockReset();
    saveMatrixSessionMock.mockReset();
    clearMatrixRecoveryKeyMock.mockReset();
    clearMatrixRecoveryKeyMock.mockResolvedValue(undefined);
    loadMatrixRecoveryKeyMock.mockReset();
    loadMatrixRecoveryKeyMock.mockResolvedValue(null);
    saveMatrixRecoveryKeyMock.mockReset();
    saveMatrixRecoveryKeyMock.mockResolvedValue(true);
  });

  it('reuses the stored device id and initializes Rust Crypto before sync', async () => {
    const rawClient = createRawMatrixClient();
    const credentials = {
      access_token: 'syt_token',
      device_id: 'BROWSER_DEVICE',
      homeserver_url: 'http://obee.local',
      matrix_user_id: '@admin:obee.local',
    };
    createClientMock.mockReturnValue(rawClient);
    getMatrixCredentialsMock.mockResolvedValue(credentials);
    loadMatrixSessionMock.mockResolvedValue({
      ...credentials,
      access_token: 'old_token',
    });
    saveMatrixSessionMock.mockResolvedValue(undefined);
    setAuthenticatedUser();

    const store = useChatStore();
    await store.initialize();

    expect(loadMatrixSessionMock).toHaveBeenCalledWith('user-1');
    expect(getMatrixCredentialsMock).not.toHaveBeenCalled();
    expect(saveMatrixSessionMock).not.toHaveBeenCalled();
    expect(createClientMock).toHaveBeenCalledWith({
      accessToken: 'old_token',
      baseUrl: window.location.origin,
      deviceId: 'BROWSER_DEVICE',
      disableVoip: true,
      cryptoCallbacks: expect.any(Object),
      userId: '@admin:obee.local',
    });
    expect(rawClient.initRustCrypto).toHaveBeenCalledWith({
      cryptoDatabasePrefix: 'obee-matrix-@admin:obee.local-BROWSER_DEVICE',
      useIndexedDB: true,
    });
    expect(rawClient.startClient).toHaveBeenCalledWith({
      initialSyncLimit: 50,
    });
    expect(store.isCryptoReady).toBe(true);
    expect(store.matrixDeviceId).toBe('BROWSER_DEVICE');
  });

  it('restores the cached browser recovery key before enabling key backup', async () => {
    const rawClient = createRawMatrixClient();
    const encodedRecoveryKey = encodeRecoveryKey(new Uint8Array(32).fill(7));
    const credentials = {
      access_token: 'syt_token',
      device_id: 'BROWSER_DEVICE',
      homeserver_url: 'http://obee.local',
      matrix_user_id: '@admin:obee.local',
    };
    createClientMock.mockReturnValue(rawClient);
    getMatrixCredentialsMock.mockResolvedValue(credentials);
    loadMatrixSessionMock.mockResolvedValue({
      ...credentials,
      access_token: 'old_token',
    });
    loadMatrixRecoveryKeyMock.mockResolvedValue(encodedRecoveryKey);
    setAuthenticatedUser();

    const store = useChatStore();
    await store.initialize();

    expect(loadMatrixRecoveryKeyMock).toHaveBeenCalledWith({
      deviceId: 'BROWSER_DEVICE',
      matrixUserId: '@admin:obee.local',
      obeeUserId: 'user-1',
    });
    expect(rawClient.secretStorage.checkKey).toHaveBeenCalledOnce();
    expect(store.browserTrustStatus).toBe('trusted');
    expect(store.isCryptoReady).toBe(true);
  });

  it('forgets the local browser trust for the current Matrix device', async () => {
    const rawClient = createRawMatrixClient();
    const credentials = {
      access_token: 'syt_token',
      device_id: 'BROWSER_DEVICE',
      homeserver_url: 'http://obee.local',
      matrix_user_id: '@admin:obee.local',
    };
    createClientMock.mockReturnValue(rawClient);
    getMatrixCredentialsMock.mockResolvedValue(credentials);
    loadMatrixSessionMock.mockResolvedValue(credentials);
    setAuthenticatedUser();

    const store = useChatStore();
    await store.initialize();
    await store.forgetBrowserTrust();

    expect(clearMatrixRecoveryKeyMock).toHaveBeenCalledWith({
      deviceId: 'BROWSER_DEVICE',
      matrixUserId: '@admin:obee.local',
      obeeUserId: 'user-1',
    });
    expect(store.browserTrustStatus).toBe('not-trusted');
  });

  it('creates and persists a Matrix session with the server device id when none exists', async () => {
    const rawClient = createRawMatrixClient();
    const credentials = {
      access_token: 'syt_token',
      device_id: 'NEW_BROWSER_DEVICE',
      homeserver_url: 'http://obee.local',
      matrix_user_id: '@admin:obee.local',
    };
    createClientMock.mockReturnValue(rawClient);
    getMatrixCredentialsMock.mockResolvedValue(credentials);
    loadMatrixSessionMock.mockResolvedValue(null);
    saveMatrixSessionMock.mockResolvedValue(undefined);
    setAuthenticatedUser();

    await useChatStore().initialize();

    expect(getMatrixCredentialsMock).toHaveBeenCalledOnce();
    expect(getMatrixCredentialsMock).toHaveBeenCalledWith();
    expect(saveMatrixSessionMock).toHaveBeenCalledWith('user-1', credentials);
  });

  it('stops the client when re-authentication returns a different device id', async () => {
    const rawClient = createRawMatrixClient();
    const credentials = {
      access_token: 'syt_token',
      device_id: 'BROWSER_DEVICE',
      homeserver_url: 'http://obee.local',
      matrix_user_id: '@admin:obee.local',
    };
    createClientMock.mockReturnValue(rawClient);
    getMatrixCredentialsMock.mockResolvedValue(credentials);
    loadMatrixSessionMock.mockResolvedValue(null);
    saveMatrixSessionMock.mockResolvedValue(undefined);
    setAuthenticatedUser();

    const store = useChatStore();
    await store.initialize();

    getMatrixCredentialsMock.mockResolvedValue({
      ...credentials,
      access_token: 'syt_new_token',
      device_id: 'UNEXPECTED_DEVICE',
    });
    const logoutHandler = (
      rawClient.on as ReturnType<typeof vi.fn>
    ).mock.calls.find(
      ([event]) => event === HttpApiEvent.SessionLoggedOut,
    )?.[1];

    expect(logoutHandler).toBeTypeOf('function');
    logoutHandler();

    await vi.waitFor(() => expect(store.cryptoError).toBe('device-mismatch'));
    expect(getMatrixCredentialsMock).toHaveBeenLastCalledWith('BROWSER_DEVICE');
    expect(rawClient.stopClient).toHaveBeenCalledOnce();
    expect(store.getCryptoStatus()).toBe('error');
  });

  it('requires recovery setup before marking Rust Crypto ready', async () => {
    const privateKey = new Uint8Array(32).fill(7);
    const bootstrapSecretStorageMock = vi.fn().mockResolvedValue(undefined);
    const rawClient = createRawMatrixClient({
      bootstrapSecretStorage: bootstrapSecretStorageMock,
      createRecoveryKeyFromPassphrase: vi.fn().mockResolvedValue({
        encodedPrivateKey: 'Es1234567890abcdef',
        keyInfo: { name: 'Obee recovery key' },
        privateKey,
      }),
      getKeyBackupInfo: vi.fn().mockResolvedValue(null),
      getSecretStorageStatus: vi.fn().mockResolvedValue({
        defaultKeyId: null,
      }),
    });
    const credentials = {
      access_token: 'syt_token',
      device_id: 'BROWSER_DEVICE',
      homeserver_url: 'http://obee.local',
      matrix_user_id: '@admin:obee.local',
    };
    createClientMock.mockReturnValue(rawClient);
    getMatrixCredentialsMock.mockResolvedValue(credentials);
    loadMatrixSessionMock.mockResolvedValue(null);
    saveMatrixSessionMock.mockResolvedValue(undefined);
    setAuthenticatedUser();

    const store = useChatStore();
    await store.initialize();

    expect(store.getCryptoStatus()).toBe('setup-required');
    expect(store.recoveryKey).toBe('Es1234567890abcdef');
    expect(store.isCryptoReady).toBe(false);
    const initCallOrder = (rawClient.initRustCrypto as ReturnType<typeof vi.fn>)
      .mock.invocationCallOrder[0];
    const startCallOrder = (rawClient.startClient as ReturnType<typeof vi.fn>)
      .mock.invocationCallOrder[0];
    expect(initCallOrder).toBeDefined();
    expect(startCallOrder).toBeDefined();
    expect(initCallOrder ?? Number.POSITIVE_INFINITY).toBeLessThan(
      startCallOrder ?? Number.NEGATIVE_INFINITY,
    );

    await store.setupRecovery();

    expect(bootstrapSecretStorageMock).toHaveBeenCalledWith({
      createSecretStorageKey: expect.any(Function),
      setupNewKeyBackup: true,
    });
    expect(saveMatrixRecoveryKeyMock).toHaveBeenCalledWith(
      {
        deviceId: 'BROWSER_DEVICE',
        matrixUserId: '@admin:obee.local',
        obeeUserId: 'user-1',
      },
      'Es1234567890abcdef',
    );
    expect(store.browserTrustStatus).toBe('trusted');
    expect(store.getCryptoStatus()).toBe('ready');
    expect(store.recoveryKey).toBeNull();
    expect(privateKey.every((value) => value === 0)).toBe(true);
  });

  it('does not accept an invalid recovery key as a restored crypto session', async () => {
    const rawClient = createRawMatrixClient();
    const credentials = {
      access_token: 'syt_token',
      device_id: 'BROWSER_DEVICE',
      homeserver_url: 'http://obee.local',
      matrix_user_id: '@admin:obee.local',
    };
    createClientMock.mockReturnValue(rawClient);
    getMatrixCredentialsMock.mockResolvedValue(credentials);
    loadMatrixSessionMock.mockResolvedValue(null);
    saveMatrixSessionMock.mockResolvedValue(undefined);
    setAuthenticatedUser();

    const store = useChatStore();
    await store.initialize();

    await expect(
      store.restoreFromRecoveryKey('not-a-matrix-recovery-key'),
    ).rejects.toThrow(/base58/i);
    expect(store.recoveryError).toBe('invalid-key');
    expect(store.getCryptoStatus()).toBe('recovery-required');
    expect(store.isRecoveryActionLoading).toBe(false);
  });
});

describe('chat store', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
    decryptAttachmentMock.mockReset();
    encryptAttachmentMock.mockReset();
  });

  it('initializes with empty state', () => {
    const store = useChatStore();

    expect(store.client).toBeNull();
    expect(store.isReady).toBe(false);
    expect(store.isCryptoReady).toBe(false);
    expect(store.matrixDeviceId).toBeNull();
    expect(store.isLoadingMessages).toBe(false);
    expect(store.isInitializing).toBe(false);
    expect(store.activeRoomId).toBeNull();
    expect(store.rooms).toEqual([]);
    expect(store.messages).toEqual([]);
    expect(store.pinnedEventIds).toEqual([]);
    expect(store.pinnedMessages).toEqual([]);
    expect(store.canPinActiveRoomMessages).toBe(false);
    expect(store.unreadCount).toBe(0);
    expect(store.directRooms).toEqual([]);
    expect(store.groupRooms).toEqual([]);
  });

  it('correctly calculates unread count and filters direct/group rooms', () => {
    const store = useChatStore();

    store.rooms = [
      {
        id: '!direct1:obee.local',
        encryptionStatus: 'encrypted',
        isDirect: true,
        lastEventTimestamp: 1000,
        lastMessage: 'Hello direct',
        memberCount: 2,
        name: 'Alice',
        unreadCount: 3,
      },
      {
        id: '!group1:obee.local',
        encryptionStatus: 'encrypted',
        isDirect: false,
        lastEventTimestamp: 2000,
        lastMessage: 'Hello group',
        memberCount: 5,
        name: 'General Channel',
        unreadCount: 2,
      },
    ];

    expect(store.unreadCount).toBe(5);
    expect(store.directRooms).toHaveLength(1);
    expect(store.directRooms[0]?.name).toBe('Alice');
    expect(store.groupRooms).toHaveLength(1);
    expect(store.groupRooms[0]?.name).toBe('General Channel');
  });

  it('resets state completely on $reset()', () => {
    const store = useChatStore();

    store.activeRoomId = '!room1:obee.local';
    store.currentUserId = '@admin:obee.local';
    store.isReady = true;
    store.pinnedEventIds = ['$pinned_event'];
    store.rooms = [
      {
        id: '!room1:obee.local',
        encryptionStatus: 'encrypted',
        isDirect: false,
        lastEventTimestamp: 1000,
        lastMessage: 'Test',
        memberCount: 3,
        name: 'Test Room',
        unreadCount: 1,
      },
    ];

    store.$reset();

    expect(store.activeRoomId).toBeNull();
    expect(store.currentUserId).toBeNull();
    expect(store.isReady).toBe(false);
    expect(store.isLoadingMessages).toBe(false);
    expect(store.rooms).toEqual([]);
    expect(store.messages).toEqual([]);
    expect(store.pinnedEventIds).toEqual([]);
    expect(store.unreadCount).toBe(0);
  });

  it('does not add an app-owned duplicate alongside the Matrix local echo', async () => {
    const store = useChatStore();
    store.activeRoomId = '!room1:obee.local';
    store.currentUserId = '@admin:obee.local';

    const sendTextMessageMock = vi
      .fn()
      .mockResolvedValue({ event_id: '$event_123' });

    setEncryptedClient(store, '!room1:obee.local', {
      sendTextMessage: sendTextMessageMock,
    });

    await store.sendMessage('Hello from test');

    expect(sendTextMessageMock).toHaveBeenCalledWith(
      '!room1:obee.local',
      'Hello from test',
    );
    expect(store.messages).toHaveLength(0);
  });

  it('blocks message sending until crypto is ready and the room is encrypted', async () => {
    const store = useChatStore();
    store.activeRoomId = '!room1:obee.local';
    store.currentUserId = '@admin:obee.local';
    const sendTextMessageMock = vi.fn();
    setEncryptedClient(store, '!room1:obee.local', {
      sendTextMessage: sendTextMessageMock,
    });
    store.cryptoStatus = 'initializing';

    await expect(store.sendMessage('Blocked message')).rejects.toThrow(
      'Matrix encryption is not ready',
    );
    expect(sendTextMessageMock).not.toHaveBeenCalled();

    store.cryptoStatus = 'ready';
    setEncryptedClient(store, '!room1:obee.local', {
      getCrypto: vi.fn().mockReturnValue({
        isEncryptionEnabledInRoom: vi.fn().mockResolvedValue(false),
      }),
      sendTextMessage: sendTextMessageMock,
    });

    await expect(store.sendMessage('Plaintext fallback')).rejects.toThrow(
      'This Matrix room is not encrypted',
    );
    expect(sendTextMessageMock).not.toHaveBeenCalled();
  });

  it('loads encrypted decryption failures as an explicit non-plaintext state', async () => {
    const store = useChatStore();
    const roomId = '!encrypted-room:obee.local';
    const encryptedEvent = {
      getContent: vi.fn().mockReturnValue({ ciphertext: 'ciphertext' }),
      getId: vi.fn().mockReturnValue('$encrypted_event'),
      getSender: vi.fn().mockReturnValue('@bob:obee.local'),
      getTs: vi.fn().mockReturnValue(1000),
      getType: vi.fn().mockReturnValue(EventType.RoomMessage),
      getWireType: vi.fn().mockReturnValue(EventType.RoomMessageEncrypted),
      isBeingDecrypted: vi.fn().mockReturnValue(false),
      isDecryptionFailure: vi.fn().mockReturnValue(true),
      isRedacted: vi.fn().mockReturnValue(false),
    };
    const room = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
      },
      findEventById: vi.fn(),
      getJoinedMembers: vi.fn().mockReturnValue([]),
      getLiveTimeline: vi.fn().mockReturnValue({
        getEvents: vi.fn().mockReturnValue([encryptedEvent]),
      }),
      getMember: vi.fn().mockReturnValue({ name: 'Bob' }),
      getMyMembership: vi.fn().mockReturnValue('join'),
      roomId,
    };
    store.activeRoomId = roomId;
    store.currentUserId = '@admin:obee.local';
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      getRooms: vi.fn().mockReturnValue([]),
      sendReadReceipt: vi.fn().mockResolvedValue(undefined),
      scrollback: vi.fn().mockResolvedValue(undefined),
    } as unknown as MatrixClient;

    await store.selectRoom(roomId);

    expect(store.messages).toEqual([
      expect.objectContaining({
        body: '',
        decryptionStatus: 'failed',
        id: '$encrypted_event',
      }),
    ]);
  });

  it('parses group member events as system notifications in group rooms', async () => {
    const store = useChatStore();
    const roomId = '!group-room:obee.local';
    const memberJoinEvent = {
      getContent: vi
        .fn()
        .mockReturnValue({ displayname: 'Bob', membership: 'join' }),
      getId: vi.fn().mockReturnValue('$member_join_event'),
      getPrevContent: vi.fn().mockReturnValue({ membership: 'leave' }),
      getSender: vi.fn().mockReturnValue('@bob:obee.local'),
      getStateKey: vi.fn().mockReturnValue('@bob:obee.local'),
      getTs: vi.fn().mockReturnValue(2000),
      getType: vi.fn().mockReturnValue(EventType.RoomMember),
      isBeingDecrypted: vi.fn().mockReturnValue(false),
      isDecryptionFailure: vi.fn().mockReturnValue(false),
      isRedacted: vi.fn().mockReturnValue(false),
    };
    const redundantInviteJoinEvent = {
      getContent: vi
        .fn()
        .mockReturnValue({ displayname: 'Charlie', membership: 'join' }),
      getId: vi.fn().mockReturnValue('$redundant_event'),
      getPrevContent: vi.fn().mockReturnValue({ membership: 'invite' }),
      getSender: vi.fn().mockReturnValue('@charlie:obee.local'),
      getStateKey: vi.fn().mockReturnValue('@charlie:obee.local'),
      getTs: vi.fn().mockReturnValue(2100),
      getType: vi.fn().mockReturnValue(EventType.RoomMember),
      isBeingDecrypted: vi.fn().mockReturnValue(false),
      isDecryptionFailure: vi.fn().mockReturnValue(false),
      isRedacted: vi.fn().mockReturnValue(false),
    };
    const room = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
      },
      findEventById: vi.fn(),
      getAltAliases: vi.fn().mockReturnValue([]),
      getCanonicalAlias: vi.fn().mockReturnValue(''),
      getJoinedMembers: vi.fn().mockReturnValue([]),
      getLiveTimeline: vi.fn().mockReturnValue({
        getEvents: vi
          .fn()
          .mockReturnValue([memberJoinEvent, redundantInviteJoinEvent]),
      }),
      getMember: vi.fn().mockReturnValue({ name: 'Bob' }),
      getMyMembership: vi.fn().mockReturnValue('join'),
      roomId,
    };
    store.rooms = [
      {
        id: roomId,
        encryptionStatus: 'encrypted',
        isDirect: false,
        lastEventTimestamp: 2000,
        lastMessage: '',
        memberCount: 3,
        name: 'Test Group',
        unreadCount: 0,
      },
    ];
    store.activeRoomId = roomId;
    store.currentUserId = '@admin:obee.local';
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      getRooms: vi.fn().mockReturnValue([]),
      scrollback: vi.fn().mockResolvedValue(undefined),
      sendReadReceipt: vi.fn().mockResolvedValue(undefined),
    } as any;

    await store.selectRoom(roomId);

    expect(store.messages).toEqual([
      expect.objectContaining({
        id: '$member_join_event',
        isSystem: true,
        systemEvent: expect.objectContaining({
          actorId: '@bob:obee.local',
          targetId: '@bob:obee.local',
          type: 'member_join',
        }),
      }),
    ]);
  });

  it('encrypts media before uploading ciphertext and sends standard Matrix metadata', async () => {
    const store = useChatStore();
    const file = new File(['plaintext'], 'notes.txt', { type: 'text/plain' });
    const ciphertext = new Uint8Array([1, 2, 3]).buffer;
    encryptAttachmentMock.mockResolvedValue({
      data: ciphertext,
      info: {
        hashes: { sha256: 'ciphertext-hash' },
        iv: 'ciphertext-iv',
        key: {
          alg: 'A256CTR',
          ext: true,
          k: 'ciphertext-key',
          key_ops: ['encrypt', 'decrypt'],
          kty: 'oct',
        },
        v: 'v2',
      },
    });
    const uploadContentMock = vi.fn().mockResolvedValue({
      content_uri: 'mxc://obee.local/ciphertext',
    });
    const sendMessageMock = vi.fn().mockResolvedValue({
      event_id: '$media_event',
    });
    store.activeRoomId = '!room1:obee.local';
    store.currentUserId = '@admin:obee.local';
    setEncryptedClient(store, '!room1:obee.local', {
      sendMessage: sendMessageMock,
      uploadContent: uploadContentMock,
    });

    await store.sendAttachment(file);

    expect(encryptAttachmentMock).toHaveBeenCalledWith(expect.any(ArrayBuffer));
    const [uploadedBlob, uploadOptions] = uploadContentMock.mock.calls[0] ?? [];
    expect(uploadedBlob).toBeInstanceOf(Blob);
    expect(new Uint8Array(await uploadedBlob.arrayBuffer())).toEqual(
      new Uint8Array(ciphertext),
    );
    expect(uploadOptions).toEqual(
      expect.objectContaining({ includeFilename: false }),
    );
    expect(sendMessageMock).toHaveBeenCalledWith(
      '!room1:obee.local',
      expect.objectContaining({
        body: 'notes.txt',
        file: {
          hashes: { sha256: 'ciphertext-hash' },
          iv: 'ciphertext-iv',
          key: expect.objectContaining({ k: 'ciphertext-key' }),
          url: 'mxc://obee.local/ciphertext',
          v: 'v2',
        },
        msgtype: 'm.file',
      }),
    );
  });

  it('downloads encrypted media through the authenticated Matrix HTTP layer', async () => {
    const store = useChatStore();
    const encryptedFile = {
      hashes: { sha256: 'ciphertext-hash' },
      iv: 'ciphertext-iv',
      key: {
        alg: 'A256CTR',
        ext: true,
        k: 'ciphertext-key',
        key_ops: ['encrypt', 'decrypt'],
        kty: 'oct',
      },
      url: 'mxc://obee.local/ciphertext',
      v: 'v2',
    } as ChatMessageAttachment['encryptedFile'];
    const attachment: ChatMessageAttachment = {
      encryptedFile,
      filename: 'notes.txt',
      info: { mimetype: 'text/plain', size: 9 },
      msgtype: 'm.file',
    };
    const authedRequestMock = vi
      .fn()
      .mockResolvedValue(new Blob([new Uint8Array([1, 2, 3])]));
    decryptAttachmentMock.mockResolvedValue(new Uint8Array([9, 8, 7]));
    store.messages = [
      {
        attachments: [attachment],
        body: 'notes.txt',
        decryptionStatus: 'decrypted',
        id: '$media_event',
        isMe: true,
        isRead: false,
        senderId: '@admin:obee.local',
        senderName: 'Admin',
        status: 'sent',
        timestamp: 1000,
      },
    ];
    setEncryptedClient(store, '!room1:obee.local', {
      http: { authedRequest: authedRequestMock },
      mxcUrlToHttp: vi
        .fn()
        .mockReturnValue(
          'http://obee.local/_matrix/client/v1/media/download/obee.local/ciphertext',
        ),
    });

    const originalCreateObjectURL = URL.createObjectURL;
    const originalRevokeObjectURL = URL.revokeObjectURL;
    const createObjectURLMock = vi.fn().mockReturnValue('blob:decrypted');
    const revokeObjectURLMock = vi.fn();
    Object.defineProperty(URL, 'createObjectURL', {
      configurable: true,
      value: createObjectURLMock,
    });
    Object.defineProperty(URL, 'revokeObjectURL', {
      configurable: true,
      value: revokeObjectURLMock,
    });

    try {
      await store.downloadAttachment('$media_event', 0);
      expect(createObjectURLMock).toHaveBeenCalledOnce();
      const cachedUrl = await store.getAttachmentUrl('$media_event', 0);
      expect(cachedUrl).toBe('blob:decrypted');
      expect(createObjectURLMock).toHaveBeenCalledOnce();

      store.clearActiveRoom();
      expect(revokeObjectURLMock).toHaveBeenCalledWith('blob:decrypted');
    } finally {
      Object.defineProperty(URL, 'createObjectURL', {
        configurable: true,
        value: originalCreateObjectURL,
      });
      Object.defineProperty(URL, 'revokeObjectURL', {
        configurable: true,
        value: originalRevokeObjectURL,
      });
    }

    expect(authedRequestMock).toHaveBeenCalledWith(
      'GET',
      '/_matrix/client/v1/media/download/obee.local/ciphertext',
      undefined,
      undefined,
      { prefix: '', rawResponseBody: true },
    );
    expect(decryptAttachmentMock).toHaveBeenCalledWith(
      expect.any(ArrayBuffer),
      encryptedFile,
    );
  });

  it('does not add an app-owned error item when the Matrix send fails', async () => {
    const store = useChatStore();
    store.activeRoomId = '!room1:obee.local';
    store.currentUserId = '@admin:obee.local';

    const sendTextMessageMock = vi
      .fn()
      .mockRejectedValue(new Error('Network error'));

    setEncryptedClient(store, '!room1:obee.local', {
      sendTextMessage: sendTextMessageMock,
    });

    await expect(store.sendMessage('Failing message')).rejects.toThrow(
      'Network error',
    );

    expect(store.messages).toHaveLength(0);
  });

  it('correctly strips Matrix reply fallback block', async () => {
    const { stripReplyFallback } = await import('./chat');

    expect(stripReplyFallback('Normal message')).toBe('Normal message');
    expect(
      stripReplyFallback('> <@alice:obee.local> Original text\n\nMy reply'),
    ).toBe('My reply');
    expect(
      stripReplyFallback(
        '> <@bob:obee.local> Multi\n> line quote\n\nSecond reply',
      ),
    ).toBe('Second reply');
  });

  it('sends reply message with m.relates_to structure', async () => {
    const store = useChatStore();
    store.activeRoomId = '!room1:obee.local';
    store.currentUserId = '@admin:obee.local';

    store.messages = [
      {
        body: 'Original message',
        decryptionStatus: 'decrypted',
        id: '$orig_1',
        isMe: false,
        isRead: false,
        senderId: '@bob:obee.local',
        senderName: 'Bob',
        status: 'sent',
        timestamp: 1000,
      },
    ];

    const sendMessageMock = vi
      .fn()
      .mockResolvedValue({ event_id: '$reply_event' });

    setEncryptedClient(store, '!room1:obee.local', {
      sendMessage: sendMessageMock,
    });

    await store.sendMessage('This is my reply', '$orig_1');

    expect(sendMessageMock).toHaveBeenCalledWith(
      '!room1:obee.local',
      expect.objectContaining({
        'm.relates_to': {
          'm.in_reply_to': {
            event_id: '$orig_1',
          },
        },
        msgtype: 'm.text',
      }),
    );
  });

  it('generates deterministic 1-1 room alias regardless of participant order', () => {
    const alias1 = getDirectChatAlias('@admin:obee.local', '@alice:obee.local');
    const alias2 = getDirectChatAlias('@alice:obee.local', '@admin:obee.local');

    expect(alias1.alias).toBe('#dm_admin_alice:obee.local');
    expect(alias1.roomAliasName).toBe('dm_admin_alice');
    expect(alias2.alias).toBe('#dm_admin_alice:obee.local');
    expect(alias2.roomAliasName).toBe('dm_admin_alice');
  });

  it('creates direct chat with deterministic room alias and shared history', async () => {
    const store = useChatStore();
    store.currentUserId = '@admin:obee.local';

    const createRoomMock = vi
      .fn()
      .mockResolvedValue({ room_id: '!new_dm_room:obee.local' });
    const getRoomIdForAliasMock = vi
      .fn()
      .mockRejectedValue({ errcode: 'M_NOT_FOUND' });

    store.client = {
      createRoom: createRoomMock,
      getRoom: vi.fn().mockReturnValue(null),
      getRoomIdForAlias: getRoomIdForAliasMock,
      getRooms: vi.fn().mockReturnValue([]),
      getUserId: vi.fn().mockReturnValue('@admin:obee.local'),
      joinRoom: vi.fn().mockResolvedValue({}),
    } as any;

    const roomId = await store.createDirectChat('@bob:obee.local');

    expect(roomId).toBe('!new_dm_room:obee.local');
    expect(getRoomIdForAliasMock).toHaveBeenCalledWith(
      '#dm_admin_bob:obee.local',
    );
    expect(createRoomMock).toHaveBeenCalledWith(
      expect.objectContaining({
        initial_state: [
          {
            content: { history_visibility: 'shared' },
            state_key: '',
            type: 'm.room.history_visibility',
          },
          {
            content: { algorithm: 'm.megolm.v1.aes-sha2' },
            state_key: '',
            type: EventType.RoomEncryption,
          },
        ],
        invite: ['@bob:obee.local'],
        is_direct: true,
        power_level_content_override: {
          events: {
            [EventType.RoomPinnedEvents]: 0,
          },
        },
        room_alias_name: 'dm_admin_bob',
      }),
    );
  });

  it('creates independent group chat with custom name and shared history', async () => {
    const store = useChatStore();
    store.currentUserId = '@admin:obee.local';

    const createRoomMock = vi
      .fn()
      .mockResolvedValue({ room_id: '!group_room_123:obee.local' });

    store.client = {
      createRoom: createRoomMock,
      getRoom: vi.fn().mockReturnValue(null),
      getRooms: vi.fn().mockReturnValue([]),
      getUserId: vi.fn().mockReturnValue('@admin:obee.local'),
      joinRoom: vi.fn().mockResolvedValue({}),
    } as any;

    const roomId = await store.createGroupChat('Project Obee', [
      '@alice:obee.local',
      '@bob:obee.local',
    ]);

    expect(roomId).toBe('!group_room_123:obee.local');
    expect(createRoomMock).toHaveBeenCalledWith(
      expect.objectContaining({
        initial_state: [
          {
            content: { history_visibility: 'shared' },
            state_key: '',
            type: 'm.room.history_visibility',
          },
          {
            content: { algorithm: 'm.megolm.v1.aes-sha2' },
            state_key: '',
            type: EventType.RoomEncryption,
          },
        ],
        invite: ['@alice:obee.local', '@bob:obee.local'],
        name: 'Project Obee',
      }),
    );
  });

  it('marks outgoing messages as read when another room member has read them', async () => {
    const store = useChatStore();
    const roomId = '!room1:obee.local';
    const messageEvent = {
      getContent: () => ({ body: 'Seen message' }),
      getId: () => '$seen_message',
      getSender: () => '@admin:obee.local',
      getTs: () => 1000,
      getType: () => 'm.room.message',
      isRedacted: () => false,
    };
    const hasUserReadEventMock = vi.fn().mockReturnValue(true);
    const room = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
      },
      findEventById: vi.fn(),
      getJoinedMembers: () => [
        { userId: '@admin:obee.local' },
        { userId: '@bob:obee.local' },
      ],
      getLiveTimeline: () => ({ getEvents: () => [messageEvent] }),
      getMember: vi.fn((userId: string) => ({ name: userId })),
      getMyMembership: () => 'join',
      hasUserReadEvent: hasUserReadEventMock,
      roomId,
    };

    store.currentUserId = '@admin:obee.local';
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      getRooms: vi.fn().mockReturnValue([]),
      scrollback: vi.fn().mockResolvedValue(undefined),
      sendReadReceipt: vi.fn().mockResolvedValue(undefined),
    } as any;

    await store.selectRoom(roomId);

    expect(store.messages[0]?.isRead).toBe(true);
    expect(hasUserReadEventMock).toHaveBeenCalledWith(
      '@bob:obee.local',
      '$seen_message',
    );
  });

  it('redacts message and marks it as isRedacted', async () => {
    const store = useChatStore();
    store.activeRoomId = '!room1:obee.local';

    store.messages = [
      {
        body: 'Message to be deleted',
        decryptionStatus: 'decrypted',
        id: '$msg_to_delete',
        isMe: true,
        isRead: false,
        senderId: '@admin:obee.local',
        senderName: 'Admin',
        status: 'sent',
        timestamp: 1000,
      },
    ];

    const redactEventMock = vi.fn().mockResolvedValue({});
    store.client = {
      getRoom: vi.fn().mockReturnValue(null),
      redactEvent: redactEventMock,
    } as any;

    await store.redactMessage('!room1:obee.local', '$msg_to_delete');
    expect(redactEventMock).toHaveBeenCalled();
    const redactedMsg = store.messages.find((m) => m.id === '$msg_to_delete');
    expect(redactedMsg?.isRedacted).toBe(true);
    expect(redactedMsg?.body).toBe('');
  });

  it('allows either joined member to pin and unpin messages in a direct room', async () => {
    const store = useChatStore();
    const roomId = '!direct1:obee.local';
    let pinned: string[] = [];
    const sendStateEventMock = vi
      .fn()
      .mockImplementation(
        (
          _roomId: string,
          eventType: string,
          content: { pinned?: string[] },
        ) => {
          if (eventType === EventType.RoomPinnedEvents) {
            pinned = content.pinned ?? [];
          }
          return Promise.resolve({});
        },
      );
    const room = {
      currentState: {
        getStateEvents: vi.fn((eventType: string) =>
          eventType === EventType.RoomPinnedEvents
            ? { getContent: () => ({ pinned }) }
            : null,
        ),
        hasSufficientPowerLevelFor: vi.fn().mockReturnValue(false),
      },
      getMember: vi.fn().mockReturnValue({
        membership: 'join',
        powerLevel: 0,
      }),
      getMyMembership: vi.fn().mockReturnValue('join'),
      roomId,
    };

    store.activeRoomId = roomId;
    store.currentUserId = '@member:obee.local';
    store.rooms = [
      {
        id: roomId,
        encryptionStatus: 'encrypted',
        isDirect: true,
        lastEventTimestamp: 0,
        lastMessage: '',
        memberCount: 2,
        name: 'Member',
        unreadCount: 0,
      },
    ];
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      sendStateEvent: sendStateEventMock,
    } as unknown as MatrixClient;

    expect(store.canPinActiveRoomMessages).toBe(true);

    await store.pinMessage(roomId, '$message');
    expect(sendStateEventMock).toHaveBeenCalledWith(
      roomId,
      EventType.RoomPinnedEvents,
      { pinned: ['$message'] },
      '',
    );
    expect(store.pinnedEventIds).toEqual(['$message']);

    await store.unpinMessage(roomId, '$message');
    expect(sendStateEventMock).toHaveBeenLastCalledWith(
      roomId,
      EventType.RoomPinnedEvents,
      { pinned: [] },
      '',
    );
    expect(store.pinnedEventIds).toEqual([]);
  });

  it('adds the pinned-events power-level override for an older direct room', async () => {
    const store = useChatStore();
    const roomId = '!direct1:obee.local';
    const sendStateEventMock = vi.fn().mockResolvedValue({});
    const room = {
      currentState: {
        getStateEvents: vi.fn((eventType: string) => {
          if (eventType === EventType.RoomPowerLevels) {
            return { getContent: () => ({ events_default: 50 }) };
          }
          return { getContent: () => ({ pinned: [] }) };
        }),
        hasSufficientPowerLevelFor: vi.fn().mockReturnValue(true),
      },
      getMember: vi.fn().mockReturnValue({
        membership: 'join',
        powerLevel: 100,
      }),
      getMyMembership: vi.fn().mockReturnValue('join'),
      roomId,
    };

    store.activeRoomId = roomId;
    store.currentUserId = '@admin:obee.local';
    store.rooms = [
      {
        id: roomId,
        encryptionStatus: 'encrypted',
        isDirect: true,
        lastEventTimestamp: 0,
        lastMessage: '',
        memberCount: 2,
        name: 'Member',
        unreadCount: 0,
      },
    ];
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      sendStateEvent: sendStateEventMock,
    } as unknown as MatrixClient;

    await store.pinMessage(roomId, '$message');

    expect(sendStateEventMock).toHaveBeenNthCalledWith(
      1,
      roomId,
      EventType.RoomPowerLevels,
      expect.objectContaining({
        events: {
          [EventType.RoomPinnedEvents]: 0,
        },
      }),
      '',
    );
    expect(sendStateEventMock).toHaveBeenNthCalledWith(
      2,
      roomId,
      EventType.RoomPinnedEvents,
      { pinned: ['$message'] },
      '',
    );
  });

  it('keeps the current pin state when updating the pinned-events state fails', async () => {
    const store = useChatStore();
    const roomId = '!direct1:obee.local';
    const room = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue({
          getContent: () => ({ pinned: ['$existing'] }),
        }),
        hasSufficientPowerLevelFor: vi.fn().mockReturnValue(false),
      },
      getMember: vi.fn().mockReturnValue({
        membership: 'join',
        powerLevel: 0,
      }),
      getMyMembership: vi.fn().mockReturnValue('join'),
      roomId,
    };

    store.activeRoomId = roomId;
    store.currentUserId = '@member:obee.local';
    store.pinnedEventIds = ['$existing'];
    store.rooms = [
      {
        id: roomId,
        encryptionStatus: 'encrypted',
        isDirect: true,
        lastEventTimestamp: 0,
        lastMessage: '',
        memberCount: 2,
        name: 'Member',
        unreadCount: 0,
      },
    ];
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      sendStateEvent: vi.fn().mockRejectedValue(new Error('Forbidden')),
    } as unknown as MatrixClient;

    await expect(store.pinMessage(roomId, '$new_message')).rejects.toThrow(
      'Forbidden',
    );
    expect(store.pinnedEventIds).toEqual(['$existing']);
  });

  it('rejects pinning for a regular member in a group room', async () => {
    const store = useChatStore();
    const roomId = '!group1:obee.local';
    const sendStateEventMock = vi.fn();
    const room = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
        hasSufficientPowerLevelFor: vi.fn().mockReturnValue(false),
      },
      getMember: vi.fn().mockReturnValue({
        membership: 'join',
        powerLevel: 0,
      }),
      getMyMembership: vi.fn().mockReturnValue('join'),
      roomId,
    };

    store.activeRoomId = roomId;
    store.currentUserId = '@member:obee.local';
    store.rooms = [
      {
        id: roomId,
        encryptionStatus: 'encrypted',
        isDirect: false,
        lastEventTimestamp: 0,
        lastMessage: '',
        memberCount: 3,
        name: 'Group',
        unreadCount: 0,
      },
    ];
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      sendStateEvent: sendStateEventMock,
    } as unknown as MatrixClient;

    expect(store.canPinActiveRoomMessages).toBe(false);
    await expect(store.pinMessage(roomId, '$message')).rejects.toThrow(
      'permission',
    );
    expect(sendStateEventMock).not.toHaveBeenCalled();
  });

  it('allows a group admin to pin messages', async () => {
    const store = useChatStore();
    const roomId = '!group1:obee.local';
    const sendStateEventMock = vi.fn().mockResolvedValue({});
    const room = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
        hasSufficientPowerLevelFor: vi.fn().mockReturnValue(true),
      },
      getMember: vi.fn().mockReturnValue({
        membership: 'join',
        powerLevel: 100,
      }),
      getMyMembership: vi.fn().mockReturnValue('join'),
      roomId,
    };

    store.activeRoomId = roomId;
    store.currentUserId = '@admin:obee.local';
    store.rooms = [
      {
        id: roomId,
        encryptionStatus: 'encrypted',
        isDirect: false,
        lastEventTimestamp: 0,
        lastMessage: '',
        memberCount: 3,
        name: 'Group',
        unreadCount: 0,
      },
    ];
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      sendStateEvent: sendStateEventMock,
    } as unknown as MatrixClient;

    expect(store.canPinActiveRoomMessages).toBe(true);
    await store.pinMessage(roomId, '$message');
    expect(sendStateEventMock).toHaveBeenCalledWith(
      roomId,
      EventType.RoomPinnedEvents,
      { pinned: ['$message'] },
      '',
    );
  });

  it('reads pinned event state in Matrix order and keeps unavailable pins', async () => {
    const store = useChatStore();
    const roomId = '!direct1:obee.local';
    const messageEvent = {
      getContent: () => ({ body: 'Pinned message' }),
      getId: () => '$pinned_message',
      getSender: () => '@member:obee.local',
      getTs: () => 1000,
      getType: () => 'm.room.message',
      isRedacted: () => false,
    };
    const room = {
      currentState: {
        getStateEvents: vi.fn((eventType: string) =>
          eventType === EventType.RoomPinnedEvents
            ? {
                getContent: () => ({ pinned: ['$pinned_message', '$missing'] }),
              }
            : null,
        ),
      },
      findEventById: vi.fn(),
      getJoinedMembers: vi
        .fn()
        .mockReturnValue([{ userId: '@member:obee.local' }]),
      getLiveTimeline: vi
        .fn()
        .mockReturnValue({ getEvents: () => [messageEvent] }),
      getMember: vi.fn().mockReturnValue({
        membership: 'join',
        name: 'Member',
      }),
      getMyMembership: vi.fn().mockReturnValue('join'),
      hasUserReadEvent: vi.fn().mockReturnValue(false),
      roomId,
    };

    store.currentUserId = '@member:obee.local';
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      getRooms: vi.fn().mockReturnValue([]),
      scrollback: vi.fn().mockResolvedValue(undefined),
      sendReadReceipt: vi.fn().mockResolvedValue(undefined),
    } as unknown as MatrixClient;

    await store.selectRoom(roomId);

    expect(store.pinnedEventIds).toEqual(['$pinned_message', '$missing']);
    expect(store.pinnedMessages.map((message) => message.id)).toEqual([
      '$pinned_message',
    ]);
  });

  it('scrolls back until a pinned message is loaded and stops at history end', async () => {
    const store = useChatStore();
    const roomId = '!direct1:obee.local';
    const currentEvent = {
      getContent: () => ({ body: 'Current message' }),
      getId: () => '$current_message',
      getSender: () => '@member:obee.local',
      getTs: () => 2000,
      getType: () => 'm.room.message',
      isRedacted: () => false,
    };
    const oldEvent = {
      getContent: () => ({ body: 'Old message' }),
      getId: () => '$old_message',
      getSender: () => '@member:obee.local',
      getTs: () => 1000,
      getType: () => 'm.room.message',
      isRedacted: () => false,
    };
    let events = [currentEvent];
    const scrollbackMock = vi.fn().mockImplementation(async () => {
      events = events.length === 1 ? [oldEvent, currentEvent] : events;
    });
    const room = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
      },
      findEventById: vi.fn(),
      getJoinedMembers: vi
        .fn()
        .mockReturnValue([{ userId: '@member:obee.local' }]),
      getLiveTimeline: () => ({ getEvents: () => events }),
      getMember: vi.fn().mockReturnValue({
        membership: 'join',
        name: 'Member',
      }),
      hasUserReadEvent: vi.fn().mockReturnValue(false),
      roomId,
    };

    store.activeRoomId = roomId;
    store.currentUserId = '@member:obee.local';
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      scrollback: scrollbackMock,
    } as unknown as MatrixClient;

    await expect(store.ensureMessageLoaded('$old_message')).resolves.toBe(true);
    expect(scrollbackMock).toHaveBeenCalledOnce();
    expect(store.messages[0]?.id).toBe('$old_message');

    await expect(store.ensureMessageLoaded('$missing_message')).resolves.toBe(
      false,
    );
    expect(scrollbackMock).toHaveBeenCalledTimes(2);
    expect(store.hasMoreHistory).toBe(false);
  });

  it('returns both joined and invited members consistently in getRoomMembers', () => {
    const store = useChatStore();
    const mockRoom = {
      currentState: {
        hasSufficientPowerLevelFor: vi
          .fn()
          .mockImplementation(
            (_action: string, powerLevel: number) => powerLevel > 0,
          ),
      },
      getMembers: vi.fn().mockReturnValue([
        {
          getMxcAvatarUrl: () => 'mxc://server/avatar1',
          membership: 'join',
          name: 'Admin',
          powerLevel: 100,
          userId: '@admin:obee.local',
        },
        {
          getMxcAvatarUrl: () => undefined,
          membership: 'join',
          name: 'Test Basic',
          powerLevel: 0,
          userId: '@test_basic:obee.local',
        },
        {
          getMxcAvatarUrl: () => undefined,
          membership: 'invite',
          name: 'Tester 1',
          powerLevel: 0,
          userId: '@tester1:obee.local',
        },
        {
          getMxcAvatarUrl: () => undefined,
          membership: 'leave',
          name: 'Old Member',
          powerLevel: 0,
          userId: '@old:obee.local',
        },
      ]),
    };

    store.client = {
      getRoom: vi.fn().mockReturnValue(mockRoom),
    } as any;

    const members = store.getRoomMembers('!room1:obee.local');
    expect(members).toHaveLength(3);
    expect(members.map((m) => m.userId)).toEqual([
      '@admin:obee.local',
      '@test_basic:obee.local',
      '@tester1:obee.local',
    ]);
    expect(
      members.find((m) => m.userId === '@tester1:obee.local')?.membership,
    ).toBe('invite');
    expect(members.find((m) => m.userId === '@admin:obee.local')?.isAdmin).toBe(
      true,
    );
    expect(
      members.find((m) => m.userId === '@test_basic:obee.local')?.isAdmin,
    ).toBe(false);
  });

  it('exposes member management permissions from the active room', () => {
    const store = useChatStore();
    store.activeRoomId = '!room1:obee.local';
    store.currentUserId = '@admin:obee.local';

    const members = [
      {
        membership: 'join',
        powerLevel: 100,
        userId: '@admin:obee.local',
      },
      {
        membership: 'join',
        powerLevel: 0,
        userId: '@member:obee.local',
      },
      {
        membership: 'join',
        powerLevel: 100,
        userId: '@other-admin:obee.local',
      },
    ];
    const mockRoom = {
      canInvite: vi.fn().mockReturnValue(true),
      currentState: {
        hasSufficientPowerLevelFor: vi.fn().mockReturnValue(true),
      },
      getMember: vi.fn((userId: string) =>
        members.find((member) => member.userId === userId),
      ),
      getMembers: vi.fn().mockReturnValue(members),
    };

    store.client = {
      getRoom: vi.fn().mockReturnValue(mockRoom),
    } as unknown as MatrixClient;

    expect(store.canInviteActiveRoomMembers).toBe(true);
    expect(store.activeRemovableMemberIds).toEqual(['@member:obee.local']);
  });

  it('invites a room member through Matrix and refreshes room state', async () => {
    const store = useChatStore();
    const inviteMock = vi.fn().mockResolvedValue({});
    const loadMembersMock = vi.fn().mockResolvedValue(true);
    const mockRoom = {
      canInvite: vi.fn().mockReturnValue(true),
      getMembers: vi.fn().mockReturnValue([]),
      loadMembersIfNeeded: loadMembersMock,
    };
    store.currentUserId = '@admin:obee.local';
    store.client = {
      getRoom: vi.fn().mockReturnValue(mockRoom),
      getRooms: vi.fn().mockReturnValue([]),
      invite: inviteMock,
    } as unknown as MatrixClient;

    await store.inviteRoomMember('!room1:obee.local', '@member:obee.local');

    expect(inviteMock).toHaveBeenCalledWith(
      '!room1:obee.local',
      '@member:obee.local',
    );
    expect(loadMembersMock).toHaveBeenCalledOnce();
  });

  it('removes a lower-power room member through Matrix and refreshes room state', async () => {
    const store = useChatStore();
    const kickMock = vi.fn().mockResolvedValue({});
    const loadMembersMock = vi.fn().mockResolvedValue(true);
    const members = [
      { powerLevel: 100, userId: '@admin:obee.local' },
      { powerLevel: 0, userId: '@member:obee.local' },
    ];
    const mockRoom = {
      currentState: {
        hasSufficientPowerLevelFor: vi.fn().mockReturnValue(true),
      },
      getMember: vi.fn((userId: string) =>
        members.find((member) => member.userId === userId),
      ),
      loadMembersIfNeeded: loadMembersMock,
    };
    store.currentUserId = '@admin:obee.local';
    store.client = {
      getRoom: vi.fn().mockReturnValue(mockRoom),
      getRooms: vi.fn().mockReturnValue([]),
      kick: kickMock,
    } as unknown as MatrixClient;

    await store.removeRoomMember('!room1:obee.local', '@member:obee.local');

    expect(kickMock).toHaveBeenCalledWith(
      '!room1:obee.local',
      '@member:obee.local',
    );
    expect(loadMembersMock).toHaveBeenCalledOnce();
  });

  it('leaves a group and removes it from the current account', async () => {
    const store = useChatStore();
    const roomId = '!group1:obee.local';
    const leaveMock = vi.fn().mockResolvedValue({});
    const forgetMock = vi.fn().mockResolvedValue({});
    store.activeRoomId = roomId;
    store.rooms = [
      {
        id: roomId,
        encryptionStatus: 'encrypted',
        isDirect: false,
        lastEventTimestamp: 1000,
        lastMessage: 'Group message',
        memberCount: 2,
        name: 'Project Obee',
        unreadCount: 0,
      },
    ];
    store.client = {
      forget: forgetMock,
      getRoom: vi.fn().mockReturnValue(null),
      leave: leaveMock,
    } as any;

    await store.leaveGroup(roomId);

    expect(leaveMock).toHaveBeenCalledWith(roomId);
    expect(forgetMock).toHaveBeenCalledWith(roomId);
    expect(store.rooms).toEqual([]);
    expect(store.activeRoomId).toBeNull();
  });

  it('allows room admins to remove a group from their account', async () => {
    const store = useChatStore();
    const roomId = '!group1:obee.local';
    const leaveMock = vi.fn().mockResolvedValue({});
    const forgetMock = vi.fn().mockResolvedValue({});
    const room = {
      currentState: {
        hasSufficientPowerLevelFor: vi.fn().mockReturnValue(true),
      },
      getMember: vi.fn().mockReturnValue({ powerLevel: 50 }),
      isSpaceRoom: vi.fn().mockReturnValue(false),
    };
    store.currentUserId = '@admin:obee.local';
    store.client = {
      forget: forgetMock,
      getRoom: vi.fn().mockReturnValue(room),
      leave: leaveMock,
    } as any;

    await store.deleteGroup(roomId);

    expect(leaveMock).toHaveBeenCalledWith(roomId);
    expect(forgetMock).toHaveBeenCalledWith(roomId);
  });

  it('exposes group deletion only to room admins', () => {
    const store = useChatStore();
    const currentMember = { powerLevel: 50 };
    const room = {
      currentState: {
        hasSufficientPowerLevelFor: vi
          .fn()
          .mockImplementation(
            (_action: string, powerLevel: number) => powerLevel > 0,
          ),
      },
      getMember: vi.fn().mockReturnValue(currentMember),
      isSpaceRoom: vi.fn().mockReturnValue(false),
    };
    store.activeRoomId = '!group1:obee.local';
    store.currentUserId = '@admin:obee.local';
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
    } as any;

    expect(store.canDeleteActiveGroup).toBe(true);

    currentMember.powerLevel = 0;
    store.roomSyncVersion += 1;
    expect(store.canDeleteActiveGroup).toBe(false);
  });

  it('marks room timestamp as last message timestamp, or falls back to room creation timestamp when no messages', () => {
    const store = useChatStore();
    store.currentUserId = '@admin:obee.local';

    const mockRoomWithMessages = {
      currentState: {
        getStateEvents: vi.fn((type: string) => {
          if (type === 'm.room.create') {
            return { getTs: () => 1_000_000 };
          }
          return null;
        }),
      },
      getAltAliases: () => [],
      getCanonicalAlias: () => undefined,
      getJoinedMembers: () => [{ userId: '@admin:obee.local' }],
      getLiveTimeline: () => ({
        getEvents: () => [
          {
            getContent: () => ({ body: 'Hello world' }),
            getSender: () => '@admin:obee.local',
            getTs: () => 2_500_000,
            getType: () => 'm.room.message',
            isRedacted: () => false,
          },
        ],
      }),
      getMembers: () => [{ membership: 'join', userId: '@admin:obee.local' }],
      getMxcAvatarUrl: () => undefined,
      getMyMembership: () => 'join',
      getUnreadNotificationCount: () => 0,
      name: 'Room With Messages',
      roomId: '!room_with_msg:obee.local',
    };

    const mockRoomWithoutMessages = {
      currentState: {
        getStateEvents: vi.fn((type: string) => {
          if (type === 'm.room.create') {
            return { getTs: () => 1_500_000 };
          }
          return null;
        }),
      },
      getAltAliases: () => [],
      getCanonicalAlias: () => undefined,
      getJoinedMembers: () => [{ userId: '@admin:obee.local' }],
      getLiveTimeline: () => ({
        getEvents: () => [
          {
            getTs: () => 1_500_000,
            getType: () => 'm.room.create',
          },
        ],
      }),
      getMembers: () => [{ membership: 'join', userId: '@admin:obee.local' }],
      getMxcAvatarUrl: () => undefined,
      getMyMembership: () => 'join',
      getUnreadNotificationCount: () => 0,
      name: 'Empty Room',
      roomId: '!room_empty:obee.local',
    };

    store.client = {
      getRooms: vi
        .fn()
        .mockReturnValue([mockRoomWithMessages, mockRoomWithoutMessages]),
    } as any;

    store.syncRooms();

    const roomWithMsg = store.rooms.find(
      (r) => r.id === '!room_with_msg:obee.local',
    );
    const emptyRoom = store.rooms.find(
      (r) => r.id === '!room_empty:obee.local',
    );

    expect(roomWithMsg?.lastEventTimestamp).toBe(2_500_000);
    expect(emptyRoom?.lastEventTimestamp).toBe(1_500_000);
  });

  it('excludes the Matrix homeserver Admin Room from synced rooms', () => {
    const store = useChatStore();
    store.currentUserId = '@admin:obee.local';

    const adminRoom = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
      },
      getAltAliases: () => [],
      getCanonicalAlias: () => '#admins:obee.local',
      getJoinedMembers: () => [
        { userId: '@admin:obee.local' },
        { userId: '@conduit:obee.local' },
      ],
      getLiveTimeline: () => ({ getEvents: () => [] }),
      getMembers: () => [
        { membership: 'join', userId: '@admin:obee.local' },
        { membership: 'join', userId: '@conduit:obee.local' },
      ],
      getMxcAvatarUrl: () => undefined,
      getMyMembership: () => 'join',
      getUnreadNotificationCount: () => 1,
      name: 'obee.local Admin Room',
      roomId: '!admin_room:obee.local',
    };

    const normalRoom = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
      },
      getAltAliases: () => [],
      getCanonicalAlias: () => undefined,
      getJoinedMembers: () => [{ userId: '@admin:obee.local' }],
      getLiveTimeline: () => ({ getEvents: () => [] }),
      getMembers: () => [{ membership: 'join', userId: '@admin:obee.local' }],
      getMxcAvatarUrl: () => undefined,
      getMyMembership: () => 'join',
      getUnreadNotificationCount: () => 0,
      name: 'General',
      roomId: '!general:obee.local',
    };

    store.client = {
      getRooms: vi.fn().mockReturnValue([adminRoom, normalRoom]),
    } as unknown as MatrixClient;

    store.syncRooms();

    expect(store.rooms.map((r) => r.id)).toEqual(['!general:obee.local']);
  });

  it('marks room as read when markRoomAsRead is called and avoids duplicate read receipts for the same event', async () => {
    const store = useChatStore();
    const roomId = '!room1:obee.local';
    const lastEvent = {
      getContent: () => ({ body: 'Incoming message' }),
      getId: () => '$incoming_1',
      getSender: () => '@bob:obee.local',
      getTs: () => 2000,
      getType: () => 'm.room.message',
      isRedacted: () => false,
    };
    const setUnreadNotificationCountMock = vi.fn();
    const sendReadReceiptMock = vi.fn().mockResolvedValue(undefined);
    const room = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
      },
      findEventById: vi.fn(),
      getAltAliases: () => [],
      getCanonicalAlias: () => undefined,
      getJoinedMembers: () => [
        { userId: '@admin:obee.local' },
        { userId: '@bob:obee.local' },
      ],
      getLiveTimeline: () => ({ getEvents: () => [lastEvent] }),
      getMember: vi.fn((userId: string) => ({
        getMxcAvatarUrl: () => undefined,
        name: userId,
      })),
      getMembers: () => [
        {
          getMxcAvatarUrl: () => undefined,
          membership: 'join',
          name: 'Admin',
          userId: '@admin:obee.local',
        },
        {
          getMxcAvatarUrl: () => undefined,
          membership: 'join',
          name: 'Bob',
          userId: '@bob:obee.local',
        },
      ],
      getMxcAvatarUrl: () => undefined,
      getMyMembership: () => 'join',
      getUnreadNotificationCount: () => 0,
      hasPendingEvent: () => false,
      hasUserReadEvent: () => false,
      name: 'Bob',
      roomId,
      setUnreadNotificationCount: setUnreadNotificationCountMock,
    };

    store.currentUserId = '@admin:obee.local';
    store.activeRoomId = roomId;
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      getRooms: vi.fn().mockReturnValue([room]),
      sendReadReceipt: sendReadReceiptMock,
    } as unknown as MatrixClient;

    await store.markRoomAsRead();
    await store.markRoomAsRead();

    expect(setUnreadNotificationCountMock).toHaveBeenCalled();
    expect(sendReadReceiptMock).toHaveBeenCalledTimes(1);
    expect(sendReadReceiptMock).toHaveBeenCalledWith(lastEvent);
  });

  it('keeps only the latest reaction per user per message and replaces previous reaction when toggling a new emoji', async () => {
    const store = useChatStore();
    const roomId = '!room1:obee.local';
    const messageEvent = {
      getContent: () => ({ body: 'React to me' }),
      getId: () => '$msg_1',
      getSender: () => '@bob:obee.local',
      getTs: () => 1000,
      getType: () => 'm.room.message',
      isRedacted: () => false,
    };
    const oldReactionByAdmin = {
      getContent: () => ({
        'm.relates_to': {
          event_id: '$msg_1',
          key: '👍',
          rel_type: 'm.annotation',
        },
      }),
      getId: () => '$react_old',
      getRelation: () => ({
        event_id: '$msg_1',
        key: '👍',
        rel_type: 'm.annotation',
      }),
      getSender: () => '@admin:obee.local',
      getTs: () => 1100,
      getType: () => 'm.reaction',
      isRedacted: () => false,
    };
    const newerReactionByAdmin = {
      getContent: () => ({
        'm.relates_to': {
          event_id: '$msg_1',
          key: '❤️',
          rel_type: 'm.annotation',
        },
      }),
      getId: () => '$react_new',
      getRelation: () => ({
        event_id: '$msg_1',
        key: '❤️',
        rel_type: 'm.annotation',
      }),
      getSender: () => '@admin:obee.local',
      getTs: () => 1200,
      getType: () => 'm.reaction',
      isRedacted: () => false,
    };
    const reactionByBob = {
      getContent: () => ({
        'm.relates_to': {
          event_id: '$msg_1',
          key: '😂',
          rel_type: 'm.annotation',
        },
      }),
      getId: () => '$react_bob',
      getRelation: () => ({
        event_id: '$msg_1',
        key: '😂',
        rel_type: 'm.annotation',
      }),
      getSender: () => '@bob:obee.local',
      getTs: () => 1300,
      getType: () => 'm.reaction',
      isRedacted: () => false,
    };

    const redactEventMock = vi.fn().mockResolvedValue({});
    const sendEventMock = vi.fn().mockResolvedValue({});
    const room = {
      currentState: {
        getStateEvents: vi.fn().mockReturnValue(null),
      },
      findEventById: vi.fn(),
      getJoinedMembers: () => [
        { userId: '@admin:obee.local' },
        { userId: '@bob:obee.local' },
      ],
      getLiveTimeline: () => ({
        getEvents: () => [
          messageEvent,
          oldReactionByAdmin,
          newerReactionByAdmin,
          reactionByBob,
        ],
      }),
      getMember: vi.fn((userId: string) => ({ name: userId })),
      getMyMembership: () => 'join',
      hasUserReadEvent: () => false,
      roomId,
    };

    store.currentUserId = '@admin:obee.local';
    store.client = {
      getRoom: vi.fn().mockReturnValue(room),
      getRooms: vi.fn().mockReturnValue([]),
      redactEvent: redactEventMock,
      scrollback: vi.fn().mockResolvedValue(undefined),
      sendEvent: sendEventMock,
      sendReadReceipt: vi.fn().mockResolvedValue(undefined),
    } as unknown as MatrixClient;

    await store.selectRoom(roomId);

    // Admin has both 👍 (ts 1100) and ❤️ (ts 1200) in timeline, only ❤️ should be kept for Admin
    expect(store.messages[0]?.reactions).toEqual([
      expect.objectContaining({
        count: 1,
        hasReacted: true,
        key: '❤️',
        myEventId: '$react_new',
      }),
      expect.objectContaining({
        count: 1,
        hasReacted: false,
        key: '😂',
      }),
    ]);

    // When Admin selects 😮, previous reaction events by Admin ($react_old, $react_new) are redacted and 😮 is sent
    await store.toggleReaction('$msg_1', '😮');

    expect(redactEventMock).toHaveBeenCalledWith(roomId, null, '$react_new');
    expect(redactEventMock).toHaveBeenCalledWith(roomId, null, '$react_old');
    expect(sendEventMock).toHaveBeenCalledWith(
      roomId,
      EventType.Reaction,
      expect.objectContaining({
        'm.relates_to': {
          event_id: '$msg_1',
          key: '😮',
          rel_type: 'm.annotation',
        },
      }),
    );
  });
});

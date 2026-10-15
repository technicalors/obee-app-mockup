import type { MatrixClient } from 'matrix-js-sdk';

import type { Ref, ShallowRef } from 'vue';

import type { ChatRoomMemberInfo, ChatRoomSummary } from './chat.types';

import { computed } from 'vue';

import { Preset } from 'matrix-js-sdk';

interface ChatGroupActionsContext {
  activeRoomId: Ref<null | string>;
  clearActiveRoom: () => void;
  client: ShallowRef<MatrixClient | null>;
  currentUserId: Ref<null | string>;
  rooms: Ref<ChatRoomSummary[]>;
  roomSyncVersion: Ref<number>;
  selectRoom: (roomId: string) => Promise<void>;
  syncRooms: () => void;
}

export function createChatGroupActions(context: ChatGroupActionsContext) {
  function getRoomMembers(roomId: string): ChatRoomMemberInfo[] {
    void context.roomSyncVersion.value;
    if (!context.client.value) return [];
    const room = context.client.value.getRoom(roomId);
    if (!room) return [];

    const activeMembers = room
      .getMembers()
      .filter(
        (member) =>
          member.membership === 'join' || member.membership === 'invite',
      );
    return activeMembers.map((member) => ({
      avatarUrl: member.getMxcAvatarUrl() ?? undefined,
      displayName: member.name,
      isAdmin: room.currentState.hasSufficientPowerLevelFor(
        'kick',
        member.powerLevel,
      ),
      membership: member.membership,
      powerLevel: member.powerLevel,
      userId: member.userId,
    }));
  }

  const activeRoomMembers = computed<ChatRoomMemberInfo[]>(() => {
    void context.roomSyncVersion.value;
    if (!context.activeRoomId.value) return [];
    return getRoomMembers(context.activeRoomId.value);
  });

  const canInviteActiveRoomMembers = computed(() => {
    void context.roomSyncVersion.value;
    if (
      !context.activeRoomId.value ||
      !context.currentUserId.value ||
      !context.client.value
    ) {
      return false;
    }

    const room = context.client.value.getRoom(context.activeRoomId.value);
    return room?.canInvite(context.currentUserId.value) ?? false;
  });

  const canDeleteActiveGroup = computed(() => {
    void context.roomSyncVersion.value;
    if (
      !context.activeRoomId.value ||
      !context.currentUserId.value ||
      !context.client.value
    ) {
      return false;
    }

    const room = context.client.value.getRoom(context.activeRoomId.value);
    const currentMember = room?.getMember(context.currentUserId.value);
    return Boolean(
      room &&
      currentMember &&
      !room.isSpaceRoom() &&
      room.currentState.hasSufficientPowerLevelFor(
        'kick',
        currentMember.powerLevel,
      ),
    );
  });

  const activeRemovableMemberIds = computed<string[]>(() => {
    void context.roomSyncVersion.value;
    if (
      !context.activeRoomId.value ||
      !context.currentUserId.value ||
      !context.client.value
    ) {
      return [];
    }

    const room = context.client.value.getRoom(context.activeRoomId.value);
    const currentMember = room?.getMember(context.currentUserId.value);
    if (!room || !currentMember) return [];
    if (
      !room.currentState.hasSufficientPowerLevelFor(
        'kick',
        currentMember.powerLevel,
      )
    ) {
      return [];
    }

    return room
      .getMembers()
      .filter(
        (member) =>
          (member.membership === 'join' || member.membership === 'invite') &&
          member.userId !== context.currentUserId.value &&
          member.powerLevel < currentMember.powerLevel,
      )
      .map((member) => member.userId);
  });

  async function inviteRoomMember(
    roomId: string,
    userId: string,
  ): Promise<void> {
    if (!context.client.value) throw new Error('Matrix client is not ready');

    const room = context.client.value.getRoom(roomId);
    if (!room) throw new Error(`Matrix room not found: ${roomId}`);

    const myUserId = context.currentUserId.value;
    if (!myUserId || !room.canInvite(myUserId)) {
      throw new Error('You do not have permission to invite members');
    }

    await context.client.value.invite(roomId, userId);
    await room.loadMembersIfNeeded();
    context.roomSyncVersion.value += 1;
    context.syncRooms();
  }

  async function removeRoomMember(
    roomId: string,
    userId: string,
  ): Promise<void> {
    if (!context.client.value) throw new Error('Matrix client is not ready');

    const room = context.client.value.getRoom(roomId);
    if (!room) throw new Error(`Matrix room not found: ${roomId}`);

    const myUserId = context.currentUserId.value;
    const currentMember = myUserId ? room.getMember(myUserId) : null;
    const targetMember = room.getMember(userId);
    if (!myUserId || !currentMember || !targetMember) {
      throw new Error('Room member information is unavailable');
    }
    if (
      !room.currentState.hasSufficientPowerLevelFor(
        'kick',
        currentMember.powerLevel,
      ) ||
      targetMember.userId === myUserId ||
      targetMember.powerLevel >= currentMember.powerLevel
    ) {
      throw new Error('You do not have permission to remove this member');
    }

    await context.client.value.kick(roomId, userId);
    await room.loadMembersIfNeeded();
    context.roomSyncVersion.value += 1;
    context.syncRooms();
  }

  async function removeRoomFromAccount(roomId: string): Promise<void> {
    if (!context.client.value) throw new Error('Matrix client is not ready');

    await context.client.value.leave(roomId);
    await context.client.value.forget(roomId);
    context.rooms.value = context.rooms.value.filter(
      (room) => room.id !== roomId,
    );
    if (context.activeRoomId.value === roomId) {
      context.clearActiveRoom();
    }
  }

  async function leaveGroup(roomId: string): Promise<void> {
    await removeRoomFromAccount(roomId);
  }

  async function deleteGroup(roomId: string): Promise<void> {
    if (!context.client.value) throw new Error('Matrix client is not ready');

    const room = context.client.value.getRoom(roomId);
    const myId = context.currentUserId.value;
    const currentMember = myId ? room?.getMember(myId) : null;
    if (
      !room ||
      !myId ||
      room.isSpaceRoom() ||
      !currentMember ||
      !room.currentState.hasSufficientPowerLevelFor(
        'kick',
        currentMember.powerLevel,
      )
    ) {
      throw new Error('You do not have permission to delete this group');
    }

    await removeRoomFromAccount(roomId);
  }

  async function createGroupChat(
    name: string,
    inviteUserIds: string[],
  ): Promise<string> {
    if (!context.client.value) throw new Error('Matrix client is not ready');

    const result = await context.client.value.createRoom({
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
            algorithm: 'm.megolm.v1.aes-sha2',
          },
          state_key: '',
          type: 'm.room.encryption',
        },
      ],
      invite: inviteUserIds,
      name,
      preset: Preset.PrivateChat,
    });

    const myId =
      context.currentUserId.value ?? context.client.value.getUserId() ?? '';
    const uniqueMembers = [...new Set([myId, ...inviteUserIds])];
    const newSummary: ChatRoomSummary = {
      id: result.room_id,
      encryptionStatus: 'encrypted',
      isDirect: false,
      lastEventTimestamp: Date.now(),
      lastMessage: '',
      memberCount: uniqueMembers.length,
      memberUserIds: uniqueMembers,
      name,
      unreadCount: 0,
    };
    if (!context.rooms.value.some((room) => room.id === result.room_id)) {
      context.rooms.value = [newSummary, ...context.rooms.value];
    }

    await context.selectRoom(result.room_id);
    context.syncRooms();
    return result.room_id;
  }

  return {
    activeRemovableMemberIds,
    activeRoomMembers,
    canDeleteActiveGroup,
    canInviteActiveRoomMembers,
    createGroupChat,
    deleteGroup,
    getRoomMembers,
    inviteRoomMember,
    leaveGroup,
    removeRoomMember,
  };
}

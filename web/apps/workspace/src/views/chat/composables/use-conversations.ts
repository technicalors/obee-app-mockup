import type { Ref } from 'vue';

import type { ConversationItem, GroupMemberAvatarInfo } from '../types';

import type { User } from '#/api';
import type { ChatRoomSummary } from '#/store';

import { computed, ref } from 'vue';

import { getDirectChatAlias, useChatStore } from '#/store';
import { getUserAvatarSource } from '#/views/users/avatar';

export function findColleagueByMatrixId(
  matrixUserId: string,
  colleaguesList: User[],
): undefined | User {
  if (!matrixUserId) return undefined;
  const normalized = matrixUserId.trim().toLowerCase();
  const localpart =
    normalized.replace(/^@/, '').split(':')[0]?.trim().toLowerCase() ?? '';

  return colleaguesList.find((c) => {
    if (c.matrix_user_id && c.matrix_user_id.toLowerCase() === normalized) {
      return true;
    }
    const cUsername = c.username?.trim().toLowerCase();
    if (cUsername && (cUsername === localpart || cUsername === normalized)) {
      return true;
    }
    return false;
  });
}

export function useConversations(
  selectableColleagues: Ref<User[]>,
  rooms: Ref<ChatRoomSummary[]>,
  colleagues?: Ref<User[]>,
) {
  const store = useChatStore();
  const searchQuery = ref('');

  const allConversations = computed<ConversationItem[]>(() => {
    void store.roomSyncVersion;
    const items: ConversationItem[] = [];
    const handledRoomIds = new Set<string>();
    const myId = store.currentUserId;
    const serverName = myId?.split(':')[1];
    const colleagueList = colleagues?.value ?? selectableColleagues.value;

    // 1. Direct chats for all colleagues
    for (const colleague of selectableColleagues.value) {
      const targetMatrixUserId = colleague.matrix_user_id;

      const { alias: expectedAlias } =
        myId && serverName && targetMatrixUserId
          ? getDirectChatAlias(myId, targetMatrixUserId, serverName)
          : { alias: '' };

      // Match with existing Matrix room(s) for this user
      const candidateRooms = rooms.value.filter((r) => {
        if (!r.isDirect) return false;
        if (expectedAlias && r.alias === expectedAlias) {
          return true;
        }
        if (
          r.directUserId &&
          targetMatrixUserId &&
          r.directUserId.toLowerCase() === targetMatrixUserId.toLowerCase()
        ) {
          return true;
        }
        if (
          targetMatrixUserId &&
          r.memberUserIds?.some(
            (id) => id.toLowerCase() === targetMatrixUserId.toLowerCase(),
          )
        ) {
          return true;
        }
        return false;
      });

      if (candidateRooms.length > 0) {
        candidateRooms.sort(
          (a, b) => b.lastEventTimestamp - a.lastEventTimestamp,
        );
        const matchingRoom = candidateRooms[0];
        if (!matchingRoom) continue;

        for (const cr of candidateRooms) {
          handledRoomIds.add(cr.id);
        }

        items.push({
          avatarUrl: getUserAvatarSource(colleague),
          id: matchingRoom.id,
          isDirect: true,
          lastEventTimestamp: matchingRoom.lastEventTimestamp,
          lastMessage: matchingRoom.lastMessage,
          memberCount: 2,
          name: colleague.name || matchingRoom.name,
          roomId: matchingRoom.id,
          targetMatrixUserId,
          unreadCount: matchingRoom.unreadCount,
          user: colleague,
        });
      } else {
        // Empty content for user with no previous messages
        items.push({
          avatarUrl: getUserAvatarSource(colleague),
          id: `user_${colleague.id}`,
          isDirect: true,
          lastEventTimestamp: 0,
          lastMessage: '',
          memberCount: 2,
          name: colleague.name,
          roomId: undefined,
          targetMatrixUserId,
          unreadCount: 0,
          user: colleague,
        });
      }
    }

    // 2. Add group rooms and other rooms (e.g. system bot)
    for (const room of rooms.value) {
      if (handledRoomIds.has(room.id)) continue;

      const roomColleague =
        room.isDirect && room.directUserId
          ? findColleagueByMatrixId(room.directUserId, colleagueList)
          : undefined;
      const roomTargetMatrixUserId = roomColleague
        ? roomColleague.matrix_user_id
        : room.directUserId;

      let groupMemberAvatars: GroupMemberAvatarInfo[] | undefined;
      if (!room.isDirect) {
        const roomMembers = store.getRoomMembers(room.id);
        if (roomMembers.length > 0) {
          groupMemberAvatars = roomMembers.map((m) => {
            const colleague = findColleagueByMatrixId(m.userId, colleagueList);
            return {
              avatarUrl: colleague
                ? getUserAvatarSource(colleague)
                : m.avatarUrl,
              displayName: colleague?.name || m.displayName || m.userId,
              userId: m.userId,
            };
          });
        } else if (room.memberUserIds && room.memberUserIds.length > 0) {
          groupMemberAvatars = room.memberUserIds.map((userId) => {
            const colleague = findColleagueByMatrixId(userId, colleagueList);
            return {
              avatarUrl: colleague ? getUserAvatarSource(colleague) : undefined,
              displayName: colleague?.name || userId,
              userId,
            };
          });
        }
      }

      items.push({
        avatarUrl: room.avatarUrl,
        groupMemberAvatars,
        id: room.id,
        isDirect: room.isDirect,
        lastEventTimestamp: room.lastEventTimestamp,
        lastMessage: room.lastMessage,
        memberCount: room.memberCount,
        name: room.name,
        roomId: room.id,
        targetMatrixUserId: roomTargetMatrixUserId,
        unreadCount: room.unreadCount,
        user: roomColleague,
      });
    }

    // 3. Sort: Recent active conversations first, empty conversations sorted alphabetically
    return items.toSorted((a, b) => {
      if (a.lastEventTimestamp > 0 && b.lastEventTimestamp > 0) {
        if (b.lastEventTimestamp !== a.lastEventTimestamp) {
          return b.lastEventTimestamp - a.lastEventTimestamp;
        }
        return a.name.localeCompare(b.name, 'vi');
      }
      if (a.lastEventTimestamp > 0) return -1;
      if (b.lastEventTimestamp > 0) return 1;
      return a.name.localeCompare(b.name, 'vi');
    });
  });

  const displayedConversations = computed(() => {
    if (!searchQuery.value.trim()) {
      return allConversations.value;
    }
    const query = searchQuery.value.toLowerCase();
    return allConversations.value.filter(
      (c) =>
        c.name.toLowerCase().includes(query) ||
        c.lastMessage.toLowerCase().includes(query),
    );
  });

  return {
    allConversations,
    displayedConversations,
    searchQuery,
  };
}

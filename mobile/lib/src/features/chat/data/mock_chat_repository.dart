import 'package:obee_mobile/src/features/chat/data/chat_coworker.dart';
import 'package:obee_mobile/src/features/chat/data/chat_conversation.dart';
import 'package:obee_mobile/src/features/chat/data/chat_group_info.dart';
import 'package:obee_mobile/src/features/chat/data/chat_message.dart';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';
import 'package:obee_mobile/src/features/chat/data/chat_thread.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';

final class MockChatRepository implements ChatRepository {
  MockChatRepository();

  static const User _adminUser = User(
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
    id: 'user-admin',
    name: 'Admin User',
    username: 'admin.user',
    email: 'admin.user@obee.test',
    avatar: '/avatars/avatar-1.svg',
  );

  static const User _minhAnhUser = User(
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
    id: 'user-minh-anh',
    name: 'Minh Anh',
    username: 'minh.anh',
    email: 'minh.anh@obee.test',
    avatar: '/avatars/avatar-2.svg',
  );

  static const User _phuongLinhUser = User(
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
    id: 'user-phuong-linh',
    name: 'Phương Linh',
    username: 'phuong.linh',
    email: 'phuong.linh@obee.test',
    avatar: '/avatars/avatar-3.svg',
  );

  static const User _hoangLanUser = User(
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
    id: 'user-hoang-lan',
    name: 'Hoàng Lan',
    username: 'hoang.lan',
    email: 'hoang.lan@obee.test',
    avatar: '/avatars/avatar-4.svg',
  );

  final List<ChatCoworker> _coworkers = const [
    ChatCoworker(
      id: 'coworker-minh-anh',
      displayName: 'Minh Anh',
      subtitle: 'Nhóm vận hành',
      user: _minhAnhUser,
    ),
    ChatCoworker(
      id: 'coworker-phuong-linh',
      displayName: 'Phương Linh',
      subtitle: 'Nhóm sản phẩm',
      user: _phuongLinhUser,
    ),
    ChatCoworker(
      id: 'coworker-hoang-lan',
      displayName: 'Hoàng Lan',
      subtitle: 'Nhóm dự án Apollo',
      user: _hoangLanUser,
    ),
  ];

  final Map<String, String> _directConversationIdsByCoworker = {
    'coworker-minh-anh': 'direct-minh-anh',
  };

  final List<ChatConversation> _directConversations = [
    const ChatConversation(
      kind: ChatConversationKind.oneToOne,
      id: 'direct-minh-anh',
      title: 'Minh Anh',
      previewText: 'Minh Anh: Mình đang trên đường đến văn phòng.',
      timestampLabel: '08:45',
      avatarKind: ChatConversationAvatarKind.person,
      participantNames: ['Minh Anh'],
      participantUser: _minhAnhUser,
      unreadCount: 2,
    ),
    const ChatConversation(
      kind: ChatConversationKind.group,
      id: 'group-apollo',
      title: 'Nhóm dự án Apollo',
      previewText: 'Lan: Bản build mới đã sẵn sàng để kiểm tra.',
      timestampLabel: 'Hôm nay',
      avatarKind: ChatConversationAvatarKind.group,
      participantNames: ['Lan', 'Admin User'],
      unreadCount: 0,
    ),
  ];

  final Map<String, ChatThread> _threads = {
    'company-channel': ChatThread(
      conversationId: 'company-channel',
      title: 'Kênh công ty',
      kind: ChatThreadKind.general,
      isReadOnly: false,
      messages: [
        ChatMessage(
          id: 'message-1',
          senderName: 'HR',
          text: 'Nhớ cập nhật báo cáo trước 17:00 hôm nay.',
          sentAt: DateTime(2026, 6, 13, 16, 45),
          isSelf: false,
        ),
        ChatMessage(
          id: 'message-2',
          senderName: 'Linh',
          text: 'Họp nhanh bắt đầu lúc 09:00 tại phòng họp tầng 3.',
          sentAt: DateTime(2026, 6, 14, 8, 10),
          isSelf: false,
        ),
        ChatMessage(
          id: 'message-3',
          senderName: 'Admin User',
          text: 'Đã rõ, mình sẽ có mặt đúng giờ.',
          sentAt: DateTime(2026, 6, 14, 8, 14),
          isSelf: true,
        ),
      ],
    ),
    'announcements': ChatThread(
      conversationId: 'announcements',
      title: 'Thông báo',
      kind: ChatThreadKind.general,
      isReadOnly: true,
      messages: [
        ChatMessage(
          id: 'announcement-1',
          senderName: 'HR',
          text: 'Lịch nghỉ Tết đã được cập nhật.',
          sentAt: DateTime(2026, 6, 14, 9, 0),
          isSelf: false,
        ),
      ],
    ),
    'direct-minh-anh': ChatThread(
      conversationId: 'direct-minh-anh',
      title: 'Minh Anh',
      kind: ChatThreadKind.oneToOne,
      isReadOnly: false,
      messages: [
        ChatMessage(
          id: 'direct-minh-anh-1',
          senderName: 'Minh Anh',
          text: 'Mình đang trên đường đến văn phòng.',
          sentAt: DateTime(2026, 6, 15, 8, 45),
          isSelf: false,
        ),
        ChatMessage(
          id: 'direct-minh-anh-2',
          senderName: 'Admin User',
          text: 'Ổn rồi, gặp bạn ở phòng họp nhé.',
          sentAt: DateTime(2026, 6, 15, 8, 47),
          isSelf: true,
        ),
      ],
    ),
    'group-apollo': ChatThread(
      conversationId: 'group-apollo',
      title: 'Nhóm dự án Apollo',
      kind: ChatThreadKind.group,
      isReadOnly: false,
      messages: [
        ChatMessage(
          id: 'group-apollo-1',
          senderName: 'Lan',
          text: 'Bản build mới đã sẵn sàng để kiểm tra.',
          sentAt: DateTime(2026, 6, 15, 8, 12),
          isSelf: false,
        ),
        ChatMessage(
          id: 'group-apollo-2',
          senderName: 'Admin User',
          text: 'Mình sẽ kiểm tra ngay sau khi vào văn phòng.',
          sentAt: DateTime(2026, 6, 15, 8, 20),
          isSelf: true,
        ),
      ],
    ),
  };

  final Map<String, ChatGroupInfo> _groupInfos = {
    'group-apollo': const ChatGroupInfo(
      conversationId: 'group-apollo',
      title: 'Nhóm dự án Apollo',
      canRename: false,
      canLeave: false,
      members: [
        ChatGroupMember(
          id: 'member-admin-user',
          displayName: 'Admin User',
          subtitle: 'Quản trị viên',
          isCurrentUser: true,
          user: _adminUser,
        ),
        ChatGroupMember(
          id: 'member-hoang-lan',
          displayName: 'Hoàng Lan',
          subtitle: 'Nhóm dự án Apollo',
          isCurrentUser: false,
          user: _hoangLanUser,
        ),
        ChatGroupMember(
          id: 'member-phuong-linh',
          displayName: 'Phương Linh',
          subtitle: 'Nhóm sản phẩm',
          isCurrentUser: false,
          user: _phuongLinhUser,
        ),
      ],
    ),
  };

  @override
  Future<List<ChatConversation>> loadGeneralChannels() async {
    return const [
      ChatConversation(
        kind: ChatConversationKind.general,
        id: 'company-channel',
        title: 'Kênh công ty',
        previewText: 'Linh: Họp nhanh bắt đầu lúc 09:00.',
        timestampLabel: '09:12',
        avatarKind: ChatConversationAvatarKind.organization,
        unreadCount: 2,
        isReadOnly: false,
      ),
      ChatConversation(
        kind: ChatConversationKind.general,
        id: 'announcements',
        title: 'Thông báo',
        previewText: 'HR: Lịch nghỉ Tết đã được cập nhật.',
        timestampLabel: 'Hôm qua',
        avatarKind: ChatConversationAvatarKind.announcement,
        isReadOnly: true,
      ),
    ];
  }

  @override
  Future<List<ChatConversation>> loadDirectConversations() async {
    return List<ChatConversation>.unmodifiable(_directConversations);
  }

  @override
  Future<List<ChatCoworker>> loadCoworkers() async {
    return List<ChatCoworker>.unmodifiable(_coworkers);
  }

  @override
  Future<String> openDirectConversationForCoworker(String coworkerId) async {
    final existingConversationId = _directConversationIdsByCoworker[coworkerId];
    if (existingConversationId != null) {
      return existingConversationId;
    }

    final coworker = _coworkers.singleWhere(
      (candidate) => candidate.id == coworkerId,
    );
    final conversationId = 'direct-${coworkerId.replaceFirst('coworker-', '')}';
    _directConversationIdsByCoworker[coworkerId] = conversationId;
    _threads[conversationId] = ChatThread(
      conversationId: conversationId,
      title: coworker.displayName,
      kind: ChatThreadKind.oneToOne,
      isReadOnly: false,
      messages: const [],
    );
    _directConversations.insert(
      0,
      ChatConversation(
        kind: ChatConversationKind.oneToOne,
        id: conversationId,
        title: coworker.displayName,
        previewText: 'Chưa có tin nhắn nào.',
        timestampLabel: 'Bây giờ',
        avatarKind: ChatConversationAvatarKind.person,
        participantNames: [coworker.displayName],
        participantUser: coworker.user,
      ),
    );

    return conversationId;
  }

  @override
  Future<ChatThread> loadThread(String conversationId) async {
    final thread = _threads[conversationId];
    if (thread == null) {
      throw StateError('Không tìm thấy cuộc trò chuyện: $conversationId');
    }

    return thread;
  }

  @override
  Future<ChatGroupInfo> loadGroupInfo(String conversationId) async {
    final groupInfo = _groupInfos[conversationId];
    if (groupInfo == null) {
      throw StateError('Không tìm thấy thông tin nhóm: $conversationId');
    }

    return groupInfo;
  }

  @override
  Future<ChatThread> sendThreadMessage({
    required String conversationId,
    required String text,
  }) async {
    final thread = await loadThread(conversationId);
    final existingConversationIndex = _directConversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );
    final nextMessage = ChatMessage(
      id: 'message-local-${thread.messages.length + 1}',
      senderName: 'Admin User',
      text: text,
      sentAt: DateTime(2026, 6, 14, 9, 16),
      isSelf: true,
    );
    final updatedThread = thread.copyWith(
      messages: [...thread.messages, nextMessage],
    );
    _threads[conversationId] = updatedThread;
    if (existingConversationIndex != -1) {
      final existingConversation =
          _directConversations[existingConversationIndex];
      _replaceDirectConversation(
        ChatConversation(
          kind: existingConversation.kind,
          id: conversationId,
          title: updatedThread.title,
          previewText: 'Admin User: $text',
          timestampLabel: 'Bây giờ',
          avatarKind: existingConversation.avatarKind,
          participantNames: existingConversation.participantNames,
          participantUser: existingConversation.participantUser,
        ),
      );
    }

    return updatedThread;
  }

  void _replaceDirectConversation(ChatConversation updatedConversation) {
    final existingIndex = _directConversations.indexWhere(
      (conversation) => conversation.id == updatedConversation.id,
    );
    if (existingIndex == -1) {
      _directConversations.insert(0, updatedConversation);
      return;
    }

    _directConversations
      ..removeAt(existingIndex)
      ..insert(0, updatedConversation);
  }
}

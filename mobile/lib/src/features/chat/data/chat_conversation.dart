import 'package:obee_mobile/src/features/auth/data/user.dart';

enum ChatConversationKind { general, oneToOne, group }

enum ChatConversationAvatarKind { person, group, organization, announcement }

class ChatConversation {
  const ChatConversation({
    required this.kind,
    required this.id,
    required this.title,
    required this.previewText,
    required this.timestampLabel,
    required this.avatarKind,
    this.participantNames = const [],
    this.participantUser,
    this.isReadOnly = false,
    this.unreadCount = 0,
  }) : assert(
         avatarKind == ChatConversationAvatarKind.person
             ? participantUser != null
             : participantUser == null,
         'Person conversations require participantUser and non-person conversations must not provide one.',
       );

  final ChatConversationKind kind;
  final String id;
  final String title;
  final String previewText;
  final String timestampLabel;
  final ChatConversationAvatarKind avatarKind;
  final List<String> participantNames;
  final User? participantUser;
  final bool isReadOnly;
  final int unreadCount;

  bool get hasUnread => unreadCount > 0;

  bool get isDirect => kind != ChatConversationKind.general;

  bool get isGroupConversation => kind == ChatConversationKind.group;
  String get unreadStatusLabel =>
      hasUnread ? '$unreadCount tin chưa đọc' : 'không có tin chưa đọc';

  bool matchesSearchQuery(String query) {
    final normalizedQuery = query.toLowerCase();

    if (title.toLowerCase().contains(normalizedQuery)) {
      return true;
    }

    return participantNames.any(
      (participantName) =>
          participantName.toLowerCase().contains(normalizedQuery),
    );
  }
}

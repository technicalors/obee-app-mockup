import 'package:obee_mobile/src/features/auth/data/user.dart';

class ChatGroupInfo {
  const ChatGroupInfo({
    required this.conversationId,
    required this.title,
    required this.members,
    required this.canRename,
    required this.canLeave,
  });

  final String conversationId;
  final String title;
  final List<ChatGroupMember> members;
  final bool canRename;
  final bool canLeave;
}

class ChatGroupMember {
  const ChatGroupMember({
    required this.id,
    required this.displayName,
    required this.subtitle,
    required this.isCurrentUser,
    required this.user,
  });

  final String id;
  final String displayName;
  final String subtitle;
  final bool isCurrentUser;
  final User user;
}

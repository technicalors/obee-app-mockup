import 'package:obee_mobile/src/features/auth/data/user.dart';

class ChatCoworker {
  const ChatCoworker({
    required this.id,
    required this.displayName,
    required this.subtitle,
    required this.user,
  });

  final String id;
  final String displayName;
  final String subtitle;
  final User user;

  bool matchesSearchQuery(String query) {
    final normalizedQuery = query.toLowerCase();

    return displayName.toLowerCase().contains(normalizedQuery) ||
        subtitle.toLowerCase().contains(normalizedQuery);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/chat/data/chat_conversation.dart';
import 'package:obee_mobile/src/features/chat/state/chat_hub_provider.dart';

final directChatSearchProvider =
    NotifierProvider<DirectChatSearchController, String>(
      DirectChatSearchController.new,
    );

final filteredDirectConversationsProvider = Provider<List<ChatConversation>>((
  ref,
) {
  final query = ref.watch(directChatSearchProvider);
  final conversations = ref
      .watch(directConversationsProvider)
      .maybeWhen(
        data: (conversations) => conversations,
        orElse: () => const <ChatConversation>[],
      );

  if (query.isEmpty) {
    return conversations;
  }

  return conversations
      .where((conversation) => conversation.matchesSearchQuery(query))
      .toList();
});

class DirectChatSearchController extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void updateQuery(String query) {
    if (state == query) {
      return;
    }

    state = query;
  }

  void clear() {
    if (state.isEmpty) {
      return;
    }

    state = '';
  }
}

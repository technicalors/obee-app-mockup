import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/chat/data/chat_coworker.dart';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';
import 'package:obee_mobile/src/features/chat/state/chat_hub_provider.dart';
import 'package:obee_mobile/src/features/chat/state/chat_thread_provider.dart';

final coworkerPickerProvider = FutureProvider<List<ChatCoworker>>((ref) {
  return ref.watch(chatRepositoryProvider).loadCoworkers();
});

final newDirectChatSearchProvider =
    NotifierProvider<NewDirectChatSearchController, String>(
      NewDirectChatSearchController.new,
    );

final filteredCoworkerPickerProvider = Provider<List<ChatCoworker>>((ref) {
  final query = ref.watch(newDirectChatSearchProvider);
  final coworkers = ref
      .watch(coworkerPickerProvider)
      .maybeWhen(
        data: (coworkers) => coworkers,
        orElse: () => const <ChatCoworker>[],
      );

  if (query.isEmpty) {
    return coworkers;
  }

  return coworkers
      .where((coworker) => coworker.matchesSearchQuery(query))
      .toList(growable: false);
});

final newDirectChatControllerProvider = Provider<NewDirectChatController>((
  ref,
) {
  return NewDirectChatController(ref);
});

class NewDirectChatSearchController extends Notifier<String> {
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

class NewDirectChatController {
  NewDirectChatController(this._ref);

  final Ref _ref;

  Future<String> openConversationForCoworker(String coworkerId) async {
    final conversationId = await _ref
        .read(chatRepositoryProvider)
        .openDirectConversationForCoworker(coworkerId);

    _ref.invalidate(directConversationsProvider);
    _ref.invalidate(chatThreadProvider(conversationId));
    return conversationId;
  }
}

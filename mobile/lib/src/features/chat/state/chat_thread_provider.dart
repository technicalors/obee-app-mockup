import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';
import 'package:obee_mobile/src/features/chat/data/chat_thread.dart';
import 'package:obee_mobile/src/features/chat/state/chat_hub_provider.dart';

final chatThreadProvider = FutureProvider.family<ChatThread, String>((
  ref,
  conversationId,
) {
  return ref.watch(chatRepositoryProvider).loadThread(conversationId);
});

final chatThreadControllerProvider =
    Provider.family<ChatThreadController, String>((ref, conversationId) {
      return ChatThreadController(ref: ref, conversationId: conversationId);
    });

class ChatThreadController {
  ChatThreadController({required this._ref, required this._conversationId});

  final Ref _ref;
  final String _conversationId;

  Future<void> sendMessage(String text) async {
    final updatedThread = await _ref
        .read(chatRepositoryProvider)
        .sendThreadMessage(conversationId: _conversationId, text: text);
    _ref.invalidate(chatThreadProvider(_conversationId));
    if (updatedThread.kind != ChatThreadKind.general) {
      _ref.invalidate(directConversationsProvider);
      await _ref.read(directConversationsProvider.future);
    }
    await _ref.read(chatThreadProvider(_conversationId).future);
  }
}

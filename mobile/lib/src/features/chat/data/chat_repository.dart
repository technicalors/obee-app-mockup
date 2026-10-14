import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/chat/data/chat_coworker.dart';
import 'package:obee_mobile/src/features/chat/data/chat_conversation.dart';
import 'package:obee_mobile/src/features/chat/data/chat_group_info.dart';
import 'package:obee_mobile/src/features/chat/data/chat_thread.dart';
import 'package:obee_mobile/src/features/chat/data/mock_chat_repository.dart';

abstract interface class ChatRepository {
  Future<List<ChatConversation>> loadGeneralChannels();

  Future<List<ChatConversation>> loadDirectConversations();

  Future<List<ChatCoworker>> loadCoworkers();

  Future<String> openDirectConversationForCoworker(String coworkerId);

  Future<ChatThread> loadThread(String conversationId);

  Future<ChatGroupInfo> loadGroupInfo(String conversationId);

  Future<ChatThread> sendThreadMessage({
    required String conversationId,
    required String text,
  });
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return MockChatRepository();
});

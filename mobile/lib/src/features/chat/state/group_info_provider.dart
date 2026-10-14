import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/chat/data/chat_group_info.dart';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';

final groupInfoProvider = FutureProvider.family<ChatGroupInfo, String>((
  ref,
  conversationId,
) {
  return ref.watch(chatRepositoryProvider).loadGroupInfo(conversationId);
});

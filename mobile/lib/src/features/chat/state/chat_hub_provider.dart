import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/chat/data/chat_conversation.dart';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';

final chatHubProvider = NotifierProvider<ChatHubController, ChatHubState>(
  ChatHubController.new,
);

final generalChannelsProvider = FutureProvider<List<ChatConversation>>((ref) {
  return ref.watch(chatRepositoryProvider).loadGeneralChannels();
});

final generalUnreadCountProvider = Provider<int?>((ref) {
  final channelsAsync = ref.watch(generalChannelsProvider);

  return switch (channelsAsync) {
    AsyncData(:final value) => value.fold<int>(
      0,
      (total, channel) => total + channel.unreadCount,
    ),
    _ => null,
  };
});

final directConversationsProvider = FutureProvider<List<ChatConversation>>((
  ref,
) {
  return ref.watch(chatRepositoryProvider).loadDirectConversations();
});

final directUnreadCountProvider = Provider<int?>((ref) {
  final conversationsAsync = ref.watch(directConversationsProvider);

  return switch (conversationsAsync) {
    AsyncData(:final value) => value.fold<int>(
      0,
      (total, conversation) => total + conversation.unreadCount,
    ),
    _ => null,
  };
});

class ChatHubController extends Notifier<ChatHubState> {
  @override
  ChatHubState build() {
    return const ChatHubState();
  }

  void selectTab(ChatHubTab tab) {
    if (state.selectedTab == tab) {
      return;
    }

    state = state.copyWith(selectedTab: tab);
  }

  Future<void> refresh() async {
    try {
      await Future.wait([
        ref.refresh(generalChannelsProvider.future),
        ref.refresh(directConversationsProvider.future),
      ]);
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        errorMessage: 'Không thể tải lại danh sách trò chuyện.',
      );
    }
  }

  void clearFeedback() {
    state = state.copyWith(errorMessage: null);
  }
}

enum ChatHubTab { general, direct }

class ChatHubState {
  const ChatHubState({
    this.selectedTab = ChatHubTab.general,
    this.errorMessage,
  });

  final ChatHubTab selectedTab;
  final String? errorMessage;

  ChatHubState copyWith({ChatHubTab? selectedTab, String? errorMessage}) {
    return ChatHubState(
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: errorMessage,
    );
  }
}

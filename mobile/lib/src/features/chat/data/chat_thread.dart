import 'package:obee_mobile/src/features/chat/data/chat_message.dart';

enum ChatThreadKind { general, oneToOne, group }

class ChatThread {
  const ChatThread({
    required this.conversationId,
    required this.title,
    required this.kind,
    required this.isReadOnly,
    required this.messages,
  });

  final String conversationId;
  final String title;
  final ChatThreadKind kind;
  final bool isReadOnly;
  final List<ChatMessage> messages;

  bool get showsSenderLabels => kind != ChatThreadKind.oneToOne;

  ChatThread copyWith({
    String? conversationId,
    String? title,
    ChatThreadKind? kind,
    bool? isReadOnly,
    List<ChatMessage>? messages,
  }) {
    return ChatThread(
      conversationId: conversationId ?? this.conversationId,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      messages: messages ?? this.messages,
    );
  }
}

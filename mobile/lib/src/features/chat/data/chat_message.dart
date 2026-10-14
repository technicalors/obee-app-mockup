class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.isSelf,
  });

  final String id;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isSelf;
}

class MessageModel {
  final String name;

  final String profile;

  final String lastMessage;

  final String time;

  final List<ChatMessage> messages;

  MessageModel({
    required this.name,

    required this.profile,

    required this.lastMessage,

    required this.time,

    required this.messages,
  });
}

class ChatMessage {
  final String text;

  final String time;

  final String date;

  final bool isMe;

  ChatMessage({
    required this.text,

    required this.time,

    required this.date,

    required this.isMe,
  });
}

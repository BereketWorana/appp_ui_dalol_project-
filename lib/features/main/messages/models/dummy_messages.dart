import 'message_model.dart';

final List<MessageModel> messages = [
  MessageModel(
    name: "Grand Palace Hotel",

    profile: "assets/images/r1.jpg",

    lastMessage: "Your room is available tomorrow",

    time: "10:32",

    messages: [
      ChatMessage(
        text: "Hello, I want to book a room",

        time: "10:20",

        date: "Today",

        isMe: true,
      ),

      ChatMessage(
        text: "Welcome! We have deluxe rooms available",

        time: "10:25",

        date: "Today",

        isMe: false,
      ),

      ChatMessage(
        text: "Your room is available tomorrow",

        time: "10:32",

        date: "Today",

        isMe: false,
      ),
    ],
  ),

  MessageModel(
    name: "Paradise Restaurant",

    profile: "assets/images/r2.jpg",

    lastMessage: "Reservation confirmed",

    time: "Yesterday",

    messages: [
      ChatMessage(
        text: "Can I reserve a table?",

        time: "8:00",

        date: "Yesterday",

        isMe: true,
      ),

      ChatMessage(
        text: "Reservation confirmed",

        time: "8:10",

        date: "Yesterday",

        isMe: false,
      ),
    ],
  ),
];

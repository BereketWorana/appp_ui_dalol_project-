import 'package:flutter/material.dart';

import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final MessageModel chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  List<ChatMessage> chatMessages = [];

  @override
  void initState() {
    super.initState();

    chatMessages = List.from(widget.chat.messages);
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      chatMessages.add(
        ChatMessage(
          text: messageController.text,

          time: TimeOfDay.now().format(context),

          date: "Today",

          isMe: true,
        ),
      );

      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff101010),

      appBar: AppBar(
        backgroundColor: const Color(0xff171717),

        elevation: 0,

        title: Row(
          children: [
            CircleAvatar(
              radius: 20,

              backgroundImage: AssetImage(widget.chat.profile),
            ),

            const SizedBox(width: 12),

            Text(
              widget.chat.name,

              style: const TextStyle(
                color: Colors.white,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),

              itemCount: chatMessages.length,

              itemBuilder: (context, index) {
                final msg = chatMessages[index];

                bool showDate =
                    index == 0 || chatMessages[index - 1].date != msg.date;

                return Column(
                  children: [
                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,

                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white12,

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            msg.date,

                            style: const TextStyle(
                              color: Colors.white70,

                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                    Align(
                      alignment: msg.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,

                          vertical: 10,
                        ),

                        constraints: const BoxConstraints(maxWidth: 280),

                        decoration: BoxDecoration(
                          color: msg.isMe
                              ? Colors.blueAccent
                              : const Color(0xff242424),

                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),

                            topRight: const Radius.circular(20),

                            bottomLeft: msg.isMe
                                ? const Radius.circular(20)
                                : Radius.zero,

                            bottomRight: msg.isMe
                                ? Radius.zero
                                : const Radius.circular(20),
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,

                          children: [
                            Text(
                              msg.text,

                              style: const TextStyle(
                                color: Colors.white,

                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              msg.time,

                              style: const TextStyle(
                                color: Colors.white70,

                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          messageInput(),
        ],
      ),
    );
  }

  Widget messageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      color: const Color(0xff171717),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Message...",

                hintStyle: const TextStyle(color: Colors.white54),

                filled: true,

                fillColor: Colors.white12,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          CircleAvatar(
            backgroundColor: Colors.blueAccent,

            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),

              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

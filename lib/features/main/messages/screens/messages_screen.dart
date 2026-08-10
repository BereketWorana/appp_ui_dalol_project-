import 'package:flutter/material.dart';

import '../../../auth/screens/login_screen.dart';

import '../../../../core/services/user_session.dart';
import '../../../../data/models/user.dart';

import '../models/dummy_messages.dart';
import '../models/message_model.dart';

import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  final User? selectedUser;

  const MessagesScreen({super.key, this.selectedUser});

  @override
  Widget build(BuildContext context) {
    if (!UserSession.isLoggedIn) {
      return const LoginScreen();
    }

    // ==========================================
    // OPEN DIRECT CHAT WITH SELECTED USER
    // ==========================================

    if (selectedUser != null) {
      final user = selectedUser!;

      final directChat = MessageModel(
        name: user.fullName,

        profile: user.profileImage,

        lastMessage: "Start a conversation",

        time: "",

        messages: [],
      );

      return Scaffold(
        backgroundColor: const Color(0xff0B0B0B),

        appBar: AppBar(
          backgroundColor: const Color(0xff0B0B0B),

          elevation: 0,

          title: const Text(
            "Messages",

            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        body: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),

          leading: CircleAvatar(
            radius: 28,

            backgroundImage: AssetImage(user.profileImage),
          ),

          title: Text(
            user.fullName,

            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          subtitle: const Text(
            "Start a conversation",

            style: TextStyle(color: Colors.white60),
          ),

          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),

          onTap: () {
            Navigator.push(
              context,

              MaterialPageRoute(builder: (_) => ChatScreen(chat: directChat)),
            );
          },
        ),
      );
    }

    // ==========================================
    // NORMAL MESSAGES LIST
    // ==========================================

    return Scaffold(
      backgroundColor: const Color(0xff0B0B0B),

      appBar: AppBar(
        backgroundColor: const Color(0xff0B0B0B),

        elevation: 0,

        title: const Text(
          "Messages",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView.builder(
        itemCount: messages.length,

        itemBuilder: (context, index) {
          final chat = messages[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),

            leading: CircleAvatar(
              radius: 28,

              backgroundImage: AssetImage(chat.profile),
            ),

            title: Text(
              chat.name,

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Text(
              chat.lastMessage,

              maxLines: 1,

              style: const TextStyle(color: Colors.white60),
            ),

            trailing: Text(
              chat.time,

              style: const TextStyle(color: Colors.white54),
            ),

            onTap: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
              );
            },
          );
        },
      ),
    );
  }
}

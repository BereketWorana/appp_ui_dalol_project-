import 'package:flutter/material.dart';

import 'register_screen.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  void openRegistration(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterScreen(selectedRole: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Choose Your Journey",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "How would you like to use Super Platform?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Choose how you want to use the platform.",
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),

              const SizedBox(height: 30),

              _roleCard(
                context,
                icon: Icons.travel_explore,
                title: "Consumer",
                description:
                    "Discover destinations, book hotels, save favorites, chat with hotels and enjoy personalized travel experiences.",
                buttonText: "Continue as Consumer",
                onTap: () {
                  openRegistration(context, "consumer");
                },
              ),

              const SizedBox(height: 20),

              _roleCard(
                context,
                icon: Icons.video_camera_back,
                title: "Creator",
                description:
                    "Share travel videos, inspire tourists, build your audience and earn rewards from your content.",
                buttonText: "Apply as Creator",
                onTap: () {
                  openRegistration(context, "creator");
                },
              ),

              const SizedBox(height: 20),

              _roleCard(
                context,
                icon: Icons.hotel,
                title: "Hotel Owner",
                description:
                    "Promote your hotel, manage rooms, receive bookings and upload promotional videos.",
                buttonText: "Apply as Hotel Owner",
                onTap: () {
                  openRegistration(context, "merchant");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _roleCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String description,
  required String buttonText,
  required VoidCallback onTap,
}) {
  return Container(
    padding: const EdgeInsets.all(22),

    decoration: BoxDecoration(
      color: const Color(0xFF181818),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white10),
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF2454E8).withValues(alpha: .15),
          child: Icon(icon, color: const Color(0xFF4C7EFF), size: 30),
        ),

        const SizedBox(height: 18),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          height: 48,

          child: ElevatedButton(
            onPressed: onTap,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2454E8),
              foregroundColor: Colors.white,
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';

import 'customer_registration_screen.dart';
import 'influencer_registration_screen.dart';
import 'hotel_owner_register_screen.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  // ============================================================
  // OPEN CUSTOMER REGISTRATION
  // ============================================================

  void openCustomerRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerRegistrationScreen()),
    );
  }

  // ============================================================
  // OPEN INFLUENCER REGISTRATION
  // ============================================================

  void openInfluencerRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InfluencerRegistrationScreen()),
    );
  }

  // ============================================================
  // OPEN HOTEL OWNER REGISTRATION
  // ============================================================

  void openHotelOwnerRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HotelOwnerRegisterScreen()),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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
              // ==================================================
              // HEADER
              // ==================================================
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

              // ==================================================
              // CONSUMER
              // ==================================================
              _roleCard(
                context,
                icon: Icons.travel_explore,
                title: "Consumer",
                description:
                    "Discover destinations, book hotels, save favorites, chat with hotels and enjoy personalized travel experiences.",
                buttonText: "Continue as Consumer",
                onTap: () {
                  openCustomerRegistration(context);
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CREATOR / INFLUENCER
              // ==================================================
              _roleCard(
                context,
                icon: Icons.video_camera_back,
                title: "Creator",
                description:
                    "Share travel videos, inspire tourists, build your audience and earn rewards from your content.",
                buttonText: "Apply as Creator",
                onTap: () {
                  openInfluencerRegistration(context);
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // HOTEL OWNER
              // ==================================================
              _roleCard(
                context,
                icon: Icons.hotel,
                title: "Hotel Owner",
                description:
                    "Promote your hotel, manage rooms, receive bookings and grow your hotel business on Super Platform.",
                buttonText: "Apply as Hotel Owner",
                onTap: () {
                  openHotelOwnerRegistration(context);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ROLE CARD
// ================================================================

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
        // ========================================================
        // ICON
        // ========================================================
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF2454E8).withValues(alpha: .15),

          child: Icon(icon, color: const Color(0xFF4C7EFF), size: 30),
        ),

        const SizedBox(height: 18),

        // ========================================================
        // TITLE
        // ========================================================
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        // ========================================================
        // DESCRIPTION
        // ========================================================
        Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 22),

        // ========================================================
        // BUTTON
        // ========================================================
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

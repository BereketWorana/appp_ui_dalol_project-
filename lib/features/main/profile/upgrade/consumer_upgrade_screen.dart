import 'package:flutter/material.dart';

import 'merchant_application_screen.dart';
import 'creator_application_screen.dart';

class ConsumerUpgradeScreen extends StatelessWidget {
  const ConsumerUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        elevation: 0,

        title: const Text(
          "Create",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 100,

              height: 100,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(30),
              ),

              child: const Icon(
                Icons.add_circle_outline,

                color: Colors.black,

                size: 55,
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Unlock Creation",

              style: TextStyle(
                color: Colors.white,

                fontSize: 32,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Create videos, promote hotels, "
              "or start your business on the platform.",

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),

            const SizedBox(height: 45),

            upgradeCard(
              context,

              icon: Icons.video_camera_back_outlined,

              title: "Become a Creator",

              subtitle: "Upload tourism videos and share experiences",

              action: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => const CreatorApplicationScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            upgradeCard(
              context,

              icon: Icons.hotel_outlined,

              title: "Register Business",

              subtitle: "Add your hotel, rooms and offers",

              action: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) => const MerchantApplicationScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget upgradeCard(
    BuildContext context, {

    required IconData icon,

    required String title,

    required String subtitle,

    required VoidCallback action,
  }) {
    return GestureDetector(
      onTap: action,

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),

          borderRadius: BorderRadius.circular(22),

          border: Border.all(color: Colors.white24),
        ),

        child: Row(
          children: [
            Container(
              width: 55,

              height: 55,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),
              ),

              child: Icon(icon, color: Colors.black, size: 30),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 18,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(subtitle, style: const TextStyle(color: Colors.white60)),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,

              color: Colors.white54,

              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

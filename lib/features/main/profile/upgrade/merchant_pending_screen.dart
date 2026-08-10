import 'package:flutter/material.dart';

import '../../screens/main_screen.dart';

class MerchantPendingScreen extends StatelessWidget {
  const MerchantPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 120,

                height: 120,

                decoration: BoxDecoration(
                  color: Colors.white,

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.hourglass_top_rounded,

                  color: Colors.black,

                  size: 60,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Application Submitted",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 30,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Your business application is under review.\n\n"
                "Our team will verify your information "
                "and notify you after approval.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white60,

                  fontSize: 16,

                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,

                  vertical: 15,
                ),

                decoration: BoxDecoration(
                  color: Colors.white12,

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(color: Colors.white24),
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(Icons.pending_actions, color: Colors.white),

                    SizedBox(width: 12),

                    Text(
                      "Status: Pending",

                      style: TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,

                      MaterialPageRoute(
                        builder: (context) => const ConsumerMainScreen(),
                      ),

                      (route) => false,
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,

                    foregroundColor: Colors.black,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: const Text(
                    "Continue Exploring",

                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

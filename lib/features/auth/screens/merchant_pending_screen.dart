import 'package:flutter/material.dart';

import '../../main/screens/main_screen.dart';

class MerchantPendingScreen extends StatelessWidget {
  final String? hotelName;
  final String? hotelId;

  const MerchantPendingScreen({super.key, this.hotelName, this.hotelId});

  // ============================================================
  // CONTINUE AS GUEST
  // ============================================================

  void continueAsGuest(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ConsumerMainScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: Colors.black,

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),

            child: Column(
              children: [
                const Spacer(),

                // ==================================================
                // PENDING ICON
                // ==================================================
                Container(
                  width: 110,
                  height: 110,

                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.10),

                    shape: BoxShape.circle,

                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.20),
                    ),
                  ),

                  child: Container(
                    margin: const EdgeInsets.all(12),

                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // TITLE
                // ==================================================
                const Text(
                  "Hotel Under Review",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // HOTEL NAME
                // ==================================================
                if (hotelName != null && hotelName!.trim().isNotEmpty)
                  Text(
                    hotelName!.trim(),
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(height: 12),

                // ==================================================
                // DESCRIPTION
                // ==================================================
                const Text(
                  "Your hotel registration has been successfully submitted and is currently under admin review.",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // STATUS CARD
                // ==================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.30),
                    ),
                  ),

                  child: Column(
                    children: [
                      const Text(
                        "APPLICATION STATUS",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 9,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: const Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              color: Colors.orange,
                              size: 19,
                            ),

                            SizedBox(width: 8),

                            Text(
                              "PENDING REVIEW",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Your hotel is waiting for administrator approval.",
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "You will be notified once your hotel has been reviewed and approved.",
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ==================================================
                // GUEST BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      continueAsGuest(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    child: const Text(
                      "Continue as Guest",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // SMALL MESSAGE
                // ==================================================
                const Text(
                  "You can continue browsing the platform while your hotel application is being reviewed.",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../features/main/home/screens/home_screen.dart';

class MerchantPendingScreen extends StatelessWidget {
  const MerchantPendingScreen({
    super.key,
    required hotelId,
    required String hotelName,
  });

  // ============================================================
  // CONTINUE AS GUEST
  // ============================================================

  void continueAsGuest(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

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
                // SUCCESS ICON
                // ==================================================
                Container(
                  width: 110,
                  height: 110,

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),

                    shape: BoxShape.circle,

                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),

                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // TITLE
                // ==================================================
                const Text(
                  "Application Submitted!",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // DESCRIPTION
                // ==================================================
                const Text(
                  "Your hotel registration has been successfully submitted and is now under review.",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // APPROVAL INFO
                // ==================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),

                  child: const Column(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: Colors.white70,
                        size: 30,
                      ),

                      SizedBox(height: 12),

                      Text(
                        "Waiting for approval",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 7),

                      Text(
                        "Once your hotel is approved by the administrator, you will be able to access your hotel management features.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          height: 1.4,
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
                  "You can continue browsing the platform while your application is being reviewed.",
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

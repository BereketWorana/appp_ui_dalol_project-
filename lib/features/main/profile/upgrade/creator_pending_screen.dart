import 'package:flutter/material.dart';

import '../../../main/screens/main_screen.dart';

class CreatorPendingScreen extends StatelessWidget {
  final String? fullName;
  final String? email;

  const CreatorPendingScreen({super.key, this.fullName, this.email});

  // ============================================================
  // CONTINUE AS GUEST
  // ============================================================

  void continueAsGuest(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ConsumerMainScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            children: [
              // ==================================================
              // CONTENT
              // ==================================================
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        // ==================================================
                        // SUCCESS ICON
                        // ==================================================
                        Container(
                          width: 105,
                          height: 105,

                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: .12),
                            shape: BoxShape.circle,
                          ),

                          child: Container(
                            margin: const EdgeInsets.all(12),

                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.hourglass_top,
                              color: Colors.white,
                              size: 48,
                            ),
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

                        const SizedBox(height: 12),

                        // ==================================================
                        // NAME
                        // ==================================================
                        if (fullName != null && fullName!.trim().isNotEmpty)
                          Text(
                            "Thank you, ${fullName!.trim()}",
                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // STATUS CARD
                        // ==================================================
                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(22),

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .06),

                            borderRadius: BorderRadius.circular(20),

                            border: Border.all(
                              color: Colors.orange.withValues(alpha: .35),
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
                                  color: Colors.orange.withValues(alpha: .15),

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
                                      "PENDING",
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

                              const SizedBox(height: 20),

                              const Text(
                                "Your influencer application has been successfully submitted and is waiting for admin approval.",
                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                "You will receive a notification once your account is approved.",
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

                        const SizedBox(height: 25),

                        // ==================================================
                        // WHAT HAPPENS NEXT
                        // ==================================================
                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .04),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                "What happens next?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 14),

                              _Step(
                                number: "1",
                                text: "Admin reviews your application",
                              ),

                              SizedBox(height: 12),

                              _Step(
                                number: "2",
                                text: "Your influencer profile is approved",
                              ),

                              SizedBox(height: 12),

                              _Step(
                                number: "3",
                                text: "You receive a notification",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // CONTINUE AS GUEST
              // ==================================================
              Padding(
                padding: const EdgeInsets.only(bottom: 20),

                child: SizedBox(
                  width: double.infinity,

                  height: 56,

                  child: ElevatedButton(
                    onPressed: () {
                      continueAsGuest(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,

                      foregroundColor: Colors.black,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    child: const Text(
                      "Continue as Guest",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

// ============================================================
// APPLICATION STEP
// ============================================================

class _Step extends StatelessWidget {
  final String number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,

          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),

          alignment: Alignment.center,

          child: Text(
            number,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

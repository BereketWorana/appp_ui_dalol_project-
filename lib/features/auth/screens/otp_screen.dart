import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/models/user.dart';

import '../../main/screens/main_screen.dart';
import '../../main/profile/upgrade/creator_application_screen.dart';
import '../../main/profile/upgrade/merchant_application_screen.dart';

import '../widgets/auth_button.dart';

class OtpScreen extends StatefulWidget {
  final String selectedRole;

  final String fullName;
  final String phone;
  final String email;
  final String password;

  const OtpScreen({
    super.key,
    required this.selectedRole,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  int seconds = 60;

  Timer? timer;

  bool verifying = false;

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  // ==========================================
  // OTP TIMER
  // ==========================================

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (seconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  // ==========================================
  // VERIFY OTP
  // ==========================================

  Future<void> verifyOTP() async {
    final otp = otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit OTP")),
      );

      return;
    }

    setState(() {
      verifying = true;
    });

    // ------------------------------------------
    // TEMPORARY OTP VERIFICATION
    //
    // Later this will call your backend.
    // ------------------------------------------

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // ==========================================
    // CREATE USER
    // ==========================================

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch,

      fullName: widget.fullName,

      phone: widget.phone,

      email: widget.email,

      password: widget.password,

      role: widget.selectedRole,

      profileImage: "assets/images/default_profile.jpg",

      coverImage: "assets/images/default_cover.jpg",
    );

    // ==========================================
    // SAVE LOGIN SESSION
    // ==========================================

    AuthService.login(user);

    setState(() {
      verifying = false;
    });

    // ==========================================
    // CONSUMER
    // ==========================================

    if (widget.selectedRole == "consumer") {
      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(builder: (_) => const ConsumerMainScreen()),

        (route) => false,
      );

      return;
    }

    // ==========================================
    // CREATOR
    // ==========================================

    if (widget.selectedRole == "creator") {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const CreatorApplicationScreen()),
      );

      return;
    }

    // ==========================================
    // HOTEL OWNER
    // ==========================================

    if (widget.selectedRole == "merchant") {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const MerchantApplicationScreen()),
      );

      return;
    }
  }

  // ==========================================
  // RESEND OTP
  // ==========================================

  void resendOTP() {
    setState(() {
      seconds = 60;
    });

    startTimer();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("OTP has been resent")));
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    timer?.cancel();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 40),

              // =================================
              // TITLE
              // =================================
              const Text(
                "Verify Phone",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Enter the 6 digit code sent to "
                "${widget.phone}",

                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 35),

              // =================================
              // OTP BOXES
              // =================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: List.generate(6, (index) => otpBox(index)),
              ),

              const SizedBox(height: 30),

              // =================================
              // VERIFY BUTTON
              // =================================
              verifying
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : AuthButton(text: "Verify", onPressed: verifyOTP),

              const SizedBox(height: 20),

              // =================================
              // RESEND
              // =================================
              Center(
                child: seconds > 0
                    ? Text(
                        "Resend code in "
                        "$seconds seconds",

                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      )
                    : TextButton(
                        onPressed: resendOTP,

                        child: const Text(
                          "Resend OTP",

                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),

              const Spacer(),

              // =================================
              // CHANGE PHONE
              // =================================
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text(
                    "Change phone number",

                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // OTP BOX
  // ==========================================

  Widget otpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,

      child: TextField(
        controller: otpControllers[index],

        keyboardType: TextInputType.number,

        maxLength: 1,

        textAlign: TextAlign.center,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),

        decoration: InputDecoration(
          counterText: "",

          filled: true,

          fillColor: Colors.white10,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),

            borderSide: const BorderSide(color: Colors.white24),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),

            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),

        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }

          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}

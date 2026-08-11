import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';

import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ============================================================
  // CONTROLLER
  // ============================================================

  final emailController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool loading = false;

  bool success = false;

  String? emailError;

  String? generalError;

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool validEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  // ============================================================
  // SEND RESET LINK
  // ============================================================

  Future<void> sendResetLink() async {
    if (loading) {
      return;
    }

    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    // ------------------------------------------------------------
    // CLEAR ERRORS
    // ------------------------------------------------------------

    setState(() {
      emailError = null;
      generalError = null;
    });

    // ------------------------------------------------------------
    // VALIDATE EMAIL
    // ------------------------------------------------------------

    if (email.isEmpty) {
      setState(() {
        emailError = "Email is required";
      });

      return;
    }

    if (!validEmail(email)) {
      setState(() {
        emailError = "Please enter a valid email address";
      });

      return;
    }

    // ------------------------------------------------------------
    // LOADING
    // ------------------------------------------------------------

    setState(() {
      loading = true;
    });

    try {
      final result = await AuthService.forgotPassword(email: email);

      if (!mounted) {
        return;
      }

      if (result["success"] != true) {
        setState(() {
          loading = false;
          generalError =
              result["message"]?.toString() ?? "Unable to send reset link.";
        });

        return;
      }

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      setState(() {
        loading = false;
        success = true;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        generalError = "Unable to connect to the server. Please try again.";
      });
    }
  }

  // ============================================================
  // BACK TO LOGIN
  // ============================================================

  void backToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // ERROR TEXT
  // ============================================================

  Widget errorText(String? error) {
    if (error == null || error.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 6),
      child: Text(
        error,
        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }

  // ============================================================
  // GENERAL ERROR
  // ============================================================

  Widget generalErrorBox() {
    if (generalError == null || generalError!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 19),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              generalError!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUCCESS MESSAGE
  // ============================================================

  Widget successBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.30)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 22),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              "If an account exists with this email, "
              "a password reset link has been sent. "
              "Please check your email.",
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 25),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // BACK BUTTON
              // ==================================================
              IconButton(
                onPressed: loading ? null : backToLogin,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // ICON
              // ==================================================
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.lock_reset,
                  color: Colors.black,
                  size: 34,
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // TITLE
              // ==================================================
              const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter the email address associated "
                "with your account and we'll send you "
                "a secure password reset link.",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SUCCESS
              // ==================================================
              if (success) ...[
                successBox(),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: backToLogin,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // ================================================
                // EMAIL
                // ================================================
                AuthTextField(
                  hint: "Email address",
                  icon: Icons.email_outlined,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                errorText(emailError),

                // ================================================
                // GENERAL ERROR
                // ================================================
                generalErrorBox(),

                const SizedBox(height: 20),

                // ================================================
                // SEND BUTTON
                // ================================================
                loading
                    ? const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: AuthButton(
                          text: "Send Reset Link",
                          onPressed: sendResetLink,
                        ),
                      ),
              ],

              const SizedBox(height: 30),

              // ==================================================
              // LOGIN
              // ==================================================
              Center(
                child: TextButton(
                  onPressed: loading ? null : backToLogin,
                  child: const Text(
                    "Back to Login",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }
}

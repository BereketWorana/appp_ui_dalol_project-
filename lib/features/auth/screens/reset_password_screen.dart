import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';

import '../widgets/auth_button.dart';

import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool loading = false;

  bool success = false;

  bool passwordVisible = false;

  bool confirmPasswordVisible = false;

  String? passwordError;

  String? confirmPasswordError;

  String? generalError;

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<void> resetPassword() async {
    if (loading) {
      return;
    }

    FocusScope.of(context).unfocus();

    final password = passwordController.text;

    final confirmPassword = confirmPasswordController.text;

    // ------------------------------------------------------------
    // CLEAR ERRORS
    // ------------------------------------------------------------

    setState(() {
      passwordError = null;
      confirmPasswordError = null;
      generalError = null;
    });

    bool hasError = false;

    // ============================================================
    // PASSWORD
    // ============================================================

    if (password.isEmpty) {
      passwordError = "New password is required";
      hasError = true;
    } else if (password.length < 6) {
      passwordError = "Password must be at least 6 characters";
      hasError = true;
    }

    // ============================================================
    // CONFIRM PASSWORD
    // ============================================================

    if (confirmPassword.isEmpty) {
      confirmPasswordError = "Please confirm your password";
      hasError = true;
    } else if (password != confirmPassword) {
      confirmPasswordError = "Passwords do not match";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    // ============================================================
    // LOADING
    // ============================================================

    setState(() {
      loading = true;
    });

    try {
      final result = await AuthService.resetPassword(
        token: widget.token,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      if (!mounted) {
        return;
      }

      // ==========================================================
      // FAILURE
      // ==========================================================

      if (result["success"] != true) {
        setState(() {
          loading = false;
          generalError =
              result["message"]?.toString() ?? "Unable to reset your password.";
        });

        return;
      }

      // ==========================================================
      // SUCCESS
      // ==========================================================

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
  // GO LOGIN
  // ============================================================

  void goToLogin() {
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
  // PASSWORD FIELD
  // ============================================================

  Widget passwordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: controller,

        enabled: !loading,

        obscureText: !visible,

        style: const TextStyle(color: Colors.white, fontSize: 16),

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: const TextStyle(color: Colors.white54),

          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),

          suffixIcon: IconButton(
            onPressed: loading ? null : onToggle,
            icon: Icon(
              visible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
          ),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // ============================================================
  // SUCCESS BOX
  // ============================================================

  Widget successBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.30)),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 48),

          SizedBox(height: 14),

          Text(
            "Password Reset Successfully",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Your password has been changed. "
            "You can now log in using your new password.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.45),
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
              // BACK
              // ==================================================
              IconButton(
                onPressed: loading ? null : goToLogin,
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
                "Reset Password",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Create a new password for your account.",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.4,
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
                    onPressed: goToLogin,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Go to Login",
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
                // NEW PASSWORD
                // ================================================
                passwordField(
                  controller: passwordController,
                  hint: "New Password",
                  visible: passwordVisible,
                  onToggle: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),

                errorText(passwordError),

                const SizedBox(height: 12),

                // ================================================
                // CONFIRM PASSWORD
                // ================================================
                passwordField(
                  controller: confirmPasswordController,
                  hint: "Confirm Password",
                  visible: confirmPasswordVisible,
                  onToggle: () {
                    setState(() {
                      confirmPasswordVisible = !confirmPasswordVisible;
                    });
                  },
                ),

                errorText(confirmPasswordError),

                // ================================================
                // SERVER ERROR
                // ================================================
                generalErrorBox(),

                const SizedBox(height: 20),

                // ================================================
                // RESET BUTTON
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
                          text: "Reset Password",
                          onPressed: resetPassword,
                        ),
                      ),
              ],

              const SizedBox(height: 30),

              // ==================================================
              // LOGIN
              // ==================================================
              Center(
                child: TextButton(
                  onPressed: loading ? null : goToLogin,
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
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}

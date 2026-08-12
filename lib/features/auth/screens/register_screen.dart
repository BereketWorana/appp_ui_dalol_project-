import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';

import '../../main/screens/main_screen.dart';
import '../../main/profile/upgrade/creator_application_screen.dart';
import '../../main/profile/upgrade/merchant_application_screen.dart';

import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_login_button.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String selectedRole;

  const RegisterScreen({super.key, required this.selectedRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool registering = false;

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  bool termsAccepted = false;

  // ============================================================
  // ERRORS
  // ============================================================

  String? nameError;
  String? phoneError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? termsError;

  String? generalError;

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool validEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  // ============================================================
  // PHONE VALIDATION
  // ============================================================

  bool validPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(cleaned);
  }

  // ============================================================
  // CLEAR ERRORS
  // ============================================================

  void clearErrors() {
    setState(() {
      nameError = null;
      phoneError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
      termsError = null;
      generalError = null;
    });
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> register() async {
    if (registering) return;

    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    setState(() {
      nameError = null;
      phoneError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
      termsError = null;
      generalError = null;
    });

    bool hasError = false;

    // ============================================================
    // NAME
    // ============================================================

    if (name.isEmpty) {
      nameError = "Full name is required";
      hasError = true;
    } else if (name.length < 2) {
      nameError = "Full name must be at least 2 characters";
      hasError = true;
    }

    // ============================================================
    // PHONE
    // ============================================================

    if (phone.isEmpty) {
      phoneError = "Phone number is required";
      hasError = true;
    } else if (!validPhone(phone)) {
      phoneError = "Please enter a valid phone number";
      hasError = true;
    }

    // ============================================================
    // EMAIL
    // ============================================================

    if (email.isEmpty) {
      emailError = "Email is required";
      hasError = true;
    } else if (!validEmail(email)) {
      emailError = "Please enter a valid email address";
      hasError = true;
    }

    // ============================================================
    // PASSWORD
    // ============================================================

    if (password.isEmpty) {
      passwordError = "Password is required";
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

    // ============================================================
    // TERMS
    // ============================================================

    if (!termsAccepted) {
      termsError = "You must accept the Terms & Conditions";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    // ============================================================
    // START REGISTERING
    // ============================================================

    setState(() {
      registering = true;
      generalError = null;
    });

    try {
      final result = await AuthService.register(
        fullName: name,
        email: email,
        phone: phone,
        password: password,
        role: widget.selectedRole,
        termsAccepted: termsAccepted,
      );

      if (!mounted) return;

      // ============================================================
      // REGISTRATION FAILED
      // ============================================================

      if (result["success"] != true) {
        setState(() {
          registering = false;

          generalError =
              result["message"]?.toString() ??
              "Registration failed. Please try again.";
        });

        return;
      }

      // ============================================================
      // REGISTRATION SUCCESS
      // ============================================================

      setState(() {
        registering = false;
      });

      final role = widget.selectedRole.toLowerCase();

      // ============================================================
      // MERCHANT
      // ============================================================

      if (role == "merchant") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MerchantApplicationScreen()),
        );

        return;
      }

      // ============================================================
      // CREATOR
      // ============================================================

      if (role == "creator" || role == "influencer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CreatorApplicationScreen()),
        );

        return;
      }

      // ============================================================
      // NORMAL CONSUMER
      // ============================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ConsumerMainScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        registering = false;

        generalError = "Unable to connect to the server. Please try again.";
      });
    }
  }

  // ============================================================
  // SOCIAL REGISTER
  // ============================================================

  void socialRegister(String provider) {
    setState(() {
      generalError = "$provider registration is not implemented yet.";
    });
  }

  // ============================================================
  // ROLE TITLE
  // ============================================================

  String get roleTitle {
    switch (widget.selectedRole) {
      case "creator":
      case "influencer":
        return "Creator Account";

      case "merchant":
        return "Hotel Owner Account";

      default:
        return "User Account";
    }
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  String get description {
    switch (widget.selectedRole) {
      case "creator":
      case "influencer":
        return "Create your account before applying as a creator.";

      case "merchant":
        return "Create your account before registering your hotel.";

      default:
        return "Create your account and start exploring Ethiopia.";
    }
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
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
          height: 1.3,
        ),
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
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 20),

              // ==================================================
              // BACK
              // ==================================================
              IconButton(
                onPressed: registering
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // TITLE
              // ==================================================
              Text(
                roleTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                description,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // NAME
              // ==================================================
              AuthTextField(
                hint: "Full name",
                icon: Icons.person_outline,
                controller: nameController,
              ),

              errorText(nameError),

              const SizedBox(height: 10),

              // ==================================================
              // PHONE
              // ==================================================
              AuthTextField(
                hint: "Phone number",
                icon: Icons.phone,
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),

              errorText(phoneError),

              const SizedBox(height: 10),

              // ==================================================
              // EMAIL
              // ==================================================
              AuthTextField(
                hint: "Email",
                icon: Icons.email_outlined,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              errorText(emailError),

              const SizedBox(height: 10),

              // ==================================================
              // PASSWORD
              // ==================================================
              _passwordField(
                controller: passwordController,
                hint: "Password",
                visible: passwordVisible,
                onToggle: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),

              errorText(passwordError),

              const SizedBox(height: 10),

              // ==================================================
              // CONFIRM PASSWORD
              // ==================================================
              _passwordField(
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

              // ==================================================
              // SERVER ERROR
              // ==================================================
              generalErrorBox(),

              const SizedBox(height: 15),

              // ==================================================
              // ROLE
              // ==================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_circle_outlined,
                      color: Colors.white70,
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      "Role",
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),

                    const Spacer(),

                    Text(
                      widget.selectedRole,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // TERMS
              // ==================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: termsAccepted,
                    activeColor: Colors.white,
                    checkColor: Colors.black,

                    onChanged: registering
                        ? null
                        : (value) {
                            setState(() {
                              termsAccepted = value ?? false;

                              if (termsAccepted) {
                                termsError = null;
                              }
                            });
                          },

                    side: const BorderSide(color: Colors.white54),
                  ),

                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "I agree to the Terms & Conditions and Privacy Policy.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (termsError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    termsError!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // ==================================================
              // REGISTER BUTTON
              // ==================================================
              registering
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
                        text: "Create Account",
                        onPressed: register,
                      ),
                    ),

              const SizedBox(height: 20),

              // ==================================================
              // OR
              // ==================================================
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white24)),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "OR",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),

                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // GOOGLE
              // ==================================================
              SocialLoginButton(
                text: "Continue with Google",
                image: "assets/logo/google.png",
                onPressed: registering
                    ? null
                    : () {
                        socialRegister("Google");
                      },
              ),

              const SizedBox(height: 12),

              // ==================================================
              // FACEBOOK
              // ==================================================
              SocialLoginButton(
                text: "Continue with Facebook",
                image: "assets/logo/facebook.png",
                onPressed: registering
                    ? null
                    : () {
                        socialRegister("Facebook");
                      },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // LOGIN
              // ==================================================
              Center(
                child: TextButton(
                  onPressed: registering
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },

                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.white, fontSize: 14),
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

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _passwordField({
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

        obscureText: !visible,

        enabled: !registering,

        style: const TextStyle(color: Colors.white, fontSize: 16),

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: const TextStyle(color: Colors.white54),

          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),

          suffixIcon: IconButton(
            onPressed: registering ? null : onToggle,
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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}

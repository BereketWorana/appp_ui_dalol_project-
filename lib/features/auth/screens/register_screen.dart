import 'package:flutter/material.dart';

import 'otp_screen.dart';

import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  final String selectedRole;

  const RegisterScreen({super.key, required this.selectedRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void register() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // ==========================
    // VALIDATION
    // ==========================

    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));

      return;
    }

    if (!email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email address")),
      );

      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );

      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));

      return;
    }

    // ==========================
    // GO TO NEXT STEP
    // ==========================

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          selectedRole: widget.selectedRole,
          fullName: name,
          phone: phone,
          email: email,
          password: password,
        ),
      ),
    );
  }

  void socialRegister(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$provider registration coming soon")),
    );
  }

  @override
  Widget build(BuildContext context) {
    String roleTitle;

    switch (widget.selectedRole) {
      case "creator":
        roleTitle = "Creator Account";

        break;

      case "merchant":
        roleTitle = "Hotel Owner Account";

        break;

      default:
        roleTitle = "Consumer Account";
    }

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 20),

              // BACK BUTTON
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                padding: EdgeInsets.zero,

                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const SizedBox(height: 15),

              // TITLE
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
                widget.selectedRole == "creator"
                    ? "Create your account before applying as a creator."
                    : widget.selectedRole == "merchant"
                    ? "Create your account before registering your hotel."
                    : "Create your account and start exploring Ethiopia.",

                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 25),

              // FULL NAME
              AuthTextField(
                hint: "Full name",
                icon: Icons.person_outline,
                controller: nameController,
              ),

              const SizedBox(height: 12),

              // PHONE
              AuthTextField(
                hint: "Phone number",
                icon: Icons.phone,
                controller: phoneController,
              ),

              const SizedBox(height: 12),

              // EMAIL
              AuthTextField(
                hint: "Email",
                icon: Icons.email_outlined,
                controller: emailController,
              ),

              const SizedBox(height: 12),

              // PASSWORD
              AuthTextField(
                hint: "Password",
                icon: Icons.lock_outline,
                controller: passwordController,
                obscure: true,
              ),

              const SizedBox(height: 12),

              // CONFIRM PASSWORD
              AuthTextField(
                hint: "Confirm Password",
                icon: Icons.lock,
                controller: confirmPasswordController,
                obscure: true,
              ),

              const SizedBox(height: 20),

              // CREATE ACCOUNT
              AuthButton(text: "Continue", onPressed: register),

              const SizedBox(height: 20),

              // DIVIDER
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

              // GOOGLE
              SocialLoginButton(
                text: "Continue with Google",
                image: "assets/logo/google.png",

                onPressed: () {
                  socialRegister("Google");
                },
              ),

              const SizedBox(height: 12),

              // FACEBOOK
              SocialLoginButton(
                text: "Continue with Facebook",
                image: "assets/logo/facebook.png",

                onPressed: () {
                  socialRegister("Facebook");
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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

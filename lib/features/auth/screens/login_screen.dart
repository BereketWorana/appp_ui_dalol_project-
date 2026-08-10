import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/services/user_service.dart';

import 'choose_role_screen.dart';

import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_login_button.dart';

import '../../main/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  /// When true, pressing the Android back button from Login
  /// will take the user to Home instead of closing the app.
  final bool returnToHome;

  const LoginScreen({super.key, this.returnToHome = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  // ==========================================
  // LOGIN
  // ==========================================

  Future<void> login() async {
    if (phoneController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your phone/email and password"),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    final user = await UserService.login(
      phoneController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone/email or password")),
      );

      return;
    }

    // ==========================================
    // SAVE LOGGED-IN USER
    // ==========================================

    AuthService.login(user);

    // ==========================================
    // ALL USERS GO TO HOME
    // ==========================================

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ConsumerMainScreen()),
      (route) => false,
    );
  }

  // ==========================================
  // SOCIAL LOGIN
  // ==========================================

  void socialLogin(String provider) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$provider login coming soon")));
  }

  // ==========================================
  // REGISTER
  // ==========================================

  void openRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChooseRoleScreen()),
    );
  }

  // ==========================================
  // GO HOME
  // ==========================================

  void goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ConsumerMainScreen()),
      (route) => false,
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.returnToHome,

      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.returnToHome) {
          goHome();
        }
      },

      child: Scaffold(
        backgroundColor: Colors.black,

        // Important:
        // Allows the screen to resize properly
        // when the keyboard opens.
        resizeToAvoidBottomInset: true,

        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                padding: const EdgeInsets.symmetric(horizontal: 28),

                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),

                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const SizedBox(height: 30),

                        // ==================================
                        // LOGO
                        // ==================================
                        Container(
                          width: 62,
                          height: 62,

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(19),
                          ),

                          child: const Icon(
                            Icons.travel_explore,
                            color: Colors.black,
                            size: 35,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================================
                        // TITLE
                        // ==================================
                        const Text(
                          "Welcome",

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Login to continue exploring Ethiopia",

                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),

                        const SizedBox(height: 28),

                        // ==================================
                        // PHONE / EMAIL
                        // ==================================
                        AuthTextField(
                          hint: "Phone number or Email",
                          icon: Icons.phone_android,
                          controller: phoneController,
                        ),

                        const SizedBox(height: 14),

                        // ==================================
                        // PASSWORD
                        // ==================================
                        AuthTextField(
                          hint: "Password",
                          icon: Icons.lock_outline,
                          controller: passwordController,
                          obscure: true,
                        ),

                        const SizedBox(height: 22),

                        // ==================================
                        // LOGIN BUTTON
                        // ==================================
                        loading
                            ? const Center(
                                child: SizedBox(
                                  height: 25,
                                  width: 25,

                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,

                                child: AuthButton(
                                  text: "Login",
                                  onPressed: login,
                                ),
                              ),

                        const SizedBox(height: 18),

                        // ==================================
                        // OR
                        // ==================================
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Colors.white24),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),

                              child: Text(
                                "OR",

                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            const Expanded(
                              child: Divider(color: Colors.white24),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ==================================
                        // GOOGLE
                        // ==================================
                        SocialLoginButton(
                          text: "Continue with Google",
                          image: "assets/logo/google.png",

                          onPressed: () {
                            socialLogin("Google");
                          },
                        ),

                        const SizedBox(height: 12),

                        // ==================================
                        // FACEBOOK
                        // ==================================
                        SocialLoginButton(
                          text: "Continue with Facebook",
                          image: "assets/logo/facebook.png",

                          onPressed: () {
                            socialLogin("Facebook");
                          },
                        ),

                        // Instead of Spacer(), use flexible
                        // empty space only when there is room.
                        const Spacer(),

                        // ==================================
                        // REGISTER
                        // ==================================
                        Center(
                          child: TextButton(
                            onPressed: openRegistration,

                            child: const Text(
                              "Don't have an account? Register",

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}

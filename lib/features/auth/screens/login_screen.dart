import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';

import 'choose_role_screen.dart';

import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_login_button.dart';

import '../../main/screens/main_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  /// When true, pressing the Android back button from Login
  /// will return the user to Home.
  final bool returnToHome;

  const LoginScreen({super.key, this.returnToHome = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool loading = false;
  bool rememberMe = false;

  // Inline error message
  String? loginError;

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    // Clear previous error.
    setState(() {
      loginError = null;
    });

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    if (username.isEmpty) {
      setState(() {
        loginError = "Email or phone number is required.";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        loginError = "Password is required.";
      });
      return;
    }

    if (loading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      loginError = null;
    });

    try {
      // ==========================================================
      // LOGIN THROUGH AUTH SERVICE
      // ==========================================================

      final result = await AuthService.login(
        phone: username,
        password: password,
        rememberMe: rememberMe,
      );

      if (!mounted) return;

      // ==========================================================
      // LOGIN FAILED
      // ==========================================================

      if (result["success"] != true) {
        setState(() {
          loading = false;
          loginError =
              result["message"]?.toString() ??
              "Invalid email/phone or password.";
        });

        return;
      }

      // ==========================================================
      // LOGIN SUCCESSFUL
      // ==========================================================

      setState(() {
        loading = false;
        loginError = null;
      });

      if (!mounted) return;

      // ==========================================================
      // GO TO HOME FEED
      // ==========================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ConsumerMainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        loginError = "Unable to connect to the server. Please try again.";
      });
    }
  }

  // ============================================================
  // SOCIAL LOGIN
  // ============================================================

  void socialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$provider sign-in coming soon!"),
        backgroundColor: const Color(0xFF323232),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  void forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  // ============================================================
  // CONTINUE AS GUEST
  // ============================================================

  void continueAsGuest() {
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ConsumerMainScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // OPEN REGISTRATION
  // ============================================================

  void openRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChooseRoleScreen()),
    );
  }

  // ============================================================
  // GO HOME
  // ============================================================

  void goHome() {
    if (!mounted) return;

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
      canPop: !widget.returnToHome,

      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.returnToHome) {
          goHome();
        }
      },

      child: Scaffold(
        backgroundColor: Colors.black,
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

                        // ==================================================
                        // LOGO
                        // ==================================================
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

                        // ==================================================
                        // TITLE
                        // ==================================================
                        const Text(
                          "Welcome Back",

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

                        // ==================================================
                        // EMAIL / PHONE
                        // ==================================================
                        AuthTextField(
                          hint: "Phone number or Email",
                          icon: Icons.phone_android,
                          controller: usernameController,
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // PASSWORD
                        // ==================================================
                        AuthTextField(
                          hint: "Password",
                          icon: Icons.lock_outline,
                          controller: passwordController,
                          obscure: true,
                        ),

                        const SizedBox(height: 10),

                        // ==================================================
                        // REMEMBER ME / FORGOT PASSWORD
                        // ==================================================
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,

                              activeColor: Colors.white,
                              checkColor: Colors.black,

                              side: const BorderSide(color: Colors.white54),

                              onChanged: loading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        rememberMe = value ?? false;
                                      });
                                    },
                            ),

                            const Text(
                              "Remember Me",

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),

                            const Spacer(),

                            TextButton(
                              onPressed: loading ? null : forgotPassword,

                              child: const Text(
                                "Forgot Password?",

                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ==================================================
                        // INLINE ERROR
                        // ==================================================
                        if (loginError != null) ...[
                          const SizedBox(height: 2),

                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),

                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.25),
                              ),
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                ),

                                const SizedBox(width: 9),

                                Expanded(
                                  child: Text(
                                    loginError!,

                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // ==================================================
                        // LOGIN BUTTON
                        // ==================================================
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

                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // GOOGLE
                        // ==================================================
                        SocialLoginButton(
                          text: "Continue with Google",

                          image: "assets/logo/google.png",

                          onPressed: loading
                              ? null
                              : () {
                                  socialLogin("Google");
                                },
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // FACEBOOK
                        // ==================================================
                        SocialLoginButton(
                          text: "Continue with Facebook",

                          image: "assets/logo/facebook.png",

                          onPressed: loading
                              ? null
                              : () {
                                  socialLogin("Facebook");
                                },
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // CONTINUE AS GUEST
                        // ==================================================
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: loading ? null : continueAsGuest,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              "Continue as Guest",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // ==================================================
                        // REGISTER
                        // ==================================================
                        Center(
                          child: TextButton(
                            onPressed: loading ? null : openRegistration,

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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}

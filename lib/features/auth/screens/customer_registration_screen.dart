import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../main/screens/main_screen.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() =>
      _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState
    extends State<CustomerRegistrationScreen> {
  // ============================================================
  // API
  // ============================================================

  static const String registerEndpoint =
      "https://booking.dalloltech.com/api/auth/register";

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
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
  String? emailError;
  String? phoneError;
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

    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned);
  }

  // ============================================================
  // CLEAR ERRORS
  // ============================================================

  void clearErrors() {
    nameError = null;
    emailError = null;
    phoneError = null;
    passwordError = null;
    confirmPasswordError = null;
    termsError = null;
    generalError = null;
  }

  // ============================================================
  // VALIDATE FORM
  // ============================================================

  bool validateForm() {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    clearErrors();

    bool hasError = false;

    // ==========================================================
    // FULL NAME
    // ==========================================================

    if (name.isEmpty || name.length < 2) {
      nameError = "Full Name is required";
      hasError = true;
    }

    // ==========================================================
    // EMAIL
    // ==========================================================

    if (email.isEmpty || !validEmail(email)) {
      emailError = "Please enter a valid email";
      hasError = true;
    }

    // ==========================================================
    // PHONE
    // ==========================================================

    if (phone.isEmpty || !validPhone(phone)) {
      phoneError = "Please enter a valid phone number";
      hasError = true;
    }

    // ==========================================================
    // PASSWORD
    // ==========================================================

    if (password.isEmpty || password.length < 6) {
      passwordError = "Password must be at least 6 characters";
      hasError = true;
    }

    // ==========================================================
    // CONFIRM PASSWORD
    // ==========================================================

    if (confirmPassword.isEmpty || password != confirmPassword) {
      confirmPasswordError = "Passwords do not match";
      hasError = true;
    }

    // ==========================================================
    // TERMS
    // ==========================================================

    if (!termsAccepted) {
      termsError = "You must accept Terms & Conditions";
      hasError = true;
    }

    setState(() {});

    return !hasError;
  }

  // ============================================================
  // REGISTER CUSTOMER
  // ============================================================

  Future<void> registerCustomer() async {
    if (registering) {
      return;
    }

    if (!validateForm()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final body = {
      "full_name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "password": passwordController.text,
      "confirm_password": confirmPasswordController.text,

      // Customer role
      "role": "consumer",

      // API requires 1 or true
      "terms_accepted": 1,
    };

    setState(() {
      registering = true;
      generalError = null;
    });

    try {
      debugPrint("==========================================");
      debugPrint("CUSTOMER REGISTRATION");
      debugPrint("POST: $registerEndpoint");
      debugPrint("BODY:");
      debugPrint(jsonEncode(body));
      debugPrint("==========================================");

      final response = await http
          .post(
            Uri.parse(registerEndpoint),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) {
        return;
      }

      debugPrint("==========================================");
      debugPrint("CUSTOMER REGISTRATION RESPONSE");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("==========================================");

      final result = parseApiResponse(response);

      // ========================================================
      // SUCCESS
      // ========================================================

      if (result["success"] == true) {
        setState(() {
          registering = false;
        });

        if (!mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ConsumerMainScreen()),
          (route) => false,
        );

        return;
      }

      // ========================================================
      // FAILED
      // ========================================================

      setState(() {
        registering = false;

        generalError =
            result["message"]?.toString() ??
            "Registration failed. Please check your information.";
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      debugPrint("CUSTOMER REGISTRATION ERROR: $e");

      setState(() {
        registering = false;
        generalError = getConnectionError(e);
      });
    }
  }

  // ============================================================
  // PARSE API RESPONSE
  // ============================================================

  Map<String, dynamic> parseApiResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyText = response.body.trim();

    // ==========================================================
    // EMPTY RESPONSE
    // ==========================================================

    if (bodyText.isEmpty) {
      return {
        "success": false,
        "message": "The server returned an empty response.",
      };
    }

    // ==========================================================
    // HTML RESPONSE
    // ==========================================================

    final contentType = response.headers["content-type"] ?? "";

    if (contentType.contains("text/html") ||
        bodyText.startsWith("<!DOCTYPE") ||
        bodyText.startsWith("<html") ||
        bodyText.startsWith("<")) {
      if (statusCode == 404) {
        return {
          "success": false,
          "message":
              "Registration service could not be found. Please check the API endpoint.",
        };
      }

      if (statusCode >= 500) {
        return {
          "success": false,
          "message":
              "The server is currently unavailable. Please try again later.",
        };
      }

      return {
        "success": false,
        "message": "Unable to process the registration request.",
      };
    }

    // ==========================================================
    // DECODE JSON
    // ==========================================================

    dynamic decoded;

    try {
      decoded = jsonDecode(bodyText);
    } catch (_) {
      return {
        "success": false,
        "message": "The server returned an invalid response.",
      };
    }

    if (decoded is! Map) {
      return {"success": false, "message": "Unexpected server response."};
    }

    final body = Map<String, dynamic>.from(decoded);

    // ==========================================================
    // SUCCESS
    // ==========================================================

    if (body["success"] == true && statusCode >= 200 && statusCode < 300) {
      return {
        "success": true,
        "message": body["message"]?.toString() ?? "Registration successful.",
        "data": body["data"],
      };
    }

    // ==========================================================
    // ERROR MESSAGE
    // ==========================================================

    String message = body["message"]?.toString() ?? "";

    // ==========================================================
    // VALIDATION ERRORS
    // ==========================================================

    final errors = body["errors"];

    if (errors is Map) {
      final errorMessages = <String>[];

      errors.forEach((key, value) {
        if (value is List) {
          for (final item in value) {
            errorMessages.add(item.toString());
          }
        } else {
          errorMessages.add(value.toString());
        }
      });

      if (errorMessages.isNotEmpty) {
        message = errorMessages.join("\n");
      }
    }

    // ==========================================================
    // 400 / 422
    // ==========================================================

    if (statusCode == 400 || statusCode == 422) {
      return {
        "success": false,
        "message": message.isNotEmpty
            ? message
            : "Some information is invalid. Please check your details.",
      };
    }

    // ==========================================================
    // 401
    // ==========================================================

    if (statusCode == 401) {
      return {
        "success": false,
        "message": message.isNotEmpty
            ? message
            : "Registration was not authorized.",
      };
    }

    // ==========================================================
    // 404
    // ==========================================================

    if (statusCode == 404) {
      return {
        "success": false,
        "message": "Registration service could not be found.",
      };
    }

    // ==========================================================
    // 500+
    // ==========================================================

    if (statusCode >= 500) {
      return {
        "success": false,
        "message":
            "The server is currently unavailable. Please try again later.",
      };
    }

    // ==========================================================
    // DEFAULT
    // ==========================================================

    return {
      "success": false,
      "message": message.isNotEmpty
          ? message
          : "Registration failed. Please try again.",
    };
  }

  // ============================================================
  // CONNECTION ERROR
  // ============================================================

  String getConnectionError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains("timeout")) {
      return "The server took too long to respond. Please try again.";
    }

    if (text.contains("socketexception") ||
        text.contains("failed host lookup") ||
        text.contains("connection refused") ||
        text.contains("network is unreachable")) {
      return "Unable to connect to the server. Please check your internet connection.";
    }

    return "Unable to connect to the server. Please try again.";
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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              generalError!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: registering
                ? null
                : () {
                    setState(() {
                      generalError = null;
                    });
                  },
            child: const Icon(Icons.close, color: Colors.redAccent, size: 18),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: controller,
        enabled: !registering,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 5,
          ),
        ),
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
        enabled: !registering,
        obscureText: !visible,
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget termsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: termsAccepted,
              activeColor: Colors.white,
              checkColor: Colors.black,
              side: const BorderSide(color: Colors.white54),
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
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 12, right: 4),
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
        if (termsError != null) errorText(termsError),
      ],
    );
  }

  // ============================================================
  // REGISTER BUTTON
  // ============================================================

  Widget registerButton() {
    if (registering) {
      return Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: registerCustomer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          "Create Account",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !registering,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

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

                const SizedBox(height: 18),

                // ==================================================
                // TITLE
                // ==================================================
                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  "Create a customer account and start exploring Ethiopia.",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // SERVER ERROR
                // ==================================================
                generalErrorBox(),

                // ==================================================
                // FULL NAME
                // ==================================================
                inputField(
                  controller: nameController,
                  hint: "Full name",
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ),

                errorText(nameError),

                const SizedBox(height: 11),

                // ==================================================
                // EMAIL
                // ==================================================
                inputField(
                  controller: emailController,
                  hint: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                errorText(emailError),

                const SizedBox(height: 11),

                // ==================================================
                // PHONE
                // ==================================================
                inputField(
                  controller: phoneController,
                  hint: "Phone number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),

                errorText(phoneError),

                const SizedBox(height: 11),

                // ==================================================
                // PASSWORD
                // ==================================================
                passwordField(
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

                const SizedBox(height: 11),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================
                passwordField(
                  controller: confirmPasswordController,
                  hint: "Confirm password",
                  visible: confirmPasswordVisible,
                  onToggle: () {
                    setState(() {
                      confirmPasswordVisible = !confirmPasswordVisible;
                    });
                  },
                ),

                errorText(confirmPasswordError),

                const SizedBox(height: 15),

                // ==================================================
                // TERMS
                // ==================================================
                termsSection(),

                const SizedBox(height: 20),

                // ==================================================
                // REGISTER
                // ==================================================
                registerButton(),

                const SizedBox(height: 22),

                // ==================================================
                // LOGIN
                // ==================================================
                Center(
                  child: TextButton(
                    onPressed: registering
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
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
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfluencerRegistrationScreen extends StatefulWidget {
  const InfluencerRegistrationScreen({super.key});

  @override
  State<InfluencerRegistrationScreen> createState() =>
      _InfluencerRegistrationScreenState();
}

class _InfluencerRegistrationScreenState
    extends State<InfluencerRegistrationScreen> {
  // ============================================================
  // API
  // ============================================================

  static const String registerEndpoint =
      "https://booking.dalloltech.com/api/influencer/register";

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final bioController = TextEditingController();

  final instagramController = TextEditingController();
  final youtubeController = TextEditingController();
  final tiktokController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool registering = false;

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  bool termsAccepted = false;

  String category = "Travel";

  String? generalError;

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<String> categories = const [
    "Travel",
    "Food",
    "Lifestyle",
    "Fashion",
    "Beauty",
    "Technology",
    "Other",
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    passwordController.dispose();
    confirmPasswordController.dispose();

    bioController.dispose();

    instagramController.dispose();
    youtubeController.dispose();
    tiktokController.dispose();

    super.dispose();
  }

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
  // URL VALIDATION
  // ============================================================

  bool validOptionalUrl(String value) {
    if (value.trim().isEmpty) {
      return true;
    }

    final uri = Uri.tryParse(value.trim());

    if (uri == null) {
      return false;
    }

    return uri.hasScheme &&
        (uri.scheme == "http" || uri.scheme == "https") &&
        uri.host.isNotEmpty;
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> registerInfluencer() async {
    if (registering) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      generalError = null;
    });

    // ==========================================================
    // VALUES
    // ==========================================================

    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final bio = bioController.text.trim();

    final instagram = instagramController.text.trim();
    final youtube = youtubeController.text.trim();
    final tiktok = tiktokController.text.trim();

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (fullName.isEmpty) {
      showError("Full name is required.");
      return;
    }

    if (fullName.length < 2) {
      showError("Full name must be at least 2 characters.");
      return;
    }

    if (fullName.length > 100) {
      showError("Full name must not exceed 100 characters.");
      return;
    }

    if (email.isEmpty) {
      showError("Email is required.");
      return;
    }

    if (!validEmail(email)) {
      showError("Please enter a valid email address.");
      return;
    }

    if (phone.isEmpty) {
      showError("Phone number is required.");
      return;
    }

    if (!validPhone(phone)) {
      showError("Phone number must contain 10 to 15 digits.");
      return;
    }

    if (password.isEmpty) {
      showError("Password is required.");
      return;
    }

    if (password.length < 6) {
      showError("Password must be at least 6 characters.");
      return;
    }

    if (confirmPassword.isEmpty) {
      showError("Please confirm your password.");
      return;
    }

    if (password != confirmPassword) {
      showError("Passwords do not match.");
      return;
    }

    if (bio.isEmpty) {
      showError("Bio is required.");
      return;
    }

    if (bio.length < 10) {
      showError("Bio must be at least 10 characters.");
      return;
    }

    if (category.isEmpty) {
      showError("Please select a category.");
      return;
    }

    // ==========================================================
    // OPTIONAL SOCIAL URLS
    // ==========================================================

    if (!validOptionalUrl(instagram)) {
      showError("Please enter a valid Instagram URL.");
      return;
    }

    if (!validOptionalUrl(youtube)) {
      showError("Please enter a valid YouTube URL.");
      return;
    }

    if (!validOptionalUrl(tiktok)) {
      showError("Please enter a valid TikTok URL.");
      return;
    }

    // ==========================================================
    // TERMS
    // ==========================================================

    if (!termsAccepted) {
      showError("You must accept the Terms & Conditions and Privacy Policy.");
      return;
    }

    // ==========================================================
    // REQUEST BODY
    //
    // IMPORTANT:
    // terms_accepted is sent as INTEGER 1.
    //
    // Optional social fields are only added when provided.
    // ==========================================================

    final Map<String, dynamic> body = {
      "full_name": fullName,
      "email": email,
      "phone": phone,
      "password": password,
      "confirm_password": confirmPassword,
      "bio": bio,
      "category": category,
      "terms_accepted": 1,
    };

    if (instagram.isNotEmpty) {
      body["instagram"] = instagram;
    }

    if (youtube.isNotEmpty) {
      body["youtube"] = youtube;
    }

    if (tiktok.isNotEmpty) {
      body["tiktok"] = tiktok;
    }

    // ==========================================================
    // DEBUG
    // ==========================================================

    debugPrint("==========================================");
    debugPrint("INFLUENCER REGISTRATION");
    debugPrint("Endpoint: $registerEndpoint");
    debugPrint("Request body:");
    debugPrint(jsonEncode(body));
    debugPrint("==========================================");

    setState(() {
      registering = true;
      generalError = null;
    });

    // ==========================================================
    // API REQUEST
    // ==========================================================

    try {
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

      final result = parseApiResponse(response);

      // ========================================================
      // SUCCESS
      // ========================================================

      if (result["success"] == true) {
        setState(() {
          registering = false;
        });

        final data = result["data"];

        final influencerId = data is Map ? data["influencer_id"] : null;

        final userId = data is Map ? data["user_id"] : null;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InfluencerPendingScreen(
              fullName: fullName,
              email: email,
              influencerId: influencerId,
              userId: userId,
            ),
          ),
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
            "Registration failed. Please try again.";
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        registering = false;
        generalError = getConnectionError(e);
      });
    }
  }

  // ============================================================
  // API RESPONSE
  // ============================================================

  Map<String, dynamic> parseApiResponse(http.Response response) {
    final statusCode = response.statusCode;

    final contentType = response.headers["content-type"] ?? "";

    // ==========================================================
    // HTML RESPONSE
    // ==========================================================

    if (contentType.contains("text/html") ||
        response.body.trimLeft().startsWith("<")) {
      if (statusCode == 404) {
        return {
          "success": false,
          "message": "The influencer registration service could not be found.",
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
        "message": "Unable to process the influencer registration request.",
      };
    }

    // ==========================================================
    // EMPTY RESPONSE
    // ==========================================================

    if (response.body.trim().isEmpty) {
      return {
        "success": false,
        "message": "The server returned an empty response.",
      };
    }

    // ==========================================================
    // JSON
    // ==========================================================

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
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
    // STATUS CODES
    // ==========================================================

    if (statusCode == 400 || statusCode == 422) {
      return {
        "success": false,
        "message": message.isNotEmpty
            ? message
            : "Some information is invalid. Please check your details.",
      };
    }

    if (statusCode == 401 || statusCode == 403) {
      return {
        "success": false,
        "message": "You are not authorized to complete this registration.",
      };
    }

    if (statusCode == 404) {
      return {
        "success": false,
        "message": "The influencer registration service could not be found.",
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
  // ERROR
  // ============================================================

  void showError(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      generalError = message;
    });
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

        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,

          leading: IconButton(
            onPressed: registering
                ? null
                : () {
                    Navigator.pop(context);
                  },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          title: const Text(
            "Influencer Registration",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),

          centerTitle: true,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

            padding: const EdgeInsets.fromLTRB(22, 15, 22, 30),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                title(),

                const SizedBox(height: 25),

                if (generalError != null) errorBox(),

                // ==================================================
                // PERSONAL INFORMATION
                // ==================================================
                sectionTitle(
                  "Personal Information",
                  "Enter your basic account information.",
                ),

                const SizedBox(height: 15),

                input(
                  controller: fullNameController,
                  label: "Full Name *",
                  icon: Icons.person_outline,
                  enabled: !registering,
                ),

                const SizedBox(height: 13),

                input(
                  controller: emailController,
                  label: "Email *",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !registering,
                ),

                const SizedBox(height: 13),

                input(
                  controller: phoneController,
                  label: "Phone Number *",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  enabled: !registering,
                ),

                const SizedBox(height: 25),

                // ==================================================
                // PASSWORD
                // ==================================================
                sectionTitle(
                  "Password",
                  "Create a secure password for your account.",
                ),

                const SizedBox(height: 15),

                passwordInput(
                  controller: passwordController,
                  label: "Password *",
                  visible: passwordVisible,
                  onToggle: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),

                const SizedBox(height: 13),

                passwordInput(
                  controller: confirmPasswordController,
                  label: "Confirm Password *",
                  visible: confirmPasswordVisible,
                  onToggle: () {
                    setState(() {
                      confirmPasswordVisible = !confirmPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 25),

                // ==================================================
                // INFLUENCER INFORMATION
                // ==================================================
                sectionTitle(
                  "Influencer Information",
                  "Tell us about your content and category.",
                ),

                const SizedBox(height: 15),

                input(
                  controller: bioController,
                  label: "Bio *",
                  icon: Icons.description_outlined,
                  maxLines: 5,
                  enabled: !registering,
                ),

                const SizedBox(height: 15),

                categoryDropdown(),

                const SizedBox(height: 25),

                // ==================================================
                // SOCIAL MEDIA
                // ==================================================
                sectionTitle(
                  "Social Media",
                  "Add your social profiles. These fields are optional.",
                ),

                const SizedBox(height: 15),

                input(
                  controller: instagramController,
                  label: "Instagram URL",
                  icon: Icons.camera_alt_outlined,
                  keyboardType: TextInputType.url,
                  enabled: !registering,
                ),

                const SizedBox(height: 13),

                input(
                  controller: youtubeController,
                  label: "YouTube URL",
                  icon: Icons.play_circle_outline,
                  keyboardType: TextInputType.url,
                  enabled: !registering,
                ),

                const SizedBox(height: 13),

                input(
                  controller: tiktokController,
                  label: "TikTok URL",
                  icon: Icons.music_note_outlined,
                  keyboardType: TextInputType.url,
                  enabled: !registering,
                ),

                const SizedBox(height: 25),

                // ==================================================
                // TERMS
                // ==================================================
                sectionTitle(
                  "Terms & Conditions",
                  "You must accept the terms to create your account.",
                ),

                const SizedBox(height: 10),

                termsBox(),

                const SizedBox(height: 25),

                // ==================================================
                // REGISTER BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: registering
                      ? Container(
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
                        )
                      : ElevatedButton(
                          onPressed: registerInfluencer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "Create Influencer Account",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // APPROVAL INFORMATION
                // ==================================================
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.white70),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "After registration, your influencer account will remain pending until it is reviewed and approved by an administrator.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Become an Influencer",
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 7),
        Text(
          "Create your influencer account and submit it for approval.",
          style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(String heading, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
    );
  }

  // ============================================================
  // PASSWORD INPUT
  // ============================================================

  Widget passwordInput({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      enabled: !registering,
      obscureText: !visible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          onPressed: registering ? null : onToggle,
          icon: Icon(
            visible ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY DROPDOWN
  // ============================================================

  Widget categoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: category,
          dropdownColor: Colors.black,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: categories.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: registering
              ? null
              : (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    category = value;
                  });
                },
        ),
      ),
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget termsBox() {
    return GestureDetector(
      onTap: registering
          ? null
          : () {
              setState(() {
                termsAccepted = !termsAccepted;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: termsAccepted ? Colors.white54 : Colors.white12,
          ),
        ),
        child: Row(
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
                      });
                    },
              side: const BorderSide(color: Colors.white54),
            ),
            const SizedBox(width: 5),
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
      ),
    );
  }

  // ============================================================
  // ERROR BOX
  // ============================================================

  Widget errorBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
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
                height: 1.35,
              ),
            ),
          ),
          IconButton(
            onPressed: registering
                ? null
                : () {
                    setState(() {
                      generalError = null;
                    });
                  },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// INFLUENCER PENDING SCREEN
// ================================================================

class InfluencerPendingScreen extends StatelessWidget {
  final String fullName;
  final String email;
  final dynamic influencerId;
  final dynamic userId;

  const InfluencerPendingScreen({
    super.key,
    required this.fullName,
    required this.email,
    this.influencerId,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top,
                    color: Colors.black,
                    size: 45,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Registration Submitted",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Thank you, $fullName.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Your influencer account has been successfully registered and is now pending admin approval.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Registered Email",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
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
                      "Continue",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

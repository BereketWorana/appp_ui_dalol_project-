import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'creator_pending_screen.dart';

class CreatorApplicationScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

  const CreatorApplicationScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  @override
  State<CreatorApplicationScreen> createState() =>
      _CreatorApplicationScreenState();
}

class _CreatorApplicationScreenState extends State<CreatorApplicationScreen> {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = "https://booking.dalloltech.com/api";

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController bioController = TextEditingController();

  final TextEditingController instagramController = TextEditingController();

  final TextEditingController youtubeController = TextEditingController();

  final TextEditingController tiktokController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool submitting = false;

  bool termsAccepted = false;

  String category = "Travel";

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
  // VALIDATE
  // ============================================================

  bool validate() {
    // ----------------------------------------------------------
    // BIO
    // ----------------------------------------------------------

    final bio = bioController.text.trim();

    if (bio.isEmpty) {
      showError("Please enter your biography.");
      return false;
    }

    if (bio.length < 10) {
      showError("Bio must be at least 10 characters.");
      return false;
    }

    // ----------------------------------------------------------
    // CATEGORY
    // ----------------------------------------------------------

    if (!categories.contains(category)) {
      showError("Please select a valid category.");
      return false;
    }

    // ----------------------------------------------------------
    // TERMS
    // ----------------------------------------------------------

    if (!termsAccepted) {
      showError("Please accept the Influencer Terms.");
      return false;
    }

    // ----------------------------------------------------------
    // PASSWORD
    // ----------------------------------------------------------

    if (widget.password != widget.confirmPassword) {
      showError("Passwords do not match.");
      return false;
    }

    return true;
  }

  // ============================================================
  // SUBMIT APPLICATION
  // ============================================================

  Future<void> submitApplication() async {
    if (submitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!validate()) {
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      // ========================================================
      // URL
      // ========================================================

      final uri = Uri.parse("$baseUrl/influencer/register");

      // ========================================================
      // BODY
      // ========================================================

      final body = {
        "full_name": widget.fullName.trim(),

        "email": widget.email.trim(),

        "phone": widget.phone.trim(),

        "password": widget.password,

        "confirm_password": widget.confirmPassword,

        "bio": bioController.text.trim(),

        "category": category,

        "terms_accepted": termsAccepted ? 1 : 0,

        // Optional fields
        "instagram": instagramController.text.trim(),

        "youtube": youtubeController.text.trim(),

        "tiktok": tiktokController.text.trim(),
      };

      // ========================================================
      // DEBUG
      // ========================================================

      debugPrint("============================================");

      debugPrint("INFLUENCER REGISTRATION REQUEST");

      debugPrint("URL: $uri");

      debugPrint("BODY: ${jsonEncode(body)}");

      debugPrint("============================================");

      // ========================================================
      // REQUEST
      // ========================================================

      final response = await http
          .post(
            uri,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) {
        return;
      }

      debugPrint("Influencer registration status: ${response.statusCode}");

      debugPrint("Influencer registration response: ${response.body}");

      // ========================================================
      // DECODE
      // ========================================================

      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (_) {
        responseData = null;
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData != null &&
          responseData["success"] == true) {
        setState(() {
          submitting = false;
        });

        // ------------------------------------------------------
        // API RESPONSE:
        //
        // {
        //   "success": true,
        //   "message": "...",
        //   "data": {
        //      "user_id": 24,
        //      "influencer_id": 9,
        //      "full_name": "...",
        //      "email": "...",
        //      "status": "pending"
        //   }
        // }
        // ------------------------------------------------------

        final data = responseData["data"];

        String fullName = widget.fullName;
        String email = widget.email;

        if (data is Map) {
          if (data["full_name"] != null) {
            fullName = data["full_name"].toString();
          }

          if (data["email"] != null) {
            email = data["email"].toString();
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CreatorPendingScreen(fullName: fullName, email: email),
          ),
        );

        return;
      }

      // ========================================================
      // ERROR
      // ========================================================

      final message = parseApiResponse(response.statusCode, response.body);

      setState(() {
        submitting = false;
      });

      showError(message);
    } on SocketException {
      if (!mounted) {
        return;
      }

      setState(() {
        submitting = false;
      });

      showError(
        "Unable to connect to the server. Please check your internet connection.",
      );
    } on HttpException {
      if (!mounted) {
        return;
      }

      setState(() {
        submitting = false;
      });

      showError("Unable to connect to the server. Please try again later.");
    } on FormatException {
      if (!mounted) {
        return;
      }

      setState(() {
        submitting = false;
      });

      showError("The server returned an invalid response.");
    } catch (e) {
      debugPrint("Influencer registration error: $e");

      if (!mounted) {
        return;
      }

      setState(() {
        submitting = false;
      });

      showError("Unable to complete registration. Please try again.");
    }
  }

  // ============================================================
  // PARSE API RESPONSE
  // ============================================================

  String parseApiResponse(int statusCode, String responseBody) {
    if (responseBody.trim().isEmpty) {
      if (statusCode >= 500) {
        return "Server error. Please try again later.";
      }

      return "Registration failed. Please try again.";
    }

    // ==========================================================
    // HTML RESPONSE
    // ==========================================================

    final lowerBody = responseBody.toLowerCase();

    if (lowerBody.contains("<html") ||
        lowerBody.contains("<!doctype") ||
        lowerBody.contains("<body") ||
        lowerBody.contains("</")) {
      if (statusCode >= 500) {
        return "The server is currently unavailable. Please try again later.";
      }

      return "Unable to connect to the registration service.";
    }

    // ==========================================================
    // JSON RESPONSE
    // ==========================================================

    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        // ------------------------------------------------------
        // MAIN MESSAGE
        // ------------------------------------------------------

        final message = decoded["message"];

        if (message is String && message.trim().isNotEmpty) {
          final errors = decoded["errors"];

          final extractedErrors = extractErrors(errors);

          if (extractedErrors.isNotEmpty) {
            return extractedErrors;
          }

          return message;
        }

        // ------------------------------------------------------
        // ERRORS
        // ------------------------------------------------------

        final errors = decoded["errors"];

        final errorMessage = extractErrors(errors);

        if (errorMessage.isNotEmpty) {
          return errorMessage;
        }

        // ------------------------------------------------------
        // ERROR
        // ------------------------------------------------------

        final error = decoded["error"];

        if (error is String && error.trim().isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // Invalid JSON
    }

    // ==========================================================
    // STATUS CODES
    // ==========================================================

    if (statusCode == 400) {
      return "Registration failed. Please check your information.";
    }

    if (statusCode == 409) {
      return "An account with this email or phone number already exists.";
    }

    if (statusCode == 422) {
      return "Some information is invalid or already registered. Please check your information.";
    }

    if (statusCode >= 500) {
      return "Server error. Please try again later.";
    }

    return "Influencer registration failed. Please try again.";
  }

  // ============================================================
  // EXTRACT VALIDATION ERRORS
  // ============================================================

  String extractErrors(dynamic errors) {
    if (errors == null) {
      return "";
    }

    if (errors is Map) {
      final messages = <String>[];

      errors.forEach((key, value) {
        if (value is String) {
          messages.add(value);
        } else if (value is List) {
          for (final item in value) {
            if (item is String) {
              messages.add(item);
            } else {
              messages.add(item.toString());
            }
          }
        } else if (value != null) {
          messages.add(value.toString());
        }
      });

      return messages.join("\n");
    }

    if (errors is String) {
      return errors;
    }

    if (errors is List) {
      return errors.map((e) => e.toString()).join("\n");
    }

    return "";
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget field(
    String hint,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: !submitting,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white30),
        ),
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Influencer Application",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // FORM
            // ==================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // TITLE
                    // ==================================================
                    const Text(
                      "Tell us about yourself",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Complete your influencer profile. Your application will be reviewed by our admin team.",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // BIO
                    // ==================================================
                    const Text(
                      "Biography",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    field(
                      "Tell us about yourself",
                      Icons.description_outlined,
                      bioController,
                      maxLines: 6,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Minimum 10 characters",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // CATEGORY
                    // ==================================================
                    const Text(
                      "Content Category",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: category,
                          isExpanded: true,
                          dropdownColor: const Color(0xff181818),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          items: categories
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: submitting
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
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // SOCIAL MEDIA
                    // ==================================================
                    const Text(
                      "Social Media",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Add your social media profiles. These fields are optional.",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),

                    const SizedBox(height: 16),

                    // INSTAGRAM
                    field(
                      "Instagram URL (optional)",
                      Icons.camera_alt_outlined,
                      instagramController,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 12),

                    // YOUTUBE
                    field(
                      "YouTube URL (optional)",
                      Icons.play_circle_outline,
                      youtubeController,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 12),

                    // TIKTOK
                    field(
                      "TikTok URL (optional)",
                      Icons.music_note,
                      tiktokController,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // TERMS
                    // ==================================================
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CheckboxListTile(
                        value: termsAccepted,
                        onChanged: submitting
                            ? null
                            : (value) {
                                setState(() {
                                  termsAccepted = value ?? false;
                                });
                              },
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "I agree to the Influencer Terms and confirm that the information provided is accurate.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ==================================================
                    // APPLICATION NOTE
                    // ==================================================
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white60,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "After submitting, your influencer account will remain pending until an administrator reviews and approves your application.",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // SUBMIT BUTTON
            // ==================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: submitting ? null : submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Submit Application",
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
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    bioController.dispose();
    instagramController.dispose();
    youtubeController.dispose();
    tiktokController.dispose();

    super.dispose();
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HotelOwnerRegisterScreen extends StatefulWidget {
  const HotelOwnerRegisterScreen({super.key});

  @override
  State<HotelOwnerRegisterScreen> createState() =>
      _HotelOwnerRegisterScreenState();
}

class _HotelOwnerRegisterScreenState extends State<HotelOwnerRegisterScreen> {
  // ============================================================
  // API
  // ============================================================

  static const String registerUrl =
      "https://booking.dalloltech.com/api/hotel/register";

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final hotelNameController = TextEditingController();
  final hotelAddressController = TextEditingController();
  final hotelCityController = TextEditingController();

  final hotelDescriptionController = TextEditingController();
  final hotelRegionController = TextEditingController();
  final hotelPhoneController = TextEditingController();
  final hotelEmailController = TextEditingController();

  final starRatingController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool registering = false;

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  bool termsAccepted = false;

  // ============================================================
  // AMENITIES
  // ============================================================

  final List<String> availableAmenities = [
    "WiFi",
    "Swimming Pool",
    "Restaurant",
    "Parking",
    "Bar",
    "Gym",
    "Spa",
    "Room Service",
    "Airport Shuttle",
    "Conference Room",
    "Laundry",
    "24 Hour Reception",
  ];

  final Set<String> selectedAmenities = {};

  // ============================================================
  // IMAGE URLS
  // ============================================================

  final List<TextEditingController> imageUrlControllers = [];

  // ============================================================
  // ERROR
  // ============================================================

  String? generalError;

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

    hotelNameController.dispose();
    hotelAddressController.dispose();
    hotelCityController.dispose();

    hotelDescriptionController.dispose();
    hotelRegionController.dispose();
    hotelPhoneController.dispose();
    hotelEmailController.dispose();

    starRatingController.dispose();

    for (final controller in imageUrlControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  // ============================================================
  // PHONE VALIDATION
  // ============================================================

  bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned);
  }

  // ============================================================
  // STAR RATING VALIDATION
  // ============================================================

  double? getStarRating() {
    final value = starRatingController.text.trim();

    if (value.isEmpty) {
      return null;
    }

    final rating = double.tryParse(value);

    return rating;
  }

  // ============================================================
  // VALIDATE
  // ============================================================

  bool validateForm() {
    setState(() {
      generalError = null;
    });

    // ----------------------------------------------------------
    // FULL NAME
    // ----------------------------------------------------------

    final fullName = fullNameController.text.trim();

    if (fullName.isEmpty) {
      showError("Full name is required.");
      return false;
    }

    if (fullName.length < 3) {
      showError("Full name must be at least 3 characters.");
      return false;
    }

    if (fullName.length > 100) {
      showError("Full name must not exceed 100 characters.");
      return false;
    }

    // ----------------------------------------------------------
    // EMAIL
    // ----------------------------------------------------------

    final email = emailController.text.trim();

    if (email.isEmpty) {
      showError("Email is required.");
      return false;
    }

    if (!isValidEmail(email)) {
      showError("Please enter a valid email address.");
      return false;
    }

    // ----------------------------------------------------------
    // PHONE
    // ----------------------------------------------------------

    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      showError("Phone number is required.");
      return false;
    }

    if (!isValidPhone(phone)) {
      showError("Phone number must contain between 10 and 15 digits.");
      return false;
    }

    // ----------------------------------------------------------
    // PASSWORD
    // ----------------------------------------------------------

    final password = passwordController.text;

    if (password.isEmpty) {
      showError("Password is required.");
      return false;
    }

    if (password.length < 6) {
      showError("Password must be at least 6 characters.");
      return false;
    }

    // ----------------------------------------------------------
    // CONFIRM PASSWORD
    // ----------------------------------------------------------

    final confirmPassword = confirmPasswordController.text;

    if (confirmPassword.isEmpty) {
      showError("Please confirm your password.");
      return false;
    }

    if (password != confirmPassword) {
      showError("Passwords do not match.");
      return false;
    }

    // ----------------------------------------------------------
    // HOTEL NAME
    // ----------------------------------------------------------

    final hotelName = hotelNameController.text.trim();

    if (hotelName.isEmpty) {
      showError("Hotel name is required.");
      return false;
    }

    if (hotelName.length < 3) {
      showError("Hotel name must be at least 3 characters.");
      return false;
    }

    if (hotelName.length > 255) {
      showError("Hotel name must not exceed 255 characters.");
      return false;
    }

    // ----------------------------------------------------------
    // HOTEL ADDRESS
    // ----------------------------------------------------------

    if (hotelAddressController.text.trim().isEmpty) {
      showError("Hotel address is required.");
      return false;
    }

    // ----------------------------------------------------------
    // HOTEL CITY
    // ----------------------------------------------------------

    if (hotelCityController.text.trim().isEmpty) {
      showError("Hotel city is required.");
      return false;
    }

    // ----------------------------------------------------------
    // OPTIONAL HOTEL EMAIL
    // ----------------------------------------------------------

    final hotelEmail = hotelEmailController.text.trim();

    if (hotelEmail.isNotEmpty && !isValidEmail(hotelEmail)) {
      showError("Please enter a valid hotel email address.");
      return false;
    }

    // ----------------------------------------------------------
    // OPTIONAL HOTEL PHONE
    // ----------------------------------------------------------

    final hotelPhone = hotelPhoneController.text.trim();

    if (hotelPhone.isNotEmpty && !isValidPhone(hotelPhone)) {
      showError("Hotel phone number must contain between 10 and 15 digits.");
      return false;
    }

    // ----------------------------------------------------------
    // STAR RATING
    // ----------------------------------------------------------

    final rating = getStarRating();

    if (starRatingController.text.trim().isNotEmpty) {
      if (rating == null) {
        showError("Please enter a valid star rating.");
        return false;
      }

      if (rating < 0 || rating > 5) {
        showError("Star rating must be between 0 and 5.");
        return false;
      }
    }

    // ----------------------------------------------------------
    // IMAGE URLS
    // ----------------------------------------------------------

    for (final controller in imageUrlControllers) {
      final url = controller.text.trim();

      if (url.isEmpty) {
        continue;
      }

      final uri = Uri.tryParse(url);

      if (uri == null ||
          !uri.hasScheme ||
          (uri.scheme != "http" && uri.scheme != "https")) {
        showError("Please enter valid image URLs.");
        return false;
      }
    }

    // ----------------------------------------------------------
    // TERMS
    // ----------------------------------------------------------

    if (!termsAccepted) {
      showError("You must accept the Terms & Conditions to continue.");
      return false;
    }

    return true;
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> registerHotelOwner() async {
    if (registering) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!validateForm()) {
      return;
    }

    setState(() {
      registering = true;
      generalError = null;
    });

    try {
      // ========================================================
      // BUILD PAYLOAD
      //
      // Required fields are always included.
      //
      // Optional fields are only included if the user provided
      // a value.
      // ========================================================

      final Map<String, dynamic> payload = {
        "full_name": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "password": passwordController.text,
        "confirm_password": confirmPasswordController.text,

        "hotel_name": hotelNameController.text.trim(),
        "hotel_address": hotelAddressController.text.trim(),
        "hotel_city": hotelCityController.text.trim(),

        // Required by API.
        "terms_accepted": 1,
      };

      // ========================================================
      // OPTIONAL DESCRIPTION
      // ========================================================

      final description = hotelDescriptionController.text.trim();

      if (description.isNotEmpty) {
        payload["hotel_description"] = description;
      }

      // ========================================================
      // OPTIONAL REGION
      // ========================================================

      final region = hotelRegionController.text.trim();

      if (region.isNotEmpty) {
        payload["hotel_region"] = region;
      }

      // ========================================================
      // OPTIONAL HOTEL PHONE
      // ========================================================

      final hotelPhone = hotelPhoneController.text.trim();

      if (hotelPhone.isNotEmpty) {
        payload["hotel_phone"] = hotelPhone;
      }

      // ========================================================
      // OPTIONAL HOTEL EMAIL
      // ========================================================

      final hotelEmail = hotelEmailController.text.trim();

      if (hotelEmail.isNotEmpty) {
        payload["hotel_email"] = hotelEmail;
      }

      // ========================================================
      // OPTIONAL STAR RATING
      //
      // Supports:
      //
      // 1
      // 2.5
      // 4
      // 4.5
      // 5
      // ========================================================

      final rating = getStarRating();

      if (rating != null) {
        payload["star_rating"] = rating;
      }

      // ========================================================
      // OPTIONAL AMENITIES
      // ========================================================

      if (selectedAmenities.isNotEmpty) {
        payload["amenities"] = selectedAmenities.toList();
      }

      // ========================================================
      // OPTIONAL IMAGE URLS
      // ========================================================

      final imageUrls = imageUrlControllers
          .map((controller) => controller.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (imageUrls.isNotEmpty) {
        payload["images"] = imageUrls;
      }

      // ========================================================
      // DEBUG
      // ========================================================

      debugPrint("========================================");
      debugPrint("HOTEL OWNER REGISTRATION");
      debugPrint("POST: $registerUrl");
      debugPrint("REQUEST:");
      debugPrint(jsonEncode(payload));
      debugPrint("========================================");

      // ========================================================
      // API REQUEST
      // ========================================================

      final response = await http
          .post(
            Uri.parse(registerUrl),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) {
        return;
      }

      final result = parseResponse(response);

      // ========================================================
      // SUCCESS
      // ========================================================

      if (result["success"] == true) {
        setState(() {
          registering = false;
        });

        await showSuccessDialog(result);

        return;
      }

      // ========================================================
      // FAILURE
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

      debugPrint("HOTEL REGISTRATION ERROR: $e");

      setState(() {
        registering = false;
        generalError = connectionError(e);
      });
    }
  }

  // ============================================================
  // PARSE RESPONSE
  // ============================================================

  Map<String, dynamic> parseResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      return {
        "success": false,
        "message": "The server returned an empty response.",
      };
    }

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

    if (body["success"] == true &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      return {
        "success": true,
        "message": body["message"]?.toString() ?? "Registration successful.",
        "data": body["data"],
      };
    }

    // ==========================================================
    // API VALIDATION ERRORS
    // ==========================================================

    String message = body["message"]?.toString() ?? "";

    final errors = body["errors"];

    if (errors is Map) {
      final messages = <String>[];

      errors.forEach((key, value) {
        if (value is List) {
          for (final item in value) {
            messages.add(item.toString());
          }
        } else {
          messages.add(value.toString());
        }
      });

      if (messages.isNotEmpty) {
        message = messages.join("\n");
      }
    }

    // ==========================================================
    // STATUS CODES
    // ==========================================================

    if (response.statusCode == 400 || response.statusCode == 422) {
      return {
        "success": false,
        "message": message.isNotEmpty
            ? message
            : "Some information is invalid. Please check your details.",
      };
    }

    if (response.statusCode == 409) {
      return {
        "success": false,
        "message": message.isNotEmpty
            ? message
            : "An account with this information already exists.",
      };
    }

    if (response.statusCode >= 500) {
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

  String connectionError(Object error) {
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
  // SUCCESS DIALOG
  // ============================================================

  Future<void> showSuccessDialog(Map<String, dynamic> result) async {
    final data = result["data"];

    String hotelId = "";

    if (data is Map && data["hotel_id"] != null) {
      hotelId = data["hotel_id"].toString();
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.greenAccent, size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Registration Successful",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            result["message"]?.toString() ??
                "Your hotel has been registered and is pending admin approval.",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HotelPendingScreen(
                      hotelName: hotelNameController.text.trim(),
                      hotelId: hotelId,
                    ),
                  ),
                );
              },
              child: const Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void showError(String message) {
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
            onPressed: registering ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            "Hotel Owner Registration",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title(
                  "Create Hotel Owner Account",
                  "Register yourself and your hotel.",
                ),

                const SizedBox(height: 25),

                if (generalError != null) errorBox(),

                // ==================================================
                // OWNER
                // ==================================================
                sectionTitle("Owner Information"),

                const SizedBox(height: 12),

                input(
                  controller: fullNameController,
                  label: "Full Name *",
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 14),

                input(
                  controller: emailController,
                  label: "Email *",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                input(
                  controller: phoneController,
                  label: "Phone *",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 14),

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

                const SizedBox(height: 14),

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

                const SizedBox(height: 28),

                // ==================================================
                // HOTEL
                // ==================================================
                sectionTitle("Hotel Information"),

                const SizedBox(height: 12),

                input(
                  controller: hotelNameController,
                  label: "Hotel Name *",
                  icon: Icons.hotel_outlined,
                ),

                const SizedBox(height: 14),

                input(
                  controller: hotelAddressController,
                  label: "Hotel Address *",
                  icon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 14),

                input(
                  controller: hotelCityController,
                  label: "Hotel City *",
                  icon: Icons.location_city_outlined,
                ),

                const SizedBox(height: 14),

                input(
                  controller: hotelRegionController,
                  label: "Hotel Region",
                  icon: Icons.map_outlined,
                ),

                const SizedBox(height: 14),

                input(
                  controller: hotelDescriptionController,
                  label: "Hotel Description",
                  icon: Icons.description_outlined,
                  maxLines: 5,
                ),

                const SizedBox(height: 14),

                input(
                  controller: hotelPhoneController,
                  label: "Hotel Phone",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 14),

                input(
                  controller: hotelEmailController,
                  label: "Hotel Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 28),

                // ==================================================
                // RATING
                // ==================================================
                sectionTitle("Star Rating"),

                const SizedBox(height: 6),

                const Text(
                  "Optional. Enter a value from 0 to 5, including decimals such as 4.5.",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 12),

                input(
                  controller: starRatingController,
                  label: "Star Rating",
                  icon: Icons.star_outline,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // AMENITIES
                // ==================================================
                sectionTitle("Amenities"),

                const SizedBox(height: 6),

                const Text(
                  "Optional. Select the amenities available at your hotel.",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 12),

                amenityGrid(),

                const SizedBox(height: 28),

                // ==================================================
                // IMAGE URLS
                // ==================================================
                sectionTitle("Hotel Images"),

                const SizedBox(height: 6),

                const Text(
                  "Optional. Add image URLs if your hotel images are already hosted online.",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 12),

                imageUrlFields(),

                const SizedBox(height: 28),

                // ==================================================
                // TERMS
                // ==================================================
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: termsAccepted
                          ? Colors.white24
                          : Colors.redAccent.withValues(alpha: 0.35),
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

                                  if (termsAccepted) {
                                    generalError = null;
                                  }
                                });
                              },
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            "I confirm that the information provided is correct and I agree to the Terms & Conditions and Privacy Policy.",
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

                const SizedBox(height: 22),

                // ==================================================
                // REGISTER BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: registering ? null : registerHotelOwner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white12,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: registering
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Register Hotel",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
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

  Widget title(String heading, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: !registering,
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
      ),
    );
  }

  // ============================================================
  // AMENITY GRID
  // ============================================================

  Widget amenityGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableAmenities.map((amenity) {
        final selected = selectedAmenities.contains(amenity);

        return GestureDetector(
          onTap: registering
              ? null
              : () {
                  setState(() {
                    if (selected) {
                      selectedAmenities.remove(amenity);
                    } else {
                      selectedAmenities.add(amenity);
                    }
                  });
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? Colors.white : Colors.white24,
              ),
            ),
            child: Text(
              amenity,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // IMAGE URL FIELDS
  // ============================================================

  Widget imageUrlFields() {
    return Column(
      children: [
        ...List.generate(imageUrlControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: input(
                    controller: imageUrlControllers[index],
                    label: "Image URL ${index + 1}",
                    icon: Icons.image_outlined,
                    keyboardType: TextInputType.url,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: registering
                      ? null
                      : () {
                          setState(() {
                            imageUrlControllers[index].dispose();

                            imageUrlControllers.removeAt(index);
                          });
                        },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 4),

        OutlinedButton.icon(
          onPressed: registering
              ? null
              : () {
                  setState(() {
                    imageUrlControllers.add(TextEditingController());
                  });
                },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Add Image URL",
            style: TextStyle(color: Colors.white),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
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
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
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
// HOTEL PENDING SCREEN
// ================================================================

class HotelPendingScreen extends StatelessWidget {
  final String hotelName;
  final String hotelId;

  const HotelPendingScreen({
    super.key,
    required this.hotelName,
    required this.hotelId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_top_rounded,
                  color: Colors.white,
                  size: 75,
                ),

                const SizedBox(height: 25),

                const Text(
                  "Hotel Pending Approval",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  hotelName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Your hotel registration has been submitted successfully. An administrator will review your hotel before it becomes available.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                if (hotelId.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Text(
                    "Hotel ID: $hotelId",
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
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

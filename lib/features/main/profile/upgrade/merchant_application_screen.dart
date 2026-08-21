import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'merchant_pending_screen.dart';

class MerchantApplicationScreen extends StatefulWidget {
  // ============================================================
  // USER REGISTRATION INFORMATION
  //
  // These values come directly from RegisterScreen.
  //
  // The hotel API uses the same email/phone to find and link
  // the hotel to the registered user.
  // ============================================================

  final String fullName;
  final String email;
  final String phone;
  final String password;

  const MerchantApplicationScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<MerchantApplicationScreen> createState() =>
      _MerchantApplicationScreenState();
}

class _MerchantApplicationScreenState extends State<MerchantApplicationScreen> {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = "https://booking.dalloltech.com/api";

  static const String registerHotelEndpoint = "$baseUrl/admin/hotels";

  // ============================================================
  // STEP
  // ============================================================

  int currentStep = 0;

  bool submitting = false;

  // ============================================================
  // HOTEL INFORMATION
  // ============================================================

  final hotelNameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final regionController = TextEditingController();
  final descriptionController = TextEditingController();

  // ============================================================
  // HOTEL DETAILS
  // ============================================================

  String hotelType = "Hotel";

  int starRating = 0;

  TimeOfDay checkInTime = const TimeOfDay(hour: 14, minute: 0);

  TimeOfDay checkOutTime = const TimeOfDay(hour: 11, minute: 0);

  final videoUrlController = TextEditingController();

  // ============================================================
  // AMENITIES
  // ============================================================

  final List<String> availableAmenities = [
    "WiFi",
    "Pool",
    "Restaurant",
    "Parking",
    "Bar",
    "Gym",
    "Spa",
    "Room Service",
    "Airport Shuttle",
  ];

  final Set<String> selectedAmenities = {};

  // ============================================================
  // ERROR
  // ============================================================

  String? generalError;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    hotelNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    regionController.dispose();
    descriptionController.dispose();
    videoUrlController.dispose();

    super.dispose();
  }

  // ============================================================
  // STEP 1 VALIDATION
  // ============================================================

  bool validateStepOne() {
    setState(() {
      generalError = null;
    });

    final name = hotelNameController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();

    if (name.isEmpty) {
      showError("Hotel name is required.");
      return false;
    }

    if (name.length < 3) {
      showError("Hotel name must be at least 3 characters.");
      return false;
    }

    if (address.isEmpty) {
      showError("Hotel address is required.");
      return false;
    }

    if (city.isEmpty) {
      showError("City is required.");
      return false;
    }

    return true;
  }

  // ============================================================
  // STEP 2 VALIDATION
  // ============================================================

  bool validateStepTwo() {
    setState(() {
      generalError = null;
    });

    if (selectedAmenities.isEmpty) {
      showError("Please select at least one amenity.");
      return false;
    }

    final video = videoUrlController.text.trim();

    if (video.isNotEmpty) {
      final uri = Uri.tryParse(video);

      if (uri == null ||
          !uri.hasScheme ||
          (uri.scheme != "http" && uri.scheme != "https")) {
        showError("Please enter a valid video URL.");
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // NEXT
  // ============================================================

  void nextStep() {
    if (submitting) return;

    if (currentStep == 0) {
      if (!validateStepOne()) return;

      setState(() {
        currentStep = 1;
      });

      return;
    }

    if (currentStep == 1) {
      if (!validateStepTwo()) return;

      setState(() {
        currentStep = 2;
      });

      return;
    }
  }

  // ============================================================
  // BACK
  // ============================================================

  void previousStep() {
    if (submitting) return;

    if (currentStep == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      currentStep--;
      generalError = null;
    });
  }

  // ============================================================
  // SUBMIT HOTEL
  // ============================================================

  Future<void> submitApplication() async {
    if (submitting) return;

    if (!validateStepOne()) {
      setState(() {
        currentStep = 0;
      });
      return;
    }

    if (!validateStepTwo()) {
      setState(() {
        currentStep = 1;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      submitting = true;
      generalError = null;
    });

    try {
      // ========================================================
      // IMPORTANT
      //
      // EMAIL AND PHONE COME FROM REGISTER SCREEN.
      //
      // DO NOT allow the hotel application to use different
      // credentials.
      // ========================================================

      final payload = {
        "name": hotelNameController.text.trim(),

        "address": addressController.text.trim(),

        "city": cityController.text.trim(),

        "phone": widget.phone,

        "email": widget.email,

        "type_id": hotelTypeToId(),

        "star_rating": starRating,

        "check_in_time": formatTime(checkInTime),

        "check_out_time": formatTime(checkOutTime),

        "amenities": selectedAmenities.toList(),

        // Optional fields supported by your previous API.
        "description": descriptionController.text.trim(),

        "region": regionController.text.trim(),

        "video_url": videoUrlController.text.trim(),
      };

      debugPrint("==========================================");

      debugPrint("HOTEL REGISTRATION");

      debugPrint("Registered user:");

      debugPrint("Full name: ${widget.fullName}");

      debugPrint("Email: ${widget.email}");

      debugPrint("Phone: ${widget.phone}");

      debugPrint("Hotel payload:");

      debugPrint(jsonEncode(payload));

      debugPrint("==========================================");

      final response = await http
          .post(
            Uri.parse(registerHotelEndpoint),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      final result = parseApiResponse(response);

      if (result["success"] == true) {
        setState(() {
          submitting = false;
        });

        // ======================================================
        // HOTEL CREATED
        // STATUS IS PENDING
        // ======================================================

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MerchantPendingScreen(
              hotelName: hotelNameController.text.trim(),
              hotelId: extractHotelId(result),
            ),
          ),
        );

        return;
      }

      setState(() {
        submitting = false;

        generalError =
            result["message"]?.toString() ??
            "Hotel registration failed. Please try again.";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        submitting = false;
        generalError = getConnectionError(e);
      });
    }
  }

  // ============================================================
  // EXTRACT HOTEL ID
  // ============================================================

  dynamic extractHotelId(Map<String, dynamic> result) {
    final data = result["data"];

    if (data is Map) {
      return data["id"];
    }

    return null;
  }

  // ============================================================
  // API RESPONSE
  // ============================================================

  Map<String, dynamic> parseApiResponse(http.Response response) {
    final statusCode = response.statusCode;

    final contentType = response.headers["content-type"] ?? "";

    // ==========================================================
    // HTML
    // ==========================================================

    if (contentType.contains("text/html") ||
        response.body.trimLeft().startsWith("<")) {
      if (statusCode == 404) {
        return {
          "success": false,
          "message": "The hotel registration service could not be found.",
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
        "message": "Unable to process the hotel registration request.",
      };
    }

    // ==========================================================
    // EMPTY
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

    final apiSuccess = body["success"] == true;

    if (apiSuccess && statusCode >= 200 && statusCode < 300) {
      return {
        "success": true,
        "message":
            body["message"]?.toString() ?? "Hotel registered successfully.",
        "data": body["data"],
      };
    }

    // ==========================================================
    // ERRORS
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
        "message": "The hotel registration service could not be found.",
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
          : "Hotel registration failed. Please try again.",
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
  // HOTEL TYPE
  // ============================================================

  int hotelTypeToId() {
    switch (hotelType) {
      case "Hotel":
        return 1;

      case "Resort":
        return 2;

      case "Guest House":
        return 3;

      default:
        return 1;
    }
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, "0");

    final minute = time.minute.toString().padLeft(2, "0");

    return "$hour:$minute:00";
  }

  // ============================================================
  // TIME PICKERS
  // ============================================================

  Future<void> selectCheckInTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: checkInTime,
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      checkInTime = selected;
    });
  }

  Future<void> selectCheckOutTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: checkOutTime,
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      checkOutTime = selected;
    });
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
      canPop: !submitting,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            onPressed: submitting ? null : previousStep,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            "Hotel Application",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                child: progressBar(),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 15, 22, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (generalError != null) errorBox(),

                      if (currentStep == 0) hotelInformationStep(),

                      if (currentStep == 1) hotelDetailsStep(),

                      if (currentStep == 2) reviewStep(),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
                child: bottomButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget progressBar() {
    return Row(
      children: [
        stepCircle("1", "Hotel", currentStep >= 0),

        Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            color: currentStep >= 1 ? Colors.white : Colors.white24,
          ),
        ),

        stepCircle("2", "Details", currentStep >= 1),

        Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            color: currentStep >= 2 ? Colors.white : Colors.white24,
          ),
        ),

        stepCircle("3", "Review", currentStep >= 2),
      ],
    );
  }

  Widget stepCircle(String number, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white12,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: active ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 1
  // ============================================================

  Widget hotelInformationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Hotel Information", "Tell us about your hotel."),

        const SizedBox(height: 25),

        input(
          controller: hotelNameController,
          label: "Hotel Name *",
          icon: Icons.hotel,
        ),

        const SizedBox(height: 15),

        input(
          controller: addressController,
          label: "Address *",
          icon: Icons.location_on_outlined,
        ),

        const SizedBox(height: 15),

        input(
          controller: cityController,
          label: "City *",
          icon: Icons.location_city,
        ),

        const SizedBox(height: 15),

        input(
          controller: regionController,
          label: "Region",
          icon: Icons.map_outlined,
        ),

        const SizedBox(height: 15),

        input(
          controller: descriptionController,
          label: "Description",
          icon: Icons.description_outlined,
          maxLines: 5,
        ),

        const SizedBox(height: 25),

        // ======================================================
        // REGISTERED ACCOUNT
        // ======================================================
        const Text(
          "Registered Account",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          "This hotel will be linked to the account you just created.",
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),

        const SizedBox(height: 15),

        registeredAccountField(
          icon: Icons.person_outline,
          label: "Account Name",
          value: widget.fullName,
        ),

        const SizedBox(height: 12),

        registeredAccountField(
          icon: Icons.phone_outlined,
          label: "Registered Phone",
          value: widget.phone,
        ),

        const SizedBox(height: 12),

        registeredAccountField(
          icon: Icons.email_outlined,
          label: "Registered Email",
          value: widget.email,
        ),
      ],
    );
  }

  // ============================================================
  // REGISTERED ACCOUNT FIELD
  // ============================================================

  Widget registeredAccountField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),

          const Icon(Icons.verified_outlined, color: Colors.white38, size: 20),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 2
  // ============================================================

  Widget hotelDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Hotel Details", "Add the details guests should know."),

        const SizedBox(height: 25),

        const Text(
          "Hotel Type",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),

        const SizedBox(height: 8),

        dropdown(),

        const SizedBox(height: 22),

        const Text(
          "Star Rating",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),

        const SizedBox(height: 8),

        starSelector(),

        const SizedBox(height: 22),

        timeField(
          title: "Check-in Time",
          time: checkInTime,
          onTap: selectCheckInTime,
        ),

        const SizedBox(height: 15),

        timeField(
          title: "Check-out Time",
          time: checkOutTime,
          onTap: selectCheckOutTime,
        ),

        const SizedBox(height: 25),

        const Text(
          "Amenities *",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          "Select at least one amenity.",
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),

        const SizedBox(height: 12),

        amenityGrid(),

        const SizedBox(height: 25),

        input(
          controller: videoUrlController,
          label: "Promotional Video URL",
          icon: Icons.video_library_outlined,
          keyboardType: TextInputType.url,
        ),

        const SizedBox(height: 8),

        const Text(
          "Optional. Example: https://youtube.com/watch?v=...",
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 3
  // ============================================================

  Widget reviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title(
          "Review Application",
          "Please check your information before submitting.",
        ),

        const SizedBox(height: 25),

        reviewSection("Hotel Information", [
          reviewRow("Hotel Name", hotelNameController.text),
          reviewRow("Address", addressController.text),
          reviewRow("City", cityController.text),
          reviewRow("Region", hotelValue(regionController.text)),
          reviewRow("Description", hotelValue(descriptionController.text)),
        ]),

        const SizedBox(height: 15),

        reviewSection("Account", [
          reviewRow("Name", widget.fullName),
          reviewRow("Phone", widget.phone),
          reviewRow("Email", widget.email),
        ]),

        const SizedBox(height: 15),

        reviewSection("Hotel Details", [
          reviewRow("Type", hotelType),
          reviewRow(
            "Star Rating",
            starRating == 0 ? "Not specified" : "$starRating stars",
          ),
          reviewRow("Check-in", formatTime(checkInTime)),
          reviewRow("Check-out", formatTime(checkOutTime)),
          reviewRow("Video URL", hotelValue(videoUrlController.text)),
        ]),

        const SizedBox(height: 15),

        reviewSection("Amenities", [
          reviewRow("Selected", selectedAmenities.join(", ")),
        ]),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.white70),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  "After submission, your hotel will remain pending until it is reviewed and approved by the administrator.",
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
      ],
    );
  }

  // ============================================================
  // REVIEW SECTION
  // ============================================================

  Widget reviewSection(String heading, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...children,
        ],
      ),
    );
  }

  Widget reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String hotelValue(String value) {
    return value.trim().isEmpty ? "Not provided" : value.trim();
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
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !submitting,
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
  // DROPDOWN
  // ============================================================

  Widget dropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: hotelType,
          dropdownColor: Colors.black,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: const [
            DropdownMenuItem(value: "Hotel", child: Text("Hotel")),
            DropdownMenuItem(value: "Resort", child: Text("Resort")),
            DropdownMenuItem(value: "Guest House", child: Text("Guest House")),
          ],
          onChanged: submitting
              ? null
              : (value) {
                  if (value == null) return;

                  setState(() {
                    hotelType = value;
                  });
                },
        ),
      ),
    );
  }

  // ============================================================
  // STAR SELECTOR
  // ============================================================

  Widget starSelector() {
    return Row(
      children: List.generate(5, (index) {
        final star = index + 1;

        return GestureDetector(
          onTap: submitting
              ? null
              : () {
                  setState(() {
                    starRating = star;
                  });
                },
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              star <= starRating ? Icons.star : Icons.star_border,
              color: Colors.white,
              size: 35,
            ),
          ),
        );
      }),
    );
  }

  // ============================================================
  // TIME FIELD
  // ============================================================

  Widget timeField({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: submitting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white70),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    time.format(context),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AMENITIES
  // ============================================================

  Widget amenityGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableAmenities.map((amenity) {
        final selected = selectedAmenities.contains(amenity);

        return GestureDetector(
          onTap: submitting
              ? null
              : () {
                  setState(() {
                    if (selected) {
                      selectedAmenities.remove(amenity);
                    } else {
                      selectedAmenities.add(amenity);
                    }

                    generalError = null;
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

  // ============================================================
  // BOTTOM BUTTON
  // ============================================================

  Widget bottomButton() {
    if (submitting) {
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
        onPressed: currentStep < 2 ? nextStep : submitApplication,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          currentStep == 0
              ? "Continue"
              : currentStep == 1
              ? "Review Application"
              : "Submit Application",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

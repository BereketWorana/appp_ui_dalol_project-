import 'package:flutter/material.dart';

import 'creator_pending_screen.dart';
import '../../../../core/services/upgrade_service.dart';

class CreatorApplicationScreen extends StatefulWidget {
  const CreatorApplicationScreen({super.key});

  @override
  State<CreatorApplicationScreen> createState() =>
      _CreatorApplicationScreenState();
}

class _CreatorApplicationScreenState extends State<CreatorApplicationScreen> {
  bool submitting = false;

  String? errorMessage;

  final bioController = TextEditingController();

  final phoneController = TextEditingController();

  String category = "Travel";

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> submitApplication() async {
    if (submitting) return;

    final bio = bioController.text.trim();
    final phone = phoneController.text.trim();

    if (bio.isEmpty) {
      showError("Please enter your creator bio.");
      return;
    }

    if (phone.isEmpty) {
      showError("Please enter your phone number.");
      return;
    }

    setState(() {
      submitting = true;
      errorMessage = null;
    });

    final result = await UpgradeService.registerCreator(
      bio: bio,
      category: category,
      phone: phone,
    );

    if (!mounted) return;

    if (result["success"] != true) {
      setState(() {
        submitting = false;

        errorMessage =
            result["message"]?.toString() ?? "Unable to submit application.";
      });

      return;
    }

    setState(() {
      submitting = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CreatorPendingScreen()),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void showError(String message) {
    setState(() {
      errorMessage = message;
    });
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

        automaticallyImplyLeading: !submitting,

        title: const Text(
          "Creator Application",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Become a Creator",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Tell us about yourself and your content. Your application will be reviewed by our team.",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              if (errorMessage != null) errorBox(),

              const SizedBox(height: 10),

              // ==================================================
              // CATEGORY
              // ==================================================
              const Text(
                "Content Category",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 8),

              categoryDropdown(),

              const SizedBox(height: 18),

              // ==================================================
              // PHONE
              // ==================================================
              field(
                "Phone number",
                Icons.phone,
                phoneController,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 18),

              // ==================================================
              // BIO
              // ==================================================
              field(
                "Tell us about your content",
                Icons.person_outline,
                bioController,
                maxLines: 6,
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SUBMIT
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: submitting ? null : submitApplication,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Submit Application",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
  // CATEGORY DROPDOWN
  // ============================================================

  Widget categoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),

      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(18),
      ),

      child: DropdownButton<String>(
        value: category,

        dropdownColor: Colors.black,

        underline: const SizedBox(),

        isExpanded: true,

        style: const TextStyle(color: Colors.white),

        items:
            [
                  "Travel",
                  "Hotels",
                  "Food",
                  "Lifestyle",
                  "Photography",
                  "Entertainment",
                  "Other",
                ]
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),

        onChanged: submitting
            ? null
            : (value) {
                if (value == null) return;

                setState(() {
                  category = value;
                });
              },
      ),
    );
  }

  // ============================================================
  // FIELD
  // ============================================================

  Widget field(
    String hint,
    IconData icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,

      enabled: !submitting,

      keyboardType: keyboardType,

      maxLines: maxLines,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(color: Colors.white54),

        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Icon(icon, color: Colors.white70),
        ),

        filled: true,

        fillColor: Colors.white12,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget errorBox() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: .1),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.redAccent.withValues(alpha: .35)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    bioController.dispose();
    phoneController.dispose();

    super.dispose();
  }
}

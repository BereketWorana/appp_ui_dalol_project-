import 'package:flutter/material.dart';

import 'merchant_pending_screen.dart';
import '../../../../core/services/upgrade_service.dart';

class MerchantApplicationScreen extends StatefulWidget {
  const MerchantApplicationScreen({super.key});

  @override
  State<MerchantApplicationScreen> createState() =>
      _MerchantApplicationScreenState();
}

class _MerchantApplicationScreenState extends State<MerchantApplicationScreen> {
  int currentStep = 0;

  bool submitting = false;

  String? errorMessage;

  final businessNameController = TextEditingController();

  final descriptionController = TextEditingController();

  final locationController = TextEditingController();

  final phoneController = TextEditingController();

  String businessType = "Hotel";

  // ============================================================
  // NEXT STEP
  // ============================================================

  void nextStep() {
    if (submitting) return;

    if (currentStep == 0) {
      if (!validateBusinessInfo()) {
        return;
      }

      setState(() {
        currentStep = 1;
        errorMessage = null;
      });

      return;
    }

    submitApplication();
  }

  // ============================================================
  // VALIDATE
  // ============================================================

  bool validateBusinessInfo() {
    if (businessNameController.text.trim().isEmpty) {
      showError("Business name is required.");
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      showError("Business description is required.");
      return false;
    }

    if (locationController.text.trim().isEmpty) {
      showError("Business location is required.");
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      showError("Business phone number is required.");
      return false;
    }

    return true;
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> submitApplication() async {
    if (submitting) return;

    setState(() {
      submitting = true;
      errorMessage = null;
    });

    final result = await UpgradeService.registerMerchant(
      businessName: businessNameController.text.trim(),
      businessType: businessType,
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      phone: phoneController.text.trim(),
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
      MaterialPageRoute(builder: (_) => const MerchantPendingScreen()),
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
          "Business Application",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),

        child: Column(
          children: [
            progressBar(),

            const SizedBox(height: 30),

            if (errorMessage != null) errorBox(),

            Expanded(child: currentStep == 0 ? businessInfo() : verification()),

            button(),
          ],
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
        stepCircle("1", currentStep >= 0),

        Expanded(
          child: Container(
            height: 3,
            color: currentStep >= 1 ? Colors.white : Colors.white24,
          ),
        ),

        stepCircle("2", currentStep >= 1),
      ],
    );
  }

  Widget stepCircle(String text, bool active) {
    return Container(
      width: 45,
      height: 45,

      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white12,
        shape: BoxShape.circle,
      ),

      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUSINESS INFO
  // ============================================================

  Widget businessInfo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Business Information",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          field("Business name", Icons.business, businessNameController),

          const SizedBox(height: 15),

          dropdown(),

          const SizedBox(height: 15),

          field(
            "Description",
            Icons.description,
            descriptionController,
            maxLines: 4,
          ),

          const SizedBox(height: 15),

          field("Location", Icons.location_on, locationController),

          const SizedBox(height: 15),

          field(
            "Phone number",
            Icons.phone,
            phoneController,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VERIFICATION
  // ============================================================

  Widget verification() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Verification",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Upload your verification documents.",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),

          const SizedBox(height: 25),

          uploadCard("Business License", Icons.description),

          const SizedBox(height: 15),

          uploadCard("Owner ID", Icons.badge),

          const SizedBox(height: 15),

          uploadCard("Business Images", Icons.image),
        ],
      ),
    );
  }

  // ============================================================
  // UPLOAD CARD
  // ============================================================

  Widget uploadCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          const Icon(Icons.add_circle_outline, color: Colors.white),
        ],
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
        color: Colors.white12,
        borderRadius: BorderRadius.circular(18),
      ),

      child: DropdownButton<String>(
        value: businessType,

        dropdownColor: Colors.black,

        underline: const SizedBox(),

        isExpanded: true,

        style: const TextStyle(color: Colors.white),

        items: [
          "Hotel",
          "Restaurant",
          "Event Place",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),

        onChanged: submitting
            ? null
            : (value) {
                if (value == null) return;

                setState(() {
                  businessType = value;
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

        prefixIcon: Icon(icon, color: Colors.white70),

        filled: true,

        fillColor: Colors.white12,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ============================================================
  // BUTTON
  // ============================================================

  Widget button() {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton(
        onPressed: submitting ? null : nextStep,

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
            : Text(
                currentStep == 0 ? "Continue" : "Submit Application",
                style: const TextStyle(fontWeight: FontWeight.bold),
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

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: .1),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.redAccent.withValues(alpha: .35)),
      ),

      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
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
    businessNameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    phoneController.dispose();

    super.dispose();
  }
}

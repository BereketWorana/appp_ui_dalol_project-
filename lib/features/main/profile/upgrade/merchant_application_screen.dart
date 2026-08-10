import 'package:flutter/material.dart';

import 'merchant_pending_screen.dart';

class MerchantApplicationScreen extends StatefulWidget {
  const MerchantApplicationScreen({super.key});

  @override
  State<MerchantApplicationScreen> createState() =>
      _MerchantApplicationScreenState();
}

class _MerchantApplicationScreenState extends State<MerchantApplicationScreen> {
  int currentStep = 0;

  final businessNameController = TextEditingController();

  final descriptionController = TextEditingController();

  final locationController = TextEditingController();

  final phoneController = TextEditingController();

  String businessType = "Hotel";

  void nextStep() {
    if (currentStep < 1) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (context) => const MerchantPendingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        elevation: 0,

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

            Expanded(child: currentStep == 0 ? businessInfo() : verification()),

            button(),
          ],
        ),
      ),
    );
  }

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

          field("Description", Icons.description, descriptionController),

          const SizedBox(height: 15),

          field("Location", Icons.location_on, locationController),

          const SizedBox(height: 15),

          field("Phone number", Icons.phone, phoneController),
        ],
      ),
    );
  }

  Widget verification() {
    return Column(
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

        const SizedBox(height: 25),

        uploadCard("Business License", Icons.description),

        const SizedBox(height: 15),

        uploadCard("Owner ID", Icons.badge),

        const SizedBox(height: 15),

        uploadCard("Business Images", Icons.image),
      ],
    );
  }

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

        onChanged: (v) {
          setState(() {
            businessType = v!;
          });
        },
      ),
    );
  }

  Widget field(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,

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

  Widget button() {
    return SizedBox(
      width: double.infinity,

      height: 55,

      child: ElevatedButton(
        onPressed: nextStep,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,

          foregroundColor: Colors.black,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: Text(
          currentStep == 0 ? "Continue" : "Submit Application",

          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

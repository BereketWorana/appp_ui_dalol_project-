import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
import '../../screens/main_screen.dart';

class CreatorApplicationScreen extends StatefulWidget {
  const CreatorApplicationScreen({super.key});

  @override
  State<CreatorApplicationScreen> createState() =>
      _CreatorApplicationScreenState();
}

class _CreatorApplicationScreenState extends State<CreatorApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;

  final displayNameController = TextEditingController();
  final bioController = TextEditingController();

  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final youtubeController = TextEditingController();
  final telegramController = TextEditingController();
  final tiktokController = TextEditingController();
  final websiteController = TextEditingController();

  final sampleVideoController = TextEditingController();

  String experience = "Beginner";

  final List<String> categories = [
    "Travel",
    "Hotels",
    "Food",
    "Lifestyle",
    "Technology",
    "Education",
    "Entertainment",
    "Photography",
    "Sports",
  ];

  final List<String> selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Become a Creator"),
        centerTitle: true,
      ),

      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: currentStep,
          type: StepperType.vertical,
          onStepContinue: () {
            if (currentStep < 3) {
              setState(() {
                currentStep++;
              });
            }
          },
          onStepCancel: () {
            if (currentStep > 0) {
              setState(() {
                currentStep--;
              });
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (currentStep != 3)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text("Next"),
                  ),

                const SizedBox(width: 10),

                if (currentStep != 0 && currentStep != 3)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Back"),
                  ),
              ],
            );
          },
          steps: [
            Step(
              isActive: currentStep >= 0,
              title: const Text("Personal Information"),
              content: Column(
                children: [
                  TextFormField(
                    initialValue: user.fullName,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    initialValue: user.email,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    initialValue: user.phone,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: "Phone"),
                  ),
                ],
              ),
            ),

            Step(
              isActive: currentStep >= 1,
              title: const Text("Creator Profile"),
              content: Column(
                children: [
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: "Display Name",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Display name is required";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: "Bio"),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Content Categories",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final selected = selectedCategories.contains(category);

                      return FilterChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Step(
              isActive: currentStep >= 2,
              title: const Text("Social Media"),
              content: Column(
                children: [
                  TextFormField(
                    controller: instagramController,
                    decoration: const InputDecoration(
                      labelText: "Instagram",
                      prefixIcon: Icon(Icons.camera_alt_outlined),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: tiktokController,
                    decoration: const InputDecoration(
                      labelText: "TikTok",
                      prefixIcon: Icon(Icons.music_note),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: facebookController,
                    decoration: const InputDecoration(
                      labelText: "Facebook",
                      prefixIcon: Icon(Icons.facebook),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: youtubeController,
                    decoration: const InputDecoration(
                      labelText: "YouTube",
                      prefixIcon: Icon(Icons.play_circle_outline),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: telegramController,
                    decoration: const InputDecoration(
                      labelText: "Telegram",
                      prefixIcon: Icon(Icons.send_outlined),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: websiteController,
                    decoration: const InputDecoration(
                      labelText: "Website (Optional)",
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                ],
              ),
            ),

            Step(
              isActive: currentStep >= 3,
              title: const Text("Review & Submit"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Experience",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  RadioListTile<String>(
                    value: "Beginner",
                    groupValue: experience,
                    onChanged: (value) {
                      setState(() {
                        experience = value!;
                      });
                    },
                    title: const Text("Beginner"),
                  ),

                  RadioListTile<String>(
                    value: "Intermediate",
                    groupValue: experience,
                    onChanged: (value) {
                      setState(() {
                        experience = value!;
                      });
                    },
                    title: const Text("Intermediate"),
                  ),

                  RadioListTile<String>(
                    value: "Professional",
                    groupValue: experience,
                    onChanged: (value) {
                      setState(() {
                        experience = value!;
                      });
                    },
                    title: const Text("Professional"),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: sampleVideoController,
                    decoration: const InputDecoration(
                      labelText: "Sample Video Link",
                      hintText: "https://youtube.com/...",
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "By submitting this application, you agree to follow the Creator Community Guidelines and Terms of Service.",
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Submit Application"),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Row(
                                children: [
                                  Icon(Icons.verified, color: Colors.green),
                                  SizedBox(width: 10),
                                  Text("Application Submitted"),
                                ],
                              ),
                              content: const Text(
                                "Thank you!\n\n"
                                "Your creator application has been submitted successfully.\n\n"
                                "Our team will review it and notify you once it has been approved.",
                              ),
                              actions: [
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ConsumerMainScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    displayNameController.dispose();
    bioController.dispose();

    instagramController.dispose();
    facebookController.dispose();
    youtubeController.dispose();
    telegramController.dispose();
    tiktokController.dispose();
    websiteController.dispose();

    sampleVideoController.dispose();

    super.dispose();
  }
}

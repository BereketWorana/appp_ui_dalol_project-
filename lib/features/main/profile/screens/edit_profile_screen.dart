import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();

  final phoneController = TextEditingController();

  final emailController = TextEditingController();

  File? profileFile;

  File? coverFile;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final user = AuthService.currentUser;

    nameController.text = user?.fullName ?? "";

    phoneController.text = user?.phone ?? "";

    emailController.text = user?.email ?? "";
  }

  Future<void> pickImage(bool profile) async {
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      if (profile) {
        profileFile = File(image.path);
      } else {
        coverFile = File(image.path);
      }
    });
  }

  void verifyEmail() {
    final otpController = TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff1B1B1B),

          title: const Text(
            "Verify Email",
            style: TextStyle(color: Colors.white),
          ),

          content: TextField(
            controller: otpController,

            keyboardType: TextInputType.number,

            style: const TextStyle(color: Colors.white),

            decoration: const InputDecoration(
              hintText: "Enter OTP",

              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Email verified")));
              },

              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: const Text("Edit Profile"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // COVER IMAGE
            GestureDetector(
              onTap: () {
                pickImage(false);
              },

              child: Container(
                height: 160,

                width: double.infinity,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  image: DecorationImage(
                    image: coverFile != null
                        ? FileImage(coverFile!)
                        : AssetImage(
                                AuthService.currentUser?.coverImage ??
                                    "assets/images/logo.png",
                              )
                              as ImageProvider,

                    fit: BoxFit.cover,
                  ),
                ),

                child: const Center(
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 35),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // PROFILE IMAGE
            GestureDetector(
              onTap: () {
                pickImage(true);
              },

              child: CircleAvatar(
                radius: 55,

                backgroundImage: profileFile != null
                    ? FileImage(profileFile!)
                    : AssetImage(
                            AuthService.currentUser?.profileImage ??
                                "assets/images/logo.png",
                          )
                          as ImageProvider,

                child: const Align(
                  alignment: Alignment.bottomRight,

                  child: CircleAvatar(
                    radius: 16,

                    backgroundColor: Colors.white,

                    child: Icon(
                      Icons.camera_alt,

                      size: 18,

                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            buildField("Full Name", nameController, Icons.person),

            buildField("Phone", phoneController, Icons.phone),

            TextField(
              controller: emailController,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                labelText: "Email",

                labelStyle: const TextStyle(color: Colors.white70),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.verified, color: Colors.green),

                  onPressed: verifyEmail,
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,

              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,

                  foregroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile saved")),
                  );

                  Navigator.pop(context);
                },

                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(
    String title,

    TextEditingController controller,

    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: TextField(
        controller: controller,

        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          labelText: title,

          labelStyle: const TextStyle(color: Colors.white70),

          prefixIcon: Icon(icon, color: Colors.white70),
        ),
      ),
    );
  }
}

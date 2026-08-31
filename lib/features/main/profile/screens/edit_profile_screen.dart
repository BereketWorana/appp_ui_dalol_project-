import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../data/services/user_service.dart';

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
  bool _isSaving = false;

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

  Future<void> _saveProfile() async {
    final user = AuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must be logged in to update your profile."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newName = nameController.text.trim();
    final newPhone = phoneController.text.trim();
    final newEmail = emailController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Full Name cannot be empty."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final Map<String, dynamic> changes = {};
    if (newName != user.fullName) {
      changes['full_name'] = newName;
    }
    if (newPhone != user.phone) {
      changes['phone'] = newPhone;
    }
    if (newEmail != user.email) {
      changes['email'] = newEmail;
    }

    final bool hasImageSelected = profileFile != null || coverFile != null;

    if (changes.isEmpty && !hasImageSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No changes to save."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      var updatedUser = user;

      // If text fields changed, update via API
      if (changes.isNotEmpty) {
        updatedUser = await UserService.updateUserProfile(
          userId: user.id,
          changes: changes,
        );
      }

      // Optimistically apply picked local image paths if present
      if (profileFile != null) {
        updatedUser = updatedUser.copyWith(profileImage: profileFile!.path);
      }
      if (coverFile != null) {
        updatedUser = updatedUser.copyWith(coverImage: coverFile!.path);
      }

      await AuthService.updateCurrentUser(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $msg"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // COVER IMAGE
            GestureDetector(
              onTap: () => pickImage(false),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: coverFile != null
                        ? FileImage(coverFile!) as ImageProvider
                        : (AuthService.currentUser?.coverImage != null &&
                                AuthService.currentUser!.coverImage.startsWith('/'))
                            ? FileImage(File(AuthService.currentUser!.coverImage))
                            : AssetImage(
                                AuthService.currentUser?.coverImage ??
                                    "assets/images/logo.png",
                              ) as ImageProvider,
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
              onTap: () => pickImage(true),
              child: CircleAvatar(
                radius: 55,
                backgroundImage: profileFile != null
                    ? FileImage(profileFile!) as ImageProvider
                    : (AuthService.currentUser?.profileImage != null &&
                            AuthService.currentUser!.profileImage.startsWith('/'))
                        ? FileImage(File(AuthService.currentUser!.profileImage))
                        : AssetImage(
                            AuthService.currentUser?.profileImage ??
                                "assets/images/logo.png",
                          ) as ImageProvider,
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
              enabled: !_isSaving,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(color: Colors.white70),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.verified, color: Colors.green),
                  onPressed: _isSaving ? null : verifyEmail,
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
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
        enabled: !_isSaving,
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

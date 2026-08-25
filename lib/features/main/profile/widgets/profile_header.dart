import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String coverImage;
  final String profileImage;
  final String name;
  final String email;

  final bool isLoggedIn;
  final bool isConsumer;

  final VoidCallback onLogin;
  final VoidCallback? onLogout;
  final VoidCallback? onUpgrade;

  const ProfileHeader({
    super.key,
    required this.coverImage,
    required this.profileImage,
    required this.name,
    required this.email,
    required this.isLoggedIn,
    required this.isConsumer,
    required this.onLogin,
    required this.onLogout,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: double.infinity,
              height: 150,
              child: Image.asset(coverImage, fit: BoxFit.cover),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: .40),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 20,
              bottom: -45,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage(profileImage),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 55),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isLoggedIn)
                SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    onPressed: onLogin,
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text("Login"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    if (isConsumer && onUpgrade != null)
                      SizedBox(
                        width: 120,
                        child: ElevatedButton.icon(
                          onPressed: onUpgrade,
                          icon: const Icon(Icons.workspace_premium, size: 18),
                          label: const Text("Upgrade"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                    if (isConsumer && onUpgrade != null) const SizedBox(height: 10),

                    if (onLogout != null)
                      SizedBox(
                        width: 120,
                        child: ElevatedButton.icon(
                          onPressed: onLogout,
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text("Logout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

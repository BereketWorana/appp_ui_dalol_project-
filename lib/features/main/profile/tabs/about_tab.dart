import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
import '../screens/edit_profile_screen.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          icon: Icons.person,
          color: Colors.blue,
          title: "Full Name",
          value: user?.fullName ?? "Guest User",
        ),

        const SizedBox(height: 12),

        _InfoCard(
          icon: Icons.email,
          color: Colors.orange,
          title: "Email",
          value: user?.email ?? "Not Available",
        ),

        const SizedBox(height: 12),

        _InfoCard(
          icon: Icons.phone,
          color: Colors.green,
          title: "Phone",
          value: user?.phone ?? "Not Available",
        ),

        const SizedBox(height: 12),

        _InfoCard(
          icon: Icons.badge,
          color: Colors.purple,
          title: "Account Type",
          value: (user?.role ?? "Guest").toUpperCase(),
        ),

        const SizedBox(height: 12),

        const _InfoCard(
          icon: Icons.location_on,
          color: Colors.red,
          title: "Location",
          value: "Addis Ababa, Ethiopia",
        ),

        const SizedBox(height: 35),

        if (user != null)
          Center(
            child: SizedBox(
              width: 220,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(height: 30),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

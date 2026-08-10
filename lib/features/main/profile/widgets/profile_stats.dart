import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------
    // Guest user
    // ---------------------------------------
    if (!AuthService.isLoggedIn) {
      return const SizedBox.shrink();
    }

    final role = AuthService.role;

    // ---------------------------------------
    // Consumer
    // Consumers don't have creator-style
    // followers/likes statistics.
    // ---------------------------------------
    if (role == "consumer") {
      return const SizedBox.shrink();
    }

    // ---------------------------------------
    // Creator / Merchant
    // ---------------------------------------
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: const [
          Expanded(
            child: _StatCard(
              icon: Icons.person_add_alt_1,
              title: "Following",
              value: "125",
              color: Color(0xFF2979FF),
            ),
          ),

          SizedBox(width: 8),

          Expanded(
            child: _StatCard(
              icon: Icons.people_alt_outlined,
              title: "Followers",
              value: "2.4K",
              color: Color(0xFF4CAF50),
            ),
          ),

          SizedBox(width: 8),

          Expanded(
            child: _StatCard(
              icon: Icons.favorite,
              title: "Likes",
              value: "15.8K",
              color: Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: .18),

            child: Icon(icon, color: color, size: 16),
          ),

          const Spacer(),

          FittedBox(
            fit: BoxFit.scaleDown,

            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 2),

          FittedBox(
            fit: BoxFit.scaleDown,

            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryChip({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white12,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.white24),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, color: Colors.white, size: 15),

          const SizedBox(width: 5),

          Text(
            title,

            style: const TextStyle(
              color: Colors.white,

              fontSize: 13,

              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

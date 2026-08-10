import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,

      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,

        children: const [
          CategoryButton(icon: Icons.grid_view, title: "All"),

          CategoryButton(icon: Icons.star, title: "Luxury"),

          CategoryButton(icon: Icons.pool, title: "Resort"),

          CategoryButton(icon: Icons.apartment, title: "Business"),

          CategoryButton(icon: Icons.attach_money, title: "Budget"),

          CategoryButton(icon: Icons.family_restroom, title: "Family"),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryButton({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),

      padding: const EdgeInsets.symmetric(horizontal: 18),

      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),

          const SizedBox(width: 8),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

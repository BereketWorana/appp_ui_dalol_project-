import 'package:flutter/material.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(Icons.hotel, color: Colors.white, size: 32),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  "Hotels",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {},

                icon: const Icon(Icons.notifications_none, color: Colors.white),
              ),

              IconButton(
                onPressed: () {},

                icon: const Icon(Icons.menu, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            "Hello,",
            style: TextStyle(color: Colors.white70, fontSize: 26),
          ),

          const Text(
            "Traveller",
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Find your perfect stay anywhere in Ethiopia.",
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TripKitContent extends StatelessWidget {
  const TripKitContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "✈️ My Trip Kit",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Everything you need for your journey",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildKitItem(
            "📋 Itinerary",
            "View your travel plan",
            Icons.list_alt,
          ),
          _buildKitItem(
            "🎫 Tickets",
            "Manage your bookings",
            Icons.confirmation_number,
          ),
          _buildKitItem("🧳 Packing List", "What to bring", Icons.checklist),
          _buildKitItem(
            "📍 Places to Visit",
            "Must-see attractions",
            Icons.location_on,
          ),
          _buildKitItem(
            "🍜 Food Guide",
            "Best local cuisine",
            Icons.restaurant,
          ),
          _buildKitItem("🚗 Transport", "Getting around", Icons.directions_car),
        ],
      ),
    );
  }

  Widget _buildKitItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
        ],
      ),
    );
  }
}

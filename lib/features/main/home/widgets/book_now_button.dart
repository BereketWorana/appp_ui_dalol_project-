import '../../../../data/models/user.dart';
import 'package:flutter/material.dart';

import '../../../../data/dummy/hotel_dummy.dart';
import '../../booking/screens/hotel_details_screen.dart';

class BookNowButton extends StatelessWidget {
  final int hotelId;

  const BookNowButton({
    super.key,
    required this.hotelId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          final hotel = hotels.firstWhere(
            (h) => h.id == hotelId, // Fallback if needed
          );

          Navigator.push(
            context,
            MaterialPageRoute(
             builder: (_) => HotelDetailScreen(hotel: hotel as dynamic),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hotel information is not available."),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade400, Colors.pink.shade600],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Book',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

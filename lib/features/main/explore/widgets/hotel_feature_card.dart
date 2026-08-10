import 'package:flutter/material.dart';

import '../../../../data/models/user.dart';
import '../../booking/screens/hotel_details_screen.dart';

class HotelFeatureCard extends StatelessWidget {
  final User hotel;

  const HotelFeatureCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,

      margin: const EdgeInsets.only(right: 18),

      height: 280,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),

        image: DecorationImage(
          image: AssetImage(hotel.coverImage),

          fit: BoxFit.cover,
        ),
      ),

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),

          gradient: LinearGradient(
            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisAlignment: MainAxisAlignment.end,

          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 18),

                SizedBox(width: 5),

                Text(
                  "4.9",

                  style: TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              hotel.fullName,

              style: const TextStyle(
                color: Colors.white,

                fontSize: 24,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Luxury hotel with premium rooms and excellent hospitality.",

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: 140,

              height: 42,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => HotelDetailScreen(hotel: hotel),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,

                  foregroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: const Text(
                  "Book Now",

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

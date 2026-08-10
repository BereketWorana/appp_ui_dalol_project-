import 'package:flutter/material.dart';

import '../../../../data/models/user.dart';
import '../../booking/screens/hotel_details_screen.dart';

class FeaturedHotelBanner extends StatelessWidget {
  final User hotel;

  const FeaturedHotelBanner({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),

        image: DecorationImage(
          image: AssetImage(hotel.coverImage),

          fit: BoxFit.cover,
        ),
      ),

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),

          gradient: LinearGradient(
            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [
              Colors.transparent,

              Colors.black.withValues(alpha: 0.35),

              Colors.black.withValues(alpha: 0.90),
            ],
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(22),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisAlignment: MainAxisAlignment.end,

            children: [
              const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),

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

              const SizedBox(height: 10),

              Text(
                hotel.fullName,

                style: const TextStyle(
                  color: Colors.white,

                  fontSize: 26,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Luxury hotel with premium rooms and excellent hospitality.",

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(color: Colors.white70, height: 1.4),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: 160,

                height: 48,

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
                      borderRadius: BorderRadius.circular(15),
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
      ),
    );
  }
}

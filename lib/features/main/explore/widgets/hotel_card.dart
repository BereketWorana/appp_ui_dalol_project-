import 'package:flutter/material.dart';

import '../../../../data/models/hotel.dart';
import '../../booking/screens/hotel_details_screen.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;

  const HotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,

      margin: const EdgeInsets.only(right: 18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),

            blurRadius: 12,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),

                  topRight: Radius.circular(22),
                ),

                child: Image.asset(
                  hotel.image,

                  height: 170,

                  width: double.infinity,

                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 12,

                right: 12,

                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,

                    shape: BoxShape.circle,
                  ),

                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite_border,

                      color: Colors.black,
                    ),

                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    hotel.name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),

                      SizedBox(width: 4),

                      Text("Addis Ababa", style: TextStyle(color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Luxury hotel with premium rooms and excellent hospitality.",

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(height: 1.3),
                  ),

                  const Spacer(),

                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),

                      SizedBox(width: 4),

                      Text(
                        "4.9",

                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Spacer(),

                      Text(
                        "From 4500 ETB",

                        style: TextStyle(
                          fontWeight: FontWeight.bold,

                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,

                    height: 44,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => HotelDetailScreen(hotel: hotel),
                          ),
                        );
                      },

                      child: const Text("View Hotel"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

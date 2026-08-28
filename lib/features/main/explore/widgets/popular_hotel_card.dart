import 'package:flutter/material.dart';

import '../../../../data/models/hotel.dart';

class PopularHotelCard extends StatelessWidget {
  final Hotel hotel;

  const PopularHotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 16),

      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),

            child: Image.asset(
              hotel.image,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  hotel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: const [
                    Icon(Icons.location_on, size: 15, color: Colors.white60),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Ethiopia",
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 16),

                    SizedBox(width: 4),

                    Text("4.9", style: TextStyle(color: Colors.white)),

                    Spacer(),

                    Text(
                      "From 4500 ETB",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

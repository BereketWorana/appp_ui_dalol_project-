import 'package:flutter/material.dart';

import '../../../../../data/models/room.dart';
import '../../../../../data/models/hotel.dart';

import '../screens/booking_information_screen.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  final Hotel hotel;

  const RoomCard({super.key, required this.room, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),

      decoration: BoxDecoration(
        color: const Color(0xFF181818),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white12),
      ),

      child: SizedBox(
        height: 155,

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // ==========================================
            // ROOM IMAGE
            // ==========================================
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),

              child: SizedBox(
                width: 125,

                child: Image.asset(room.image, fit: BoxFit.cover),
              ),
            ),

            // ==========================================
            // ROOM INFORMATION
            // ==========================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==================================
                    // ROOM TYPE
                    // ==================================
                    Text(
                      room.roomType,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // ==================================
                    // CAPACITY
                    // ==================================
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          color: Colors.white60,
                          size: 16,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          "${room.capacity} Guests",

                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    // ==================================
                    // FACILITIES
                    // ==================================
                    Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 4,

                        children: room.facilities
                            .take(2)
                            .map(
                              (item) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.white10,

                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: Text(
                                  item,

                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // ==================================
                    // PRICE + SELECT
                    // ==================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        // PRICE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "${room.pricePerNight} ETB",

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Text(
                              "per night",

                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),

                        // SELECT BUTTON
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => BookingInformationScreen(
                                  hotel: hotel,
                                  room: room,
                                ),
                              ),
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,

                            foregroundColor: Colors.black,

                            elevation: 0,

                            minimumSize: const Size(70, 34),

                            padding: const EdgeInsets.symmetric(horizontal: 12),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          child: const Text(
                            "Select",

                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

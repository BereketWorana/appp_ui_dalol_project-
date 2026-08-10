import 'package:flutter/material.dart';

import '../../../../data/models/video.dart';
import '../../../../data/dummy/user_dummy.dart';
import '../../booking/screens/hotel_details_screen.dart';

class Description extends StatelessWidget {
  final Video video;

  const Description({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // CHECK IF VIDEO SUPPORTS BOOKING
    // ==========================================

    final bool canBook =
        video.ownerType == "merchant" || video.ownerType == "creator";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // ==========================================
        // OWNER NAME + BOOK BUTTON
        // ==========================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      video.ownerName,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Verified badge for merchants
                  if (video.ownerType == "merchant")
                    const Padding(
                      padding: EdgeInsets.only(left: 5),

                      child: Icon(Icons.verified, color: Colors.blue, size: 18),
                    ),
                ],
              ),
            ),

            // ==========================================
            // BOOK BUTTON
            // Creator + Merchant
            // ==========================================
            if (canBook)
              ElevatedButton(
                onPressed: () {
                  try {
                    final hotel = users.firstWhere(
                      (user) => user.id == video.ownerId,
                    );

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => HotelDetailScreen(hotel: hotel),
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

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,

                  foregroundColor: Colors.black,

                  elevation: 2,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 8,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),

                child: const Text(
                  "Book",

                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // ==========================================
        // VIDEO DESCRIPTION
        // ==========================================
        const SizedBox(height: 6),

        Text(
          video.description,

          maxLines: 2,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

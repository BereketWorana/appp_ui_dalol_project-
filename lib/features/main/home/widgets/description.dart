import 'package:flutter/material.dart';

import '../../../../data/models/post.dart';
import 'book_now_button.dart';

class Description extends StatelessWidget {
  final Post post;

  const Description({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // CHECK IF POST SUPPORTS BOOKING
    // ==========================================

    final bool canBook = post.hasHotelLink;

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
                      post.ownerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Verified badge for merchants
                  if (post.isMerchant)
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(Icons.verified, color: Colors.blue, size: 18),
                    ),
                ],
              ),
            ),

            // ==========================================
            // BOOK BUTTON
            // ==========================================
            if (canBook)
              BookNowButton(hotelId: post.hotelId ?? post.ownerId),
          ],
        ),

        const SizedBox(height: 8),

        // ==========================================
        // POST DESCRIPTION
        // ==========================================
        const SizedBox(height: 6),

        Text(
          post.caption,
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

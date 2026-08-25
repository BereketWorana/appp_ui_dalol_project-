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

        const SizedBox(height: 6),

        // ==========================================
        // LOCATION · RATING · PRICE ROW
        // ==========================================
        if (post.location != null || post.rating != null || post.price != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 4,
              children: [
                // Location
                if (post.location != null && post.location!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        post.location!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                // Rating
                if (post.rating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        post.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                // Price
                if (post.price != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.payments_outlined, color: Colors.white70, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        'ETB ${post.price!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

        // ==========================================
        // CAPTION
        // ==========================================
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

        // ==========================================
        // HASHTAGS
        // ==========================================
        if (post.hashtags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: post.hashtags
                  .map((t) => Text(
                        '#$t',
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

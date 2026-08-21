import 'package:flutter/material.dart';

import '../../../../data/models/video.dart';

class Description extends StatelessWidget {
  final Video video;

  const Description({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ======================================================
        // USER NAME + BOOK BUTTON
        // ======================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==================================================
            // USER NAME
            // ==================================================
            Expanded(
              child: Text(
                video.ownerName.isNotEmpty ? video.ownerName : "Unknown User",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BOOK BUTTON
            // ==================================================
            //
            // IMPORTANT:
            // The button is ALWAYS visible now.
            //
            // We are NOT checking:
            // hotelId
            // ownerType
            // user role
            //
            // Every post gets a Book button.
            // ==================================================
            const SizedBox(width: 10),

            ElevatedButton(
              onPressed: () {
                // For now we display the hotel ID.
                //
                // Next we can connect this directly to the
                // hotel details/booking API.

                if (video.hotelId != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Opening hotel ID ${video.hotelId}"),
                    ),
                  );
                } else {
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
                  horizontal: 20,
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

        const SizedBox(height: 6),

        // ======================================================
        // TITLE
        // ======================================================
        if (video.title.isNotEmpty)
          Text(
            video.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

        // ======================================================
        // DESCRIPTION
        // ======================================================
        if (video.description.isNotEmpty) ...[
          const SizedBox(height: 4),

          Text(
            video.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],

        // ======================================================
        // HOTEL
        // ======================================================
        if (video.hotelName != null && video.hotelName!.isNotEmpty) ...[
          const SizedBox(height: 6),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hotel, color: Colors.white, size: 16),

              const SizedBox(width: 5),

              Flexible(
                child: Text(
                  video.hotelName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (video.hotelCity != null && video.hotelCity!.isNotEmpty) ...[
                const SizedBox(width: 5),

                Text(
                  "• ${video.hotelCity}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ],
          ),
        ],

        // ======================================================
        // HASHTAGS
        // ======================================================
        if (video.hashtags.isNotEmpty) ...[
          const SizedBox(height: 5),

          Text(
            video.hashtags
                .map((tag) => tag.startsWith("#") ? tag : "#$tag")
                .join(" "),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

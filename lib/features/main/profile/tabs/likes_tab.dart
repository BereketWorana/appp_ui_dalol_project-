import 'package:flutter/material.dart';

class LikesTab extends StatelessWidget {
  const LikesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary liked videos.
    // Later we will replace this with videos loaded
    // from the backend/database.

    final likedVideos = [
      "assets/images/r11.jpg",
      "assets/images/r11.jpg",
      "assets/images/r11.jpg",
      "assets/images/r11.jpg",
      "assets/images/r11.jpg",
      "assets/images/r11.jpg",
    ];

    if (likedVideos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, color: Colors.white38, size: 55),

            SizedBox(height: 15),

            Text(
              "No liked videos yet",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),

            SizedBox(height: 5),

            Text(
              "Videos you like will appear here",
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),

      itemCount: likedVideos.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,

        crossAxisSpacing: 8,

        mainAxisSpacing: 8,

        childAspectRatio: 0.72,
      ),

      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Later:
            // Open the selected liked video.
          },

          child: Stack(
            fit: StackFit.expand,

            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),

                child: Image.asset(likedVideos[index], fit: BoxFit.cover),
              ),

              // Dark gradient at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 55,

                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
              ),

              // Like icon
              const Positioned(
                left: 8,
                bottom: 7,

                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 17),

                    SizedBox(width: 5),

                    Text(
                      "Liked",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

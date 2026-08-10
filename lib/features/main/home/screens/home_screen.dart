import 'package:flutter/material.dart';

import '../../../../data/models/video.dart';
import '../../../../data/services/video_service.dart';

import '../widgets/hotel_feed_item.dart';
import 'menu_screen.dart';
import 'notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Video>>(
        future: VideoService.getVideos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final videos = snapshot.data!;

          if (videos.isEmpty) {
            return const Center(
              child: Text(
                "No videos available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              /// Video Feed
              PageView.builder(
                scrollDirection: Axis.vertical,
                controller: controller,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return HotelFeedItem(video: videos[index]);
                },
              ),

              /// Top Buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .35),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MenuScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .35),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

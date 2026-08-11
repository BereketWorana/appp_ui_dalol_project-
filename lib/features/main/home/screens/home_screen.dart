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

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  // ============================================================
  // PAGE CONTROLLER
  // ============================================================

  late final PageController pageController;

  // ============================================================
  // VIDEOS
  // ============================================================

  List<Video> videos = [];

  bool loading = true;

  String? error;

  // ============================================================
  // CURRENT VIDEO
  // ============================================================

  int currentIndex = 0;

  // ============================================================
  // KEEP HOME ALIVE
  // ============================================================

  @override
  bool get wantKeepAlive => true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: 0);

    loadVideos();
  }

  // ============================================================
  // LOAD VIDEOS
  // ============================================================

  Future<void> loadVideos() async {
    try {
      final result = await VideoService.getVideos();

      if (!mounted) return;

      setState(() {
        videos = result;
        loading = false;
      });
    } catch (e) {
      debugPrint('Video loading error: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
        error = "Unable to load videos.";
      });
    }
  }

  // ============================================================
  // PAGE CHANGED
  // ============================================================

  void onPageChanged(int index) {
    if (!mounted) return;

    setState(() {
      currentIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.black,

      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : error != null
          ? Center(
              child: Text(error!, style: const TextStyle(color: Colors.white)),
            )
          : videos.isEmpty
          ? const Center(
              child: Text(
                "No videos available",
                style: TextStyle(color: Colors.white),
              ),
            )
          : Stack(
              children: [
                // ==================================================
                // VIDEO FEED
                // ==================================================
                PageView.builder(
                  controller: pageController,

                  scrollDirection: Axis.vertical,

                  // TikTok-style page snapping.
                  physics: const PageScrollPhysics(),

                  itemCount: videos.length,

                  onPageChanged: onPageChanged,

                  itemBuilder: (context, index) {
                    return HotelFeedItem(
                      key: ValueKey(videos[index].id),

                      video: videos[index],

                      isActive: index == currentIndex,
                    );
                  },
                ),

                // ==================================================
                // TOP BUTTONS
                // ==================================================
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        // ==========================================
                        // MENU
                        // ==========================================
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

                        // ==========================================
                        // NOTIFICATIONS
                        // ==========================================
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
                                  builder: (_) => const NotificationScreen(),
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
            ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }
}

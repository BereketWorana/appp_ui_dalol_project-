import 'package:flutter/material.dart';

import '../../../../data/models/video.dart';
import '../../../../data/services/video_service.dart';

import '../widgets/vedio_feed.dart';
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

  List<Video> videos = <Video>[];

  bool loading = true;

  String? error;

  // ============================================================
  // CURRENT VIDEO
  // ============================================================

  int currentIndex = 0;

  // ============================================================
  // KEEP SCREEN ALIVE
  // ============================================================

  @override
  bool get wantKeepAlive => true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    pageController = PageController();

    loadVideos();
  }

  // ============================================================
  // LOAD VIDEOS
  // ============================================================

  Future<void> loadVideos() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final result = await VideoService.getVideos(
        userId: 24,
        limit: 20,
        offset: 0,
        accessToken: "YOUR_REAL_ACCESS_TOKEN",
      );

      if (!mounted) return;

      setState(() {
        videos = result;
        loading = false;
        currentIndex = 0;
      });
    } catch (e) {
      debugPrint("================================");
      debugPrint("VIDEO FEED ERROR");
      debugPrint(e.toString());
      debugPrint("================================");

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

    return Scaffold(backgroundColor: Colors.black, body: _buildBody());
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 50),

              const SizedBox(height: 15),

              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: loadVideos, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.video_library_outlined,
              color: Colors.white54,
              size: 60,
            ),

            const SizedBox(height: 15),

            const Text(
              "No videos available",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: loadVideos, child: const Text("Refresh")),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // FEED
    // ----------------------------------------------------------

    return Stack(
      children: [
        // ========================================================
        // VERTICAL VIDEO FEED
        // ========================================================
        PageView.builder(
          controller: pageController,

          scrollDirection: Axis.vertical,

          physics: const PageScrollPhysics(),

          itemCount: videos.length,

          onPageChanged: onPageChanged,

          itemBuilder: (context, index) {
            final Video video = videos[index];

            return HotelFeedItem(
              key: ValueKey(video.id),

              video: video,

              isActive: index == currentIndex,
            );
          },
        ),

        // ========================================================
        // TOP BUTTONS
        // ========================================================
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ==================================================
                // MENU
                // ==================================================
                _topButton(
                  icon: Icons.menu,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MenuScreen()),
                    );
                  },
                ),

                // ==================================================
                // NOTIFICATIONS
                // ==================================================
                _topButton(
                  icon: Icons.notifications_none,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TOP BUTTON
  // ============================================================

  Widget _topButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .35),
        shape: BoxShape.circle,
      ),

      child: IconButton(
        icon: Icon(icon, color: Colors.white),

        onPressed: onPressed,
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

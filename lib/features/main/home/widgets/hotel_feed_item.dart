import 'package:flutter/material.dart';

import '../../../../data/models/video.dart';

import 'hotel_video_player.dart';
import 'right_actions.dart';
import 'description.dart';

class HotelFeedItem extends StatefulWidget {
  final Video video;

  final bool isActive;

  const HotelFeedItem({super.key, required this.video, required this.isActive});

  @override
  State<HotelFeedItem> createState() => _HotelFeedItemState();
}

class _HotelFeedItemState extends State<HotelFeedItem>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // VIDEO KEY
  // ============================================================

  final GlobalKey<HotelVideoPlayerState> videoKey =
      GlobalKey<HotelVideoPlayerState>();

  // ============================================================
  // HEART
  // ============================================================

  bool showHeart = false;

  late AnimationController heartController;

  late Animation<double> heartScale;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    heartController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 350),
    );

    heartScale = Tween<double>(begin: .5, end: 1.2).animate(
      CurvedAnimation(parent: heartController, curve: Curves.easeOutBack),
    );
  }

  // ============================================================
  // SINGLE TAP
  // ============================================================

  void onTapVideo() {
    videoKey.currentState?.togglePlayPause();
  }

  // ============================================================
  // DOUBLE TAP
  // ============================================================

  Future<void> onDoubleTap() async {
    if (!mounted) return;

    // ----------------------------------------------------------
    // LIKE
    // ----------------------------------------------------------

    setState(() {
      showHeart = true;
    });

    heartController.forward(from: 0);

    // ----------------------------------------------------------
    // Keep video playing after double tap.
    //
    // This makes the interaction feel like TikTok:
    // double tap = like, not pause.
    // ----------------------------------------------------------

    videoKey.currentState?.playIfPaused();

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    await heartController.reverse();

    if (!mounted) return;

    setState(() {
      showHeart = false;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // --------------------------------------------------------
      // SINGLE TAP
      // --------------------------------------------------------
      onTap: onTapVideo,

      // --------------------------------------------------------
      // DOUBLE TAP
      // --------------------------------------------------------
      onDoubleTap: onDoubleTap,

      child: Stack(
        fit: StackFit.expand,

        children: [
          // ====================================================
          // VIDEO
          // ====================================================
          HotelVideoPlayer(
            key: videoKey,

            video: widget.video.video,

            isActive: widget.isActive,
          ),

          // ====================================================
          // GRADIENT
          // ====================================================
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,

                  end: Alignment.bottomCenter,

                  stops: const [.45, .75, 1],

                  colors: [
                    Colors.transparent,

                    Colors.black.withValues(alpha: .4),

                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // ====================================================
          // BIG HEART
          // ====================================================
          if (showHeart)
            IgnorePointer(
              child: Center(
                child: ScaleTransition(
                  scale: heartScale,

                  child: const Icon(
                    Icons.favorite,

                    color: Colors.white,

                    size: 120,
                  ),
                ),
              ),
            ),

          // ====================================================
          // RIGHT ACTIONS
          // ====================================================
          Positioned(
            right: 15,

            bottom: 40,

            child: RightActions(video: widget.video),
          ),

          // ====================================================
          // DESCRIPTION
          // ====================================================
          Positioned(
            left: 20,

            right: 100,

            bottom: 20,

            child: Description(video: widget.video),
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
    heartController.dispose();

    super.dispose();
  }
}

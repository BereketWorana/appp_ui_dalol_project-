import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HotelVideoPlayer extends StatefulWidget {
  final String video;
  final bool isActive;

  const HotelVideoPlayer({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<HotelVideoPlayer> createState() => HotelVideoPlayerState();
}

class HotelVideoPlayerState extends State<HotelVideoPlayer> {
  // ============================================================
  // VIDEO CONTROLLER
  // ============================================================

  late VideoPlayerController controller;

  // ============================================================
  // STATE
  // ============================================================

  bool initialized = false;

  // ============================================================
  // PLAY / PAUSE ICON
  // ============================================================

  bool showControlIcon = false;

  IconData controlIcon = Icons.pause;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.asset(widget.video);

    initializeVideo();
  }

  // ============================================================
  // INITIALIZE VIDEO
  // ============================================================

  Future<void> initializeVideo() async {
    try {
      await controller.initialize();

      if (!mounted) return;

      await controller.setLooping(true);

      setState(() {
        initialized = true;
      });

      // --------------------------------------------------------
      // ONLY ACTIVE VIDEO PLAYS
      // --------------------------------------------------------

      if (widget.isActive) {
        await controller.play();
      }
    } catch (e) {
      debugPrint("Video initialization error: $e");

      if (!mounted) return;

      setState(() {
        initialized = false;
      });
    }
  }

  // ============================================================
  // ACTIVE VIDEO CHANGED
  // ============================================================

  @override
  void didUpdateWidget(covariant HotelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!initialized) return;

    // ----------------------------------------------------------
    // VIDEO BECAME ACTIVE
    // ----------------------------------------------------------

    if (widget.isActive && !oldWidget.isActive) {
      controller.play();
    }

    // ----------------------------------------------------------
    // VIDEO BECAME INACTIVE
    // ----------------------------------------------------------

    if (!widget.isActive && oldWidget.isActive) {
      controller.pause();

      if (mounted) {
        setState(() {
          showControlIcon = false;
        });
      }
    }
  }

  // ============================================================
  // TOGGLE PLAY / PAUSE
  // ============================================================

  void togglePlayPause() {
    if (!initialized) return;

    // ----------------------------------------------------------
    // PLAYING → PAUSE
    // ----------------------------------------------------------

    if (controller.value.isPlaying) {
      controller.pause();

      _showControlIcon(Icons.pause);

      return;
    }

    // ----------------------------------------------------------
    // PAUSED → PLAY
    // ----------------------------------------------------------

    controller.play();

    _showControlIcon(Icons.play_arrow);
  }

  // ============================================================
  // PLAY IF PAUSED
  // ============================================================

  void playIfPaused() {
    if (!initialized) return;

    if (!controller.value.isPlaying) {
      controller.play();
    }
  }

  // ============================================================
  // SHOW PLAY / PAUSE ICON
  // ============================================================

  void _showControlIcon(IconData icon) {
    if (!mounted) return;

    setState(() {
      controlIcon = icon;
      showControlIcon = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      setState(() {
        showControlIcon = false;
      });
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // LOADING
    // ==========================================================

    if (!initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    // ==========================================================
    // VIDEO
    // ==========================================================

    return Stack(
      alignment: Alignment.center,

      children: [
        // ======================================================
        // VIDEO
        // ======================================================
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,

            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,

              child: VideoPlayer(controller),
            ),
          ),
        ),

        // ======================================================
        // PLAY / PAUSE INDICATOR
        // ======================================================
        IgnorePointer(
          child: AnimatedScale(
            scale: showControlIcon ? 1.0 : 0.6,

            duration: const Duration(milliseconds: 150),

            curve: Curves.easeOut,

            child: AnimatedOpacity(
              opacity: showControlIcon ? 1.0 : 0.0,

              duration: const Duration(milliseconds: 150),

              child: Container(
                width: 76,
                height: 76,

                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .45),

                  shape: BoxShape.circle,
                ),

                child: Icon(controlIcon, color: Colors.white, size: 46),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../data/models/video.dart';

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
  // VIDEO CONTROLLER
  // ============================================================

  VideoPlayerController? controller;

  bool initialized = false;

  bool videoError = false;

  // ============================================================
  // PLAY CONTROL
  // ============================================================

  bool showControlIcon = false;

  IconData controlIcon = Icons.pause;

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

    // Only initialize video posts.
    if (isVideoPost) {
      initializeVideo();
    }
  }

  // ============================================================
  // POST TYPE
  // ============================================================

  bool get isVideoPost {
    return widget.video.postType.toLowerCase() == "video";
  }

  bool get isImagePost {
    return widget.video.postType.toLowerCase() == "image";
  }

  // ============================================================
  // VIDEO URL
  // ============================================================

  String get videoUrl {
    if (widget.video.mediaUrls.isEmpty) {
      return "";
    }

    return widget.video.mediaUrls.first;
  }

  // ============================================================
  // IMAGE URL
  // ============================================================

  String get imageUrl {
    if (widget.video.mediaUrls.isNotEmpty) {
      return widget.video.mediaUrls.first;
    }

    return widget.video.thumbnailUrl;
  }

  // ============================================================
  // INITIALIZE VIDEO
  // ============================================================

  Future<void> initializeVideo() async {
    if (videoUrl.isEmpty) {
      setStateIfMounted(() {
        videoError = true;
      });

      return;
    }

    try {
      debugPrint("VIDEO URL: $videoUrl");

      final uri = Uri.tryParse(videoUrl);

      if (uri == null) {
        throw Exception("Invalid video URL");
      }

      final videoController = VideoPlayerController.networkUrl(uri);

      controller = videoController;

      await videoController.initialize();

      if (!mounted) {
        videoController.dispose();
        return;
      }

      await videoController.setLooping(true);

      setState(() {
        initialized = true;
        videoError = false;
      });

      if (widget.isActive) {
        await videoController.play();
      }
    } catch (e) {
      debugPrint("VIDEO ERROR: $e");

      if (!mounted) return;

      setState(() {
        initialized = false;
        videoError = true;
      });
    }
  }

  // ============================================================
  // UPDATE ACTIVE STATE
  // ============================================================

  @override
  void didUpdateWidget(covariant HotelFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!isVideoPost) return;

    final videoController = controller;

    if (videoController == null || !initialized) {
      return;
    }

    // Became active.
    if (widget.isActive && !oldWidget.isActive) {
      videoController.play();
    }

    // Became inactive.
    if (!widget.isActive && oldWidget.isActive) {
      videoController.pause();

      if (mounted) {
        setState(() {
          showControlIcon = false;
        });
      }
    }
  }

  // ============================================================
  // SINGLE TAP
  // ============================================================

  void onTapPost() {
    if (!isVideoPost) {
      return;
    }

    togglePlayPause();
  }

  // ============================================================
  // DOUBLE TAP
  // ============================================================

  Future<void> onDoubleTap() async {
    if (!mounted) return;

    setState(() {
      showHeart = true;
    });

    heartController.forward(from: 0);

    if (isVideoPost) {
      playIfPaused();
    }

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    await heartController.reverse();

    if (!mounted) return;

    setState(() {
      showHeart = false;
    });
  }

  // ============================================================
  // TOGGLE PLAY
  // ============================================================

  void togglePlayPause() {
    final videoController = controller;

    if (videoController == null || !initialized) {
      return;
    }

    if (videoController.value.isPlaying) {
      videoController.pause();

      showControl(Icons.pause);
    } else {
      videoController.play();

      showControl(Icons.play_arrow);
    }
  }

  // ============================================================
  // PLAY IF PAUSED
  // ============================================================

  void playIfPaused() {
    final videoController = controller;

    if (videoController == null || !initialized) {
      return;
    }

    if (!videoController.value.isPlaying) {
      videoController.play();
    }
  }

  // ============================================================
  // SHOW CONTROL
  // ============================================================

  void showControl(IconData icon) {
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
  // SAFE SET STATE
  // ============================================================

  void setStateIfMounted(VoidCallback callback) {
    if (!mounted) return;

    setState(callback);
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget buildImage() {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54, size: 60),
      );
    }

    return SizedBox.expand(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,

        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },

        errorBuilder: (context, error, stackTrace) {
          debugPrint("IMAGE ERROR: $error");

          return const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
          );
        },
      ),
    );
  }

  // ============================================================
  // VIDEO
  // ============================================================

  Widget buildVideo() {
    final videoController = controller;

    if (videoError) {
      return const Center(
        child: Icon(
          Icons.video_library_outlined,
          color: Colors.white54,
          size: 60,
        ),
      );
    }

    if (!initialized || videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: videoController.value.size.width,
              height: videoController.value.size.height,
              child: VideoPlayer(videoController),
            ),
          ),
        ),

        IgnorePointer(
          child: AnimatedScale(
            scale: showControlIcon ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 150),
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
  // MEDIA
  // ============================================================

  Widget buildMedia() {
    if (isVideoPost) {
      return buildVideo();
    }

    return buildImage();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTap: onTapPost,

      onDoubleTap: onDoubleTap,

      child: Stack(
        fit: StackFit.expand,

        children: [
          // ======================================================
          // IMAGE / VIDEO
          // ======================================================
          buildMedia(),

          // ======================================================
          // GRADIENT
          // ======================================================
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

          // ======================================================
          // BIG HEART
          // ======================================================
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

          // ======================================================
          // RIGHT ACTIONS
          // ======================================================
          Positioned(
            right: 15,
            bottom: 40,
            child: RightActions(video: widget.video),
          ),

          // ======================================================
          // DESCRIPTION
          // ======================================================
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

    controller?.dispose();

    super.dispose();
  }
}

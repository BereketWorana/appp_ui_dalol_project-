import 'package:flutter/material.dart';

import '../../../../data/models/video.dart';

import 'hotel_video_player.dart';
import 'right_actions.dart';
import 'description.dart';

class HotelFeedItem extends StatefulWidget {
  final Video video;

  const HotelFeedItem({super.key, required this.video});

  @override
  State<HotelFeedItem> createState() => _HotelFeedItemState();
}

class _HotelFeedItemState extends State<HotelFeedItem>
    with SingleTickerProviderStateMixin {
  bool showHeart = false;

  late AnimationController controller;

  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    scale = Tween<double>(
      begin: .5,
      end: 1.2,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onDoubleTap() async {
    setState(() {
      showHeart = true;
    });

    controller.forward();

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    controller.reverse();

    setState(() {
      showHeart = false;
    });

    // In Part 4 we'll connect this to RightActions
    // so the heart count increases automatically.
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,

      child: Stack(
        fit: StackFit.expand,

        children: [
          HotelVideoPlayer(video: widget.video.video),

          Container(
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

          if (showHeart)
            Center(
              child: ScaleTransition(
                scale: scale,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 120,
                ),
              ),
            ),

          Positioned(
            right: 15,
            bottom: 40,
            child: RightActions(video: widget.video),
          ),

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
}

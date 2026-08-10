import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HotelVideoPlayer extends StatefulWidget {
  final String video;

  const HotelVideoPlayer({super.key, required this.video});

  @override
  State<HotelVideoPlayer> createState() => _HotelVideoPlayerState();
}

class _HotelVideoPlayerState extends State<HotelVideoPlayer> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.asset(widget.video)
      ..initialize().then((_) {
        controller.setLooping(true);

        controller.play();

        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,

        child: SizedBox(
          width: controller.value.size.width,

          height: controller.value.size.height,

          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }
}

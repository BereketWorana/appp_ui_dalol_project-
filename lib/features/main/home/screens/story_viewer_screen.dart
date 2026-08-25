import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../data/models/story.dart';
import '../widgets/book_now_button.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late int currentIndex;
  late AnimationController _animController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _animController = AnimationController(vsync: this);
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
    _loadStory();
  }

  @override
  void dispose() {
    _animController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _loadStory() {
    _animController.stop();
    _animController.reset();
    
    final oldController = _videoController;
    _videoController = null;
    
    // Dispose old controller async to avoid stuttering
    if (oldController != null) {
      Future.microtask(() => oldController.dispose());
    }

    final story = widget.stories[currentIndex];
    
    if (story.mediaType == 'video') {
      _videoController = VideoPlayerController.asset(story.mediaUrl)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController!.play();
            _animController.duration = _videoController!.value.duration;
            _animController.forward();
          }
        });
    } else {
      _animController.duration = const Duration(seconds: 5);
      _animController.forward();
    }
    setState(() {}); // Trigger rebuild to show loading or image immediately
  }

  void _nextStory() {
    if (currentIndex < widget.stories.length - 1) {
      setState(() => currentIndex++);
      _loadStory();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _loadStory();
    } else {
      // Tap left on first story -> reset animation to 0 and replay
      _loadStory();
    }
  }

  void _onTapDown(TapDownDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      _previousStory();
    } else {
      _nextStory();
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 15) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ================================================
            // MEDIA BACKGROUND
            // ================================================
            if (story.mediaType == 'video')
              if (_videoController != null && _videoController!.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator(color: Colors.white))
            else
              Image.asset(story.mediaUrl, fit: BoxFit.cover),

            // ================================================
            // TOP GRADIENT FOR LEGIBILITY
            // ================================================
            const Positioned(
              top: 0, left: 0, right: 0,
              height: 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),

            // ================================================
            // TOP UI OVERLAY
            // ================================================
            SafeArea(
              child: Column(
                children: [
                  // Progress Bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: List.generate(widget.stories.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                double value = 0;
                                if (index < currentIndex) {
                                  value = 1;
                                } else if (index == currentIndex) {
                                  value = _animController.value;
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: Colors.white38,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    minHeight: 2,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(story.userAvatar),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          story.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _timeAgo(story.createdAt),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================================================
            // BOOK NOW BUTTON (If applicable)
            // ================================================
            if (story.hasHotelLink)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: BookNowButton(hotelId: story.hotelId!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

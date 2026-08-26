import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/post.dart';
import '../../../../data/services/post_service.dart';
import '../providers/post_actions_provider.dart';
import '../providers/feed_provider.dart';
import 'hotel_video_player.dart';
import 'right_actions.dart';
import 'description.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isActive;
  final bool showStoriesRow;

  const PostCard({
    super.key,
    required this.post,
    required this.isActive,
    this.showStoriesRow = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  final GlobalKey<HotelVideoPlayerState> videoKey = GlobalKey<HotelVideoPlayerState>();
  bool showHeart = false;
  late AnimationController heartController;
  late Animation<double> heartScale;

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      PostService.trackView(widget.post.id);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      PostService.trackView(widget.post.id);
    }
    heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    heartScale = Tween<double>(begin: .5, end: 1.2).animate(
      CurvedAnimation(parent: heartController, curve: Curves.easeOutBack),
    );
  }

  void onTapVideo() {
    videoKey.currentState?.togglePlayPause();
  }

  Future<void> onDoubleTap() async {
    if (!mounted) return;
    
    // Show animation
    setState(() {
      showHeart = true;
    });
    heartController.forward(from: 0);
    
    // Play video if paused
    videoKey.currentState?.playIfPaused();
    
    // Only like — never unlike on double-tap (TikTok/IG behavior).
    // Read live state from FeedProvider, not the stale widget.post snapshot.
    final feedProvider = context.read<FeedProvider>();
    final currentPost = feedProvider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    if (!currentPost.isLiked) {
      final postActionsProvider = context.read<PostActionsProvider>();
      await postActionsProvider.toggleLike(context, widget.post.id, feedProvider);
    }

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    await heartController.reverse();
    if (!mounted) return;
    setState(() {
      showHeart = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapVideo,
      onDoubleTap: onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // VIDEO
          HotelVideoPlayer(
            key: videoKey,
            video: widget.post.mediaUrl,
            isActive: widget.isActive,
          ),

          // GRADIENT
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

          // BIG HEART
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

          // RIGHT ACTIONS
          Positioned(
            right: 15,
            bottom: 40,
            child: RightActions(post: widget.post), // NEED TO UPDATE right_actions.dart
          ),

          // DESCRIPTION
          Positioned(
            left: 20,
            right: 100,
            bottom: 20,
            child: Description(post: widget.post), // NEED TO UPDATE description.dart
          ),
          
          // STORIES ROW
          // if (widget.showStoriesRow)
          //   const Positioned(
          //     top: 100,
          //     left: 0,
          //     right: 0,
          //     child: StoriesSection(),
          //   ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    heartController.dispose();
    super.dispose();
  }
}

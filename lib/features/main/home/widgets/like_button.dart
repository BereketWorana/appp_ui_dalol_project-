import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_actions_provider.dart';
import '../providers/feed_provider.dart';

class LikeButton extends StatelessWidget {
  final int postId;
  final int likes;

  const LikeButton({
    super.key,
    required this.postId,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PostActionsProvider>(
      builder: (context, provider, child) {
        final isLiked = provider.isLiked(postId);

        return GestureDetector(
          onTap: () {
            final feedProvider = context.read<FeedProvider>();
            provider.toggleLike(context, postId, feedProvider);
          },
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey<bool>(isLiked),
                  color: isLiked ? Colors.red : Colors.white,
                  size: 36,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                likes.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

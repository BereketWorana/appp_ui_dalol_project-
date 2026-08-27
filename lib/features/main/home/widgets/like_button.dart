import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final feedProvider = context.read<FeedProvider>();
            provider.toggleLike(context, postId, feedProvider);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                    child: child,
                  );
                },
                child: Icon(
                  isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  key: ValueKey<bool>(isLiked),
                  color: isLiked ? const Color(0xFFFF3040) : Colors.white,
                  size: 29,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 1.5),
                      blurRadius: 4,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatCount(likes),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
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

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 10000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

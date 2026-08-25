import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_actions_provider.dart';
import '../providers/feed_provider.dart';

class FollowButton extends StatelessWidget {
  final int userId;

  const FollowButton({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PostActionsProvider>(
      builder: (context, provider, child) {
        final isFollowing = provider.isFollowing(userId);

        return GestureDetector(
          onTap: () {
            final feedProvider = context.read<FeedProvider>();
            provider.toggleFollow(context, userId, feedProvider);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.grey.shade600 : Colors.pink.shade500,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(
              isFollowing ? Icons.check : Icons.add,
              size: 13,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

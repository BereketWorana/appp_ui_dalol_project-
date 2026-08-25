import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/post_actions_provider.dart';
import '../providers/feed_provider.dart';

class ProfileHeader extends StatelessWidget {
  final int userId;
  final String userName;
  final String userAvatar;

  const ProfileHeader({
    super.key,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black87, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundImage: userAvatar.startsWith('assets')
                ? AssetImage(userAvatar) as ImageProvider
                : NetworkImage(userAvatar),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Stats: Followers | Following | Posts
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _StatColumn(label: 'Followers', value: '1.2K'),
                _StatColumn(label: 'Following', value: '342'),
                _StatColumn(label: 'Posts', value: '42'),
              ],
            ),
          ),
          
          // Follow button
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Consumer<PostActionsProvider>(
              builder: (context, provider, _) {
                final isFollowing = provider.isFollowing(userId);
                return ElevatedButton(
                  onPressed: () {
                    final feedProvider = context.read<FeedProvider>();
                    provider.toggleFollow(context, userId, feedProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey : Colors.pink,
                  ),
                  child: Text(isFollowing ? 'Following' : 'Follow'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

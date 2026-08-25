import 'package:flutter/material.dart';

import '../../../../data/models/post.dart';
import '../../../../data/services/post_service.dart';

class UserPostsGrid extends StatefulWidget {
  final int userId;

  const UserPostsGrid({super.key, required this.userId});

  @override
  State<UserPostsGrid> createState() => _UserPostsGridState();
}

class _UserPostsGridState extends State<UserPostsGrid> {
  List<Post> userPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    try {
      final posts = await PostService.getUserPosts(widget.userId);
      if (mounted) {
        setState(() {
          userPosts = posts;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userPosts.isEmpty) {
      return const Center(
        child: Text('No posts yet', style: TextStyle(color: Colors.white54)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return GestureDetector(
          onTap: () {
            // Tap post thumbnail → go back to feed, scroll to this post
            // Or navigate to post detail screen
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade900,
            ),
            // Normally use thumbnail or mediaUrl to display the image.
            // Since our mock uses videos, we can just show an icon or a placeholder if it's not an image
            child: const Icon(Icons.video_collection, color: Colors.white54),
          ),
        );
      },
    );
  }
}

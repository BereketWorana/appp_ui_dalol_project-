import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/post.dart';
import '../providers/post_actions_provider.dart';
import '../providers/feed_provider.dart';

import 'comments_sheet.dart';
import 'share_dialog.dart';
import 'like_button.dart';
import 'follow_button.dart';
import '../../profile/screens/profile_screen.dart';

class RightActions extends StatefulWidget {
  final Post post;

  const RightActions({super.key, required this.post});

  @override
  State<RightActions> createState() => _RightActionsState();
}

class _RightActionsState extends State<RightActions> {
  bool saved = false;
  late int bookmarks;

  @override
  void initState() {
    super.initState();
    bookmarks = widget.post.bookmarks;
    
    // Seed initial state into provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<PostActionsProvider>();
        provider.seedLikeState(widget.post.id, widget.post.isLiked);
        provider.seedFollowState(widget.post.ownerId, widget.post.isFollowing);
      }
    });
  }

  void toggleSave() {
    setState(() {
      saved = !saved;
      if (saved) {
        bookmarks++;
      } else {
        bookmarks--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Poster profile image with Instagram style follow badge
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  userId: widget.post.ownerId,
                ),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: widget.post.ownerAvatar.startsWith('assets') 
                  ? Image.asset(widget.post.ownerAvatar, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: widget.post.ownerAvatar,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                    ),
                ),
              ),

              Positioned(
                bottom: -7,
                child: FollowButton(userId: widget.post.ownerId),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // LIKE BUTTON (Instagram Heart)
        LikeButton(postId: widget.post.id, likes: widget.post.likes),

        const SizedBox(height: 18),

        // COMMENT BUTTON (Instagram Speech Bubble)
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          color: Colors.white,
          count: widget.post.comments,
          onTap: () {
            final feedProvider = context.read<FeedProvider>();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) {
                return ChangeNotifierProvider.value(
                  value: feedProvider,
                  child: CommentsSheet(postId: widget.post.id),
                );
              },
            );
          },
        ),

        const SizedBox(height: 18),

        // SHARE BUTTON (Instagram Paper Plane)
        _ActionButton(
          icon: Icons.send_rounded,
          color: Colors.white,
          count: widget.post.shares,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                return ShareDialog(postId: widget.post.id);
              },
            );
          },
        ),

        const SizedBox(height: 18),

        // SAVE BUTTON (Instagram Bookmark Ribbon)
        _ActionButton(
          icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: saved ? const Color(0xFFFFE000) : Colors.white,
          count: bookmarks,
          onTap: toggleSave,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
            shadows: const [
              Shadow(
                offset: Offset(0, 1.5),
                blurRadius: 4,
                color: Colors.black45,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            _formatCount(count),
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


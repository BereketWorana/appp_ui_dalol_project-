import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/post.dart';
import '../providers/post_actions_provider.dart';

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
        // Poster profile image
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
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: widget.post.ownerAvatar.startsWith('assets') 
                  ? Image.asset(widget.post.ownerAvatar, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: widget.post.ownerAvatar,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const CircularProgressIndicator(),
                      errorWidget: (_, __, ___) => const Icon(Icons.person),
                    ),
                ),
              ),

              Positioned(
                bottom: -4,
                right: -4,
                child: FollowButton(userId: widget.post.ownerId),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // LIKE BUTTON
        LikeButton(postId: widget.post.id, likes: widget.post.likes),

        const SizedBox(height: 20),

        // COMMENT BUTTON
        _ActionButton(
          icon: Icons.mode_comment_outlined,
          color: Colors.white,
          count: widget.post.comments.toString(),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) {
                return CommentsSheet(postId: widget.post.id);
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // SHARE BUTTON
        _ActionButton(
          icon: Icons.ios_share_sharp,
          color: Colors.white,
          count: widget.post.shares.toString(),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              builder: (_) {
                return ShareDialog(postId: widget.post.id);
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // SAVE BUTTON
        _ActionButton(
          icon: saved ? Icons.bookmark : Icons.bookmark_border,
          color: saved ? Colors.yellow : Colors.white,
          count: bookmarks.toString(),
          onTap: toggleSave,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String count;
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
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 36,
            shadows: const [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black38,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            count,
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
  }
}


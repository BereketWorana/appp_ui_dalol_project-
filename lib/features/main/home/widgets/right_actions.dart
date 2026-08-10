import 'package:flutter/material.dart';

import '../../../../data/models/video.dart';

import 'comments_sheet.dart';
import '../../../../data/dummy/user_dummy.dart';
import '../../profile/screens/poster_profile_screen.dart';

class RightActions extends StatefulWidget {
  final Video video;

  const RightActions({super.key, required this.video});

  @override
  State<RightActions> createState() => _RightActionsState();
}

class _RightActionsState extends State<RightActions>
    with SingleTickerProviderStateMixin {
  bool liked = false;

  bool saved = false;

  bool followed = false;

  late int likes;

  late int bookmarks;

  late AnimationController likeController;

  late Animation<double> likeAnimation;

  @override
  void initState() {
    super.initState();

    likes = widget.video.likes;

    bookmarks = widget.video.bookmarks;

    likeController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 250),
    );

    likeAnimation = Tween<double>(
      begin: 1,

      end: 1.25,
    ).animate(CurvedAnimation(parent: likeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    likeController.dispose();

    super.dispose();
  }

  void toggleLike() {
    setState(() {
      liked = !liked;

      if (liked) {
        likes++;
      } else {
        likes--;
      }
    });

    likeController.forward().then((_) {
      likeController.reverse();
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

  void toggleFollow() {
    setState(() {
      followed = !followed;
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
            final owner = users.firstWhere(
              (user) => user.id == widget.video.ownerId,
            );

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) => PosterProfileScreen(user: owner),
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
                  image: DecorationImage(
                    image: AssetImage(
                      users
                          .firstWhere((user) => user.id == widget.video.ownerId)
                          .profileImage,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                bottom: -4,
                right: -4,
                child: GestureDetector(
                  onTap: toggleFollow,

                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: followed ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      followed ? Icons.check : Icons.add,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Like button
        AnimatedBuilder(
          animation: likeAnimation,

          builder: (context, child) {
            return Transform.scale(scale: likeAnimation.value, child: child);
          },

          child: _ActionButton(
            icon: liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? Colors.red : Colors.white,
            count: likes.toString(),
            onTap: toggleLike,
          ),
        ),

        const SizedBox(height: 20),

        // COMMENT BUTTON
        _ActionButton(
          icon: Icons.mode_comment_outlined,
          color: Colors.white,
          count: widget.video.comments.toString(),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) {
                return const CommentsSheet();
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // SHARE BUTTON
        _ActionButton(
          icon: Icons.ios_share_sharp,
          color: Colors.white,
          count: widget.video.shares.toString(),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              builder: (_) {
                return const ShareSheet();
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

class ShareSheet extends StatelessWidget {
  const ShareSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 360,

        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Container(
              width: 45,

              height: 5,

              decoration: BoxDecoration(
                color: Colors.grey.shade400,

                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Share",

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 22,

              runSpacing: 22,

              alignment: WrapAlignment.center,

              children: const [
                _ShareItem(icon: Icons.telegram, title: "Telegram"),
                _ShareItem(icon: Icons.chat, title: "WhatsApp"),
                _ShareItem(icon: Icons.email, title: "Gmail"),
                _ShareItem(icon: Icons.facebook, title: "Facebook"),
                _ShareItem(icon: Icons.copy, title: "Copy"),
                _ShareItem(icon: Icons.more_horiz, title: "More"),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),

                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ShareItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$title selected")));
      },

      child: SizedBox(
        width: 70,

        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              child: Icon(icon, color: Colors.black, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

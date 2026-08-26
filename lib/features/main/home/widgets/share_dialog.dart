import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../data/services/post_service.dart';
import '../providers/feed_provider.dart';

class ShareDialog extends StatelessWidget {
  final int postId;

  const ShareDialog({super.key, required this.postId});

  Future<void> _shareAction(BuildContext context, String platform) async {
    // Record mock share interaction
    await PostService.sharePost(postId);

    if (!context.mounted) return;

    try {
      // Optimistically update share count in feed UI if provider is available.
      // May not be accessible here since the dialog runs on a separate modal route.
      context.read<FeedProvider>().incrementShareCount(postId);
    } catch (_) {
      // ProviderNotFoundException is expected — swallow silently.
    }

    if (!context.mounted) return;

    if (platform == 'Copy') {
      await Clipboard.setData(
        ClipboardData(text: 'https://superplatform.com/post/$postId'),
      );
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard')),
      );
    } else if (platform == 'More') {
      Navigator.pop(context);
      Share.share(
        'Check out this post on SuperPlatform: https://superplatform.com/post/$postId',
      );
    } else {
      // Share API not yet built — show friendly holding message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sharing to $platform coming soon!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Section label ─────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Share to',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── App icon horizontal scroll row ────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _AppShareItem(
                  icon: Icons.chat_rounded,
                  iconColor: Colors.white,
                  background: const Color(0xFF25D366), // WhatsApp green
                  label: 'WhatsApp',
                  onTap: () => _shareAction(context, 'WhatsApp'),
                ),
                _AppShareItem(
                  icon: Icons.camera_alt_rounded,
                  iconColor: Colors.white,
                  background: const Color(0xFFE1306C), // Instagram pink
                  label: 'Instagram',
                  onTap: () => _shareAction(context, 'Instagram'),
                ),
                _AppShareItem(
                  icon: Icons.facebook_rounded,
                  iconColor: Colors.white,
                  background: const Color(0xFF1877F2), // Facebook blue
                  label: 'Facebook',
                  onTap: () => _shareAction(context, 'Facebook'),
                ),
                _AppShareItem(
                  icon: Icons.alternate_email_rounded,
                  iconColor: Colors.white,
                  background: Colors.black,
                  label: 'X / Twitter',
                  onTap: () => _shareAction(context, 'Twitter'),
                ),
                _AppShareItem(
                  icon: Icons.more_horiz_rounded,
                  iconColor: Colors.white,
                  background: const Color(0xFF3A3A3C),
                  label: 'More',
                  onTap: () => _shareAction(context, 'More'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Divider ───────────────────────────────────────────
          const Divider(color: Colors.white12, height: 1, indent: 20, endIndent: 20),

          const SizedBox(height: 4),

          // ── Copy Link pill row ────────────────────────────────
          InkWell(
            onTap: () => _shareAction(context, 'Copy'),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  // Link icon in circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Copy Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
                ],
              ),
            ),
          ),

          // ── Cancel button ─────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              4,
              16,
              16 + MediaQuery.of(context).viewPadding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF3A3A3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App icon item in the horizontal scroll row
// ─────────────────────────────────────────────────────────────────────────────

class _AppShareItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color background;
  final String label;
  final VoidCallback onTap;

  const _AppShareItem({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 0.5),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

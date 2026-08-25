import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/post_service.dart';

class ShareDialog extends StatelessWidget {
  final int postId;

  const ShareDialog({super.key, required this.postId});

  Future<void> _shareAction(BuildContext context, String platform) async {
    // Record mock share interaction
    await PostService.sharePost(postId);
    
    if (!context.mounted) return;
    
    if (platform == 'Copy') {
      await Clipboard.setData(ClipboardData(text: 'https://superplatform.com/post/$postId'));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard')),
      );
    } else if (platform == 'More') {
      Share.share('Check out this post on SuperPlatform: https://superplatform.com/post/$postId');
    } else {
      // Deep linking mock
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sharing to $platform...')),
      );
    }
    
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

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
              "Share to",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 22,
              runSpacing: 22,
              alignment: WrapAlignment.center,
              children: [
                _ShareItem(icon: Icons.chat, title: "WhatsApp", onTap: () => _shareAction(context, "WhatsApp")),
                _ShareItem(icon: Icons.camera_alt, title: "Instagram", onTap: () => _shareAction(context, "Instagram")),
                _ShareItem(icon: Icons.telegram, title: "Telegram", onTap: () => _shareAction(context, "Telegram")),
                _ShareItem(icon: Icons.alternate_email, title: "Twitter", onTap: () => _shareAction(context, "Twitter")),
                _ShareItem(icon: Icons.copy, title: "Copy", onTap: () => _shareAction(context, "Copy")),
                _ShareItem(icon: Icons.more_horiz, title: "More", onTap: () => _shareAction(context, "More")),
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
  final VoidCallback onTap;

  const _ShareItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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

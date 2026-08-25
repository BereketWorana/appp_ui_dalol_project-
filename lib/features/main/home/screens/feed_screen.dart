import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/models/post.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import 'menu_screen.dart';
import 'notification.dart';

// ============================================================
// FEED SCREEN  (Task 5.1)
// ============================================================
//
// TikTok-style vertical PageView feed.
//
// Features implemented:
//   ✅ Full-screen vertical PageView
//   ✅ Shimmer loading state
//   ✅ Pull-to-refresh (RefreshIndicator on page scroll)
//   ✅ Infinite scroll (loads more when 2 posts from end)
//   ✅ Empty state
//   ✅ Error state with retry
//   ✅ Stories row at the top of the first post
//   ✅ Top action bar (menu + notifications)

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin {
  // ============================================================
  // PAGE CONTROLLER
  // ============================================================

  late final PageController _pageController;

  int _currentIndex = 0;

  // ============================================================
  // KEEP ALIVE (so feed doesn't reload when switching tabs)
  // ============================================================

  @override
  bool get wantKeepAlive => true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Load feed on first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadFeed();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // PAGE CHANGED
  // ============================================================

  void _onPageChanged(int index) {
    if (!mounted) return;
    setState(() => _currentIndex = index);

    // ----------------------------------------------------------
    // INFINITE SCROLL: load more when 2 posts from the end.
    // ----------------------------------------------------------
    final provider = context.read<FeedProvider>();
    if (index >= provider.posts.length - 2) {
      provider.loadMore();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<FeedProvider>(
        builder: (context, provider, _) {
          // ====================================================
          // LOADING (shimmer)
          // ====================================================
          if (provider.isLoading) {
            return _FeedShimmer();
          }

          // ====================================================
          // ERROR
          // ====================================================
          if (provider.error != null && provider.posts.isEmpty) {
            return _ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadFeed(),
            );
          }

          // ====================================================
          // EMPTY
          // ====================================================
          if (provider.isEmpty) {
            return const _EmptyState();
          }

          // ====================================================
          // FEED
          // ====================================================
          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: Colors.white,
            backgroundColor: Colors.black87,
            child: Stack(
              children: [
                // ================================================
                // PAGE VIEW
                // ================================================
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  physics: const PageScrollPhysics(),
                  itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    // ------------------------------------------
                    // LOADING MORE indicator at the end
                    // ------------------------------------------
                    if (index >= provider.posts.length) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    final Post post = provider.posts[index];

                    return PostCard(
                      key: ValueKey(post.id),
                      post: post,
                      isActive: index == _currentIndex,
                      // Show stories row only on the first post
                      showStoriesRow: index == 0,
                    );
                  },
                ),

                // ================================================
                // TOP ACTION BAR
                // ================================================
                _TopBar(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// TOP BAR
// ============================================================

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Menu
            _TopBarButton(
              icon: Icons.menu,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              ),
            ),

            // App Logo / "For You"
            const Text(
              'For You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),

            // Notifications
            _TopBarButton(
              icon: Icons.notifications_none,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// ============================================================
// SHIMMER LOADING STATE  (Task 5.1)
// ============================================================

class _FeedShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen shimmer
          Container(color: Colors.grey[850]),

          // Bottom overlay skeleton
          Positioned(
            left: 20,
            right: 110,
            bottom: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + name row
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 120,
                      height: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(width: double.infinity, height: 12, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 200, height: 12, color: Colors.white),
                const SizedBox(height: 12),
                Container(
                  width: 100,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),

          // Right side action buttons skeleton
          Positioned(
            right: 15,
            bottom: 80,
            child: Column(
              children: List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(width: 28, height: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, color: Colors.white38, size: 64),
          SizedBox(height: 16),
          Text(
            'No posts available',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: TextStyle(color: Colors.white30, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white38,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

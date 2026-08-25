import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_tab_bar.dart';

import '../tabs/about_tab.dart';
import '../tabs/favorites_tab.dart';
import '../tabs/likes_tab.dart';

import '../../profile/upgrade/consumer_upgrade_screen.dart';
import '../../../auth/screens/login_screen.dart';
import '../../../../data/dummy/user_dummy.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ==========================================
  // LOGOUT
  // ==========================================

  void logout() {
    AuthService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(returnToHome: true)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isViewingSelf = widget.userId == null || widget.userId == AuthService.currentUser?.id;
    
    final user = isViewingSelf 
        ? AuthService.currentUser 
        : users.firstWhere(
            (u) => u.id == widget.userId, 
            orElse: () => users.first,
          );

    // ==========================================
    // NOT LOGGED IN
    // ==========================================
    //
    // IMPORTANT:
    // Do NOT navigate to Login here.
    //
    // ConsumerMainScreen handles authentication
    // before allowing the user to enter this screen.
    // ==========================================

    if (!AuthService.isLoggedIn || user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Please login to view your profile.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    // ==========================================
    // LOGGED IN PROFILE
    // ==========================================

    return DefaultTabController(
      length: 3,

      child: Scaffold(
        backgroundColor: Colors.black,

        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // ==================================
                      // PROFILE HEADER
                      // ==================================
                      ProfileHeader(
                        coverImage: user.coverImage,
                        profileImage: user.profileImage,
                        name: user.fullName,
                        email: user.email,

                        isLoggedIn: true,

                        isConsumer: user.role == "consumer",

                        onLogin: () {},

                        // ==================================
                        // UPGRADE
                        // ==================================
                        onUpgrade: isViewingSelf ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ConsumerUpgradeScreen(),
                            ),
                          );
                        } : null,

                        // ==================================
                        // LOGOUT
                        // ==================================
                        onLogout: isViewingSelf ? logout : null,
                      ),

                      const ProfileStats(),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // ==================================
                // PROFILE TABS
                // ==================================
                SliverPersistentHeader(
                  pinned: true,

                  delegate: _TabBarDelegate(const ProfileTabBar()),
                ),
              ];
            },

            // ==================================
            // TAB CONTENT
            // ==================================
            body: const TabBarView(
              children: [AboutTab(), FavoritesTab(), LikesTab()],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB BAR DELEGATE
// ==========================================

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget tabBar;

  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.black, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}

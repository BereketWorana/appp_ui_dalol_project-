import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/screens/feed_screen.dart';
import '../home/providers/feed_provider.dart';
import '../home/providers/post_actions_provider.dart';
import '../explore/screens/explore_screen.dart';
import '../messages/screens/messages_screen.dart';
import '../profile/screens/profile_screen.dart';

import '../../auth/screens/login_screen.dart';
import '../create/creator_upload.dart';
import '../create/hotel_admin_upload.dart';

import '../../../core/services/auth_service.dart';

class ConsumerMainScreen extends StatefulWidget {
  const ConsumerMainScreen({super.key});

  @override
  State<ConsumerMainScreen> createState() => _ConsumerMainScreenState();
}

class _ConsumerMainScreenState extends State<ConsumerMainScreen> {
  int currentIndex = 0;

  // ============================================================
  // SCREENS
  // ============================================================
  //
  // IMPORTANT:
  // These are created once and kept alive using IndexedStack.
  // This prevents Home videos from being destroyed/recreated
  // every time the user changes the bottom navigation.
  // ============================================================

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FeedProvider()),
          ChangeNotifierProvider(create: (_) => PostActionsProvider()),
        ],
        child: const FeedScreen(),
      ),
      const ExploreScreen(),
      const SizedBox(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];
  }

  // ============================================================
  // OPEN LOGIN
  // ============================================================

  void openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(returnToHome: true)),
    );
  }

  // ============================================================
  // CREATE / PLUS BUTTON
  // ============================================================

  void handleCreateButton() {
    // ----------------------------------------------------------
    // NOT LOGGED IN
    // ----------------------------------------------------------

    if (!AuthService.isLoggedIn) {
      openLogin();
      return;
    }

    final user = AuthService.currentUser;

    if (user == null) {
      openLogin();
      return;
    }

    // ----------------------------------------------------------
    // CREATOR
    // ----------------------------------------------------------

    if (user.role == "creator") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreatorUploadScreen()),
      );

      return;
    }

    // ----------------------------------------------------------
    // MERCHANT
    // ----------------------------------------------------------

    if (user.role == "merchant") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HotelAdminUploadScreen()),
      );

      return;
    }

    // ----------------------------------------------------------
    // CONSUMER
    // ----------------------------------------------------------

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You need a creator or merchant account to upload."),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void changeTab(int index) {
    // ----------------------------------------------------------
    // CREATE
    // ----------------------------------------------------------

    if (index == 2) {
      handleCreateButton();
      return;
    }

    // ----------------------------------------------------------
    // MESSAGES
    // ----------------------------------------------------------

    if (index == 3 && !AuthService.isLoggedIn) {
      openLogin();
      return;
    }

    // ----------------------------------------------------------
    // PROFILE
    // ----------------------------------------------------------

    if (index == 4 && !AuthService.isLoggedIn) {
      openLogin();
      return;
    }

    // ----------------------------------------------------------
    // CHANGE TAB
    // ----------------------------------------------------------

    if (currentIndex == index) {
      return;
    }

    setState(() {
      currentIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ========================================================
      // IMPORTANT:
      // IndexedStack keeps all screens alive.
      // ========================================================
      body: IndexedStack(index: currentIndex, children: screens),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        backgroundColor: Colors.black,

        selectedItemColor: Colors.white,

        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        elevation: 0,

        onTap: changeTab,

        items: [
          // ====================================================
          // HOME
          // ====================================================
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          // ====================================================
          // EXPLORE
          // ====================================================
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: "Explore",
          ),

          // ====================================================
          // CREATE
          // ====================================================
          BottomNavigationBarItem(
            label: "",

            icon: Container(
              width: 48,
              height: 48,

              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: const Icon(Icons.add, color: Colors.black, size: 32),
            ),
          ),

          // ====================================================
          // MESSAGES
          // ====================================================
          const BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: "Messages",
          ),

          // ====================================================
          // PROFILE
          // ====================================================
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../home/screens/home_screen.dart';
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

  // ==========================================
  // OPEN LOGIN
  // ==========================================

  void openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(returnToHome: true)),
    );
  }

  // ==========================================
  // CREATE / PLUS BUTTON
  // ==========================================

  void handleCreateButton() {
    // User is not logged in
    if (!AuthService.isLoggedIn) {
      openLogin();
      return;
    }

    final user = AuthService.currentUser;

    if (user == null) {
      openLogin();
      return;
    }

    // ==========================================
    // CREATOR
    // ==========================================

    if (user.role == "creator") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreatorUploadScreen()),
      );

      return;
    }

    // ==========================================
    // MERCHANT
    // ==========================================

    if (user.role == "merchant") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HotelAdminUploadScreen()),
      );

      return;
    }

    // ==========================================
    // NORMAL CONSUMER
    // ==========================================
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const ExploreScreen(),
      const SizedBox(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        backgroundColor: Colors.black,

        selectedItemColor: Colors.white,

        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          // ==================================
          // CREATE / PLUS BUTTON
          // ==================================

          if (index == 2) {
            handleCreateButton();
            return;
          }

          // ==================================
          // MESSAGES
          // ==================================

          if (index == 3 && !AuthService.isLoggedIn) {
            openLogin();
            return;
          }

          // ==================================
          // CHANGE SCREEN
          // ==================================

          setState(() {
            currentIndex = index;
          });
        },

        items: [
          // ==================================
          // HOME
          // ==================================
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          // ==================================
          // EXPLORE
          // ==================================
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: "Explore",
          ),

          // ==================================
          // CREATE
          // ==================================
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

          // ==================================
          // MESSAGES
          // ==================================
          const BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: "Messages",
          ),

          // ==================================
          // PROFILE
          // ==================================
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

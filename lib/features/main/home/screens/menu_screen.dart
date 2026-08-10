import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../menu/analytics_content.dart';
import '../menu/booking_management_content.dart';
import '../menu/creator_dashboard_content.dart';
import '../menu/dashboard_content.dart';
import '../menu/local_ai_content.dart';
import '../menu/my_rooms_content.dart';
import '../menu/my_videos_content.dart';
import '../menu/reviews_content.dart';
import '../menu/settings_content.dart';
import '../menu/support_content.dart';
import '../menu/trip_kit_content.dart';
import '../menu/wallet_content.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool menuExpanded = true;
  String selectedPage = "Dashboard";

  @override
  Widget build(BuildContext context) {
    final role = AuthService.currentUser?.role ?? "consumer";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            //================ HEADER (Reduced height by 50%) =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2454E8), Color(0xFF3A74FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Menu Icon (Three lines) - Now on LEFT
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            menuExpanded = !menuExpanded;
                          });
                        },
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      // Back Arrow - Now on RIGHT
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          role == "merchant"
                              ? Icons.hotel
                              : role == "creator"
                              ? Icons.video_camera_back
                              : Icons.travel_explore,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Explore Features",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Everything you need in one place",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: menuExpanded
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: role == "merchant"
                          ? _merchantMenu()
                          : role == "creator"
                          ? _creatorMenu()
                          : _consumerMenu(),
                    )
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  //==================== CONSUMER MENU ====================
  List<Widget> _consumerMenu() {
    return [
      _menuItem(Icons.account_balance_wallet_outlined, "Wallet", "wallet"),
      _menuItem(Icons.smart_toy_outlined, "Local Guide AI", "ai"),
      _menuItem(Icons.card_travel_outlined, "Trip Kit", "trip"),
      _menuItem(Icons.confirmation_number_outlined, "My Bookings", "bookings"),
      _menuItem(Icons.settings_outlined, "Settings", "settings"),
      _menuItem(Icons.support_agent_outlined, "Support", "support"),
    ];
  }

  //==================== MERCHANT MENU ====================
  List<Widget> _merchantMenu() {
    return [
      _menuItem(Icons.dashboard_outlined, "Dashboard", "dashboard"),
      _menuItem(Icons.hotel_outlined, "My Rooms", "rooms"),
      _menuItem(Icons.video_library_outlined, "My Videos", "videos"),
      _menuItem(
        Icons.event_note_outlined,
        "Booking Management",
        "booking_management",
      ),
      _menuItem(Icons.account_balance_wallet_outlined, "Wallet", "wallet"),
      _menuItem(Icons.smart_toy_outlined, "Local Guide AI", "ai"),
      _menuItem(Icons.card_travel_outlined, "Trip Kit", "trip"),
      _menuItem(Icons.rate_review_outlined, "Reviews", "reviews"),
      _menuItem(Icons.settings_outlined, "Settings", "settings"),
      _menuItem(Icons.support_agent_outlined, "Support", "support"),
    ];
  }

  //==================== CREATOR MENU ====================
  List<Widget> _creatorMenu() {
    return [
      _menuItem(
        Icons.dashboard_outlined,
        "Creator Dashboard",
        "creator_dashboard",
      ),
      _menuItem(Icons.video_library_outlined, "My Videos", "videos"),
      _menuItem(Icons.bar_chart_outlined, "Analytics", "analytics"),
      _menuItem(Icons.account_balance_wallet_outlined, "Earnings", "earnings"),
      _menuItem(Icons.campaign_outlined, "Brand Collaborations", "brands"),
      _menuItem(Icons.emoji_events_outlined, "Campaigns", "campaigns"),
      _menuItem(Icons.smart_toy_outlined, "Local Guide AI", "ai"),
      _menuItem(Icons.card_travel_outlined, "Trip Kit", "trip"),
      _menuItem(Icons.settings_outlined, "Settings", "settings"),
      _menuItem(Icons.support_agent_outlined, "Support", "support"),
    ];
  }

  //==================== BUILD CONTENT ====================
  Widget _buildContent() {
    switch (selectedPage) {
      case "dashboard":
        return const DashboardContent();
      case "rooms":
        return const MyRoomsContent();
      case "videos":
        return const MyVideosContent();
      case "booking_management":
        return const BookingManagementContent();
      case "wallet":
        return const WalletContent();
      case "ai":
        return const LocalAIContent();
      case "trip":
        return const TripKitContent();
      case "reviews":
        return const ReviewsContent();
      case "creator_dashboard":
        return const CreatorDashboardContent();
      case "analytics":
        return const AnalyticsContent();
      case "earnings":
        return const WalletContent();
      case "brands":
        return const SupportContent();
      case "campaigns":
        return const SupportContent();
      case "bookings":
        return const BookingManagementContent();
      case "settings":
        return const SettingsContent();
      case "support":
        return const SupportContent();

      default:
        return const Center(
          child: Text(
            "Page Not Found",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  //==================== MENU ITEM ====================
  Widget _menuItem(IconData icon, String title, String page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: () {
          setState(() {
            selectedPage = page;
            menuExpanded = false;
          });
        },
      ),
    );
  }
}

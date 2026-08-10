import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Unread',
    'Likes',
    'Comments',
    'Follows',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  backgroundColor: Colors.white,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.done_all, color: Colors.white70, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filters.map((filter) {
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 4),

          // Notifications List
          Expanded(child: _buildActivityTab()),
        ],
      ),
    );
  }

  //==================== ACTIVITY TAB ====================
  Widget _buildActivityTab() {
    final notifications = _getFilteredNotifications();

    if (notifications.isEmpty) {
      return _buildEmptyState(
        Icons.notifications_off,
        "No notifications",
        "You're all caught up!",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(
          notification['icon'] as IconData,
          notification['title'] as String,
          notification['subtitle'] as String,
          notification['time'] as String,
          notification['isRead'] as bool,
        );
      },
    );
  }

  //==================== NOTIFICATION ITEM ====================
  Widget _buildNotificationItem(
    IconData icon,
    String title,
    String subtitle,
    String time,
    bool isRead,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRead ? const Color(0xFF0D0D0D) : const Color(0xFF181818),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          // Unread indicator
          if (!isRead)
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  //==================== EMPTY STATE ====================
  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white24, size: 56),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  //==================== FILTERED NOTIFICATIONS ====================
  List<Map<String, dynamic>> _getFilteredNotifications() {
    final allNotifications = _getAllNotifications();

    if (_selectedFilter == 'All') {
      return allNotifications;
    }

    return allNotifications.where((notification) {
      final title = notification['title'] as String;
      if (_selectedFilter == 'Unread') {
        return notification['isRead'] == false;
      }
      return title.contains(_selectedFilter);
    }).toList();
  }

  //==================== ALL NOTIFICATIONS ====================
  List<Map<String, dynamic>> _getAllNotifications() {
    return [
      {
        'icon': Icons.favorite,
        'title': 'Liked your video',
        'subtitle': 'Jane Smith liked your video "Luxury Suite Tour"',
        'time': '2 min ago',
        'isRead': false,
      },
      {
        'icon': Icons.comment,
        'title': 'Commented on your post',
        'subtitle': 'Mike Johnson: "Amazing place! 😍"',
        'time': '15 min ago',
        'isRead': false,
      },
      {
        'icon': Icons.person_add,
        'title': 'Started following you',
        'subtitle': 'Sarah Williams started following you',
        'time': '1 hour ago',
        'isRead': true,
      },
      {
        'icon': Icons.thumb_up,
        'title': 'Liked your comment',
        'subtitle': 'David Brown liked your comment on "Best Hotels"',
        'time': '3 hours ago',
        'isRead': true,
      },
      {
        'icon': Icons.share,
        'title': 'Shared your content',
        'subtitle': 'Emily Davis shared your video "Pool Experience"',
        'time': '5 hours ago',
        'isRead': true,
      },
      {
        'icon': Icons.bookmark,
        'title': 'Saved your post',
        'subtitle': 'Robert Wilson saved your post "Hotel Guide"',
        'time': '1 day ago',
        'isRead': true,
      },
      {
        'icon': Icons.message,
        'title': 'New message',
        'subtitle': 'You have a new message from Lisa Chen',
        'time': '2 days ago',
        'isRead': true,
      },
    ];
  }
}

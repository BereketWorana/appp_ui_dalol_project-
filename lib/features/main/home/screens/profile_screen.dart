import 'package:flutter/material.dart';

import '../widgets/profile_header.dart';
import '../widgets/user_posts_grid.dart';

class ProfileScreen extends StatelessWidget {
  final int userId;
  final String userName;
  final String userAvatar;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Profile header
          ProfileHeader(
            userName: userName,
            userAvatar: userAvatar,
            userId: userId,
          ),
          
          // User's posts grid
          Expanded(
            child: UserPostsGrid(userId: userId),
          ),
        ],
      ),
    );
  }
}

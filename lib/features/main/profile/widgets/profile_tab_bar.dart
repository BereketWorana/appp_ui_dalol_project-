import 'package:flutter/material.dart';

class ProfileTabBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      indicatorColor: Colors.white,

      indicatorWeight: 2,

      labelColor: Colors.white,

      unselectedLabelColor: Colors.white38,

      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),

      unselectedLabelStyle: TextStyle(fontSize: 13),

      tabs: [
        Tab(icon: Icon(Icons.person_outline, size: 20), text: "About"),

        Tab(icon: Icon(Icons.bookmark_border, size: 20), text: "Favorites"),

        Tab(icon: Icon(Icons.favorite_border, size: 20), text: "Likes"),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);
}

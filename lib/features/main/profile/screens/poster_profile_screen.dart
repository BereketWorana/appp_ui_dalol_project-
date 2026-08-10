import 'package:flutter/material.dart';

import '../../../../data/models/user.dart';
import '../../../../data/dummy/video_dummy.dart';

import '../../messages/screens/messages_screen.dart';

class PosterProfileScreen extends StatefulWidget {
  final User user;

  const PosterProfileScreen({super.key, required this.user});

  @override
  State<PosterProfileScreen> createState() => _PosterProfileScreenState();
}

class _PosterProfileScreenState extends State<PosterProfileScreen>
    with SingleTickerProviderStateMixin {
  bool following = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  // ==========================================
  // OPEN MESSAGE
  // ==========================================

  void openMessage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessagesScreen(selectedUser: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userVideos = videos
        .where((video) => video.ownerId == widget.user.id)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: DefaultTabController(
          length: 3,

          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // ==================================
                      // COVER + PROFILE IMAGE
                      // ==================================
                      Stack(
                        clipBehavior: Clip.none,

                        children: [
                          SizedBox(
                            height: 115,

                            width: double.infinity,

                            child: Image.asset(
                              widget.user.coverImage,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 20,
                            bottom: -45,

                            child: CircleAvatar(
                              radius: 48,

                              backgroundImage: AssetImage(
                                widget.user.profileImage,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 65),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // ==================================
                            // NAME
                            // ==================================
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.user.fullName,

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                if (widget.user.role == "merchant")
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // ==================================
                            // ROLE
                            // ==================================
                            Text(
                              widget.user.role == "merchant"
                                  ? "Hotel"
                                  : "Creator",

                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==================================
                            // PROFILE STATS
                            // ==================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,

                              children: [
                                profileStat("125", "Following"),

                                profileStat("2.4K", "Followers"),

                                profileStat("15.8K", "Likes"),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ==================================
                            // BIO
                            // ==================================
                            const Text(
                              "Luxury hotel experience with comfortable "
                              "rooms, beautiful views, and excellent "
                              "hospitality.",

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==================================
                            // FOLLOW + MESSAGE
                            // ==================================
                            Row(
                              children: [
                                // FOLLOW BUTTON
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        following = !following;
                                      });
                                    },

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: following
                                          ? Colors.grey
                                          : Colors.white,

                                      foregroundColor: Colors.black,

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    child: Text(
                                      following ? "Following" : "Follow",
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // MESSAGE BUTTON
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: openMessage,

                                    icon: const Icon(
                                      Icons.message_outlined,
                                      size: 19,
                                    ),

                                    label: const Text("Message"),

                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,

                                      side: const BorderSide(
                                        color: Colors.white30,
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),

                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ];
            },

            body: Column(
              children: [
                // ==================================
                // TAB BAR
                // ==================================
                Container(
                  color: Colors.black,

                  child: TabBar(
                    controller: _tabController,

                    indicatorColor: Colors.white,

                    labelColor: Colors.white,

                    unselectedLabelColor: Colors.white54,

                    tabs: const [
                      Tab(
                        icon: Icon(Icons.video_collection_outlined),
                        text: "Videos",
                      ),

                      Tab(icon: Icon(Icons.image_outlined), text: "Images"),

                      Tab(icon: Icon(Icons.favorite_border), text: "Likes"),
                    ],
                  ),
                ),

                // ==================================
                // TAB CONTENT
                // ==================================
                Expanded(
                  child: TabBarView(
                    controller: _tabController,

                    children: [
                      // ==============================
                      // VIDEOS
                      // ==============================
                      GridView.builder(
                        padding: const EdgeInsets.all(10),

                        itemCount: userVideos.length,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),

                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),

                            child: Stack(
                              fit: StackFit.expand,

                              children: [
                                Image.asset(
                                  userVideos[index].thumbnail,
                                  fit: BoxFit.cover,
                                ),

                                const Positioned(
                                  right: 6,
                                  bottom: 6,

                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // ==============================
                      // IMAGES
                      // ==============================
                      GridView.builder(
                        padding: const EdgeInsets.all(10),

                        itemCount: userVideos.length,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),

                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),

                            child: Image.asset(
                              userVideos[index].thumbnail,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),

                      // ==============================
                      // LIKES
                      // ==============================
                      GridView.builder(
                        padding: const EdgeInsets.all(10),

                        itemCount: userVideos.length,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),

                        itemBuilder: (context, index) {
                          return Stack(
                            fit: StackFit.expand,

                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),

                                child: Image.asset(
                                  userVideos[index].thumbnail,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),

                                  color: Colors.black38,
                                ),
                              ),

                              const Center(
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PROFILE STAT
  // ==========================================

  Widget profileStat(String number, String title) {
    return Column(
      children: [
        Text(
          number,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,

          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

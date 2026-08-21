import 'package:flutter/material.dart';

import '../../../../data/models/user.dart';

import '../../messages/screens/messages_screen.dart';

class PosterProfileScreen extends StatefulWidget {
  final User user;

  const PosterProfileScreen({super.key, required this.user});

  @override
  State<PosterProfileScreen> createState() => _PosterProfileScreenState();
}

class _PosterProfileScreenState extends State<PosterProfileScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // STATE
  // ============================================================

  bool following = false;

  late TabController _tabController;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  // ============================================================
  // OPEN MESSAGE
  // ============================================================

  void openMessage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessagesScreen(selectedUser: widget.user),
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget profileImage() {
    final image = widget.user.profileImage;

    if (image.isEmpty) {
      return const CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white12,
        child: Icon(Icons.person, color: Colors.white, size: 45),
      );
    }

    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.white12,
      backgroundImage: AssetImage(image),
    );
  }

  // ============================================================
  // COVER IMAGE
  // ============================================================

  Widget coverImage() {
    final image = widget.user.coverImage;

    if (image.isEmpty) {
      return Container(
        height: 115,
        width: double.infinity,
        color: const Color(0xFF181818),
      );
    }

    return SizedBox(
      height: 115,
      width: double.infinity,
      child: Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            color: const Color(0xFF181818),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white38,
                size: 35,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isMerchant = widget.user.role == "merchant";

    final String displayRole = isMerchant ? "Hotel" : "Creator";

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ==================================================
                    // COVER + PROFILE IMAGE
                    // ==================================================
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        coverImage(),

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
                          child: profileImage(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 65),

                    // ==================================================
                    // PROFILE INFORMATION
                    // ==================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ============================================
                          // NAME
                          // ============================================
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.user.fullName,

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              if (isMerchant)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),

                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 22,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // ============================================
                          // ROLE
                          // ============================================
                          Text(
                            displayRole,

                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ============================================
                          // PROFILE STATS
                          // ============================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,

                            children: [
                              profileStat("125", "Following"),

                              profileStat("2.4K", "Followers"),

                              profileStat("15.8K", "Likes"),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ============================================
                          // BIO
                          // ============================================
                          Text(
                            isMerchant
                                ? "Luxury hotel experience with comfortable rooms, beautiful views, and excellent hospitality."
                                : "Travel creator sharing amazing places, experiences, and adventures.",

                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ============================================
                          // FOLLOW + MESSAGE
                          // ============================================
                          Row(
                            children: [
                              // FOLLOW
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

                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),

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

                              // MESSAGE
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

                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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

          // ==========================================================
          // TAB CONTENT
          // ==========================================================
          body: Column(
            children: [
              // ========================================================
              // TAB BAR
              // ========================================================
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

              // ========================================================
              // TAB VIEW
              // ========================================================
              Expanded(
                child: TabBarView(
                  controller: _tabController,

                  children: [
                    // ====================================================
                    // VIDEOS
                    // ====================================================
                    _emptyTab(
                      icon: Icons.video_collection_outlined,
                      title: "No videos yet",
                    ),

                    // ====================================================
                    // IMAGES
                    // ====================================================
                    _emptyTab(
                      icon: Icons.image_outlined,
                      title: "No images yet",
                    ),

                    // ====================================================
                    // LIKES
                    // ====================================================
                    _emptyTab(
                      icon: Icons.favorite_border,
                      title: "No liked posts yet",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY TAB
  // ============================================================

  Widget _emptyTab({required IconData icon, required String title}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Colors.white24, size: 55),

          const SizedBox(height: 12),

          Text(
            title,

            style: const TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE STAT
  // ============================================================

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

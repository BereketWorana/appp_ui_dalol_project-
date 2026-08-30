import 'package:flutter/material.dart';

import '../../../../data/models/user.dart';
import '../../../../data/services/user_service.dart';
import '../../messages/screens/messages_screen.dart';

class PosterProfileScreen extends StatefulWidget {
  final User? user;
  final int? userId;

  const PosterProfileScreen({
    super.key,
    this.user,
    this.userId,
  }) : assert(user != null || userId != null, 'Either user or userId must be provided');

  @override
  State<PosterProfileScreen> createState() => _PosterProfileScreenState();
}

class _PosterProfileScreenState extends State<PosterProfileScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // STATE
  // ============================================================

  User? _loadedUser;
  bool _isLoading = false;
  String? _error;
  bool following = false;

  late TabController _tabController;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadedUser = widget.user;
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final int? targetId = widget.userId ?? widget.user?.id;
    if (targetId == null || targetId == 0) {
      if (_loadedUser == null) {
        setState(() {
          _error = "Invalid user ID";
        });
      }
      return;
    }

    setState(() {
      _isLoading = _loadedUser == null;
      _error = null;
    });

    try {
      final fetchedUser = await UserService.getUserByIdFromApi(targetId);
      if (mounted) {
        setState(() {
          _loadedUser = fetchedUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_loadedUser == null) {
            _error = e.toString().replaceAll('Exception: ', '');
          }
          _isLoading = false;
        });
      }
    }
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
    if (_loadedUser == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessagesScreen(selectedUser: _loadedUser!),
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget profileImage() {
    final image = _loadedUser?.profileImage ?? '';

    if (image.isEmpty) {
      return const CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white12,
        child: Icon(Icons.person, color: Colors.white, size: 45),
      );
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white12,
        backgroundImage: NetworkImage(image),
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
    final image = _loadedUser?.coverImage ?? '';

    if (image.isEmpty) {
      return Container(
        height: 115,
        width: double.infinity,
        color: const Color(0xFF181818),
      );
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return SizedBox(
        height: 115,
        width: double.infinity,
        child: Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: const Color(0xFF181818)),
        ),
      );
    }

    return SizedBox(
      height: 115,
      width: double.infinity,
      child: Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(color: const Color(0xFF181818)),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.yellow),
        ),
      );
    }

    if (_error != null && _loadedUser == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  child: const Text('Retry', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = _loadedUser!;
    final bool isMerchant = user.role == "merchant";
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
                          left: 10,
                          top: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
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
                                  user.fullName,

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

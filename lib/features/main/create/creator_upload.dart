import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CreatorUploadScreen extends StatefulWidget {
  const CreatorUploadScreen({super.key});

  @override
  State<CreatorUploadScreen> createState() => _CreatorUploadScreenState();
}

class _CreatorUploadScreenState extends State<CreatorUploadScreen> {
  final captionController = TextEditingController();

  List<Map<String, dynamic>> hotelOwners = [];

  Map<String, dynamic>? selectedHotel;

  bool loadingHotels = true;
  bool posting = false;

  String? selectedVideo;

  @override
  void initState() {
    super.initState();
    loadHotelOwners();
  }

  // ============================================================
  // LOAD REGISTERED HOTEL OWNERS
  // ============================================================

  Future<void> loadHotelOwners() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/users.json');

      final List<dynamic> users = jsonDecode(jsonString);

      final hotels = users
          .where(
            (user) =>
                user is Map<String, dynamic> &&
                user['role'] == 'merchant' &&
                user['status'] == 'active',
          )
          .map<Map<String, dynamic>>((user) => Map<String, dynamic>.from(user))
          .toList();

      if (!mounted) return;

      setState(() {
        hotelOwners = hotels;
        loadingHotels = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingHotels = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not load registered hotels: $e")),
      );
    }
  }

  // ============================================================
  // SELECT VIDEO
  // ============================================================

  Future<void> selectVideo() async {
    /*
      Temporary video selector.

      Later we can connect this to:
      image_picker
      file_picker
      or your backend/video storage.

      For now this creates a selected-video state.
    */

    setState(() {
      selectedVideo = "selected_video.mp4";
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Video selected")));
  }

  // ============================================================
  // SELECT HOTEL
  // ============================================================

  Future<void> selectHotel() async {
    if (hotelOwners.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No registered hotels are available")),
      );

      return;
    }

    final hotel = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tag a Hotel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Select one registered hotel for this video.",
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),

                const SizedBox(height: 20),

                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: hotelOwners.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: Colors.white12),
                    itemBuilder: (context, index) {
                      final hotel = hotelOwners[index];

                      final name =
                          hotel['fullName']?.toString() ?? "Unnamed Hotel";

                      final email = hotel['email']?.toString() ?? "";

                      final profileImage = hotel['profileImage']?.toString();

                      return ListTile(
                        contentPadding: EdgeInsets.zero,

                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white12,
                          backgroundImage:
                              profileImage != null && profileImage.isNotEmpty
                              ? AssetImage(profileImage)
                              : null,
                          child: profileImage == null || profileImage.isEmpty
                              ? const Icon(Icons.hotel, color: Colors.white)
                              : null,
                        ),

                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),

                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white38,
                          size: 16,
                        ),

                        onTap: () {
                          Navigator.pop(context, hotel);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (hotel != null && mounted) {
      setState(() {
        selectedHotel = hotel;
      });
    }
  }

  // ============================================================
  // POST VIDEO
  // ============================================================

  Future<void> postVideo() async {
    final caption = captionController.text.trim();

    if (selectedVideo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a video")));

      return;
    }

    if (caption.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a caption")));

      return;
    }

    // HOTEL TAG IS REQUIRED
    if (selectedHotel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please tag a hotel before posting")),
      );

      return;
    }

    setState(() {
      posting = true;
    });

    /*
      Later send this information to your backend:

      video
      caption
      taggedHotelId

      Example:

      final taggedHotelId = selectedHotel!['id'];
    */

    final taggedHotelId = selectedHotel!['id'];
    final taggedHotelName = selectedHotel!['fullName'];

    debugPrint("VIDEO: $selectedVideo");
    debugPrint("CAPTION: $caption");
    debugPrint("TAGGED HOTEL ID: $taggedHotelId");
    debugPrint("TAGGED HOTEL: $taggedHotelName");

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      posting = false;
    });

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Video Posted", style: TextStyle(color: Colors.white)),
            ],
          ),

          content: Text(
            "Your video has been posted and tagged with $taggedHotelName.",
            style: const TextStyle(color: Colors.white70),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          "Create Video",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // VIDEO PREVIEW
              // ==================================================
              GestureDetector(
                onTap: selectVideo,

                child: Container(
                  width: double.infinity,
                  height: 230,

                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),

                  child: selectedVideo == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              color: Colors.white,
                              size: 55,
                            ),

                            SizedBox(height: 15),

                            Text(
                              "Select Video",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6),

                            Text(
                              "Tap to choose a video",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 55,
                            ),

                            SizedBox(height: 15),

                            Text(
                              "Video Selected",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6),

                            Text(
                              "Tap to change video",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // CAPTION
              // ==================================================
              const Text(
                "Caption",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: captionController,
                maxLines: 4,

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  hintText: "Write something about your video...",
                  hintStyle: const TextStyle(color: Colors.white38),

                  filled: true,
                  fillColor: const Color(0xFF181818),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // TAG HOTEL
              // ==================================================
              Row(
                children: [
                  const Text(
                    "Tag Hotel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Text(
                    "*",
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              loadingHotels
                  ? Container(
                      height: 70,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF181818),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : GestureDetector(
                      onTap: selectHotel,

                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),

                        decoration: BoxDecoration(
                          color: const Color(0xFF181818),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedHotel != null
                                ? Colors.white24
                                : Colors.red.withValues(alpha: .4),
                          ),
                        ),

                        child: selectedHotel == null
                            ? const Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white10,
                                    child: Icon(
                                      Icons.hotel,
                                      color: Colors.white,
                                    ),
                                  ),

                                  SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Select a hotel",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Choose one registered hotel",
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white54,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white10,
                                    backgroundImage:
                                        selectedHotel!['profileImage'] != null
                                        ? AssetImage(
                                            selectedHotel!['profileImage'],
                                          )
                                        : null,
                                    child:
                                        selectedHotel!['profileImage'] == null
                                        ? const Icon(
                                            Icons.hotel,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedHotel!['fullName'] ?? "Hotel",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        const Text(
                                          "Registered hotel",
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                      ),
                    ),

              const SizedBox(height: 30),

              // ==================================================
              // POST BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton.icon(
                  onPressed: posting ? null : postVideo,

                  icon: posting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.publish),

                  label: Text(posting ? "Posting..." : "Post Video"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2454E8),
                    foregroundColor: Colors.white,

                    disabledBackgroundColor: const Color(
                      0xFF2454E8,
                    ).withValues(alpha: .5),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }
}

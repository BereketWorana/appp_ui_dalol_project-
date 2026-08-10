import 'package:flutter/material.dart';

class HotelAdminUploadScreen extends StatefulWidget {
  const HotelAdminUploadScreen({super.key});

  @override
  State<HotelAdminUploadScreen> createState() => _HotelAdminUploadScreenState();
}

class _HotelAdminUploadScreenState extends State<HotelAdminUploadScreen> {
  final captionController = TextEditingController();

  bool posting = false;

  String? selectedVideo;

  // ============================================================
  // SELECT VIDEO
  // ============================================================

  Future<void> selectVideo() async {
    /*
      Temporary video selector.

      Later connect this to your real video picker/backend.
    */

    setState(() {
      selectedVideo = "selected_video.mp4";
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Video selected")));
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

    setState(() {
      posting = true;
    });

    /*
      Later send:

      video
      caption
      hotelAdminId

      to your backend.
    */

    debugPrint("HOTEL VIDEO: $selectedVideo");
    debugPrint("CAPTION: $caption");

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

          content: const Text(
            "Your hotel video has been posted successfully.",
            style: TextStyle(color: Colors.white70),
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

        centerTitle: true,

        title: const Text(
          "Upload Hotel Video",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // VIDEO
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
                  hintText: "Write something about your hotel...",
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

              const SizedBox(height: 30),

              // ==================================================
              // POST
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

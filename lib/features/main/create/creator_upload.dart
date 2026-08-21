import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart';

class CreatorUploadScreen extends StatefulWidget {
  const CreatorUploadScreen({super.key});

  @override
  State<CreatorUploadScreen> createState() => _CreatorUploadScreenState();
}

class _CreatorUploadScreenState extends State<CreatorUploadScreen> {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = "https://booking.dalloltech.com/api";

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final hashtagsController = TextEditingController();
  final hotelIdController = TextEditingController();

  // ============================================================
  // IMAGE / VIDEO PICKER
  // ============================================================

  final ImagePicker picker = ImagePicker();

  File? selectedMedia;

  String? selectedMediaType;

  // ============================================================
  // STATE
  // ============================================================

  bool posting = false;

  // ============================================================
  // PICK MEDIA
  // ============================================================

  Future<void> selectMedia() async {
    if (posting) return;

    try {
      final XFile? file = await picker.pickMedia();

      if (file == null) {
        return;
      }

      final extension = file.path.split('.').last.toLowerCase();

      final imageExtensions = ["jpg", "jpeg", "png", "gif", "webp"];

      final videoExtensions = ["mp4", "mov", "avi", "mkv", "webm", "3gp"];

      String? type;

      if (imageExtensions.contains(extension)) {
        type = "image";
      } else if (videoExtensions.contains(extension)) {
        type = "video";
      }

      if (type == null) {
        showError("Unsupported media type. Please select an image or video.");

        return;
      }

      final fileObject = File(file.path);

      if (!await fileObject.exists()) {
        showError("The selected file could not be found.");

        return;
      }

      if (!mounted) return;

      setState(() {
        selectedMedia = fileObject;
        selectedMediaType = type;
      });
    } catch (e) {
      debugPrint("Media selection error: $e");

      if (!mounted) return;

      showError("Unable to select the media file.");
    }
  }

  // ============================================================
  // POST VIDEO / IMAGE
  // ============================================================

  Future<void> postContent() async {
    if (posting) return;

    FocusScope.of(context).unfocus();

    // ==========================================================
    // VALIDATE LOGIN
    // ==========================================================

    final user = AuthService.currentUser;
    final accessToken = AuthService.accessToken;

    if (user == null) {
      showError("You are not logged in.");

      return;
    }

    if (accessToken == null || accessToken.isEmpty) {
      showError("Authentication token is missing. Please login again.");

      return;
    }

    // ==========================================================
    // VALIDATE MEDIA
    // ==========================================================

    if (selectedMedia == null || selectedMediaType == null) {
      showError("Please select an image or video.");

      return;
    }

    // ==========================================================
    // VALIDATE TITLE
    // ==========================================================

    final title = titleController.text.trim();

    if (title.isEmpty) {
      showError("Please enter a post title.");

      return;
    }

    if (title.length < 3) {
      showError("Post title must be at least 3 characters.");

      return;
    }

    // ==========================================================
    // DESCRIPTION
    // ==========================================================

    final description = descriptionController.text.trim();

    // ==========================================================
    // HASHTAGS
    // ==========================================================

    final hashtags = hashtagsController.text.trim();

    // ==========================================================
    // HOTEL ID
    // ==========================================================

    final hotelIdText = hotelIdController.text.trim();

    if (hotelIdText.isNotEmpty) {
      final hotelId = int.tryParse(hotelIdText);

      if (hotelId == null || hotelId <= 0) {
        showError("Please enter a valid hotel ID.");

        return;
      }
    }

    // ==========================================================
    // START POSTING
    // ==========================================================

    setState(() {
      posting = true;
    });

    try {
      // ========================================================
      // URL
      // ========================================================

      final uri = Uri.parse("$baseUrl/posts/create");

      // ========================================================
      // MULTIPART REQUEST
      // ========================================================

      final request = http.MultipartRequest("POST", uri);

      // ========================================================
      // HEADERS
      // ========================================================

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $accessToken",
      });

      // ========================================================
      // USER ID
      // ========================================================

      request.fields["user_id"] = user.id.toString();

      // ========================================================
      // TITLE
      // ========================================================

      request.fields["title"] = title;

      // ========================================================
      // DESCRIPTION
      // ========================================================

      if (description.isNotEmpty) {
        request.fields["description"] = description;
      }

      // ========================================================
      // POST TYPE
      // ========================================================

      request.fields["post_type"] = selectedMediaType!;

      // ========================================================
      // HASHTAGS
      // ========================================================

      if (hashtags.isNotEmpty) {
        request.fields["hashtags"] = hashtags;
      }

      // ========================================================
      // HOTEL ID
      // ========================================================

      if (hotelIdText.isNotEmpty) {
        request.fields["hotel_id"] = hotelIdText;
      }

      // ========================================================
      // MEDIA FILE
      // ========================================================

      final mediaFile = await http.MultipartFile.fromPath(
        "media",
        selectedMedia!.path,
      );

      request.files.add(mediaFile);

      // ========================================================
      // DEBUG
      // ========================================================

      debugPrint("========================================");
      debugPrint("CREATE POST REQUEST");
      debugPrint("========================================");
      debugPrint("User ID: ${user.id}");
      debugPrint("Title: $title");
      debugPrint("Description: $description");
      debugPrint("Post Type: $selectedMediaType");
      debugPrint("Hashtags: $hashtags");
      debugPrint("Hotel ID: $hotelIdText");
      debugPrint("Media: ${selectedMedia!.path}");
      debugPrint("========================================");

      // ========================================================
      // SEND
      // ========================================================

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      debugPrint("========================================");
      debugPrint("CREATE POST RESPONSE");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
      debugPrint("========================================");

      // ========================================================
      // PARSE RESPONSE
      // ========================================================

      Map<String, dynamic>? body;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } catch (_) {
        body = null;
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body != null &&
          body["success"] == true) {
        setState(() {
          posting = false;
        });

        final postId = body["post_id"]?.toString() ?? "";

        final mediaUrls = body["media_urls"];

        String mediaUrl = "";

        if (mediaUrls is List && mediaUrls.isNotEmpty) {
          mediaUrl = mediaUrls.first.toString();
        }

        await showSuccessDialog(postId: postId, mediaUrl: mediaUrl);

        if (!mounted) return;

        Navigator.pop(context);

        return;
      }

      // ========================================================
      // API ERROR
      // ========================================================

      setState(() {
        posting = false;
      });

      final message = parseApiError(response.statusCode, body, response.body);

      showError(message);
    } on SocketException {
      if (!mounted) return;

      setState(() {
        posting = false;
      });

      showError(
        "Unable to connect to the server. Please check your internet connection.",
      );
    } on http.ClientException {
      if (!mounted) return;

      setState(() {
        posting = false;
      });

      showError("Unable to connect to the server.");
    } catch (e) {
      debugPrint("Create post error: $e");

      if (!mounted) return;

      setState(() {
        posting = false;
      });

      showError("Unable to create the post. Please try again.");
    }
  }

  // ============================================================
  // PARSE API ERROR
  // ============================================================

  String parseApiError(
    int statusCode,
    Map<String, dynamic>? body,
    String rawBody,
  ) {
    // ==========================================================
    // API MESSAGE
    // ==========================================================

    if (body != null) {
      final message = body["message"];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      // ========================================================
      // API "MESSAGES"
      // ========================================================

      final messages = body["messages"];

      if (messages is Map) {
        final errors = <String>[];

        messages.forEach((key, value) {
          if (value is String) {
            errors.add(value);
          } else if (value is List) {
            for (final item in value) {
              errors.add(item.toString());
            }
          }
        });

        if (errors.isNotEmpty) {
          return errors.join("\n");
        }
      }

      // ========================================================
      // API "ERRORS"
      // ========================================================

      final errors = body["errors"];

      if (errors is Map) {
        final errorMessages = <String>[];

        errors.forEach((key, value) {
          if (value is String) {
            errorMessages.add(value);
          } else if (value is List) {
            for (final item in value) {
              errorMessages.add(item.toString());
            }
          }
        });

        if (errorMessages.isNotEmpty) {
          return errorMessages.join("\n");
        }
      }
    }

    // ==========================================================
    // STATUS CODES
    // ==========================================================

    if (statusCode == 401) {
      return "Your session has expired. Please login again.";
    }

    if (statusCode == 403) {
      return "You are not allowed to create posts.";
    }

    if (statusCode == 422) {
      return "Please check the information you entered.";
    }

    if (statusCode >= 500) {
      return "Server error. Please try again later.";
    }

    // ==========================================================
    // HTML RESPONSE
    // ==========================================================

    final lower = rawBody.toLowerCase();

    if (lower.contains("<html") ||
        lower.contains("<!doctype") ||
        lower.contains("<body")) {
      return "The server returned an invalid response.";
    }

    return "Post creation failed. Please try again.";
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> showSuccessDialog({
    required String postId,
    required String mediaUrl,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
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
              Expanded(
                child: Text(
                  "Post Created",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your post was successfully uploaded.",
                style: TextStyle(color: Colors.white70),
              ),

              if (postId.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  "Post ID: $postId",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],

              if (mediaUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  "Media uploaded successfully.",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // MEDIA PREVIEW
  // ============================================================

  Widget mediaPreview() {
    if (selectedMedia == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, color: Colors.white, size: 55),
          SizedBox(height: 15),
          Text(
            "Select Image or Video",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text("Tap to choose media", style: TextStyle(color: Colors.white54)),
        ],
      );
    }

    if (selectedMediaType == "image") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          selectedMedia!,
          width: double.infinity,
          height: 230,
          fit: BoxFit.cover,
        ),
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 55),
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
        Text("Tap to change video", style: TextStyle(color: Colors.white54)),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget field(
    String hint,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: !posting,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white70),
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
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Post",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // USER
                    // ==================================================
                    if (user != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.white12,
                              child: Icon(Icons.person, color: Colors.white),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "User ID: ${user.id}",
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // MEDIA
                    // ==================================================
                    GestureDetector(
                      onTap: posting ? null : selectMedia,

                      child: Container(
                        width: double.infinity,
                        height: 230,

                        decoration: BoxDecoration(
                          color: const Color(0xFF181818),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),

                        child: mediaPreview(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // TITLE
                    // ==================================================
                    const Text(
                      "Title",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    field("Enter post title", Icons.title, titleController),

                    const SizedBox(height: 20),

                    // ==================================================
                    // DESCRIPTION
                    // ==================================================
                    const Text(
                      "Description",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    field(
                      "Write something about your post...",
                      Icons.description_outlined,
                      descriptionController,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // HASHTAGS
                    // ==================================================
                    const Text(
                      "Hashtags",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    field(
                      "travel, ethiopia, adventure",
                      Icons.tag,
                      hashtagsController,
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // HOTEL
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

                        const SizedBox(width: 6),

                        const Text(
                          "(Optional)",
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "For now, enter the hotel ID manually.",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),

                    const SizedBox(height: 10),

                    field(
                      "Hotel ID e.g. 1",
                      Icons.hotel_outlined,
                      hotelIdController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ========================================================
            // POST BUTTON
            // ========================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),

              child: SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: posting ? null : postContent,

                  icon: posting
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.publish),

                  label: Text(posting ? "Uploading..." : "Create Post"),

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
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    hashtagsController.dispose();
    hotelIdController.dispose();

    super.dispose();
  }
}

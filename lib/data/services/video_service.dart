import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/video.dart';

class VideoService {
  static const String baseUrl = "https://booking.dalloltech.com/api";

  // ============================================================
  // GET FEED
  // ============================================================

  static Future<List<Video>> getVideos({
    required int userId,
    required String accessToken,
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/posts/feed"
      "?user_id=$userId"
      "&limit=$limit"
      "&offset=$offset",
    );

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    print("FEED STATUS: ${response.statusCode}");
    print("FEED RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load feed: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid feed response.");
    }

    if (decoded["success"] != true) {
      throw Exception(decoded["message"]?.toString() ?? "Failed to load feed.");
    }

    final rawData = decoded["data"];

    if (rawData is! List) {
      return [];
    }

    final List<Video> result = [];

    for (final item in rawData) {
      if (item is Map) {
        try {
          final video = Video.fromJson(Map<String, dynamic>.from(item));
          if (video.mediaUrls.isNotEmpty &&
              !video.mediaUrls.first.contains('1787385729_f6f5ff8e2cb78978.mp4')) {
            result.add(video);
          }
        } catch (e) {
          print("Video parse error: $e");
        }
      }
    }

    return result;
  }
}

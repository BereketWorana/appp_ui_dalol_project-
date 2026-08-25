import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/post.dart';
import '../dummy/feed_dummy.dart';

// ============================================================
// FEED SERVICE
// ============================================================
//
// Hits GET https://booking.dalloltech.com/api/posts/feed
//
// Pagination (offset-based, confirmed from API response):
//   Request:  ?offset=0&limit=10
//   Response: { "success": true, "data": [...], "has_more": true, "offset": 0 }
//
// FALLBACK BEHAVIOR:
//   If the API returns an empty list (backend not yet seeded),
//   this service falls back to mockPosts so the UI always has
//   content to display during development.
//
//   To disable the fallback once the backend is seeded:
//   → Delete the two lines marked [REMOVE WHEN API SEEDED]

class FeedService {
  // ============================================================
  // BASE URL
  // ============================================================

  static const String _baseUrl = 'https://booking.dalloltech.com';

  // ============================================================
  // GET FEED
  // ============================================================

  /// Fetches paginated feed posts.
  ///
  /// [offset] — number of posts already loaded (starts at 0).
  /// [limit]  — how many posts to fetch per page (default 10).
  ///
  /// Returns a [FeedResult] with the post list and pagination info.
  static Future<FeedResult> getFeed({
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api/posts/feed?offset=$offset&limit=$limit',
      );
      
      debugPrint('GET $uri');

      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 10));
          
      debugPrint('Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final rawList = body['data'] as List<dynamic>? ?? [];
        final hasMore = body['has_more'] as bool? ?? false;

        final posts = rawList
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();

        // --------------------------------------------------------
        // [REMOVE WHEN API SEEDED] Fallback to mock data
        // --------------------------------------------------------
        if (posts.isEmpty && offset == 0) {
          debugPrint('Using mock data because API returned empty list');
          return FeedResult(posts: mockPosts, hasMore: false);
        }

        return FeedResult(posts: posts, hasMore: hasMore);
      }

      // Handle specific errors
      if (response.statusCode == 401) {
        throw Exception('Unauthorized - token expired. Please login again.');
      }
      if (response.statusCode == 404) {
        throw Exception('Feed endpoint not found');
      }
      if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      }

      // Fallback on network errors for initial load
      if (offset == 0) {
        debugPrint('Using mock data due to network error/non-200 status');
        return FeedResult(posts: mockPosts, hasMore: false);
      }
      
      throw Exception('Failed to load feed: ${response.statusCode}');
    } on SocketException {
      // No internet connection
      if (offset == 0) {
        debugPrint('SocketException: Using mock data');
        return FeedResult(posts: mockPosts, hasMore: false);
      }
      rethrow;
    } on HttpException {
      if (offset == 0) {
        debugPrint('HttpException: Using mock data');
        return FeedResult(posts: mockPosts, hasMore: false);
      }
      rethrow;
    }
  }

  // ============================================================
  // HEADERS
  // ============================================================

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}

// ============================================================
// FEED RESULT
// ============================================================

class FeedResult {
  final List<Post> posts;
  final bool hasMore;

  const FeedResult({required this.posts, required this.hasMore});
}

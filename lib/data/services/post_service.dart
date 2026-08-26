import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/services/auth_service.dart';
import '../models/comment.dart';
import '../models/post.dart';

class PostService {
  static const String _baseUrl = 'https://booking.dalloltech.com';

  static Future<Map<String, String>> _headers() async {
    final token = AuthService.accessToken;
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Toggles like status for a post.
  static Future<bool> toggleLike(int postId) async {
    final uri = Uri.parse('$_baseUrl/api/posts/like');
    debugPrint('POST $uri');

    final response = await http
        .post(
          uri,
          headers: await _headers(),
          body: json.encode({
            'post_id': postId,
            'user_id': AuthService.currentUser?.id ?? 0,
          }),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint('Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception('Failed to toggle like: ${response.statusCode}');
  }

  /// Submits a comment to a post.
  static Future<Comment> submitComment(int postId, String text) async {
    final uri = Uri.parse('$_baseUrl/api/posts/comment');
    debugPrint('POST $uri');

    final response = await http
        .post(
          uri,
          headers: await _headers(),
          body: json.encode({
            'post_id': postId,
            'user_id': AuthService.currentUser?.id ?? 0,
            'comment': text,
          }),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint('Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body.containsKey('comment') && body['comment'] != null) {
          return Comment.fromJson(body['comment'] as Map<String, dynamic>);
        }
        return Comment(
          id: body['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          postId: postId,
          userId: 1,
          userName: 'Current User',
          userAvatar: 'assets/images/r1.jpg',
          text: text,
          createdAt: DateTime.now(),
        );
      } catch (e) {
        debugPrint('Error parsing comment response: $e');
        return Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          postId: postId,
          userId: 1,
          userName: 'Current User',
          userAvatar: 'assets/images/r1.jpg',
          text: text,
          createdAt: DateTime.now(),
        );
      }
    }

    throw Exception('Failed to submit comment: ${response.statusCode}');
  }
  
  /// Fetches comments for a post.
  static Future<List<Comment>> getComments(int postId, {int offset = 0, int limit = 50}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/posts/comments/$postId?limit=$limit&offset=$offset');
      debugPrint('GET $uri');

      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          final rawList = body['data'] as List<dynamic>;
          return rawList
              .map((c) => Comment.fromJson(c as Map<String, dynamic>))
              .toList();
        }
      }
      return []; // Return empty list instead of throwing on failure
    } catch (e) {
      debugPrint('Failed to fetch comments: $e');
      return [];
    }
  }

  /// Tracks when a post becomes visible.
  /// Fire-and-forget: never awaited, never blocks the UI.
  static void trackView(int postId) {
    final uri = Uri.parse('$_baseUrl/api/posts/view');
    _headers().then((headers) {
      http
          .post(
            uri,
            headers: headers,
            body: json.encode({'post_id': postId}),
          )
          .catchError((e) {
            debugPrint('trackView failed for post $postId: $e');
            return http.Response('', 500);
          });
    }).catchError((e) {
      debugPrint('trackView header error for post $postId: $e');
    });
  }

  /// Shares a post.
  static Future<bool> sharePost(int postId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// Fetches posts for a specific user.
  static Future<List<Post>> getUserPosts(int userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock: return a few posts by this user
    return [
      Post(
        id: DateTime.now().millisecondsSinceEpoch, // Unique ID for mock
        ownerId: userId,
        ownerName: 'User Name',
        ownerAvatar: 'assets/images/r1.jpg',
        ownerRole: 'consumer',
        ownerUsername: '@username',
        mediaUrl: 'assets/videos/v2.mp4',
        mediaType: 'video',
        thumbnail: 'assets/images/r1.jpg',
        caption: 'My first post',
        hashtags: ['first'],
        likes: 120,
        comments: 5,
        shares: 2,
        bookmarks: 0,
        location: 'Addis Ababa',
        rating: 4.5,
        price: 3500,
        isLiked: false,
        isFollowing: false,
        createdAt: DateTime.now(),
      ),
      Post(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        ownerId: userId,
        ownerName: 'User Name',
        ownerAvatar: 'assets/images/r1.jpg',
        ownerRole: 'merchant',
        ownerUsername: '@username',
        mediaUrl: 'assets/videos/v3.mp4',
        mediaType: 'video',
        thumbnail: 'assets/images/r1.jpg',
        caption: 'Another beautiful day',
        hashtags: ['beautiful'],
        likes: 85,
        comments: 12,
        shares: 4,
        bookmarks: 1,
        location: 'Bishoftu',
        rating: 5.0,
        price: 5000,
        isLiked: false,
        isFollowing: false,
        hotelId: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/services/auth_service.dart';

class FollowService {
  static const String _baseUrl = 'https://booking.dalloltech.com';

  static Future<Map<String, String>> _headers() async {
    final token = AuthService.accessToken;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Toggles follow status for a user.
  ///
  /// If [isFollowing] is true (user wants to unfollow):
  ///   → POST /api/unfollow/{id} with {follower_id}
  ///
  /// If [isFollowing] is false or null (user wants to follow):
  ///   → POST /api/follow/{id} with {follower_id}
  static Future<bool> toggleFollow(int userId, {bool? isFollowing}) async {
    final currentUserId = AuthService.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('You must be logged in to follow users');
    }

    final bool wantsToUnfollow = isFollowing == true;
    final String endpoint = wantsToUnfollow
        ? '$_baseUrl/api/unfollow/$userId'
        : '$_baseUrl/api/follow/$userId';
    final uri = Uri.parse(endpoint);

    debugPrint('POST $uri');

    final response = await http
        .post(
          uri,
          headers: await _headers(),
          body: json.encode({
            'follower_id': currentUserId,
          }),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint('Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception(
        'Failed to ${wantsToUnfollow ? "unfollow" : "follow"}: ${response.statusCode}');
  }
}

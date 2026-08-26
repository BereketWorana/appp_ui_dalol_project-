import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FollowService {
  static const String _baseUrl = 'https://booking.dalloltech.com';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Toggles follow status for a user.
  /// Issues DELETE to /api/unfollow/{id} if [isFollowing] is false,
  /// otherwise issues POST to /api/follow/{id}.
  static Future<bool> toggleFollow(int userId, {bool? isFollowing}) async {
    final isUnfollow = isFollowing == false;
    final path = isUnfollow ? '/api/unfollow/$userId' : '/api/follow/$userId';
    final uri = Uri.parse('$_baseUrl$path');
    
    debugPrint('${isUnfollow ? "DELETE" : "POST"} $uri');

    final response = isUnfollow
        ? await http
            .delete(uri, headers: await _headers())
            .timeout(const Duration(seconds: 10))
        : await http
            .post(uri, headers: await _headers())
            .timeout(const Duration(seconds: 10));

    debugPrint('Response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception('Failed to update follow status: ${response.statusCode}');
  }
}

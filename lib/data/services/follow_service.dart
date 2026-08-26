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
    // MOCK SUCCESS FOR DEMO (Backend API is not ready)
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}

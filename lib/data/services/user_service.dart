import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/services/api_service.dart';
import '../../data/models/user.dart';

class UserService {
  // ============================================================
  // FETCH USER BY ID FROM BACKEND (CLIENT-SIDE FILTERED)
  // ============================================================

  /// Fetches all profiles from GET /api/profiles and filters client-side
  /// to find the single user matching [id].
  ///
  /// Strictly checks the JSON body's `success` field rather than relying
  /// on HTTP status codes. Throws an Exception if the API fails or if
  /// the requested user ID is not found.
  static Future<User> getUserByIdFromApi(int id) async {
    final response = await ApiService.get('/profiles');

    if (response['success'] == false) {
      final msg = response['message'] ?? 'Failed to fetch user profiles';
      throw Exception(msg);
    }

    final data = response['data'];
    if (data is! List) {
      throw Exception('Invalid user profiles payload from server');
    }

    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final itemId = int.tryParse(item['id']?.toString() ?? '');
        if (itemId == id) {
          return User.fromJson(item);
        }
      }
    }

    throw Exception('User with ID $id not found');
  }

  // ============================================================
  // LOCAL USERS
  // ============================================================

  /// Returns users from the local JSON file.
  ///
  /// This can still be used by parts of the application
  /// that have not yet been connected to the backend.
  static Future<List<User>> getUsers() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/users.json',
    );

    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((user) => User.fromJson(user)).toList();
  }

  // ============================================================
  // LOCAL LOGIN
  // ============================================================

  /// Temporary local login.
  ///
  /// This remains available until the Login task is connected
  /// to POST /api/auth/login.
  static Future<User?> login(String username, String password) async {
    final users = await getUsers();

    try {
      return users.firstWhere(
        (user) =>
            (user.email.toLowerCase() == username.toLowerCase() ||
                user.phone == username) &&
            user.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // GET USER BY ID
  // ============================================================

  static Future<User?> getUserById(int id) async {
    final users = await getUsers();

    try {
      return users.firstWhere((user) => user.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // CONSUMERS
  // ============================================================

  static Future<List<User>> getConsumers() async {
    final users = await getUsers();

    return users.where((user) => user.role == "consumer").toList();
  }

  // ============================================================
  // CREATORS
  // ============================================================

  static Future<List<User>> getCreators() async {
    final users = await getUsers();

    return users.where((user) => user.role == "creator").toList();
  }

  // ============================================================
  // MERCHANTS
  // ============================================================

  static Future<List<User>> getMerchants() async {
    final users = await getUsers();

    return users.where((user) => user.role == "merchant").toList();
  }
}

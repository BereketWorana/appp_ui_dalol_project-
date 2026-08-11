import 'dart:convert';

import 'package:flutter/services.dart';

import '../../data/models/user.dart';

class UserService {
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

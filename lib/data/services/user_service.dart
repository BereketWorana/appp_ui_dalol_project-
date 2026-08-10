import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/user.dart';

class UserService {
  /// Returns all users from users.json
  static Future<List<User>> getUsers() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/users.json',
    );

    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((user) => User.fromJson(user)).toList();
  }

  /// Login using phone OR email
  static Future<User?> login(String username, String password) async {
    final users = await getUsers();

    try {
      return users.firstWhere(
        (user) =>
            (user.email.toLowerCase() == username.toLowerCase() ||
                user.phone == username) &&
            user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get user by ID
  static Future<User?> getUserById(int id) async {
    final users = await getUsers();

    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all consumers
  static Future<List<User>> getConsumers() async {
    final users = await getUsers();

    return users.where((user) => user.role == "consumer").toList();
  }

  /// Get all creators
  static Future<List<User>> getCreators() async {
    final users = await getUsers();

    return users.where((user) => user.role == "creator").toList();
  }

  /// Get all merchants
  static Future<List<User>> getMerchants() async {
    final users = await getUsers();

    return users.where((user) => user.role == "merchant").toList();
  }
}

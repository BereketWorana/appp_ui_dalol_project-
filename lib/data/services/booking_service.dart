import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/booking.dart';
import '../models/user.dart';
import '../../core/services/auth_service.dart';
import 'user_service.dart';

class BookingService {
  /// Load all bookings
  static Future<List<Booking>> getBookings() async {
    final jsonString = await rootBundle.loadString('assets/data/bookings.json');

    final List<dynamic> data = json.decode(jsonString);

    return data.map((e) => Booking.fromJson(e)).toList();
  }

  /// Current user's bookings
  static Future<List<Booking>> getMyBookings() async {
    if (!AuthService.isLoggedIn) {
      return [];
    }

    final bookings = await getBookings();

    return bookings
        .where((b) => b.consumerId == AuthService.currentUser!.id)
        .toList();
  }

  /// Find merchant (hotel)
  static Future<User?> getMerchant(int merchantId) async {
    final users = await UserService.getUsers();

    try {
      return users.firstWhere((u) => u.id == merchantId);
    } catch (_) {
      return null;
    }
  }

  /// Booking status color
  static String getStatus(String status) {
    return status.toLowerCase();
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/booking.dart';
import '../models/user.dart';
import '../../core/services/auth_service.dart';
import 'user_service.dart';

class BookingService {
  /// Load all local bookings.
  ///
  /// This is kept for the existing UI until the booking API
  /// is connected.
  static Future<List<Booking>> getBookings() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/bookings.json',
      );

      final List<dynamic> data = json.decode(jsonString);

      return data
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get bookings belonging to the currently logged-in user.
  static Future<List<Booking>> getMyBookings() async {
    final user = AuthService.currentUser;

    if (user == null) {
      return [];
    }

    final bookings = await getBookings();

    return bookings.where((booking) {
      return booking.consumerId == user.id;
    }).toList();
  }

  /// Find a merchant/hotel by user ID.
  static Future<User?> getMerchant(int merchantId) async {
    try {
      final users = await UserService.getUsers();

      return users.firstWhere((user) => user.id == merchantId);
    } catch (e) {
      return null;
    }
  }

  /// Normalize booking status.
  static String getStatus(String status) {
    return status.trim().toLowerCase();
  }
}

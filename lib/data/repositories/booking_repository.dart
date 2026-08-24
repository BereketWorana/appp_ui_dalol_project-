import 'dart:convert';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../models/booking.dart';

class BookingRepository {
  // ============================================================
  // CREATE BOOKING - Guest booking (no login required)
  // ============================================================
  
  static Future<Map<String, dynamic>> createBooking({
    required int roomId,
    required int hotelId,
    required String checkIn,
    required String checkOut,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
    int adults = 1,
    int children = 0,
    int rooms = 1,
    double totalPrice = 0,
    String paymentMethod = 'pay_at_hotel',
    String? specialRequests,
    int? userId,
  }) async {
    try {
      final body = {
        'room_id': roomId,
        'hotel_id': hotelId,
        'check_in': checkIn,
        'check_out': checkOut,
        'adults': adults,
        'children': children,
        'rooms': rooms,
        'total_price': totalPrice.toString(),
        'payment_method': paymentMethod,
        'guest_name': guestName,
        'guest_email': guestEmail,
        'guest_phone': guestPhone,
      };

      if (specialRequests != null && specialRequests.isNotEmpty) {
        body['special_requests'] = specialRequests;
      }

      if (userId != null && userId > 0) {
        body['user_id'] = userId;
      }

      print('📝 ===== CREATING BOOKING =====');
      print('📝 Body: ${jsonEncode(body)}');
      
      final response = await ApiService.post(
        '/bookings',
        body: body,
        requireAuth: false,
      );
      
      print('📝 Booking Response: $response');
      return response;
    } catch (e) {
      print('❌ Booking creation exception: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // ============================================================
  // GET USER BOOKINGS (Requires login)
  // ============================================================
  
  static Future<List<Booking>> getUserBookings({
    String? email,
    int? userId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (email != null) queryParams['email'] = email;
      if (userId != null) queryParams['user_id'] = userId.toString();

      final response = await ApiService.get(
        '/bookings/user',
        queryParams: queryParams,
        requireAuth: true,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((item) => Booking.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Get bookings failed: $e');
      return [];
    }
  }

  // ============================================================
  // GET SINGLE BOOKING
  // ============================================================
  
  static Future<Map<String, dynamic>> getBooking(int bookingId) async {
    try {
      final response = await ApiService.get(
        '/bookings/$bookingId',
        requireAuth: true,
      );
      return response;
    } catch (e) {
      print('❌ Get booking failed: $e');
      rethrow;
    }
  }

  // ============================================================
  // CANCEL BOOKING
  // ============================================================
  
  static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final response = await ApiService.post(
        '/bookings/cancel/$bookingId',
        requireAuth: true,
      );
      return response;
    } catch (e) {
      print('❌ Cancel booking failed: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET BOOKING STATISTICS
  // ============================================================
  
  static Future<Map<String, dynamic>> getStats({int? hotelId}) async {
    try {
      final queryParams = <String, String>{};
      if (hotelId != null) queryParams['hotel_id'] = hotelId.toString();

      final response = await ApiService.get(
        '/bookings/stats',
        queryParams: queryParams,
        requireAuth: true,
      );
      return response;
    } catch (e) {
      print('❌ Get stats failed: $e');
      rethrow;
    }
  }
}
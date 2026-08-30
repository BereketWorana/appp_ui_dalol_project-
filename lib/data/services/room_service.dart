import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../models/room.dart';

class RoomService {
  // ============================================================
  // GET ROOMS BY HOTEL
  // ============================================================

  /// Fetches rooms for a specific hotel from the backend.
  /// GET /api/rooms/hotel/{hotelId}
  /// Throws exception on network/server errors so UI can render Retry UI.
  static Future<List<Room>> getRoomsByHotel(int hotelId) async {
    debugPrint('🏨 Fetching rooms for hotel ID: $hotelId');

    final response = await ApiService.get(
      '/rooms/hotel/$hotelId',
      requireAuth: false,
    );

    debugPrint('📥 Response for hotel $hotelId: $response');

    if (response['success'] == false && response.containsKey('message')) {
      throw Exception(response['message']);
    }

    final dynamic rawData = response['data'] ?? response['rooms'];

    if (rawData is List) {
      return rawData
          .map((item) => Room.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  // ============================================================
  // CHECK AVAILABILITY
  // ============================================================

  /// Checks room availability for a hotel given dates and guest count.
  /// POST /api/rooms/check-availability
  /// Body: {"hotel_id": hotelId, "check_in": checkIn, "check_out": checkOut, "guests": guests}
  /// Throws exception on network/server errors.
  static Future<List<Room>> checkAvailability(
    int hotelId,
    String checkIn,
    String checkOut,
    int guests,
  ) async {
    debugPrint(
      '🏨 Checking room availability for hotel ID: $hotelId ($checkIn -> $checkOut, guests: $guests)',
    );

    final response = await ApiService.post(
      '/rooms/check-availability',
      body: {
        'hotel_id': hotelId,
        'check_in': checkIn,
        'check_out': checkOut,
        'guests': guests,
      },
      requireAuth: false,
    );

    debugPrint('📥 Response for availability check: $response');

    if (response['success'] == false && response.containsKey('message')) {
      throw Exception(response['message']);
    }

    final dynamic rawData =
        response['data'] ??
        response['available_rooms'] ??
        response['rooms'];

    if (rawData is List) {
      return rawData
          .map((item) => Room.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }
}

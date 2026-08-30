import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../models/room.dart';
import '../models/room_type.dart';

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

  // ============================================================
  // CREATE ROOM
  // ============================================================

  /// Creates a new room for a hotel.
  /// POST /api/rooms (requireAuth: true)
  /// Body: {hotel_id, room_type_id, name, price_per_night, remaining_rooms, max_occupancy, description, bed_type}
  /// Throws exception on error so calling UI can display real error message.
  static Future<Map<String, dynamic>> createRoom({
    required int hotelId,
    required int roomTypeId,
    required String name,
    required double pricePerNight,
    required int remainingRooms,
    required int maxOccupancy,
    String? description,
    String? bedType,
  }) async {
    debugPrint('🏨 Creating room "$name" for hotel ID: $hotelId');

    final body = <String, dynamic>{
      'hotel_id': hotelId,
      'room_type_id': roomTypeId,
      'name': name,
      'price_per_night': pricePerNight,
      'remaining_rooms': remainingRooms,
      'max_occupancy': maxOccupancy,
    };

    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }
    if (bedType != null && bedType.trim().isNotEmpty) {
      body['bed_type'] = bedType.trim();
    }

    final response = await ApiService.post(
      '/rooms',
      body: body,
      requireAuth: true,
    );

    debugPrint('📥 Response for createRoom: $response');

    if (response['success'] == false && response.containsKey('message')) {
      throw Exception(response['message']);
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    return response;
  }

  // ============================================================
  // GET ROOM TYPES
  // ============================================================

  /// Fetches available room types for dropdown population.
  /// GET /api/room-types (requireAuth: false)
  /// Throws exception on error.
  static Future<List<RoomType>> getRoomTypes() async {
    debugPrint('🏨 Fetching room types');

    final response = await ApiService.get(
      '/room-types',
      requireAuth: false,
    );

    debugPrint('📥 Response for room types: $response');

    if (response['success'] == false && response.containsKey('message')) {
      throw Exception(response['message']);
    }

    final dynamic rawData = response['data'] ?? response['room_types'];

    if (rawData is List) {
      return rawData
          .map((item) => RoomType.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }
}

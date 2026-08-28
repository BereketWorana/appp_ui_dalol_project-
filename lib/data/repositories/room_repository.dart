import '../../core/services/api_service.dart';
import '../models/room.dart';

class RoomRepository {
  // ============================================================
  // CHECK AVAILABILITY BY HOTEL
  // ============================================================
  
  static Future<Map<String, dynamic>> checkAvailabilityByHotel({
    required int hotelId,
    required String checkIn,
    required String checkOut,
    int rooms = 1,
  }) async {
    try {
      print('🏨 ===== CHECK AVAILABILITY =====');
      print('🏨 Hotel ID: $hotelId');
      print('🏨 Check-in: $checkIn');
      print('🏨 Check-out: $checkOut');
      
      final response = await ApiService.get(
        '/check-availability-by-hotel',
        queryParams: {
          'hotel_id': hotelId.toString(),
          'check_in': checkIn,
          'check_out': checkOut,
          'rooms': rooms.toString(),
        },
        requireAuth: false,
      );
      
      print('🏨 API Response: $response');
      return response;
    } catch (e) {
      print('❌ Availability check failed: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET ROOMS BY HOTEL
  // ============================================================
  
  static Future<List<Room>> getRoomsByHotel({
    required int hotelId,
    required String checkIn,
    required String checkOut,
    int rooms = 1,
  }) async {
    try {
      final response = await checkAvailabilityByHotel(
        hotelId: hotelId,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: rooms,
      );
      
      if (response['success'] == true) {
        final List<dynamic> roomsData = response['available_rooms'] ?? [];
        print('📦 Found ${roomsData.length} rooms');
        
        if (roomsData.isEmpty) {
          return [];
        }
        
        final List<Room> roomList = [];
        for (var data in roomsData) {
          try {
            final room = Room.fromJson(data);
            roomList.add(room);
            print('✅ Parsed room: ${room.name}');
          } catch (e) {
            print('❌ Failed to parse room: $e');
          }
        }
        
        return roomList;
      } else {
        print('⚠️ API Error: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('❌ Get rooms by hotel failed: $e');
      return [];
    }
  }

  // ============================================================
  // CHECK AVAILABILITY FOR SPECIFIC ROOM
  // ============================================================
  
  static Future<Map<String, dynamic>> checkAvailability({
    required int roomId,
    required String checkIn,
    required String checkOut,
    int rooms = 1,
  }) async {
    try {
      print('🏨 Checking availability for room: $roomId');
      
      final response = await ApiService.get(
        '/check-availability',
        queryParams: {
          'room_id': roomId.toString(),
          'check_in': checkIn,
          'check_out': checkOut,
          'rooms': rooms.toString(),
        },
        requireAuth: false,
      );
      
      print('✅ Room availability response: $response');
      return response;
    } catch (e) {
      print('❌ Room availability check failed: $e');
      rethrow;
    }
  }
}

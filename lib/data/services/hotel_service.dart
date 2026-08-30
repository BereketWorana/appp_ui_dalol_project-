import '../../core/services/api_service.dart';
import '../models/hotel.dart';

class HotelService {
  // ============================================================
  // GET ALL HOTELS
  // ============================================================

  /// Fetches hotel listing from GET /api/hotels.
  ///
  /// Validates the API response `success` flag explicitly and returns
  /// a list of parsed [Hotel] models. Throws an [Exception] if the request fails.
  static Future<List<Hotel>> getHotels() async {
    final response = await ApiService.get('/hotels');

    if (response['success'] == false) {
      final msg = response['message'] ?? 'Failed to fetch hotels list';
      throw Exception(msg);
    }

    final data = response['data'];
    if (data is! List) {
      throw Exception('Invalid hotels payload from server');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => Hotel.fromJson(json))
        .toList();
  }
}

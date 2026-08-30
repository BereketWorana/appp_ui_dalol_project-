class Room {
  final int id;
  final int hotelId;
  final int roomTypeId;
  final String name;
  final String? description;
  final double pricePerNight;
  final int bookedRooms;
  final int remainingRooms;
  final int maxOccupancy;
  final String bedType;
  final List<String> amenities;
  final List<String> images;
  final String roomNumber;
  final String floor;
  final String status;
  final String? roomFeatures;
  final String? notes;
  final String isActive;
  final int availableRoomsCount;
  final int bookedRoomsCount;

  Room({
    required this.id,
    required this.hotelId,
    required this.roomTypeId,
    required this.name,
    this.description,
    required this.pricePerNight,
    required this.bookedRooms,
    required this.remainingRooms,
    required this.maxOccupancy,
    required this.bedType,
    required this.amenities,
    required this.images,
    required this.roomNumber,
    required this.floor,
    required this.status,
    this.roomFeatures,
    this.notes,
    required this.isActive,
    required this.availableRoomsCount,
    required this.bookedRoomsCount,
  });

  // ============================================================
  // CONVERT JSON TO ROOM OBJECT
  // ============================================================

  factory Room.fromJson(Map<String, dynamic> json) {
    // Parse numeric fields safely (strings or ints/doubles)
    final int id = int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    final int hotelId = int.tryParse(
          json['hotel_id']?.toString() ??
          json['merchantId']?.toString() ??
          '0',
        ) ??
        0;
    final int roomTypeId = int.tryParse(
          json['room_type_id']?.toString() ?? '0',
        ) ??
        0;

    final String name = json['name']?.toString() ??
        json['room_type']?.toString() ??
        json['roomType']?.toString() ??
        'Standard Room';

    final String? description = json['description']?.toString();

    final double pricePerNight = double.tryParse(
          json['price_per_night']?.toString() ??
          json['price']?.toString() ??
          '0',
        ) ??
        0.0;

    final int bookedRooms = int.tryParse(
          json['booked_rooms']?.toString() ?? '0',
        ) ??
        0;

    final int remainingRooms = int.tryParse(
          json['remaining_rooms']?.toString() ??
          json['available_rooms']?.toString() ??
          '0',
        ) ??
        0;

    final int maxOccupancy = int.tryParse(
          json['max_occupancy']?.toString() ??
          json['capacity']?.toString() ??
          '1',
        ) ??
        1;

    final String bedType = json['bed_type']?.toString() ??
        json['room_type']?.toString() ??
        'Queen';

    // Facilities / Amenities parsing
    List<String> amenities = [];
    if (json['amenities'] is List) {
      amenities = List<String>.from(
        (json['amenities'] as List).map((e) => e.toString()),
      );
    } else if (json['facilities'] is List) {
      amenities = List<String>.from(
        (json['facilities'] as List).map((e) => e.toString()),
      );
    } else if (json['facilities'] is String) {
      amenities = (json['facilities'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (amenities.isEmpty) {
      amenities = ['WiFi', 'TV'];
    }

    // Images parsing with relative URL resolution
    List<String> images = [];
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      images = List<String>.from((json['images'] as List).map((e) {
        var url = e.toString().trim();
        if (url.isNotEmpty &&
            !url.startsWith('http') &&
            !url.startsWith('assets/')) {
          url = url.startsWith('/')
              ? 'https://booking.dalloltech.com$url'
              : 'https://booking.dalloltech.com/$url';
        }
        return url;
      }));
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      var url = json['image'].toString().trim();
      if (url.isNotEmpty &&
          !url.startsWith('http') &&
          !url.startsWith('assets/')) {
        url = url.startsWith('/')
            ? 'https://booking.dalloltech.com$url'
            : 'https://booking.dalloltech.com/$url';
      }
      images = [url];
    } else {
      images = ['https://images.unsplash.com/photo-1618773928121-c32242e63f39'];
    }

    final String roomNumber = json['room_number']?.toString() ?? '101';
    final String floor = json['floor']?.toString() ?? '1';
    final String status = json['status']?.toString() ?? 'available';
    final String? roomFeatures = json['room_features']?.toString();
    final String? notes = json['notes']?.toString();
    final String isActive = json['is_active']?.toString() ?? 't';

    final int availableRoomsCount = int.tryParse(
          json['available_rooms']?.toString() ?? remainingRooms.toString(),
        ) ??
        remainingRooms;

    final int bookedRoomsCount = int.tryParse(
          json['booked_rooms_count']?.toString() ?? bookedRooms.toString(),
        ) ??
        bookedRooms;

    return Room(
      id: id,
      hotelId: hotelId,
      roomTypeId: roomTypeId,
      name: name,
      description: description,
      pricePerNight: pricePerNight,
      bookedRooms: bookedRooms,
      remainingRooms: remainingRooms,
      maxOccupancy: maxOccupancy,
      bedType: bedType,
      amenities: amenities,
      images: images,
      roomNumber: roomNumber,
      floor: floor,
      status: status,
      roomFeatures: roomFeatures,
      notes: notes,
      isActive: isActive,
      availableRoomsCount: availableRoomsCount,
      bookedRoomsCount: bookedRoomsCount,
    );
  }

  // ============================================================
  // CONVERT ROOM TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'hotel_id': hotelId.toString(),
      'room_type_id': roomTypeId.toString(),
      'name': name,
      'description': description,
      'price_per_night': pricePerNight.toStringAsFixed(2),
      'booked_rooms': bookedRooms.toString(),
      'remaining_rooms': remainingRooms.toString(),
      'max_occupancy': maxOccupancy.toString(),
      'bed_type': bedType,
      'amenities': amenities,
      'images': images,
      'room_number': roomNumber,
      'floor': floor,
      'status': status,
      'room_features': roomFeatures,
      'notes': notes,
      'is_active': isActive,
      'available_rooms': availableRoomsCount,
      'booked_rooms_count': bookedRoomsCount,
    };
  }

  // ============================================================
  // BACKWARD COMPATIBLE GETTERS
  // ============================================================

  String get roomType => bedType.isNotEmpty ? bedType : name;
  int get capacity => maxOccupancy;
  List<String> get facilities => amenities;
  String get image =>
      images.isNotEmpty
          ? images.first
          : 'https://images.unsplash.com/photo-1618773928121-c32242e63f39';
  int? get merchantId => hotelId > 0 ? hotelId : null;
  bool get isAvailable => remainingRooms > 0 || availableRoomsCount > 0;
  String get formattedPrice => '${pricePerNight.toStringAsFixed(2)} ETB';
  String get occupancyText =>
      '$maxOccupancy Guest${maxOccupancy > 1 ? 's' : ''}';
  String get facilitiesText => facilities.join(', ');
}

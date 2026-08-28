class Room {
  final int id;
  final String name;
  final String roomType;
  final double pricePerNight;
  final int capacity;
  final int maxOccupancy;
  final int remainingRooms;
  final List<String> facilities;
  final String image;
  final String? description;
  final int? merchantId;

  Room({
    required this.id,
    required this.name,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.maxOccupancy,
    required this.remainingRooms,
    required this.facilities,
    required this.image,
    this.description,
    this.merchantId,
  });

  // ============================================================
  // CONVERT JSON TO ROOM OBJECT
  // ============================================================

  factory Room.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing room JSON: $json');
    
    // Parse ID - handle both String and int
    final int id = int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    
    // Get name - try multiple possible keys
    final String name = json['name']?.toString() ?? 
                        json['room_type']?.toString() ?? 
                        json['roomType']?.toString() ?? 
                        'Standard Room';
    
    // Get room type
    final String roomType = json['room_type']?.toString() ?? 
                            json['roomType']?.toString() ?? 
                            name;
    
    // Parse price - handle both String and double
    final double price = double.tryParse(
      json['price_per_night']?.toString() ?? '0'
    ) ?? 0.0;
    
    // Parse max occupancy
    final int maxOcc = int.tryParse(
      json['max_occupancy']?.toString() ?? '1'
    ) ?? 1;
    
    // Parse remaining rooms
    final int remaining = int.tryParse(
      json['remaining_rooms']?.toString() ?? '0'
    ) ?? 0;
    
    // Capacity - use max_occupancy as fallback
    final int capacity = int.tryParse(
      json['capacity']?.toString() ?? maxOcc.toString()
    ) ?? maxOcc;
    
    // Parse facilities
    List<String> facilities = [];
    if (json['facilities'] != null) {
      if (json['facilities'] is List) {
        facilities = List<String>.from(json['facilities']);
      } else if (json['facilities'] is String) {
        facilities = (json['facilities'] as String).split(',').map((e) => e.trim()).toList();
      }
    }
    
    // Default facilities if none provided
    if (facilities.isEmpty) {
      facilities = ['WiFi', 'TV', 'AC'];
    }
    
    // Get image
    String image = json['image']?.toString() ?? 
                   json['images']?[0]?.toString() ?? 
                   json['image_url']?.toString() ?? 
                   'https://images.unsplash.com/photo-1618773928121-c32242e63f39';
    
    // Get merchant ID
    final int? merchantId = json['hotel_id'] != null 
        ? int.tryParse(json['hotel_id'].toString()) 
        : null;
    
    print('✅ Parsed room: ID=$id, Name=$name, Price=$price, Remaining=$remaining');
    
    return Room(
      id: id,
      name: name,
      roomType: roomType,
      pricePerNight: price,
      capacity: capacity,
      maxOccupancy: maxOcc,
      remainingRooms: remaining,
      facilities: facilities,
      image: image,
      description: json['description']?.toString(),
      merchantId: merchantId,
    );
  }

  // ============================================================
  // CONVERT ROOM TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'room_type': roomType,
      'price_per_night': pricePerNight,
      'max_occupancy': maxOccupancy,
      'remaining_rooms': remainingRooms,
      'capacity': capacity,
      'facilities': facilities,
      'image': image,
      'description': description,
      'hotel_id': merchantId,
    };
  }

  // ============================================================
  // CREATE A COPY WITH UPDATED FIELDS
  // ============================================================

  Room copyWith({
    int? id,
    String? name,
    String? roomType,
    double? pricePerNight,
    int? capacity,
    int? maxOccupancy,
    int? remainingRooms,
    List<String>? facilities,
    String? image,
    String? description,
    int? merchantId,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      roomType: roomType ?? this.roomType,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      capacity: capacity ?? this.capacity,
      maxOccupancy: maxOccupancy ?? this.maxOccupancy,
      remainingRooms: remainingRooms ?? this.remainingRooms,
      facilities: facilities ?? this.facilities,
      image: image ?? this.image,
      description: description ?? this.description,
      merchantId: merchantId ?? this.merchantId,
    );
  }

  // ============================================================
  // CONVENIENCE GETTERS
  // ============================================================

  bool get isAvailable => remainingRooms > 0;
  String get formattedPrice => '${pricePerNight.toStringAsFixed(2)} ETB';
  String get occupancyText => '$maxOccupancy Guest${maxOccupancy > 1 ? 's' : ''}';
  String get facilitiesText => facilities.join(', ');
}

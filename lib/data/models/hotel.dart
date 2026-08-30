class Hotel {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? region;
  final String description;
  final double rating;
  final int reviewCount;
  final int starRating;
  final double pricePerNight;
  final List<String> images;
  final List<String> amenities;
  final bool isFeatured;
  final int remainingRooms;
  final int totalRooms;
  final double? latitude;
  final double? longitude;
  final String? videoUrl;
  final bool isActive;
  final String? phone;
  final String? email;
  final String? status;

  // Legacy fields for backward compatibility
  final int likes;
  final int comments;
  final int shares;

  Hotel({
    required this.id,
    required this.name,
    this.address,
    String? city,
    this.region,
    required this.description,
    required this.rating,
    this.reviewCount = 0,
    this.starRating = 0,
    double? pricePerNight,
    double? price,
    List<String>? images,
    String? image,
    String? video,
    String? location,
    this.amenities = const [],
    this.isFeatured = false,
    this.remainingRooms = 0,
    this.totalRooms = 0,
    this.latitude,
    this.longitude,
    String? videoUrl,
    this.isActive = true,
    this.phone,
    this.email,
    this.status,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
  })  : city = city ?? location,
        pricePerNight = pricePerNight ?? price ?? 0.0,
        images = images ?? (image != null && image.isNotEmpty ? [image] : const []),
        videoUrl = videoUrl ?? video;

  // ============================================================
  // BACKWARD COMPATIBILITY GETTERS
  // ============================================================

  /// Returns first image URL or fallback string for legacy UI components.
  String get image {
    if (images.isNotEmpty) return images.first;
    return '';
  }

  /// Returns video URL for legacy UI components.
  String get video => videoUrl ?? '';

  /// Returns location display string for legacy UI components.
  String get location {
    if (city != null && city!.isNotEmpty) return city!;
    if (region != null && region!.isNotEmpty) return region!;
    if (address != null && address!.isNotEmpty) return address!;
    return 'Ethiopia';
  }

  /// Alias for pricePerNight for legacy UI components.
  double get price => pricePerNight;

  // ============================================================
  // JSON PARSER
  // ============================================================

  factory Hotel.fromJson(Map<String, dynamic> json) {
    // Parse images array safely
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((img) => img?.toString() ?? '')
          .where((img) => img.isNotEmpty)
          .toList();
    } else if (json['image'] != null) {
      parsedImages = [json['image'].toString()];
    }

    // Parse amenities array safely
    List<String> parsedAmenities = [];
    if (json['amenities'] is List) {
      parsedAmenities = (json['amenities'] as List)
          .map((a) => a?.toString() ?? '')
          .where((a) => a.isNotEmpty)
          .toList();
    }

    return Hotel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Hotel',
      address: json['address']?.toString(),
      city: json['city']?.toString() ?? json['location']?.toString(),
      region: json['region']?.toString(),
      description: json['description']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      reviewCount: int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
      starRating: int.tryParse(json['star_rating']?.toString() ?? '0') ?? 0,
      pricePerNight: double.tryParse(
            json['price_per_night']?.toString() ??
                json['price']?.toString() ??
                '0.0',
          ) ??
          0.0,
      images: parsedImages,
      amenities: parsedAmenities,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      remainingRooms:
          int.tryParse(json['remaining_rooms']?.toString() ?? '0') ?? 0,
      totalRooms: int.tryParse(json['total_rooms']?.toString() ?? '0') ?? 0,
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      videoUrl: json['video_url']?.toString() ?? json['video']?.toString(),
      isActive: json['is_active'] != false && json['is_active'] != 0,
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      status: json['status']?.toString(),
      likes: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      comments: int.tryParse(json['comments']?.toString() ?? '0') ?? 0,
      shares: int.tryParse(json['shares']?.toString() ?? '0') ?? 0,
    );
  }
}


// ============================================================
// POST MODEL
// ============================================================
//
// This replaces the old Video model for the Home Feed module.
// It carries all the data required by Tasks 5.1–5.9.
//
// API shape (GET /api/posts/feed):
// {
//   "id": 1,
//   "ownerId": 2,
//   "ownerName": "Skylight Hotel",
//   "ownerAvatar": "assets/images/r3.jpg",
//   "ownerRole": "merchant",          // merchant | creator | consumer
//   "ownerUsername": "@skylighthotel",
//   "hotelId": 10,                    // null if not linked to a hotel
//   "mediaUrl": "assets/videos/hotel1.mp4",
//   "mediaType": "video",             // video | image
//   "thumbnail": "assets/images/r3.jpg",
//   "caption": "Experience luxury...",
//   "hashtags": ["luxury", "addis"],
//   "location": "Addis Ababa, Ethiopia",
//   "price": 3800,                    // starting price in ETB; null if not applicable
//   "rating": 4.6,                    // hotel/place rating; null if not applicable
//   "likes": 1250,
//   "comments": 186,
//   "shares": 74,
//   "bookmarks": 230,
//   "isLiked": false,
//   "isFollowing": false,
//   "createdAt": "2026-08-17T10:00:00Z"
// }

class Post {
  final int id;

  // ============================================================
  // OWNER
  // ============================================================

  final int ownerId;
  final String ownerName;
  final String ownerAvatar;
  final String ownerRole; // "merchant" | "creator" | "consumer"
  final String ownerUsername;

  // ============================================================
  // HOTEL LINK (Task 5.8 — Book Now)
  // ============================================================

  final int? hotelId; // null = no hotel linked

  // ============================================================
  // MEDIA
  // ============================================================

  final String mediaUrl;
  final String mediaType; // "video" | "image"
  final String thumbnail;

  // ============================================================
  // CONTENT
  // ============================================================

  final String caption;
  final List<String> hashtags;

  // ============================================================
  // LOCATION & PRICING
  // ============================================================

  final String? location;
  final double? price; // starting price in ETB
  final double? rating; // 0.0–5.0

  // ============================================================
  // ENGAGEMENT COUNTS
  // ============================================================

  final int likes;
  final int comments;
  final int shares;
  final int bookmarks;

  // ============================================================
  // CURRENT USER STATE
  // ============================================================

  final bool isLiked;
  final bool isFollowing;

  // ============================================================
  // TIMESTAMP
  // ============================================================

  final DateTime createdAt;

  const Post({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerAvatar,
    required this.ownerRole,
    required this.ownerUsername,
    this.hotelId,
    required this.mediaUrl,
    required this.mediaType,
    required this.thumbnail,
    required this.caption,
    required this.hashtags,
    this.location,
    this.price,
    this.rating,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.bookmarks,
    required this.isLiked,
    required this.isFollowing,
    required this.createdAt,
  });

  // ============================================================
  // SAFE PARSING HELPERS
  // ============================================================

  static int _toInt(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ============================================================
  // FROM JSON (API response)
  // ============================================================

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: _toInt(json['id']),
      ownerId: _toInt(json['ownerId']),
      ownerName: json['ownerName']?.toString() ?? '',
      ownerAvatar: json['ownerAvatar']?.toString() ?? '',
      ownerRole: json['ownerRole']?.toString() ?? 'consumer',
      ownerUsername: json['ownerUsername']?.toString() ?? '',
      hotelId: _toIntOrNull(json['hotelId']),
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      mediaType: json['mediaType']?.toString() ?? 'video',
      thumbnail: json['thumbnail']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location']?.toString(),
      price: _toDoubleOrNull(json['price']),
      rating: _toDoubleOrNull(json['rating']),
      likes: _toInt(json['likes']),
      comments: _toInt(json['comments']),
      shares: _toInt(json['shares']),
      bookmarks: _toInt(json['bookmarks']),
      isLiked: json['isLiked'] == true || json['isLiked'] == 1 || json['isLiked'] == "1",
      isFollowing: json['isFollowing'] == true || json['isFollowing'] == 1 || json['isFollowing'] == "1",
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // ============================================================
  // COPY WITH (for optimistic updates)
  // ============================================================

  Post copyWith({
    int? likes,
    int? comments,
    int? shares,
    int? bookmarks,
    bool? isLiked,
    bool? isFollowing,
  }) {
    return Post(
      id: id,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerAvatar: ownerAvatar,
      ownerRole: ownerRole,
      ownerUsername: ownerUsername,
      hotelId: hotelId,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      thumbnail: thumbnail,
      caption: caption,
      hashtags: hashtags,
      location: location,
      price: price,
      rating: rating,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      bookmarks: bookmarks ?? this.bookmarks,
      isLiked: isLiked ?? this.isLiked,
      isFollowing: isFollowing ?? this.isFollowing,
      createdAt: createdAt,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool get isMerchant => ownerRole == 'merchant';
  bool get isCreator => ownerRole == 'creator';
  bool get hasHotelLink => hotelId != null;
  bool get isVideo => mediaType == 'video';
}


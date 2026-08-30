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
    String mediaUrl = '';
    if (json['media_urls'] is List && (json['media_urls'] as List).isNotEmpty) {
      mediaUrl = (json['media_urls'] as List).first?.toString() ?? '';
    } else if (json['mediaUrl'] != null) {
      mediaUrl = json['mediaUrl'].toString();
    } else if (json['media_url'] != null) {
      mediaUrl = json['media_url'].toString();
    }

    if (mediaUrl.isNotEmpty && !mediaUrl.startsWith('http') && !mediaUrl.startsWith('assets/')) {
      if (mediaUrl.startsWith('/')) {
        mediaUrl = 'https://booking.dalloltech.com$mediaUrl';
      } else {
        mediaUrl = 'https://booking.dalloltech.com/$mediaUrl';
      }
    }

    String ownerAvatar = json['ownerAvatar']?.toString() ?? json['user_avatar']?.toString() ?? '';
    if (ownerAvatar.isNotEmpty && !ownerAvatar.startsWith('http') && !ownerAvatar.startsWith('assets/')) {
      if (ownerAvatar.startsWith('/')) {
        ownerAvatar = 'https://booking.dalloltech.com$ownerAvatar';
      } else {
        ownerAvatar = 'https://booking.dalloltech.com/$ownerAvatar';
      }
    }

    String thumbnail = json['thumbnail']?.toString() ?? json['thumbnail_url']?.toString() ?? '';
    if (thumbnail.isNotEmpty && !thumbnail.startsWith('http') && !thumbnail.startsWith('assets/')) {
      if (thumbnail.startsWith('/')) {
        thumbnail = 'https://booking.dalloltech.com$thumbnail';
      } else {
        thumbnail = 'https://booking.dalloltech.com/$thumbnail';
      }
    }

    return Post(
      id: _toInt(json['id']),
      ownerId: _toInt(json['ownerId'] ?? json['user_id']),
      ownerName: json['ownerName']?.toString() ?? json['user_name']?.toString() ?? '',
      ownerAvatar: json['ownerAvatar']?.toString() ?? json['user_avatar']?.toString() ?? '',
      ownerRole: json['ownerRole']?.toString() ?? 'consumer',
      ownerUsername: json['ownerUsername']?.toString() ?? json['username']?.toString() ?? '',
      hotelId: _toIntOrNull(json['hotelId'] ?? json['hotel_id']),
      mediaUrl: mediaUrl,
      mediaType: json['mediaType']?.toString() ?? json['post_type']?.toString() ?? 'video',
      thumbnail: json['thumbnail']?.toString() ?? json['thumbnail_url']?.toString() ?? '',
      caption: json['caption']?.toString() ?? json['description']?.toString() ?? json['title']?.toString() ?? '',
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location']?.toString() ?? json['hotel_city']?.toString(),
      price: _toDoubleOrNull(json['price']),
      rating: _toDoubleOrNull(json['rating'] ?? json['hotel_rating']),
      likes: _toInt(json['likes'] ?? json['likes_count']),
      comments: _toInt(json['comments'] ?? json['comments_count']),
      shares: _toInt(json['shares'] ?? json['shares_count']),
      bookmarks: _toInt(json['bookmarks']),
      isLiked: json['isLiked'] == true || json['isLiked'] == 1 || json['isLiked'] == "1" ||
          json['is_liked'] == true || json['is_liked'] == 1 || json['is_liked'] == "1",
      isFollowing: json['isFollowing'] == true || json['isFollowing'] == 1 || json['isFollowing'] == "1",
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
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


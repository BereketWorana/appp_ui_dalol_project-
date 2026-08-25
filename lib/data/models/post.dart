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
  // FROM JSON (API response)
  // ============================================================

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      ownerId: json['ownerId'] as int,
      ownerName: json['ownerName'] as String? ?? '',
      ownerAvatar: json['ownerAvatar'] as String? ?? '',
      ownerRole: json['ownerRole'] as String? ?? 'consumer',
      ownerUsername: json['ownerUsername'] as String? ?? '',
      hotelId: json['hotelId'] as int?,
      mediaUrl: json['mediaUrl'] as String? ?? '',
      mediaType: json['mediaType'] as String? ?? 'video',
      thumbnail: json['thumbnail'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      bookmarks: json['bookmarks'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
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

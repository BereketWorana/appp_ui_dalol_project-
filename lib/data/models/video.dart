class Video {
  final int id;
  final int userId;
  final int? hotelId;

  final String userName;
  final String userAvatar;

  final String postType;
  final String title;
  final String description;

  final List<String> mediaUrls;
  final String thumbnailUrl;

  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int bookmarksCount;

  final List<String> hashtags;

  final bool isLiked;

  final String? hotelName;
  final String? hotelCity;
  final double? hotelRating;
  final double? hotelStarRating;

  final String createdAt;
  final String createdAtFormatted;

  Video({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.userName,
    required this.userAvatar,
    required this.postType,
    required this.title,
    required this.description,
    required this.mediaUrls,
    required this.thumbnailUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.bookmarksCount,
    required this.hashtags,
    required this.isLiked,
    required this.hotelName,
    required this.hotelCity,
    required this.hotelRating,
    required this.hotelStarRating,
    required this.createdAt,
    required this.createdAtFormatted,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    // ----------------------------------------------------------
    // MEDIA
    // ----------------------------------------------------------

    final List<String> media = [];

    if (json["media_urls"] is List) {
      for (final item in json["media_urls"]) {
        if (item != null) {
          final value = item.toString().trim();

          if (value.isNotEmpty) {
            media.add(value);
          }
        }
      }
    }

    // ----------------------------------------------------------
    // HASHTAGS
    // ----------------------------------------------------------

    final List<String> tags = [];

    if (json["hashtags"] is List) {
      for (final item in json["hashtags"]) {
        if (item != null) {
          final value = item.toString().trim();

          if (value.isNotEmpty) {
            tags.add(value);
          }
        }
      }
    }

    // ----------------------------------------------------------
    // AVATAR
    // ----------------------------------------------------------

    String avatar = "";

    if (json["user_avatar"] != null) {
      avatar = json["user_avatar"].toString().trim();
    }

    // ----------------------------------------------------------
    // HOTEL ID
    // ----------------------------------------------------------

    int? hotelId;

    if (json["hotel_id"] != null) {
      hotelId = int.tryParse(json["hotel_id"].toString());
    }

    // ----------------------------------------------------------
    // HOTEL RATING
    // ----------------------------------------------------------

    double? hotelRating;

    if (json["hotel_rating"] != null) {
      hotelRating = double.tryParse(json["hotel_rating"].toString());
    }

    // ----------------------------------------------------------
    // STAR RATING
    // ----------------------------------------------------------

    double? hotelStarRating;

    if (json["hotel_star_rating"] != null) {
      hotelStarRating = double.tryParse(json["hotel_star_rating"].toString());
    }

    // ----------------------------------------------------------
    // RETURN
    // ----------------------------------------------------------

    return Video(
      id: int.tryParse(json["id"]?.toString() ?? "") ?? 0,

      userId: int.tryParse(json["user_id"]?.toString() ?? "") ?? 0,

      hotelId: hotelId,

      userName: json["user_name"]?.toString().trim().isNotEmpty == true
          ? json["user_name"].toString()
          : "Unknown User",

      userAvatar: avatar,

      postType: json["post_type"]?.toString() ?? "image",

      title: json["title"]?.toString() ?? "",

      description: json["description"]?.toString() ?? "",

      mediaUrls: media,

      thumbnailUrl: json["thumbnail_url"]?.toString() ?? "",

      likesCount: int.tryParse(json["likes_count"]?.toString() ?? "") ?? 0,

      commentsCount:
          int.tryParse(json["comments_count"]?.toString() ?? "") ?? 0,

      sharesCount: int.tryParse(json["shares_count"]?.toString() ?? "") ?? 0,

      bookmarksCount: 0,

      hashtags: tags,

      isLiked: json["is_liked"] == true,

      hotelName: json["hotel_name"]?.toString(),

      hotelCity: json["hotel_city"]?.toString(),

      hotelRating: hotelRating,

      hotelStarRating: hotelStarRating,

      createdAt: json["created_at"]?.toString() ?? "",

      createdAtFormatted: json["created_at_formatted"]?.toString() ?? "",
    );
  }

  // ============================================================
  // COMPATIBILITY GETTERS
  // ============================================================

  int get ownerId => userId;

  String get ownerName => userName;

  String get video {
    if (mediaUrls.isEmpty) {
      return "";
    }

    return mediaUrls.first;
  }

  String get thumbnail {
    if (thumbnailUrl.isNotEmpty) {
      return thumbnailUrl;
    }

    if (mediaUrls.isNotEmpty) {
      return mediaUrls.first;
    }

    return "";
  }

  int get likes => likesCount;

  int get comments => commentsCount;

  int get shares => sharesCount;

  int get bookmarks => bookmarksCount;

  bool get hasHotel {
    return hotelId != null && hotelId! > 0;
  }
}

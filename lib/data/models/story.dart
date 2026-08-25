class Story {
  final int id;
  final int userId;
  final String userName;
  final String userAvatar;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int? hotelId;

  const Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    required this.expiresAt,
    this.hotelId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get hasHotelLink => hotelId != null;
}

class Video {
  final int id;
  final int ownerId;
  final String ownerType;
  final String ownerName;

  final String video;
  final String thumbnail;

  final String title;
  final String description;

  final int likes;
  final int comments;
  final int shares;
  final int bookmarks;

  Video({
    required this.id,
    required this.ownerId,
    required this.ownerType,
    required this.ownerName,
    required this.video,
    required this.thumbnail,
    required this.title,
    required this.description,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.bookmarks,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json["id"],
      ownerId: json["ownerId"],
      ownerType: json["ownerType"],
      ownerName: json["ownerName"],
      video: json["video"],
      thumbnail: json["thumbnail"],
      title: json["title"],
      description: json["description"],
      likes: json["likes"],
      comments: json["comments"],
      shares: json["shares"],
      bookmarks: json["bookmarks"],
    );
  }
}

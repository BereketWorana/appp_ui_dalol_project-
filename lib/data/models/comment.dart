class Comment {
  final int id;
  final int postId;
  final int userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['postId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String? ?? 'User',
      userAvatar: json['userAvatar'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

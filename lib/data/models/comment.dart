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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      postId: int.tryParse(json['post_id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      userName: json['user_name'] as String? ?? 'User',
      userAvatar: json['avatar'] as String? ?? '',
      text: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
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

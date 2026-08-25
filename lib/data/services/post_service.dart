import '../models/comment.dart';
import '../models/post.dart';

class PostService {
  /// Toggles like status for a post.
  /// Throws an exception for testing if [postId] == 999.
  static Future<bool> toggleLike(int postId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Hardcoded failure test case
    if (postId == 999) {
      throw Exception('Like failed - test case');
    }

    // Return true for success (mock)
    return true;
  }

  /// Submits a comment to a post.
  /// Returns a mock Comment object.
  static Future<Comment> submitComment(int postId, String text) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulate error for testing
    if (postId == 999) {
      throw Exception('Comment submission failed - test case');
    }

    return Comment(
      id: DateTime.now().millisecondsSinceEpoch, // mock ID
      postId: postId,
      userId: 1, // mock current user ID
      userName: 'Current User',
      userAvatar: 'assets/images/r1.jpg',
      text: text,
      createdAt: DateTime.now(),
    );
  }
  
  /// Fetches comments for a post.
  static Future<List<Comment>> getComments(int postId, {int offset = 0, int limit = 20}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (offset > 0) return []; // No more comments for mock
    
    // Return a few mock comments if it's the first page
    return [
      Comment(
        id: 1,
        postId: postId,
        userId: 2,
        userName: 'Abebe B.',
        userAvatar: 'assets/images/r2.jpg',
        text: 'This looks amazing! 🔥',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Comment(
        id: 2,
        postId: postId,
        userId: 3,
        userName: 'Sara W.',
        userAvatar: 'assets/images/r4.jpg',
        text: 'How much is it per night?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  /// Shares a post.
  static Future<bool> sharePost(int postId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// Fetches posts for a specific user.
  static Future<List<Post>> getUserPosts(int userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock: return a few posts by this user
    return [
      Post(
        id: DateTime.now().millisecondsSinceEpoch, // Unique ID for mock
        ownerId: userId,
        ownerName: 'User Name',
        ownerAvatar: 'assets/images/r1.jpg',
        ownerRole: 'consumer',
        ownerUsername: '@username',
        mediaUrl: 'assets/videos/v2.mp4',
        mediaType: 'video',
        thumbnail: 'assets/images/r1.jpg',
        caption: 'My first post',
        hashtags: ['first'],
        likes: 120,
        comments: 5,
        shares: 2,
        bookmarks: 0,
        location: 'Addis Ababa',
        rating: 4.5,
        price: 3500,
        isLiked: false,
        isFollowing: false,
        createdAt: DateTime.now(),
      ),
      Post(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        ownerId: userId,
        ownerName: 'User Name',
        ownerAvatar: 'assets/images/r1.jpg',
        ownerRole: 'merchant',
        ownerUsername: '@username',
        mediaUrl: 'assets/videos/v3.mp4',
        mediaType: 'video',
        thumbnail: 'assets/images/r1.jpg',
        caption: 'Another beautiful day',
        hashtags: ['beautiful'],
        likes: 85,
        comments: 12,
        shares: 4,
        bookmarks: 1,
        location: 'Bishoftu',
        rating: 5.0,
        price: 5000,
        isLiked: false,
        isFollowing: false,
        hotelId: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

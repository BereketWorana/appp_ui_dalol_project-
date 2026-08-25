import 'package:flutter/foundation.dart';

import '../../../../data/models/post.dart';
import '../../../../data/services/feed_service.dart';

// ============================================================
// FEED PROVIDER
// ============================================================
//
// Manages:
//   - Feed post list
//   - Pagination state (offset, hasMore)
//   - Loading / refreshing / error states
//   - Optimistic like & follow count updates
//
// Used by: feed_screen.dart, post_card.dart
//
// Usage in a widget tree:
//   ChangeNotifierProvider(
//     create: (_) => FeedProvider()..loadFeed(),
//     child: const FeedScreen(),
//   )

class FeedProvider extends ChangeNotifier {
  // ============================================================
  // STATE
  // ============================================================

  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  static const int _limit = 10;

  // ============================================================
  // GETTERS
  // ============================================================

  List<Post> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get isEmpty => !_isLoading && !_isRefreshing && _posts.isEmpty && _error == null;

  // ============================================================
  // INITIAL LOAD
  // ============================================================

  Future<void> loadFeed() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FeedService.getFeed(offset: 0, limit: _limit);

      _posts = result.posts;
      _hasMore = result.hasMore;
      _offset = result.posts.length;
      _error = null;
    } catch (e) {
      debugPrint('FeedProvider.loadFeed error: $e');
      _error = 'Unable to load feed. Pull down to retry.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // PULL TO REFRESH
  // ============================================================

  Future<void> refresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FeedService.getFeed(offset: 0, limit: _limit);

      _posts = result.posts;
      _hasMore = result.hasMore;
      _offset = result.posts.length;
      _error = null;
    } catch (e) {
      debugPrint('FeedProvider.refresh error: $e');
      // Don't overwrite existing posts on refresh failure.
      // Just surface the error briefly.
      _error = 'Refresh failed. Try again.';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD MORE (infinite scroll)
  // ============================================================

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await FeedService.getFeed(
        offset: _offset,
        limit: _limit,
      );

      _posts = [..._posts, ...result.posts];
      _hasMore = result.hasMore;
      _offset += result.posts.length;
    } catch (e) {
      debugPrint('FeedProvider.loadMore error: $e');
      // Fail silently — user can scroll back down to trigger again.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ============================================================
  // OPTIMISTIC LIKE UPDATE
  // ============================================================
  //
  // Called from LikeButton BEFORE the API call.
  // If the API fails, the widget calls revertLike().

  void optimisticLike(int postId, {required bool liked}) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    _posts[index] = post.copyWith(
      isLiked: liked,
      likes: liked ? post.likes + 1 : (post.likes - 1).clamp(0, 999999),
    );
    notifyListeners();
  }

  // ============================================================
  // OPTIMISTIC FOLLOW UPDATE
  // ============================================================

  void optimisticFollow(int ownerId, {required bool following}) {
    // Update all posts from this owner simultaneously.
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].ownerId == ownerId) {
        _posts[i] = _posts[i].copyWith(isFollowing: following);
      }
    }
    notifyListeners();
  }

  // ============================================================
  // UPDATE COMMENT COUNT
  // ============================================================

  void incrementCommentCount(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    _posts[index] = post.copyWith(comments: post.comments + 1);
    notifyListeners();
  }

  void decrementCommentCount(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    _posts[index] = post.copyWith(
      comments: (post.comments - 1).clamp(0, 999999),
    );
    notifyListeners();
  }
}

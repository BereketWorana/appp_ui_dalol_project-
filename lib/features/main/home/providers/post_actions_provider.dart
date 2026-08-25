import 'package:flutter/material.dart';

import '../../../../data/services/post_service.dart';
import '../../../../data/services/follow_service.dart';
import 'feed_provider.dart';

class PostActionsProvider extends ChangeNotifier {
  // Sets to track interaction states independently of the feed.
  // Using sets ensures O(1) lookups.
  final Set<int> _likedPosts = {};
  final Set<int> _followedUsers = {};
  
  // Track ongoing actions for debouncing
  final Set<int> _followingInProgress = {};
  final Set<int> _likingInProgress = {};

  bool isLiked(int postId) => _likedPosts.contains(postId);
  bool isFollowing(int userId) => _followedUsers.contains(userId);

  /// Initializes the state for a post/user from the initial feed load.
  /// If the post is already liked/followed according to the API, we seed the state.
  void seedLikeState(int postId, bool initialLiked) {
    if (initialLiked) _likedPosts.add(postId);
  }
  
  void seedFollowState(int userId, bool initialFollowing) {
    if (initialFollowing) _followedUsers.add(userId);
  }

  /// Toggles like status with optimistic UI updates and rollback.
  Future<void> toggleLike(BuildContext context, int postId, FeedProvider feedProvider) async {
    // Debounce check
    if (_likingInProgress.contains(postId)) return;
    
    final currentlyLiked = isLiked(postId);
    
    // OPTIMISTIC UPDATE
    _likingInProgress.add(postId);
    if (currentlyLiked) {
      _likedPosts.remove(postId);
    } else {
      _likedPosts.add(postId);
    }
    
    // Also notify FeedProvider to update the count instantly
    feedProvider.optimisticLike(postId, liked: !currentlyLiked);
    
    notifyListeners();

    try {
      await PostService.toggleLike(postId);
    } catch (e) {
      // ROLLBACK ON FAILURE
      if (currentlyLiked) {
        _likedPosts.add(postId);
      } else {
        _likedPosts.remove(postId);
      }
      
      // Rollback count in FeedProvider
      feedProvider.optimisticLike(postId, liked: currentlyLiked);
      
      notifyListeners();
      
      // Show snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to like post. Try again.')),
        );
      }
    } finally {
      _likingInProgress.remove(postId);
    }
  }

  /// Toggles follow status with optimistic UI updates and rollback.
  Future<void> toggleFollow(BuildContext context, int userId, FeedProvider feedProvider) async {
    // Debounce check
    if (_followingInProgress.contains(userId)) return;
    
    final currentlyFollowing = isFollowing(userId);
    
    // OPTIMISTIC UPDATE
    _followingInProgress.add(userId);
    if (currentlyFollowing) {
      _followedUsers.remove(userId);
    } else {
      _followedUsers.add(userId);
    }
    
    // Also update all posts by this user in FeedProvider
    feedProvider.optimisticFollow(userId, following: !currentlyFollowing);
    
    notifyListeners();

    try {
      await FollowService.toggleFollow(userId);
    } catch (e) {
      // ROLLBACK ON FAILURE
      if (currentlyFollowing) {
        _followedUsers.add(userId);
      } else {
        _followedUsers.remove(userId);
      }
      
      // Rollback in FeedProvider
      feedProvider.optimisticFollow(userId, following: currentlyFollowing);
      
      notifyListeners();
      
      // Show snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update follow status. Try again.')),
        );
      }
    } finally {
      _followingInProgress.remove(userId);
    }
  }
}

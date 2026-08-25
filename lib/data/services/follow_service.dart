class FollowService {
  /// Toggles follow status for a user.
  /// Throws an exception for testing if [userId] == 999.
  static Future<bool> toggleFollow(int userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Hardcoded failure test case
    if (userId == 999) {
      throw Exception('Follow failed - test case');
    }

    // Return true for success (mock)
    return true;
  }
}

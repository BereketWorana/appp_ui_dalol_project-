import '../../data/models/user.dart';

class AuthService {
  static User? _currentUser;

  /// Current logged in user
  static User? get currentUser => _currentUser;

  /// Logged in?
  static bool get isLoggedIn => _currentUser != null;

  /// Login
  static void login(User user) {
    _currentUser = user;
  }

  /// Logout
  static void logout() {
    _currentUser = null;
  }

  /// Replace current user (useful after profile update)
  static void updateUser(User user) {
    _currentUser = user;
  }

  /// Role
  static String get role => _currentUser?.role ?? "consumer";

  /// Name
  static String get name => _currentUser?.fullName ?? "";

  /// Email
  static String get email => _currentUser?.email ?? "";

  /// Phone
  static String get phone => _currentUser?.phone ?? "";

  /// Profile image
  static String get profileImage =>
      _currentUser?.profileImage ?? "assets/images/default_profile.png";

  /// Cover image
  static String get coverImage =>
      _currentUser?.coverImage ?? "assets/images/default_cover.jpg";
}

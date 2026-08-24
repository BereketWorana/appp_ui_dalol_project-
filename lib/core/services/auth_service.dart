import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import '../config/app_config.dart';

class AuthService {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = AppConfig.apiBaseUrl;

  // ============================================================
  // SESSION KEYS
  // ============================================================

  static const String _accessTokenKey = "access_token";
  static const String _refreshTokenKey = "refresh_token";
  static const String _userKey = "current_user";
  static const String _rememberMeKey = "remember_me";

  // ============================================================
  // CURRENT USER
  // ============================================================

  static User? _currentUser;
  static User? get currentUser => _currentUser;

  // ============================================================
  // ACCESS TOKEN
  // ============================================================

  static String? _accessToken;
  static String? get accessToken => _accessToken;

  // ============================================================
  // LOGIN STATUS
  // ============================================================

  static bool get isLoggedIn {
    return _accessToken != null && _accessToken!.isNotEmpty && _currentUser != null;
  }

  // ============================================================
  // ROLE
  // ============================================================

  static String get role => _currentUser?.role ?? "consumer";

  // ============================================================
  // REMEMBER ME STATUS
  // ============================================================

  static bool _rememberMe = false;
  static bool get rememberMe => _rememberMe;

  // ============================================================
  // GET CURRENT USER ID
  // ============================================================

  static int? get userId => _currentUser?.id;

  // ============================================================
  // GET AUTH HEADER
  // ============================================================

  static Map<String, String> get authHeader {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      return {
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'application/json',
      };
    }
    return {'Accept': 'application/json'};
  }

  // ============================================================
  // CHECK IF TOKEN EXISTS
  // ============================================================

  static bool get hasValidToken {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  // ============================================================
  // INITIALIZE AUTH SESSION
  // ============================================================

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool(_rememberMeKey) ?? false;

    if (!_rememberMe) {
      _accessToken = null;
      _currentUser = null;
      return;
    }

    _accessToken = prefs.getString(_accessTokenKey);
    final userJson = prefs.getString(_userKey);

    if (userJson != null && userJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(userJson);
        if (decoded is Map<String, dynamic>) {
          _currentUser = User.fromJson(decoded);
        }
      } catch (_) {
        _currentUser = null;
      }
    }

    if (_accessToken == null || _accessToken!.isEmpty || _currentUser == null) {
      _accessToken = null;
      _currentUser = null;
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userKey);
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      print('🔐 Login attempt: $phone');
      
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      ).timeout(const Duration(seconds: 30));

      print('📥 Login Response Status: ${response.statusCode}');
      print('📥 Login Response Body: ${response.body}');

      Map<String, dynamic> body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        } else {
          return {"success": false, "message": "Invalid response from server."};
        }
      } catch (_) {
        return {"success": false, "message": "Invalid response from server."};
      }

      if (response.statusCode == 200 && body["status"] == true) {
        final data = body["data"];
        if (data == null || data is! Map) {
          return {"success": false, "message": "Invalid login response from server."};
        }

        final rawUser = data["user"];
        if (rawUser == null || rawUser is! Map) {
          return {"success": false, "message": "User information was not returned."};
        }

        final rawTokens = data["tokens"];
        if (rawTokens == null || rawTokens is! Map) {
          return {"success": false, "message": "Authentication token was not returned."};
        }

        final tokenData = Map<String, dynamic>.from(rawTokens);
        final accessToken = tokenData["access_token"]?.toString();
        if (accessToken == null || accessToken.isEmpty) {
          return {"success": false, "message": "Authentication token is missing."};
        }

        _accessToken = accessToken;
        final refreshToken = tokenData["refresh_token"]?.toString();
        _currentUser = _userFromApi(Map<String, dynamic>.from(rawUser));
        _rememberMe = rememberMe;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_rememberMeKey, rememberMe);

        if (rememberMe) {
          await prefs.setString(_accessTokenKey, _accessToken!);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await prefs.setString(_refreshTokenKey, refreshToken);
          }
          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
        } else {
          await prefs.remove(_accessTokenKey);
          await prefs.remove(_refreshTokenKey);
          await prefs.remove(_userKey);
        }

        return {
          "success": true,
          "message": body["message"]?.toString() ?? "Login successful.",
          "user": _currentUser,
        };
      }

      return {"success": false, "message": _extractErrorMessage(body["message"])};
    } catch (e) {
      print('❌ Login Error: $e');
      return {"success": false, "message": "Unable to connect to the server. Please check your internet connection."};
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    bool termsAccepted = false,
  }) async {
    try {
      print('📝 Register attempt: $email');
      
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "full_name": fullName,
          "phone": phone,
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📥 Register Response Status: ${response.statusCode}');
      print('📥 Register Response Body: ${response.body}');

      Map<String, dynamic> body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        } else {
          return {"success": false, "message": "Invalid response from server."};
        }
      } catch (_) {
        return {"success": false, "message": "Invalid response from server."};
      }

      if ((response.statusCode == 200 || response.statusCode == 201) && body["status"] == true) {
        final data = body["data"];
        if (data == null || data is! Map) {
          return {"success": false, "message": "Invalid registration response."};
        }

        final rawUser = data["user"];
        if (rawUser == null || rawUser is! Map) {
          return {"success": false, "message": "User information was not returned."};
        }

        final rawTokens = data["tokens"];
        if (rawTokens == null || rawTokens is! Map) {
          return {"success": false, "message": "Authentication token was not returned."};
        }

        final tokenData = Map<String, dynamic>.from(rawTokens);
        final accessToken = tokenData["access_token"]?.toString();
        if (accessToken == null || accessToken.isEmpty) {
          return {"success": false, "message": "Authentication token is missing."};
        }

        _accessToken = accessToken;
        final refreshToken = tokenData["refresh_token"]?.toString();
        _currentUser = _userFromApi(Map<String, dynamic>.from(rawUser), selectedRole: role);
        _rememberMe = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_rememberMeKey, true);
        await prefs.setString(_accessTokenKey, _accessToken!);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await prefs.setString(_refreshTokenKey, refreshToken);
        }
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

        return {
          "success": true,
          "message": body["message"]?.toString() ?? "Registration successful.",
          "user": _currentUser,
        };
      }

      return {"success": false, "message": _extractErrorMessage(body["message"])};
    } catch (e) {
      print('❌ Register Error: $e');
      return {"success": false, "message": "Unable to connect to the server. Please check your internet connection."};
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    _accessToken = null;
    _currentUser = null;
    _rememberMe = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_rememberMeKey);
  }

  // ============================================================
  // REFRESH TOKEN
  // ============================================================

  static Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      print('🔄 Refreshing token...');
      
      final response = await http.post(
        Uri.parse("$baseUrl/auth/refresh"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"refresh_token": refreshToken}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final body = jsonDecode(response.body);
          if (body['status'] == true) {
            final newToken = body['data']?['access_token']?.toString();
            if (newToken != null && newToken.isNotEmpty) {
              _accessToken = newToken;
              await prefs.setString(_accessTokenKey, newToken);
              print('✅ Token refreshed successfully');
              return true;
            }
          }
        } catch (_) {
          return false;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      print('🔑 Forgot password request for: $email');
      
      final response = await http.post(
        Uri.parse("$baseUrl/auth/forgot-password"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 30));

      Map<String, dynamic> body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        } else {
          return {"success": false, "message": "Invalid response from server."};
        }
      } catch (_) {
        return {"success": false, "message": "Invalid response from server."};
      }

      if (response.statusCode == 200 && body["status"] == true) {
        return {
          "success": true,
          "message": body["message"]?.toString() ?? 
              "Password reset link has been sent to your email.",
        };
      }

      return {
        "success": false,
        "message": _extractErrorMessage(body["message"]),
      };
    } catch (e) {
      print('❌ Forgot Password Error: $e');
      return {
        "success": false,
        "message": "Unable to connect to the server. Please try again.",
      };
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      print('🔑 Resetting password...');
      
      final response = await http.post(
        Uri.parse("$baseUrl/auth/reset-password"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "token": token,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      ).timeout(const Duration(seconds: 30));

      Map<String, dynamic> body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        } else {
          return {"success": false, "message": "Invalid response from server."};
        }
      } catch (_) {
        return {"success": false, "message": "Invalid response from server."};
      }

      if (response.statusCode == 200 && body["status"] == true) {
        return {
          "success": true,
          "message": body["message"]?.toString() ?? "Password reset successfully.",
        };
      }

      return {
        "success": false,
        "message": _extractErrorMessage(body["message"]),
      };
    } catch (e) {
      print('❌ Reset Password Error: $e');
      return {
        "success": false,
        "message": "Unable to connect to the server. Please try again.",
      };
    }
  }

  // ============================================================
  // GET PROFILE
  // ============================================================

  static Future<Map<String, dynamic>> getProfile() async {
    if (!isLoggedIn) {
      return {"success": false, "message": "Not logged in."};
    }

    try {
      print('👤 Getting profile for user: ${_currentUser!.id}');
      
      final response = await http.get(
        Uri.parse("$baseUrl/profiles?user_id=${_currentUser!.id}"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_accessToken",
        },
      ).timeout(const Duration(seconds: 30));

      Map<String, dynamic> body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        } else {
          return {"success": false, "message": "Invalid response from server."};
        }
      } catch (_) {
        return {"success": false, "message": "Invalid response from server."};
      }

      if (response.statusCode == 200 && (body["success"] == true || body["status"] == true)) {
        return {"success": true, "data": body["data"]};
      }

      return {
        "success": false,
        "message": _extractErrorMessage(body["message"]),
      };
    } catch (e) {
      print('❌ Get Profile Error: $e');
      return {"success": false, "message": "Unable to load profile."};
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static User _userFromApi(Map<String, dynamic> data, {String? selectedRole}) {
    final int id = int.tryParse(data["id"]?.toString() ?? "") ?? 0;
    final String userType = data["user_type"]?.toString() ?? "customer";

    String appRole;
    if (selectedRole != null && selectedRole.isNotEmpty) {
      appRole = selectedRole;
    } else {
      switch (userType.toLowerCase()) {
        case "merchant":
        case "hotel_admin":
          appRole = "merchant";
          break;
        case "influencer":
        case "creator":
          appRole = "creator";
          break;
        default:
          appRole = "consumer";
      }
    }

    return User(
      id: id,
      fullName: data["full_name"]?.toString() ?? "",
      phone: data["phone"]?.toString() ?? "",
      email: data["email"]?.toString() ?? "",
      password: "",
      role: appRole,
      profileImage: data["avatar"]?.toString() ?? "assets/images/default_profile.jpg",
      coverImage: data["cover_image"]?.toString() ?? "assets/images/default_cover.jpg",
    );
  }

  static String _extractErrorMessage(dynamic message) {
    if (message == null) return "Something went wrong.";
    if (message is String) return message;
    if (message is List) {
      final messages = message.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      if (messages.isNotEmpty) return messages.join("\n");
    }
    if (message is Map) {
      final messages = <String>[];
      message.forEach((key, value) {
        if (value is List) {
          messages.addAll(value.map((e) => e.toString()));
        } else {
          messages.add(value.toString());
        }
      });
      if (messages.isNotEmpty) return messages.join("\n");
    }
    return message.toString();
  }
}
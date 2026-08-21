import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user.dart';

class AuthService {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = "https://booking.dalloltech.com/api/";

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
    return _accessToken != null &&
        _accessToken!.isNotEmpty &&
        _currentUser != null;
  }

  // ============================================================
  // ROLE
  // ============================================================

  static String get role {
    return _currentUser?.role ?? "consumer";
  }

  // ============================================================
  // REMEMBER ME
  // ============================================================

  static bool _rememberMe = false;

  static bool get rememberMe => _rememberMe;

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
        } else {
          _currentUser = null;
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
  // LOGIN API
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${baseUrl}auth/login"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"phone": phone, "password": password}),
          )
          .timeout(const Duration(seconds: 20));

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
          return {
            "success": false,
            "message": "Invalid login response from server.",
          };
        }

        final rawUser = data["user"];

        if (rawUser == null || rawUser is! Map) {
          return {
            "success": false,
            "message": "User information was not returned by the server.",
          };
        }

        final userData = Map<String, dynamic>.from(rawUser);

        final rawTokens = data["tokens"];

        if (rawTokens == null || rawTokens is! Map) {
          return {
            "success": false,
            "message": "Authentication token was not returned by the server.",
          };
        }

        final tokenData = Map<String, dynamic>.from(rawTokens);

        final accessToken = tokenData["access_token"]?.toString();

        if (accessToken == null || accessToken.isEmpty) {
          return {
            "success": false,
            "message": "Authentication token is missing.",
          };
        }

        _accessToken = accessToken;

        final refreshToken = tokenData["refresh_token"]?.toString();

        // IMPORTANT:
        // Login role comes from API user_type.
        _currentUser = _userFromApi(userData);

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

      return {
        "success": false,
        "message": _extractErrorMessage(body["message"]),
      };
    } on http.ClientException {
      return {"success": false, "message": "Unable to connect to the server."};
    } catch (_) {
      return {"success": false, "message": "Unable to connect to the server."};
    }
  }

  // ============================================================
  // NORMAL REGISTER API
  //
  // Used ONLY for:
  // - consumer
  // - merchant / hotel owner
  //
  // NOT used for influencer.
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
      final response = await http
          .post(
            Uri.parse("${baseUrl}auth/register"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "full_name": fullName,
              "phone": phone,
              "email": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 20));

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

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body["status"] == true) {
        final data = body["data"];

        if (data == null || data is! Map) {
          return {
            "success": false,
            "message": "Invalid registration response.",
          };
        }

        final rawUser = data["user"];

        if (rawUser == null || rawUser is! Map) {
          return {
            "success": false,
            "message": "User information was not returned.",
          };
        }

        final userData = Map<String, dynamic>.from(rawUser);

        final rawTokens = data["tokens"];

        if (rawTokens == null || rawTokens is! Map) {
          return {
            "success": false,
            "message": "Authentication token was not returned.",
          };
        }

        final tokenData = Map<String, dynamic>.from(rawTokens);

        final accessToken = tokenData["access_token"]?.toString();

        if (accessToken == null || accessToken.isEmpty) {
          return {
            "success": false,
            "message": "Authentication token is missing.",
          };
        }

        _accessToken = accessToken;

        final refreshToken = tokenData["refresh_token"]?.toString();

        _currentUser = _userFromApi(userData, selectedRole: role);

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

      return {
        "success": false,
        "message": _extractErrorMessage(body["message"]),
      };
    } on http.ClientException {
      return {"success": false, "message": "Unable to connect to the server."};
    } catch (_) {
      return {"success": false, "message": "Unable to connect to the server."};
    }
  }

  // ============================================================
  // INFLUENCER REGISTRATION
  //
  // IMPORTANT:
  // This is completely separate from auth/register.
  //
  // The CreatorApplicationScreen should call this API.
  //
  // Endpoint:
  // POST /influencer/register
  //
  // It creates a PENDING influencer account.
  // ============================================================

  static Future<Map<String, dynamic>> registerInfluencer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String bio,
    required String category,
    required bool termsAccepted,
    String? instagram,
    String? youtube,
    String? tiktok,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "password": password,
        "confirm_password": confirmPassword,
        "bio": bio,
        "category": category,
        "terms_accepted": termsAccepted ? 1 : 0,
      };

      // Optional social links.
      if (instagram != null && instagram.trim().isNotEmpty) {
        requestBody["instagram"] = instagram.trim();
      }

      if (youtube != null && youtube.trim().isNotEmpty) {
        requestBody["youtube"] = youtube.trim();
      }

      if (tiktok != null && tiktok.trim().isNotEmpty) {
        requestBody["tiktok"] = tiktok.trim();
      }

      final response = await http
          .post(
            Uri.parse("${baseUrl}influencer/register"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 20));

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

      // ========================================================
      // SUCCESS
      // ========================================================

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body["success"] == true) {
        final data = body["data"];

        return {
          "success": true,
          "message":
              body["message"]?.toString() ??
              "Registration successful! Your influencer account is pending admin approval.",
          "data": data,
        };
      }

      // ========================================================
      // VALIDATION / API ERROR
      // ========================================================

      return {
        "success": false,
        "message": _extractErrorMessage(body["message"]),
        "errors": body["errors"],
      };
    } on http.ClientException {
      return {"success": false, "message": "Unable to connect to the server."};
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to the server. Please try again.",
      };
    }
  }

  // ============================================================
  // CONVERT API USER TO APP USER
  // ============================================================

  static User _userFromApi(Map<String, dynamic> data, {String? selectedRole}) {
    final int id = int.tryParse(data["id"]?.toString() ?? "") ?? 0;

    final String userType = data["user_type"]?.toString() ?? "customer";

    String appRole;

    // Registration role has priority ONLY for normal registration.
    if (selectedRole != null && selectedRole.isNotEmpty) {
      appRole = selectedRole;
    } else {
      switch (userType.toLowerCase()) {
        case "hotel_owner":
          appRole = "merchant";
          break;

        case "influencer":
        case "creator":
          appRole = "creator";
          break;

        case "merchant":
          appRole = "merchant";
          break;

        case "customer":
        case "consumer":
        default:
          appRole = "consumer";
          break;
      }
    }

    return User(
      id: id,
      fullName: data["full_name"]?.toString() ?? "",
      phone: data["phone"]?.toString() ?? "",
      email: data["email"]?.toString() ?? "",
      password: "",
      role: appRole,
      profileImage:
          data["avatar"]?.toString() ?? "assets/images/default_profile.jpg",
      coverImage:
          data["cover_image"]?.toString() ?? "assets/images/default_cover.jpg",
    );
  }

  // ============================================================
  // GET CURRENT USER PROFILE
  // ============================================================

  static Future<Map<String, dynamic>> getProfile() async {
    if (!isLoggedIn) {
      return {"success": false, "message": "Not logged in."};
    }

    try {
      final response = await http
          .get(
            Uri.parse("${baseUrl}profiles?user_id=${_currentUser!.id}"),
            headers: {
              "Accept": "application/json",
              "Authorization": "Bearer $_accessToken",
            },
          )
          .timeout(const Duration(seconds: 20));

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

      if (response.statusCode == 200 &&
          (body["success"] == true || body["status"] == true)) {
        return {"success": true, "data": body["data"]};
      }

      return {
        "success": false,
        "message": _extractErrorMessage(body["message"]),
      };
    } catch (_) {
      return {"success": false, "message": "Unable to load profile."};
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
  // ERROR MESSAGE
  // ============================================================

  static String _extractErrorMessage(dynamic message) {
    if (message == null) {
      return "Something went wrong.";
    }

    if (message is String) {
      return message;
    }

    if (message is List) {
      final messages = message
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();

      if (messages.isNotEmpty) {
        return messages.join("\n");
      }
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

      if (messages.isNotEmpty) {
        return messages.join("\n");
      }
    }

    return message.toString();
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}auth/forgot-password"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email}),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["status"] == true) {
        return {
          "success": true,
          "message":
              body["message"]?.toString() ??
              "Password reset link has been sent to your email.",
        };
      }

      return {
        "success": false,
        "message": _extractErrorMessage(body["message"]),
      };
    } catch (_) {
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
      final response = await http.post(
        Uri.parse("${baseUrl}auth/reset-password"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "token": token,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["status"] == true) {
        return {
          "success": true,
          "message":
              body["message"]?.toString() ?? "Password reset successfully.",
        };
      }

      return {
        "success": false,
        "message": _extractErrorMessage(body["message"]),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to the server. Please try again.",
      };
    }
  }
}

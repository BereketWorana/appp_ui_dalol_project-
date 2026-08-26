import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user.dart';

class AuthService {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = "https://booking.dalloltech.com/api";

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
  // REMEMBER ME STATUS
  // ============================================================

  static bool _rememberMe = false;

  static bool get rememberMe => _rememberMe;

  // ============================================================
  // INITIALIZE AUTH SESSION
  //
  // Call this BEFORE runApp().
  //
  // If Remember Me was enabled, the saved session is restored.
  // Otherwise the user starts as logged out.
  // ============================================================

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _rememberMe = prefs.getBool(_rememberMeKey) ?? false;

    // ------------------------------------------------------------
    // If Remember Me was NOT enabled, do not restore the session.
    // ------------------------------------------------------------

    if (!_rememberMe) {
      _accessToken = null;
      _currentUser = null;
      return;
    }

    // ------------------------------------------------------------
    // Restore access token
    // ------------------------------------------------------------

    _accessToken = prefs.getString(_accessTokenKey);

    // ------------------------------------------------------------
    // Restore current user
    // ------------------------------------------------------------

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

    // ------------------------------------------------------------
    // If either token or user is missing, session is invalid.
    // ------------------------------------------------------------

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
      // ----------------------------------------------------------
      // SEND LOGIN REQUEST
      // ----------------------------------------------------------

      final response = await http
          .post(
            Uri.parse("$baseUrl/auth/login"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"phone": phone, "password": password}),
          )
          .timeout(const Duration(seconds: 20));

      // ----------------------------------------------------------
      // DECODE RESPONSE
      // ----------------------------------------------------------

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

      // ----------------------------------------------------------
      // LOGIN SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200 && body["status"] == true) {
        final data = body["data"];

        if (data == null || data is! Map) {
          return {
            "success": false,
            "message": "Invalid login response from server.",
          };
        }

        // --------------------------------------------------------
        // USER
        // --------------------------------------------------------

        final rawUser = data["user"];

        if (rawUser == null || rawUser is! Map) {
          return {
            "success": false,
            "message": "User information was not returned by the server.",
          };
        }

        final userData = Map<String, dynamic>.from(rawUser);

        // --------------------------------------------------------
        // TOKENS
        // --------------------------------------------------------

        final rawTokens = data["tokens"];

        if (rawTokens == null || rawTokens is! Map) {
          return {
            "success": false,
            "message": "Authentication token was not returned by the server.",
          };
        }

        final tokenData = Map<String, dynamic>.from(rawTokens);

        // --------------------------------------------------------
        // ACCESS TOKEN
        // --------------------------------------------------------

        final accessToken = tokenData["access_token"]?.toString();

        if (accessToken == null || accessToken.isEmpty) {
          return {
            "success": false,
            "message": "Authentication token is missing.",
          };
        }

        _accessToken = accessToken;

        // --------------------------------------------------------
        // REFRESH TOKEN
        // --------------------------------------------------------

        final refreshToken = tokenData["refresh_token"]?.toString();

        // --------------------------------------------------------
        // CONVERT API USER TO APP USER
        // --------------------------------------------------------

        _currentUser = _userFromApi(userData);

        // --------------------------------------------------------
        // REMEMBER ME
        // --------------------------------------------------------

        _rememberMe = rememberMe;

        // --------------------------------------------------------
        // SAVE SESSION
        // --------------------------------------------------------

        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool(_rememberMeKey, rememberMe);

        if (rememberMe) {
          // ------------------------------------------------------
          // Save session permanently.
          // ------------------------------------------------------

          await prefs.setString(_accessTokenKey, _accessToken!);

          if (refreshToken != null && refreshToken.isNotEmpty) {
            await prefs.setString(_refreshTokenKey, refreshToken);
          }

          await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
        } else {
          // ------------------------------------------------------
          // Do NOT save login session.
          //
          // The user remains logged in while the app is running,
          // but after the app is completely closed/reopened,
          // initialize() will not restore the session.
          // ------------------------------------------------------

          await prefs.remove(_accessTokenKey);
          await prefs.remove(_refreshTokenKey);
          await prefs.remove(_userKey);
        }

        // --------------------------------------------------------
        // SUCCESS
        // --------------------------------------------------------

        return {
          "success": true,
          "message": body["message"]?.toString() ?? "Login successful.",
          "user": _currentUser,
        };
      }

      // ----------------------------------------------------------
      // LOGIN FAILED
      // ----------------------------------------------------------

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
  // REGISTER API
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
            Uri.parse("$baseUrl/auth/register"),
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

      // ----------------------------------------------------------
      // DECODE RESPONSE
      // ----------------------------------------------------------

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

      // ----------------------------------------------------------
      // REGISTRATION SUCCESS
      // ----------------------------------------------------------

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body["status"] == true) {
        final data = body["data"];

        if (data == null || data is! Map) {
          return {
            "success": false,
            "message": "Invalid registration response.",
          };
        }

        // --------------------------------------------------------
        // USER
        // --------------------------------------------------------

        final rawUser = data["user"];

        if (rawUser == null || rawUser is! Map) {
          return {
            "success": false,
            "message": "User information was not returned.",
          };
        }

        final userData = Map<String, dynamic>.from(rawUser);

        // --------------------------------------------------------
        // TOKENS
        // --------------------------------------------------------

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

        // --------------------------------------------------------
        // REFRESH TOKEN
        // --------------------------------------------------------

        final refreshToken = tokenData["refresh_token"]?.toString();

        // --------------------------------------------------------
        // CREATE APP USER
        // --------------------------------------------------------

        _currentUser = _userFromApi(userData, selectedRole: role);

        // --------------------------------------------------------
        // REGISTRATION CREATES AN ACTIVE SESSION
        //
        // This allows the user to go directly to the home feed
        // after registration.
        // --------------------------------------------------------

        _rememberMe = true;

        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool(_rememberMeKey, true);

        await prefs.setString(_accessTokenKey, _accessToken!);

        if (refreshToken != null && refreshToken.isNotEmpty) {
          await prefs.setString(_refreshTokenKey, refreshToken);
        }

        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

        // --------------------------------------------------------
        // SUCCESS
        // --------------------------------------------------------

        return {
          "success": true,
          "message": body["message"]?.toString() ?? "Registration successful.",
          "user": _currentUser,
        };
      }

      // ----------------------------------------------------------
      // REGISTRATION FAILED
      // ----------------------------------------------------------

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
  // CONVERT API USER TO APP USER
  // ============================================================

  static User _userFromApi(Map<String, dynamic> data, {String? selectedRole}) {
    final int id = int.tryParse(data["id"]?.toString() ?? "") ?? 0;

    final String userType = data["user_type"]?.toString() ?? "customer";

    String appRole;

    // ------------------------------------------------------------
    // Registration role has priority.
    // ------------------------------------------------------------

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
      profileImage:
          data["avatar"]?.toString() ?? "assets/images/r1.jpg",
      coverImage:
          data["cover_image"]?.toString() ?? "assets/images/r2.jpg",
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
            Uri.parse("$baseUrl/profiles?user_id=${_currentUser!.id}"),
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
  //
  // This completely removes the saved session.
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
        Uri.parse("$baseUrl/auth/forgot-password"),
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
        Uri.parse("$baseUrl/auth/reset-password"),
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

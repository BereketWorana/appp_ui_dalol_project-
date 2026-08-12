import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/services/auth_service.dart';

class UpgradeService {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = AuthService.baseUrl;

  // ============================================================
  // REGISTER MERCHANT / HOTEL ADMIN
  // ============================================================

  static Future<Map<String, dynamic>> registerMerchant({
    required String businessName,
    required String businessType,
    required String description,
    required String location,
    required String phone,
  }) async {
    try {
      final token = AuthService.accessToken;

      if (token == null) {
        return {
          "success": false,
          "message": "You must be logged in to submit an application.",
        };
      }

      final response = await http.post(
        Uri.parse("$baseUrl/hotel-admin/register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "business_name": businessName,
          "business_type": businessType,
          "description": description,
          "location": location,
          "phone": phone,
        }),
      );

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded is Map &&
          (decoded["status"] == true || decoded["success"] == true)) {
        return {
          "success": true,
          "message":
              decoded["message"]?.toString() ??
              "Hotel application submitted successfully.",
          "data": decoded["data"],
        };
      }

      return {
        "success": false,
        "message": _extractMessage(decoded, response.statusCode),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to the server. Please try again.",
      };
    }
  }

  // ============================================================
  // REGISTER CREATOR / INFLUENCER
  // ============================================================

  static Future<Map<String, dynamic>> registerCreator({
    required String bio,
    required String category,
    required String phone,
  }) async {
    try {
      final token = AuthService.accessToken;

      if (token == null) {
        return {
          "success": false,
          "message": "You must be logged in to submit an application.",
        };
      }

      final response = await http.post(
        Uri.parse("$baseUrl/influencer/register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"bio": bio, "category": category, "phone": phone}),
      );

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded is Map &&
          (decoded["status"] == true || decoded["success"] == true)) {
        return {
          "success": true,
          "message":
              decoded["message"]?.toString() ??
              "Creator application submitted successfully.",
          "data": decoded["data"],
        };
      }

      return {
        "success": false,
        "message": _extractMessage(decoded, response.statusCode),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to the server. Please try again.",
      };
    }
  }

  // ============================================================
  // MERCHANT STATUS
  // ============================================================

  static Future<Map<String, dynamic>> merchantStatus() async {
    return _getStatus("$baseUrl/hotel-admin/status");
  }

  // ============================================================
  // CREATOR STATUS
  // ============================================================

  static Future<Map<String, dynamic>> creatorStatus() async {
    return _getStatus("$baseUrl/influencer/status");
  }

  // ============================================================
  // STATUS REQUEST
  // ============================================================

  static Future<Map<String, dynamic>> _getStatus(String url) async {
    try {
      final token = AuthService.accessToken;

      if (token == null) {
        return {"success": false, "message": "You must be logged in."};
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded is Map &&
          (decoded["status"] == true || decoded["success"] == true)) {
        return {
          "success": true,
          "message": decoded["message"]?.toString(),
          "data": decoded["data"],
        };
      }

      return {
        "success": false,
        "message": _extractMessage(decoded, response.statusCode),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to check application status.",
      };
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  static String _extractMessage(dynamic body, int statusCode) {
    if (body == null) {
      return "Request failed. Server returned status $statusCode.";
    }

    if (body is Map) {
      final message = body["message"];

      if (message is String && message.isNotEmpty) {
        return message;
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

      if (body["error"] is String) {
        return body["error"].toString();
      }
    }

    return "Request failed. Please check your information and try again.";
  }
}

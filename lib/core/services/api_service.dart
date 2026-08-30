import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  // ============================================================
  // POST REQUEST
  // ============================================================
  
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (requireAuth && AuthService.hasValidToken) {
        headers['Authorization'] = 'Bearer ${AuthService.accessToken}';
      }

      print('📤 ===== POST REQUEST =====');
      print('📤 URL: $uri');
      print('📤 Headers: $headers');
      print('📤 Body: ${jsonEncode(body)}');

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('❌ Request timed out after 30 seconds');
              throw Exception('Connection timeout. Please try again.');
            },
          );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('❌ Client Exception: $e');
      return {
        'success': false,
        'message': 'Unable to connect to server. Please check your internet connection.',
        'error': e.toString(),
      };
    } catch (e) {
      print('❌ POST Error: $e');
      return {
        'success': false,
        'message': 'Failed to create booking: $e',
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // GET REQUEST
  // ============================================================
  
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final headers = <String, String>{
        'Accept': 'application/json',
      };

      if (requireAuth && AuthService.hasValidToken) {
        headers['Authorization'] = 'Bearer ${AuthService.accessToken}';
      }

      print('📤 GET: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch data',
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // PUT REQUEST
  // ============================================================

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (requireAuth && AuthService.hasValidToken) {
        headers['Authorization'] = 'Bearer ${AuthService.accessToken}';
      }

      print('📤 PUT: $uri');
      print('📤 Body: ${jsonEncode(body)}');

      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Connection timeout. Please try again.');
            },
          );

      print('📥 PUT Status: ${response.statusCode}');
      print('📥 PUT Body: ${response.body}');

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('❌ PUT Client Exception: $e');
      return {
        'success': false,
        'message': 'Unable to connect to server. Please check your internet connection.',
        'error': e.toString(),
      };
    } catch (e) {
      print('❌ PUT Error: $e');
      return {
        'success': false,
        'message': 'Request failed: $e',
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // DELETE REQUEST
  // ============================================================

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final headers = <String, String>{
        'Accept': 'application/json',
      };

      if (requireAuth && AuthService.hasValidToken) {
        headers['Authorization'] = 'Bearer ${AuthService.accessToken}';
      }

      print('📤 DELETE: $uri');

      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 DELETE Status: ${response.statusCode}');
      print('📥 DELETE Body: ${response.body}');

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('❌ DELETE Client Exception: $e');
      return {
        'success': false,
        'message': 'Unable to connect to server. Please check your internet connection.',
        'error': e.toString(),
      };
    } catch (e) {
      print('❌ DELETE Error: $e');
      return {
        'success': false,
        'message': 'Request failed: $e',
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // HANDLE RESPONSE
  // ============================================================
  
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Server error',
          'status_code': response.statusCode,
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid response from server',
        'error': e.toString(),
      };
    }
  }
}

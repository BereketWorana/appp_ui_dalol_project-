import 'dart:async';  // Add this for Completer
import 'dart:convert';
import 'dart:html' as html;
import 'auth_service.dart';

class WebApiService {
  static const String baseUrl = "https://booking.dalloltech.com/api";

  // ============================================================
  // POST REQUEST - Using html.HttpRequest (bypasses CORS on web)
  // ============================================================
  
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final url = '$baseUrl$endpoint';
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (requireAuth && AuthService.hasValidToken) {
        headers['Authorization'] = 'Bearer ${AuthService.accessToken}';
      }
      
      print('📤 ===== WEB POST REQUEST =====');
      print('📤 URL: $url');
      print('📤 Body: ${body != null ? jsonEncode(body) : 'null'}');
      
      // Use html.HttpRequest for web (bypasses CORS)
      final request = html.HttpRequest();
      request.open('POST', url);
      
      headers.forEach((key, value) {
        request.setRequestHeader(key, value);
      });
      
      // Send the request
      final completer = Completer<Map<String, dynamic>>();
      
      request.onLoad.listen((event) {
        try {
          final responseData = jsonDecode(request.responseText ?? '{}');
          final status = request.status ?? 0;
          print('📥 Response Status: $status');
          print('📥 Response Body: ${request.responseText}');
          
          if (status >= 200 && status < 300) {
            completer.complete(responseData);
          } else {
            completer.complete({
              'success': false,
              'message': responseData['message']?.toString() ?? 'An error occurred',
              'status_code': status,
            });
          }
        } catch (e) {
          completer.complete({
            'success': false,
            'message': 'Invalid response from server',
          });
        }
      });
      
      request.onError.listen((event) {
        completer.complete({
          'success': false,
          'message': 'Failed to connect to server',
        });
      });
      
      request.send(body != null ? jsonEncode(body) : null);
      
      return await completer.future;
    } catch (e) {
      print('❌ POST Error: $e');
      return {
        'success': false,
        'message': 'Failed to create booking',
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // GET REQUEST - Using html.HttpRequest
  // ============================================================
  
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requireAuth = false,
  }) async {
    try {
      var url = '$baseUrl$endpoint';
      if (queryParams != null && queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$queryString';
      }
      
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      
      if (requireAuth && AuthService.hasValidToken) {
        headers['Authorization'] = 'Bearer ${AuthService.accessToken}';
      }
      
      print('📤 ===== WEB GET REQUEST =====');
      print('📤 URL: $url');
      
      final request = html.HttpRequest();
      request.open('GET', url);
      
      headers.forEach((key, value) {
        request.setRequestHeader(key, value);
      });
      
      final completer = Completer<Map<String, dynamic>>();
      
      request.onLoad.listen((event) {
        try {
          final responseData = jsonDecode(request.responseText ?? '{}');
          final status = request.status ?? 0;
          print('📥 Response Status: $status');
          print('📥 Response Body: ${request.responseText}');
          
          if (status >= 200 && status < 300) {
            completer.complete(responseData);
          } else {
            completer.complete({
              'success': false,
              'message': responseData['message']?.toString() ?? 'An error occurred',
              'status_code': status,
            });
          }
        } catch (e) {
          completer.complete({
            'success': false,
            'message': 'Invalid response from server',
          });
        }
      });
      
      request.onError.listen((event) {
        completer.complete({
          'success': false,
          'message': 'Failed to connect to server',
        });
      });
      
      request.send();
      
      return await completer.future;
    } catch (e) {
      print('❌ GET Error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch data',
        'error': e.toString(),
      };
    }
  }
}

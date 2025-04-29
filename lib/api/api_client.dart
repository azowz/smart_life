// lib/api/api_client.dart

import 'dart:convert';
import 'package:final_project/api/services/auth_service.dart';
import 'package:http/http.dart' as http;
import '../api/api_config.dart';

class ApiClient {
  static String baseUrl = 'http://10.0.2.2:8000';

  static void initialize({required String url}) {
    baseUrl = url;
  }

  static bool get isAuthenticated => ApiConfig.authToken != null;

  static Map<String, String> _getHeaders(
      {bool withAuth = true, bool useFormEncoding = false}) {
    final headers = <String, String>{};

    if (useFormEncoding) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    } else {
      headers['Content-Type'] = 'application/json';
    }

    if (withAuth && ApiConfig.authToken != null) {
      headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';
    }

    return headers;
  }

  static Future<http.Response> get(String endpoint,
      {bool withAuth = true}) async {
    return _sendRequest(() => http.get(Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(withAuth: withAuth)));
  }

  static Future<http.Response> post(String endpoint, dynamic body,
      {bool withAuth = true, bool useFormEncoding = false}) async {
    final headers =
        _getHeaders(withAuth: withAuth, useFormEncoding: useFormEncoding);
    final requestBody = useFormEncoding ? body : jsonEncode(body);

    return _sendRequest(() => http.post(Uri.parse('$baseUrl$endpoint'),
        headers: headers, body: requestBody));
  }

  static Future<http.Response> put(String endpoint, dynamic body,
      {bool withAuth = true}) async {
    final headers = _getHeaders(withAuth: withAuth);
    final requestBody = jsonEncode(body);

    return _sendRequest(() => http.put(Uri.parse('$baseUrl$endpoint'),
        headers: headers, body: requestBody));
  }

  static Future<http.Response> patch(String endpoint, dynamic body,
      {bool withAuth = true}) async {
    final headers = _getHeaders(withAuth: withAuth);
    final requestBody = jsonEncode(body);

    return _sendRequest(() => http.patch(Uri.parse('$baseUrl$endpoint'),
        headers: headers, body: requestBody));
  }

  static Future<http.Response> delete(String endpoint,
      {bool withAuth = true}) async {
    return _sendRequest(() => http.delete(Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(withAuth: withAuth)));
  }

  static Future<http.Response> _sendRequest(
      Future<http.Response> Function() requestFn) async {
    try {
      http.Response response = await requestFn();

      if (response.statusCode == 401) {
        print('🔁 Token expired or unauthorized. Trying refresh...');

        // Attempt token refresh
        final refreshed = await _attemptRefreshToken();

        if (refreshed) {
          print('✅ Token refreshed. Retrying original request...');
          response = await requestFn();
        } else {
          print('❌ Unable to refresh token. Logging out.');
          ApiConfig.clearTokens();
          throw Exception('Unauthorized. Please login again.');
        }
      }

      return response;
    } catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> _attemptRefreshToken() async {
    try {
      final refresh = ApiConfig.refreshToken;
      if (refresh == null) return false;

      final refreshedData = await AuthService.refreshToken();

      ApiConfig.authToken = refreshedData['access_token'];
      if (refreshedData['refresh_token'] != null) {
        ApiConfig.refreshToken = refreshedData['refresh_token'];
      }

      return true;
    } catch (e) {
      print('❌ Failed to refresh token: $e');
      return false;
    }
  }
}

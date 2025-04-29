import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:final_project/api/services/auth_service.dart';
import '../api/api_config.dart';

class ApiClient {
  static String baseUrl = 'http://10.0.2.2:8000';

  // Allows override of the base URL
  static void initialize({required String url}) {
    baseUrl = url;
  }

  static bool get isAuthenticated => ApiConfig.authToken != null;

  // Generates headers for requests
  static Map<String, String> _getHeaders({
    bool withAuth = true,
    bool useFormEncoding = false,
  }) {
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

  /// HTTP GET
  static Future<http.Response> get(String endpoint,
      {bool withAuth = true}) async {
    return _sendRequest(() => http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: _getHeaders(withAuth: withAuth),
        ));
  }

  /// HTTP POST
  static Future<http.Response> post(String endpoint, dynamic body,
      {bool withAuth = true, bool useFormEncoding = false}) async {
    final headers =
        _getHeaders(withAuth: withAuth, useFormEncoding: useFormEncoding);
    final requestBody = useFormEncoding ? body : jsonEncode(body);

    print('🟢 POST → $baseUrl$endpoint');
    print('📦 Body: $requestBody');

    return _sendRequest(() => http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: requestBody,
        ));
  }

  /// HTTP PUT
  static Future<http.Response> put(String endpoint, dynamic body,
      {bool withAuth = true}) async {
    final headers = _getHeaders(withAuth: withAuth);
    final requestBody = jsonEncode(body);

    print('🟣 PUT → $baseUrl$endpoint');
    print('📦 Body: $requestBody');

    return _sendRequest(() => http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: requestBody,
        ));
  }

  /// HTTP PATCH
  static Future<http.Response> patch(String endpoint, dynamic body,
      {bool withAuth = true}) async {
    final headers = _getHeaders(withAuth: withAuth);
    final requestBody = jsonEncode(body);

    print('🟡 PATCH → $baseUrl$endpoint');
    print('📦 Body: $requestBody');

    return _sendRequest(() => http.patch(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: requestBody,
        ));
  }

  /// HTTP DELETE
  static Future<http.Response> delete(String endpoint,
      {bool withAuth = true}) async {
    print('🔴 DELETE → $baseUrl$endpoint');
    return _sendRequest(() => http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: _getHeaders(withAuth: withAuth),
        ));
  }

  // Wrapper for handling requests and retrying if token expired
  static Future<http.Response> _sendRequest(
      Future<http.Response> Function() requestFn) async {
    try {
      http.Response response = await requestFn();

      if (response.statusCode == 401) {
        print('🔁 Token expired. Attempting refresh...');

        final refreshed = await _attemptRefreshToken();
        if (refreshed) {
          print('✅ Token refreshed. Retrying request...');
          response = await requestFn();
        } else {
          print('❌ Refresh failed. Logging out.');
          ApiConfig.clearTokens();
          throw Exception('Unauthorized. Please log in again.');
        }
      }

      return response;
    } catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Token refresh logic
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

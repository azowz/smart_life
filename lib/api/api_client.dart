// lib/api/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static String baseUrl =
      'http://10.0.2.2:8000'; // Default URL for Android emulator
  static String? _authToken;

  // Initialize API client with base URL and optional token
  static void initialize(String url, {String? authToken}) {
    baseUrl = url;
    _authToken = authToken;
  }

  // Set authentication token
  static void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear authentication token (for logout)
  static void clearAuthToken() {
    _authToken = null;
  }

  // Check if user is authenticated
  static bool get isAuthenticated => _authToken != null;

  // Create headers with optional auth token
  static Map<String, String> _getHeaders({bool withAuth = true}) {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // GET request
  static Future<http.Response> get(String endpoint,
      {bool withAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(withAuth: withAuth),
      );
      return response;
    } catch (e) {
      print('GET request error: $e');
      throw Exception('Network error: $e');
    }
  }

  // POST request
  static Future<http.Response> post(
    String endpoint,
    dynamic body, {
    bool withAuth = true,
    bool useFormEncoding = false,
  }) async {
    try {
      final headers = _getHeaders(withAuth: withAuth);

      if (useFormEncoding) {
        headers['Content-Type'] = 'application/x-www-form-urlencoded';
      }

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: useFormEncoding ? body : jsonEncode(body),
      );
      return response;
    } catch (e) {
      print('POST request error: $e');
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  static Future<http.Response> put(
    String endpoint,
    dynamic body, {
    bool withAuth = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(withAuth: withAuth),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print('PUT request error: $e');
      throw Exception('Network error: $e');
    }
  }

  // PATCH request
  static Future<http.Response> patch(
    String endpoint,
    dynamic body, {
    bool withAuth = true,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(withAuth: withAuth),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print('PATCH request error: $e');
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  static Future<http.Response> delete(
    String endpoint, {
    bool withAuth = true,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(withAuth: withAuth),
      );
      return response;
    } catch (e) {
      print('DELETE request error: $e');
      throw Exception('Network error: $e');
    }
  }
}

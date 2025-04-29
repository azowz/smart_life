// lib/api/api_config.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static String? authToken;
  static String? refreshToken;

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Check if user is authenticated
  static bool get isAuthenticated => authToken != null;

  /// Save access token in memory and secure storage
  static Future<void> setAuthToken(String token) async {
    authToken = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
      print('✅ Access token saved to secure storage');
    } catch (e) {
      print('❌ Error saving access token: $e');
    }
  }

  /// Save refresh token in memory and secure storage
  static Future<void> setRefreshToken(String token) async {
    refreshToken = token;
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      print('✅ Refresh token saved to secure storage');
    } catch (e) {
      print('❌ Error saving refresh token: $e');
    }
  }

  /// Clear both tokens from memory and storage
  static Future<void> clearTokens() async {
    authToken = null;
    refreshToken = null;
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      print('✅ Tokens cleared from secure storage');
    } catch (e) {
      print('❌ Error clearing tokens: $e');
    }
  }

  /// Initialize tokens from storage at app startup
  static Future<void> initialize() async {
    try {
      final savedToken = await _storage.read(key: _tokenKey);
      final savedRefreshToken = await _storage.read(key: _refreshTokenKey);

      if (savedToken != null) {
        authToken = savedToken;
        print('✅ Loaded access token from secure storage');
      }

      if (savedRefreshToken != null) {
        refreshToken = savedRefreshToken;
        print('✅ Loaded refresh token from secure storage');
      }
    } catch (e) {
      print('❌ Error loading tokens from secure storage: $e');
      authToken = null;
      refreshToken = null;
    }
  }
}

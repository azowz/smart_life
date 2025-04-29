// lib/api/services/auth_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

class AuthService {
  // Login function with proper form data encoding for FastAPI
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/token');

    // Critical fix: FastAPI OAuth2PasswordRequestForm requires x-www-form-urlencoded
    // with key-value pairs as a string, not a map
    final encodedUsername = Uri.encodeComponent(username.trim());
    final encodedPassword = Uri.encodeComponent(password.trim());
    final formBody = 'username=$encodedUsername&password=$encodedPassword';

    print('🔐 Attempting login for user: $username');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: formBody, // Use the properly formatted string
      );

      print('📊 Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Login successful');

        // Save tokens for future requests
        await ApiConfig.setAuthToken(data['access_token']);
        if (data['refresh_token'] != null) {
          await ApiConfig.setRefreshToken(data['refresh_token']);
        }

        return data;
      } else {
        print('❌ Login failed: ${response.body}');
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception('Login error: $e');
    }
  }

  // Refresh token function with proper formatting
  static Future<Map<String, dynamic>> refreshToken() async {
    final refresh = ApiConfig.refreshToken;
    if (refresh == null) {
      throw Exception('No refresh token available');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/refresh_token');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refresh}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update tokens
        await ApiConfig.setAuthToken(data['access_token']);
        if (data['refresh_token'] != null) {
          await ApiConfig.setRefreshToken(data['refresh_token']);
        }

        return data;
      } else {
        throw Exception('Failed to refresh token: ${response.body}');
      }
    } catch (e) {
      print('❌ Refresh token error: $e');
      throw Exception('Refresh token error: $e');
    }
  }

  // Create user function (registration)
  static Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String gender,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/register');

    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'gender': gender,
    };

    print('👤 Creating new user: $username');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('📊 Registration response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ User created successfully');

        // If response includes tokens, save them
        try {
          final responseData = json.decode(response.body);
          if (responseData['access_token'] != null) {
            await ApiConfig.setAuthToken(responseData['access_token']);
          }
          if (responseData['refresh_token'] != null) {
            await ApiConfig.setRefreshToken(responseData['refresh_token']);
          }
        } catch (e) {
          print('⚠️ Notice: Could not parse tokens from registration response');
        }

        return true;
      } else {
        print('❌ Failed to create user: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Create user error: $e');
      return false;
    }
  }

  // Create account with additional details
  static Future<bool> createAccount({
    required String username,
    required List<String> habits,
    required bool agreeToTerms,
    required bool subscribeToEmails,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/create_account');

    final Map<String, dynamic> data = {
      'username': username,
      'habits': habits,
      'agreeToTerms': agreeToTerms,
      'subscribeToEmails': subscribeToEmails,
    };

    // Need token for this endpoint
    if (ApiConfig.authToken == null) {
      print('❌ Authentication token missing for createAccount');
      return false;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.authToken}',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Account created successfully');
        return true;
      } else {
        print('❌ Failed to create account: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Create account error: $e');
      return false;
    }
  }
}

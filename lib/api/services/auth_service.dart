import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart'; // Import api_config.dart to access baseUrl

class AuthService {
  // Login function with email or username
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/token'); // Use the baseUrl from ApiConfig
    final body = _isValidEmail(username)
        ? {'email': username, 'password': password}
        : {'username': username, 'password': password};

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Function to validate email format
  static bool _isValidEmail(String input) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(input);
  }

  // Function to refresh the access token using refresh token
  static Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/refresh_token'); // Use the baseUrl from ApiConfig
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'refresh_token': refreshToken},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }

  // Function to create a new user (Register)
  static Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String gender,
  }) async {
    // Updated endpoint to use the public registration endpoint
    final url = Uri.parse('${ApiConfig.baseUrl}/users/register');
    final data = {
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone_number': phoneNumber, // Changed from 'phone' to 'phone_number'
      'password': password,
      'gender': gender,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // No authentication token needed for registration
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('User created: ${response.body}');
        return true;
      } else {
        print('Failed to create user: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error in createUser: $e');
      return false;
    }
  }

  // Function to create an account (Account registration with additional details)
  static Future<bool> createAccount({
    required String username,
    required List<String> habits,
    required bool agreeToTerms,
    required bool subscribeToEmails,
  }) async {
    final Map<String, dynamic> data = {
      'username': username,
      'habits': habits,
      'agreeToTerms': agreeToTerms,
      'subscribeToEmails': subscribeToEmails,
    };

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/users/create_account'); // Use the baseUrl from ApiConfig
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Account created successfully: ${response.body}');
      return true;
    } else {
      print('❌ Failed to create account: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }
}

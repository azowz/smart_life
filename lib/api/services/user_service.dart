import '../api_client.dart';
import 'dart:convert';

class UserService {
  /// Fetch current user data
  static Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await ApiClient.get('/users/me');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch current user');
    }
  }

  /// Fetch user data by ID
  static Future<Map<String, dynamic>> fetchUserById(int userId) async {
    final response = await ApiClient.get('/users/$userId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user by ID');
    }
  }

  /// Create a new user (register)
  static Future<Map<String, dynamic>> createUser({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    String? phoneNumber,
  }) async {
    final response = await ApiClient.post(
      '/users/register', // Updated to use the new register endpoint
      {
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'phone_number': phoneNumber, // Fixed field name to match API
      },
      withAuth: false,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  /// Update user password
  static Future<bool> updateUserPassword({
    required int userId,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    final response = await ApiClient.patch(
      '/users/$userId/password/',
      {
        'password': newPassword,
        'password_confirm': confirmPassword,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update password: ${response.body}');
    }
  }
}

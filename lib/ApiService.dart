import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Make sure this URL is correct
  static String? _authToken;

  // Save token after sign in
  static void setAuthToken(String token) {
    _authToken = token;
  }

  // Initialize the API service with the token
  static void initialize() {
    setAuthToken('your_token_here'); // Set a valid token if needed
  }

  // Check if the input is a valid email
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  // Sign in using username or email
  static Future<String> signInByEmailOrUsername(String input, String password) async {
    final url = Uri.parse('$baseUrl/token');
    
    final body = _isValidEmail(input)
      ? {'email': input, 'password': password}  // Use email if valid
      : {'username': input, 'password': password}; // Use username otherwise

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setAuthToken(data['access_token']);
      return 'Success';
    } else {
      return 'Failed: ${response.body}';
    }
  }

  // Create user
  static Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String gender,
  }) async {
    final url = Uri.parse('$baseUrl/users/'); // Ensure this matches your FastAPI route
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone': phoneNumber,
      'password': password,
      'gender': gender,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
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

  // Update user password
  static Future<bool> updateUserPassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      print('Passwords do not match');
      return false;
    }

    final url = Uri.parse('$baseUrl/users/$userId/password/'); // Correct URL for password update
    final Map<String, dynamic> data = {
      'password': newPassword,
      'password_confirm': confirmPassword,
    };

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Password updated: ${response.body}');
        return true;
      } else {
        print('Failed to update password: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error in updateUserPassword: $e');
      return false;
    }
  }

  // Get all content
  static Future<List<dynamic>> getAllContent() async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load content');
    }
  }

  // Get content by ID or slug
  static Future<Map<String, dynamic>> getContent(String idOrSlug) async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/$idOrSlug/'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Content not found');
    }
  }

  // Create content (requires auth)
  static Future<Map<String, dynamic>> createContent(Map<String, dynamic> content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/content/'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
      body: json.encode(content),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create content');
    }
  }

  // Update content (requires auth)
  static Future<Map<String, dynamic>> updateContent(int contentId, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/content/$contentId/'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update content');
    }
  }

  // Delete content (requires auth)
  static Future<bool> deleteContent(int contentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/content/$contentId/'),
      headers: {
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );

    return response.statusCode == 200;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void initialize() {
    setAuthToken('YOur_token_here');
  }

  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  static Future<String> signInByEmailOrUsername(
      String input, String password) async {
    final url = Uri.parse('$baseUrl/token');
    final body = _isValidEmail(input)
        ? {'email': input, 'password': password}
        : {'username': input, 'password': password};

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

  static Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String gender,
  }) async {
    final url = Uri.parse('$baseUrl/users/');
    final data = {
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

    final url = Uri.parse('$baseUrl/users/$userId/password/');
    final data = {
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

  static Future<Map<String, dynamic>> createContent(
      Map<String, dynamic> content) async {
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

  static Future<Map<String, dynamic>> updateContent(
      int contentId, Map<String, dynamic> updates) async {
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

  static Future<bool> deleteContent(int contentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/content/$contentId/'),
      headers: {
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> submitHabitsForUser({
    required int userId,
    required List<String> habits,
  }) async {
    final url = Uri.parse('$baseUrl/users/$userId/habits/');
    final data = {'habits': habits};

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Habits submitted: ${response.body}');
        return true;
      } else {
        print('Failed to submit habits: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting habits: $e');
      return false;
    }
  }

  static Future<bool> addUserHabits({
    required String username,
    required List<String> habits,
  }) async {
    final url = Uri.parse('$baseUrl/habits/bulk_add/');
    final data = {
      'username': username,
      'habits': habits,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Habits added successfully: ${response.body}');
        return true;
      } else {
        print('Failed to add habits: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error in addUserHabits: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> fetchUserData(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/username/$username/'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  static Future<Map<String, dynamic>?> fetchUserDataByUsername(
      String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  static Future<bool> createAccount({
    required String username,
    required List<String> habits,
    required bool agreeToTerms,
    required bool subscribeToEmails,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'habits': habits,
        'agreeToTerms': agreeToTerms,
        'subscribeToEmails': subscribeToEmails,
      }),
    );

    return response.statusCode == 201;
  }

  static Future<void> testBulkAddConnection() async {
    final url = Uri.parse('$baseUrl/habits/bulk_add/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('Test connection success');
      } else {
        print('Failed to test connection: ${response.statusCode}');
      }
    } catch (e) {
      print('Error testing connection: $e');
    }
  }

  /// AI Chat Methods
  static Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    String? conversationId,
    String? userId,
  }) async {
    final url = Uri.parse('$baseUrl/ai/chat/');
    final data = {
      'message': message,
      if (conversationId != null) 'conversation_id': conversationId,
      if (userId != null) 'user_id': userId,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in sendChatMessage: $e');
      throw Exception('Failed to connect to AI service');
    }
  }

  static Future<Map<String, dynamic>> startNewConversation({
    required String userId,
    String? initialMessage,
  }) async {
    final url = Uri.parse('$baseUrl/ai/conversation/');
    final data = {
      'user_id': userId,
      if (initialMessage != null) 'initial_message': initialMessage,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to start conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in startNewConversation: $e');
      throw Exception('Failed to start new conversation');
    }
  }

// In ApiService class
  static Future<List<Map<String, dynamic>>> getConversationHistory(
      String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ai/conversations/$userId/'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);

      // Handle both List<String> and List<Map> responses
      if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else {
            return {'id': item.toString(), 'name': 'Conversation'};
          }
        }).toList();
      }
      throw Exception('Unexpected response format');
    }
    throw Exception('Failed to load history');
  }

  static Future<Map<String, dynamic>> getConversation(
      String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ai/conversation/$conversationId/'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Ensure messages are properly formatted
      if (data['messages'] is List) {
        final messages = data['messages'].map((msg) {
          if (msg is Map) {
            return {
              'content': msg['content'] ?? msg['text'] ?? '',
              'sender': msg['sender'] ?? (msg['isUser'] ? 'user' : 'ai')
            };
          }
          return {'content': msg.toString(), 'sender': 'ai'};
        }).toList();

        return {...data, 'messages': messages};
      }
      return data;
    }
    throw Exception('Conversation not found');
  }


  // Method to add a habit to the database
 
  // دالة إضافة عادة (بدون تذكير)
  Future<bool> addHabit(String name, String color, int goal, String frequency) async {
    final url = Uri.parse('$baseUrl/habits/');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'color': color,
          'goal': goal,
          'frequency': frequency,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add habit: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding habit: $e');
      return false;
    }
  }
  
  // دالة إنشاء عادة (مع تذكير)
  Future<bool> createHabit(String habitName, String color, int goal, String frequency, String reminder) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/habits/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'habit_name': habitName,
          'color': color,
          'goal': goal,
          'frequency': frequency,
          'reminder': reminder,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to create habit: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating habit: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> sendChatMessageWithUser({
  required String message,
  required String userId,
  String? conversationId,
}) async {
  final url = Uri.parse('$baseUrl/ai/chat/');  // Ensure the endpoint is correct for sending chat messages.

  final data = {
    'message': message,
    'user_id': userId,  // User ID to link the chat message
    if (conversationId != null) 'conversation_id': conversationId,  // Optional: If conversation exists
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',  // Include the auth token for authorization
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);  // Successfully sent the message
    } else {
      throw Exception('Failed to get AI response: ${response.statusCode}');  // Handle errors
    }
  } catch (e) {
    print('Error in sendChatMessageWithUser: $e');
    throw Exception('Failed to connect to AI service');
  }
}

}




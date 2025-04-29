import '../api_client.dart';
import 'dart:convert';

class UserSettingsService {
  /// Create user settings
  static Future<Map<String, dynamic>> createSettings(
      Map<String, dynamic> settingsData) async {
    final response = await ApiClient.post('/user-settings/', settingsData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user settings');
    }
  }

  /// Get settings for a user
  static Future<Map<String, dynamic>> getSettings(int userId) async {
    final response = await ApiClient.get('/user-settings/$userId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user settings');
    }
  }

  /// Update user settings
  static Future<Map<String, dynamic>> updateSettings(
      int userId, Map<String, dynamic> updates) async {
    final response = await ApiClient.patch('/user-settings/$userId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update user settings');
    }
  }

  /// Delete user settings
  static Future<void> deleteSettings(int userId) async {
    final response = await ApiClient.delete('/user-settings/$userId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user settings');
    }
  }
}

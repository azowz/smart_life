import '../api_client.dart';
import 'dart:convert';

class SystemSettingService {
  /// Get all system settings
  static Future<List<dynamic>> getAllSettings() async {
    final response = await ApiClient.get('/system-settings/');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch system settings');
    }
  }

  /// Get single setting by key
  static Future<Map<String, dynamic>> getSetting(String key) async {
    final response = await ApiClient.get('/system-settings/$key');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Setting not found');
    }
  }

  /// Create or update a setting
  static Future<Map<String, dynamic>> createOrUpdateSetting(
      Map<String, dynamic> settingData) async {
    final response = await ApiClient.post('/system-settings/', settingData);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to save system setting: ${response.body}');
    }
  }

  /// Delete a setting by key
  static Future<void> deleteSetting(String key) async {
    final response = await ApiClient.delete('/system-settings/$key');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete system setting');
    }
  }
}

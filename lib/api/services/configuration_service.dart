import '../api_client.dart';
import 'dart:convert';

class ConfigurationService {
  /// Get all configurations
  static Future<List<dynamic>> getAllConfigurations() async {
    final response = await ApiClient.get('/configuration/');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch configurations');
    }
  }

  /// Get active configuration
  static Future<Map<String, dynamic>> getActiveConfiguration() async {
    final response = await ApiClient.get('/configuration/active');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch active configuration');
    }
  }

  /// Create a new configuration
  static Future<Map<String, dynamic>> createConfiguration(
      Map<String, dynamic> configData) async {
    final response = await ApiClient.post('/configuration/', configData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create configuration: ${response.body}');
    }
  }

  /// Update an existing configuration
  static Future<Map<String, dynamic>> updateConfiguration(
      int configId, Map<String, dynamic> updates) async {
    final response = await ApiClient.patch('/configuration/$configId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update configuration: ${response.body}');
    }
  }

  /// Delete a configuration
  static Future<void> deleteConfiguration(int configId) async {
    final response = await ApiClient.delete('/configuration/$configId');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete configuration');
    }
  }
}

import '../api_client.dart';
import 'dart:convert';

class AIPromptTemplateService {
  /// Fetch all AI prompt templates
  static Future<List<dynamic>> getTemplates() async {
    final response = await ApiClient.get('/ai-prompt-templates/');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch AI templates');
    }
  }

  /// Fetch a single template by ID
  static Future<Map<String, dynamic>> getTemplateById(int templateId) async {
    final response = await ApiClient.get('/ai-prompt-templates/$templateId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Template not found');
    }
  }

  /// Create a new template
  static Future<Map<String, dynamic>> createTemplate(
      Map<String, dynamic> templateData) async {
    final response =
        await ApiClient.post('/ai-prompt-templates/', templateData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create AI template');
    }
  }

  /// Update a template
  static Future<Map<String, dynamic>> updateTemplate(
      int templateId, Map<String, dynamic> updates) async {
    final response =
        await ApiClient.put('/ai-prompt-templates/$templateId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update AI template');
    }
  }

  /// Delete a template
  static Future<void> deleteTemplate(int templateId) async {
    final response = await ApiClient.delete('/ai-prompt-templates/$templateId');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete AI template');
    }
  }
}
